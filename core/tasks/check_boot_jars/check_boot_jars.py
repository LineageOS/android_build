#!/usr/bin/env python

"""
Check boot jars.

Usage: check_boot_jars.py <dexdump_path> <package_allow_list_file> <jar1> <jar2> ...
"""
import logging
import os.path
import re
import subprocess
import sys


# The compiled allow list RE.
allow_list_re = None


def LoadAllowList(filename):
  """ Load and compile allow list regular expressions from filename.
  """
  lines = []
  with open(filename, 'r') as f:
    for line in f:
      line = line.strip()
      if not line or line.startswith('#'):
        continue
      lines.append(line)
  combined_re = r'^(%s)$' % '|'.join(lines)
  global allow_list_re
  try:
    allow_list_re = re.compile(combined_re)
  except re.error:
    logging.exception(
        'Cannot compile package allow list regular expression: %r',
        combined_re)
    allow_list_re = None
    return False
  return True

# Pattern that matches the class descriptor in a "Class descriptor" line output
# by dexdump and extracts the class name - with / instead of .
CLASS_DESCRIPTOR_RE = re.compile("'L([^;]+);'")

def CheckDexJar(dexdump_path, allow_list_path, jar):
  """Check a dex jar file.
  """
  # Get the class descriptor lines in the dexdump output. This filters out lines
  # that do not contain class descriptors to reduce the size of the data read by
  # this script.
  p = subprocess.Popen(args='%s %s | grep "Class descriptor "' % (dexdump_path, jar),
      stdout=subprocess.PIPE, shell=True)
  stdout, _ = p.communicate()
  if p.returncode != 0:
    return False
  # Split the output into lines
  lines = stdout.split('\n')
  classes = 0
  for line in lines:
    # The last line will be empty
    if line == '':
      continue
    # Try and find the descriptor on the line. Fail immediately if it cannot be found
    # as the dexdump output has probably changed.
    found = CLASS_DESCRIPTOR_RE.search(line)
    if not found:
      print >> sys.stderr, ('Could not find class descriptor in line `%s`' % line)
      return False
    # Extract the class name (using / instead of .) from the class descriptor line
    f = found.group(1)
    classes += 1
    package_name = os.path.dirname(f)
    package_name = package_name.replace('/', '.')
    if not package_name or not allow_list_re.match(package_name):
      print >> sys.stderr, ('Error: %s contains class file %s, whose package name "%s" is empty or'
                            ' not in the allow list %s of packages allowed on the bootclasspath.'
                            % (jar, f, package_name, allow_list_path))
      return False
  if classes == 0:
    print >> sys.stderr, ('Error: %s does not contain any class files.' % jar)
    return False
  return True


def main(argv):
  if len(argv) < 3:
    print __doc__
    return 1
  dexdump_path = argv[0]
  allow_list_path = argv[1]

  if not LoadAllowList(allow_list_path):
    return 1

  passed = True
  for jar in argv[2:]:
    if not CheckDexJar(dexdump_path, allow_list_path, jar):
      passed = False
  if not passed:
    return 1

  return 0


if __name__ == '__main__':
  sys.exit(main(sys.argv[1:]))
