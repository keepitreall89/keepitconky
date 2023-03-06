--Lua for Feed Card Conky
require 'cairo'

--Function that draws a Card Path from adjacent corner coordinates
function card_path(	x1, y1, x2, y2)
	if conky_window.width <= x1 or conky_window.width<= x2 or
		conky_window.height <= y1 or conky_window.height <= y2 or
		x1 == x2 or y1 == y2 then
		return
	end
	local radius = 3
	
	--Flip them if needed, want x1, y2 to be bottom left point
	if x1 > x2 then
		x1, x2 = x2, x1
	end
	if y1 > y2 then
		y1, y2 = y2, y1
	end
	
	--draw background card for depth effect
	--start at bottom left and go clockwise
	cairo_new_path( cr)
	--set properties
	cairo_set_source_rgba( cr, .5, .5, .5, .5)
	cairo_set_line_width( cr, 2)
	cairo_arc( cr, x1+radius+5, y2-radius+2, radius, .5*math.pi, math.pi)
	cairo_arc( cr, x1+radius+5, y1+radius+2, radius, math.pi, 1.5*math.pi)
	cairo_arc (cr, x2-radius+5, y1+radius+2, radius, 1.5*math.pi, 2*math.pi)
	cairo_arc (cr, x2-radius+5, y2-radius+2, radius, 2*math.pi, .5*math.pi)
	cairo_close_path(cr)
	cairo_fill( cr)
	cairo_stroke(cr)
	cairo_destroy(cr)
	cr = cairo_create(surface)
	
	--draw forground card
	cairo_set_source_rgba( cr, .2, .95, .98, .8)
	cairo_arc( cr, x1+radius, y2-radius, radius, .5*math.pi, math.pi)
	cairo_arc( cr, x1+radius, y1+radius, radius, math.pi, 1.5*math.pi)
	cairo_arc (cr, x2-radius, y1+radius, radius, 1.5*math.pi, 2*math.pi)
	cairo_arc (cr, x2-radius, y2-radius, radius, 2*math.pi, .5*math.pi)
	cairo_close_path(cr)
	cairo_fill( cr)
	cairo_destroy(cr)
	cr = cairo_create(surface)
end

--x and y should be the same an x1, y1 for the card under the text.
--text_list needs to be an array
function card_text(text_list, author_text, x, y)
	local font = "Free Sans"
	local slant = CAIRO_FONT_SLANT_NORMAL
	local weight = CAIRO_FONT_WEIGHT_NORMAL
	local size = 20
	local rgba = {.2, .2, .2, 1}
	local x1 = x + size
	local y1 = y + size + 5
	
	for i, text in pairs(text_list) do
		cairo_set_source_rgba(cr, rgba[1], rgba[2], rgba[3], rgba[4])
		cairo_set_font_size(cr, size)
		cairo_select_font_face(cr, font, slant, weight)
		cairo_move_to(cr, x1, y1)
		cairo_show_text(cr, text)
		cairo_stroke(cr)
		cairo_destroy(cr)
		cr = cairo_create(surface)
		y1 = y1+size
	end
	--draw author
	local author
	if author_text == nil then author = "Anon" else author = author_text end
	author = "@".. author
	--todo find a better way to move to right
	x1 = math.floor(conky_window.width)-10-5-math.floor(string.len(author)*size/1.5)
	y1 = math.floor(y/100)*100 + 100 - gap - size
	slant = CAIRO_FONT_SLANT_ITALIC
	weight = CAIRO_FONT_WEIGHT_BOLD
	font = "FreeMono"
	rgba = {93/255.0, 88/255.0, 102/255.0, 1}
	cairo_set_source_rgba(cr, rgba[1], rgba[2], rgba[3], rgba[4])
	cairo_set_font_size(cr, size)
	cairo_select_font_face(cr, font, slant, weight)
	cairo_move_to(cr, x1, y1)
	cairo_show_text(cr, author)
	cairo_stroke(cr)
	cairo_destroy(cr)
	cr = cairo_create(surface)
	
end

--Main Window function
function conky_main()
	if conky_window == nil then
		return
	end
	surface = cairo_xlib_surface_create(	conky_window.display,
											conky_window.drawable,
											conky_window.visual,
											conky_window.width,
											conky_window.height)
	--Card list
	cpus = {tonumber(conky_parse("${cpu cpu0}")),
		tonumber(conky_parse("${cpu cpu1}")),
		tonumber(conky_parse("${cpu cpu2}")),
		tonumber(conky_parse("${cpu cpu3}")),
		tonumber(conky_parse("${cpu cpu4}")),
		tonumber(conky_parse("${cpu cpu5}")),
		tonumber(conky_parse("${cpu cpu6}")),
		tonumber(conky_parse("${cpu cpu7}")),
		tonumber(conky_parse("${cpu cpu8}")),
		tonumber(conky_parse("${cpu cpu9}")),
		tonumber(conky_parse("${cpu cpu10}")),
		tonumber(conky_parse("${cpu cpu11}")),
		tonumber(conky_parse("${cpu cpu12}")),
		tonumber(conky_parse("${cpu cpu13}")),
		tonumber(conky_parse("${cpu cpu14}")),
		tonumber(conky_parse("${cpu cpu15}"))}
	local cpu_sum = 0
	for i, cpu in pairs(cpus) do
		cpu_sum = cpu_sum+cpu
		end
	cpu_sum = cpu_sum/16
	local cards = {
		{
			text = {conky_parse("The ${running_processes} things that you probably"),
				"know are running on your computer."},
			author = "In_the_Running"
			},
		{
			text = {conky_parse("The ${processes} scary things that you"),
				"don't know are running."},
			author = "Gremlins"
			},
		{
			text = {"You may be using only "..tostring(cpu_sum).."%",
				"of your CPU!"},
			author = "Missed_Cycles_Inc"
			}
		}
	local x = 5
	local y = 5
	local x2 = conky_window.width-10
	local y2 = 100
	gap = 5
	--leaving out the 'local' makes this a global
	cr = cairo_create(surface)
	
	for i, card in pairs(cards) do
		card_path(x, y, x2, y2)
		card_text(card.text, card.author, x, y)
		y = y2 + gap
		y2 = y2 + 100
	end 
	
	
	cairo_destroy(cr)
	cairo_surface_destroy(surface)
	cr = nil
end
	