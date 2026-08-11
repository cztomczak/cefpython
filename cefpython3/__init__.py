import ctypes
import importlib
import os
import platform
import sys

__all__ = ["cefpython"]
__author__ = "The CEF Python authors"

try:
    from importlib.metadata import version as _pkg_version
    __version__ = _pkg_version("cefpython3")
except Exception:
    __version__ = "unknown"

package_dir = os.path.dirname(os.path.abspath(__file__))

# Let subprocess and the C extension find CEF DLLs / .so files next to this
# __init__.py regardless of the working directory.
os.environ["CEFPYTHON3_PATH"] = package_dir

if platform.system() == "Linux":
    # Force GDK to use X11/XWayland backend before libcef.so loads and
    # initialises GDK.  Without this, GDK picks the Wayland backend on
    # GNOME/Wayland sessions, making gdk_x11_window_get_xid() return 0.
    os.environ.setdefault("GDK_BACKEND", "x11")
    _ld = os.environ.get("LD_LIBRARY_PATH", "")
    os.environ["LD_LIBRARY_PATH"] = (
        package_dir + os.pathsep + _ld if _ld else package_dir
    )
    ctypes.CDLL(os.path.join(package_dir, "libcef.so"), ctypes.RTLD_GLOBAL)

_pyver = "{0}{1}".format(*sys.version_info[:2])
cefpython = importlib.import_module(".cefpython_py{}".format(_pyver), package=__name__)
