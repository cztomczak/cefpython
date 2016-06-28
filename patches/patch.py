# CEF Python patches to Chromium and CEF.
# See upstream cef/patch/patch.cfg for how patching works in CEF.
# Current working directory is cef_build_dir/chromium/cef/ .
# See also docs/Build-instructions.md and tools/automate.py .

import platform

OS_POSTFIX = ("win" if platform.system() == "Windows" else
              "linux" if platform.system() == "Linux" else
              "mac" if platform.system() == "Darwin" else "unknown")

# ALL PLATFORMS
# noinspection PyUnresolvedReferences
patches.extend([
    {
        # Fixes HTTPS cache problems with private certificates
        'name': 'issue125',
        'path': '../net/http/'
    },
    {
        # Expose CefOverridePath to override PathService path keys
        'name': 'issue231',
        'path': './'
    },
])

# LINUX
if OS_POSTFIX == "linux":
    pass
