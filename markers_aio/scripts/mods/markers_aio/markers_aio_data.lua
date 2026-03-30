local mod = get_mod("markers_aio")

local apply_color_to_text = function(text, r, g, b)
	return "{#color(" .. r .. "," .. g .. "," .. b .. ")}" .. text .. "{#reset()}"
end

local fonts = mod._get_font_options()

local Gold = mod.lookup_border_color("Gold")
local Silver = mod.lookup_border_color("Silver")
local Steel = mod.lookup_border_color("Steel")
local Tarnished = mod.lookup_border_color("Tarnished")

local border_colours = {
	{
		text = apply_color_to_text(mod:localize("Gold"), Gold[2], Gold[3], Gold[4]),
		value = "Gold",
	},
	{
		text = apply_color_to_text(mod:localize("Silver"), Silver[2], Silver[3], Silver[4]),
		value = "Silver",
	},
	{
		text = apply_color_to_text(mod:localize("Steel"), Steel[2], Steel[3], Steel[4]),
		value = "Steel",
	},
	{
		text = apply_color_to_text(mod:localize("Tarnished"), Tarnished[2], Tarnished[3], Tarnished[4]),
		value = "Tarnished",
	},
}

local chest_icons = {
	{
		text = "Default",
		value = "content/ui/materials/hud/interactions/icons/default",
	},
	{
		text = "Video",
		value = "content/ui/materials/icons/system/settings/category_video",
	},
	{
		text = "Loot",
		value = "content/ui/materials/icons/generic/loot",
	},
}

local luggable_icons = {
	{
		text = "Exclamation",
		value = "content/ui/materials/hud/interactions/icons/environment_alert",
	},
	{
		text = "Hands",
		value = "content/ui/materials/hud/communication_wheel/icons/thanks",
	},
	{
		text = "Fist",
		value = "content/ui/materials/icons/presets/preset_18",
	},
}

local background_colours = {
	{
		text = "Black",
		value = "Black",
	},
	{
		text = "Terminal",
		value = "Terminal",
	},
}
local distance_text_positions = {
	{
		text = "Top",
		value = "Top",
	},
	{
		text = "Bottom",
		value = "Bottom",
	},
	{
		text = "Left",
		value = "Left",
	},
	{
		text = "Right",
		value = "Right",
	},
	{
		text = "Center",
		value = "Center",
	},
}

----- NEW HELPERS TO REDUCE REPEATED CODE
local function rgb_group(setting_prefix, defaults)
	return {
		setting_id = setting_prefix,
		type = "group",
		sub_widgets = {
			{
				setting_id = setting_prefix .. "_R",
				type = "numeric",
				default_value = defaults[1],
				range = { 0, 255 },
				step_size = 1,
				tooltip = "colour_R_tooltip",
			},
			{
				setting_id = setting_prefix .. "_G",
				type = "numeric",
				default_value = defaults[2],
				range = { 0, 255 },
				step_size = 1,
				tooltip = "colour_G_tooltip",
			},
			{
				setting_id = setting_prefix .. "_B",
				type = "numeric",
				default_value = defaults[3],
				range = { 0, 255 },
				step_size = 1,
				tooltip = "colour_B_tooltip",
			},
		},
	}
end

local function percent_slider(id, default)
	return {
		setting_id = id,
		type = "numeric",
		default_value = default,
		range = { 0, 100 },
		step_size = 1,
		tooltip = "max_distance_tooltip",
	}
end

local function los_slider(id, default)
	return {
		setting_id = id,
		type = "numeric",
		default_value = default,
		range = { 0, 100 },
		step_size = 1,
		tooltip = id .. "_tooltip",
	}
end

local function scale_slider(id, default)
	return {
		setting_id = id,
		type = "numeric",
		default_value = default,
		range = { 50, 150 },
		step_size = 1,
		tooltip = "scale_tooltip",
	}
end

local function alpha_slider(id, default)
	return {
		setting_id = id,
		type = "numeric",
		default_value = default,
		range = { 0.1, 1 },
		decimals_number = 2,
		step_size = 0.05,
		tooltip = "alpha_tooltip",
	}
end

local function border_dropdown(id, default)
	return {
		setting_id = id,
		type = "dropdown",
		options = border_colours,
		default_value = default,
		tooltip = "border_colour_tooltip",
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {

			-- GLOBAL
			{
				setting_id = "aio_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "los_fade_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "los_fade_enable_tooltip",
					},
					los_slider("los_opacity", 50),
					los_slider("ads_los_opacity", 50),
					{
						setting_id = "marker_background_colour",
						type = "dropdown",
						options = background_colours,
						default_value = "Terminal",
						tooltip = "marker_background_colour_tooltip",
					},
					{
						setting_id = "font_type",
						type = "dropdown",
						options = fonts,
						default_value = "mono_tide_bold",
						tooltip = "font_type_tooltip",
					},
					{
						setting_id = "distance_text_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "distance_text_enable_tooltip",
					},
					{
						setting_id = "distance_text_position",
						type = "dropdown",
						options = distance_text_positions,
						default_value = "Bottom",
						tooltip = "distance_text_position_tooltip",
					},
					scale_slider("distance_text_scale", 100),
				},
			},

			-- AMMO / MED
			{
				setting_id = "ammo_med_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "ammo_med_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_med_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "ammo_med_markers_alternate_large_ammo_icon",
								type = "checkbox",
								default_value = true,
								tooltip = "ammo_med_markers_alternate_large_ammo_icon_tooltip",
							},
							{
								setting_id = "ammo_med_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "ammo_med_require_line_of_sight",
								type = "checkbox",
								default_value = true,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "ammo_med_toggle_los",
								type = "keybind",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								function_name = "ammo_med_toggle_los",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("ammo_med_max_distance", 50),
							percent_slider("med_station_max_distance", 20),
							scale_slider("ammo_med_scale", 100),
							alpha_slider("ammo_med_alpha", 1),
							{
								setting_id = "display_ammo_charges",
								type = "checkbox",
								default_value = true,
								tooltip = "display_ammo_charges_tooltip",
							},
							{
								setting_id = "display_med_charges",
								type = "checkbox",
								default_value = true,
								tooltip = "display_med_charges_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges",
								type = "checkbox",
								default_value = true,
								tooltip = "change_colour_for_ammo_charges_tooltip",
							},
							{
								setting_id = "display_field_improv_icon",
								type = "checkbox",
								default_value = true,
								tooltip = "display_field_improv_icon_tooltip",
							},
							{
								setting_id = "display_med_ring",
								type = "checkbox",
								default_value = true,
								tooltip = "display_med_ring_tooltip",
							},
							{
								setting_id = "display_field_improv_colour",
								type = "checkbox",
								default_value = true,
								tooltip = "display_field_improv_colour_tooltip",
							},
						},
					},

					rgb_group("field_improv_colour", { 50, 0, 255 }),

					rgb_group("ammo_small_colour", { 252, 252, 222 }),

					border_dropdown("ammo_small_border_colour", "Silver"),

					rgb_group("ammo_large_colour", { 252, 252, 222 }),

					border_dropdown("ammo_large_border_colour", "Silver"),

					rgb_group("ammo_crate_colour", { 252, 252, 222 }),

					border_dropdown("ammo_crate_border_colour", "Gold"),

					rgb_group("med_crate_colour", { 252, 252, 222 }),

					border_dropdown("med_crate_border_colour", "Gold"),

					rgb_group("grenade_colour", { 252, 252, 222 }),

					border_dropdown("grenade_border_colour", "Gold"),
				},
			},

			-- CHESTS
			{
				setting_id = "chest_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "chest_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "chest_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "chest_icon",
								type = "dropdown",
								options = chest_icons,
								default_value = "content/ui/materials/icons/system/settings/category_video",
								tooltip = "icon_tooltip",
							},
							{
								setting_id = "chest_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "chest_require_line_of_sight",
								type = "checkbox",
								default_value = true,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "chest_toggle_los",
								type = "keybind",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								function_name = "chest_toggle_los",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("chest_max_distance", 50),
							scale_slider("chest_scale", 100),
							alpha_slider("chest_alpha", 1),
						},
					},
					rgb_group("chest_icon_colour", { 252, 252, 222 }),
					border_dropdown("chest_border_colour", "Gold"),
				},
			},

			-- HERETICAL IDOL
			{
				setting_id = "heretical_idol_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "heretical_idol_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "heretical_idol_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "heretical_idol_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "heretical_idol_require_line_of_sight",
								type = "checkbox",
								default_value = false,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "heretical_idol_toggle_los",
								type = "keybind",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								function_name = "heretical_idol_toggle_los",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("heretical_idol_max_distance", 50),
							scale_slider("heretical_idol_scale", 100),
							alpha_slider("heretical_idol_alpha", 1),
						},
					},
					rgb_group("icon_colour", { 132, 156, 99 }),

					border_dropdown("idol_border_colour", "Tarnished"),
				},
			},

			-- MATERIALS
			{
				setting_id = "material_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "material_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "material_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "material_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "material_require_line_of_sight",
								type = "checkbox",
								default_value = true,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "material_toggle_los",
								type = "keybind",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								function_name = "material_toggle_los",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("material_max_distance", 50),
							scale_slider("material_scale", 100),
							alpha_slider("material_alpha", 1),

							border_dropdown("material_small_border_colour", "Silver"),
							border_dropdown("material_large_border_colour", "Gold"),
						},
					},
					rgb_group("plasteel_icon_colour", { 243, 115, 85 }),
					rgb_group("diamantine_icon_colour", { 95, 158, 160 }),
				},
			},

			-- STIMM
			{
				setting_id = "stimm_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "stimm_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "stimm_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "broker_stimm_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "stimm_enable_tooltip",
							},
							{
								setting_id = "stimm_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "stimm_require_line_of_sight",
								type = "checkbox",
								default_value = true,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "stimm_toggle_los",
								type = "keybind",
								function_name = "stimm_toggle_los",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("stimm_max_distance", 50),
							scale_slider("stimm_scale", 100),
							alpha_slider("stimm_alpha", 1),
						},
					},
					rgb_group("boost_stimm_icon_colour", { 255, 255, 30 }),
					border_dropdown("boost_stimm_border_colour", "Gold"),

					rgb_group("corruption_stimm_icon_colour", { 30, 255, 30 }),
					border_dropdown("corruption_stimm_border_colour", "Gold"),

					rgb_group("power_stimm_icon_colour", { 255, 30, 30 }),
					border_dropdown("power_stimm_border_colour", "Gold"),

					rgb_group("speed_stimm_icon_colour", { 30, 150, 255 }),
					border_dropdown("speed_stimm_border_colour", "Gold"),

					rgb_group("broker_stimm_icon_colour", { 200, 20, 200 }),
					border_dropdown("broker_stimm_border_colour", "Gold"),
				},
			},

			-- TOMES
			{
				setting_id = "tome_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "tome_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "tome_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "tome_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "tome_require_line_of_sight",
								type = "checkbox",
								default_value = true,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "tome_toggle_los",
								type = "keybind",
								function_name = "tome_toggle_los",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("tome_max_distance", 50),
							scale_slider("tome_scale", 100),
							alpha_slider("tome_alpha", 1),
						},
					},
					rgb_group("grim_colour", { 150, 252, 0 }),
					rgb_group("script_colour", { 255, 252, 0 }),
					border_dropdown("tome_border_colour", "Gold"),
				},
			},

			-- LUGGABLE
			{
				setting_id = "luggable_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "luggable_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "luggable_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "luggable_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "luggable_require_line_of_sight",
								type = "checkbox",
								default_value = false,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "luggable_toggle_los",
								type = "keybind",
								function_name = "luggable_toggle_los",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								tooltip = "toggle_los_tooltip",
							},
							{
								setting_id = "luggable_icon",
								type = "dropdown",
								options = luggable_icons,
								default_value = "content/ui/materials/hud/interactions/icons/environment_alert",
								tooltip = "icon_tooltip",
							},
							percent_slider("luggable_max_distance", 50),
							scale_slider("luggable_scale", 100),
							alpha_slider("luggable_alpha", 1),
						},
					},
					rgb_group("luggable_colour", { 0, 240, 255 }),
					border_dropdown("luggable_border_colour", "Gold"),
				},
			},

			-- MARTYR SKULL
			{
				setting_id = "martyrs_skull_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "martyrs_skull_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "martyrs_skull_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "martyrs_skull_guide_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "martyrs_skull_guide_enable_tooltip",
							},
							{
								setting_id = "martyrs_skull_guide_disable_if_collected",
								type = "checkbox",
								default_value = true,
								tooltip = "martyrs_skull_guide_disable_if_collected_tooltip",
							},
							{
								setting_id = "martyrs_skull_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "martyrs_skull_require_line_of_sight",
								type = "checkbox",
								default_value = false,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "martyrs_skull_toggle_los",
								type = "keybind",
								function_name = "martyrs_skull_toggle_los",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("martyrs_skull_max_distance", 50),
							scale_slider("martyrs_skull_scale", 100),
							alpha_slider("martyrs_skull_alpha", 1),
						},
					},
					rgb_group("martyrs_skull_colour", { 255, 200, 0 }),
					border_dropdown("martyrs_skull_border_colour", "Gold"),
				},
			},

			-- EXPEDITION
			{
				setting_id = "expedition_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "expedition_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "expedition_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "expedition_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "expedition_require_line_of_sight",
								type = "checkbox",
								default_value = true,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "expedition_toggle_los",
								type = "keybind",
								function_name = "expedition_toggle_los",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("expedition_max_distance", 50),
							scale_slider("expedition_scale", 100),
							alpha_slider("expedition_alpha", 1),

							border_dropdown("expedition_border_colour", "Silver"),
							border_dropdown("expedition_border_colour_1", "Tarnished"),
							border_dropdown("expedition_border_colour_2", "Steel"),
							border_dropdown("expedition_border_colour_3", "Gold"),
						},
					},
					rgb_group("expedition_colour", { 192, 194, 110 }),
					rgb_group("expedition_pickups_colour", { 223, 108, 110 }),
					rgb_group("expedition_currency_colour", { 233, 185, 110 }),
					rgb_group("expedition_reliquary_colour", { 108, 158, 255 }),
					rgb_group("expedition_remnants_colour", { 137, 206, 125 }),
					rgb_group("expedition_crate_colour", { 198, 110, 0 }),
				},
			},

			-- UNKNOWN
			{
				setting_id = "unknown_markers_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "unknown_general_settings",
						type = "group",
						sub_widgets = {
							{
								setting_id = "unknown_enable",
								type = "checkbox",
								default_value = true,
								tooltip = "enable_tooltip",
							},
							{
								setting_id = "unknown_keep_on_screen",
								type = "checkbox",
								default_value = false,
								tooltip = "keep_on_screen_tooltip",
							},
							{
								setting_id = "unknown_require_line_of_sight",
								type = "checkbox",
								default_value = true,
								tooltip = "require_line_of_sight_tooltip",
							},
							{
								setting_id = "unknown_toggle_los",
								type = "keybind",
								function_name = "unknown_toggle_los",
								default_value = {},
								keybind_global = true,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								tooltip = "toggle_los_tooltip",
							},
							percent_slider("unknown_max_distance", 50),
							scale_slider("unknown_scale", 100),
							alpha_slider("unknown_alpha", 1),
						},
					},
					rgb_group("unknown_colour", { 255, 255, 255 }),
					border_dropdown("unknown_border_colour", "Silver"),
				},
			},
		},
	},
}
