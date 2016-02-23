from recommonmark.parser import CommonMarkParser

source_suffix = ['.md']
source_parsers = {
    '.md': CommonMarkParser,
}
