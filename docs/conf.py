from recommonmark.parser import CommonMarkParser

source_suffix = ['.rst', '.md']
source_parsers = {
    '.md': CommonMarkParser,
}
project = u'CEF Python'
language = 'en'
master_doc = 'Home'
man_pages = [
    (master_doc, 'cefpython', u'CEF Python Documentation',
     [u'Czarek Tomczak'], 1)
]
htmlhelp_basename = 'cefdoc'
