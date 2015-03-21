#!/usr/bin/env python
#
# Copyright (C) 2015 Cyanogen, Inc.
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

"""
Compress files for transparent kernel decompression

Usage:  compress_files extension directory

"""
import os
import os.path
import subprocess
import sys
import commands
import shutil
import tempfile
from stat import *
import gzip
import xattr

def RunCommand(cmd):
  """ Echo and run the given command

  Args:
    cmd: the command represented as a list of strings.
  Returns:
    The exit code.
  """
  print "Running: ", " ".join(cmd)
  p = subprocess.Popen(cmd)
  p.communicate()
  return p.returncode

def IsGzip(content):
  hdr = content[0:2]
  if ord(content[0]) != 037:
    return False
  if ord(content[1]) != 0213 and ord(content[1]) != 0236:
    return False
  if ord(content[2]) != 8:
    return False
  return True

def CompressFile(pathname):
  """Compress a file.

  Args:
    pathname: File to compress.

  Returns:
    True iff the file is compressed successfully.
  """
  st = os.stat(pathname)
  f = open(pathname, 'r')
  content = f.read()
  if len(content) != st.st_size:
    print "Failed to read %s" % (pathname)
    return False

  if IsGzip(content):
    # Already compressed
    return True

  # XXX: handle errors
  gzpathname = "%s.gz" % (pathname)
  print "compress %s" % (pathname)
  gzf = gzip.open(gzpathname, 'wb')
  gzf.write(content)
  gzf.close()
  os.chown(gzpathname, st.st_uid, st.st_gid)
  xattr.setxattr(gzpathname, "user.compression.method", "gzip")
  xattr.setxattr(gzpathname, "user.compression.realsize", "%d" % (st.st_size))
  os.rename(gzpathname, pathname)

  return True

def CompressFiles(ext, dir):
  """Compress files named *.ext under dir.

  Args:
    ext: File extension to compress.
    dir: Directory in which to search.

  Returns:
    True iff the files are compressed successfully.
  """
  in_size = 0
  out_size = 0
  for root, subdirs, files in os.walk(dir):
    for f in files:
      if not f.endswith(".%s" % (ext)):
        continue
      pathname = os.path.join(root, f)
      if os.path.islink(pathname):
        continue
      size = os.stat(pathname).st_size
      ret = CompressFile(pathname)
      if not ret:
        return ret
      gzsize = os.stat(pathname).st_size
      in_size += size
      out_size += gzsize

  print "in_size=%d" % (in_size)
  print "out_size=%d" % (out_size)

  return True


def main(argv):
  if len(argv) != 2:
    print __doc__
    sys.exit(1)

  ext = argv[0]
  dir = argv[1]

  print "compress_files: ext=%s dir=%s" % (ext, dir)

  if not CompressFiles(ext, dir):
    print >> sys.stderr, "error: failed to compress %s files in %s" % (ext, dir)
    sys.exit(1)


if __name__ == '__main__':
  main(sys.argv[1:])
