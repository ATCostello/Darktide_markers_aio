local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIScenegraph = require("scripts/managers/ui/ui_scenegraph")
local UISettings = require("scripts/settings/ui/ui_settings")
local SpecialRulesSettings = require("scripts/settings/ability/special_rules_settings")
local CompanionServoSkullSettings = require("scripts/settings/companion/companion_servo_skull_settings")

mod.frame_settings = {}
mod._aio_frame = 0
mod._settings_version = 0
mod.frame_settings.mod_enabled = mod:is_enabled() or false

mod:io_dofile("markers_aio/scripts/mods/markers_aio/utils/category_toggles")

-- cached functions
local has_extension = ScriptUnit.has_extension
local vector_distance = Vector3.distance
local vector_distance_squared = Vector3.distance_squared
local vector_dot = Vector3.dot

local function player_is_usable(player)
	return type(player) == "table" and rawget(player, "__deleted") ~= true
end

local function get_player_unit(player)
	if not player_is_usable(player) then
		return nil
	end

	return rawget(player, "player_unit")
end

mod.player_is_usable = player_is_usable
mod.get_player_unit = get_player_unit

local function get_valid_hud_camera(hud)
	if type(hud) ~= "table" then
		return nil
	end

	local state = Managers.state
	local camera_manager = state and state.camera
	local viewport_name = rawget(hud, "_world_viewport_name")

	if not camera_manager or not camera_manager.has_camera or not viewport_name then
		return nil
	end

	local camera = camera_manager:has_camera(viewport_name)

	if camera and rawget(hud, "_camera") ~= camera then
		hud._camera = camera
	end

	return camera
end

local function get_valid_world_marker_camera(hud_element)
	if type(hud_element) ~= "table" then
		return nil
	end

	local camera = get_valid_hud_camera(rawget(hud_element, "_parent"))

	hud_element._player_camera = camera

	return camera
end

mod.get_valid_hud_camera = get_valid_hud_camera
mod.get_valid_world_marker_camera = get_valid_world_marker_camera

mod.get_local_player = function()
	local frame = mod._aio_frame

	if mod._local_player_frame ~= frame then
		mod._local_player_frame = frame
		local player = Managers.player:local_player_safe(1)
		mod._local_player_cached = player_is_usable(player) and player or nil
	end

	return mod._local_player_cached
end

mod.get_player_units = function()
	local frame = mod._aio_frame

	if mod._player_units_frame ~= frame then
		mod._player_units_frame = frame

		local units = mod._player_units

		if units then
			table.clear(units)
		else
			units = {}
			mod._player_units = units
		end

		local players = Managers.player:players()

		for _, player in pairs(players) do
			local unit = get_player_unit(player)

			if unit then
				units[unit] = true
			end
		end
	end

	return mod._player_units
end

mod.update_ads_state = function()
	local fs = mod.frame_settings
	local player = mod.get_local_player()

	local unit = get_player_unit(player)

	if not unit or not Unit.alive(unit) then
		fs.is_ads = false
		return
	end

	local ude = mod._ads_ude

	if mod._ads_unit ~= unit then
		mod._ads_unit = unit
		ude = ScriptUnit.has_extension(unit, "unit_data_system")
		mod._ads_ude = ude
	end

	if not ude then
		fs.is_ads = false
		return
	end

	local alternate_fire = ude:read_component("alternate_fire")

	fs.is_ads = alternate_fire ~= nil and alternate_fire.is_active == true
end

local marker_types = {
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
	"servo_skull",
	"unknown",
	"player_assistance",
	"spillway_path",
}

mod.build_settings = function()
	local fs = mod.frame_settings

	fs.mod_enabled = mod:is_enabled() or false

	mod._settings_version = mod._settings_version + 1

	fs.los_enabled = mod:get("los_fade_enable") == true
	fs.los_opacity = (mod:get("los_opacity")) / 100
	fs.ads_los_opacity = (mod:get("ads_los_opacity")) / 100

	fs.distance_text_enable = mod:get("distance_text_enable")
	fs.distance_text_position = mod:get("distance_text_position")
	fs.distance_text_scale = mod:get("distance_text_scale")

	fs.med_station_max_distance = mod:get("med_station_max_distance")

	fs.enable = fs.enable or {}
	fs.enable.tome = mod:get("tome_enable")
	fs.enable.material = mod:get("material_enable")
	fs.enable.ammo_med = mod:get("ammo_med_enable")
	fs.enable.stimm = mod:get("stimm_enable")
	fs.enable.chest = mod:get("chest_enable")
	fs.enable.heretical_idol = mod:get("heretical_idol_enable")
	fs.enable.event = mod:get("event_enable")
	fs.enable.objective = mod:get("objective_enable")
	fs.enable.luggable = mod:get("luggable_enable")
	fs.enable.martyrs_skull = mod:get("martyrs_skull_enable")
	fs.enable.rations = mod:get("event_enable")
	fs.enable.atonement = mod:get("event_enable")
	fs.enable.expedition = mod:get("expedition_enable")
	fs.enable.servo_skull = mod:get("servo_skull_enable")
	fs.enable.unknown = mod:get("unknown_enable")
	fs.enable.servo_skull_enable_assistance_module = mod:get("servo_skull_enable_assistance_module")
	fs.enable.player_assistance = mod:get("player_assistance_enable")
	fs.enable.spillway_path = mod:get("spillway_path_enable")
	fs.enable.spillway_path_route = mod:get("spillway_path_route_enable")
	fs.spillway_route_fx = mod:get("spillway_path_route_fx")
	fs.spillway_path_route_thickness = mod:get("spillway_path_route_thickness")

	fs.proximity_enable = mod:get("proximity_enable") == true
	fs.proximity_range = mod:get("proximity_range") or 15
	fs.proximity_message_destination = mod:get("proximity_message_destination") or "chat"
	fs.proximity_message_format = mod:get("proximity_message_format")

	fs.proximity_types = fs.proximity_types or {}

	for _, marker_type in ipairs(marker_types) do
		fs.proximity_types[marker_type] = mod:get("proximity_" .. marker_type) == true
	end

	fs.proximity_subtypes = fs.proximity_subtypes or {}

	for marker_type, subtypes in pairs(mod.proximity_subtypes or {}) do
		local enabled_subtypes = fs.proximity_subtypes[marker_type]

		if not enabled_subtypes then
			enabled_subtypes = {}
			fs.proximity_subtypes[marker_type] = enabled_subtypes
		end

		table.clear(enabled_subtypes)

		for i = 1, #subtypes do
			local subtype = subtypes[i]
			local setting_id = mod.proximity_subtype_setting_id
					and mod.proximity_subtype_setting_id(marker_type, subtype)
				or ("proximity_" .. marker_type .. "_" .. subtype)

			enabled_subtypes[subtype] = mod:get(setting_id) ~= false
		end
	end

	fs.category_enabled = fs.category_enabled or {}

	for _, entry in ipairs(mod.category_toggles or {}) do
		local enabled = mod:get(entry.setting_id) ~= false
		fs.category_enabled[entry.group_setting_id] = enabled

		if not enabled then
			local frame_keys = entry.frame_keys

			for i = 1, #(frame_keys or {}) do
				mod.set_frame_value(fs, frame_keys[i], false)
			end
		end
	end

	if mod.clear_proximity_name_cache then
		mod.clear_proximity_name_cache()
	end

	fs.marker_background_colour = mod:get("marker_background_colour")
	fs.font_type = mod:get("font_type")
	fs.recolor_stimm_compat_enable = mod:get("recolor_stimm_compat_enable")
	fs.mod_name_pizazz_toggle = mod:get("mod_name_pizazz_toggle")

	fs.martyrs_skull_guide_enable = mod:get("martyrs_skull_guide_enable")
	fs.martyrs_skull_guide_markers_enable = mod:get("martyrs_skull_guide_markers_enable")
	fs.martyrs_skull_guide_disable_if_collected = mod:get("martyrs_skull_guide_disable_if_collected")
	fs.martyrs_skull_border_colour = mod:get("martyrs_skull_border_colour")
	fs.servo_skull_icon = mod:get("servo_skull_icon")
	fs.decoding_icon = mod:get("decoding_icon")
	fs.servo_skull_pulse_when_stalled = mod:get("servo_skull_pulse_when_stalled")
	fs.servo_skull_border_colour = mod:get("servo_skull_border_colour")
	fs.servo_skull_stalled_border_colour = mod:get("servo_skull_stalled_border_colour")
	fs.servo_skull_active_border_colour = mod:get("servo_skull_active_border_colour")
	fs.servo_skull_default_colour_R = mod:get("servo_skull_default_colour_R")
	fs.servo_skull_default_colour_G = mod:get("servo_skull_default_colour_G")
	fs.servo_skull_default_colour_B = mod:get("servo_skull_default_colour_B")
	fs.servo_skull_stalled_colour_R = mod:get("servo_skull_stalled_colour_R")
	fs.servo_skull_stalled_colour_G = mod:get("servo_skull_stalled_colour_G")
	fs.servo_skull_stalled_colour_B = mod:get("servo_skull_stalled_colour_B")
	fs.servo_skull_active_colour_R = mod:get("servo_skull_active_colour_R")
	fs.servo_skull_active_colour_G = mod:get("servo_skull_active_colour_G")
	fs.servo_skull_active_colour_B = mod:get("servo_skull_active_colour_B")
	fs.player_assistance_icon = mod:get("player_assistance_icon")
	fs.player_assistance_servo_skull_icon = mod:get("player_assistance_servo_skull_icon")
	fs.player_assistance_pulse_when_stalled = mod:get("player_assistance_pulse_when_stalled")
	fs.player_assistance_border_colour = mod:get("player_assistance_border_colour")
	fs.player_assistance_stalled_border_colour = mod:get("player_assistance_stalled_border_colour")
	fs.player_assistance_active_border_colour = mod:get("player_assistance_active_border_colour")
	fs.player_assistance_default_colour_R = mod:get("player_assistance_default_colour_R")
	fs.player_assistance_default_colour_G = mod:get("player_assistance_default_colour_G")
	fs.player_assistance_default_colour_B = mod:get("player_assistance_default_colour_B")
	fs.player_assistance_stalled_colour_R = mod:get("player_assistance_stalled_colour_R")
	fs.player_assistance_stalled_colour_G = mod:get("player_assistance_stalled_colour_G")
	fs.player_assistance_stalled_colour_B = mod:get("player_assistance_stalled_colour_B")
	fs.player_assistance_active_colour_R = mod:get("player_assistance_active_colour_R")
	fs.player_assistance_active_colour_G = mod:get("player_assistance_active_colour_G")
	fs.player_assistance_active_colour_B = mod:get("player_assistance_active_colour_B")
	fs.event_require_line_of_sight = mod:get("event_require_line_of_sight")
	fs.event_keep_on_screen = mod:get("event_keep_on_screen")
	fs.event_border_colour = mod:get("event_border_colour")
	fs.event_colour_R = mod:get("event_colour_R")
	fs.event_colour_G = mod:get("event_colour_G")
	fs.event_colour_B = mod:get("event_colour_B")
	fs.event_max_distance = mod:get("event_max_distance")
	fs.rations_keep_on_screen = mod:get("rations_keep_on_screen")
	fs.unknown_border_colour = mod:get("unknown_border_colour")
	fs.unknown_markers_extra_allowed = mod:get("unknown_markers_extra_allowed")
	fs.unknown_colour_R = mod:get("unknown_colour_R")
	fs.unknown_colour_G = mod:get("unknown_colour_G")
	fs.unknown_colour_B = mod:get("unknown_colour_B")
	fs.chest_icon = mod:get("chest_icon")
	fs.chest_border_colour = mod:get("chest_border_colour")
	fs.chest_icon_colour_R = mod:get("chest_icon_colour_R")
	fs.chest_icon_colour_G = mod:get("chest_icon_colour_G")
	fs.chest_icon_colour_B = mod:get("chest_icon_colour_B")
	fs.luggable_icon = mod:get("luggable_icon")
	fs.luggable_border_colour = mod:get("luggable_border_colour")
	fs.icon_colour_R = mod:get("icon_colour_R")
	fs.icon_colour_G = mod:get("icon_colour_G")
	fs.icon_colour_B = mod:get("icon_colour_B")
	fs.idol_border_colour = mod:get("idol_border_colour")

	fs.per_type = fs.per_type or {}
	local pt = fs.per_type

	for _, t in ipairs(marker_types) do
		pt[t] = pt[t] or {}
		pt[t].max_distance = mod:get(t .. "_max_distance")
		pt[t].require_line_of_sight = mod:get(t .. "_require_line_of_sight")
		pt[t].keep_on_screen = mod:get(t .. "_keep_on_screen")
		pt[t].scale = mod:get(t .. "_scale") or 100
		pt[t].alpha = mod:get(t .. "_alpha") or 1
		pt[t].colour_R = mod:get(t .. "_colour_R")
		pt[t].colour_G = mod:get(t .. "_colour_G")
		pt[t].colour_B = mod:get(t .. "_colour_B")
		pt[t].border_colour = mod:get(t .. "_border_colour")
	end

	pt.stolen_rations = pt.stolen_rations or {}
	pt.tainted_device = pt.tainted_device or {}
	pt.tainted_skull = pt.tainted_skull or {}
	pt.rations = pt.rations or {}
	pt.atonement = pt.atonement or {}

	pt.stolen_rations.max_distance = mod:get("stolen_rations_max_distance") or mod:get("event_max_distance")
	pt.stolen_rations.require_line_of_sight = mod:get("stolen_rations_require_line_of_sight")
		or mod:get("event_require_line_of_sight")
	pt.stolen_rations.keep_on_screen = mod:get("rations_keep_on_screen")

	pt.tainted_device.max_distance = mod:get("tainted_device_max_distance") or mod:get("event_max_distance")
	pt.tainted_device.require_line_of_sight = mod:get("tainted_device_require_line_of_sight")
		or mod:get("event_require_line_of_sight")
	pt.tainted_device.keep_on_screen = mod:get("event_keep_on_screen")

	pt.tainted_skull.max_distance = mod:get("tainted_skull_max_distance") or mod:get("event_max_distance")
	pt.tainted_skull.require_line_of_sight = mod:get("event_require_line_of_sight")
	pt.tainted_skull.keep_on_screen = mod:get("event_keep_on_screen")

	pt.rations.max_distance = pt.ammo_med.max_distance
	pt.rations.require_line_of_sight = mod:get("event_require_line_of_sight")
	pt.rations.keep_on_screen = mod:get("rations_keep_on_screen")

	pt.atonement.max_distance = pt.event.max_distance
	pt.atonement.require_line_of_sight = mod:get("event_require_line_of_sight")
	pt.atonement.keep_on_screen = mod:get("event_keep_on_screen")

	for _, t in ipairs({ "stolen_rations", "tainted_device", "tainted_skull", "rations", "atonement" }) do
		pt[t].colour_R = mod:get("event_colour_R")
		pt[t].colour_G = mod:get("event_colour_G")
		pt[t].colour_B = mod:get("event_colour_B")
		pt[t].border_colour = mod:get("event_border_colour")
	end

	fs.chest_max_distance = pt.chest.max_distance
	fs.chest_keep_on_screen = pt.chest.keep_on_screen
	fs.material_max_distance = pt.material.max_distance
	fs.material_keep_on_screen = pt.material.keep_on_screen
	fs.tome_max_distance = pt.tome.max_distance
	fs.tome_keep_on_screen = pt.tome.keep_on_screen
	fs.stimm_max_distance = pt.stimm.max_distance
	fs.stimm_keep_on_screen = pt.stimm.keep_on_screen
	fs.heretical_idol_max_distance = pt.heretical_idol.max_distance
	fs.heretical_idol_keep_on_screen = pt.heretical_idol.keep_on_screen
	fs.heretical_idol_enable = fs.enable.heretical_idol

	fs.objective_max_distance = pt.objective.max_distance
	fs.objective_keep_on_screen = pt.objective.keep_on_screen
	fs.objective_require_line_of_sight = pt.objective.require_line_of_sight

	fs.ammo_status_colours_enable = mod:get("ammo_status_colours_enable")
	fs.ammo_status_dim_unwanted_enable = mod:get("ammo_status_dim_unwanted_enable") ~= false
	fs.ammo_status_circle_enable = mod:get("ammo_status_circle_enable")
	fs.ammo_status_numeric_enable = mod:get("ammo_status_numeric_enable")
	fs.ammo_status_show_most_needy = mod:get("ammo_status_show_most_needy")
	fs.ammo_status_show_gain = mod:get("ammo_status_show_gain")
	fs.ammo_status_show_waste = mod:get("ammo_status_show_waste")
	fs.ammo_status_margin = mod:get("ammo_status_margin") or 0
	fs.ammo_status_green_colour_R = mod:get("ammo_status_green_colour_R")
	fs.ammo_status_green_colour_G = mod:get("ammo_status_green_colour_G")
	fs.ammo_status_green_colour_B = mod:get("ammo_status_green_colour_B")
	fs.ammo_status_orange_colour_R = mod:get("ammo_status_orange_colour_R")
	fs.ammo_status_orange_colour_G = mod:get("ammo_status_orange_colour_G")
	fs.ammo_status_orange_colour_B = mod:get("ammo_status_orange_colour_B")
	fs.ammo_status_red_colour_R = mod:get("ammo_status_red_colour_R")
	fs.ammo_status_red_colour_G = mod:get("ammo_status_red_colour_G")
	fs.ammo_status_red_colour_B = mod:get("ammo_status_red_colour_B")
	fs.ammo_status_enable = mod:get("ammo_status_enable")
	fs.ammo_status_marker_text_enable = mod:get("ammo_status_marker_text_enable")
	fs.ammo_status_popup_text_enable = mod:get("ammo_status_popup_text_enable")
	fs.ammo_status_text_font_size = mod:get("ammo_status_text_font_size")
	fs.ammo_status_text_position = mod:get("ammo_status_text_position")
	fs.ammo_status_text_offset = mod:get("ammo_status_text_offset")
	fs.ammo_status_text_width = mod:get("ammo_status_text_width")
	fs.ammo_status_gain_colour_R = mod:get("ammo_status_gain_colour_R")
	fs.ammo_status_gain_colour_G = mod:get("ammo_status_gain_colour_G")
	fs.ammo_status_gain_colour_B = mod:get("ammo_status_gain_colour_B")
	fs.ammo_status_waste_colour_R = mod:get("ammo_status_waste_colour_R")
	fs.ammo_status_waste_colour_G = mod:get("ammo_status_waste_colour_G")
	fs.ammo_status_waste_colour_B = mod:get("ammo_status_waste_colour_B")

	fs.ammo_med_max_distance = mod:get("ammo_med_max_distance")
	fs.ammo_med_keep_on_screen = mod:get("ammo_med_keep_on_screen")
	fs.ammo_med_require_line_of_sight = mod:get("ammo_med_require_line_of_sight")
	fs.med_station_require_line_of_sight = mod:get("med_station_require_line_of_sight")
	fs.med_station_max_distance = mod:get("med_station_max_distance")
	fs.display_med_ring = mod:get("display_med_ring")
	fs.display_med_charges = mod:get("display_med_charges")
	fs.display_med_crate_estimate = mod:get("display_med_crate_estimate")
	fs.display_ammo_charges = mod:get("display_ammo_charges")
	fs.change_colour_for_ammo_charges = mod:get("change_colour_for_ammo_charges")

	fs.charges_4_colour_R = mod:get("change_colour_for_ammo_charges_4_R")
	fs.charges_4_colour_G = mod:get("change_colour_for_ammo_charges_4_G")
	fs.charges_4_colour_B = mod:get("change_colour_for_ammo_charges_4_B")

	fs.charges_3_colour_R = mod:get("change_colour_for_ammo_charges_3_R")
	fs.charges_3_colour_G = mod:get("change_colour_for_ammo_charges_3_G")
	fs.charges_3_colour_B = mod:get("change_colour_for_ammo_charges_3_B")

	fs.charges_2_colour_R = mod:get("change_colour_for_ammo_charges_2_R")
	fs.charges_2_colour_G = mod:get("change_colour_for_ammo_charges_2_G")
	fs.charges_2_colour_B = mod:get("change_colour_for_ammo_charges_2_B")

	fs.charges_1_colour_R = mod:get("change_colour_for_ammo_charges_1_R")
	fs.charges_1_colour_G = mod:get("change_colour_for_ammo_charges_1_G")
	fs.charges_1_colour_B = mod:get("change_colour_for_ammo_charges_1_B")

	fs.display_field_improv_colour = mod:get("display_field_improv_colour")
	fs.display_field_improv_icon = mod:get("display_field_improv_icon")
	fs.ammo_med_markers_alternate_large_ammo_icon = mod:get("ammo_med_markers_alternate_large_ammo_icon")
	fs.field_improv_colour_R = mod:get("field_improv_colour_R")
	fs.field_improv_colour_G = mod:get("field_improv_colour_G")
	fs.field_improv_colour_B = mod:get("field_improv_colour_B")
	fs.ammo_small_colour_R = mod:get("ammo_small_colour_R")
	fs.ammo_small_colour_G = mod:get("ammo_small_colour_G")
	fs.ammo_small_colour_B = mod:get("ammo_small_colour_B")
	fs.ammo_small_border_colour = mod:get("ammo_small_border_colour")
	fs.ammo_large_colour_R = mod:get("ammo_large_colour_R")
	fs.ammo_large_colour_G = mod:get("ammo_large_colour_G")
	fs.ammo_large_colour_B = mod:get("ammo_large_colour_B")
	fs.ammo_large_border_colour = mod:get("ammo_large_border_colour")
	fs.ammo_crate_colour_R = mod:get("ammo_crate_colour_R")
	fs.ammo_crate_colour_G = mod:get("ammo_crate_colour_G")
	fs.ammo_crate_colour_B = mod:get("ammo_crate_colour_B")
	fs.ammo_crate_border_colour = mod:get("ammo_crate_border_colour")
	fs.med_crate_colour_R = mod:get("med_crate_colour_R")
	fs.med_crate_colour_G = mod:get("med_crate_colour_G")
	fs.med_crate_colour_B = mod:get("med_crate_colour_B")
	fs.med_crate_border_colour = mod:get("med_crate_border_colour")
	fs.grenade_colour_R = mod:get("grenade_colour_R")
	fs.grenade_colour_G = mod:get("grenade_colour_G")
	fs.grenade_colour_B = mod:get("grenade_colour_B")
	fs.grenade_border_colour = mod:get("grenade_border_colour")

	fs.power_stimm_icon_colour_R = mod:get("power_stimm_icon_colour_R")
	fs.power_stimm_icon_colour_G = mod:get("power_stimm_icon_colour_G")
	fs.power_stimm_icon_colour_B = mod:get("power_stimm_icon_colour_B")
	fs.power_stimm_border_colour = mod:get("power_stimm_border_colour")
	fs.speed_stimm_icon_colour_R = mod:get("speed_stimm_icon_colour_R")
	fs.speed_stimm_icon_colour_G = mod:get("speed_stimm_icon_colour_G")
	fs.speed_stimm_icon_colour_B = mod:get("speed_stimm_icon_colour_B")
	fs.speed_stimm_border_colour = mod:get("speed_stimm_border_colour")
	fs.boost_stimm_icon_colour_R = mod:get("boost_stimm_icon_colour_R")
	fs.boost_stimm_icon_colour_G = mod:get("boost_stimm_icon_colour_G")
	fs.boost_stimm_icon_colour_B = mod:get("boost_stimm_icon_colour_B")
	fs.boost_stimm_border_colour = mod:get("boost_stimm_border_colour")
	fs.corruption_stimm_icon_colour_R = mod:get("corruption_stimm_icon_colour_R")
	fs.corruption_stimm_icon_colour_G = mod:get("corruption_stimm_icon_colour_G")
	fs.corruption_stimm_icon_colour_B = mod:get("corruption_stimm_icon_colour_B")
	fs.corruption_stimm_border_colour = mod:get("corruption_stimm_border_colour")
	fs.broker_stimm_icon_colour_R = mod:get("broker_stimm_icon_colour_R")
	fs.broker_stimm_icon_colour_G = mod:get("broker_stimm_icon_colour_G")
	fs.broker_stimm_icon_colour_B = mod:get("broker_stimm_icon_colour_B")
	fs.broker_stimm_border_colour = mod:get("broker_stimm_border_colour")
	fs.broker_stimm_enable = mod:get("broker_stimm_enable")
	fs.stimm_require_line_of_sight = mod:get("stimm_require_line_of_sight")
	fs.boost_stimm_require_line_of_sight = mod:get("boost_stimm_require_line_of_sight")
	fs.corruption_stimm_require_line_of_sight = mod:get("corruption_stimm_require_line_of_sight")
	fs.power_stimm_require_line_of_sight = mod:get("power_stimm_require_line_of_sight")
	fs.speed_stimm_require_line_of_sight = mod:get("speed_stimm_require_line_of_sight")
	fs.broker_stimm_require_line_of_sight = mod:get("broker_stimm_require_line_of_sight")
	fs.toggle_background_colour = mod:get("toggle_background_colour")

	fs.plasteel_icon_colour_R = mod:get("plasteel_icon_colour_R")
	fs.plasteel_icon_colour_G = mod:get("plasteel_icon_colour_G")
	fs.plasteel_icon_colour_B = mod:get("plasteel_icon_colour_B")
	fs.diamantine_icon_colour_R = mod:get("diamantine_icon_colour_R")
	fs.diamantine_icon_colour_G = mod:get("diamantine_icon_colour_G")
	fs.diamantine_icon_colour_B = mod:get("diamantine_icon_colour_B")
	fs.material_small_border_colour = mod:get("material_small_border_colour")
	fs.material_large_border_colour = mod:get("material_large_border_colour")
	fs.toggle_large_plasteel = mod:get("toggle_large_plasteel")
	fs.toggle_small_plasteel = mod:get("toggle_small_plasteel")
	fs.toggle_large_diamantine = mod:get("toggle_large_diamantine")
	fs.toggle_small_diamantine = mod:get("toggle_small_diamantine")

	fs.grim_colour_R = mod:get("grim_colour_R")
	fs.grim_colour_G = mod:get("grim_colour_G")
	fs.grim_colour_B = mod:get("grim_colour_B")
	fs.script_colour_R = mod:get("script_colour_R")
	fs.script_colour_G = mod:get("script_colour_G")
	fs.script_colour_B = mod:get("script_colour_B")
	fs.tome_border_colour = mod:get("tome_border_colour")

	fs.expedition_border_colour = mod:get("expedition_border_colour")
	fs.expedition_border_colour_1 = mod:get("expedition_border_colour_1")
	fs.expedition_border_colour_2 = mod:get("expedition_border_colour_2")
	fs.expedition_border_colour_3 = mod:get("expedition_border_colour_3")
	fs.expedition_pickups_colour_R = mod:get("expedition_pickups_colour_R")
	fs.expedition_pickups_colour_G = mod:get("expedition_pickups_colour_G")
	fs.expedition_pickups_colour_B = mod:get("expedition_pickups_colour_B")
	fs.expedition_currency_colour_R = mod:get("expedition_currency_colour_R")
	fs.expedition_currency_colour_G = mod:get("expedition_currency_colour_G")
	fs.expedition_currency_colour_B = mod:get("expedition_currency_colour_B")
	fs.expedition_reliquary_colour_R = mod:get("expedition_reliquary_colour_R")
	fs.expedition_reliquary_colour_G = mod:get("expedition_reliquary_colour_G")
	fs.expedition_reliquary_colour_B = mod:get("expedition_reliquary_colour_B")
	fs.expedition_remnants_colour_R = mod:get("expedition_remnants_colour_R")
	fs.expedition_remnants_colour_G = mod:get("expedition_remnants_colour_G")
	fs.expedition_remnants_colour_B = mod:get("expedition_remnants_colour_B")
	fs.expedition_crate_colour_R = mod:get("expedition_crate_colour_R")
	fs.expedition_crate_colour_G = mod:get("expedition_crate_colour_G")
	fs.expedition_crate_colour_B = mod:get("expedition_crate_colour_B")
	fs.expedition_colour_R = mod:get("expedition_colour_R")
	fs.expedition_colour_G = mod:get("expedition_colour_G")
	fs.expedition_colour_B = mod:get("expedition_colour_B")
end

mod._runtime_state_timer = 0
mod._runtime_state_unit = nil

mod.update_runtime_state = function(dt)
	local fs = mod.frame_settings

	mod.update_ads_state()

	local player = mod.get_local_player()
	local unit = get_player_unit(player)

	if not unit or not ALIVE[unit] then
		fs.servo_skull_equipped = false
		fs.inject_ally = nil
		fs.servo_skull_injecting = false

		mod._runtime_state_unit = nil
		mod._runtime_state_timer = 0

		return
	end

	local unit_changed = mod._runtime_state_unit ~= unit

	mod._runtime_state_timer = mod._runtime_state_timer - (dt or 0)

	if not unit_changed and mod._runtime_state_timer > 0 then
		return
	end

	mod._runtime_state_unit = unit
	mod._runtime_state_timer = 0.15

	fs.servo_skull_equipped = false
	fs.inject_ally = nil
	fs.servo_skull_injecting = false

	local talent_ext = has_extension(unit, "talent_system")

	if not talent_ext then
		return
	end

	local sr = SpecialRulesSettings.special_rules
	local inject_rule = sr.cryptic_servo_skull_inject_ally

	local has_inject_rule = talent_ext:has_special_rule(inject_rule)

	fs.servo_skull_equipped = has_inject_rule
		or talent_ext:has_special_rule(sr.cryptic_servo_skull_hack)
		or talent_ext:has_special_rule(sr.cryptic_servo_skull_flamethrower)

	if not has_inject_rule then
		return
	end

	local spawner_ext = has_extension(unit, "companion_spawner_system")

	if not spawner_ext then
		return
	end

	local comp_unit = spawner_ext:spawned_unit_lookup(inject_rule)

	if not comp_unit or not ALIVE[comp_unit] then
		return
	end

	local ability_ext = has_extension(unit, "ability_system")

	if not ability_ext then
		return
	end

	if
		ability_ext:remaining_ability_charges("grenade_ability")
		< CompanionServoSkullSettings.ability_charges.inject_ally
	then
		return
	end

	local inject_data = mod._inject_ally_data

	if not inject_data then
		inject_data = {}
		mod._inject_ally_data = inject_data
	end

	inject_data.companion_unit = comp_unit
	fs.inject_ally = inject_data

	local game_session = Managers.state.game_session:game_session()

	if not game_session then
		return
	end

	local go_id = Managers.state.unit_spawner:game_object_id(comp_unit)

	if not go_id then
		return
	end

	fs.servo_skull_injecting = GameSession.game_object_field(game_session, go_id, "state") == "inject_ally"
end

mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/pickup_name_overrides")

mod.build_settings()

local HereticalIdolTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/heretical_idols/heretical_idol_markers_template")
local MedMarkerTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/ammo_med/ammo_med_markers_template")
local ChestMarkerTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/chest_markers/chest_markers_template")
local MartyrsSkullMarkerTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/martyrs_skull/martyrs_skull_markers_template")
local MartyrsSkullMarkerGuideTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/martyrs_skull/martyrs_skull_markers_guide_template")
local SpillwayPathMarkerTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/spillway_markers/spillway_path_markers_template")
local GUIDE_WIDGET_PATH = "markers_aio/scripts/mods/markers_aio/modules/martyrs_skull/martyrs_skull_guide_widget"
mod:add_require_path(GUIDE_WIDGET_PATH)

local guide_element_def = {
	class_name = "MartyrsSkullGuideElement",
	filename = GUIDE_WIDGET_PATH,
	visibility_groups = {
		"dead",
		"alive",
		"player_in_danger_zone",
	},
}

mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/ammo_med/ammo_med_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/chest_markers/chest_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/heretical_idols/heretical_idol_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/material_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/stimm_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/tome_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/tainted_device_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/tainted_skull_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/luggable_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/martyrs_skull/martyrs_skull_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/stolen_rations_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/atonement_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/unknown_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/expedition_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/objective_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/servo_skull_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/player_assistance_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/spillway_markers/spillway_path_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/spillway_markers/spillway_path_route")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/proximity_notifications")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/utils/icon_package_loader")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/markers_aio_localization")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/utils/utilities")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/utils/tagging_utils")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/marker_dispatcher")

mod.refresh_templates = function()
	mod.build_settings()

	if mod.frame_settings.mod_enabled then
		local is_mod_loading = true

		mod:hook_require("scripts/extension_systems/unit_templates", function(instance)
			if is_mod_loading then
				-- live games
				mod:hook_safe(
					instance.medical_crate_deployable,
					"husk_init",
					function(unit, config, template_context, game_session, game_object_id, owner_id)
						mod.add_medkit_marker_and_proximity(nil, unit)
					end
				)

				-- private games
				mod:hook_safe(
					instance.medical_crate_deployable,
					"local_unit_spawned",
					function(
						unit,
						template_context,
						game_object_data,
						side_id,
						deployable,
						placed_on_unit,
						owner_unit_or_nil
					)
						mod.add_medkit_marker_and_proximity(nil, unit)
					end
				)

				is_mod_loading = false
			end
		end)

		local load_package = function(path, id)
			if not Managers.package:has_loaded(path) then
				Managers.package:load(path, id)
				return
			end
		end

		mod._ensure_icon_packages_loaded()

		load_package("content/levels/training_grounds/missions/mission_tg_basic_combat_01", "medkit_radius")
		load_package("packages/ui/views/options_view/options_view", "large_ammo1")
		load_package("packages/ui/views/inventory_background_view/inventory_background_view", "large_ammo2")

		mod.marker_dispatcher.initialize()

		mod.check_recolorstimms()

		-- Init stuff
		mod.active_chests = {}
		mod.current_heretical_idol_markers = {}
		mod.totem_units = {}
		mod.medical_crate_charges = {}
		mod.reset_martyrs_skull_guides()
		mod.reset_spillway_path_markers()
		mod.reset_spillway_path_route()
		mod._needs_totem_scan = true

		local loc = Managers and Managers.localization

		if loc and loc._string_cache then
			local cache = loc._string_cache
			local mod_names = {
				"mod_marker_chest_name",
				"mod_marker_item_name",
				"mod_marker_medicae_station_name",
				"mod_marker_heretical_idol_name",
				"mod_marker_stimm_name",
				"mod_marker_power_stimm_name",
				"mod_marker_speed_stimm_name",
				"mod_marker_boost_stimm_name",
				"mod_marker_medic_stimm_name",
				"mod_marker_broker_stimm_name",
				"mod_marker_tome_name",
				"mod_marker_material_name",
				"mod_marker_luggable_name",
				"mod_marker_expedition_name",
				"mod_marker_event_name",
				"mod_marker_servo_skull_name",
				"mod_marker_unknown_name",
			}
			for _, key in ipairs(mod_names) do
				local resolved = mod:localize(key)
				if resolved and resolved ~= key then
					cache[key] = resolved
				end
			end
		end
	end
end

mod.on_all_mods_loaded = function()
	if mod.refresh_pickup_name_options then
		mod.refresh_pickup_name_options()
	end
	if mod.update_pickup_name_settings then
		mod.update_pickup_name_settings(nil)
	end
	mod.refresh_templates()
end

mod:hook_safe(CLASS.UIViewHandler, "close_view", function(self, view_name, ...)
	if view_name == "dmf_options_view" or view_name == "options_view" then
		mod.refresh_templates()
	end
end)

mod:hook(
	"UIManager",
	"create_player_hud",
	function(original_func, self, peer_id, local_player_id, elements, visibility_groups)
		mod:add_require_path(GUIDE_WIDGET_PATH)

		if elements then
			table.insert(elements, guide_element_def)
		end
		return original_func(self, peer_id, local_player_id, elements, visibility_groups)
	end
)

mod:hook(
	"UIManager",
	"create_spectator_hud",
	function(original_func, self, world_viewport_name, peer_id, local_player_id, elements, visibility_groups)
		mod:add_require_path(GUIDE_WIDGET_PATH)

		if elements then
			table.insert(elements, guide_element_def)
		end
		return original_func(self, world_viewport_name, peer_id, local_player_id, elements, visibility_groups)
	end
)

mod.guide_widget_set_content = function(header, body, steps)
	local hud = Managers.ui and Managers.ui:get_hud()
	if not hud then
		return
	end
	local element = hud._elements and hud._elements["MartyrsSkullGuideElement"]
	if element then
		element:set_content(header, body, steps)
	end
end

mod.guide_widget_clear = function()
	local hud = Managers.ui and Managers.ui:get_hud()
	if not hud then
		return
	end
	local element = hud._elements and hud._elements["MartyrsSkullGuideElement"]
	if element then
		element:clear()
	end
end

mod:hook_safe(CLASS.HudElementWorldMarkers, "init", function(self)
	if
		HereticalIdolTemplate
		and MedMarkerTemplate
		and ChestMarkerTemplate
		and MartyrsSkullMarkerTemplate
		and MartyrsSkullMarkerGuideTemplate
		and SpillwayPathMarkerTemplate
	then
		if not self._marker_templates[HereticalIdolTemplate.name] then
			self._marker_templates[HereticalIdolTemplate.name] = HereticalIdolTemplate
		end
		if not self._marker_templates["nurgle_totem"] then
			self._marker_templates["nurgle_totem"] = HereticalIdolTemplate
		end
		if not self._marker_templates[MedMarkerTemplate.name] then
			self._marker_templates[MedMarkerTemplate.name] = MedMarkerTemplate
		end
		if not self._marker_templates[ChestMarkerTemplate.name] then
			self._marker_templates[ChestMarkerTemplate.name] = ChestMarkerTemplate
		end
		if not self._marker_templates[MartyrsSkullMarkerTemplate.name] then
			self._marker_templates[MartyrsSkullMarkerTemplate.name] = MartyrsSkullMarkerTemplate
		end
		if not self._marker_templates[MartyrsSkullMarkerGuideTemplate.name] then
			self._marker_templates[MartyrsSkullMarkerGuideTemplate.name] = MartyrsSkullMarkerGuideTemplate
		end
		if not self._marker_templates[SpillwayPathMarkerTemplate.name] then
			self._marker_templates[SpillwayPathMarkerTemplate.name] = SpillwayPathMarkerTemplate
		end
	end

	mod.active_chests = {}
	mod.current_heretical_idol_markers = {}
	mod.totem_units = {}
	mod.medical_crate_charges = {}
	if mod.reset_martyrs_skull_guides then
		mod.reset_martyrs_skull_guides()
	end
	if mod.reset_spillway_path_markers then
		mod.reset_spillway_path_markers()
	end
	if mod.reset_spillway_path_route then
		mod.reset_spillway_path_route()
	end
	mod._needs_totem_scan = true

	local loc = Managers and Managers.localization

	if loc and loc._string_cache then
		local cache = loc._string_cache
		local mod_names = {
			"mod_marker_chest_name",
			"mod_marker_item_name",
			"mod_marker_medicae_station_name",
			"mod_marker_heretical_idol_name",
			"mod_marker_stimm_name",
			"mod_marker_power_stimm_name",
			"mod_marker_speed_stimm_name",
			"mod_marker_boost_stimm_name",
			"mod_marker_medic_stimm_name",
			"mod_marker_broker_stimm_name",
			"mod_marker_tome_name",
			"mod_marker_material_name",
			"mod_marker_luggable_name",
			"mod_marker_expedition_name",
			"mod_marker_event_name",
			"mod_marker_servo_skull_name",
			"mod_marker_unknown_name",
		}
		for _, key in ipairs(mod_names) do
			local resolved = mod:localize(key)
			if resolved and resolved ~= key then
				cache[key] = resolved
			end
		end
	end
end)

mod:hook_safe(CLASS.MissionObjectiveSystem, "hot_join_sync", function(self, sender, channel)
	mod.reset_martyrs_skull_guides()
	mod.scan_for_existing_totems()
end)

mod.get_marker_pickup_type = function(marker)
	local cached = marker._aio_pickup_type
	if cached ~= nil then
		return cached
	end

	if
		marker.type ~= "interaction"
		or not marker.unit
		or not Unit
		or type(marker.unit) ~= "userdata"
		or not Unit.alive(marker.unit)
		or not Unit.has_data(marker.unit, "pickup_type")
	then
		return
	end

	local pickup_type = Unit.get_data(marker.unit, "pickup_type")
	if pickup_type ~= nil then
		marker._aio_pickup_type = pickup_type
	end

	return pickup_type
end

local smart_tag_system_cache
local smart_tag_system_manager

mod.get_smart_tag_system = function()
	local extension_manager = Managers.state.extension

	if smart_tag_system_manager ~= extension_manager then
		smart_tag_system_manager = extension_manager
		smart_tag_system_cache = extension_manager and extension_manager:system("smart_tag_system")
	end

	return smart_tag_system_cache
end

mod.get_marker_extension = function(marker, extension_name)
	local unit = marker.unit

	if not unit or not ALIVE[unit] then
		return nil
	end

	local cache = marker._aio_ext

	if not cache or marker._aio_ext_unit ~= unit then
		cache = {}
		marker._aio_ext = cache
		marker._aio_ext_unit = unit
	end

	local extension = cache[extension_name]

	if extension ~= nil then
		return extension or nil
	end

	extension = has_extension(unit, extension_name)

	cache[extension_name] = extension or false

	return extension
end

mod.set_colour = function(dst, src)
	if not dst or not src then
		return
	end

	dst[1] = src[1] or 255
	dst[2] = src[2] or 255
	dst[3] = src[3] or 255
	dst[4] = src[4] or 255
end

mod.set_colour_argb = function(dst, a, r, g, b)
	if not dst then
		return
	end

	dst[1] = a or 255
	dst[2] = r or 255
	dst[3] = g or 255
	dst[4] = b or 255
end

local LOOKUP_COLOUR_DEFAULT = { 255, 255, 255, 255 }

local COLOUR_LOOKUP = {
	Gold = { 255, 232, 188, 109 },
	Silver = { 255, 187, 198, 201 },
	Steel = { 255, 161, 166, 169 },
	Black = { 255, 35, 31, 32 },
	Brass = { 255, 226, 199, 126 },
	Terminal = Color.terminal_background(225, true),
	Default = { 255, 161, 166, 169 },
	Tarnished = { 255, 130, 115, 102 },
}

mod.lookup_colour = function(colour_string)
	local color = LOOKUP_COLOUR_DEFAULT

	if colour_string then
		color = COLOUR_LOOKUP[colour_string]
	end

	return color
end

mod.get_marker_by_id = function(id)
	local ui_manager = Managers.ui

	if not ui_manager then
		return nil
	end

	local hud = ui_manager:get_hud()

	if not hud then
		return nil
	end

	local world_markers = hud:element("HudElementWorldMarkers")

	if not world_markers then
		return nil
	end

	local markers_by_id = world_markers._markers_by_id

	return markers_by_id and markers_by_id[id]
end

local function compute_marker_scale(scale_settings, distance)
	if distance and scale_settings then
		local easing_function = scale_settings.easing_function

		if distance > scale_settings.distance_max then
			return scale_settings.scale_from
		elseif distance < scale_settings.distance_min then
			return scale_settings.scale_to
		else
			local distance_fade_fraction = 1
				- (distance - scale_settings.distance_min)
					/ (scale_settings.distance_max - scale_settings.distance_min)
			local eased_distance_scale_fraction = easing_function and easing_function(distance_fade_fraction)
				or distance_fade_fraction
			local adjusted_fade = scale_settings.scale_from
				+ eased_distance_scale_fraction * (scale_settings.scale_to - scale_settings.scale_from)

			return adjusted_fade
		end
	else
		return 1
	end
end

HudElementWorldMarkers._get_scale = function(self, scale_settings, distance)
	return compute_marker_scale(scale_settings, distance) or 1
end

HudElementWorldMarkers._get_fade = function(self, fade_settings, distance)
	if fade_settings and distance then
		local easing_function = fade_settings.easing_function
		local return_value

		if distance > fade_settings.distance_max then
			return_value = fade_settings.fade_from
		elseif distance < fade_settings.distance_min then
			return_value = fade_settings.fade_to
		else
			local distance_fade_fraction = 1
				- (distance - fade_settings.distance_min)
					/ (fade_settings.distance_max - fade_settings.distance_min)
			local eased_distance_fade_fraction = easing_function and easing_function(distance_fade_fraction)
				or distance_fade_fraction
			local adjusted_fade = fade_settings.fade_from
				+ eased_distance_fade_fraction * (fade_settings.fade_to - fade_settings.fade_from)

			return_value = adjusted_fade
		end

		if fade_settings.invert then
			return 1 - return_value
		else
			return return_value
		end
	else
		return 1
	end
end

local temp_drawable_objectives = {}
local temp_drawable_normal = {}
local temp_drawable_aio = {}

local function sort_drawable_markers(a, b)
	return (a.distance or 0) > (b.distance or 0)
end

local HudElementWorldMarkersSettings =
	require("scripts/ui/hud/elements/world_markers/hud_element_world_markers_settings")

local BASE_Z = 0
local Z_STRIDE = 4

local function draw_marker_list(self, markers, ui_renderer, draw_index)
	for i = 1, #markers do
		local marker = markers[i]
		local widget = marker.widget

		draw_index = draw_index + 1

		local offset = widget.offset

		if offset then
			offset[3] = BASE_Z + draw_index * Z_STRIDE
		end

		local alpha_multiplier = widget.alpha_multiplier or 1

		if marker.markers_aio_type == nil then
			local template = marker.template
			local fade_settings = template and template.fade_settings

			if fade_settings and not marker.block_fade_settings then
				local fade = self:_get_fade(fade_settings, marker.distance) or 1

				widget.alpha_multiplier = alpha_multiplier * fade
				UIWidget.draw(widget, ui_renderer)
				widget.alpha_multiplier = alpha_multiplier
			else
				UIWidget.draw(widget, ui_renderer)
			end
		else
			UIWidget.draw(widget, ui_renderer)
		end
	end

	return draw_index
end

HudElementWorldMarkers._draw_markers = function(self, dt, t, input_service, ui_renderer, render_settings)
	local camera = mod.get_valid_world_marker_camera(self)
	if not camera then
		return
	end

	local markers_by_type = self._markers_by_type

	local objectives = temp_drawable_objectives
	local normal = temp_drawable_normal
	local aio = temp_drawable_aio

	table.clear(objectives)
	table.clear(normal)
	table.clear(aio)

	for _, markers in pairs(markers_by_type) do
		for i = 1, #markers do
			local marker = markers[i]

			if marker.draw and marker.widget then
				if marker.type == "objective" then
					objectives[#objectives + 1] = marker
				elseif marker.markers_aio_type then
					aio[#aio + 1] = marker
				else
					normal[#normal + 1] = marker
				end
			end
		end
	end

	if #normal > 1 then
		table.sort(normal, sort_drawable_markers)
	end

	if #aio > 1 then
		table.sort(aio, sort_drawable_markers)
	end

	local draw_index = 0

	draw_index = draw_marker_list(self, objectives, ui_renderer, draw_index)
	draw_index = draw_marker_list(self, normal, ui_renderer, draw_index)
	draw_index = draw_marker_list(self, aio, ui_renderer, draw_index)
end

local DEBUG_MARKER = "objective"
local temp_array_markers_to_remove = {}
local temp_marker_raycast_queue = {}

local function force_text_full_alpha(marker)
	if not marker or not marker.widget or not marker.widget.style then
		return
	end

	local widget = marker.widget
	local style = widget.style
	local text_style = style.marker_text

	if not text_style or not text_style.color then
		return
	end

	local widget_alpha = widget.alpha_multiplier or 1
	if widget_alpha <= 0 then
		return
	end

	local corrected_alpha = math.clamp(255 / widget_alpha, 0, 255)

	text_style.color[1] = corrected_alpha
end

local function compute_distance_alpha(marker, max_distance)
	if not max_distance or not marker.distance then
		return 1
	end

	local d = math.clamp(marker.distance / max_distance, 0, 1)

	if d < 0.85 then
		return 1
	end

	local t = (d - 0.85) / 0.25
	t = math.clamp(t, 0, 1)
	t = t * t * (3 - 2 * t)

	return 1 - t
end

local function classify_aio_marker(self, marker, marker_type)
	if not mod.frame_settings.mod_enabled or not mod:is_enabled() then
		return
	end

	local type_old
	local marker_function

	if not mod.frame_settings or mod.frame_settings and not mod.frame_settings.enable then
		return
	end

	if mod.frame_settings.enable.objective and mod.update_objective_markers then
		type_old = marker.markers_aio_type
		mod.update_objective_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_objective_markers
		end
	end

	if mod.frame_settings.enable.tome and mod.update_tome_markers then
		type_old = marker.markers_aio_type
		mod.update_tome_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_tome_markers
		end
	end

	if mod.frame_settings.enable.material and mod.update_material_markers then
		type_old = marker.markers_aio_type
		mod.update_material_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_material_markers
		end
	end

	if mod.frame_settings.enable.ammo_med and mod.update_ammo_med_markers then
		type_old = marker.markers_aio_type
		mod.update_ammo_med_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_ammo_med_markers
		end
	end

	if mod.frame_settings.enable.stimm and mod.update_stimm_markers then
		type_old = marker.markers_aio_type
		mod.update_stimm_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_stimm_markers
		end
	end

	if mod.frame_settings.enable.chest and mod.update_chest_markers then
		type_old = marker.markers_aio_type
		mod.update_chest_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_chest_markers
		end
	end

	if mod.frame_settings.enable.heretical_idol and mod.update_marker_icon then
		type_old = marker.markers_aio_type
		mod.update_marker_icon(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_marker_icon
		end
	end

	if mod.frame_settings.enable.luggable and mod.update_luggable_markers then
		type_old = marker.markers_aio_type
		mod.update_luggable_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_luggable_markers
		end
	end

	if mod.frame_settings.enable.expedition and mod.update_expedition_markers then
		type_old = marker.markers_aio_type
		mod.update_expedition_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_expedition_markers
		end
	end

	if mod.frame_settings.enable.unknown and not marker.markers_aio_type and mod.update_unknown_markers then
		type_old = marker.markers_aio_type
		mod.update_unknown_markers(self, marker)

		if marker.markers_aio_type ~= type_old then
			marker_function = mod.update_unknown_markers
		end
	end

	marker._aio_static_handler = marker_function
	marker._aio_classified = true
end

local function marker_max_distance(marker, template, pt)
	local max_distance = template and template.max_distance

	if marker.markers_aio_type then
		max_distance = pt and pt.max_distance or max_distance
	end

	if marker.aio_med_station and marker.markers_aio_type == "ammo_med" then
		max_distance = tonumber(mod.frame_settings.med_station_max_distance) or max_distance
	end

	return max_distance
end

local function update_distance_text_style(widget, fs)
	local style = widget.style.marker_distance_text

	if not style then
		return
	end

	local scale = fs.distance_text_scale * 0.01
	local position = fs.distance_text_position

	local background = widget.style.background
	local icon = widget.style.icon

	if not background or not icon then
		return
	end

	style.font_size = icon.size[2] * 0.5 * scale

	local offset = style.offset

	if not offset then
		return
	end

	offset[1] = 0
	offset[2] = 0

	if position == "Top" then
		offset[2] = -background.size[2] * 0.5 * scale
	elseif position == "Left" then
		offset[1] = -background.size[1] * 0.5 * scale - 8
	elseif position == "Right" then
		offset[1] = background.size[1] * 0.5 * scale + 8
	elseif position == "Center" then
		style.font_size = icon.size[2] / 2.4 * scale

		local ring = widget.style.ring

		if ring and ring.offset then
			offset[3] = ring.offset[3] + 1
		end
	else
		offset[2] = background.size[2] * 0.5 * scale
	end
end

local toggle_check_complete = true

mod.on_disabled = function(initial_call)
	toggle_check_complete = false
end
mod.on_enabled = function(initial_call)
	toggle_check_complete = false
end

HudElementWorldMarkers._calculate_markers = function(self, dt, t, input_service, ui_renderer, render_settings)
	self._next_update = self._next_update or 0
	if t < self._next_update then
		return
	end

	self._next_update = t + 0.01

	local fs = mod.frame_settings

	if fs.mod_enabled then
		mod._aio_frame = mod._aio_frame + 1

		if t then
			mod._aio_ping_progress = 0.5 + math.sin(t * 7) * 0.5
		end

		if mod._frame_settings_dirty then
			mod._frame_settings_dirty = false
			mod.build_settings()
		end

		mod.update_runtime_state(dt)

		local enable_objective = fs and fs.enable and fs.enable.objective or false

		if mod._needs_totem_scan then
			mod._needs_totem_scan = false
			mod.scan_for_existing_totems()
		end

		-- make sure the templates are loaded for our custom markers.
		if HereticalIdolTemplate then
			if not self._marker_templates[HereticalIdolTemplate.name] then
				self._marker_templates[HereticalIdolTemplate.name] = HereticalIdolTemplate
			end
			if not self._marker_templates["nurgle_totem"] then
				self._marker_templates["nurgle_totem"] = HereticalIdolTemplate
			end
		end
		if MedMarkerTemplate then
			if not self._marker_templates[MedMarkerTemplate.name] then
				self._marker_templates[MedMarkerTemplate.name] = MedMarkerTemplate
			end
		end
		if ChestMarkerTemplate then
			if not self._marker_templates[ChestMarkerTemplate.name] then
				self._marker_templates[ChestMarkerTemplate.name] = ChestMarkerTemplate
			end
		end
		if MartyrsSkullMarkerTemplate then
			if not self._marker_templates[MartyrsSkullMarkerTemplate.name] then
				self._marker_templates[MartyrsSkullMarkerTemplate.name] = MartyrsSkullMarkerTemplate
			end
		end
		if MartyrsSkullMarkerGuideTemplate then
			if not self._marker_templates[MartyrsSkullMarkerGuideTemplate.name] then
				self._marker_templates[MartyrsSkullMarkerGuideTemplate.name] = MartyrsSkullMarkerGuideTemplate
			end
		end
		if SpillwayPathMarkerTemplate then
			if not self._marker_templates[SpillwayPathMarkerTemplate.name] then
				self._marker_templates[SpillwayPathMarkerTemplate.name] = SpillwayPathMarkerTemplate
			end
		end
	end

	if not toggle_check_complete then
		if mod:is_enabled() then
			--
		else
			-- RESET TO DEFAULT TEMPLATES ON MOD DISABLE
			local marker_templates = HudElementWorldMarkersSettings.marker_templates

			for i = 1, #marker_templates do
				local template_path = marker_templates[i]
				local template = require(template_path)
				local name = template.name

				self._marker_templates[name] = template
			end

			-- Remove markers_aio_type
			local markers_by_type = self._markers_by_type

			if markers_by_type then
				for marker_type, markers in pairs(markers_by_type) do
					for i = 1, #markers do
						local marker = markers[i]

						if marker and marker.markers_aio_type then
							marker.markers_aio_type = nil
						end
					end
				end
			end

			toggle_check_complete = true
		end
	end

	local raycasts_allowed = self._raycast_frame_counter == 0

	self._raycast_frame_counter = (self._raycast_frame_counter + 1)
		% HudElementWorldMarkersSettings.raycasts_frame_delay

	local camera = get_valid_world_marker_camera(self)

	if camera then
		local scale = ui_renderer.scale
		local inverse_scale = ui_renderer.inverse_scale
		local camera_position = Camera.local_position(camera)
		local camera_rotation = Camera.local_rotation(camera)
		local camera_forward = Quaternion.forward(camera_rotation)
		local camera_direction = camera_forward
		local camera_left_direction = Vector3.cross(camera_direction, Vector3.up())
		local camera_position_center = camera_position + camera_forward
		local camera_pose = Camera.local_pose(camera)
		local camera_position_right = Matrix4x4.right(camera_pose)
		local camera_position_left = -camera_position_right
		local camera_position_up = Matrix4x4.up(camera_pose)
		local camera_position_down = -camera_position_up
		local root_size = UIScenegraph.size_scaled(self._ui_scenegraph, "screen")
		local screen_offset_x, screen_offset_y = self:_get_screen_offset(scale)
		local markers_by_id = self._markers_by_id
		local markers_by_type = self._markers_by_type
		local ALIVE = ALIVE
		local enable = fs.enable

		table.clear(temp_marker_raycast_queue)

		for marker_type, markers in pairs(markers_by_type) do
			for i = 1, #markers do
				local marker = markers[i]
				local id = marker.id
				local template = marker.template
				local update = markers_by_id[id] ~= nil
				local remove = marker.remove
				local widget = marker.widget

				-- default stuff
				if widget then
					local content = widget.content
					local screen_clamp = template.screen_clamp and not marker.block_screen_clamp
					local screen_margins = template.screen_margins

					local pt = marker.markers_aio_type and fs.per_type[marker.markers_aio_type] or nil
					local max_distance = marker_max_distance(marker, template, pt)

					if
						fs.mod_enabled
						and not enable_objective
						and (marker.type == "objective" or (template and template.name == "objective"))
					then
						max_distance = nil
					end

					if marker.block_max_distance then
						max_distance = math.huge
					end

					local life_time = template.life_time
					local check_line_of_sight = template.check_line_of_sight
					local marker_position

					if update then
						local world_position = marker.world_position

						if world_position then
							marker_position = world_position:unbox()
						else
							local unit = marker.unit

							if ALIVE[unit] then
								local unit_node = template.unit_node
								local node = 1

								if unit_node and fs.mod_enabled then
									if marker._aio_node_unit ~= unit or marker._aio_node_name ~= unit_node then
										marker._aio_node_unit = unit
										marker._aio_node_name = unit_node

										if Unit.has_node(unit, unit_node) then
											marker._aio_node_id = Unit.node(unit, unit_node)
										else
											marker._aio_node_id = 1
										end
									end

									node = marker._aio_node_id or 1
								end

								marker_position = Unit.world_position(unit, node)
							else
								remove = true
							end
						end

						if life_time then
							local duration = marker.duration or 0
							duration = math.min(duration + dt, life_time)

							if life_time <= duration then
								remove = true
							else
								marker.duration = duration
							end
						end
					end

					if remove then
						update = false
						temp_array_markers_to_remove[#temp_array_markers_to_remove + 1] = marker
					end

					if update then
						local position_offset = template.position_offset

						if position_offset then
							marker_position.x = marker_position.x + position_offset[1]
							marker_position.y = marker_position.y + position_offset[2]
							marker_position.z = marker_position.z + position_offset[3]
						end

						Vector3Box.store(marker.position, marker_position)

						local delta = marker_position - camera_position
						local distance_sq = Vector3.length_squared(delta)

						local max_distance_sq

						if max_distance and fs.mod_enabled then
							if marker._aio_cached_max_distance ~= max_distance then
								marker._aio_cached_max_distance = max_distance
								marker._aio_cached_max_distance_sq = max_distance * max_distance
							end

							max_distance_sq = marker._aio_cached_max_distance_sq
						end

						local out_of_reach = max_distance_sq and distance_sq > max_distance_sq

						local draw = not out_of_reach

						local distance = math.sqrt(distance_sq)

						content.distance = distance
						marker.distance = distance

						if not out_of_reach then
							local forward_dot_dir = vector_dot(camera_direction, delta)
							local left_dot_dir = vector_dot(camera_left_direction, delta)
							local is_inside_frustum = Camera.inside_frustum(camera, marker_position) > 0

							local angle = math.atan2(left_dot_dir, forward_dot_dir)
							local is_behind = forward_dot_dir < 0 and true or false
							local is_under = marker_position.z < camera_position.z
							local x, y = self:_convert_world_to_screen_position(camera, marker_position)
							local pixel_offset = template.pixel_offset

							if pixel_offset then
								x = x + pixel_offset[1]
								y = y + pixel_offset[2]
							end

							x = x - screen_offset_x
							y = y - screen_offset_y

							local is_clamped, is_clamped_left, is_clamped_right, is_clamped_up, is_clamped_down =
								false, false, false, false, false

							if screen_clamp then
								local clamped_x, clamped_y

								clamped_x, clamped_y, is_clamped_left, is_clamped_right, is_clamped_up, is_clamped_down =
									self:_clamp_to_screen(
										x,
										y,
										screen_margins,
										is_behind,
										is_under,
										marker_position,
										camera_position_center,
										camera_position_left,
										camera_position_right,
										camera_position_up,
										camera_position_down
									)
								is_clamped = is_clamped_left or is_clamped_right or is_clamped_up or is_clamped_down
								x = clamped_x
								y = clamped_y
							end

							if not is_clamped then
								if is_behind then
									draw = false
								elseif not is_inside_frustum then
									local vertical_pixel_overlap, horizontal_pixel_overlap

									if x < 0 then
										horizontal_pixel_overlap = math.abs(x)
									elseif x > root_size[1] then
										horizontal_pixel_overlap = x - root_size[1]
									end

									if y < 0 then
										vertical_pixel_overlap = math.abs(y)
									elseif y > root_size[2] then
										vertical_pixel_overlap = y - root_size[2]
									end

									if vertical_pixel_overlap or horizontal_pixel_overlap then
										draw = false

										local check_widget_visible = template.check_widget_visible

										if check_widget_visible then
											draw = check_widget_visible(
												widget,
												vertical_pixel_overlap,
												horizontal_pixel_overlap
											)
										end
									else
										draw = false
									end
								end
							elseif is_clamped_left or is_clamped_right then
								if is_clamped_left then
									angle = 0
								elseif is_clamped_right then
									angle = math.pi
								end
							elseif is_clamped_up then
								angle = math.pi * 0.5
							elseif is_clamped_down then
								angle = -math.pi * 0.5
							end

							content.is_inside_frustum = is_inside_frustum
							content.is_clamped = is_clamped
							content.is_under = is_under
							content.distance = distance
							content.angle = angle
							marker.is_inside_frustum = is_inside_frustum
							marker.is_clamped = is_clamped
							marker.is_under = is_under
							marker.distance = distance
							marker.angle = angle

							local offset = widget.offset

							offset[1] = x * inverse_scale
							offset[2] = y * inverse_scale

							if draw then
								marker.raycast_frame_count = (marker.raycast_frame_count or 0) + 1

								if raycasts_allowed then
									temp_marker_raycast_queue[#temp_marker_raycast_queue + 1] = marker
								end
							end
						end

						marker.draw = draw
					end

					marker.update = update
				end

				-- custom markers aio stuff
				if marker and marker.update then
					local template = marker.template
					local update_function = template and template.update_function

					if update_function then
						update_function(self, ui_renderer, marker.widget, marker, template, dt, t)
					end

					-- Objective decoder handling.
					if marker.type == "objective" and marker.widget then
						local unit = marker.unit

						if unit and Unit.alive(unit) then
							local decoder_ext = mod.get_marker_extension(marker, "decoder_device_system")

							if decoder_ext and decoder_ext:unit_is_enabled() and not decoder_ext:is_finished() then
								marker.widget.content.text = ""
							end
						end
					end

					-- Static classification.
					if
						fs.mod_enabled and not marker._aio_classified
						or marker._aio_classified_settings ~= mod._settings_version
					then
						classify_aio_marker(self, marker, marker_type)
						marker._aio_classified_settings = mod._settings_version
					end

					-- Cached static handler.
					local static_handler = marker._aio_static_handler

					if static_handler then
						static_handler(self, marker)
					end

					-- Handle marker types (Dispatcher)
					if fs.mod_enabled then
						if mod.marker_dispatcher then
							mod.marker_dispatcher.dispatch(self, marker, marker_type, dt, t)
						end
					end

					local pt = marker.markers_aio_type and fs.per_type[marker.markers_aio_type]

					if marker.markers_aio_type then
						mod.adjust_los_requirement(marker, pt)
						mod.adjust_distance_visibility(marker, pt)
						mod.fade_icon_not_in_los(marker, ui_renderer, pt)
					end

					if marker.aio_suppress then
						marker.draw = false
						marker.widget.alpha_multiplier = 0
					end

					if marker.draw or marker.markers_aio_type then
						mod.adjust_scale(self, marker, ui_renderer, t, pt)
					end

					local widget = marker.widget
					if
						marker.markers_aio_type
						and widget.style.marker_distance_text
						and widget.content.marker_distance_text ~= nil
						and marker.distance
						and widget.style.background
						and widget.style.icon
						and marker.markers_aio_type ~= "objective"
						and marker.type ~= "objective"
						and marker.type ~= "hub_objective"
					then
						if fs.distance_text_enable then
							local meters = math.floor(marker.distance)

							if marker._aio_dist_m ~= meters then
								marker._aio_dist_m = meters
								widget.content.marker_distance_text = meters .. "m"
							end
						elseif marker._aio_dist_m ~= false then
							marker._aio_dist_m = false
							widget.content.marker_distance_text = ""
						end

						update_distance_text_style(widget, fs)
					end
				end
			end
		end

		if raycasts_allowed then
			self:_raycast_markers(temp_marker_raycast_queue)
			table.clear(temp_marker_raycast_queue)
		end

		if fs.mod_enabled and mod._spillway_route_frame ~= mod._aio_frame and mod.update_spillway_path_route then
			mod._spillway_route_frame = mod._aio_frame
			mod.update_spillway_path_route(dt)
		end

		if fs.mod_enabled and fs.proximity_enable and mod.update_proximity_notifications then
			mod.update_proximity_notifications(self, dt, t)
		end
	else
		get_valid_world_marker_camera(self)
	end

	local markers_to_remove = #temp_array_markers_to_remove

	if markers_to_remove > 0 then
		for i = 1, markers_to_remove do
			local marker = temp_array_markers_to_remove[i]
			self:_unregister_marker(marker)
		end

		table.clear(temp_array_markers_to_remove)
	end
end

local HudElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local HudElementInteraction = require("scripts/ui/hud/elements/interaction/hud_element_interaction")

local DEFAULT_HUD_INTERACTION_MAX_SPAWN_DISTANCE_SQ = HudElementInteractionSettings.max_spawn_distance_sq

local function interaction_marker_spawn_distance_sq(interactee_unit, extension)
	local max_distance_sq = HUDElementInteractionSettings
			and tonumber(HUDElementInteractionSettings.max_spawn_distance_sq)
		or 3600
	local fs = mod.frame_settings

	local is_health_station = extension and extension._active_interaction_type == "health_station"
		or interactee_unit and has_extension(interactee_unit, "health_station_system")

	if is_health_station then
		local med_max_distance = tonumber(fs and fs.med_station_max_distance)

		if med_max_distance then
			max_distance_sq = med_max_distance * med_max_distance
		end
	end

	return max_distance_sq
end

HudElementInteraction._update_interactee_data = function(self, interactee_unit, extension)
	local parent = self._parent
	local player = parent:player()
	local player_unit = get_player_unit(player)
	local camera = get_valid_hud_camera(parent)
	local camera_position = camera and Camera.local_position(camera)

	local is_active = extension:active()
	local is_other_unit = interactee_unit ~= player_unit

	local render_marker = is_active and is_other_unit and extension:show_marker(player_unit)

	if is_other_unit and is_active and not render_marker and not extension._active_interaction_type then
		local health_station_extension = has_extension(interactee_unit, "health_station_system")

		if health_station_extension then
			local has_charges = health_station_extension._charge_amount and health_station_extension._charge_amount > 0
			local battery_plugged = health_station_extension.battery_in_slot ~= nil
				and health_station_extension:battery_in_slot()
			render_marker = has_charges or not battery_plugged
		end
	end

	local interaction_units = self._interaction_units
	local marker = nil

	local max_spawn_distance_sq = interaction_marker_spawn_distance_sq(interactee_unit, extension)

	if interactee_unit ~= player_unit and render_marker and camera_position then
		local interactee_position = Unit.world_position(interactee_unit, 1)
		local distance_sq = vector_distance_squared(interactee_position, camera_position)

		render_marker = distance_sq <= max_spawn_distance_sq
	end

	if render_marker then
		if not interaction_units[interactee_unit] then
			interaction_units[interactee_unit] = {
				extension = nil,
				marker_id = nil,
				requested = true,
				extension = extension,
			}

			local marker_callback = callback(self, "_on_interaction_marker_spawned", interactee_unit)
			local marker_type = "interaction"

			Managers.event:trigger("add_world_marker_unit", marker_type, interactee_unit, marker_callback, extension)
		end
	elseif interaction_units[interactee_unit] then
		local decoder_ext = has_extension(interactee_unit, "decoder_device_system")
		local is_decoder_device = decoder_ext and decoder_ext:unit_is_enabled() and not decoder_ext:is_finished()

		if not is_decoder_device then
			local marker_id = interaction_units[interactee_unit].marker_id

			if marker_id then
				Managers.event:trigger("remove_world_marker", marker_id)
				interaction_units[interactee_unit] = nil
			end
		end
	end
end

mod.auspex_active = false
mod:hook_safe(CLASS.AuspexEffects, "wield", function(self)
	if self._is_husk then
		return
	end
	mod.auspex_active = true
end)

mod:hook_safe(CLASS.AuspexEffects, "unwield", function(self)
	if self._is_husk then
		return
	end
	mod.auspex_active = false
end)

mod.fade_icon_not_in_los = function(marker, ui_renderer, pt)
	if not marker.markers_aio_type then
		return
	end

	local widget = marker.widget
	if not widget then
		return
	end

	local fs = mod.frame_settings
	pt = pt or fs.per_type[marker.markers_aio_type]
	local mod_alpha = pt and pt.alpha or 1
	local mod_max_distance = pt and pt.max_distance or 30

	-- force increase max distance of marker if tagged
	local is_tagged = marker.widget and marker.widget.content and marker.widget.content.tagged
	if is_tagged then
		mod_max_distance = 100
	end

	local base_alpha = mod_alpha

	------------------------------------------------
	-- Distance-based alpha
	------------------------------------------------
	local distance_factor = 1

	if mod_max_distance and marker.distance then
		local d = math.clamp(marker.distance / mod_max_distance, 0, 1)

		if d >= 0.75 then
			local t = (d - 0.75) / 0.25
			t = math.clamp(t, 0, 1)

			t = t * t * (3 - 2 * t)

			distance_factor = 1 - t
		else
			distance_factor = 1
		end
	end

	local target_alpha = base_alpha * distance_factor

	local has_raycast = marker.raycast_result ~= nil
	local is_out_of_los = (not has_raycast) or marker.raycast_result == true

	if fs.los_enabled and is_out_of_los then
		target_alpha = target_alpha * (fs.los_opacity or 1)
	end

	if fs.is_ads then
		target_alpha = target_alpha * (fs.ads_los_opacity or 1)
	end

	if mod.auspex_active then
		target_alpha = 0.05
	end

	if marker.ammo_status_dim then
		target_alpha = target_alpha * 0.5
	end

	local current = marker.aio_fade_alpha or widget.alpha_multiplier or target_alpha
	widget.alpha_multiplier = math.lerp(current, target_alpha, 0.8)
	marker.aio_fade_alpha = widget.alpha_multiplier

	return target_alpha
end

local do_draw = function(marker)
	marker.draw = true
end

local dont_draw = function(marker, pt)
	if not marker then
		return
	end
	pt = pt or mod.frame_settings.per_type[marker.markers_aio_type]
	local mod_keep_on_screen = pt and pt.keep_on_screen
	local is_tagged = marker.widget and marker.widget.content and marker.widget.content.tagged

	if marker.is_inside_frustum then
		if is_tagged then
			marker.draw = true
		else
			marker.draw = false
		end
	elseif is_tagged and mod_keep_on_screen then
		marker.draw = true
	else
		marker.draw = false
	end
end

mod.adjust_los_requirement = function(marker, pt)
	if not marker.markers_aio_type then
		return
	end

	pt = pt or mod.frame_settings.per_type[marker.markers_aio_type]
	local mod_require_los = marker.aio_check_line_of_sight
	if mod_require_los == nil then
		mod_require_los = pt and pt.require_line_of_sight
	end
	local mod_keep_on_screen = pt and pt.keep_on_screen
	local is_tagged = marker.widget and marker.widget.content and marker.widget.content.tagged
	local is_blocked = not marker.raycast_result

	if mod_require_los then
		if marker.is_inside_frustum then
			if is_blocked or is_tagged then
				do_draw(marker)
			else
				dont_draw(marker, pt)
			end
		elseif (is_blocked and mod_keep_on_screen) or (is_tagged and mod_keep_on_screen) then
			do_draw(marker)
		else
			dont_draw(marker, pt)
		end
	else
		if (marker.is_inside_frustum or mod_keep_on_screen) or (marker.is_inside_frustum and is_tagged) then
			do_draw(marker)
		else
			dont_draw(marker, pt)
		end
	end
end

local SCALE_EPSILON = 0.001
local SCALE_SNAP_EPSILON = 0.005
local SCALE_LERP_MULTIPLIER = 0.2
local math_abs = math.abs
local math_lerp = math.lerp

mod.adjust_scale = function(self, marker, ui_renderer, t, pt)
	local widget = marker.widget
	local template = marker.template
	local settings = template.scale_settings

	if not settings then
		return
	end

	local distance = marker.distance
	local scale = 1

	if marker.markers_aio_type then
		pt = pt or mod.frame_settings.per_type[marker.markers_aio_type]
		scale = (pt and pt.scale or 100) * 0.01
	end

	local target = compute_marker_scale(settings, distance)

	if marker.ignore_scale then
		target = 1
	else
		target = target * scale
	end

	if marker.servo_skull_pulse and t then
		target = target * (1 + (math.sin(t * math.pi * 4) + 1) * 0.1)
	end

	marker.scale = target

	if marker._aio_scale_target ~= target then
		marker._aio_scale_target = target
	end

	self:_apply_scale(widget, target)
end

local function cache_widget_scale_styles(widget)
	local styles = widget.style
	local cache = {}

	for _, pass_style in pairs(styles) do
		local size = pass_style.area_size or pass_style.texture_size or pass_style.size

		if pass_style.default_size and size then
			cache[#cache + 1] = {
				size = size,
				default_size = pass_style.default_size,
			}
		end

		if pass_style.default_offset and pass_style.offset then
			cache[#cache + 1] = {
				offset = pass_style.offset,
				default_offset = pass_style.default_offset,
			}
		end

		if pass_style.default_pivot and pass_style.pivot then
			cache[#cache + 1] = {
				pivot = pass_style.pivot,
				default_pivot = pass_style.default_pivot,
			}
		end
	end

	widget._aio_scale_styles = cache
end

HudElementWorldMarkers._apply_scale = function(self, widget, scale)
	local cache = widget._aio_scale_styles

	if not cache then
		cache_widget_scale_styles(widget)
		cache = widget._aio_scale_styles
	end

	if not cache then
		return
	end

	local applied_scale = widget._aio_applied_scale
	local scale_difference = applied_scale and math_abs(applied_scale - scale) or math.huge

	if scale_difference < SCALE_EPSILON then
		return
	end

	local snap = scale_difference < SCALE_SNAP_EPSILON

	for i = 1, #cache do
		local entry = cache[i]

		if entry.size then
			local size = entry.size
			local default = entry.default_size
			local target_1 = default[1] * scale
			local target_2 = default[2] * scale

			size[1] = snap and target_1 or math_lerp(size[1], target_1, SCALE_LERP_MULTIPLIER)
			size[2] = snap and target_2 or math_lerp(size[2], target_2, SCALE_LERP_MULTIPLIER)
		elseif entry.offset then
			local offset = entry.offset
			local default = entry.default_offset
			local target_1 = default[1] * scale
			local target_2 = default[2] * scale

			offset[1] = snap and target_1 or math_lerp(offset[1], target_1, SCALE_LERP_MULTIPLIER)
			offset[2] = snap and target_2 or math_lerp(offset[2], target_2, SCALE_LERP_MULTIPLIER)
		elseif entry.pivot then
			local pivot = entry.pivot
			local default = entry.default_pivot
			local target_1 = default[1] * scale
			local target_2 = default[2] * scale

			pivot[1] = snap and target_1 or math_lerp(pivot[1], target_1, SCALE_LERP_MULTIPLIER)
			pivot[2] = snap and target_2 or math_lerp(pivot[2], target_2, SCALE_LERP_MULTIPLIER)
		end
	end

	widget._aio_applied_scale = scale
end

mod.adjust_distance_visibility = function(marker, pt)
	if not marker.markers_aio_type then
		return
	end

	pt = pt or mod.frame_settings.per_type[marker.markers_aio_type]
	local mod_max_distance = marker_max_distance(marker, nil, pt)

	if mod_max_distance and marker.distance > mod_max_distance then
		dont_draw(marker, pt)
	end
end

mod.ammo_med_toggle_los = function()
	mod.toggle_los("ammo_med")
end

mod.chest_toggle_los = function()
	mod.toggle_los("chest")
end

mod.heretical_idol_toggle_los = function()
	mod.toggle_los("heretical_idol")
end

mod.material_toggle_los = function()
	mod.toggle_los("material")
end

mod.stimm_toggle_los = function()
	mod.toggle_los("stimm")
end

mod.tome_toggle_los = function()
	mod.toggle_los("tome")
end

mod.event_toggle_los = function()
	mod.toggle_los("event")
end

mod.luggable_toggle_los = function()
	mod.toggle_los("luggable")
end

mod.martyrs_skull_toggle_los = function()
	mod.toggle_los("martyrs_skull")
end

mod.servo_skull_toggle_los = function()
	mod.toggle_los("servo_skull")
end

mod.objective_toggle_los = function()
	mod.toggle_los("objective")
end

mod.toggle_los = function(marker_type)
	if marker_type then
		if mod:get(marker_type .. "_require_line_of_sight") == false then
			mod:set(marker_type .. "_require_line_of_sight", true)
		else
			mod:set(marker_type .. "_require_line_of_sight", false)
		end
	end
end

local MOD_MARKER_TYPES = {
	nurgle_totem = true,
	heretical_idol = true,
	med_marker = true,
	chest_item_marker = true,
	martyrs_skull = true,
	martyrs_skull_guide = true,
}

mod.remove_mod_markers = function()
	local ui_manager = Managers.ui
	local hud = ui_manager and ui_manager:get_hud()
	local world_markers = hud and hud:element("HudElementWorldMarkers")
	local markers = world_markers and world_markers._markers

	if markers then
		for i = #markers, 1, -1 do
			local marker = markers[i]

			if marker and marker.id and (marker.markers_aio_type or MOD_MARKER_TYPES[marker.type]) then
				Managers.event:trigger("remove_world_marker", marker.id)
			end
		end
	end

	mod.totem_units = {}
	mod.current_heretical_idol_markers = {}
	mod.active_chests = {}
	mod.medical_crate_charges = {}
end

local MARKER_VISUAL_CACHE_FIELDS = {
	"ui_interaction_type",
	"ui_target_type",
	"visual_type",
	"_aio_pickup_type",
	"aio_proximity_subtype",
}

local MARKER_RESET_FIELDS = {
	"block_screen_clamp",
	"block_max_distance",
	"block_fade_settings",
	"max_distance",
}

mod.reset_marker_visuals = function()
	local ui_manager = Managers.ui
	local hud = ui_manager and ui_manager:get_hud()
	local world_markers = hud and hud:element("HudElementWorldMarkers")
	local markers = world_markers and world_markers._markers

	if not markers then
		return
	end

	local marker_templates = world_markers._marker_templates

	for i = 1, #markers do
		local marker = markers[i]

		if marker then
			for j = 1, #MARKER_VISUAL_CACHE_FIELDS do
				marker[MARKER_VISUAL_CACHE_FIELDS[j]] = nil
			end

			for j = 1, #MARKER_RESET_FIELDS do
				marker[MARKER_RESET_FIELDS[j]] = nil
			end

			local base_template = marker.type and marker_templates and marker_templates[marker.type]

			if base_template then
				marker.template = table.clone(base_template)
			end
		end
	end
end

mod.on_disabled = function(initial_call)
	HudElementInteractionSettings.max_spawn_distance_sq = DEFAULT_HUD_INTERACTION_MAX_SPAWN_DISTANCE_SQ
	mod.remove_mod_markers()
	mod.reset_marker_visuals()
end

mod.on_enabled = function(initial_call)
	mod.remove_mod_markers()
end

mod.on_setting_changed = function(setting_id)
	mod._frame_settings_dirty = true

	if mod.update_pickup_name_settings then
		mod.update_pickup_name_settings(setting_id)
	end

	if not setting_id then
		return
	end

	if setting_id == "martyrs_skull_guide_x_offset" or setting_id == "martyrs_skull_guide_y_offset" then
		local hud = Managers.ui and Managers.ui:get_hud()
		if not hud then
			return
		end
		local element = hud._elements and hud._elements["MartyrsSkullGuideElement"]
		if element then
			element:set_guide_offset(
				mod:get("martyrs_skull_guide_x_offset") or 0,
				mod:get("martyrs_skull_guide_y_offset") or 0
			)
		end
		return
	end

	if
		string.find(setting_id, "_colour_R")
		or string.find(setting_id, "_colour_G")
		or string.find(setting_id, "_colour_B")
	then
		local dmf = get_mod("DMF")
		local mod_name = mod:get_name()

		local base_key = string.gsub(setting_id, "_R$", "")
		base_key = string.gsub(base_key, "_G$", "")
		base_key = string.gsub(base_key, "_B$", "")

		local old_title = mod:localize(base_key)
		local new_title = nil

		local updated_localization = mod.apply_colours()

		for id, data in pairs(updated_localization) do
			if id == base_key then
				local lang = Managers.localization:language()
				local text = data[lang] or data.en

				new_title = text
			end
		end

		if not new_title then
			return
		end

		for i, mod_data in ipairs(dmf.options_widgets_data) do
			if mod_data[1] and mod_data[1].mod_name == mod_name then
				for j = 1, #mod_data do
					if mod_data[j].setting_id == base_key then
						mod_data[j].title = new_title
						break
					end
				end
			end
		end

		local view = Managers.ui:view_instance("dmf_options_view")

		if view and view._settings_category_widgets and view._settings_category_widgets[mod:localize("mod_name")] then
			for _, data in ipairs(view._settings_category_widgets[mod:localize("mod_name")]) do
				local widget = data.widget
				if not widget or not widget.content.text then
					break
				end

				local clean = string.gsub(new_title, "{#.-}", "")
				local clean2 = string.gsub(widget.content.text, "{#.-}", "")

				if clean == clean2 then
					if widget.content.entry then
						widget.content.entry.display_name = new_title
					end
					widget.content.text = new_title
					break
				end
			end
		end
	end
end

mod._needs_totem_scan = true
