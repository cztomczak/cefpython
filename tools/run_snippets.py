# Copyright (c) 2018 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""
Run all snippets from the examples/snippets/ directory
and display a summary at the end.
"""

from common import *

import glob
import os
import subprocess
import sys


def main():
    # Iterate over all snippets
    snippets_iter = glob.glob(os.path.join(SNIPPETS_DIR, "*.py"))
    succeeded = []
    failed = []
    for snippet in snippets_iter:
        print("[run_snippets.py] Running '{snippet}'..."
              .format(snippet=os.path.basename(snippet)))
        retcode = subprocess.call([sys.executable, snippet])
        if retcode == 0:
            succeeded.append(os.path.basename(snippet))
        else:
            print("[run_snippets.py] ERROR while running snippet: {snippet}"
                  .format(snippet=snippet))
            failed.append(os.path.basename(snippet))

    # Print summary
    summary = ""
    for snippet in succeeded:
        summary += "  OK    {snippet}{nl}"\
                   .format(snippet=snippet, nl=os.linesep)
    for snippet in failed:
        summary += "  ERROR {snippet}{nl}"\
                   .format(snippet=snippet, nl=os.linesep)
    summary = summary[:-(len(os.linesep))]
    print("[run_snippets.py] SUMMARY:")
    print(summary.format())
    if len(failed):
        print("[run_snippets.py] ERRORS ({failed}) while running snippets"
              .format(failed=len(failed)))
        sys.exit(1)
    else:
        print("[run_snippets.py] OK ({succeeded})"
              .format(succeeded=len(succeeded)))


if __name__ == "__main__":
    main()
