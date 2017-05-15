# Extensions
Usefull extensions which I'm using in my work.

1. [UIApplication+OpenURL](#UIApplication+OpenURL) Usefull in case when safari may be restricted (disabled). Allows to select browser in which http(s) link should be opened.


## <a name="UIApplication+OpenURL"> </a>UIApplication+OpenURL
Supports browser selection (optional) and handles case when Safari	is restricted (disabled) in system settings. Suported browsers:

* Safari,
* Chrome,
* Firefox.
	
### Browsers other than Safari
To use other browsers you need to add their schemes to the ***LSApplicationQueriesSchemes*** array
in the *info.plist* file of your app.
	
Add following schemes to support other browsers or case when safari is restricted (disabled):
	
	googlechrome  // for http
	googlechromes // for https
	firefox
	
folowing two are for Opera Mini but they do not work anymore
	
	ohttp
	ohttps
