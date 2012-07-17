# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

# First, it copies all .pyx files from upper directory to setup/.
# Then, fixes repeating of "include" statements in pyx files.

# Only the mainfile needs to have "include" statements,
# but we're using PyCharm and to get rid of "unresolved references"
# and other errors displayed in pycharm we are adding "include"
# statements in all of the pyx files.

# I'm not 100% sure how includes work in Cython, but I suspect that
# a few includes of the same file will include the same content more
# than once, it should work, but function and variable definitions are
# duplicated, it is some kind of overhead and it could lead to some
# problems in the future, better to fix it now.

import glob
import os
import re
import shutil

print("\n")
mainfile = "cefpython.pyx"

pyxfiles = glob.glob("../*.pyx")
pyxfiles = [file for file in pyxfiles if file.find(mainfile) == -1]
# Now, pyxfiles contains all pyx files except the mainfile (cefpython.pyx),
# we do not fix includes in mainfile.

# So that this is the right directory we're in.
if os.path.exists("setup"):
	print("Wrong directory, we should be inside setup!")
	exit()

# Remove old pyx files in setup directory.
oldpyxfiles = glob.glob("./*.pyx")
print("Removing old pyx files in /setup/: %s" % oldpyxfiles)
for pyxfile in oldpyxfiles:
	if os.path.exists(pyxfile):
		os.remove(pyxfile)

# Copying pyxfiles and reading its contents.

print("Copying .pyx files to /setup/: %s" % pyxfiles)
shutil.copy("../%s" % mainfile, "./%s" % mainfile)
# Rest of the files will be copied in for loop below.

print("Fixing includes in .pyx files:")
for pyxfile in pyxfiles:
	newfile = "./%s" % os.path.basename(pyxfile)
	shutil.copy(pyxfile, newfile)
	pyxfile = newfile
	with open(pyxfile, "r") as pyxfileopened:
		content = pyxfileopened.read()
		# Do not remove the newline - so that line numbers are exact with originals.
		(content, subs) = re.subn(r"^include[\t ]+[\"'][^\"'\n\r]+[\"'][\t ]*", "", content, flags=re.MULTILINE)
		print("%s includes removed in: %s" % (subs, os.path.basename(pyxfile)))
	# Reading and writing with the same handle using "r+" mode doesn't work,
	# you need to seek(0) and write the same amount of bytes that was in the
	# file, otherwise old data from the end of file stays.
	with open(pyxfile, "w") as pyxfileopened:
		pyxfileopened.write(content)

print("\n")
