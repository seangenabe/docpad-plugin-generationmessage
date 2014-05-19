# Generation message plugin for [DocPad](http://docpad.org)

Immediately send back a custom response while generation has not yet been performed.

## Install

  docpad install generationmessage

## Configure

  plugins:
    generationmessage:
      generationMessageFile: '503-generation.html'   # The path to the generation file.

## Creating a generation message file

You can create a generation message file named "503-generation.html" under your documents or your files folder.

You _can_ create a multi-extension document, such as "503-generation.html.jade", but:

* You will need to specify its path in the configuration.
* You can't use any template helpers as they're not guaranteed to be available at the time the file will be rendered.

## Notes

* I created this plugin so that while the website is generating, Heroku's router won't time out and we can give a meaningful response to visitors.
* Most of the time it will still take time before the website will respond with the generation message due to DocPad's synchronous nature. To solve this, I imagine we would need to put several setImmediate calls to DocPad or TaskGroup, but that is outside the scope of this plugin.
