# Copyright (c) 2016 CEF Python, see the Authors file. All rights reserved.
# TODO: sort objects by name in API-index.md

"""Generate API docs from sources.

TODO:
- generate api/ docs from Cython sources
- generate API-index.md, a list of all modules/functions/classes/methods
  and constants/global module variables
- generate API-categories.md: objects, handlers, settings, types
  (eg. TerminationStatus, KeyEvent, KeyEventFlags)
"""

import os
import glob
import re

# Constants
API_DIR = os.path.join(os.path.dirname(__file__), "..", "api")


def main():
    """Main entry point."""
    api_index()


def api_index():
    """Generate API-index.md file with all modules/classes/funcs/methods."""
    files = glob.glob(os.path.join(API_DIR, "*.md"))
    contents = ("[API categories](API-categories.md) | " +
                "[API index](API-index.md)\n\n" +
                "# API index\n\n")
    for file_ in files:
        if "API-" in file_:
            continue
        with open(file_, "rb") as fo:
            raw_mdcontents = fo.read()

        parsable_mdcontents = re.sub(r"```[\s\S]+?```", "", raw_mdcontents)
        allmatches = re.findall(r"^(#|###)\s+(.*)", parsable_mdcontents,
                                re.MULTILINE)
        for allmatch in allmatches:
            hlevel = allmatch[0].strip()
            title = allmatch[1].strip()
            title = title.strip()
            if hlevel == "#":
                indent = ""
                link = os.path.basename(file_)
            elif hlevel == "###":
                indent = "  "
                link = os.path.basename(file_) + "#" + headinghash(title)
                # hash generation needs complete title. Now we can strip some.
                title = re.sub(r"\(.*", r"", title)
            else:
                assert False, "Heading level unsupported"
            contents += (indent + "* " + "[%s](%s)\n" % (title, link))
    indexfile = os.path.join(API_DIR, "API-index.md")
    with open(indexfile, "wb") as fo:
        fo.write(contents)
    print("Created %s in %s" % (os.path.basename(indexfile), API_DIR))
    print("Done")


def headinghash(title):
    """Get a link hash for a heading H1,H2,H3."""
    hash_ = title.lower()
    hash_ = re.sub(r"[^a-z0-9_\- ]+", r"", hash_)
    hash_ = hash_.replace(" ", "-")
    hash_ = re.sub(r"[-]+", r"-", hash_)
    hash_ = re.sub(r"-$", r"", hash_)
    return hash_


if __name__ == "__main__":
    main()
