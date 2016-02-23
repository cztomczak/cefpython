"""The build configuration file for Sphinx docs generator.

To generate documentation locally run these commands:

pip install sphinx sphinx-autobuild
pip install recommonmark
pip install sphinx_rtd_theme
sphinx-build -b html -d _build/doctrees . _build/html
"""

import os
import sys
from recommonmark.parser import CommonMarkParser

version = '31.2'
release = '31.2'

project = u'CEF Python'
description = u'CEF Python Documentation'
author = u'The CEF Python authors'
copyright = u'2012, '+author

master_doc = 'index'
source_suffix = ['.rst', '.md']
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

on_rtd = os.environ.get('READTHEDOCS', None) == 'True'
if not on_rtd:  # only import and set the theme if we're building docs locally
    import sphinx_rtd_theme
    html_theme = 'sphinx_rtd_theme'
    html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]
