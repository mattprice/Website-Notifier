## About
Website Notifier is a script for Mac OSX 10.8 (Mountain Lion) that notifies you of website changes via Notification Center. It could be easily modified to work with other operating systems or other notification systems, such as [Growl](http://growl.info).

## Configuration
Create a configuration file named `config.yml`. A `config-example.yml` is provided to help you get started:

```yaml
"http://example.com/":                       # Website to check for updates
  alert     : Example.com has been updated.  # Text to display for the notification
  frequency : 60                             # Frequency (in minutes) to perform the check

"http://example.com/page/2/":                # Website to check for updates
  alert     : The second page was updated.   # Text to display for the notification
  frequency : 1440                           # Frequency (in minutes) to perform the check
```

## License (MIT)
Copyright (c) 2013 Matthew Price, http://mattprice.me/

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.