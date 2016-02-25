# Build CEF with the cefpython patches applied

Use tools/automate.py with the --build-cef flag to build CEF
in an automated way with patches in this directory applied.


# Build manually

CEF Python official binaries come with custom CEF binaries
with a few patches applied for our use case.

On Linux before running any of CEF tools apply the issue73 patch
first.

To build CEF follow the instructions on the Branches and
Building CEF wiki page:
https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding

After it is successfully built - apply patches, rebuild and remake
distribs.

Note that CEF patches must be applied in the
"download_dir/chromium/src/cef/" directory, not in the "download_dir/cef/"
directory.


## How to patch

Apply a patch in current directory:
```
cd chromium/src/cef/
git apply cef.gyp.patch
```

Create a patch from unstaged changes in current directory:
```
cd chromium/src/cef/
git diff --relative > cef.gyp.patch
```


## Ninja build slows down computer

If ninja slows down your computer too much (6 parallel jobs by default),
build manually with this command (where -j2 means to run 2 jobs in parallel):
```
cd chromium/src
ninja -v -j2 -Cout\Release cefclient
```
