# Copyright (C) 2014 The Android Open Source Project
# Copyright (C) 2020 The Android Open Kang Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function

import array
import copy
import functools
import heapq
import itertools
import multiprocessing
import os
import os.path
import re
import subprocess
import sys
import threading
from collections import deque, OrderedDict
from hashlib import sha1
import zipfile

import common
from rangelib import RangeSet


__all__ = ["FileSystemDiff"]


def DataHash(data):
  hasher = sha1()
  hasher.update(data)
  return hasher.hexdigest()

def ComputePatch(src_data, tgt_data):
  src_filename = common.MakeTempFile(prefix='src-')
  f = open(src_filename, 'w')
  f.write(src_data)
  f.close()
  tgt_filename = common.MakeTempFile(prefix='tgt-')
  f = open(tgt_filename, 'w')
  f.write(tgt_data)
  f.close()
  patch_filename = common.MakeTempFile(prefix='patch-')

  diff_argv = ['bsdiff', src_filename, tgt_filename, patch_filename]
  child = subprocess.Popen(diff_argv, stdout=None, stderr=None)
  child.communicate()
  if child.returncode != 0:
    raise RuntimeError("Failed to run %s" % (" ".join(diff_argv)))

  return patch_filename

class FsNode(object):
  S_IFCHR = 0020000 # Unsupported
  S_IFDIR = 0040000
  S_IFBLK = 0060000 # Unsupported
  S_IFREG = 0100000
  S_IFLNK = 0120000

  S_IFMT  = 0170000
  S_INFMT =   07777

  @classmethod
  def GetType(cls, mode):
    type = (mode & FsNode.S_IFMT)
    if type == 0:
      type = FsNode.S_IFREG
    return type
  @classmethod
  def GetPerm(cls, mode):
    return (mode & FsNode.S_INFMT)

  def __init__(self, parent, name, type):
    self._parent = parent
    self._name = name
    self._type = type
    self._uid = 0
    self._gid = 0
    self._mode = 0

  def parent(self, val=None):
    if val is not None:
      self._parent = val
    return self._parent
  def name(self, val=None):
    if val is not None:
      self._name = val
    return self._name
  def type(self, val=None):
    if val is not None:
      self._type = val
    return self._type
  def uid(self, val=None):
    if val is not None:
      self._uid = val
    return self._uid
  def gid(self, val=None):
    if val is not None:
      self._gid = val
    return self._gid
  def mode(self, val=None):
    if val is not None:
      self._mode = val
    return self._mode

class SecurableFsNode(FsNode):
  def __init__(self, parent, name, type):
    FsNode.__init__(self, parent, name, type)
    self._selabel = ''
    self._capabilities = 0x0

  def selabel(self, val=None):
    if val is not None:
      self._selabel = val
    return self._selabel
  def capabilities(self, val=None):
    if val is not None:
      self._capabilities = val
    return self._capabilities

class FsDir(SecurableFsNode):
  def __init__(self, parent, name):
    SecurableFsNode.__init__(self, parent, name, FsNode.S_IFDIR)
    self._entries = {}

  def entries(self):
    return self._entries

  def empty(self):
    return len(self._entries) == 0

  def get_entry(self, name):
      return self._entries[name]

  def add_entry(self, node):
    self._entries[node.name()] = node

  def dirs(self):
    nodes = {}
    for name, node in self._entries.items():
      if node.type() == FsNode.S_IFDIR:
        nodes[name] = node
    return nodes

  def files(self):
    nodes = {}
    for name, node in self._entries.items():
      if node.type() != FsNode.S_IFDIR:
        nodes[name] = node
    return nodes

class FsFile(SecurableFsNode):
  def __init__(self, parent, name):
    SecurableFsNode.__init__(self, parent, name, FsNode.S_IFREG)
    self._hash = None

  def hash(self, val=None):
    if not val is None:
      self._hash = val
    return self._hash

class FsSymLink(FsNode):
  def __init__(self, parent, name, target):
    FsNode.__init__(self, parent, name, FsNode.S_IFLNK)
    self._target = target

  def target(self, val=None):
    if val is not None:
      self._target = val
    return self._target

class FileSystem(object):
  def __init__(self):
    self._root = FsDir(None, '')

  @classmethod
  def _ParseFilesystemConfig(cls, zip, partition):
    fscfg = dict()
    prefix = "%s/" % (partition.upper())
    prefixlen = len(prefix)
    if partition == 'system':
      filename = "META/filesystem_config.txt"
    else:
      filename = "META/%s_filesystem_config.txt" % (partition)
    with zip.open(filename, 'r') as f:
      # First line has empty name for root node.  Discard it.
      # XXX: What if the root metadata changes?
      line = f.readline()
      if not line.startswith(' '):
        raise RuntimeError("Cannot parse filesystem config %s" % (filename))
      # Parse the rest of the file.
      for line in f:
        fields = line.rstrip('\n').split()
        if len(fields) < 6:
          raise RuntimeError("Cannot parse filesystem config %s" % (filename))
        name = fields[0][prefixlen:]
        obj = dict()
        obj['uid'] = int(fields[1])
        obj['gid'] = int(fields[2])
        obj['mode'] = int(fields[3], 8)
        for field in fields[4:]:
          # If this fails, it is likely the filename has spaces.
          # This could be handled but it does not appear to be allowed.
          k,v = field.split('=')
          obj[k] = v
        fscfg[name] = obj

    return fscfg

  # Note: ZipInfo.external_attr encodes the file mode as per:
  #   https://unix.stackexchange.com/questions/14705/the-zip-formats-external-file-attribute
  # Shift external_attr right 16 bits to get the Unix st_mode.
  #
  # Need to check permissions, particularly for symlinks.
  # Really, though, we may not even need this info.  Directories
  # can be implied from first appearance in filesystem_config.txt
  # and prehaps symlinks could be handled another way...?
  @classmethod
  def _LoadZipInfo(cls, zip, partition):
    zi = dict()
    prefix = "%s/"  % (partition.upper())
    prefixlen = len(prefix)
    for info in zip.infolist():
      if not info.filename.startswith(prefix):
        continue
      if info.filename == prefix:
        continue
      name = info.filename[prefixlen:].rstrip('/')
      zi[name] = info
    return zi

  @classmethod
  def from_target_files_zip(cls, zip, partition):
    fsinfo = FileSystem._LoadZipInfo(zip, partition)
    fscfg = FileSystem._ParseFilesystemConfig(zip, partition)
    if len(fsinfo) != len(fscfg):
      raise RuntimeError("Zip info does not match filesystem info")
    fs = cls()
    for k in sorted(fsinfo.keys()):
      segs = k.split('/')
      info = fsinfo[k]
      cfg = fscfg[k]
      type = FsNode.GetType(info.external_attr >> 16)
      if type == 0:
        type = FsNode.S_IFREG
      parent = fs.root()
      for name in segs[0:len(segs)-1]:
        parent = parent.get_entry(name)
      name = segs[-1]
      if type == FsNode.S_IFDIR:
        node = FsDir(parent, name)
      else:
        if type == FsNode.S_IFLNK:
          buf = zip.open(info).read()
          node = FsSymLink(parent, name, buf)
        else:
          node = FsFile(parent, name)
      node.uid(cfg['uid'])
      node.gid(cfg['gid'])
      node.mode(cfg['mode'])
      if isinstance(node, SecurableFsNode):
        node.selabel(cfg['selabel'])
        node.capabilities(int(cfg['capabilities'], 16))
      parent.add_entry(node)
    return fs

  def root(self):
    return self._root


# FileSystemDiff works on two targetfiles zip files.
class FileSystemDiff(object):
  def __init__(self, partition, tgt, src=None, threads=None):
    if threads is None:
      threads = multiprocessing.cpu_count() // 2
      if threads == 0:
        threads = 1
    self.threads = threads

    self.partition = partition
    self.tgt_zip = tgt
    self.tgt_fs = FileSystem.from_target_files_zip(self.tgt_zip, partition)
    if src is None:
      self.src_zip = None
      self.src_fs = FileSystem()
    else:
      self.src_zip = src
      self.src_fs = FileSystem.from_target_files_zip(self.src_zip, partition)

  # XXX: Need to handle all cases here.  In particular:
  #  - File created
  #  - File deleted
  #  - File data changed
  #  - File metadata changed
  #  - Symlink target changed
  #  - Node changes type
  def _Compute(self, root, tgt, src):
    if tgt is None:
      tgt_dirs = {}
      tgt_files = {}
    else:
      tgt_dirs = tgt.dirs()
      tgt_files = tgt.files()
    if src is None:
      src_dirs = {}
      src_files = {}
    else:
      src_dirs = src.dirs()
      src_files = src.files()

    sys.stderr.write("Compute %s%s ...\n" % (self.fs_root, root))

    # Handle directory deletions and changes
    for src_name, src_dir in src_dirs.items():
      dirname = "%s/%s" % (root, src_name)
      fs_dirname = "%s%s" % (self.fs_root, dirname)
      if not src_name in tgt_dirs:
        #self.script.DeleteTree("%s/%s" % (root, src_name))
        self._Compute(dirname, None, src_dir)
        self.script.DeleteDirectory(fs_dirname)
        continue
      tgt_dir = tgt_dirs[src_name]
      if tgt_dir.type() != src_dir.type():
        #self.script.DeleteTree("%s/%s" % (root, src_name))
        self._Compute("%s/%s" % (root, src_name), None, src_dir)
        self.script.DeleteDirectory(fs_dirname)
        continue
      if (src_dir.uid() != tgt_dir.uid() or
          src_dir.gid() != tgt_dir.gid() or
          src_dir.mode() != tgt_dir.mode() or
          src_dir.selabel() != tgt_dir.selabel() or
          src_dir.capabilities() != tgt_dir.capabilities()):
        self.script.ChangeMetadata(fs_dirname,
            tgt_dir.uid(), tgt_dir.gid(), tgt_dir.mode(),
            tgt_dir.selabel(), tgt_dir.capabilities())
      # Recurse
      self._Compute(dirname, tgt_dir, src_dir)

    # Handle directory creations
    for tgt_name, tgt_dir in tgt_dirs.items():
      dirname = "%s/%s" % (root, tgt_name)
      fs_dirname = "%s%s" % (self.fs_root, dirname)
      if tgt_name in src_dirs:
        src_dir = src_dirs[tgt_name]
        if src_dir.type() == tgt_dir.type():
          continue
      self.script.CreateDirectory(fs_dirname,
          tgt_dir.uid(), tgt_dir.gid(), tgt_dir.mode(),
          tgt_dir.selabel(), tgt_dir.capabilities())
      self._Compute(dirname, tgt_dir, None)

    # Handle file deletions and changes
    for src_name, src_file in src_files.items():
      filename = "%s/%s" % (root, src_name)
      fs_filename = "%s%s" % (self.fs_root, filename)
      if not src_name in tgt_files:
        self.script.DeleteFile(fs_filename)
        continue
      tgt_file = tgt_files[src_name]
      if tgt_file.type() != src_file.type():
        self.script.DeleteFile(fs_filename)
        continue
      if src_file.type() == FsNode.S_IFLNK:
        if src_file.target() != tgt_file.target():
          self.script.Unlink(fs_filename)
          self.script.CreateSymbolicLink(tgt_file.target(), fs_filename,
              tgt_file.uid(), tgt_file.gid())
        if (src_file.uid() != tgt_file.uid() or
            src_file.gid() != tgt_file.gid()):
          self.script.ChangeOwner(fs_filename, tgt_file.uid(), tgt_file.gid())
      else:
        zip_filename = "%s%s" % (self.zip_partition, filename)
        zip_patch_filename = "%s.patch" % (fs_filename[1:])
        src_data = self.src_zip.open(zip_filename).read()
        src_hash = DataHash(src_data)
        tgt_data = self.tgt_zip.open(zip_filename).read()
        tgt_hash = DataHash(tgt_data)
        if src_data != tgt_data:
          patch_filename = ComputePatch(src_data, tgt_data)
          self.script.PatchFile(fs_filename, zip_patch_filename, src_hash)
          self.out_zip.write(patch_filename, zip_patch_filename)
        if (src_file.uid() != tgt_file.uid() or
            src_file.gid() != tgt_file.gid() or
            src_file.mode() != tgt_file.mode() or
            src_file.selabel() != tgt_file.selabel() or
            src_file.capabilities() != tgt_file.capabilities()):
          self.script.ChangeMetadata(fs_filename,
              tgt_file.uid(), tgt_file.gid(), tgt_file.mode(),
              tgt_file.selabel(), tgt_file.capabilities())

    # Handle file creations
    for tgt_name, tgt_file in tgt_files.items():
      filename = "%s/%s" % (root, tgt_name)
      fs_filename = "%s%s" % (self.fs_root, filename)
      if tgt_name in src_files:
        src_file = src_files[tgt_name]
        if src_file.type() == tgt_file.type():
          continue
      if tgt_file.type() == FsNode.S_IFDIR:
        self.script.CreateDirectory(fs_filename,
            tgt_file.uid(), tgt_file.gid(), tgt_file.mode(),
            tgt_file.selabel(), tgt_file.capabilities())
        self._Compute(filename, tgt_dir, None)
      elif tgt_file.type() == FsNode.S_IFLNK:
        self.script.CreateSymbolicLink(tgt_file.target(), fs_filename,
            tgt_file.uid(), tgt_file.gid())
      else:
        zip_filename = "%s%s" % (self.zip_partition, filename)
        zip_data_filename = fs_filename[1:]
        buf = self.tgt_zip.open(zip_filename).read()
        extracted_filename = common.MakeTempFile(prefix='extract-')
        f = open(extracted_filename, 'w')
        f.write(buf)
        f.close()
        self.script.CreateFile(fs_filename, zip_data_filename,
            tgt_file.uid(), tgt_file.gid(), tgt_file.mode(),
            tgt_file.selabel(), tgt_file.capabilities())
        self.out_zip.write(extracted_filename, zip_data_filename)

  def Compute(self, script, out):
    self.script = script
    self.out_zip = out

    self.zip_partition = self.partition.upper()
    self.fs_root = "/%s" % (self.partition)
    self._Compute('', self.tgt_fs.root(), self.src_fs.root())

if __name__ == '__main__':
  print("main")
  differ = FileSystemDiff(sys.argv[1], sys.argv[2])

  import edify_generator
  script = edify_generator.EdifyGenerator(3, {})
  out_zip = zipfile.ZipFile('diff.zip', 'w')
  differ.Compute(script, out_zip)

  sys.exit(0)

  print("load system")
  src_system_fs = FileSystem.from_target_files_zip(src_zip, 'system')
  tgt_system_fs = FileSystem.from_target_files_zip(tgt_zip, 'system')
  print("load vendor")
  src_vendor_fs = FileSystem.from_target_files_zip(src_zip, 'vendor')
  tgt_vendor_fs = FileSystem.from_target_files_zip(tgt_zip, 'vendor')
