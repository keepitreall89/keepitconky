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
end

--x and y should be the same an x1, y1 for the card under the text.
--text_list needs to be an array
function card_text(text_list, author_text, x, y)
	local font = "Free Sans"
	local slant = CAIRO_FONT_SLANT_NORMAL
	local weight = CAIRO_FONT_WEIGHT_BOLD
	local size = 14
	local rgba = {.2, .2, .2, 1}
	local x1 = x + size
	local y1 = y + size + 5
	
	for text in text_list do
		cairo_set_source_rgba(cr, rgba[0], rgba[1], rgba[2], rgba[3])
		cairo_set_font_size(cr, size)
		cairo_set_font_face(cr, font, slant, weight)
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
	--todo find a better way to move to right
	x1 = math.floor(conky_window.width)-10-5-(string.len(author)*size)
	y1 = math.floor(y/100)*100 + 100 - 10 - size
	slant = CAIRO_FONT_SLANT_ITALIC
	rgba = {93/255.0, 88/255.0, 102/255.0}
	cairo_set_source_rgba(cr, rgba[0], rgba[1], rgba[2], rgba[3])
	cairo_set_font_size(cr, size)
	cairo_set_font_face(cr, font, slant, weight)
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
	--leaving out the 'local' makes this a global
	cr = cairo_create(surface)
	card_path(5, 5, conky_window.width-10, 100)
	cairo_destroy(cr)
	cr = cairo_create(surface)
	local value = tonumber(conky_parse("${running_processes}"))
	local value_text = conky_parse("The ${running_processes} things that you probably know are running.")
	cairo_set_source_rgba(cr, .2,.2,.2,1)
	cairo_select_font_face(cr, "Free Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
	cairo_set_font_size(cr, 14)
	cairo_move_to(cr, 20, 25)
	cairo_show_text(cr, value_text)
	cairo_stroke(cr)
	
	
	cairo_destroy(cr)
	cairo_surface_destroy(surface)
	cr = nil
end
	