Resumable Uploader
==================

A resumable, drag & drop uploader that either
POSTs the file metadata and then sequentially PUTs file slices, 
or POSTs standard multipart/form-data.

It _appears_ to be very resilient to errors.

It uses Sinatra, jQuery, CoffeeScript et al.

This example was initially based upon Google's [Resumable HTTP Request Proposal](http://code.google.com/p/gears/wiki/ResumableHttpRequestsProposal), 
but I found it too complicated and not particularly RESTful.

I'd very much appreciate your help getting this production-ready.

License
-------

Copyright (c) 2011 Jamie Hodge

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


