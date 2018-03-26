# mmunrtf

Shell script that translates a MindMeister RTF file to a HTML formatted file.
Therefore it's name: un-rtf MindMeister RTF exports.

Tested successfully on Ubuntu and macOS.

## Basic explanation

The script
1. filters all lines with a 'liXXX' statement at the end
1. then replaces the liXXX expressions with tabs (the higher XXX is the more tabs are inserted)
1. delete all unnecessary lines and characters
1. depending on the number of tabs per line wrap the text with h1, h2, h3 or ul tags

## Usage

`mmunrtf.sh mindmeister_export.rtf > mindmeister_export.html`
