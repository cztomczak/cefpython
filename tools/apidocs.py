# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Generate API reference index in api/ directory and in root/README.md.

TODO:
- generate api/ docs from Cython sources
- generate API-index.md, a list of all modules/functions/classes/methods
  and constants/global module variables
- generate API-categories.md: objects, handlers, settings, types
  (eg. TerminationStatus, KeyEvent, KeyEventFlags)
"""

from common import *

import glob
import os
import re


def main():
    """Main entry point."""
    api_links = generate_api_links()
    update_api_index_file(api_links)
    update_readme_file(api_links)


def update_api_index_file(api_links):
    """Create or update API-index.md file."""
    contents = ("[API categories](API-categories.md#api-categories) | " +
                "[API index](API-index.md#api-index)\n\n" +
                "# API index\n\n")
    contents += api_links
    index_file = os.path.join(API_DIR, "API-index.md")
    with open(index_file, "rb") as fo:
        current_contents = fo.read().decode("utf-8")
    if contents == current_contents:
        print("No changes: %s/%s" % (os.path.basename(API_DIR),
                                     os.path.basename(index_file)))
        return
    with open(index_file, "wb") as fo:
        fo.write(contents.encode("utf-8"))
    print("Updated: %s/%s" % (os.path.basename(API_DIR),
                              os.path.basename(index_file)))


def update_readme_file(api_links):
    """Update root/README.md with API reference links."""
    api_links = api_links.replace("](", "](api/")
    readme_file = os.path.join(ROOT_DIR, "README.md")
    with open(readme_file, "rb") as fo:
        current_contents = fo.read().decode("utf-8")
    contents = current_contents
    contents = re.sub((r"### API reference\s+"
                       r"(\s*\*[ ]\[[^\r\n\[\]]+\]\([^\r\n()]+\)\s+)*"),
                      ("### API reference\r\n\r\n{api_links}"
                       .format(api_links=api_links)),
                      contents)
    if contents == current_contents:
        print("No changes: /%s" % (os.path.basename(readme_file)))
        return
    with open(readme_file, "wb") as fo:
        fo.write(contents.encode("utf-8"))
    print("Updated: /%s" % (os.path.basename(readme_file)))


def generate_api_links():
    """Generate API index with all modules / classes / functions."""
    contents = ""
    files = glob.glob(os.path.join(API_DIR, "*.md"))
    files = sorted(files, key=lambda s: s.lower())
    for file_ in files:
        # Ignore API-index.md and API-categories.md files
        if "API-" in file_:
            continue
        with open(file_, "rb") as fo:
            md_contents = fo.read().decode("utf-8")
        md_contents = re.sub(r"```[\s\S]+?```", "", md_contents)
        matches = re.findall(r"^(#|###)\s+(.*)", md_contents,
                             re.MULTILINE)
        for match in matches:
            heading_level = match[0].strip()
            title = match[1].strip()
            title = title.strip()
            if heading_level == "#":
                indent = ""
                link = os.path.basename(file_) + "#" + get_heading_hash(title)
            elif heading_level == "###":
                indent = "  "
                link = os.path.basename(file_) + "#" + get_heading_hash(title)
                # hash generation needs complete title. Now we can strip some.
                title = re.sub(r"\(.*", r"", title)
            else:
                assert False, "Heading level unsupported"
            contents += (indent + "* " + "[%s](%s)\n" % (title, link))
    return contents


def get_heading_hash(title):
    """Get a link hash for headings H1, H2, H3."""
    hash_ = title.lower()
    hash_ = re.sub(r"[^a-z0-9_\- ]+", r"", hash_)
    hash_ = hash_.replace(" ", "-")
    hash_ = re.sub(r"[-]+", r"-", hash_)
    hash_ = re.sub(r"-$", r"", hash_)
    return hash_


if __name__ == "__main__":
    main()
