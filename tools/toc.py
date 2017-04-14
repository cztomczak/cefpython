# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Create Table of contents (TOC) for a single .md file or for a directory.

Usage:
    toc.py FILE
    toc.py DIR

To ignore file when generating TOC, put an empty line just before H1.
"""

import os
import sys
import re
import glob

API_DIR = os.path.join(os.path.dirname(__file__), "..", "api")


def main():
    """Main entry point."""
    if len(sys.argv) == 1:
        sys.argv.append(API_DIR)
    if (len(sys.argv) == 1 or
            "-h" in sys.argv or
            "--help" in sys.argv or
            "/?" in sys.argv):
        print(__doc__.strip())
        sys.exit(0)
    arg1 = sys.argv[1]
    if os.path.isdir(arg1):
        (modified, warnings) = toc_dir(arg1)
        if modified:
            print("Done")
        else:
            print("No changes to TOCs. Files not modified.")
    else:
        (modified, warnings) = toc_file(arg1)
        if modified:
            print("Done")
        else:
            print("No changes to TOC. File not modified.")
    if warnings:
        print("Warnings: "+str(warnings))


def toc_file(file_):
    """A single file was passed to doctoc. Return bool whether modified
    and the number of warnings."""
    with open(file_, "rb") as fo:
        orig_contents = fo.read().decode("utf-8", "ignore")
        # Fix new lines just in case. Not using Python's "rU",
        # it is causing strange issues.
        orig_contents = re.sub(r"(\r\n|\r|\n)", os.linesep, orig_contents)
    (tocsize, contents, warnings) = create_toc(orig_contents, file_)
    if contents != orig_contents:
        with open(file_, "wb") as fo:
            fo.write(contents.encode("utf-8"))
        tocsize_str = ("TOC size: "+str(tocsize) if tocsize
                       else "TOC removed")
        print("Modified: "+file_+" ("+tocsize_str+")")
        return True, warnings
    else:
        return False, warnings


def toc_dir(dir_):
    """A directory was passed to doctoc. Return bool whether any file was
    modified and the number of warnings."""
    files = glob.glob(os.path.join(dir_, "*.md"))
    modified_any = False
    warnings = 0
    for file_ in files:
        if "API-categories.md" in file_ or "API-index.md" in file_:
            continue
        (modified, warnings) = toc_file(file_)
        if not modified_any:
            modified_any = True if modified else False
    return modified_any, warnings


def create_toc(contents, file_):
    """Create or modify TOC for the document contents."""
    match = re.search(r"Table of contents:%s(\s*\* \[[^\]]+\]\([^)]+\)%s){2,}"
                      % (os.linesep, os.linesep), contents)
    oldtoc = match.group(0) if match else None
    (tocsize, toc, warnings) = parse_headings(contents, file_)
    if oldtoc:
        if not toc:
            # If toc removed need to remove an additional new lines
            # that was inserted after toc.
            contents = contents.replace(oldtoc+os.linesep, toc)
        else:
            contents = contents.replace(oldtoc, toc)
    elif tocsize:
        # Insert after H1, but if there is text directly after H1
        # then insert after that text.
        first_line = False
        if not re.search(r"^#\s+", contents):
            print("WARNING: missing H1 on first line. Ignoring file: "+file_)
            return 0, contents, warnings+1
        lines = contents.splitlines()
        contents = ""
        toc_inserted = False
        for line in lines:
            if not first_line:
                first_line = True
            else:
                if not toc_inserted and re.search(r"^(##|###)", line):
                    contents = contents[0:-len(os.linesep)]
                    contents += os.linesep + toc + os.linesep + os.linesep
                    toc_inserted = True
            contents += line + os.linesep
    # Special case for README.md - remove Quick Links toc for subheadings
    re_find = (r"  \* \[Docs\]\(#docs\)[\r\n]+"
               r"  \* \[API categories\]\(#api-categories\)[\r\n]+"
               r"  \* \[API index\]\(#api-index\)\r?\n?")
    contents = re.sub(re_find, "", contents)
    return tocsize, contents, warnings


def parse_headings(raw_contents, file_):
    """Parse contents looking for headings. Return a tuple with number
    of TOC elements, the TOC fragment and the number of warnings."""
    # Remove code blocks
    parsable_contents = re.sub(r"```[\s\S]+?```", "", raw_contents)
    # Parse H1,H2,H3
    headings = re.findall(r"^(#|##|###)\s+(.*)", parsable_contents,
                          re.MULTILINE)
    toc = "Table of contents:" + os.linesep
    tocsize = 0
    warnings = 0
    count_h1 = 0
    count_h2 = 0
    for heading in headings:
        level = heading[0]
        level = (1 if level == "#" else
                 2 if level == "##" else
                 3 if level == "###" else None)
        assert level is not None
        title = heading[1].strip()
        if level == 1:
            count_h1 += 1
            if count_h1 > 1:
                warnings += 1
                print("WARNING: found more than one H1 in "+file_)
            continue
        if level == 2:
            count_h2 += 1
        hash_ = headinghash(title)
        indent = ""
        if level == 3:
            if count_h2:
                # If there was no H2 yet then H3 shouldn't have indent.
                indent = " " * 2
        toc += indent + "* [%s](#%s)" % (title, hash_) + os.linesep
        tocsize += 1
    if tocsize <= 1:
        # If there is only one H2/H3 heading do not create TOC.
        toc = ""
        tocsize = 0
    return tocsize, toc, warnings


def headinghash(title):
    """Get a link hash for a heading H1,H2,H3."""
    hash_ = title.lower()
    hash_ = hash_.replace(" - ", "specialcase1")
    hash_ = hash_.replace(" / ", "specialcase2")
    hash_ = re.sub(r"[^a-z0-9_\- ]+", r"", hash_)
    hash_ = hash_.replace(" ", "-")
    hash_ = re.sub(r"[-]+", r"-", hash_)
    hash_ = re.sub(r"-$", r"", hash_)
    hash_ = hash_.replace("specialcase1", "---")
    hash_ = hash_.replace("specialcase2", "--")
    return hash_


if __name__ == "__main__":
    main()
