# Copyright (c) 2012-2014 The CEF Python authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# This script finds dependencies. It fetches google chrome
# debian package dependencies from src.chromium.org for
# specific revision. Filters these dependencies with data
# returned by ldd command. Saves results to deps.txt.

import os
import sys
import re
import platform
import glob
import subprocess

def main():
    branch = get_branch()
    revision = get_chromium_revision(branch)
    chrome_deps = get_chrome_deps(revision)
    cef_library_dependencies = get_cef_library_dependencies()
    cef_deps = get_cef_deps(cef_library_dependencies)
    final_deps = get_final_deps(chrome_deps, cef_deps)
    curdir = os.path.dirname(os.path.realpath(__file__))
    with open(curdir+"/deps.txt", "w") as f:
        f.write("\n".join(final_deps))
    log("Saved deps to deps.txt file")
    success = check_final_deps(final_deps)
    if not success:
        sys.exit(1)

def log(msg):
    print("[dependencies.py] %s" % msg)

def fetch_url(url):
    if sys.version_info[0] == 2:
        import urllib2
        try:
            urlfile = urllib2.urlopen(url)
        except:
            # 404 for example
            return None
        return urlfile.read()
    else:
        import urllib.request
        try:
            urlfile = urllib.request.urlopen(url)
        except:
            # 404 for example
            return None
        return urlfile.read()

def get_branch():
    curdir = os.path.dirname(os.path.realpath(__file__))
    with open(curdir+"/../../BUILD_COMPATIBILITY.txt") as f:
        m = re.search(r"\d+\.\d+\.(\d+)\.\d+", f.read())
        branch = m.group(1)
    log("branch = %s" % branch)
    return branch

def get_chromium_revision(branch):
    url = "http://src.chromium.org/viewvc" \
          "/chrome/branches/%s/src/chrome/VERSION" % branch
    contents = fetch_url(url)
    if not contents:
        raise Exception("Failed fetching url: %s" % url)
    m = re.search(r"revision=(\d+)", contents)
    revision = m.group(1)
    log("chromium revision = %s" % revision)
    return revision

def get_chrome_deps(revision):
    # Currently works only with SVN up to Chrome revision 293233.
    base_url = "http://src.chromium.org/svn/trunk/src" \
               "/chrome/installer/linux/debian"
    url = base_url+"/expected_deps?p=%s" % revision
    contents = fetch_url(url)
    if not contents:
        url = base_url+"/expected_deps_x64?p=%s" % revision
        contents = fetch_url(url)
        if not contents:
            raise Exception("Failed fetching url: %s" % url)
    contents = contents.strip()
    deps = contents.splitlines()
    for i, dep in enumerate(deps):
        deps[i] = dep.strip()
    deps.sort(key = lambda s: s.lower());
    log("Found %d Chrome deps" % len(deps))
    print("-" * 80)
    print("\n".join(deps))
    print("-" * 80)
    return deps

def get_cef_library_dependencies():
    # Chrome deps != library dependencies
    # deps = package dependencies (for apt-get install)
    # library dependencies -> a package with such name may not exist
    curdir = os.path.dirname(os.path.realpath(__file__))
    bits = platform.architecture()[0]
    assert (bits == "32bit" or bits == "64bit")
    binaries_dir = curdir+"/../binaries_%s" % bits
    libraries = glob.glob(binaries_dir+"/*.so")
    assert(len(libraries))
    log("Found %d CEF libraries" % (len(libraries)))
    all_dependencies = []
    for library in libraries:
        library = os.path.abspath(library)
        dependencies = get_library_dependencies(library)
        all_dependencies = all_dependencies + dependencies
    all_dependencies = remove_duplicate_dependencies(all_dependencies)
    log("Found %d all CEF library dependencies combined" \
            % len(all_dependencies))
    return all_dependencies

def remove_duplicate_dependencies(dependencies):
    unique = []
    for dependency in dependencies:
        if dependency not in unique:
            unique.append(dependency)
    return unique

def get_library_dependencies(library):
    contents = subprocess.check_output("ldd %s" % library, shell=True)
    contents = contents.strip()
    lines = contents.splitlines()
    dependencies = []
    for line in lines:
        m = re.search(r"([^/\s=>]+).so[.\s]", line)
        dependencies.append(m.group(1))
    dependencies.sort(key = lambda s: s.lower());
    log("Found %d dependencies in %s:" % \
            (len(dependencies), os.path.basename(library)))
    print("-" * 80)
    print("\n".join(dependencies))
    print("-" * 80)
    return dependencies

def get_cef_deps(dependencies):
    cef_deps = []
    for dependency in dependencies:
        if package_exists(dependency):
            cef_deps.append(dependency)
    log("Found %d CEF deps for which package exists:" % len(cef_deps))
    print("-" * 80)
    print("\n".join(cef_deps))
    print("-" * 80)
    return cef_deps

def package_exists(package):
    try:
        devnull = open('/dev/null', 'w')
        contents = subprocess.check_output("dpkg -s %s" % package, 
                stderr=devnull, shell=True)
        devnull.close()
    except subprocess.CalledProcessError, e:
        return False
    if "install ok installed" in contents:
        return True
    print("**PROBABLY ERROR OCCURED** while calling: %s" % "dpkg -s "+package)
    return False

def get_final_deps(chrome_deps, cef_deps):
    final_deps = chrome_deps
    chrome_deps_names = []
    chrome_libudev0_dep = ""
    for chrome_dep in chrome_deps:
        chrome_dep_name = get_chrome_dep_name(chrome_dep)
        chrome_deps_names.append(chrome_dep_name)
        if chrome_dep_name == "libudev0":
            chrome_libudev0_dep = chrome_dep
    for cef_dep in cef_deps:
        if cef_dep not in chrome_deps_names:
            final_deps.append(cef_dep)
    log("Found %d CEF deps that were not listed in Chrome deps" % \
            (len(final_deps)-len(chrome_deps)) )
    # See Issue 145. libudev.so.0 may be missing and postinstall
    # script creates a symlink. Not sure how Google Chrome can
    # have libudev0 in deps and deb package can install fine.
    if chrome_libudev0_dep and chrome_libudev0_dep in final_deps:
        log("Removing '%s' from final deps (Issue 145)" % chrome_libudev0_dep)
        final_deps.remove(chrome_libudev0_dep)
    if "libudev0" in final_deps:
        log("Removing 'libudev0' from final deps (Issue 145)")
        final_deps.remove("libudev0")        
    log("Found %d final deps:" % len(final_deps))
    print("-" * 80)
    print("\n".join(final_deps))
    print("-" * 80)
    return final_deps

def get_chrome_dep_name(dep):
    # Eg. libxcomposite1 (>= 1:0.3-1) ===> libxcomposite1
    dep = re.sub(r"\([^\(]+\)", "", dep)
    dep = dep.strip()
    return dep

def check_final_deps(deps):
    # Check if all deps packages are installed
    deps_not_installed = []
    for dep in deps:
        dep_name = get_chrome_dep_name(dep)
        if not package_exists(dep_name):
            deps_not_installed.append(dep_name)
    if len(deps_not_installed) == 0:
        log("Everything is OK. All deps are found to be installed.")
        return True
    else:
        log("Found %d deps that are currently not installed:" % \
                len(deps_not_installed))
        print("-" * 80)
        print("\n".join(deps_not_installed))
        print("-" * 80)
        log("ERROR")
        return False

if __name__ == "__main__":
    main()
