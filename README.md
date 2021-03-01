# imageAsBase64
Implementations allowing to convert/use regular image as base64 content

## Into

It it started with me wanting to paste an clipboard-stored image as `base64` content in `markdown` documents, so I started to develop an extension for `vs code` that will allow to do it..

I later realized that it should not be an application-specific feature, like, in this case -  `VS code` feature.. but a system-wide functionality.

We have means of making this functionality in either an `AutoHotkey` or `Powershell` or other `tool`/language of our choice. 

## Current implementations

### 1. `Powershell` global keyboard hook

The script is listening for key-presses. In default implementaion - once `pause` key press is detected - the script will try to extract the `raw` image from the clipboard, and, if the image is found - it will set the value of the clipboard to `base64` string and execute `CTRL+V` command to paste the contents into currently active window.

The value will contain a valid `markdown` image format.

*Edit the source code for it to suit your needs.*

#### Known problems

- if you assign a hook to `F1` button, then some programs could mess up with the script. For example `Chrome` will corrupt the automation script.
- we cannot unfortunatelly use `GetAsyncKeyState` method. Windows Defender flags the `powershell` script as a trojan and removes the file.
- to exit the script you have to press `CTRL+C` plus any additional button.
