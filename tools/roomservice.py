#!/usr/bin/env python
import os
import sys
import urllib2
import json
import netrc, base64
from xml.etree import ElementTree

product = sys.argv[1];
device = product[product.index("_") + 1:]
print "Device %s not found. Attempting to retrieve device repository from CyanogenMod Github (http://github.com/CyanogenMod)." % device

repositories = []

try:
    authtuple = netrc.netrc().authenticators("api.github.com")

    if authtuple:
        githubauth = base64.encodestring('%s:%s' % (authtuple[0], authtuple[2])).replace('\n', '')
    else:
        githubauth = None
except:
    githubauth = None

page = 1
while True:
    githubreq = urllib2.Request("https://api.github.com/users/CyanogenMod/repos?per_page=100&page=%d" % page)
    if githubauth:
        githubreq.add_header("Authorization","Basic %s" % githubauth)
    result = json.loads(urllib2.urlopen(githubreq).read())
    if len(result) == 0:
        break
    for res in result:
        repositories.append(res)
    page = page + 1

# in-place prettyprint formatter
def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

for repository in repositories:
    repo_name = repository['name']
    if repo_name.startswith("android_device_") and repo_name.endswith("_" + device):
        print "Found repository: %s" % repository['name']
        manufacturer = repo_name.replace("android_device_", "").replace("_" + device, "")
        
        try:
            lm = ElementTree.parse(".repo/local_manifest.xml")
            lm = lm.getroot()
        except:
            lm = ElementTree.Element("manifest")
        
        for child in lm.getchildren():
            if child.attrib['name'].endswith("_" + device):
                print "Duplicate device '%s' found in local_manifest.xml." % child.attrib['name']
                sys.exit()

        repo_path = "device/%s/%s" % (manufacturer, device)
        project = ElementTree.Element("project", attrib = { "path": repo_path, "remote": "github", "name": "CyanogenMod/%s" % repository['name'], "revision": "gingerbread" })
        lm.append(project)

        indent(lm, 0)
        raw_xml = ElementTree.tostring(lm)
        raw_xml = '<?xml version="1.0" encoding="UTF-8"?>\n' + raw_xml

        f = open('.repo/local_manifest.xml', 'w')
        f.write(raw_xml)
        f.close()
        
        print "Syncing repository to retrieve project."
        os.system('repo sync %s' % repo_path)
        print "Done!"
        sys.exit()

print "Repository for %s not found in the CyanogenMod Github repository list. If this is in error, you may need to manually add it to your local_manifest.xml." % device
