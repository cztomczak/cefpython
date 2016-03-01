[API categories](API-categories.md) | [API index](API-index.md)


# Cookie (class)

See also [CookieManager](CookieManager.md).SetCookie() and [CookieVisitor](CookieVisitor.md).Visit().


Table of contents:
* [Methods](#methods)
  * [Set](#set)
  * [Get](#get)
  * [SetName](#setname)
  * [GetName](#getname)
  * [SetValue](#setvalue)
  * [GetValue](#getvalue)
  * [SetDomain](#setdomain)
  * [GetDomain](#getdomain)
  * [SetPath](#setpath)
  * [GetPath](#getpath)
  * [SetSecure](#setsecure)
  * [GetSecure](#getsecure)
  * [SetHttpOnly](#sethttponly)
  * [GetHttpOnly](#gethttponly)
  * [SetCreation](#setcreation)
  * [GetCreation](#getcreation)
  * [SetLastAccess](#setlastaccess)
  * [GetLastAccess](#getlastaccess)
  * [SetHasExpires](#sethasexpires)
  * [GetHasExpires](#gethasexpires)
  * [SetExpires](#setexpires)
  * [GetExpires](#getexpires)


## Methods


### Set

| Parameter | Type |
| --- | --- |
| cookie | dict |
| __Return__ | void |

Set cookie properties via a dict.

The cookie may have the following keys:  
- name (str)  
- value (str)  
- domain (str)  
- path (str)  
- secure (bool)  
- httpOnly (bool)  
- creation (datetime.datetime)  
- lastAccess (datetime.datetime)  
- hasExpires (bool)  
- expires (datetime.datetime)  


### Get

| | |
| --- | --- |
| __Return__ | dict |

Get all cookie properties as a dict.


### SetName

| Parameter | Type |
| --- | --- |
| name | string |
| __Return__ | void |

Set the cookie name.


### GetName

| | |
| --- | --- |
| __Return__ | string |

Get the cookie name.


### SetValue

| Parameter | Type |
| --- | --- |
| value | string |
| __Return__ | void |

Set the cookie value.


### GetValue

| | |
| --- | --- |
| __Return__ | string |

Get the cookie value.


### SetDomain

| Parameter | Type |
| --- | --- |
| domain | string |
| __Return__ | void |

If |domain| is empty a host cookie will be  
created instead of a domain cookie. Domain cookies are stored with a  
leading "." and are visible to sub-domains whereas host cookies are  
not.


### GetDomain

| | |
| --- | --- |
| __Return__ | string |

Get the cookie domain.


### SetPath

| Parameter | Type |
| --- | --- |
| path | string |
| __Return__ | void |

If |path| is non-empty only URLs at or below the path will get the  
cookie value.


### GetPath

| | |
| --- | --- |
| __Return__ | string |

Get the cookie path.


### SetSecure

| Parameter | Type |
| --- | --- |
| secure | bool |
| __Return__ | void |

If |secure| is true the cookie will only be sent for HTTPS requests.


### GetSecure

| | |
| --- | --- |
| __Return__ | bool |

Get the secure property.


### SetHttpOnly

| Parameter | Type |
| --- | --- |
| httpOnly | bool |
| __Return__ | void |

If |httponly| is true the cookie will only be sent for HTTP requests.


### GetHttpOnly

| | |
| --- | --- |
| __Return__ | bool |

Get the httpOnly property.


### SetCreation

| Parameter | Type |
| --- | --- |
| creation | datetime.datetime |
| __Return__ | void |

The cookie creation date. This is automatically populated by the system on  
cookie creation.


### GetCreation

| | |
| --- | --- |
| __Return__ | datetime.datetime |

Get the creation property.


### SetLastAccess

| Parameter | Type |
| --- | --- |
| lastAccess | datetime.datetime |
| __Return__ | void |

The cookie last access date. This is automatically populated by the system  
on access.


### GetLastAccess

| | |
| --- | --- |
| __Return__ | datetime.datetime |

Get the lastAccess property.


### SetHasExpires

| Parameter | Type |
| --- | --- |
| hasExpires | bool |
| __Return__ | void |

The cookie expiration date is only valid if |hasExpires| is true.


### GetHasExpires

| | |
| --- | --- |
| __Return__ | bool |

Get the hasExpires property.


### SetExpires

| Parameter | Type |
| --- | --- |
| expires | datetime.datetime |
| __Return__ | void |

Set the cookie expiration date. You should also call SetHasExpires().


### GetExpires

| | |
| --- | --- |
| __Return__ | datetime.datetime |

Get the expires property.
