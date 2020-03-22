# MacOS Finder Tags From Markdown

Automatically write MacOS Finder tags from your markdown files.

This script reads the 'tags' (keywords) which are defined in the metadata section of a markdown file and writes them as MacOS Finder tags using `openmeta`.

The script is intended to be run automatically by MacOS`s launch service
which will watch the directory where the markdown files are kept. When started by the launch service it checks for files which were modified within 10 seconds ago.

The metadata section of a markdown file is set at the top of the file
with `key: value` lines. You can put as many lines as you need in the metadata section. The metadata section ends on the first empty line.

So the top of a markdown file with metadata may look like this:

```
title: Markdown Finder Tags
author: Mario Zimmermann
tags: #finder #macos #markdown

# Markdown Finder Tags
This script reads the ...
```

Multiple tags are separated by spaces.

If you name your tags with a leading `#` character your tags will work
out-of-the box with [1Writer](http://1writerapp.com) for iOS (and possible other markdown apps). The MacOS Finder tags will be written without the leading `#`.

## Installation
Download and unpack the zip or clone the repo. Put the `mdtags.rb` wherever you like (i.e. in `~/scripts`) and make it executable:

    chmod +x ~/scripts/mdtags.rb

Edit the `de.zisoft.mdtags.plist` and change the path for `mdtags.rb` and the path where your markdown files are stored. So you need to modify the `strings` for the keys `Program`, `WatchPaths` and `WorkingDirectory`.


```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Disabled</key>
	<false/>
	<key>EnvironmentVariables</key>
	<dict>
		<key>LANG</key>
		<string>en_US.UTF-8</string>
	</dict>
	<key>Label</key>
	<string>de.zisoft.mdtags</string>
	<key>Program</key>
	<string>/Users/yourUserName/scripts/mdtags.rb</string>
	<key>WatchPaths</key>
	<array>
		<string>/Users/yourUserName/Dropbox/MyNotes</string>
	</array>
	<key>WorkingDirectory</key>
	<string>/Users/yourUserName/Dropbox/MyNotes</string>
</dict>
</plist>
```

Move the `de.zisoft.mdtags.plist` into `~/Library/LaunchAgents`. To activate it, open your terminal and enter the command:

    launchctl load ~/Library/LaunchAgents/de.zisoft.mdtags.plist

Now, whenever you edit and save a markdown file in the watched directory your tags at the top of the file will be written as Finder tags automatically without any further user interaction needed.

