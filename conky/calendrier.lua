------------------------------------------------------------------
-- [[ Adapdation d'un conky calendrier d'ogmen sur ubuntu.ru ]] --
------------------------------------------------------------------

require 'cairo'

-------------------------------
-- [[ Background creation ]] --
-------------------------------
function list (cr, x, y, bg)
	--Créer l'image du fond
		image_bg = cairo_image_surface_create_from_png (bg)

	--Recueillir des données sur la largeur et la hauteur de l'image
		w = cairo_image_surface_get_width (image_bg)
		h = cairo_image_surface_get_height (image_bg)

	--Comme point de départ, le coin supérieur gauche
		cairo_translate (cr, x, y)

	--Calcul de la taille de l'image
		cairo_scale (cr, 265/w, 265/h)

	--Affichage de l'image
		cairo_set_source_surface (cr, image_bg, 3, -45)
		cairo_paint (cr)
		cairo_surface_destroy (image_bg)
end

--------------------------------------------
-- [[ Calendar by londonali1010 (2009) ]] --
--------------------------------------------
function calendar (cr, x, y, font, fs, fgc, fgd, fge, fga, fda, fea)
	--Définition des couleurs des mois et des jours
		function rgb_to_r_g_b(colour,alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
		end
	
		local day = tonumber(os.date("%w"))
		local day_num = tonumber(os.date("%d"))
	
		local remainder = day_num % 7

		start_day = day - (day_num % 7)+1
		if start_day < 0 then start_day = 7 + start_day end
	
		month = tonumber(os.date("%m"))
		--[[
		month_name = os.date("%B")
		if month == 01 then month_name = "JANVIER"
			elseif month == 02 then month_name = "FEVRIER"
			elseif month == 03 then month_name = "MARS"
			elseif month == 04 then month_name = "AVRIL"
			elseif month == 05 then month_name = "MAI"
			elseif month == 06 then month_name = "JUIN"
			elseif month == 07 then month_name = "JUILLET"
			elseif month == 08 then month_name = "AOUT"
			elseif month == 09 then month_name = "SEPTEMBRE"
			elseif month == 10 then month_name = "OCTOBRE"
			elseif month == 11 then month_name = "NOVEMBRE"
			elseif month == 12 then month_name = "DECEMBRE"
		end

		year = tonumber(os.date("%Y"))
		]]

		days = { "Lu", "Ma", "Me", " Je", "Ve", "Sa", "Di" }


	function get_days_in_month()
		local month_days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
		local d = month_days[month]

		--Recalculer février pour une année bissextile	
			if month == 2 and year % 4 == 0 and (year % 100 ~= 0 or year % 400 ~= 0) then d = 29 end
			return d
	end

	--Largeur égale à la largeur de la fenêtre conky
		local size = conky_window.width

	--Coordonnées d'affichage du calendrier
		cairo_translate(cr, conky_window.width/ 2, 60)
		cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
		cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))

	--Calculer la taille de la police sur la largeur de la fenêtre
		local dpi = tonumber(conky_parse('${exec xdpyinfo | grep resolution | cut -c 18-19}'))
		local font_pixel_size = size / 8
		local font_size = font_pixel_size * 72 / dpi -- 72 pt/in * 1/dpi

	--Definir la taille de la police pour le mois et l'année
		fs = font_size * fs
		cairo_set_font_size(cr, fs * 1.2)

	--Affiche le mois et l'année
		--[[
		local text = month_name .. " " .. year

		cairo_move_to(cr, x + 50 - 3.5 * size / 8, y - 2.5 * size / 8)
		cairo_text_path(cr, text)
		cairo_fill(cr)
		]]

	--Définit la police pour afficher les jours de la semaine
		cairo_set_font_size(cr, fs * 0.8)
		local xi, yi = x - 3.5 * size / 8, y - 1.5 * size / 8
		for i = 1, 7 do
			cairo_move_to(cr, xi, yi)
			cairo_text_path(cr, days[i])
			cairo_fill(cr)
			xi = xi + size/8
		end

	--Définit la police pour les numéros
		cairo_set_font_size(cr, fs * 0.8)

		local xi = x - 3.5 * size / 8 + (start_day - 1) * size / 8
		local yi = y - 0.5 * size / 8

		days_in_month = get_days_in_month()
	
		for i = 1, days_in_month do
			--Affichage du jour courrant
				if i == day_num then
					cairo_set_source_rgba(cr, rgb_to_r_g_b(fgd, fda))
					cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
				else
					cairo_set_source_rgba(cr, rgb_to_r_g_b(fge, fea))
					cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
				end

			cairo_move_to(cr, xi, yi)
			
			--Ajoute un 0 avant les 9 premiers jours
			if i < 10 then cairo_text_path(cr, "  ") end
			
			cairo_text_path(cr, i)
			cairo_fill(cr)
			xi = xi + size / 8
			if xi == x + size / 2 - size / 16 then
				xi = x - 3.5*size / 8
				yi = yi + size / 10
					if yi > y + size / 2 then
						yi = y - 0.5 * size / 8
					end
			end

		end
end

--------------------------------------------------------------------------------

function conky_widgets()
	if conky_window == nil then return end
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

--------------------------------------------------------------------------------

--[[ Creation du fond
	cr = cairo_create (cs)
	list (cr, 
	10, 				 	--Position du l'image par rapport au bord gauche de la fenêtre conky
	10,						--Position de l'image par rapport au bord haut de la fenêtre conky
	"/home/math/chemin"  	--Chemin de l'image du fond du conky
	)
	cairo_destroy(cr)
]]

cr = cairo_create (cs)
	calendar (cr, 
	4,						--X (par rapport au bord gauche de la fenêtre conky)
	365, 					--Y (par rapport au bord gauche de la fenêtre conky)
	"Free Serif",			--Police du calendrier		 
	0.9,						--Taille de la police
	0x606060,				--Mois, année et nom des jours
	0x6EAC0B,				--Jour courant
	0x606060,				--Autres jours 
	1,					--Transparence du texte (0=transparent, 1=opaque)
	1,					--Transparence du jour courant (0=transparent, 1=opaque)
	1						--Transparence des autre jours (0=transparent, 1=opaque)
	)
	cairo_destroy(cr)

end
