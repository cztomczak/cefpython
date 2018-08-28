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
import subprocess


def main():
    """Main entry point."""
    # Call toc.py for docs/, api/, examples/ and examples/snippets/
    # directories.
    toc_dirs = [API_DIR, DOCS_DIR, EXAMPLES_DIR, SNIPPETS_DIR]
    for toc_dir in toc_dirs:
        print("Running toc.py in {}/ dir".format(os.path.basename(toc_dir)))
        retcode = subprocess.call([sys.executable,
                                   os.path.join(TOOLS_DIR, "toc.py"),
                                   toc_dir])
        assert retcode == 0, "Executing toc.py failed"

    # Generate API reference in api/ dir and in root/README.md
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
    """Update root/README.md with API categories and index links.
    API categories are copied from API-categories.md which is
    generated manually. """
    api_links = api_links.replace("](", "](api/")
    readme_file = os.path.join(ROOT_DIR, "README.md")
    with open(readme_file, "rb") as fo:
        readme_contents = fo.read().decode("utf-8")
    contents = readme_contents

    # Update API categories
    categories_file = os.path.join(API_DIR, "API-categories.md")
    with open(categories_file, "rb") as fo:
        categories_contents = fo.read().decode("utf-8")
        match = re.search(r"# API categories\s+(###[\s\S]+)",
                          categories_contents)
        assert match and match.group(1), "Failed to parse API categories"
        categories_contents = match.group(1)
        categories_contents = categories_contents.replace("###", "####")
        categories_contents = categories_contents.replace("](", "](api/")
    re_find = r"### API categories[\s\S]+### API index"
    assert re.search(re_find, readme_contents), ("API categories not found"
                                                 " in README")
    contents = re.sub(re_find,
                      (u"### API categories\r\n\r\n{categories_contents}"
                       u"\r\n### API index"
                       .format(categories_contents=categories_contents)),
                      contents)

    # Update API index
    re_find = (r"### API index\s+"
               r"(\s*\*[ ]\[[^\r\n\[\]]+\]\([^\r\n()]+\)\s+)*")
    assert re.search(re_find, readme_contents), ("API index not found"
                                                 " in README")
    contents = re.sub(re_find,
                      (u"### API index\r\n\r\n{api_links}"
                       .format(api_links=api_links)),
                      contents)

    if contents == readme_contents:
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
        md_contents = re.sub(u"```[\\s\\S]+?```", u"", md_contents)
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
