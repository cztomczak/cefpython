# `Response` object #

This object is passed as parameter to [RequestHandler](RequestHandler).OnBeforeResourceLoad() and [RequestHandler](RequestHandler).OnResourceResponse().

## CEF 3 ##

bool **IsReadOnly**()

> Returns true if this object is read-only.

int **GetStatus**()

> Get the response status code.

void **SetStatus**(int status)

> Set the response status code.

string **GetStatusText**()

> Get the response status text.

void **SetStatusText**(string statusText)

> Set the response status text.

string **GetMimeType**()

> Get the response mime type.

void **SetMimeType**(string mimeType)

> Set the response mime type.

string **GetHeader**(string name)

> Get the value for the specified response header field.

dict **GetHeaderMap**()

> Get all header fields with duplicate keys overwritten by last.

list **GetHeaderMultimap**()

> Get all header fields. Returns list of tuples (name, value). Headers may have duplicate keys, if you want to ignore duplicates use `GetHeaderMap()`.

void **SetHeaderMap**(dict `headerMap`)

> Set all header fields.

void **SetHeaderMultimap**(list `headerMultimap`)

> Set all header fields. `headerMultimap` must be a list of tuples (name, value).


## CEF 1 ##

int **GetStatus**()

> Get the response status code.

void **SetStatus**(int status)

> Set the response status code.

string **GetStatusText**()

> Get the response status text.

void **SetStatusText**(string statusText)

> Set the response status text.

string **GetMimeType**()

> Get the response mime type.

void **SetMimeType**(string mimeType)

> Set the response mime type.

string **GetHeader**(string name)

> Get the value for the specified response header field.

dict **GetHeaderMap**()

> Get all header fields with duplicate keys overwritten by last.

list **GetHeaderMultimap**()

> Get all header fields. Returns list of tuples (name, value). Headers may have duplicate keys, if you want to ignore duplicates use `GetHeaderMap()`.

void **SetHeaderMap**(dict `headerMap`)

> Set all header fields.

void **SetHeaderMultimap**(list `headerMultimap`)

> Set all header fields. `headerMultimap` must be a list of tuples (name, value).

