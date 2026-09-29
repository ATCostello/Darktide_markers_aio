local mod = get_mod("markers_aio")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local fs = mod.frame_settings
local function _player_needs_help(unit_data_extension)
	if not unit_data_extension then
		return false
	end

	local character_state_component = unit_data_extension:read_component("character_state")
	if not character_state_component then
		return false
	end

	if not PlayerUnitStatus.requires_allied_interaction_help(character_state_component) then
		return false
	end

	--if PlayerUnitStatus.is_ledge_hanging(character_state_component) then
	--	return false
	--end

	return true
end

local function _player_is_assisted(unit_data_extension)
	if not unit_data_extension then
		return false
	end

	local assisted_state_input_component = unit_data_extension:read_component("assisted_state_input")
	if not assisted_state_input_component then
		return false
	end

	return PlayerUnitStatus.is_assisted(assisted_state_input_component)
end

mod.update_player_assistance_markers = function(self, marker)
	if marker and self then
		local unit = marker.unit
		if not unit or type(unit) ~= "userdata" or not Unit.alive(unit) then
			return
		end

		local needs_help = false
		local is_assisted = false
		local skull_is_injecting = false

		local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")

		if unit_data_extension and Managers.player:player_by_unit(unit) then
			needs_help = _player_needs_help(unit_data_extension)
			is_assisted = _player_is_assisted(unit_data_extension)
		end

		if fs and fs.servo_skull_equipped and fs.inject_ally and fs.servo_skull_injecting then
			skull_is_injecting = true
		end

		if not needs_help and not skull_is_injecting then
			return
		end

		local widget = marker.widget
		if not widget or not widget.style or not widget.style.background then
			return
		end

		marker.draw = false
		widget.alpha_multiplier = 0
		widget.visible = true

		marker.markers_aio_type = "player_assistance"

		mod.set_colour(widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))
		marker.template.check_line_of_sight = fs.per_type[marker.markers_aio_type].require_line_of_sight
		marker.template.max_distance = fs.per_type[marker.markers_aio_type].max_distance
		marker.template.screen_clamp = fs.per_type[marker.markers_aio_type].keep_on_screen
		marker.block_screen_clamp = false

		widget.content.icon = fs.player_assistance_icon

		local character_state_component = unit_data_extension and unit_data_extension:read_component("character_state")
			or nil
		if character_state_component and PlayerUnitStatus.is_ledge_hanging(character_state_component) then
			--
		elseif fs and fs.servo_skull_equipped then
			widget.content.icon = fs.player_assistance_servo_skull_icon
		end

		marker.template.icon_min_size[1] = 36
		marker.template.icon_min_size[2] = 36
		marker.template.icon_max_size[1] = 48
		marker.template.icon_max_size[2] = 48

		local colour_type = "player_assistance_default"
		local border_key = "player_assistance_border_colour"
		marker.player_assistance_pulse = false

		if skull_is_injecting or is_assisted then
			colour_type = "player_assistance_active"
			border_key = "player_assistance_active_border_colour"
			marker.player_assistance_pulse = false
		elseif needs_help then
			colour_type = "player_assistance_stalled"
			border_key = "player_assistance_stalled_border_colour"
			marker.player_assistance_pulse = fs.player_assistance_pulse_when_stalled
		end

		if widget.style.ring then
			mod.set_colour(widget.style.ring.color, mod.lookup_colour(fs[border_key]))
		end

		mod.set_colour_argb(
			widget.style.icon.color,
			255,
			fs[colour_type .. "_colour_R"],
			fs[colour_type .. "_colour_G"],
			fs[colour_type .. "_colour_B"]
		)

		marker.draw = true
		if not widget.removed then
			widget.alpha_multiplier = 1
		end
	end
end
