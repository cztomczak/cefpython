# CEF Python patches to Chromium and CEF.
# See upstream cef/patch/patch.cfg for how patching works in CEF.
# Current working directory is cef_build_dir/chromium/src/ .
# See also docs/Build-instructions.md and tools/automate.py .

import platform

OS_POSTFIX = ("win" if platform.system() == "Windows" else
              "linux" if platform.system() == "Linux" else
              "mac" if platform.system() == "Darwin" else "unknown")

# ALL PLATFORMS
# noinspection PyUnresolvedReferences
patches.extend([
    #{
    #    # (Disabled) Fixes HTTPS cache problems with private certificates
    #    'name': 'issue125',
    #    'path': 'net/http/'
    #},
])

# LINUX
if OS_POSTFIX == "linux":
    # noinspection PyUnresolvedReferences
    patches.extend([
        {
            # Discovery of the "icudtl.dat" file fails on Linux.
            'name': 'issue231',
            'path': 'cef/'
        },
    ])
