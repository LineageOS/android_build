#!/usr/bin/env python
#
# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from __future__ import print_function

import cgi, os, sys


def iteritems(obj):
  if hasattr(obj, 'iteritems'):
    return obj.iteritems()
  return obj.items()


def IsDifferent(row):
  val = None
  for v in row:
    if v:
      if not val:
        val = v
      else:
        if val != v:
          return True
  return False

def main(argv):
  inputs = argv[1:]
  data = {}
  index = 0
  for input in inputs:
    f = open(input)
    lines = f.readlines()
    f.close()
    lines = [l.strip() for l in lines]
    lines = [(x_y[1],int(x_y[0])) for x_y in lines]
    for fn,sz in lines:
      if fn not in data:
        data[fn] = {}
      data[fn][index] = sz
    index = index + 1
  rows = []
  for fn,sizes in iteritems(data):
    row = [fn]
    for i in range(0,index):
      if i in sizes:
        row.append(sizes[i])
      else:
        row.append(None)
    rows.append(row)
  rows = sorted(rows, key=lambda x: x[0])
  print("""<html>
    <head>
      <style type="text/css">
        .fn, .sz, .z, .d {
          padding-left: 10px;
          padding-right: 10px;
        }
        .sz, .z, .d {
          text-align: right;
        }
        .fn {
          background-color: #ffffdd;
        }
        .sz {
          background-color: #ffffcc;
        }
        .z {
          background-color: #ffcccc;
        }
        .d {
          background-color: #99ccff;
        }
      </style>
    </head>
    <body>
  """)
  print("<table>")
  print("<tr>")
  for input in inputs:
    combo = input.split(os.path.sep)[1]
    print("  <td class='fn'>%s</td>" % cgi.escape(combo))
  print("</tr>")

  for row in rows:
    print("<tr>")
    for sz in row[1:]:
      if not sz:
        print("  <td class='z'>&nbsp;</td>")
      elif IsDifferent(row[1:]):
        print("  <td class='d'>%d</td>" % sz)
      else:
        print("  <td class='sz'>%d</td>" % sz)
    print("  <td class='fn'>%s</td>" % cgi.escape(row[0]))
    print("</tr>")
  print("</table>")
  print("</body></html>")

if __name__ == '__main__':
  main(sys.argv)


