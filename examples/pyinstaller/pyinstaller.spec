# -*- mode: python ; coding: utf-8 -*-

"""PyInstaller specification for the CEF Python wx example."""

import os
import shutil
import subprocess
import sys

from PyInstaller.building.api import COLLECT, EXE, PYZ
from PyInstaller.building.build_main import Analysis
from PyInstaller.utils.hooks import get_package_paths

if sys.platform == "darwin":
    from PyInstaller.building.osx import BUNDLE


DEBUG = bool(os.environ.get("CEFPYTHON_PYINSTALLER_DEBUG"))
ICON = None if sys.platform == "darwin" else "../resources/wxpython.ico"
MAC_HELPER_APP_NAMES = [
    "cefpython Helper.app",
    "cefpython Helper (Alerts).app",
    "cefpython Helper (GPU).app",
    "cefpython Helper (Plugin).app",
    "cefpython Helper (Renderer).app",
]


def _remove_path_and_target(path):
    """Remove a PyInstaller cross-link and its in-bundle target, if present."""
    if os.path.islink(path):
        target = os.path.realpath(path)
        parent = os.path.abspath(os.path.dirname(path))
        os.unlink(path)
        if (os.path.commonpath([target, parent]) == parent and
                os.path.isdir(target)):
            shutil.rmtree(target)
    elif os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.exists(path):
        os.unlink(path)


def _codesign_and_verify(path, bundle=True):
    command = ["codesign", "--force"]
    if bundle:
        command.append("--deep")
    command += ["--sign", "-", path]
    subprocess.check_call(command)

    command = ["codesign", "--verify"]
    if bundle:
        command.append("--deep")
    command += ["--strict", "--verbose=2", path]
    subprocess.check_call(command)


def _repair_and_sign_macos_cef_bundles(app_path):
    """Restore nested Helper.app boundaries, then sign everything inside-out.

    PyInstaller 6 splits BINARY and DATA entries between Contents/Frameworks
    and Contents/Resources. That is correct for ordinary package directories,
    but it breaks a nested Helper.app by separating its Mach-O executable from
    its Info.plist. Copy each already-built helper as an indivisible bundle
    after BUNDLE assembly, then regenerate all affected signatures.
    """
    cefpython_dir = get_package_paths("cefpython3")[1]
    frameworks_dir = os.path.join(app_path, "Contents", "Frameworks")
    resources_dir = os.path.join(app_path, "Contents", "Resources")

    framework = os.path.join(
        frameworks_dir, "Chromium Embedded Framework.framework")
    if not os.path.isdir(framework):
        raise RuntimeError("CEF framework missing from PyInstaller app: " +
                           framework)
    _codesign_and_verify(framework)

    for name in MAC_HELPER_APP_NAMES:
        # Remove PyInstaller's split/cross-linked representation before
        # restoring the source app bundle at the CEF-required sibling path.
        for root in (frameworks_dir, resources_dir):
            _remove_path_and_target(os.path.join(root, name))
        source = os.path.join(cefpython_dir, name)
        destination = os.path.join(frameworks_dir, name)
        if not os.path.isdir(source):
            raise RuntimeError("CEF helper bundle missing: " + source)
        shutil.copytree(source, destination, symlinks=True)
        _codesign_and_verify(destination)

    # Nested signatures changed, so seal and verify the outer app last.
    _codesign_and_verify(app_path)


a = Analysis(
    ["../wxpython.py"],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[],
    hookspath=["."],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)

if not os.environ.get("PYINSTALLER_CEFPYTHON3_HOOK_SUCCEEDED"):
    raise SystemExit("Error: hook-cefpython3.py was not executed or failed")

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name="cefapp",
    debug=DEBUG,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=DEBUG,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=ICON,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=False,
    name="cefapp",
)

if sys.platform == "darwin":
    app = BUNDLE(
        coll,
        name="cefapp.app",
        icon=ICON,
        bundle_identifier="org.cefpython.cefapp",
    )
    _repair_and_sign_macos_cef_bundles(app.name)
