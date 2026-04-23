# Hello world example. Doesn't depend on any third party GUI framework.
# Tested with CEF Python v57.0+.
#
# ==== High DPI support on Windows ====
# To enable DPI awareness on Windows you have to either embed DPI aware manifest
# in your executable created with pyinstaller or change python.exe properties manually:
# Compatibility > High DPI scaling override > Application.
# Setting DPI awareness programmatically via a call to cef.DpiAware.EnableHighDpiSupport
# is problematic in Python, may not work and can cause display glitches.

from cefpython3 import cefpython as cef
import platform
import sys
from packaging.version import Version as parse_version


def main():
    check_versions()
    sys.excepthook = cef.ExceptHook  # To shutdown all CEF processes on error
    switches = {}
    if sys.platform.startswith("linux"):
        # cefpython does not ship a chrome-sandbox (setuid) binary.
        # Disable both the setuid and namespace sandboxes so Chrome runs
        # subprocesses without sandboxing. Unlike --no-sandbox, these two
        # flags do NOT suppress the Mojo IPC bootstrap fd registration
        # (GlobalDescriptors key 7), so subprocesses can still communicate.
        switches["disable-setuid-sandbox"] = ""
        switches["disable-namespace-sandbox"] = ""
        # /dev/shm may be too small in VMs and containers.
        switches["disable-dev-shm-usage"] = ""
        # Suppress the GNOME Keyring unlock prompt on desktop sessions.
        switches["password-store"] = "basic"
        # Virtual GPU hardware (e.g. VMware) may not expose the DMA-BUF / GBM
        # interface required by Chrome's GPU process. Keep the GPU in-process.
        switches["disable-gpu"] = ""
        switches["disable-gpu-compositing"] = ""
        switches["in-process-gpu"] = ""
        # Keep storage and network services in-process to reduce subprocess
        # spawning overhead.
        switches["disable-features"] = "StorageServiceOutOfProcess"
        switches["enable-features"] = "NetworkServiceInProcess"
    cef.Initialize(switches=switches)
    cef.CreateBrowserSync(url="https://www.google.com/",
                          window_title="Hello World!")
    cef.MessageLoop()
    cef.Shutdown()


def check_versions():
    ver = cef.GetVersion()
    print("[hello_world.py] CEF Python {ver}".format(ver=ver["version"]))
    print("[hello_world.py] Chromium {ver}".format(ver=ver["chrome_version"]))
    print("[hello_world.py] CEF {ver}".format(ver=ver["cef_version"]))
    print("[hello_world.py] Python {ver} {arch}".format(
           ver=platform.python_version(),
           arch=platform.architecture()[0]))
    assert parse_version(cef.__version__) >= parse_version("57.0"), "CEF Python v57.0+ required to run this"


if __name__ == '__main__':
    main()
