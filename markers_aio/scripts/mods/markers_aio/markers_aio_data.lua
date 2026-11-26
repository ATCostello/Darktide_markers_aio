local mod = get_mod("markers_aio")

local apply_color_to_text = function(text, r, g, b)
	return "{#color(" .. r .. "," .. g .. "," .. b .. ")}" .. text .. "{#reset()}"
end

mod.apply_color_to_text = apply_color_to_text

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
		icon = "content/ui/materials/hud/interactions/icons/default",
	},
	{
		text = "Video",
		value = "content/ui/materials/icons/system/settings/category_video",
		icon = "content/ui/materials/icons/system/settings/category_video",
	},
	{
		text = "Loot",
		value = "content/ui/materials/icons/generic/loot",
		icon = "content/ui/materials/icons/generic/loot",
	},
}

local luggable_icons = {
	{
		text = "Exclamation",
		value = "content/ui/materials/hud/interactions/icons/environment_alert",
		icon = "content/ui/materials/hud/interactions/icons/environment_alert",
	},
	{
		text = "Hands",
		value = "content/ui/materials/hud/communication_wheel/icons/thanks",
		icon = "content/ui/materials/hud/communication_wheel/icons/thanks",
	},
	{
		text = "Fist",
		value = "content/ui/materials/icons/presets/preset_18",
		icon = "content/ui/materials/icons/presets/preset_18",
	},
	{
		text = "Luggable",
		value = "content/ui/materials/icons/player_states/lugged",
		icon = "content/ui/materials/icons/player_states/lugged",
	},
}

local player_assistance_icons = {
	{
		text = "Help",
		value = "content/ui/materials/hud/interactions/icons/help",
		icon = "content/ui/materials/hud/interactions/icons/help",
	},
	{
		text = "Medkit",
		value = "content/ui/materials/hud/interactions/icons/pocketable_medkit",
		icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit",
	},
	{
		text = "Respawn",
		value = "content/ui/materials/hud/interactions/icons/respawn",
		icon = "content/ui/materials/hud/interactions/icons/respawn",
	},
	{
		text = "Stimm",
		value = "content/ui/materials/icons/circumstances/havoc/havoc_mutator_stimmed_minions",
		icon = "content/ui/materials/icons/circumstances/havoc/havoc_mutator_stimmed_minions",
	},
}

local servo_skull_icons = {
	{
		text = "Terminal",
		value = "content/ui/materials/hud/interactions/icons/objective_side",
		icon = "content/ui/materials/hud/interactions/icons/objective_side",
	},
	{
		text = "Skull",
		value = "content/ui/materials/icons/difficulty/flat/difficulty_skull_malice",
		icon = "content/ui/materials/icons/difficulty/flat/difficulty_skull_malice",
	},
	{
		text = "Scanner",
		value = "content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
		icon = "content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
	},
	{
		text = "ScannerSkull",
		value = "content/ui/materials/backgrounds/scanner/scanner_decoration_skull",
		icon = "content/ui/materials/backgrounds/scanner/scanner_decoration_skull",
	},
}

local decoding_icons = {
	{
		text = "Terminal",
		value = "content/ui/materials/hud/interactions/icons/objective_side",
		icon = "content/ui/materials/hud/interactions/icons/objective_side",
	},

	{
		text = "Scanner",
		value = "content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
		icon = "content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
	},

	{
		text = "Investigation",
		value = "content/ui/materials/icons/mission_types/mission_type_03",
		icon = "content/ui/materials/icons/mission_types/mission_type_03",
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
local spillway_route_fx_options = {
	{
		text = "dashed",
		value = "dashed",
	},
	{
		text = "arrows",
		value = "arrows",
	},
	{
		text = "dots",
		value = "dots",
	},
	--[[{
		text = mod:localize("spillway_route_fx_smoke"),
		value = "smoke",
	},
	{
		text = mod:localize("spillway_route_fx_fire"),
		value = "fire",
	},
	{
		text = mod:localize("spillway_route_fx_arc"),
		value = "arc",
	},
	{
		text = mod:localize("spillway_route_fx_warp"),
		value = "warp",
	},
	{
		text = mod:localize("spillway_route_fx_beacon"),
		value = "beacon",
	},]]
	{
		text = "off",
		value = "off",
	},
}

local proximity_message_destinations = {
	{
		text = "chat",
		value = "chat",
	},
	{
		text = "combat_feed",
		value = "combat_feed",
	},
}

local pickup_name_keys = {
	"loc_pickup_consumable_small_clip_01",
	"loc_pickup_consumable_large_clip_01",
	"loc_pickup_consumable_small_grenade_01",
	"loc_pickup_deployable_ammo_crate_01",
	"loc_pickup_deployable_medical_crate_01",
	"loc_pickup_pocketable_ammo_crate_01",
	"loc_pickup_pocketable_medical_crate_01",
	"loc_pickup_pocketable_01",
	"loc_pickup_syringe_pocketable_02",
	"loc_pickup_syringe_pocketable_03",
	"loc_pickup_syringe_pocketable_04",
	"loc_pickup_side_mission_pocketable_01",
	"loc_pickup_side_mission_pocketable_02",
	"loc_pickup_side_mission_consumable_01",
	"loc_pickup_side_mission_communications_hack_device",
	"loc_pickup_breaching_charge",
	"loc_pickup_luggable_battery_01",
	"loc_pickup_luggable_container_01",
	"loc_pickup_luggable_control_rod_01",
	"loc_pickup_luggable_prismata_case_01",
	"loc_pickup_small_metal",
	"loc_pickup_large_metal",
	"loc_pickup_small_platinum",
	"loc_pickup_large_platinum",
	"loc_expeditions_pickup_currency_quality_low",
	"loc_expeditions_pickup_currency_quality_medium",
	"loc_expeditions_pickup_loot_quality_low",
	"loc_expeditions_pickup_loot_quality_medium",
	"loc_expeditions_pickup_loot_quality_high",
	"loc_expeditions_pickup_loot_player_drop",
	"loc_expeditions_pickup_loot_luggable_quality_low",
	"loc_expeditions_pickup_loot_luggable_quality_medium",
	"loc_expeditions_pickup_loot_luggable_quality_high",
	"loc_expeditions_pickup_explosive_luggable_01",
	"loc_expeditions_pickup_airstrike_grenade",
	"loc_expeditions_pickup_description_artillery_strike",
	"loc_expeditions_pickup_description_big_grenade",
	"loc_expeditions_pickup_description_force_field_pocketable",
	"loc_expeditions_pickup_description_motion_detection_mine_explosive",
	"loc_expeditions_pickup_description_motion_detection_mine_fire",
	"loc_expeditions_pickup_description_motion_detection_mine_shock",
	"loc_expeditions_pickup_description_syringe_timed",
	"loc_expeditions_pickup_valkyrie_hover_grenade",
	"loc_interactable_luggable_ammo",
	"loc_luggable_name_contagion_sample_desc",
	"loc_leftover_pickup_small",
	"loc_leftover_pickup_medium",
	"loc_leftover_pickup_large",
	"loc_saints_relic_pickup_small",
	"loc_saints_relic_pickup_medium",
	"loc_saints_relic_pickup_large",
	"loc_stolen_rations_pickup_small",
	"loc_stolen_rations_pickup_medium",
	"loc_tainted_skull_pickup",
	"loc_paper_pickup",
	"loc_mcguffin_pickup",
}

local pickup_name_options = {}
for i = 1, #pickup_name_keys do
	pickup_name_options[i] = {
		text = pickup_name_keys[i],
		value = pickup_name_keys[i],
	}
end
pickup_name_options.localize = false

mod.pickup_name_options = pickup_name_options

local pickup_name_sub_widgets = {
	{
		setting_id = "pickup_name_target",
		type = "dropdown",
		options = pickup_name_options,
		default_value = "loc_pickup_consumable_small_clip_01",
		tooltip = "pickup_name_target_tooltip",
	},
	{
		setting_id = "pickup_name_replacement",
		type = "text",
		default_value = "",
		placeholder_text = "pickup_name_placeholder",
		max_length = 64,
		show_length_limit = true,
		tooltip = "pickup_name_replacement_tooltip",
	},
	{
		setting_id = "pickup_name_reset",
		type = "button",
		localize = false,
		title = "",
		button_text = mod:localize("pickup_name_reset"),
		button_trigger = "pressed",
		function_name = "reset_pickup_name",
		tooltip = mod:localize("pickup_name_reset_tooltip"),
	},
}

local proximity_sub_widgets = {
	{
		setting_id = "proximity_enable",
		type = "checkbox",
		default_value = false,
		tooltip = "proximity_enable_tooltip",
	},
	{
		setting_id = "proximity_range",
		type = "numeric",
		default_value = 15,
		range = { 1, 100 },
		step_size_value = 1,
		tooltip = "proximity_range_tooltip",
	},
	{
		setting_id = "proximity_message_destination",
		type = "dropdown",
		options = proximity_message_destinations,
		default_value = "combat_feed",
		tooltip = "proximity_message_destination_tooltip",
	},
	{
		setting_id = "proximity_message_format",
		type = "text",
		default_value = mod:localize("proximity_message_default"),
		placeholder_text = "proximity_message_format_placeholder",
		max_length = 128,
		show_length_limit = true,
		tooltip = "proximity_message_format_tooltip",
	},
}

local proximity_subtypes = {
	ammo_med = {
		"small_clip",
		"large_clip",
		"small_grenade",
		"ammo_cache_pocketable",
		"ammo_cache_deployable",
		"medical_crate_pocketable",
		"medical_crate_deployable",
		"health_station",
	},
	material = {
		"small_metal",
		"large_metal",
		"small_platinum",
		"large_platinum",
	},
	stimm = {
		"syringe_power_boost_pocketable",
		"syringe_speed_boost_pocketable",
		"syringe_ability_boost_pocketable",
		"syringe_corruption_pocketable",
	},
	expedition = {
		"expedition_grenade_airstrike_pocketable",
		"expedition_grenade_artillery_strike_pocketable",
		"expedition_grenade_big_pocketable",
		"expedition_grenade_valkyrie_hover_pocketable",
		"expedition_deployable_force_field_pocketable",
		"expedition_loot_crate_tier_1",
		"expedition_loot_crate_tier_2",
		"expedition_loot_crate_tier_3",
		"expedition_loot_small_tier_1",
		"expedition_loot_small_tier_2",
		"expedition_loot_small_tier_3",
		"expedition_loot_player_drop",
		"expedition_loot_heavy_tier_1",
		"expedition_loot_heavy_tier_2",
		"expedition_loot_heavy_tier_3",
		"expedition_currency_small_tier_1",
		"expedition_currency_small_tier_2",
		"expedition_effective_sprinting",
		"expedition_max_toughness",
		"expedition_time_syringe_timed",
		"expedition_common_key",
		"expedition_deadsider_key",
		"expedition_dataslate_key",
	},
}

local function proximity_subtype_setting_id(marker_type, subtype)
	if not marker_type or not subtype then
		return nil
	end

	return "proximity_" .. marker_type .. "_" .. subtype
end

mod.proximity_subtypes = proximity_subtypes
mod.proximity_subtype_setting_id = proximity_subtype_setting_id

local proximity_marker_types = {
	"tome",
	"material",
	"ammo_med",
	"stimm",
	"chest",
	"heretical_idol",
	"event",
	"objective",
	"luggable",
	"martyrs_skull",
	"expedition",
}

for i = 1, #proximity_marker_types do
	local marker_type = proximity_marker_types[i]
	local subtypes = proximity_subtypes[marker_type]
	local widget = {
		setting_id = "proximity_" .. marker_type,
		type = "checkbox",
		default_value = false,
		tooltip = subtypes and "proximity_category_tooltip" or "proximity_type_tooltip",
	}

	if subtypes then
		widget.sub_widgets = {}

		for j = 1, #subtypes do
			widget.sub_widgets[j] = {
				setting_id = proximity_subtype_setting_id(marker_type, subtypes[j]),
				type = "checkbox",
				default_value = true,
				tooltip = "proximity_subtype_tooltip",
			}
		end
	end

	proximity_sub_widgets[#proximity_sub_widgets + 1] = widget
end

mod.category_toggles = {
	--[[{ setting_id = "category_toggle_general", group_setting_id = "aio_settings", tab_key = "tab_general" },
	{
		setting_id = "category_toggle_proximity",
		group_setting_id = "proximity_settings",
		tab_key = "tab_proximity",
		frame_keys = { "proximity_enable" },
	},
	{
		setting_id = "category_toggle_pickup_names",
		group_setting_id = "pickup_names_settings",
		tab_key = "tab_pickup_names",
		frame_keys = { "pickup_names_enable" },
	},]]
	{
		setting_id = "category_toggle_ammo_med",
		group_setting_id = "ammo_med_markers_settings",
		tab_key = "tab_ammo_med",
		frame_keys = { "enable.ammo_med" },
	},
	--[[{
		setting_id = "category_toggle_ammo_status",
		group_setting_id = "ammo_status_settings",
		tab_key = "tab_ammo_status",
		frame_keys = { "ammo_status_enable" },
	},]]
	{
		setting_id = "category_toggle_chests",
		group_setting_id = "chest_markers_settings",
		tab_key = "tab_chests",
		frame_keys = { "enable.chest" },
	},
	{
		setting_id = "category_toggle_heretical_idol",
		group_setting_id = "heretical_idol_markers_settings",
		tab_key = "tab_heretical_idol",
		frame_keys = { "enable.heretical_idol" },
	},
	{
		setting_id = "category_toggle_materials",
		group_setting_id = "material_markers_settings",
		tab_key = "tab_materials",
		frame_keys = { "enable.material" },
	},
	{
		setting_id = "category_toggle_stimms",
		group_setting_id = "stimm_markers_settings",
		tab_key = "tab_stimms",
		frame_keys = { "enable.stimm" },
	},
	{
		setting_id = "category_toggle_tomes",
		group_setting_id = "tome_markers_settings",
		tab_key = "tab_tomes",
		frame_keys = { "enable.tome" },
	},
	{
		setting_id = "category_toggle_luggables",
		group_setting_id = "luggable_markers_settings",
		tab_key = "tab_luggables",
		frame_keys = { "enable.luggable" },
	},
	{
		setting_id = "category_toggle_martyrs_skull",
		group_setting_id = "martyrs_skull_markers_settings",
		tab_key = "tab_martyrs_skull",
		frame_keys = { "enable.martyrs_skull" },
	},
	{
		setting_id = "category_toggle_spillway_path",
		group_setting_id = "spillway_path_markers_settings",
		tab_key = "tab_spillway_path",
		frame_keys = { "enable.spillway_path", "enable.spillway_path_route" },
	},
	{
		setting_id = "category_toggle_expedition",
		group_setting_id = "expedition_markers_settings",
		tab_key = "tab_expedition",
		frame_keys = { "enable.expedition" },
	},
	{
		setting_id = "category_toggle_event",
		group_setting_id = "event_markers_settings",
		tab_key = "tab_event",
		frame_keys = { "enable.event", "enable.rations", "enable.atonement" },
	},
	{
		setting_id = "category_toggle_objective",
		group_setting_id = "objective_markers_settings",
		tab_key = "tab_objective",
		frame_keys = { "enable.objective" },
	},
	{
		setting_id = "category_toggle_decoding",
		group_setting_id = "servo_skull_settings",
		tab_key = "tab_decoding",
		frame_keys = { "enable.servo_skull", "enable.servo_skull_enable_assistance_module" },
	},
	{
		setting_id = "category_toggle_player_assistance",
		group_setting_id = "player_assistance_settings",
		tab_key = "tab_player_assistance",
		frame_keys = { "enable.player_assistance" },
	},
	{
		setting_id = "category_toggle_unknown",
		group_setting_id = "unknown_markers_settings",
		tab_key = "tab_unknown",
		frame_keys = { "enable.unknown" },
	},
}

local category_toggle_sub_widgets = {}

for i = 1, #(mod.category_toggles or {}) do
	local entry = mod.category_toggles[i]

	category_toggle_sub_widgets[i] = {
		setting_id = entry.setting_id,
		title = entry.tab_key,
		type = "checkbox",
		default_value = true,
		tooltip = "category_toggle_tooltip",
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {

			-- CATEGORY TOGGLES
			{
				setting_id = "category_toggles_settings",
				title = "tab_category_toggles",
				type = "group",
				tab = mod:localize("tab_category_toggles"),
				sub_widgets = category_toggle_sub_widgets,
			},

			-- GLOBAL
			{
				setting_id = "aio_settings",
				type = "group",
				tab = mod:localize("tab_general"),
				sub_widgets = {
					{
						setting_id = "mod_name_pizazz_toggle",
						type = "checkbox",
						default_value = true,
						tooltip = "mod_name_pizazz_tooltip",
					},
					{
						setting_id = "los_fade_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "los_fade_enable_tooltip",
					},
					{
						setting_id = "los_opacity",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "los_opacity_tooltip",
					},
					{
						setting_id = "ads_los_opacity",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "ads_los_opacity_tooltip",
					},
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
					{
						setting_id = "distance_text_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
				},
			},

			-- PROXIMITY
			{
				setting_id = "proximity_settings",
				type = "group",
				tab = mod:localize("tab_proximity"),
				sub_widgets = proximity_sub_widgets,
			},

			-- PICKUP NAMES
			{
				setting_id = "pickup_names_settings",
				type = "group",
				tab = mod:localize("tab_pickup_names"),
				sub_widgets = pickup_name_sub_widgets,
			},

			-- AMMO / MED
			{

				setting_id = "ammo_med_markers_settings",
				type = "group",
				tab = mod:localize("tab_ammo_med"),
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
						setting_id = "med_station_require_line_of_sight",
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
					{
						setting_id = "ammo_med_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "med_station_max_distance",
						type = "numeric",
						default_value = 20,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "ammo_med_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "ammo_med_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
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
						setting_id = "display_med_crate_estimate",
						type = "checkbox",
						default_value = true,
						tooltip = "display_med_crate_estimate_tooltip",
					},
					{
						setting_id = "change_colour_for_ammo_charges",
						type = "checkbox",
						default_value = true,
						tooltip = "change_colour_for_ammo_charges_tooltip",
					},

					{
						setting_id = "change_colour_for_ammo_charges_4",
						type = "group",
						sub_widgets = {
							{
								setting_id = "change_colour_for_ammo_charges_4_R",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_4_G",
								type = "numeric",
								default_value = 150,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_4_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "change_colour_for_ammo_charges_3",
						type = "group",
						sub_widgets = {
							{
								setting_id = "change_colour_for_ammo_charges_3_R",
								type = "numeric",
								default_value = 150,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_3_G",
								type = "numeric",
								default_value = 150,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_3_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "change_colour_for_ammo_charges_2",
						type = "group",
						sub_widgets = {
							{
								setting_id = "change_colour_for_ammo_charges_2_R",
								type = "numeric",
								default_value = 150,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_2_G",
								type = "numeric",
								default_value = 100,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_2_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "change_colour_for_ammo_charges_1",
						type = "group",
						sub_widgets = {
							{
								setting_id = "change_colour_for_ammo_charges_1_R",
								type = "numeric",
								default_value = 150,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_1_G",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "change_colour_for_ammo_charges_1_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
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

					{
						setting_id = "field_improv_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "field_improv_colour_R",
								type = "numeric",
								default_value = 50,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "field_improv_colour_G",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "field_improv_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "ammo_small_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_small_colour_R",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_small_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_small_colour_B",
								type = "numeric",
								default_value = 222,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "ammo_small_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Silver",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "ammo_large_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_large_colour_R",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_large_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_large_colour_B",
								type = "numeric",
								default_value = 222,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "ammo_large_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Silver",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "ammo_crate_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_crate_colour_R",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_crate_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_crate_colour_B",
								type = "numeric",
								default_value = 222,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "ammo_crate_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "med_crate_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "med_crate_colour_R",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "med_crate_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "med_crate_colour_B",
								type = "numeric",
								default_value = 222,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "med_crate_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "grenade_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "grenade_colour_R",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "grenade_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "grenade_colour_B",
								type = "numeric",
								default_value = 222,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "grenade_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- AMMO STATUS
			{
				setting_id = "ammo_status_settings",
				type = "group",
				tab = mod:localize("tab_ammo_status"),
				sub_widgets = {
					{
						setting_id = "ammo_status_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_enable_tooltip",
					},
					{
						setting_id = "ammo_status_colours_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_colours_enable_tooltip",
					},
					{
						setting_id = "ammo_status_dim_unwanted_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_dim_unwanted_enable_tooltip",
					},
					{
						setting_id = "ammo_status_circle_enable",
						type = "checkbox",
						default_value = false,
						tooltip = "ammo_status_circle_enable_tooltip",
					},

					{
						setting_id = "ammo_status_show_most_needy",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_show_most_needy_tooltip",
					},
					{
						setting_id = "ammo_status_margin",
						type = "numeric",
						default_value = 20,
						range = { 1, 100 },
						step_size_value = 1,
						tooltip = "ammo_status_margin_tooltip",
					},
					{
						setting_id = "ammo_status_numeric_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_numeric_enable_tooltip",
					},
					{
						setting_id = "ammo_status_show_gain",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_show_gain_tooltip",
					},
					{
						setting_id = "ammo_status_show_waste",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_show_waste_tooltip",
					},
					{
						setting_id = "ammo_status_marker_text_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_marker_text_enable_tooltip",
					},
					{
						setting_id = "ammo_status_text_font_size",
						type = "numeric",
						default_value = 18,
						range = { 12, 60 },
						step_size_value = 1,
						tooltip = "ammo_status_text_font_size_tooltip",
					},
					{
						setting_id = "ammo_status_text_position",
						type = "dropdown",
						options = distance_text_positions,
						default_value = "Top",
						tooltip = "ammo_status_text_position_tooltip",
					},
					{
						setting_id = "ammo_status_text_offset",
						type = "numeric",
						default_value = 0,
						range = { -50, 50 },
						step_size_value = 1,
						tooltip = "ammo_status_text_offset_tooltip",
					},
					{
						setting_id = "ammo_status_text_width",
						type = "numeric",
						default_value = 500,
						range = { 100, 1000 },
						step_size_value = 10,
						tooltip = "ammo_status_text_width_tooltip",
					},
					{
						setting_id = "ammo_status_popup_text_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "ammo_status_popup_text_enable_tooltip",
					},
					{
						setting_id = "ammo_status_green_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_status_green_colour_R",
								type = "numeric",
								default_value = 112,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_status_green_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_status_green_colour_B",
								type = "numeric",
								default_value = 112,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "ammo_status_orange_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_status_orange_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_status_orange_colour_G",
								type = "numeric",
								default_value = 191,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_status_orange_colour_B",
								type = "numeric",
								default_value = 44,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "ammo_status_red_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_status_red_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_status_red_colour_G",
								type = "numeric",
								default_value = 112,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_status_red_colour_B",
								type = "numeric",
								default_value = 112,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "ammo_status_gain_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_status_gain_colour_R",
								type = "numeric",
								default_value = 140,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_status_gain_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_status_gain_colour_B",
								type = "numeric",
								default_value = 140,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "ammo_status_waste_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "ammo_status_waste_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "ammo_status_waste_colour_G",
								type = "numeric",
								default_value = 120,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "ammo_status_waste_colour_B",
								type = "numeric",
								default_value = 120,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
				},
			},

			-- CHESTS
			{
				setting_id = "chest_markers_settings",
				type = "group",
				tab = mod:localize("tab_chests"),
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
					{
						setting_id = "chest_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "chest_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "chest_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "chest_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "chest_icon_colour_R",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "chest_icon_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "chest_icon_colour_B",
								type = "numeric",
								default_value = 222,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "chest_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- HERETICAL IDOL
			{

				setting_id = "heretical_idol_markers_settings",
				type = "group",
				tab = mod:localize("tab_heretical_idol"),
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

					{
						setting_id = "heretical_idol_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "heretical_idol_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "heretical_idol_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "icon_colour_R",
								type = "numeric",
								default_value = 132,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "icon_colour_G",
								type = "numeric",
								default_value = 156,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "icon_colour_B",
								type = "numeric",
								default_value = 99,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},

					{
						setting_id = "idol_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Tarnished",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- MATERIALS
			{

				setting_id = "material_markers_settings",
				type = "group",
				tab = mod:localize("tab_materials"),
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
					{
						setting_id = "material_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "material_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "material_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "marker_toggles",
						type = "group",
						sub_widgets = {
							{
								setting_id = "toggle_large_plasteel",
								type = "checkbox",
								default_value = true,
							},
							{
								setting_id = "toggle_small_plasteel",
								type = "checkbox",
								default_value = true,
							},
							{
								setting_id = "toggle_large_diamantine",
								type = "checkbox",
								default_value = true,
							},
							{
								setting_id = "toggle_small_diamantine",
								type = "checkbox",
								default_value = true,
							},
						},
					},
					{
						setting_id = "material_small_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Silver",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "material_large_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "plasteel_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "plasteel_icon_colour_R",
								type = "numeric",
								default_value = 243,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "plasteel_icon_colour_G",
								type = "numeric",
								default_value = 115,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "plasteel_icon_colour_B",
								type = "numeric",
								default_value = 85,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "diamantine_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "diamantine_icon_colour_R",
								type = "numeric",
								default_value = 95,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "diamantine_icon_colour_G",
								type = "numeric",
								default_value = 158,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "diamantine_icon_colour_B",
								type = "numeric",
								default_value = 160,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
				},
			},

			-- STIMM
			{

				setting_id = "stimm_markers_settings",
				type = "group",
				tab = mod:localize("tab_stimms"),
				sub_widgets = {
					{
						setting_id = "stimm_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "enable_tooltip",
					},
					{
						setting_id = "recolor_stimm_compat_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "recolor_stimm_compat_enable_tooltip",
					},
					{
						setting_id = "toggle_background_colour",
						type = "checkbox",
						default_value = false,
						tooltip = "toggle_background_colour_tooltip",
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
						setting_id = "boost_stimm_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "boost_stimm_require_line_of_sight_tooltip",
					},
					{
						setting_id = "corruption_stimm_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "corruption_stimm_require_line_of_sight_tooltip",
					},
					{
						setting_id = "power_stimm_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "power_stimm_require_line_of_sight_tooltip",
					},
					{
						setting_id = "speed_stimm_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "speed_stimm_require_line_of_sight_tooltip",
					},
					{
						setting_id = "broker_stimm_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "broker_stimm_require_line_of_sight_tooltip",
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
					{
						setting_id = "stimm_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "stimm_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "stimm_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "boost_stimm_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "boost_stimm_icon_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "boost_stimm_icon_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "boost_stimm_icon_colour_B",
								type = "numeric",
								default_value = 30,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "boost_stimm_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "corruption_stimm_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "corruption_stimm_icon_colour_R",
								type = "numeric",
								default_value = 30,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "corruption_stimm_icon_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "corruption_stimm_icon_colour_B",
								type = "numeric",
								default_value = 30,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "corruption_stimm_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "power_stimm_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "power_stimm_icon_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "power_stimm_icon_colour_G",
								type = "numeric",
								default_value = 30,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "power_stimm_icon_colour_B",
								type = "numeric",
								default_value = 30,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "power_stimm_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "speed_stimm_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "speed_stimm_icon_colour_R",
								type = "numeric",
								default_value = 30,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "speed_stimm_icon_colour_G",
								type = "numeric",
								default_value = 150,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "speed_stimm_icon_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "speed_stimm_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},

					{
						setting_id = "broker_stimm_icon_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "broker_stimm_icon_colour_R",
								type = "numeric",
								default_value = 200,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "broker_stimm_icon_colour_G",
								type = "numeric",
								default_value = 20,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "broker_stimm_icon_colour_B",
								type = "numeric",
								default_value = 200,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "broker_stimm_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- TOMES
			{

				setting_id = "tome_markers_settings",
				type = "group",
				tab = mod:localize("tab_tomes"),
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
					{
						setting_id = "tome_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "tome_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "tome_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "grim_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "grim_colour_R",
								type = "numeric",
								default_value = 150,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "grim_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "grim_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "script_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "script_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "script_colour_G",
								type = "numeric",
								default_value = 252,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "script_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "tome_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- LUGGABLE
			{

				setting_id = "luggable_markers_settings",
				type = "group",
				tab = mod:localize("tab_luggables"),
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
						default_value = "content/ui/materials/icons/player_states/lugged",
						tooltip = "icon_tooltip",
					},
					{
						setting_id = "luggable_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "luggable_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "luggable_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "luggable_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "luggable_colour_R",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "luggable_colour_G",
								type = "numeric",
								default_value = 240,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "luggable_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "luggable_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- MARTYR SKULL
			{

				setting_id = "martyrs_skull_markers_settings",
				type = "group",
				tab = mod:localize("tab_martyrs_skull"),
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
						setting_id = "martyrs_skull_guide_markers_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "martyrs_skull_guide_markers_enable_tooltip",
					},
					{
						setting_id = "martyrs_skull_guide_disable_if_collected",
						type = "checkbox",
						default_value = true,
						tooltip = "martyrs_skull_guide_disable_if_collected_tooltip",
					},
					{
						setting_id = "martyrs_skull_guide_x_offset",
						type = "numeric",
						default_value = 0,
						step_size_value = 5,
						tooltip = "martyrs_skull_guide_x_offset_tooltip",
						range = { -2000, 2000 },
						decimals_number = 0,
					},
					{
						setting_id = "martyrs_skull_guide_y_offset",
						type = "numeric",
						default_value = 10,
						step_size_value = 5,
						tooltip = "martyrs_skull_guide_y_offset_tooltip",
						range = { -1200, 1200 },
						decimals_number = 0,
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
					{
						setting_id = "martyrs_skull_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "martyrs_skull_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "martyrs_skull_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "martyrs_skull_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "martyrs_skull_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "martyrs_skull_colour_G",
								type = "numeric",
								default_value = 200,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "martyrs_skull_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "martyrs_skull_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- SPILLWAY PATH
			{

				setting_id = "spillway_path_markers_settings",
				type = "group",
				tab = mod:localize("tab_spillway_path"),
				sub_widgets = {
					{
						setting_id = "spillway_path_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "enable_tooltip",
					},
					{
						setting_id = "spillway_path_route_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "route_enable_tooltip",
					},
					{
						setting_id = "spillway_path_route_fx",
						type = "dropdown",
						options = spillway_route_fx_options,
						default_value = "dashed",
						tooltip = "spillway_path_route_fx_tooltip",
					},
					--[[{
						setting_id = "spillway_path_route_thickness",
						type = "numeric",
						default_value = 1,
						range = { 1, 4 },
						decimals_number = 1,
						step_size_value = 0.5,
						tooltip = "spillway_path_route_thickness_tooltip",
					},]]
					{
						setting_id = "spillway_path_keep_on_screen",
						type = "checkbox",
						default_value = false,
						tooltip = "keep_on_screen_tooltip",
					},
					{
						setting_id = "spillway_path_require_line_of_sight",
						type = "checkbox",
						default_value = false,
						tooltip = "require_line_of_sight_tooltip",
					},
					{
						setting_id = "spillway_path_max_distance",
						type = "numeric",
						default_value = 100,
						range = { 0, 500 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "spillway_path_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "spillway_path_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "spillway_path_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "spillway_path_colour_R",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "spillway_path_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "spillway_path_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "spillway_path_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Steel",
						tooltip = "border_colour_tooltip",
					},
				},
			},

			-- EXPEDITION
			{

				setting_id = "expedition_markers_settings",
				type = "group",
				tab = mod:localize("tab_expedition"),
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
					{
						setting_id = "expedition_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "expedition_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "expedition_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},

					{
						setting_id = "expedition_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Silver",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "expedition_border_colour_1",
						type = "dropdown",
						options = border_colours,
						default_value = "Tarnished",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "expedition_border_colour_2",
						type = "dropdown",
						options = border_colours,
						default_value = "Steel",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "expedition_border_colour_3",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "expedition_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "expedition_colour_R",
								type = "numeric",
								default_value = 192,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "expedition_colour_G",
								type = "numeric",
								default_value = 194,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "expedition_colour_B",
								type = "numeric",
								default_value = 110,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "expedition_pickups_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "expedition_pickups_colour_R",
								type = "numeric",
								default_value = 223,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "expedition_pickups_colour_G",
								type = "numeric",
								default_value = 108,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "expedition_pickups_colour_B",
								type = "numeric",
								default_value = 110,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "expedition_currency_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "expedition_currency_colour_R",
								type = "numeric",
								default_value = 233,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "expedition_currency_colour_G",
								type = "numeric",
								default_value = 185,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "expedition_currency_colour_B",
								type = "numeric",
								default_value = 110,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "expedition_reliquary_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "expedition_reliquary_colour_R",
								type = "numeric",
								default_value = 108,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "expedition_reliquary_colour_G",
								type = "numeric",
								default_value = 158,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "expedition_reliquary_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "expedition_remnants_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "expedition_remnants_colour_R",
								type = "numeric",
								default_value = 137,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "expedition_remnants_colour_G",
								type = "numeric",
								default_value = 206,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "expedition_remnants_colour_B",
								type = "numeric",
								default_value = 125,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "expedition_crate_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "expedition_crate_colour_R",
								type = "numeric",
								default_value = 198,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "expedition_crate_colour_G",
								type = "numeric",
								default_value = 110,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "expedition_crate_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
				},
			},
			-- EVENT MARKERS
			{

				setting_id = "event_markers_settings",
				type = "group",
				tab = mod:localize("tab_event"),
				sub_widgets = {
					{
						setting_id = "event_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "enable_tooltip",
					},
					{
						setting_id = "event_keep_on_screen",
						type = "checkbox",
						default_value = false,
						tooltip = "keep_on_screen_tooltip",
					},
					{
						setting_id = "event_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "require_line_of_sight_tooltip",
					},
					{
						setting_id = "event_toggle_los",
						type = "keybind",
						function_name = "event_toggle_los",
						default_value = {},
						keybind_global = true,
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						tooltip = "toggle_los_tooltip",
					},
					{
						setting_id = "event_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "event_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "event_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "event_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "event_colour_R",
								type = "numeric",
								default_value = 200,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "event_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "event_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "event_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},
			-- OBJECTIVE MARKERS
			{
				setting_id = "objective_markers_settings",
				type = "group",
				tab = mod:localize("tab_objective"),
				sub_widgets = {
					{
						setting_id = "objective_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "enable_tooltip",
					},
					{
						setting_id = "objective_keep_on_screen",
						type = "checkbox",
						default_value = true,
						tooltip = "keep_on_screen_tooltip",
					},
					{
						setting_id = "objective_require_line_of_sight",
						type = "checkbox",
						default_value = false,
						tooltip = "objective_require_line_of_sight_tooltip",
					},
					{
						setting_id = "objective_toggle_los",
						type = "keybind",
						function_name = "objective_toggle_los",
						default_value = {},
						keybind_global = true,
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						tooltip = "toggle_los_tooltip",
					},
					{
						setting_id = "objective_max_distance",
						type = "numeric",
						default_value = 500,
						range = { 0, 500 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "objective_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "objective_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "objective_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "objective_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "objective_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "objective_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "objective_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},
			-- SERVO SKULL MARKERS
			{
				setting_id = "servo_skull_settings",
				type = "group",
				tab = mod:localize("tab_decoding"),
				sub_widgets = {
					{
						setting_id = "servo_skull_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "enable_tooltip",
					},
					{
						setting_id = "servo_skull_icon",
						type = "dropdown",
						options = servo_skull_icons,
						default_value = "content/ui/materials/backgrounds/scanner/scanner_decoration_skull",
						tooltip = "icon_tooltip",
					},
					{
						setting_id = "decoding_icon",
						type = "dropdown",
						options = decoding_icons,
						default_value = "content/ui/materials/icons/mission_types/mission_type_03",
						tooltip = "icon_tooltip",
					},
					{
						setting_id = "servo_skull_keep_on_screen",
						type = "checkbox",
						default_value = false,
						tooltip = "keep_on_screen_tooltip",
					},
					{
						setting_id = "servo_skull_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "require_line_of_sight_tooltip",
					},
					{
						setting_id = "servo_skull_toggle_los",
						type = "keybind",
						function_name = "servo_skull_toggle_los",
						default_value = {},
						keybind_global = true,
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						tooltip = "toggle_los_tooltip",
					},
					{
						setting_id = "servo_skull_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "servo_skull_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "servo_skull_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "servo_skull_pulse_when_stalled",
						type = "checkbox",
						default_value = true,
						tooltip = "pulse_when_stalled_tooltip",
					},

					{
						setting_id = "servo_skull_default_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "servo_skull_default_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "servo_skull_default_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "servo_skull_default_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "servo_skull_stalled_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "servo_skull_stalled_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "servo_skull_stalled_colour_G",
								type = "numeric",
								default_value = 200,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "servo_skull_stalled_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "servo_skull_active_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "servo_skull_active_colour_R",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "servo_skull_active_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "servo_skull_active_colour_B",
								type = "numeric",
								default_value = 50,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "servo_skull_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Steel",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "servo_skull_stalled_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Tarnished",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "servo_skull_active_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},
			-- PLAYER ASSISTANCE MARKERS
			{
				setting_id = "player_assistance_settings",
				type = "group",
				tab = mod:localize("tab_player_assistance"),
				sub_widgets = {
					{
						setting_id = "player_assistance_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "enable_tooltip",
					},
					{
						setting_id = "player_assistance_servo_skull_icon",
						type = "dropdown",
						options = servo_skull_icons,
						default_value = "content/ui/materials/backgrounds/scanner/scanner_decoration_skull",
						tooltip = "icon_tooltip",
					},
					{
						setting_id = "player_assistance_icon",
						type = "dropdown",
						options = player_assistance_icons,
						default_value = "content/ui/materials/hud/interactions/icons/help",
						tooltip = "icon_tooltip",
					},
					{
						setting_id = "player_assistance_keep_on_screen",
						type = "checkbox",
						default_value = false,
						tooltip = "keep_on_screen_tooltip",
					},
					{
						setting_id = "player_assistance_require_line_of_sight",
						type = "checkbox",
						default_value = true,
						tooltip = "require_line_of_sight_tooltip",
					},
					{
						setting_id = "player_assistance_toggle_los",
						type = "keybind",
						function_name = "player_assistance_toggle_los",
						default_value = {},
						keybind_global = true,
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						tooltip = "toggle_los_tooltip",
					},
					{
						setting_id = "player_assistance_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "player_assistance_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "player_assistance_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "player_assistance_pulse_when_stalled",
						type = "checkbox",
						default_value = true,
						tooltip = "pulse_when_stalled_tooltip",
					},

					{
						setting_id = "player_assistance_default_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "player_assistance_default_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "player_assistance_default_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "player_assistance_default_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "player_assistance_stalled_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "player_assistance_stalled_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "player_assistance_stalled_colour_G",
								type = "numeric",
								default_value = 200,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "player_assistance_stalled_colour_B",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "player_assistance_active_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "player_assistance_active_colour_R",
								type = "numeric",
								default_value = 0,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "player_assistance_active_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "player_assistance_active_colour_B",
								type = "numeric",
								default_value = 50,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "player_assistance_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Steel",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "player_assistance_stalled_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Tarnished",
						tooltip = "border_colour_tooltip",
					},
					{
						setting_id = "player_assistance_active_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Gold",
						tooltip = "border_colour_tooltip",
					},
				},
			},
			-- UNKNOWN
			{

				setting_id = "unknown_markers_settings",
				type = "group",
				tab = mod:localize("tab_unknown"),
				sub_widgets = {
					{
						setting_id = "unknown_enable",
						type = "checkbox",
						default_value = true,
						tooltip = "enable_tooltip",
					},
					{
						setting_id = "unknown_markers_extra_allowed",
						type = "checkbox",
						default_value = false,
						tooltip = "unknown_markers_extra_allowed_tooltip",
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
					{
						setting_id = "unknown_max_distance",
						type = "numeric",
						default_value = 50,
						range = { 0, 100 },
						step_size_value = 1,
						tooltip = "max_distance_tooltip",
					},
					{
						setting_id = "unknown_scale",
						type = "numeric",
						default_value = 100,
						range = { 50, 150 },
						step_size_value = 1,
						tooltip = "scale_tooltip",
					},
					{
						setting_id = "unknown_alpha",
						type = "numeric",
						default_value = 1,
						range = { 0.1, 1 },
						decimals_number = 2,
						step_size_value = 0.05,
						tooltip = "alpha_tooltip",
					},
					{
						setting_id = "unknown_colour",
						type = "group",
						sub_widgets = {
							{
								setting_id = "unknown_colour_R",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_R_tooltip",
							},
							{
								setting_id = "unknown_colour_G",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_G_tooltip",
							},
							{
								setting_id = "unknown_colour_B",
								type = "numeric",
								default_value = 255,
								range = { 0, 255 },
								step_size_value = 1,
								tooltip = "colour_B_tooltip",
							},
						},
					},
					{
						setting_id = "unknown_border_colour",
						type = "dropdown",
						options = border_colours,
						default_value = "Silver",
						tooltip = "border_colour_tooltip",
					},
				},
			},
		},
	},
}
