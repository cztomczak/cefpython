"""The build configuration file for Sphinx - Python Documentation Generator."""

from recommonmark.parser import CommonMarkParser

version = '31.2'
release = '31.2'

project = u'CEF Python'
description = u'CEF Python Documentation'
author = u'The CEF Python authors'
copyright = u'2012, '+author

master_doc = 'Home'
source_suffix = ['.md']
source_parsers = {
    '.md': CommonMarkParser,
}

pygments_style = 'sphinx'
language = 'en'

extensions = []
templates_path = ['_templates']
exclude_patterns = ['_build']

latex_documents = [
    (master_doc, 'cefpython.tex', description,
     author, 'manual'),
]
man_pages = [
    (master_doc, 'cefpython', description,
     [author], 1)
]
htmlhelp_basename = 'cefdoc'
