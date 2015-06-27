# slip

slip is a stupid simple parser that generates stupid simple presentations.

slip is written in lua and outputs postscript (which can easily be converted to pdf, or opened directly in most pdf viewers)

inspired by [zach gage's tweet](https://twitter.com/helvetica/status/531155104632934400):

> Someone should make a version of PowerPoint that only allows 3 words per slide  
> &mdash; Zach Gage ([@helvetica](https://twitter.com/helvetica))

## usage

	lua slip.lua [INPUT FILE] (OUTPUT FILE)
	if not specified, slip outputs to stdout

## file format

technically all slip presentations are valid markdown! use that for notes or handouts if you want.

the first 2 lines are the slideshow title and author. always. (you can leave them blank but that's pretty weird)

from then on, each slide is denoted by a hash (`#`) and a space followed by a title, then up to 3 points taking up one line each.

any non-empty lines between the end of the third point and the start of the next title are ignored. use them for comments! even better: don't.

	# slide title
	point 1
	point 2
	point 3

each point and title should be less than 140 characters for maximum tweetability and because it'll get cut off by slip after 140 characters.

points will wrap but titles will not. keep them short.

### special points

by placing a particular character (plus one space which is stripped) in front of a point, you can make it do special things. also it's just markdown so yeah. (these points and their spaces don't count toward the 140 character limit)

the dash (`-`) does nothing but it's more markdown-y

the plus (`+`) makes your point hidden (advance the slide to make it appear)

the star (`*`) makes your point monospace (for code)

### big titles

if there is nothing but whitespace (no points!) between the current slide and the next one, then the current slide is considered a big title slide.

basically, its title is horizontally and vertically centered on screen and it's big and bold so it better be important
