from recommonmark.parser import CommonMarkParser

source_suffix = ['.rst', '.md']
source_parsers = {
    '.md': CommonMarkParser,
}

master_doc = 'Home'
