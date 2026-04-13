local mod = get_mod("markers_aio")
mod.version = "2.12.03"
mod:info("Markers Improved AIO Improved is installed, using version: " .. tostring(mod.version))

mod.lookup_border_color = function(colour_string)
	local border_colours = {
		["Gold"] = {
			255,
			232,
			188,
			109,
		},
		["Silver"] = {
			255,
			187,
			198,
			201,
		},
		["Steel"] = {
			255,
			161,
			166,
			169,
		},
		["Tarnished"] = {
			255,
			120,
			57,
			0,
		},
	}
	return border_colours[colour_string]
end

-- Always use an updated font list.
-- Thanks to GideonAriphael on Nexusmods for recommendation
mod._get_font_options = function()
	local FontDefinitions = require("scripts/managers/ui/ui_fonts_definitions")
	local fonts = FontDefinitions.fonts or {}
	local options = {}
	local i = 1

	for font_name, _ in pairs(fonts) do
		options[i] = { text = font_name, value = font_name }
		i = i + 1
	end

	-- Sort alphabetically by the underlying font name for consistency
	table.sort(options, function(a, b)
		return a.value < b.value
	end)

	return options
end

-- function to apply font face to localisation text
local apply_font_to_text = function(text, font_name)
	return string.format("{#font(%s)}%s{#reset()}", font_name, text)
end

local insert_fonts = function(localisation_table)
	local fonts_data = mod._get_font_options()

	for _, data in pairs(fonts_data) do
		-- Convert snake_case to Title Case for display (e.g. proxima_nova_bold -> Proxima Nova Bold)
		local readable = data.text:gsub("_", " "):gsub("(%a)([%w]*)", function(first, rest)
			return first:upper() .. rest
		end)

		local text = string.format("%s", readable)

		local new_localised_readable_text = {
			en = apply_font_to_text(text, data.value),
		}
		localisation_table[data.value] = new_localised_readable_text
	end
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

mod.gradientText = function(text, startColor, endColor, colorSpaces)
	local result = ""
	local length = #text
	local visibleIndex = 0

	-- Count visible characters
	for i = 1, length do
		local char = text:sub(i, i)
		if colorSpaces or char ~= " " then
			visibleIndex = visibleIndex + 1
		end
	end

	local currentIndex = 0

	for i = 1, length do
		local char = text:sub(i, i)

		if not colorSpaces and char == " " then
			result = result .. char
		else
			currentIndex = currentIndex + 1
			local t = (visibleIndex <= 1) and 0 or (currentIndex - 1) / (visibleIndex - 1)

			local r = math.floor(lerp(startColor[1], endColor[1], t))
			local g = math.floor(lerp(startColor[2], endColor[2], t))
			local b = math.floor(lerp(startColor[3], endColor[3], t))

			result = result .. string.format("{#color(%d,%d,%d)}%s", r, g, b, char)
		end
	end

	result = result .. "{#reset()}"
	return result
end

local colours = {
	title = "200,140,20",
	subtitle = "226,199,126",
	text = "169,191,153",
	faded_text = "84,95,76",
}

-- rainbow
-- en = "{#color(255,0,0)}M{#color(255,85,0)}a{#color(255,170,0)}r{#color(255,255,0)}k{#color(170,255,0)}e{#color(85,255,0)}r{#color(0,255,0)}s {#color(0,255,85)}I{#color(0,255,170)}m{#color(0,255,255)}p{#color(0,170,255)}r{#color(0,85,255)}o{#color(0,0,255)}v{#color(85,0,255)}e{#color(170,0,255)}d {#color(255,0,255)}A{#color(255,0,170)}I{#color(255,0,85)}O{#reset()}",
-- fire
-- en = "{#color(255,0,0)}M{#color(255,32,0)}a{#color(255,64,0)}r{#color(255,96,0)}k{#color(255,128,0)}e{#color(255,160,0)}r{#color(255,192,0)}s {#color(255,224,0)}I{#color(255,240,64)}m{#color(255,255,128)}p{#color(255,255,160)}r{#color(255,255,192)}o{#color(255,255,210)}v{#color(255,255,225)}e{#color(255,255,240)}d {#color(255,255,255)}A{#color(255,220,180)}I{#color(255,200,150)}O{#reset()}",
-- ice
-- en = "{#color(0,128,255)}M{#color(0,110,255)}a{#color(0,90,255)}r{#color(0,70,255)}k{#color(30,50,255)}e{#color(60,30,255)}r{#color(90,0,255)}s {#color(120,0,255)}I{#color(140,0,255)}m{#color(160,0,255)}p{#color(180,0,255)}r{#color(200,0,255)}o{#color(220,0,255)}v{#color(235,0,255)}e{#color(245,0,255)}d {#color(255,0,255)}A{#color(255,0,200)}I{#color(255,0,150)}O{#reset()}",
-- green
-- en = "{#color(0,255,120)}M{#color(0,255,130)}a{#color(0,255,140)}r{#color(0,255,150)}k{#color(0,255,160)}e{#color(0,255,170)}r{#color(0,255,180)}s {#color(0,255,190)}I{#color(0,255,200)}m{#color(0,255,210)}p{#color(0,255,220)}r{#color(0,255,230)}o{#color(0,255,240)}v{#color(0,255,250)}e{#color(0,240,255)}d {#color(0,220,255)}A{#color(0,200,255)}I{#color(0,180,255)}O{#reset()}",
-- neon
-- en = "{#color(255,0,255)}M{#color(200,0,255)}a{#color(150,0,255)}r{#color(100,0,255)}k{#color(50,0,255)}e{#color(0,0,255)}r{#color(0,100,255)}s {#color(0,200,255)}I{#color(0,255,200)}m{#color(0,255,100)}p{#color(0,255,0)}r{#color(100,255,0)}o{#color(200,255,0)}v{#color(255,255,0)}e{#color(255,150,0)}d {#color(255,100,0)}A{#color(255,50,0)}I{#color(255,0,0)}O{#reset()}",
local loc = {
	mod_name_pizazz_toggle = {
		en = "Enable Name Pizazz",
	},
	mod_name_pizazz_tooltip = {
		en = "Toggles the rainbow colours effect on the mod name text. Requires a reload.\nIf enabled, you will get a small euphoric experience everytime you scroll through the mod menu, \nIf disabled - you will be a John Darktide and have no rainbow sprinkles (but I'll love you anyway).",
	},
	mod_name = {
		en = "{#color("
			.. colours.title
			.. ")} {#color(0,128,255)}M{#color(0,110,255)}a{#color(0,90,255)}r{#color(0,70,255)}k{#color(30,50,255)}e{#color(60,30,255)}r{#color(90,0,255)}s {#color(120,0,255)}I{#color(140,0,255)}m{#color(160,0,255)}p{#color(180,0,255)}r{#color(200,0,255)}o{#color(220,0,255)}v{#color(235,0,255)}e{#color(245,0,255)}d {#color(255,0,255)}A{#color(255,0,200)}I{#color(255,0,150)}O{#reset()}",
		ru = "Улучшенные метки - все в одном",
		["zh-tw"] = "標記改進整合版",
		["zh-cn"] = "全功能标记集成",
	},
	mod_name_pizazz = {
		en = "{#color("
			.. colours.title
			.. ")} {#color(0,128,255)}M{#color(0,110,255)}a{#color(0,90,255)}r{#color(0,70,255)}k{#color(30,50,255)}e{#color(60,30,255)}r{#color(90,0,255)}s {#color(120,0,255)}I{#color(140,0,255)}m{#color(160,0,255)}p{#color(180,0,255)}r{#color(200,0,255)}o{#color(220,0,255)}v{#color(235,0,255)}e{#color(245,0,255)}d {#color(255,0,255)}A{#color(255,0,200)}I{#color(255,0,150)}O{#reset()}",
		ru = "Улучшенные метки - все в одном",
		["zh-tw"] = "標記改進整合版",
		["zh-cn"] = "全功能标记集成",
	},
	mod_name_boring = {
		en = "Markers Improved AIO",
	},
	mod_description = {
		en = "{#color("
			.. colours.text
			.. ")}Adds brand new markers to some collectables, options such as distance, colour choices, line-of-sight toggles, a whole in-mission Martyr's Skull collection guide and more.{#reset()}\n\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Author: "
			.. "{#color("
			.. colours.text
			.. ")}Alfthebigheaded\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Version: {#color("
			.. colours.text
			.. ")}"
			.. mod.version
			.. "{#reset()}",
		fr = "Combine tous mes mods 'Marqueurs' en un seul paquet facile à installer. ",
		ru = "Markers Improved AIO - Объединяет все мои моды «Меток» в один простой в установке пакет.",
		["zh-tw"] = "將所有「標記」模組整合成一個方便安裝的套件。",
		["zh-cn"] = "为各类可收集物品添加全新标记，支持距离、颜色、视野显示等设置，内置殉道者颅骨收集攻略等功能。",
	},

	-- General Settings
	aio_settings = {
		en = "{#color(" .. colours.title .. ")}" .. "Global Marker Settings" .. "{#reset()}",
		fr = "MARKERS IMPROVED AIO SETTINGS",
		ru = "MARKERS IMPROVED AIO SETTINGS",
		["zh-tw"] = "圖標改善設定",
		["zh-cn"] = "全功能标记增强设置",
	},
	los_fade_enable = {
		en = "Fade out icons out of line of sight?",
		fr = "Fade out icons out of line of sight",
		ru = "Fade out icons out of line of sight",
		["zh-tw"] = "視線外淡化圖標",
		["zh-cn"] = "视野外图标淡出",
	},
	los_opacity = {
		en = "Out of Line of sight marker opacity (percentage)",
		fr = "Line of sight alpha (percentage)",
		ru = "Line of sight alpha (percentage)",
		["zh-tw"] = "視線外圖標透明度",
		["zh-cn"] = "视野外图标透明度（百分比）",
	},
	ads_los_opacity = {
		en = "ADS Line of sight marker opacity (percentage)",
		["zh-tw"] = "瞄準視線外的圖標透明度",
		["zh-cn"] = "开镜视野外图标透明度（百分比）",
	},
	marker_background_colour = {
		en = "Marker background colour",
		["zh-tw"] = "標記背景顏色",
		["zh-cn"] = "标记背景颜色",
	},
	font_type = {
		en = "Choose a font style (Global)",
		["zh-cn"] = "选择字体样式（全局）",
	},
	font_type_tooltip = {
		en = "The global font style to use. This will apply to all text elements from Markers AIO Improved.",
		["zh-cn"] = "设置使用的全局字体样式，将应用于「标记整合增强版」的所有文本元素。",
	},

	distance_text_enable = {
		en = "Toggle distance indicator",
		["zh-cn"] = "开启距离指示器",
	},
	distance_text_enable_tooltip = {
		en = "Adds a text-based indicator near the markers that shows their distance from you in meters.",
		["zh-cn"] = "在标记旁显示文字指示器，以米为单位显示与你的距离。",
	},
	distance_text_position = {
		en = "Distance indicator position",
		["zh-cn"] = "距离指示器位置",
	},
	distance_text_position_tooltip = {
		en = "Pick where to place the distance indicator in relation to the marker.\nNote: Center positioning will make the icon fade a little so you can always read the text.",
		["zh-cn"] = "选择距离指示器相对于标记的显示位置。\n注意：选择居中时图标会略微淡化，确保文字清晰可见。",
	},
	distance_text_scale = {
		en = "Distance indicator text scale",
		["zh-cn"] = "距离指示器文字大小",
	},

	Top = {
		en = "Top",
		["zh-cn"] = "顶部",
	},
	Bottom = {
		en = "Bottom",
		["zh-cn"] = "底部",
	},
	Left = {
		en = "Left",
		["zh-cn"] = "左侧",
	},
	Right = {
		en = "Right",
		["zh-cn"] = "右侧",
	},
	Center = {
		en = "Center",
		["zh-cn"] = "居中",
	},

	-- AMMO MED MARKERS
	ammo_med_markers_settings = {
		en = "AMMO & MED MARKERS",
		fr = "MARQUEURS DE MUNITIONS ET MÉDICAUX",
		ru = "МЕТКИ - БОЕПРИПАСЫ И МЕДИЦИНА",
		["zh-tw"] = "彈藥與醫療標記",
		["zh-cn"] = "弹药与医疗标记",
	},
	ammo_med_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	ammo_med_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	ammo_med_markers_alternate_large_ammo_icon = {
		en = "Use Alternative Icon for Large Ammo pickups",
		fr = "Utiliser une icône alternative pour les grandes munitions ramassées",
		ru = "Использовать альтернативные значки для больших сумок с боеприпасами",
		["zh-tw"] = "使用替代圖示表示大型彈藥",
		["zh-cn"] = "大型弹药包使用替代图标",
	},
	ammo_med_keep_on_screen = {
		en = "Keep on screen",
		fr = "Rester à l'écran",
		ru = "Держать на экране",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	ammo_med_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	ammo_med_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	med_station_max_distance = {
		en = "Medicae Station marker max distance",
		["zh-tw"] = "醫療站標記最大距離",
		["zh-cn"] = "医疗站标记最大显示距离",
	},
	ammo_med_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	ammo_med_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	ammo_med_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	ammo_med_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	display_med_charges = {
		en = "Display Medical Charges",
		fr = "Afficher les charges médicales",
		ru = "Показывать заряды медстанции",
		["zh-tw"] = "顯示醫療充能",
		["zh-cn"] = "显示医疗箱使用次数",
	},
	display_ammo_charges = {
		en = "Display Ammo Charges",
		fr = "Afficher les charges de munitions",
		ru = "Показывать заряды ящика с боеприпасами",
		["zh-tw"] = "顯示彈藥充能",
		["zh-cn"] = "显示弹药箱使用次数",
	},
	display_field_improv_colour = {
		en = "Adjust colours if 'Field Improvisation' is active?",
		fr = "Ajuster la couleur pour le talent 'Improvisation sur le terrain' ? ",
		ru = "Изменять цвет маркеров, если активен талант «Полевая импровизация»?",
		["zh-tw"] = "如果啟用「現場應變」天賦，調整標記顏色？",
		["zh-cn"] = "激活「临场应变」天赋时更改标记颜色",
	},
	display_field_improv_icon = {
		en = "Display 'Field Improvisation' Icon",
		fr = "Afficher la nouvelle icône du talent 'Improvisation sur le terrain'",
		ru = "Показывать новый значок таланта «Полевая импровизация»",
		["zh-tw"] = "顯示新的「現場應變」天賦圖示",
		["zh-cn"] = "显示「临场应变」天赋专属图标",
	},
	display_med_ring = {
		en = "Display Proximity Radius Around Medkits?",
		fr = "Afficher le rayon de proximité autour des kits médicaux ?",
		ru = "Показывать радиус действия медпакетов?",
		["zh-tw"] = "顯示醫療包周圍的接近半徑？",
		["zh-cn"] = "显示医疗箱生效范围圈",
	},
	change_colour_for_ammo_charges = {
		en = "Change ammo & medicae crate colour depending on charges left?",
		fr = "Changer la couleur des caisses de munitions en fonction des charges ? ",
		ru = "Изменять цвет значка ящика с боеприпасами в зависимости от оставшихся зарядов?",
		["zh-tw"] = "根據剩餘充能改變彈藥箱顏色？",
		["zh-cn"] = "根据剩余次数改变弹药/医疗箱颜色",
	},
	ammo_small_colour = {
		en = "Ammo (Small) Colour",
		fr = "Couleur des munitions (petites)",
		ru = "Цвет малой сумки с боеприпасами",
		["zh-tw"] = "彈藥（小型）顏色",
		["zh-cn"] = "小型弹药罐颜色",
	},
	field_improv_colour = {
		en = "Field Improvisation Talent Proximity Radius Colour",
		["zh-cn"] = "如果有老兵装备临场发挥天赋时的邻近范围颜色",
	},
	field_improv_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	field_improv_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	field_improv_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	ammo_small_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	ammo_small_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	ammo_small_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	ammo_small_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	ammo_large_colour = {
		en = "Ammo (Large) Colour",
		fr = "Couleur des munitions (grandes)",
		ru = "Цвет большой сумки с боеприпасами",
		["zh-tw"] = "彈藥（大型）顏色",
		["zh-cn"] = "大型弹药包颜色",
	},
	ammo_large_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	ammo_large_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	ammo_large_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	ammo_large_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	ammo_crate_colour = {
		en = "Ammo Crate Colour",
		fr = "Couleur de la caisse de munitions",
		ru = "Цвет ящика с боеприпасами",
		["zh-tw"] = "彈藥箱顏色",
		["zh-cn"] = "弹药箱颜色",
	},
	ammo_crate_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	ammo_crate_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	ammo_crate_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	ammo_crate_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	med_crate_colour = {
		en = "Medical Crate Colour",
		fr = "Couleur de la caisse médicale",
		ru = "Цвет медпакета",
		["zh-tw"] = "醫療箱顏色",
		["zh-cn"] = "医疗箱颜色",
	},
	med_crate_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	med_crate_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	med_crate_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	med_crate_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	grenade_colour = {
		en = "Grenade Colour",
		fr = "Couleur des grenades",
		ru = "Цвет гранат",
		["zh-tw"] = "手榴彈顏色",
		["zh-cn"] = "手雷颜色",
	},
	grenade_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	grenade_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	grenade_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	grenade_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},

	-- CHEST MARKERS
	chest_markers_settings = {
		en = "CHEST MARKERS",
		fr = "MARQUEURS DE COFFRES",
		ru = "МЕТКИ ЯЩИКОВ",
		["zh-tw"] = "寶箱圖標",
		["zh-cn"] = "宝箱标记",
	},
	chest_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	chest_alternative_icon = {
		en = "Use Alternative Icon",
		fr = "Utiliser une icône alternative",
		ru = "Включить альтернативный значок",
		["zh-tw"] = "使用替代圖示",
		["zh-cn"] = "使用替代图标",
	},
	chest_icon = {
		en = "Use Alternative Icon",
		fr = "Utiliser une icône alternative",
		ru = "Включить альтернативный значок",
		["zh-tw"] = "使用替代圖示",
		["zh-cn"] = "使用替代图标",
	},
	Default = {
		en = "Default",
		["zh-tw"] = "預設",
		["zh-cn"] = "默认",
	},
	Video = {
		en = "Video",
		["zh-tw"] = "影片",
		["zh-cn"] = "录像",
	},
	Loot = {
		en = "Loot",
		["zh-tw"] = "戰利品",
		["zh-cn"] = "战利品",
	},
	chest_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	chest_keep_on_screen = {
		en = "Keep on screen",
		fr = "Rester à l'écran",
		ru = "Держать на экране",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	chest_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	chest_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	chest_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	chest_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	chest_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	chest_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	chest_icon_colour = {
		en = "Chest Icon Colour",
		fr = "Couleur de l'icône du coffre",
		ru = "Цвет значка ящика",
		["zh-tw"] = "寶箱圖標顏色",
		["zh-cn"] = "宝箱图标颜色",
	},
	chest_icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	chest_icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	chest_icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	chest_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},

	-- HERETICAL IDOL MARKERS
	heretical_idol_markers_settings = {
		en = "HERETICAL IDOL MARKERS",
		fr = "MARQUEURS D'IDÔLES HÉRÉTIQUES",
		ru = "МЕТКИ ЕРЕТИЧЕСКИХ ИДОЛОВ",
		["zh-tw"] = "異端雕像圖標",
		["zh-cn"] = "异端雕像图标",
	},
	heretical_idol_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	heretical_idol_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	heretical_idol_keep_on_screen = {
		en = "Keep on screen",
		fr = "Rester à l'écran",
		ru = "Держать на экране",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	heretical_idol_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	heretical_idol_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	heretical_idol_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "標記的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	heretical_idol_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	heretical_idol_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	heretical_idol_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},

	icon_colour = {
		en = "Icon Colour",
		fr = "Couleur de l'icône",
		ru = "Цвет значка",
		["zh-tw"] = "圖示顏色",
		["zh-cn"] = "图标颜色",
	},
	icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	idol_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},

	-- MATERIAL MARKERS
	material_markers_settings = {
		en = "MATERIAL MARKERS",
		fr = "MARQUEURS DE MATÉRIAUX",
		ru = "МЕТКИ РЕСУРСОВ",
		["zh-tw"] = "材料圖標",
		["zh-cn"] = "物资标记",
	},
	material_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	material_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	material_keep_on_screen = {
		en = "Keep on screen",
		fr = "Rester à l'écran",
		ru = "Держать на экране",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	material_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	material_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	material_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	material_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	material_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	material_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	marker_toggles = {
		en = "Toggle Materials",
		fr = "Basculer les matériaux",
		ru = "Переключение ресурсов",
		["zh-tw"] = "切換材料",
		["zh-cn"] = "材料显示开关",
	},
	toggle_large_plasteel = {
		en = "Show Large Plasteel Markers",
		fr = "Afficher les marqueurs des grandes caches de plastacier",
		ru = "Показывать метки больших кусков пластали",
		["zh-tw"] = "顯示大型塑鋼標記",
		["zh-cn"] = "显示大型塑钢箱标记",
	},
	toggle_small_plasteel = {
		en = "Show Small Plasteel Markers",
		fr = "Afficher les marqueurs des petites caches de plastacier",
		ru = "Показывать метки малых кусков пластали",
		["zh-tw"] = "顯示小型塑鋼標記",
		["zh-cn"] = "显示小型塑钢箱标记",
	},
	toggle_large_diamantine = {
		en = "Show Large Diamantine Markers",
		fr = "Afficher les marqueurs des grandes caches de diamantine",
		ru = "Показывать метки больших кусков диамантина",
		["zh-tw"] = "顯示大型金剛晶石標記",
		["zh-cn"] = "显示大型金刚砂箱标记",
	},
	toggle_small_diamantine = {
		en = "Show Small Diamantine Markers",
		fr = "Afficher les marqueurs des petites caches de diamantine",
		ru = "Показывать малых больших кусков диамантина",
		["zh-tw"] = "顯示小型金剛晶石標記",
		["zh-cn"] = "显示小型金刚砂箱标记",
	},
	plasteel_icon_colour = {
		en = "Plasteel Icon Colour",
		fr = "Couleur de l'icône plastacier",
		ru = "Цвет значка пластали",
		["zh-tw"] = "塑鋼圖示顏色",
		["zh-cn"] = "塑钢图标颜色",
	},
	plasteel_icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	plasteel_icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	plasteel_icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	diamantine_icon_colour = {
		en = "Diamantine Icon Colour",
		fr = "Couleur de l'icône diamantine",
		ru = "Цвет значка диамантина",
		["zh-tw"] = "金剛晶石圖示顏色",
		["zh-cn"] = "金刚砂图标颜色",
	},
	diamantine_icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	diamantine_icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	diamantine_icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	material_small_border_colour = {
		en = "Small Material Cache Border Colour",
		fr = "Couleur de la bordure des petites caches",
		ru = "Цвет границы малого тайника с ресурсами",
		["zh-tw"] = "小型材料儲存邊框顏色",
		["zh-cn"] = "小型物资箱边框颜色",
	},
	material_large_border_colour = {
		en = "Large Material Cache Border Colour",
		fr = "Couleur de la bordure des grandes caches",
		ru = "Цвет границы большого тайника с ресурсами",
		["zh-tw"] = "大型材料儲存邊框顏色",
		["zh-cn"] = "大型物资箱边框颜色",
	},

	-- STIMM MARKERS
	stimm_markers_settings = {
		en = "STIMM MARKERS",
		fr = "MARQUEURS STIMM",
		ru = "МЕТКИ СТИМУЛЯТОРОВ",
		["zh-tw"] = "興奮劑標記",
		["zh-cn"] = "兴奋剂标记",
	},
	stimm_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	broker_stimm_enable = {
		en = "Enable Hive Scum Stimm Markers",
		["zh-tw"] = "啟用巢都敗類興奮劑標記",
		["zh-cn"] = "启用巢都混混兴奋剂标记",
	},
	stimm_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	stimm_keep_on_screen = {
		en = "Keep on screen",
		fr = "Rester à l'écran",
		ru = "Держать на экране",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	stimm_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	stimm_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	stimm_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	stimm_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	stimm_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	stimm_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	boost_stimm_icon_colour = {
		en = "Boost Stimm Icon Colour",
		fr = "Couleur de l'icône de boost Stimm",
		ru = "Цвет значка стимулятора усиления",
		["zh-tw"] = "增強興奮劑圖示顏色",
		["zh-cn"] = "专注兴奋剂图标颜色",
	},
	boost_stimm_icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	boost_stimm_icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	boost_stimm_icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	boost_stimm_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	corruption_stimm_icon_colour = {
		en = "Corruption Stimm Icon Colour",
		fr = "Couleur de l'icône de corruption Stimm",
		ru = "Цвет значка стимулятора лечения",
		["zh-tw"] = "治療針圖示顏色",
		["zh-cn"] = "医疗兴奋剂图标颜色",
	},
	corruption_stimm_icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	corruption_stimm_icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	corruption_stimm_icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	corruption_stimm_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	power_stimm_icon_colour = {
		en = "Power Stimm Icon Colour",
		fr = "Couleur de l'icône de puissance Stimm",
		ru = "Цвет значка стимулятора силы",
		["zh-tw"] = "戰鬥興奮劑圖示顏色",
		["zh-cn"] = "作战兴奋剂图标颜色",
	},
	power_stimm_icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	power_stimm_icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	power_stimm_icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	power_stimm_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	speed_stimm_icon_colour = {
		en = "Speed Stimm Icon Colour",
		fr = "Couleur de l'icône de vitesse Stimm",
		ru = "Цвет значка стимулятора скорости",
		["zh-tw"] = "速度興奮劑圖示顏色",
		["zh-cn"] = "敏捷兴奋剂图标颜色",
	},
	speed_stimm_icon_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	speed_stimm_icon_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	speed_stimm_icon_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	speed_stimm_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	broker_stimm_icon_colour = {
		en = "Hive Scum Stimm Icon Colour",
		["zh-tw"] = "Hive Scum Stimm Icon Colour",
		["zh-cn"] = "巢都渣滓兴奋剂图标颜色",
	},
	broker_stimm_icon_colour_R = {
		en = "R",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	broker_stimm_icon_colour_G = {
		en = "G",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	broker_stimm_icon_colour_B = {
		en = "B",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	broker_stimm_border_colour = {
		en = "Border Colour",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},

	-- TOME MARKERS
	tome_markers_settings = {
		en = "TOME MARKERS",
		fr = "MARQUEURS DE TOME",
		ru = "МЕТКИ КНИГ",
		["zh-tw"] = "聖典標記",
		["zh-cn"] = "圣经标记",
	},
	tome_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	tome_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	tome_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	tome_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	tome_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	tome_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	tome_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	tome_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	tome_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	grim_colour = {
		en = "Grimoire Colour",
		fr = "Couleur du grimoire",
		ru = "Цвет гримуара",
		["zh-tw"] = "魔術書顏色",
		["zh-cn"] = "魔法书颜色",
	},
	grim_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	grim_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	grim_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	script_colour = {
		en = "Scripture Colour",
		fr = "Couleur des textes sacrés",
		ru = "Цвет писания",
		["zh-tw"] = "經典顏色",
		["zh-cn"] = "圣经颜色",
	},
	script_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	script_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	script_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	tome_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},

	-- Tainted Communication Device Markers
	tainted_markers_settings = {
		en = "TAINTED COMMUNICATION DEVICE MARKERS",
		["zh-cn"] = "腐化通讯器标记",
		["zh-tw"] = "腐化通訊裝置圖示",
	},
	tainted_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	tainted_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	tainted_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	tainted_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	tainted_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	tainted_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	tainted_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	tainted_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	tainted_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	tainted_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	tainted_colour = {
		en = "Tainted Communications Device Colour",
		["zh-cn"] = "腐化通讯器颜色",
	},
	tainted_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	tainted_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	tainted_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},

	-- Tainted Skull Markers
	tainted_skull_markers_settings = {
		en = "TAINTED SKULL MARKERS",
		["zh-cn"] = "腐化颅骨标记",
	},
	tainted_skull_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	tainted_skull_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	tainted_skull_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	tainted_skull_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	tainted_skull_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	tainted_skull_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	tainted_skull_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	tainted_skull_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	tainted_skull_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	tainted_skull_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	tainted_skull_colour = {
		en = "Tainted Skull Colour",
		["zh-cn"] = "腐化颅骨颜色",
	},
	tainted_skull_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	tainted_skull_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	tainted_skull_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},

	-- luggable Markers
	luggable_markers_settings = {
		en = "LUGGABLE MARKERS",
		["zh-cn"] = "可搬运物品标记",
	},
	luggable_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	luggable_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	luggable_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	luggable_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	luggable_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	luggable_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	luggable_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	luggable_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	luggable_colour = {
		en = "Luggable Colour",
		["zh-cn"] = "可搬运物品颜色",
	},
	luggable_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	luggable_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	luggable_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	luggable_icon = {
		en = "Use Alternative Icon",
		fr = "Utiliser une icône alternative",
		ru = "Включить альтернативный значок",
		["zh-tw"] = "使用替代圖示",
		["zh-cn"] = "使用替代图标",
	},

	-- Martyrs Skull Markers
	martyrs_skull_markers_settings = {
		en = "MARTYRS SKULL MARKERS",
		["zh-cn"] = "殉道者颅骨标记",
	},
	martyrs_skull_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	martyrs_skull_guide_enable = {
		en = "Enable Skull Collection Guide?",
		["zh-tw"] = "啟用顱骨收集指南？",
		["zh-cn"] = "启用颅骨收集攻略",
	},
	martyrs_skull_guide_disable_if_collected = {
		en = "Only show guide if not collected?",
		["zh-tw"] = "僅在未收集時顯示指南？",
		["zh-cn"] = "仅未收集时显示攻略",
	},
	martyrs_skull_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	martyrs_skull_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	martyrs_skull_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	martyrs_skull_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	martyrs_skull_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	martyrs_skull_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	martyrs_skull_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	martyrs_skull_colour = {
		en = "Martyrs Skull Colour",
		["zh-cn"] = "殉道者颅骨颜色",
	},
	martyrs_skull_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	martyrs_skull_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	martyrs_skull_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},

	Exclamation = {
		en = "Exclamation",
		["zh-tw"] = "驚嘆號",
		["zh-cn"] = "感叹号",
	},
	Hands = {
		en = "Hands",
		["zh-tw"] = "手",
		["zh-cn"] = "手掌",
	},
	Fist = {
		en = "Fist",
		["zh-tw"] = "拳頭",
		["zh-cn"] = "拳头",
	},
	Gold = {
		en = "Gold",
		fr = "Or",
		ru = "Золото",
		["zh-tw"] = "金",
		["zh-cn"] = "金色",
	},
	Silver = {
		en = "Silver",
		fr = "Argent",
		ru = "Серебро",
		["zh-tw"] = "銀",
		["zh-cn"] = "银色",
	},
	Steel = {
		en = "Steel",
		fr = "Acier",
		ru = "Сталь",
		["zh-tw"] = "鋼",
		["zh-cn"] = "钢色",
	},
	Black = {
		en = "Black",
		["zh-tw"] = "黑",
		["zh-cn"] = "黑色",
	},
	Terminal = {
		en = "Terminal",
		["zh-tw"] = "終端",
		["zh-cn"] = "终端",
	},
	Tarnished = {
		en = "Tarnished",
		["zh-cn"] = "暗铜色",
	},
	-- new toggle LOS settings
	martyrs_skull_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	ammo_med_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	chest_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	heretical_idol_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	material_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	stimm_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	tome_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	tainted_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	tainted_skull_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	luggable_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},

	-- MARTYRS SKULL GUIDE LOCALIZATIONS... THERE'S LOTS x)
	martyrs_skull_objective_hm_cartel_1 = {
		en = "Follow number sequence",
		["zh-tw"] = "跟隨數字順序",
		["zh-cn"] = "按数字顺序操作",
	},
	martyrs_skull_objective_km_enforcer_A = {
		en = "First player, press button to start sequence",
		["zh-tw"] = "第一位玩家，按下按鈕開始序列",
		["zh-cn"] = "1号玩家：按按钮启动序列",
	},
	martyrs_skull_objective_km_enforcer_B = {
		en = "Second player, head through this door",
		["zh-tw"] = "第二位玩家，通過這扇門",
		["zh-cn"] = "2号玩家：穿过此门",
	},
	martyrs_skull_objective_km_enforcer_A1 = {
		en = "Press once to open first door",
		["zh-tw"] = "按一下以打開第一扇門",
		["zh-cn"] = "按一次打开第一道门",
	},
	martyrs_skull_objective_km_enforcer_A2 = {
		en = "Press once to open second door",
		["zh-tw"] = "按一下以打開第二扇門",
		["zh-cn"] = "按一次打开第二道门",
	},
	martyrs_skull_objective_km_enforcer_A3 = {
		en = "Press once to open third door",
		["zh-tw"] = "按一下以打開第三扇門",
		["zh-cn"] = "按一次打开第三道门",
	},
	martyrs_skull_objective_km_enforcer_B1 = {
		en = "Press first button to light up corresponding button in control room for player one for the fourth door",
		["zh-tw"] = "按下第一個按鈕以點亮控制室中對應玩家一的第四扇門按鈕",
		["zh-cn"] = "按第一个按钮，点亮控制室中1号玩家对应的第四道门按钮",
	},
	martyrs_skull_objective_km_enforcer_B2 = {
		en = "Press second button to light up corresponding button in control room for player one for the final door",
		["zh-tw"] = "按下第二個按鈕以點亮控制室中對應玩家一的最後一扇門按鈕",
		["zh-cn"] = "按第二个按钮，点亮控制室中1号玩家对应的最后一道门按钮",
	},
	martyrs_skull_objective_km_enforcer_A4 = {
		en = "Press button that lights up when player two completes B1 or B2",
		["zh-tw"] = "按下當玩家二完成 B1 或 B2 時亮起的按鈕",
		["zh-cn"] = "按下2号玩家完成B1/B2后亮起的按钮",
	},
	martyrs_skull_objective_km_enforcer_B3 = {
		en = "Open door for other players",
		["zh-tw"] = "為其他玩家打開門",
		["zh-cn"] = "为队友开门",
	},
	martyrs_skull_objective_dm_stockpile_A = {
		en = "Climb up",
		["zh-tw"] = "爬上去",
		["zh-cn"] = "向上攀爬",
	},
	martyrs_skull_objective_dm_stockpile_B = {
		en = "Head to the control panel and try move the platform along the rails infront of you. The default pattern in the following order: \nDOWN, RIGHT, RIGHT, DOWN, LEFT",
		["zh-tw"] = "前往控制面板，嘗試沿著你面前的軌道移動平台。默認模式按以下順序：\n下、右、右、下、左",
		["zh-cn"] = "前往控制台，沿轨道移动平台。默认顺序：\n下、右、右、下、左",
	},
	martyrs_skull_objective_fm_cargo_1 = {
		en = "Turn on all showers with the red inquisition symbol quickly.",
		["zh-tw"] = "快速打開所有帶有紅色異端審判符號的淋浴器。",
		["zh-cn"] = "快速打开所有带红色审判庭标识的淋浴喷头",
	},
	martyrs_skull_objective_dm_forge_1 = {
		en = "Follow number sequence",
		["zh-tw"] = "跟隨數字順序",
		["zh-cn"] = "按数字顺序操作",
	},
	martyrs_skull_objective_dm_forge_9 = {
		en = "Destroy all nurgle growths holding the door shut.",
		["zh-tw"] = "摧毀所有阻止門打開的瘟疫生長物。",
		["zh-cn"] = "摧毁所有封堵大门的纳垢增生体",
	},
	martyrs_skull_objective_dm_forge_10 = {
		en = "Open door",
		["zh-tw"] = "打開門",
		["zh-cn"] = "打开大门",
	},
	martyrs_skull_objective_lm_cooling_1 = {
		en = "Climb up boxes to reach the top",
		["zh-tw"] = "爬上箱子到達頂部",
		["zh-cn"] = "爬上箱子抵达顶部",
	},
	martyrs_skull_objective_lm_cooling_2 = {
		en = "Pick up the key in the body's hand",
		["zh-tw"] = "從屍體的手中拿起鑰匙",
		["zh-cn"] = "拾取尸体手中的钥匙",
	},
	martyrs_skull_objective_lm_cooling_3 = {
		en = "Head back over the bridge and use the key on the locked locker.",
		["zh-tw"] = "回到橋頭的房間，使用鑰匙打開鎖住的儲物櫃。",
		["zh-cn"] = "返回桥上，用钥匙打开上锁的储物柜",
	},
	martyrs_skull_objective_lm_scavenge_1 = {
		en = "Head into room across the bridge",
		["zh-tw"] = "前往橋對面的房間",
		["zh-cn"] = "进入桥对面的房间",
	},
	martyrs_skull_objective_lm_scavenge_B1 = {
		en = "Player one, climb into the right elevator",
		["zh-tw"] = "玩家一，爬進右側電梯",
		["zh-cn"] = "1号玩家：进入右侧电梯",
	},
	martyrs_skull_objective_lm_scavenge_A1 = {
		en = "Player two, climb into the left elevator to send player one upwards",
		["zh-tw"] = "玩家二，爬進左側電梯以將玩家一送上去",
		["zh-cn"] = "2号玩家：进入左侧电梯，升起1号玩家",
	},
	martyrs_skull_objective_lm_scavenge_B2 = {
		en = "Player one, grab the battery cell on the crate, and bring it back down in the elevator",
		["zh-tw"] = "玩家一，從箱子上拿起電池，並將其帶回電梯下來",
		["zh-cn"] = "1号玩家：拿取箱子上的电池，乘电梯返回",
	},
	martyrs_skull_objective_lm_scavenge_B3 = {
		en = "Place the battery cell into the socket on the wall",
		["zh-tw"] = "將電池放入牆上的插座中",
		["zh-cn"] = "将电池插入墙上的插槽",
	},
	martyrs_skull_objective_fm_armoury_1 = {
		en = "Enter the building",
		["zh-tw"] = "進入建築物",
		["zh-cn"] = "进入建筑",
	},
	martyrs_skull_objective_fm_armoury_2 = {
		en = "Turn the valve",
		["zh-tw"] = "轉動閥門",
		["zh-cn"] = "转动阀门",
	},
	martyrs_skull_objective_fm_armoury_3 = {
		en = "Climb up to begin parkour, continue up the stairs",
		["zh-tw"] = "爬上去開始跑酷，繼續上樓梯",
		["zh-cn"] = "攀爬开始跑酷，沿楼梯继续向上",
	},
	martyrs_skull_objective_fm_armoury_5 = {
		en = "Grab the power cell",
		["zh-tw"] = "拿起電池",
		["zh-cn"] = "拿取能量电池",
	},
	martyrs_skull_objective_fm_armoury_6 = {
		en = "Place the power cell into the socket, and pull the lever",
		["zh-tw"] = "將電池放入插座中，然後拉動杠杆",
		["zh-cn"] = "将电池插入插槽，拉动杠杆",
	},
	martyrs_skull_objective_fm_armoury_7 = {
		en = "Head back inside and press the button to open the gate to the skull",
		["zh-tw"] = "回到裡面，按下按鈕打開通往顱骨的門",
		["zh-cn"] = "返回室内，按按钮打开颅骨通道门",
	},
	martyrs_skull_objective_cm_raid_1 = {
		en = "Head into alleyway",
		["zh-tw"] = "前往小巷",
		["zh-cn"] = "进入小巷",
	},
	martyrs_skull_objective_cm_raid_2 = {
		en = "Grab the key on the dead body",
		["zh-tw"] = "從屍體身上拿起鑰匙",
		["zh-cn"] = "拾取尸体上的钥匙",
	},
	martyrs_skull_objective_cm_raid_3 = {
		en = "Head into the bar, and use the key to open the locked gate",
		["zh-tw"] = "前往酒吧，使用鑰匙打開鎖住的門",
		["zh-cn"] = "进入酒吧，用钥匙打开上锁的门",
	},
	martyrs_skull_objective_cm_raid_4 = {
		en = "Go up the stairs, climb over the boxes and plant the breaching charge",
		["zh-tw"] = "上樓梯，爬過箱子並安裝爆破裝置",
		["zh-cn"] = "上楼梯，翻越箱子，放置爆破炸药",
	},
	martyrs_skull_objective_cm_raid_5 = {
		en = "Pickup the key, then head back out to the bar",
		["zh-tw"] = "拿起鑰匙，然後回到酒吧",
		["zh-cn"] = "拾取钥匙，返回酒吧",
	},
	martyrs_skull_objective_cm_raid_6 = {
		en = "Use the key to open the gate behind the bar",
		["zh-tw"] = "使用鑰匙打開酒吧後面的門",
		["zh-cn"] = "用钥匙打开酒吧后门",
	},
	martyrs_skull_objective_km_heresy_1 = {
		en = "Follow number sequence",
		["zh-tw"] = "跟隨數字順序",
		["zh-cn"] = "按数字顺序操作",
	},
	martyrs_skull_objective_template_1 = {
		en = "Input code: 213\nPress middle button",
		["zh-tw"] = "輸入代碼：213\n按下中間按鈕",
		["zh-cn"] = "输入密码：213\n按下中间按钮",
	},
	martyrs_skull_objective_dm_propaganda_1 = {
		en = "Interact with the dumpster and pick up the 'skull weight' from the ground",
		["zh-tw"] = "與垃圾桶互動，從地上撿起「顱骨殘骸」",
		["zh-cn"] = "互动垃圾桶，拾取地上的颅骨配重",
	},
	martyrs_skull_objective_dm_propaganda_2 = {
		en = "Head to the Martyr's Skull door and place the skull weight on the chain",
		["zh-tw"] = "前往 Martyr's Skull 門，將顱骨重物放在鏈條上",
		["zh-cn"] = "前往殉道者颅骨大门，将颅骨配重挂在链条上",
	},
	martyrs_skull_objective_fm_resurgence_1 = {
		en = "Head to control panel, you need to line up the pipes on the wall opposite, using the valves infront of you.\nThe default number of times you will need to turn the valves from left to right are as follows:\nx3,x1,x2,x3",
		["zh-tw"] = "前往控制面板，您需要使用面前的閥門對面牆上的管道進行對齊。\n從左到右轉動閥門的次數默認為：\nx3,x1,x2,x3",
		["zh-cn"] = "前往控制台，用阀门对齐对面墙上的管道。\n从左到右阀门转动次数默认：\n3次、1次、2次、3次",
	},
	martyrs_skull_objective_hm_complex_1 = {
		en = "Remember the two symbols in the bottom right corner on the back of the panel",
		["zh-tw"] = "記住面板背面右下角的兩個符號",
		["zh-cn"] = "记住面板背面右下角的两个符号",
	},
	martyrs_skull_objective_hm_complex_2 = {
		en = "Head to the chaos rune circle, and light the candles around the edge that match the two symbols from step 1",
		["zh-tw"] = "前往混沌符文圓圈，點燃與步驟1中的兩個符號相匹配的邊緣蠟燭",
		["zh-cn"] = "前往混沌符文阵，点燃边缘匹配步骤1符号的蜡烛",
	},
	martyrs_skull_objective_cm_archives_1 = {
		en = "This puzzle involves player one pulling the levers on the ground, whilst player two completes a parkour puzzle.",
		["zh-tw"] = "這個苦修需要玩家一拉動地上的杠杆，而玩家二完成跑酷謎題。",
		["zh-cn"] = "解谜：1号玩家拉动地面杠杆，2号玩家完成跑酷",
	},
	martyrs_skull_objective_cm_archives_2 = {
		en = "Player one, begin by pulling this lever to bring the chandelier to the ground, player two jump on, and player one pull the lever again to raise player two back up, then follow the 'B' sequence of markers.",
		["zh-tw"] = "玩家一，首先拉動這個杠杆將吊燈降到地面，玩家二跳上去，然後玩家一再次拉動杠杆將玩家二抬起，然後跟隨 'B' 序列的標記。",
		["zh-cn"] = "1号玩家：拉杠杆降下吊灯→2号玩家跳上→1号玩家再次拉杠杆升起→2号玩家跟随B标记前进",
	},
	martyrs_skull_objective_cm_archives_A1 = {
		en = "Raise",
		["zh-tw"] = "升起",
		["zh-cn"] = "升起",
	},
	martyrs_skull_objective_cm_archives_A2 = {
		en = "Lower then raise",
		["zh-tw"] = "降低然後升起",
		["zh-cn"] = "降下再升起",
	},
	martyrs_skull_objective_cm_archives_A3 = {
		en = "Lower then raise",
		["zh-tw"] = "降低然後升起",
		["zh-cn"] = "降下再升起",
	},
	martyrs_skull_objective_cm_archives_A4 = {
		en = "Climb up boxes and jump over to chandelier to grab martyr's skull, once player two has completed the puzzle",
		["zh-tw"] = "爬上箱子，跳到吊燈上拿到 Martyr's Skull，等玩家二完成謎題後",
		["zh-cn"] = "2号玩家解谜完成后，爬上箱子跳上吊灯拾取殉道者颅骨",
	},
	martyrs_skull_objective_collect_skull = {
		en = "Collect Martyr's Skull!",
		["zh-tw"] = "收集 Martyr's Skull！",
		["zh-cn"] = "拾取殉道者颅骨！",
	},
	martyrs_skull_guide_title = {
		en = "MARTYR'S SKULL GUIDE",
		["zh-tw"] = "MARTYR'S SKULL 指南",
		["zh-cn"] = "殉道者颅骨攻略",
	},
	martyrs_skull_guide_players_required = {
		en = "Player 1 = A, Player 2 = B",
		["zh-tw"] = "玩家 1 = A，玩家 2 = B",
		["zh-cn"] = "1号玩家=A，2号玩家=B",
	},
	martyrs_skull_guide_players_required_solo = {
		en = "Solo",
		["zh-tw"] = "單人",
		["zh-cn"] = "单人可解",
	},
	martyrs_skull_guide_players_required_solo_parkour = {
		en = "Solo (Parkour)",
		["zh-tw"] = "單人（跑酷）",
		["zh-cn"] = "单人（跑酷）",
	},
	martyrs_skull_objective_cm_habs_A1 = {
		en = "Input code: 213\nPress middle button",
		["zh-tw"] = "輸入代碼：213\n按下中間按鈕",
		["zh-cn"] = "输入密码：213\n按下中间按钮",
	},
	martyrs_skull_objective_cm_habs_A2 = {
		en = "Press left button",
		["zh-tw"] = "按下左側按鈕",
		["zh-cn"] = "按下左侧按钮",
	},
	martyrs_skull_objective_cm_habs_A3 = {
		en = "Press right button",
		["zh-tw"] = "按下右側按鈕",
		["zh-cn"] = "按下右侧按钮",
	},
	martyrs_skull_objective_cm_habs_A4 = {
		en = "Hold lever for second player to complete B1",
		["zh-tw"] = "為第二位玩家完成 B1 持續按住杠杆",
		["zh-cn"] = "按住杠杆，等待2号玩家完成B1",
	},
	martyrs_skull_objective_cm_habs_B1 = {
		en = "Second player, press button whilst first player holds A4",
		["zh-tw"] = "第二位玩家，在第一位玩家按住 A4 時按下按鈕",
		["zh-cn"] = "2号玩家：1号玩家按住A4时按下按钮",
	},

	martyrs_skull_objective_km_station_1 = {
		en = "Turn first valve",
		["zh-tw"] = "轉動第一個閥門",
		["zh-cn"] = "转动第一个阀��",
	},
	martyrs_skull_objective_km_station_2 = {
		en = "Turn second valve",
		["zh-tw"] = "轉動第二個閥門",
		["zh-cn"] = "转动第二个阀门",
	},
	martyrs_skull_objective_km_station_3 = {
		en = "Turn third valve",
		["zh-tw"] = "轉動第三個閥門",
		["zh-cn"] = "转动第三个阀门",
	},
	martyrs_skull_objective_km_station_4 = {
		en = "Turn fourth valve",
		["zh-tw"] = "轉動第四個閥門",
		["zh-cn"] = "转动第四个阀门",
	},
	martyrs_skull_objective_km_station_5 = {
		en = "Turn final valve",
		["zh-tw"] = "轉動最後一個閥門",
		["zh-cn"] = "转动最后一个阀门",
	},

	martyrs_skull_objective_lm_rails_1 = {
		en = "Follow number sequence",
		["zh-tw"] = "跟隨數字順序",
		["zh-cn"] = "按������������������序操作",
	},

	martyrs_skull_objective_dm_rise_A1 = {
		en = "Grab the power cell",
		["zh-tw"] = "拿起電池",
		["zh-cn"] = "拿取能量电池",
	},
	martyrs_skull_objective_dm_rise_A2 = {
		en = "Insert the power cell",
		["zh-tw"] = "插入電池",
		["zh-cn"] = "插入能量电池",
	},
	martyrs_skull_objective_dm_rise_B1 = {
		en = "Player two, enter elevator",
		["zh-tw"] = "玩家二，進入電梯",
		["zh-cn"] = "2号玩家：进入电梯",
	},
	martyrs_skull_objective_dm_rise_A3 = {
		en = "Player one, hold the power switch once player 2 is in the elevator",
		["zh-tw"] = "玩家一，當玩家二在電梯裡時，按住電源開關",
		["zh-cn"] = "1号玩家：2号玩家进入电梯后按住电源开关",
	},
	martyrs_skull_objective_dm_rise_B2 = {
		en = "Grab the next power cell",
		["zh-tw"] = "拿起下一個電池",
		["zh-cn"] = "拿取下一个能量电池",
	},
	martyrs_skull_objective_dm_rise_B3 = {
		en = "Throw power cell down to player one",
		["zh-tw"] = "將電池扔給玩家一",
		["zh-cn"] = "将电池扔给1号玩家",
	},
	martyrs_skull_objective_dm_rise_A4 = {
		en = "Player one, insert second power cell",
		["zh-tw"] = "玩家一，插入第二個電池",
		["zh-cn"] = "1号玩家：插入第二个能量电池",
	},
	martyrs_skull_objective_dm_rise_A5 = {
		en = "Hold the next lever for player two",
		["zh-tw"] = "為玩家二按住下一個杠杆",
		["zh-cn"] = "为2号玩家按住下一个杠杆",
	},
	martyrs_skull_objective_dm_rise_B4 = {
		en = "Player two, press the elevator button",
		["zh-tw"] = "玩家二，按下電梯按鈕",
		["zh-cn"] = "2号玩家：按下电梯按钮",
	},
	martyrs_skull_objective_hm_strain_1 = {
		en = "Head to control room, and open the door",
		["zh-tw"] = "前往控制室，打開門",
		["zh-cn"] = "前往控制室，打开大门",
	},
	martyrs_skull_objective_hm_strain_2 = {
		en = "Look above the door for the symbols, remember these",
		["zh-tw"] = "查看門上方的符號，記住這些",
		["zh-cn"] = "查看门上方的符号并记住",
	},
	martyrs_skull_objective_hm_strain_3A = {
		en = "Press the button until you see the right hand symbol from step 2 on the door through the window",
		["zh-tw"] = "按下按鈕，直到你在窗戶上看到步驟2中門上的右手符號",
		["zh-cn"] = "按下按钮，直到你在窗戶上看到步骤2的右侧符号",
	},
	martyrs_skull_objective_hm_strain_3B = {
		en = "Press the button until you see the left hand symbol from step 2 on the door through the window",
		["zh-tw"] = "按下按鈕，直到你在窗戶上看到步驟2中門上的左手符號",
		["zh-cn"] = "按下按钮，直到你在窗戶上看到步骤2的左侧符号",
	},
	martyrs_skull_objective_hm_strain_4 = {
		en = "Once the symbols match, press the final button",
		["zh-tw"] = "當符號匹配時，按下最後一個按鈕",
		["zh-cn"] = "符号匹配后，按下最终按钮",
	},

	-- Event Markers
	event_markers_settings = {
		en = "LIVE EVENT MARKERS",
		["zh-cn"] = "活动物品标记",
	},
	event_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	event_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	event_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	event_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	event_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	event_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	event_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	event_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	event_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	event_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	event_colour = {
		en = "Live Event Markers Colour",
		["zh-cn"] = "活动物品标记颜色",
	},
	event_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	event_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	event_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	event_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},

	-- Expedition Markers
	expedition_markers_settings = {
		en = "EXPEDITION MARKERS",
		["zh-cn"] = "远征物资标记",
	},
	expedition_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	expedition_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	expedition_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	expedition_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	expedition_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	expedition_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	expedition_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	expedition_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	expedition_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	expedition_border_colour = {
		en = "Border Colour (General)",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色（通用）",
	},
	expedition_border_colour_1 = {
		en = "Border Colour (Tier 1 loot)",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色（1级）",
	},
	expedition_border_colour_2 = {
		en = "Border Colour (Tier 2 loot)",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色（2级）",
	},
	expedition_border_colour_3 = {
		en = "Border Colour (Tier 3 loot)",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色（3级）",
	},
	expedition_colour = {
		en = "Expedition Markers Colour (General)",
		["zh-cn"] = "远征标记颜色（通用）",
	},
	expedition_pickups_colour = {
		en = "Expedition Pickup Markers Colour",
		["zh-cn"] = "远征拾取物颜色",
	},
	expedition_currency_colour = {
		en = "Expedition Salvage Markers Colour",
		["zh-cn"] = "远征废料颜色",
	},
	expedition_reliquary_colour = {
		en = "Expedition Reliquary Markers Colour",
		["zh-cn"] = "远征圣骸箱颜色",
	},
	expedition_remnants_colour = {
		en = "Expedition Tech-Remnant Markers Colour",
		["zh-cn"] = "远征科技残片颜色",
	},
	expedition_crate_colour = {
		en = "Expedition Loot Crate Markers Colour",
		["zh-cn"] = "远征战利品箱颜色",
	},
	expedition_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	expedition_reliquary_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	expedition_pickups_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	expedition_currency_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	expedition_remnants_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	expedition_crate_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	expedition_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	expedition_reliquary_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	expedition_pickups_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	expedition_currency_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	expedition_remnants_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	expedition_crate_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	expedition_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	expedition_reliquary_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	expedition_pickups_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	expedition_currency_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	expedition_remnants_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	expedition_crate_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	expedition_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},

	-- Unknown Markers
	unknown_markers_settings = {
		en = "UNKNOWN MARKERS (Those not covered elsewhere!)",
		["zh-cn"] = "未知物品标记（未归类物品）",
	},
	unknown_enable = {
		en = "Enable Markers",
		fr = "Activer les marqueurs",
		ru = "Включить метки",
		["zh-tw"] = "啟用標記",
		["zh-cn"] = "启用标记",
	},
	unknown_general_settings = {
		en = "General Settings",
		fr = "Paramètres généraux",
		ru = "Общие настройки",
		["zh-tw"] = "一般設定",
		["zh-cn"] = "通用设置",
	},
	unknown_keep_on_screen = {
		en = "Keep on screen",
		ru = "Держать на экране",
		fr = "Rester à l'écran",
		["zh-tw"] = "保持顯示於螢幕",
		["zh-cn"] = "在画面中持续显示",
	},
	unknown_require_line_of_sight = {
		en = "Require line of sight",
		fr = "Nécessite une ligne de vue",
		ru = "Должно быть в зоне видимости",
		["zh-tw"] = "需要視線範圍",
		["zh-cn"] = "仅视野内显示",
	},
	unknown_max_distance = {
		en = "Max distance",
		fr = "Distance maximale",
		ru = "Максимальное расстояние",
		["zh-tw"] = "最遠距離",
		["zh-cn"] = "最大显示距离",
	},
	unknown_max_size = {
		en = "Maximum size of marker",
		fr = "Taille maximale du marqueur",
		ru = "Максимальный размер метки",
		["zh-tw"] = "圖標的最大尺寸",
		["zh-cn"] = "标记最大尺寸",
	},
	unknown_min_size = {
		en = "Minimum size of marker",
		fr = "Taille minimale du marqueur",
		ru = "Минимальный размер метки",
		["zh-tw"] = "圖標的最小尺寸",
		["zh-cn"] = "标记最小尺寸",
	},
	unknown_scale = {
		en = "Scale",
		fr = "Scale",
		ru = "Scale",
		["zh-tw"] = "圖標縮放大小",
		["zh-cn"] = "标记缩放比例",
	},
	unknown_alpha = {
		en = "Alpha Multiplier",
		fr = "Multiplicateur d'alpha",
		ru = "Прозрачность",
		["zh-tw"] = "透明度倍增器",
		["zh-cn"] = "透明度系数",
	},
	unknown_border_colour = {
		en = "Border Colour",
		fr = "Couleur de la bordure",
		ru = "Цвет границы",
		["zh-tw"] = "邊框顏色",
		["zh-cn"] = "边框颜色",
	},
	unknown_colour = {
		en = "Unknown Markers Colour",
		["zh-cn"] = "未知物品标记颜色",
	},
	unknown_colour_R = {
		en = "R",
		fr = "R",
		ru = "К",
		["zh-tw"] = "紅",
		["zh-cn"] = "红",
	},
	unknown_colour_G = {
		en = "G",
		fr = "V",
		ru = "З",
		["zh-tw"] = "綠",
		["zh-cn"] = "绿",
	},
	unknown_colour_B = {
		en = "B",
		fr = "B",
		ru = "С",
		["zh-tw"] = "藍",
		["zh-cn"] = "蓝",
	},
	unknown_toggle_los = {
		en = "Toggle 'Require Line of Sight'",
		["zh-tw"] = "切換「需要視線範圍」",
		["zh-cn"] = "切换「仅视野内显示」",
	},
	-- TOOLTIPS
	colour_R_tooltip = {
		en = "Red RGB value.",
		["zh-cn"] = "红色RGB数值。",
	},
	colour_G_tooltip = {
		en = "Green RGB value.",
		["zh-cn"] = "绿色RGB数值。",
	},
	colour_B_tooltip = {
		en = "Blue RGB value.",
		["zh-cn"] = "蓝色RGB数值。",
	},
	max_distance_tooltip = {
		en = "Maximum distance to find, update and draw markers.",
		["zh-cn"] = "搜索、更新与显示标记的最大距离。",
	},
	scale_tooltip = {
		en = "Scale multiplier to apply.\ne.g. 100=1x size, 50=0.5x size, 150=1.5x size.",
		["zh-cn"] = "标记缩放倍数。\n例如：100=1倍大小，50=0.5倍大小，150=1.5倍大小。",
	},
	los_fade_enable_tooltip = {
		en = "Fade out markers that are behind a world object/out of line of sight? Only takes effect if 'Require Line of Sight' is disabled.",
		["zh-cn"] = "是否淡化墙体后方/视线外的标记？仅在关闭「需要视线」时生效。",
	},
	los_opacity_tooltip = {
		en = "Opacity to apply to markers if line of sight fading is enabled.",
		["zh-cn"] = "启用视线淡化后，标记的不透明度。",
	},
	ads_los_opacity_tooltip = {
		en = "Opacity to apply to markers when you aim down sights of your weapon.",
		["zh-cn"] = "开镜瞄准状态下标记的不透明度。",
	},
	alpha_tooltip = {
		en = "General opacity to apply to this marker type.",
		["zh-cn"] = "此类标记的整体不透明度。",
	},
	border_colour_tooltip = {
		en = "Select a colour to apply to the 'border' or outer decorative ring of this marker type.",
		["zh-cn"] = "设置此类标记边框或外侧装饰环的颜色。",
	},
	marker_background_colour_tooltip = {
		en = "Background colour to apply to all markers.",
		["zh-cn"] = "所有标记的背景颜色。",
	},
	font_type_tooltip = {
		en = "Font type to apply to any text elements of markers adjusted by Markers AIO.",
		["zh-cn"] = "标记整合模组调整的所有标记文本字体。",
	},
	enable_tooltip = {
		en = "Enable Markers AIO adjustments to this marker type?",
		["zh-cn"] = "是否对该类标记启用标记整合模组调整？",
	},
	ammo_med_markers_alternate_large_ammo_icon_tooltip = {
		en = "Use a different icon (Which is more fitting imo) for the large ammo pouches?",
		["zh-cn"] = "为大型弹药包使用更贴合的替代图标。",
	},
	keep_on_screen_tooltip = {
		en = "Stick the marker to the edges of the screen if you are not directly looking at it?",
		["zh-cn"] = "未直视目标时，将标记固定在屏幕边缘。",
	},
	require_line_of_sight_tooltip = {
		en = "Require direct line of sight to this marker type?\nIf enabled, markers behind world objects like walls will be hidden. \nIf disabled, you will be able to see markers through world objects.",
		["zh-cn"] = "此类标记是否需要直接视线？\n启用后，墙体等障碍物后的标记会隐藏。\n关闭后可穿墙看到标记。",
	},
	toggle_los_tooltip = {
		en = "Optional: Enter a keybind to toggle the 'Require Line of Sight' functionality for this marker type.",
		["zh-cn"] = "可选：设置快捷键切换此类标记的「需要视线」功能。",
	},
	display_ammo_charges_tooltip = {
		en = "Display a text-based numerical counter indicating how many uses an ammo crate has left before it runs out.",
		["zh-cn"] = "以数字显示弹药箱剩余可使用次数。",
	},
	display_med_charges_tooltip = {
		en = "Display a text-based numerical counter indicating the percentage left on a crate or the charges left on a medical station before it runs out.",
		["zh-cn"] = "以数字显示医疗箱剩余百分比或医疗站剩余使用次数。",
	},
	change_colour_for_ammo_charges_tooltip = {
		en = "Adjust the colour of the background of ammo crate and medical markers to differentiate the amount of uses they have left?",
		["zh-cn"] = "根据剩余使用次数改变弹药箱与医疗标记的背景颜色。",
	},
	display_field_improv_colour_tooltip = {
		en = "Adjust the medical crate radius ring to change colour depending on whether a Veteran with the Field Improvisation talent is present in your party.",
		["zh-cn"] = "根据队伍中是否有携带临场发挥天赋的老兵，改变医疗箱范围环颜色。",
	},
	display_field_improv_icon_tooltip = {
		en = "Add an icon to ammo crates and medical markers depicting whether a Veteran with the Field Improvisation talent is present in your party.",
		["zh-cn"] = "在弹药箱与医疗标记上显示图标，提示队伍中是否有携带临场发挥天赋的老兵。",
	},
	display_med_ring_tooltip = {
		en = "Display a radius circle around deployed medcrates to indicate the range of the buff.",
		["zh-cn"] = "在放置的医疗箱周围显示范围圈，提示增益生效距离。",
	},
	icon_tooltip = {
		en = "Adjust the icon for this marker type.",
		["zh-cn"] = "调整此类标记的图标。",
	},
	stimm_enable_tooltip = {
		en = "Enable colour adjustments for the Hive Scum stimms on the UI elements?",
		["zh-cn"] = "为巢都药剂UI元素启用颜色调整。",
	},
	martyrs_skull_guide_enable_tooltip = {
		en = "Enable an in-mission guide to collecting Martyr's Skulls.\nIncludes written text (Inside the objective window) and in-world markers for positional reference.",
		["zh-cn"] = "启用任务内殉道者颅骨收集指引。\n包含任务窗口文字提示与场景位置标记。",
	},
	martyrs_skull_guide_disable_if_collected_tooltip = {
		en = "Disable the Martyr's Skull guide if you have already collected this skull and have the penance unlocked?",
		["zh-cn"] = "已收集颅骨并解锁苦修后，关闭殉道者颅骨指引。",
	},
}

local apply_color_to_text = function(text, r, g, b)
	return "{#color(" .. r .. "," .. g .. "," .. b .. ")}" .. text .. "{#reset()}"
end

local apply_colours = function()
	for key, values in pairs(loc) do
		-- apply rgb colours
		if
			string.find(key, "colour")
			and not string.find(key, "colour_R")
			and not string.find(key, "colour_G")
			and not string.find(key, "colour_B")
		then
			local r = mod:get(key .. "_R")
			local g = mod:get(key .. "_G")
			local b = mod:get(key .. "_B")

			if r ~= nil and g ~= nil and b ~= nil then
				for language, text in pairs(values) do
					local clean = string.gsub(text, "{#.-}", "")
					clean = string.gsub(clean, "{#reset%(%)%}", "")
					text = apply_color_to_text(clean, r, g, b)

					loc[key][language] = text
				end
			end
		end

		-- apply border colours
		if key == "Gold" or key == "Silver" or key == "Steel" or key == "Tarnished" then
			for language, text in pairs(values) do
				local argb = mod.lookup_border_color(key)

				if argb ~= nil then
					local temp = apply_color_to_text(key, argb[2], argb[3], argb[4])

					if loc[temp] == nil then
						loc[temp] = {}
						loc[temp][language] = temp
					else
						loc[temp][language] = temp
					end
				end
			end
		end

		-- adjust tooltip text opacity
		if string.find(key, "_tooltip") then
			for language, text in pairs(values) do
				local rgb = { 144, 155, 136 }

				if rgb ~= nil then
					local text = apply_color_to_text(text, rgb[1], rgb[2], rgb[3])

					if loc[key] == nil then
						loc[key] = {}
						loc[key][language] = text
					else
						loc[key][language] = text
					end
				end
			end
		end
	end

	return loc
end

-- Insert font localisation
insert_fonts(loc)

apply_colours()

mod.toggle_pizazz = function()
	for key, values in pairs(loc) do
		if key == "mod_name" then
			for language, text in pairs(values) do
				if mod:get("mod_name_pizazz_toggle") then
					loc[key][language] = loc["mod_name_pizazz"][language]
				else
					loc[key][language] = loc["mod_name_boring"][language]
				end
			end
		end
	end
end

mod.toggle_pizazz()

mod.apply_colours = function()
	apply_colours()
	return loc
end

mod.get_loc = function()
	return loc
end

return loc
