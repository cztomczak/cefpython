# Declare PyInstaller hooks-dir for cefpython.
# See https://pyinstaller.readthedocs.io/en/stable/hooks.html#provide-hooks-with-package.

import os
HERE = os.path.abspath(os.path.dirname(__file__))

def get_hooks_dir():
    """Get the folder containing hooks.

    Declare the folder containing ``hook-cefpython.py`` (i.e this one) to be
    added to PyInstaller's search paths for hooks.
    """
    return [HERE]
