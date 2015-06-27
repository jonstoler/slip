#!/usr/local/bin/lua

-- version 1.0
-- June 26, 2015

local settings = {
	pagewidth = 842,
	pageheight = 595,
	pagesettings = "0 0 0 setrgbcolor",

	linespace = 45,

	maintitlefont = "Helvetica-Bold",
	maintitlesize = 48,
	maintitleY = 330,
	maintitlecolor = "0 0 0",

	authorfont = "Helvetica",
	authorsize = 36,
	authorY = 270,
	authorcolor = "0.5 0.5 0.5",

	titlefont = "Helvetica-Bold",
	titlesize = 48,
	titleY = 500,

	bigtitlefont = "Helvetica-Bold",
	bigtitlesize = 64,

	codefont = "Courier",

	pointY = 400,
	pointX = 100,
	pointgap = 80,
	pointfont = "Helvetica",
	pointsize = 36,
	pointdraw = "gsave currentpoint exch 20 sub exch 9 add 6 0 360 arc closepath 0 setgray fill grestore",

	barcolor = "0.8 0.8 0.8",
	barfillcolor = "0.6 0.6 0.6",
	barX = 80,
	barY = 20,
	barwidth = 682,
	barheight = 3,
}

local slides = {}
local current
local title, author

local function usage()
	print "slip [INPUT] (OUTPUT)"
	print "if not specified, slip outputs to stdout"
end

if #arg == 0 then
	usage()
	return 0
end

local input, output
input = arg[1]
output = arg[2]

local f = io.open(input)
if not f then
	io.stderr:write("Could not open file " .. input .. ".")
	return 0
end
f:close()

local ps = ""
local endl = "\n"

do
	local current = nil
	for line in io.lines(input) do
		if not title then
			title = line:sub(1, 140)
		elseif not author then
			author = line:sub(1, 140)
		elseif line:match("^#") then
			line = line:sub(3, 142)
			table.insert(slides, {points = {}})
			current = slides[#slides]
			current.title = line
		elseif line ~= "" then
			if #current.points < 3 then
				table.insert(current.points, line)
			end
		end
	end
end

local function tpl(str, tbl)
	tbl = tbl or _G
	return (str:gsub("%#{(.-)%}", function(key)
		local current = tbl
		for match in (key .. "."):gmatch("(.-)%.") do
			if match:match("(.-)%[(.-)%]") then
				local t, key = match:match("(.-)%[(.-)%]")
				current = current[t] or {}
				current = current[tonumber(key)]
			else
				current = current[match]
			end
			if not current then return "#{" .. key .. "}" end
		end
		return current
	end))
end

ps = [[
%!PS
<< /PageSize [#{pagewidth} #{pageheight}] /Orientation 0 >> setpagedevice

/F { exch selectfont } def
/FMainTitle { #{maintitlesize} /#{maintitlefont} F } def
/FAuthor { #{authorsize} /#{authorfont} F } def
/FBigTitle { #{bigtitlesize} /#{bigtitlefont} F } def
/FTitle { #{titlesize} /#{titlefont} F } def
/FPoint { #{pointsize} /#{pointfont} F } def
/FCode { #{pointsize} /#{codefont} F } def

/w { #{pagewidth} } def
/h { #{pageheight} } def
/hw { w 2 div } def
/hh { h 2 div } def

/pagesetup { #{pagesettings} } def
/P { showpage pagesetup } def
/S { show } def

/mv { exch moveto } def

/center { dup stringwidth pop 2 div neg 0 rmoveto } def

/maintitle { #{maintitlecolor} setrgbcolor #{maintitleY} hw mv FMainTitle center S } def
/author { #{authorcolor} setrgbcolor #{authorY} hw mv FAuthor center S } def
/bigtitle { hh hw mv FBigTitle center S } def
/title { #{titleY} hw mv FTitle center S } def
/pt { #{pointdraw} } def

/br { #{pointX} currentpoint exch pop moveto 0 #{linespace} neg rmoveto } def
/toofar? { dup stringwidth pop currentpoint pop add ]] .. settings.pagewidth - settings.pointX .. [[ gt } bind def
/showword { toofar? {br} if show } def
/wrap { {( ) search exch showword not {exit} if show} loop} def

pagesetup
]]

ps = ps ..
	"(" .. title .. ") maintitle" .. endl ..
	"(" .. author .. ") author" .. endl .. "P" .. endl

for idx, slide in pairs(slides) do
	local function bar()
		return [[
#{barcolor} setrgbcolor	
#{barX} #{barY} #{barwidth} #{barheight} rectfill
#{barfillcolor} setrgbcolor
#{barX} #{barY} ]] .. math.ceil(settings.barwidth * (idx / #slides)) .. " #{barheight} rectfill" .. endl .. "P" .. endl
	end
	if #slide.points == 0 then -- big title
		ps = ps .. tpl([[
(#{title}) bigtitle
]], slide)
	else
		local page = tpl([[
(#{title}) title
#{pointY} #{pointX} mv
]], slide)
		for pidx, point in pairs(slide.points) do
			local pointtype = "FPoint"
			if point:sub(1, 1) == "-" then
				point = point:sub(3, 142)
			elseif point:sub(1, 1) == "+" then
				point = point:sub(3, 142)
				ps = ps .. page .. bar()
			elseif point:sub(1, 1) == "*" then
				point = point:sub(3, 142)
				pointtype = "FCode"
			else
				point = point:sub(1, 140)
			end
			page = page .. "pt" .. endl .. pointtype .. " (" .. point .. [[) wrap
#{pointX} currentpoint exch pop moveto
0 #{pointgap} neg rmoveto
]]
		end
		ps = ps .. page
	end

	ps = ps .. bar()
end

ps = tpl(ps, settings)

if output then
	local f = io.open(output, "w")
	f:write(ps)
	f:close()
else
	io.write(ps)
end
