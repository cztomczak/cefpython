# combines both files: cefpython.pyx + bindings.pyx,
# bindings go at top of cefpython.pyx

import os

bindings = ""
api = ""

with open("bindings.pyx", "r") as file:
	bindings = file.read()
with open("cefpython.pyx", "r") as file:
	api = file.read()

with open("cefpython.pyx", "w") as file:
	file.write(bindings+"\n\n"+api)

os.remove("bindings.pyx")
print "Combined: bindings.pyx + cefpython.pyx into 1 file: cefpython.pyx"