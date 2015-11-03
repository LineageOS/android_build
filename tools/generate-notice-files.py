#!/usr/bin/env python
#
# Copyright (C) 2012 The Android Open Source Project
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
Usage: generate-notice-files [plain text output file] [html output file] [file title] [directory of notices]

Generate the Android notice files, including both text and html files.

-h to display this usage message and exit.
"""

from __future__ import print_function

from collections import defaultdict
import getopt
import hashlib
import itertools
import os
import os.path
import re
import sys

MD5_BLOCKSIZE = 1024 * 1024
HTML_ESCAPE_TABLE = {
    "&": "&amp;",
    '"': "&quot;",
    "'": "&apos;",
    ">": "&gt;",
    "<": "&lt;",
    }

try:
  opts, args = getopt.getopt(sys.argv[1:], "h")
except getopt.GetoptError as err:
    print(str(err))
    print(__doc__)
    sys.exit(2)

for o, a in opts:
  if o == "-h":
    print(__doc__)
    sys.exit(2)
  else:
    print("unhandled option %s" % o)

if len(args) != 4:
    print("""need exactly four arguments, the two output files, the file title
             and the directory containing notices, not %d""" % len(args))
    print(__doc__)
    sys.exit(1)

def hexify(s):
    return ("%02x"*len(s)) % tuple(map(ord, s))

def md5sum(filename):
    """Calculate an MD5 of the file given by FILENAME,
    and return hex digest as a string.
    Output should be compatible with md5sum command"""

    f = open(filename, "rb")
    sum = hashlib.md5()
    while 1:
        block = f.read(MD5_BLOCKSIZE)
        if not block:
            break
        sum.update(block)
    f.close()
    return hexify(sum.digest())


def html_escape(text):
    """Produce entities within text."""
    return "".join(HTML_ESCAPE_TABLE.get(c,c) for c in text)

HTML_OUTPUT_CSS="""
<style type="text/css">
body { padding: 0; font-family: sans-serif; }
.same-license { background-color: #eeeeee; border-top: 20px solid white; padding: 10px; }
.label { font-weight: bold; }
.file-list { margin-left: 1em; color: blue; }
</style>
"""

def combine_notice_files_html(file_hash, input_dir, output_filename):
    """Combine notice files in FILE_HASH and output a HTML version to OUTPUT_FILENAME."""

    SRC_DIR_STRIP_RE = re.compile(input_dir + "(/.*).txt")

    # Set up a filename to row id table (anchors inside tables don't work in
    # most browsers, but href's to table row ids do)
    id_table = {}
    id_count = 0
    for value in file_hash.values():
        for filename in value:
             id_table[filename] = id_count
        id_count += 1

    # Open the output file, and output the header pieces
    output_file = open(output_filename, "wb")

    print(output_file, "<html><head>", file=output_file)
    print(HTML_OUTPUT_CSS, file=output_file)
    print('</head><body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">', file=output_file)

    # Output our table of contents
    print('<div class="toc">', file=output_file)
    print("<ul>", file=output_file)

    # Flatten the list of lists into a single list of filenames
    sorted_filenames = sorted(itertools.chain.from_iterable(file_hash.values()))

    # Print out a nice table of contents
    for filename in sorted_filenames:
        stripped_filename = SRC_DIR_STRIP_RE.sub(r"\1", filename)
        print('<li><a href="#id%d">%s</a></li>' % (id_table.get(filename), stripped_filename), file=output_file)

    print("</ul>", file=output_file)
    print("</div><!-- table of contents -->", file=output_file)
    # Output the individual notice file lists
    print('<table cellpadding="0" cellspacing="0" border="0">', file=output_file)
    for value in file_hash.values():
        print('<tr id="id%d"><td class="same-license">' % id_table.get(value[0]), file=output_file)
        print('<div class="label">Notices for file(s):</div>', file=output_file)
        print('<div class="file-list">', file=output_file)
        for filename in sorted(value):
            print("%s <br/>" % (SRC_DIR_STRIP_RE.sub(r"\1", filename)), file=output_file)
        print("</div><!-- file-list -->", file=output_file)
        print(file=output_file)
        print('<pre class="license-text">', file=output_file)
        print(html_escape(open(value[0]).read()), file=output_file)
        print("</pre><!-- license-text -->", file=output_file)
        print("</td></tr><!-- same-license -->", file=output_file)
        print(file=output_file)
        print(file=output_file)
        print(file=output_file)

    # Finish off the file output
    print( "</table>", file=output_file)
    print("</body></html>", file=output_file)
    output_file.close()

def combine_notice_files_text(file_hash, input_dir, output_filename, file_title):
    """Combine notice files in FILE_HASH and output a text version to OUTPUT_FILENAME."""

    SRC_DIR_STRIP_RE = re.compile(input_dir + "(/.*).txt")
    output_file = open(output_filename, "wb")
    print(file_title, file=output_file)
    for value in file_hash.values():
      print("============================================================", file=output_file)
      print("Notices for file(s):", file=output_file)
      for filename in sorted(value):
        print(SRC_DIR_STRIP_RE.sub(r"\1", filename), file=output_file)
      print("------------------------------------------------------------", file=output_file)
      print(open(value[0]).read(), file=output_file)
    output_file.close()

def main(args):
    txt_output_file = args[0]
    html_output_file = args[1]
    file_title = args[2]

    # Find all the notice files and md5 them
    input_dir = os.path.normpath(args[3])
    files_with_same_hash = defaultdict(list)
    for root, dir, files in os.walk(input_dir):
        for file in files:
            if file.endswith(".txt"):
                filename = os.path.join(root, file)
                file_md5sum = md5sum(filename)
                files_with_same_hash[file_md5sum].append(filename)


    print("Combining NOTICE files into HTML")
    combine_notice_files_html(files_with_same_hash, input_dir, html_output_file)
    print("Combining NOTICE files into text")
    combine_notice_files_text(files_with_same_hash, input_dir, txt_output_file, file_title)

if __name__ == "__main__":
    main(args)
