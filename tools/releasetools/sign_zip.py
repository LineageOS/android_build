#!/usr/bin/env python
#
# Copyright (C) 2017 The LineageOS Project
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
Signs the given zip with the given key producing a new zip.

Usage:  sign_release_zip key_name input_zip output_zip
"""
import sys

import common


def SignOutput(package_key, input_zip_name, output_zip_name):
  key_passwords = common.GetKeyPasswords([package_key])
  pw = key_passwords[package_key]

  common.SignFile(input_zip_name, output_zip_name, package_key, pw,
                  whole_file=True)


def main(argv):
  args = common.ParseOptions(argv, __doc__)
  if len(args) != 3:
    common.Usage(__doc__)
    sys.exit(1)

  SignOutput(argv[0], argv[1], argv[2])


if __name__ == '__main__':
  try:
    main(sys.argv[1:])
  except common.ExternalError as e:
    print()
    print("   ERROR: %s" % e)
    print()
    sys.exit(1)
