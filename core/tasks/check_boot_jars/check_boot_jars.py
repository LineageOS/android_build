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
import xml.etree.ElementTree


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

def CheckDexJar(dexdump_path, allow_list_path, jar):
  """Check a dex jar file.
  """
  # Use dexdump to generate the XML representation of the dex jar file.
  p = subprocess.Popen(args='%s -l xml %s' % (dexdump_path, jar),
      stdout=subprocess.PIPE, shell=True)
  stdout, _ = p.communicate()
  if p.returncode != 0:
    return False

  packages = 0
  try:
    # TODO(b/172063475) - improve performance
    root = xml.etree.ElementTree.fromstring(stdout)
  except xml.etree.ElementTree.ParseError as e:
    print >> sys.stderr, 'Error processing jar %s - %s' % (jar, e)
    print >> sys.stderr, stdout
    return False
  for package_elt in root.iterfind('package'):
    packages += 1
    package_name = package_elt.get('name')
    if not package_name or not allow_list_re.match(package_name):
      # Report the name of a class in the package as it is easier to navigate to
      # the source of a concrete class than to a package which is often required
      # to investigate this failure.
      class_name = package_elt[0].get('name')
      if package_name != "":
        class_name = package_name + "." + class_name
      print >> sys.stderr, ('Error: %s contains class file %s, whose package name "%s" is empty or'
                            ' not in the allow list %s of packages allowed on the bootclasspath.'
                            % (jar, class_name, package_name, allow_list_path))
      return False
  if packages == 0:
    print >> sys.stderr, ('Error: %s does not contain any packages.' % jar)
    return False
  return True


def CheckJar(dexdump_path, allow_list_path, jar):
  """Check a jar file.
  """
  # Get the list of files inside the jar file.
  p = subprocess.Popen(args='jar tf %s' % jar,
      stdout=subprocess.PIPE, shell=True)
  stdout, _ = p.communicate()
  if p.returncode != 0:
    return False
  items = stdout.split()
  if 'classes.dex' in items:
    return CheckDexJar(dexdump_path, allow_list_path, jar)
  classes = 0
  for f in items:
    if f.endswith('.class'):
      classes += 1
      package_name = os.path.dirname(f)
      package_name = package_name.replace('/', '.')
      if not package_name or not allow_list_re.match(package_name):
        print >> sys.stderr, ('Error: %s contains class file %s, whose package name %s is empty or'
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
    if not CheckJar(dexdump_path, allow_list_path, jar):
      passed = False
  if not passed:
    return 1

  return 0


if __name__ == '__main__':
  sys.exit(main(sys.argv[1:]))
