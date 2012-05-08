# combines both files: cefapi.pyx + cefbindings.pyx,
# cefbindings go at top of cefapi.pyx

import os

bindings = ""
api = ""

with open("cefbindings.pyx", "r") as file:
	bindings = file.read()
with open("cefapi.pyx", "r") as file:
	api = file.read()

with open("cefapi.pyx", "w") as file:
	file.write(bindings+"\n\n"+api)

os.remove("cefbindings.pyx")
print "Combined: cefbindings.pyx + cefapi.pyx into 1 file: cefapi.pyx"