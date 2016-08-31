#!/usr/bin/env python
#
# Copyright (C) 2008 The Android Open Source Project
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
Given a target-files zipfile, produces an image zipfile suitable for
use with 'fastboot update'.

Usage:  img_from_target_files [flags] input_target_files output_image_zip

  -z  (--bootable_zip)
      Include only the bootable images (eg 'boot' and 'recovery') in
      the output.

"""

import sys

if sys.hexversion < 0x02070000:
  print >> sys.stderr, "Python 2.7 or newer is required."
  sys.exit(1)

import errno
import os
import re
import shutil
import subprocess
import tempfile
import zipfile

import common

OPTIONS = common.OPTIONS


def CopyInfo(output_zip):
  """Copy the android-info.txt file from the input to the output."""
  common.ZipWrite(
      output_zip, os.path.join(OPTIONS.input_tmp, "OTA", "android-info.txt"),
      "android-info.txt")

def AddRadio(output_zip):
  """If they exist, add RADIO files to the output."""
  if os.path.isdir(os.path.join(OPTIONS.input_tmp, "RADIO")):
    for radio_root, radio_dirs, radio_files in os.walk(os.path.join(OPTIONS.input_tmp, "RADIO")):
      for radio_file in radio_files:
        output_zip.write(os.path.join(radio_root, radio_file), radio_file)

    # If a filesmap file exists, create a script to flash the radio images based on it
    filesmap = os.path.join(OPTIONS.input_tmp, "RADIO/filesmap")
    if os.path.isfile(filesmap):
      print "creating flash-radio.sh..."
      filesmap_data = open(filesmap, "r")
      filesmap_regex = re.compile(r'^(\S+)\s\S+\/by-name\/(\S+).*')
      tmp_flash_radio = tempfile.NamedTemporaryFile()
      tmp_flash_radio.write("#!/bin/sh\n\n")
      for filesmap_line in filesmap_data:
        filesmap_entry = filesmap_regex.search(filesmap_line)
        if filesmap_entry:
          tmp_flash_radio.write("fastboot flash %s %s\n" % (filesmap_entry.group(2), filesmap_entry.group(1)))
      tmp_flash_radio.flush()
      if os.path.getsize(tmp_flash_radio.name) > 0:
        output_zip.write(tmp_flash_radio.name, "flash-radio.sh")
      else:
        print "flash-radio.sh is empty, skipping..."
      tmp_flash_radio.close()

def main(argv):
  bootable_only = [False]

  def option_handler(o, _):
    if o in ("-z", "--bootable_zip"):
      bootable_only[0] = True
    else:
      return False
    return True

  args = common.ParseOptions(argv, __doc__,
                             extra_opts="z",
                             extra_long_opts=["bootable_zip"],
                             extra_option_handler=option_handler)

  bootable_only = bootable_only[0]

  if len(args) != 2:
    common.Usage(__doc__)
    sys.exit(1)

  OPTIONS.input_tmp, input_zip = common.UnzipTemp(args[0])
  output_zip = zipfile.ZipFile(args[1], "w", compression=zipfile.ZIP_DEFLATED)
  CopyInfo(output_zip)
  AddRadio(output_zip)

  try:
    done = False
    images_path = os.path.join(OPTIONS.input_tmp, "IMAGES")
    if os.path.exists(images_path):
      # If this is a new target-files, it already contains the images,
      # and all we have to do is copy them to the output zip.
      # Skip oem.img files since they are not needed in fastboot images.
      images = os.listdir(images_path)
      if images:
        for image in images:
          if bootable_only and image not in ("boot.img", "recovery.img"):
            continue
          if not image.endswith(".img"):
            continue
          if i == "oem.img":
            continue
          common.ZipWrite(
              output_zip, os.path.join(images_path, image), image)
        done = True

    if not done:
      # We have an old target-files that doesn't already contain the
      # images, so build them.
      import add_img_to_target_files

      OPTIONS.info_dict = common.LoadInfoDict(input_zip, OPTIONS.input_tmp)

      boot_image = common.GetBootableImage(
          "boot.img", "boot.img", OPTIONS.input_tmp, "BOOT")
      if boot_image:
        boot_image.AddToZip(output_zip)

      if OPTIONS.info_dict.get("no_recovery") != "true":
        recovery_image = common.GetBootableImage(
            "recovery.img", "recovery.img", OPTIONS.input_tmp, "RECOVERY")
        if recovery_image:
          recovery_image.AddToZip(output_zip)

      def banner(s):
        print "\n\n++++ " + s + " ++++\n\n"

      if not bootable_only:
        banner("AddSystem")
        add_img_to_target_files.AddSystem(output_zip, prefix="")
        try:
          input_zip.getinfo("VENDOR/")
          banner("AddVendor")
          add_img_to_target_files.AddVendor(output_zip, prefix="")
        except KeyError:
          pass   # no vendor partition for this device
        banner("AddUserdata")
        add_img_to_target_files.AddUserdata(output_zip, prefix="")
        banner("AddUserdataExtra")
        add_img_to_target_files.AddUserdataExtra(output_zip, prefix="")
        banner("AddCache")
        add_img_to_target_files.AddCache(output_zip, prefix="")

  finally:
    print "cleaning up..."
    common.ZipClose(output_zip)
    shutil.rmtree(OPTIONS.input_tmp)

  print "done."


if __name__ == '__main__':
  try:
    common.CloseInheritedPipes()
    main(sys.argv[1:])
  except common.ExternalError as e:
    print
    print "   ERROR: %s" % (e,)
    print
    sys.exit(1)
