# Build instructions for Linux #

The original instructions on building Chromium/CEF can be found on the CEF project [Branches and Building](https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding) wiki page.

Table of contents:


## Preliminary notes ##

  * These instructions were tested on Ubuntu 12.04 and Python 2.7. Python 3.4 is not yet supported ([Issue 121](../issues/121))
  * The path to chromium directory should not contain any spaces
  * If building on Fedora see this (4.) comment: [comment](../issues/72)

## Using precompiled binaries from cefbuilds.com ##

You can use precompiled binaries from [cefbuilds.com](http://cefbuilds.com/), so that it is not required to compile Chromium/CEF from sources. However this comes with some limitations, as such binaries won't have applied patches provided in the instructions on this page. There are several patches applied when building Chromium/CEF from sources:
  * wxpython patch - without this patch you won't be able to run the wxpython examples. However you should be just fine running the `pygtk_.py` example. Not sure about the pyqt/pyside examples, these would need to be tested.
  * tcmalloc patch - when this patch is not applied, the cefpython library must be imported the very first in application before any other libraries ([Issue 73](../issues/73))
  * https caching certificate errors patch - https caching on sites with certificate errors won't be enabled

CEF branch and revision from cefbuilds.com must match the ones provided in the [BUILD\_COMPATIBILITY.txt](../blob/master/cefpython/cef3/BUILD_COMPATIBILITY.txt) file. For example in a file named "CEF3.1650.1639", the 1650 number is a branch and the 1639 number is a revision. See also the VersionNumbering wiki page for more details.

When using precompiled binaries you can ignore steps on this page that refer to building Chromium/CEF that do not apply.

## Install the necessary tools ##

1. Make sure you have an up to date version of GIT. As of this writing syncing chromium works fine with GIT 1.7.9.5.

```
sudo apt-get install git
git --version
```

2. Install depot tools to your chromium directory (includes gclient tool that we'll be using later).

```
mkdir ~/chromium/
cd ~/chromium/
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

3. Add depot tools to your path for the current terminal session:

```
export PATH="$PATH":`pwd`/depot_tools
```

4. Check SVN version, it should be 1.6.x, otherwise you will get into troubles. You can install it using "`sudo apt-get install subversion`" command.

```
svn --version
```

5. Make sure you are running an up to date version of G++, as of this writing compiling works fine with G++ 4.6.3. Install it using "`sudo apt-get install g++`" command.

```
g++ --version
```

## Configure Chromium to use a specific revision ##

1. Go open the BUILD\_COMPATIBILITY.txt file.

For CEF 1: ../blob/master/cefpython/cef1/BUILD_COMPATIBILITY.txt

For CEF 3: ../blob/master/cefpython/cef3/BUILD_COMPATIBILITY.txt

Later we will need the "Chromium release url" and and the "CEF repository url" so keep it in sight.

2. Configure Chromium to use a specific revision (through a release url) by running the "gclient config" command, the release url we will be using is from the BUILD\_COMPATIBILITY.txt file:

```
cd ~/chromium/
gclient config {Chromium release url}
```

3. Edit the "~/chromium/.gclient" file and modify the "custom\_deps" to reduce the size of the sources to downoad:

```
  "custom_deps": {
    "src/content/test/data/layout_tests/LayoutTests": None,
    "src/chrome/tools/test/reference_build/chrome_win": None,
    "src/chrome_frame/tools/test/reference_build/chrome_win": None,
    "src/chrome/tools/test/reference_build/chrome_linux": None,
    "src/chrome/tools/test/reference_build/chrome_mac": None,
    "src/third_party/hunspell_dictionaries": None,
  },
```

This excludes some directories that contain lots of data (many many gigabytes) that would extend the time significantly when synchronizing Chromium sources with the revision we've selected.

## Download the Chromium sources ##

Download the Chromium sources by running the "gclient sync" command. The Chromium sources will be updated to the revision based on the release url we've configured earlier via "gclient config". Read also the "Possible issues" section below in case you encounter errors.

```
cd ~/chromium/
gclient sync --jobs 8 --force
```

This can take a while and sometimes it can break with some errors when a download fails. In such case you should run the "gclient sync" command once again. One of the last messages in the console should be:

```
Updating projects from gyp files...
```

#### Possible issues while running "gclient sync" ####

  * You may encounter an error while checking out the gsutil repo, fix it [by removing gsutil entries from the DEPS file](http://src.chromium.org/viewvc/chrome/releases/33.0.1750.29/DEPS?r1=245305&r2=245304&pathrev=245305).

  * If gclient sync fails with error message saying that "gmodule-2.0" / "gtk+-2.0" / "gthread-2.0"  packages are missing, then you will have to run the "install-build-deps.sh" script to install the dependencies. See the next section for details on how to do that. After it's done, run the "gclient sync" command **once again**.

## Install Chromium build dependencies ##

1. Install build dependencies by running this script, it might ask you for the root password during installation of libraries, so you might as well run it via "sudo".

  * When it asks for the debug symbols answer "No"
  * IMPORTANT: When the "ttf-mscorefonts-installer" graphical installer pops up, click `<Ok>` when it displays the License file, but later **click `<No>` when it asks to accept the EULA license terms**. If you install these fonts your font experience on websites might deteriorate in Chrome/Firefox/other browsers, as it affects not only CEF (font issues observed on Ubuntu 12.04 32bit).

```
cd ~/chromium/src/build/
sudo ./install-build-deps.sh --no-chromeos-fonts
```

If you see the "Installation complete" or "Skipping installation of Chrome OS fonts" messages at the end then everything went well.

2. Install also the libgtkglext1-dev package that is a dependency of the CEF off-screen rendering.

```
sudo apt-get update
sudo apt-get install libgtkglext1-dev
```

## Download the CEF sources ##

Download the CEF sources, the repository url can be found in the BUILD\_COMPATIBILITY.txt file that was mentioned earlier.

```
cd ~/chromium/src/
svn checkout {CEF repository url} cef
```

This will download the CEF sources to the "cef" directory.

## Download the CEF Python sources ##

Run the "git clone" command for the CEF Python repository. The command below will create "`~/cefpython/`" directory.

```
cd ~/
git clone https://github.com/cztomczak/cefpython
```

## Fix the CEF GTK implementation ##

There are a few problems with the current CEF GTK implementation. There  is a bug causing the embedded CEF window to be initially hidden. Another issue is that CEF requires the container to be of type BOX (eg. GtkVBox). In wxPython apps there is even an another issue, each wx control is embraced with a `GtkPizza` window and this needs to be fixed as well.

Apply the patch in the `"~/chromium/src/cef/`" directory. Modifications are made to the `CefBrowserHostImpl::PlatformCreateWindow` function.

```
Index: libcef/browser/browser_host_impl_gtk.cc 
===================================================================
--- browser_host_impl_gtk.cc	(revision 1639)
+++ browser_host_impl_gtk.cc	(working copy)
@@ -273,8 +273,43 @@
 
   // Parent the TabContents to the browser window.
   window_info_.widget = web_contents_->GetView()->GetNativeView();
-  gtk_container_add(GTK_CONTAINER(window_info_.parent_widget),
-                    window_info_.widget);
+  if (GTK_IS_BOX(window_info_.parent_widget)) {
+      gtk_box_pack_start(GTK_BOX(window_info_.parent_widget), 
+          window_info_.widget, TRUE, TRUE, 0);
+  } else {
+    // Parent view shouldn't contain any children, but in wxWidgets library
+    // there will be GtkPizza widget for Panel or any other control.
+    GList *children, *iter;
+    children = gtk_container_get_children(GTK_CONTAINER(
+        window_info_.parent_widget));
+    GtkWidget* child = NULL;
+    GtkWidget* vbox = gtk_vbox_new(FALSE, 0);
+    for (iter = children; iter != NULL; iter = g_list_next(iter)) {
+      child = GTK_WIDGET(iter->data);
+      // We will have to keep a reference to that child that we remove,
+      // otherwise we will get lots of warnings like "invalid unclassed
+      // pointer in cast to `GtkPizza'". First we increase a reference,
+      // we need to do this for a moment before we add this child to the
+      // vbox, then we will decrease that reference.
+      g_object_ref(G_OBJECT(child));
+      gtk_container_remove(GTK_CONTAINER(window_info_.parent_widget), child);
+    }
+    g_list_free(children);
+    gtk_box_pack_start(GTK_BOX(vbox), window_info_.widget, TRUE, TRUE, 0);
+    if (child != NULL) {
+      // This child is packed to the box only so that its reference lives,
+      // as it might be referenced from other code thus resulting in errors.
+      gtk_box_pack_end(GTK_BOX(vbox), child, FALSE, FALSE, 0);
+      gtk_widget_hide(GTK_WIDGET(child));
+      g_object_unref(G_OBJECT(child));
+    }
+    gtk_widget_show(GTK_WIDGET(vbox));
+    if (GTK_IS_SCROLLED_WINDOW(window_info_.parent_widget))
+      gtk_scrolled_window_add_with_viewport(
+          GTK_SCROLLED_WINDOW(window_info_.parent_widget), vbox);
+    else
+      gtk_container_add(GTK_CONTAINER(window_info_.parent_widget), vbox);
+  }
 
   g_signal_connect(G_OBJECT(window_info_.widget), "destroy",
                    G_CALLBACK(browser_destroy), this);
@@ -293,6 +328,8 @@
   prefs->inactive_selection_bg_color = SkColorSetRGB(200, 200, 200);
   prefs->inactive_selection_fg_color = SkColorSetRGB(50, 50, 50);
 
+  gtk_widget_show_all(GTK_WIDGET(window_info_.widget));
+
   return true;
 }
```

### wxPython auto-focus issue ###

In wxPython apps, this patch will remove the `GtkPizza` element, and it may cause issues with setting focus on a wx control that embeds the cef browser. However, if you click with a mouse inside the browser window, focus will work fine. It is the automatic focus that will be missing. This could probably be fixed by making a native OS call to focus the window. Although, this would require another dependency, for example this could be accomplished using the `pygtk` package. Another solution would be for cefpython to expose the GTK window focus function to WindowUtils, there are already a few GTK API functions exposed that are used by the pyqt example.

## Fix HTTPS caching on sites with SSL certificate errors (optional) ##

This is an optional fix. By default Chromium disables caching when there is certificate error. This patch will fix the HTTPS caching only when [ApplicationSettings](ApplicationSettings.md).ignore\_certificate\_errors is set to True. Official cefpython binaries have this fix applied, starting with the 31.0 release. See also [Issue 125](https://code.google.com/p/cefpython/issues/detail?id=125).

Apply the patch in the "`~/chromium/src/`" directory. Modifications are made in the `HttpCache::Transaction::WriteResponseInfoToEntry` function.

```
Index: net/http/http_cache_transaction.cc
===================================================================
--- http_cache_transaction.cc   (revision 241641)
+++ http_cache_transaction.cc   (working copy)
@@ -2240,7 +2240,8 @@
   // reverse-map the cert status to a net error and replay the net error.
   if ((cache_->mode() != RECORD &&
        response_.headers->HasHeaderValue("cache-control", "no-store")) ||
-      net::IsCertStatusError(response_.ssl_info.cert_status)) {
+       (!cache_->GetSession()->params().ignore_certificate_errors &&
+       net::IsCertStatusError(response_.ssl_info.cert_status))) {
     DoneWritingToEntry(false);
     ReportCacheActionFinish();
     if (net_log_.IsLoggingAllEvents())
```

## Disable the tcmalloc memory allocation global hook (optional, but recommended) ##

If tcmalloc hook is enabled it will cause troubles when CEF is not the very first library being imported in python scripts. In result of which you could be getting random unrelated segmentation faults all over app. See [Issue 73](https://code.google.com/p/cefpython/issues/detail?id=73) for more details.

Official cefpython binaries have this fix applied, starting with the 31.0 release.

To disable tcmalloc:

1. Create the `~/.gyp/` directory and the `~/.gyp/include.gypi` file. Next edit the file and paste the following contents:

```
{
  'variables': {
    'linux_use_tcmalloc': 0,
    'use_allocator': 'none',
  },
}
```

2. Remove the allocator dependency in the "chromium/src/cef/cef.gyp" file. Find the lines below and remove the line containing "`allocator.gyp`". There are two such lines present in this file (for win and linux), you may as well remove both of them.

```
[ 'OS=="linux" or OS=="freebsd" or OS=="openbsd"', {
  'dependencies':[
    '<(DEPTH)/base/allocator/allocator.gyp:allocator',
```

## Build CEF binaries and libraries ##

1. Generate the build files based on the GYP configuration by running the "cef\_create\_projects.sh" script.

```
cd ~/chromium/src/cef/
./cef_create_projects.sh
```

The last message should inform about the `~/.gyp/include.gypi` being used (if you decided to disable tcmalloc hook):

```
Using overrides found in /home/czarek/.gyp/include.gypi
```

2. Build the release version of cefclient.

```
cd ~/chromium/src/
make -j4 BUILDTYPE=Release cefclient
```

3. Create the cefclient distribution package.

```
cd ~/chromium/src/cef/tools/
./make_distrib.sh --allow-partial
```

4. Go to the `"cef_binary_*/"` directory and build the libcef\_dll\_wrapper project and cefclient projects.

```
cd ~/chromium/src/cef/binary_distrib/cef_binary_*
make -j4 BUILDTYPE=Release libcef_dll_wrapper
make -j4 BUILDTYPE=Release cefclient
```

The succession of building the projects is important. The libcef\_dll\_wrapper project needs to be build first, before cefclient. Otherwise you will get an error message saying "make: Nothing to be done for libcef\_dll\_wrapper".

The libcef\_dll\_wrapper project builds a static library for the C++ API of CEF.

5. Copy the libcef\_dll\_wrapper static library to the cefpython `"lib_64bit"` directory (or 32bit). If the directory doesn't exist create one. You have to copy both the `"libcef_dll_wrapper.a"` file and the `"libcef_dll_wrapper/"` directory containing the ".o" files.

```
mkdir ~/cefpython/cefpython/cef3/linux/setup/lib_64bit/
cd ~/chromium/src/cef/binary_distrib/cef_binary_*/out/Release/obj.target/
cp -r libcef_dll_wrapper libcef_dll_wrapper.a ~/cefpython/cefpython/cef3/linux/setup/lib_64bit/
```

If you've been building project previously, then remove the contents of the `"lib_64bit"` directory (or 32bit).

6. Copy the CEF binaries to the cefpython `"binaries_64bit/"` directory (or 32bit), including the README.txt which includes some useful information about required/optional binary files and version of CEF.

```
cd ~/chromium/src/cef/binary_distrib/cef_binary_*/out/Release/
cp -r locales/ files/ cefclient *.pak *.so ~/cefpython/cefpython/cef3/linux/binaries_64bit/
cp ~/chromium/src/cef/binary_distrib/cef_binary_*/README.txt ~/cefpython/cefpython/cef3/linux/binaries_64bit/
```

If you've been building project previously, then remove the contents of the `"binaries_64bit"` directory (or 32bit), but do not remove the python examples (**.py**.html) nor the LICENSE.txt file.

The files/ directory contains test files for the cefclient (executable) sample browser. The cefclient executable is an optional binary and may be removed, though it is a good idea to keep it in case there are some issues with CEF Python. In such case reproducing the issue with cefclient is a basis for reporting the issue to upstream CEF.

## Install Cython ##

Download Cython 0.19.2 from PYPI:

https://pypi.python.org/pypi/Cython/0.19.2

Extract it, then run "setup.py install" command via sudo:

```
sudo python setup.py install
```

## Build the CEF Python module ##

Go to the cefpython "linux/" directory and run the "compile.py" script:

```
cd ~/cefpython/cefpython/cef3/linux/
python compile.py
```

Building the makefiles may fail for the first time if the "setup/cefpython.h" is not up-to-date. If this happens you will be asked  whether to continue, answer Yes to that. You will be prompted a few times, but don't worry just keep going. The compilation will fail, but the "setup/cefpython.h" file will be generated. Now **compile it again** by running the "python compile.py" command, it should succeed this time.

If everything went well then the `"cefpython_py27.so"` module should be created in the `"binaries_64bit/"` directory (or 32bit) and the "wxpython.py" example should be launched.

If you're building on OS other than Ubuntu then you may get errors about the missing header files, for example:

```
/usr/include/glib-2.0/glib/gtypes.h:34:24: fatal error: glibconfig.h: No such file or directory
compilation terminated.
```

To fix it, find the "glibconfig.h" file somewhere in the "/usr/" directory and add that directory to the includes by editing the "~/cefpython/cefpython/cef3/linux/setup/setup.py" script. Append it to the "include\_dirs" list.

## Create a portable zip ##

To create a portable zip just compress the files in the `"binaries_64bit/"` directory (or 32bit).

## Create a setup package ##

To create a setup package run the "make-setup.py" script:

```
cd ~/cefpython/cefpython/cef3/linux/installer/
python make-setup.py -v 31.0
```

If everything went fine then you should see a setup package created in the current directory.

## Create a Debian package ##

Before creating a debian package some dependencies need to be installed (stdeb version 0.6.0 required):

```
sudo apt-get install python-support python-pip fakeroot
sudo pip install stdeb==0.6.0
```

If you were updating CEF version then you may need to generate  package dependencies. It will save results to deps.txt file which later will be used by make-deb.py.

```
cd ~/cefpython/cefpython/cef3/linux/installer/
python find-deps.py
```

After that run the "make-deb.py" script:

```
cd ~/cefpython/cefpython/cef3/linux/installer/
python make-deb.py -v 31.0
```

If debian package build succeeded the last two messages from the console should be:

```
dpkg-deb: building package `python-cefpython3' in `./python-cefpython3_31.0-1_amd64.deb'.
[make-deb.py] DONE
```

The debian package should be created in the `deb_archive/` directory.