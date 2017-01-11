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

Usage:  sign_release_zip [flags] input_zip output_zip

  -k (--package_key) <key> Key to use to sign the package (default is
      "build/target/product/security/testkey").
"""
import sys

import common

OPTIONS = common.OPTIONS

OPTIONS.package_key = "build/target/product/security/testkey"

def SignOutput(input_zip_name, output_zip_name):
  key_passwords = common.GetKeyPasswords([OPTIONS.package_key])
  pw = key_passwords[OPTIONS.package_key]

  common.SignFile(input_zip_name, output_zip_name, OPTIONS.package_key, pw,
                  whole_file=True)


def main(argv):

  def option_handler(o, a):
    if o in ("-k", "--package_key"):
      OPTIONS.package_key = a
    else:
      return False
    return True

  args = common.ParseOptions(argv, __doc__,
                             extra_opts="k:",
                             extra_long_opts=[
                                 "package_key=",
                             ], extra_option_handler=option_handler)
  if len(args) != 2:
    common.Usage(__doc__)
    sys.exit(1)

  SignOutput(args[0], args[1])


if __name__ == '__main__':
  try:
    main(sys.argv[1:])
  except common.ExternalError as e:
    print()
    print("   ERROR: %s" % e)
    print()
    sys.exit(1)
