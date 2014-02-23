# StevieWhale Agent
This utility is used in order to connect to [StevieWhale](http://github.com/molefrog/steviewhale) server and act as a printing agent that will
accept printing jobs remotely. The concept of RPC (Remote Procedure) through WebSockets is used here. The `socket.io` library is used to set up and hold connection with the server (also called as Pool of printing agents).

# Configuration
In order to run application you have to have `config.json` file. Typically, it will look like:
```JSON
{
	"pool"  : {
		"address" : "http://steviewhale.com",
		"name"    : "<Your stations name>",
		"secret"  : "<Your stations secret>",
		"timeout" : 20000
	}, 

	"printer" : {
		"name" : "Canon_CP800",
		"options" : {
			"media" : "Postcard(4x6in)"
		}
	}
}
```

## License
The MIT License (MIT)

Copyright (c) 2014 Alexey Taktarov molefrog@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.