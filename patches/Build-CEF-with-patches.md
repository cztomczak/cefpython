# Build CEF with the cefpython patches applied

CEF Python official binaries come with custom CEF binaries
with a few patches applied for our use case.

On Linux before running any CEF tools apply the issue73 patch
first.

To build CEF follow the instructions on the Branches and
Building CEF wiki page:
https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding

Use the automate-git.py tool, for example:
```
mkdir chromium && cd chromium
python automate-git.py --download-dir=./ --branch=2526 --no-debug-build --verbose-build --build-log-file
```

After it is built apply patches and rebuild:
```
cd chromium/src
ninja -v -j2 -Cout\Release cefclient
```

## How to patch

Create a patch from unstaged changes in current directory:
```
cd chromium/src/cef/
git diff > cef.gyp.patch
```

Apply a patch in current directory:
```
cd chromium/src/cef/
git apply cef.gyp.patch
```

## Ninja build slowing down computer

If ninja slows down your computer too much, build manually with
this command (where -j2 means to run 2 jobs in parallel)
```
cd chromium/src
ninja -v -j2 -Cout\Release cefclient
```
