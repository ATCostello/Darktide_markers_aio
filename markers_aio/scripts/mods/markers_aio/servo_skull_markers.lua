local mod = get_mod("markers_aio")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")

local function _is_player_downed_and_injectable(marker_unit)
	local unit_data_extension = ScriptUnit.has_extension(marker_unit, "unit_data_system")
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

	if PlayerUnitStatus.is_ledge_hanging(character_state_component) then
		return false
	end

	local assisted_state_input_component = unit_data_extension:read_component("assisted_state_input")
	if not assisted_state_input_component then
		return false
	end

	if PlayerUnitStatus.is_assisted(assisted_state_input_component) then
		return false
	end

	return true
end

local function _is_decoder_active(minigame_extension)
	if not minigame_extension then
		return false
	end
	return minigame_extension:is_active()
end

mod.update_servo_skull_markers = function(self, marker)
	if marker and self then
		local fs = mod.frame_settings
		if not fs or not fs.servo_skull_equipped then
			if marker.widget then
				marker.draw = false
				marker.widget.alpha_multiplier = 0
			end
			return
		end

		local unit = marker.unit
		if not unit or not Unit.alive(unit) then
			return
		end

		local interactee_extension = ScriptUnit.has_extension(unit, "interactee_system")
		local interaction_type = interactee_extension and interactee_extension:interaction_type()
		local decoder_ext = ScriptUnit.has_extension(unit, "decoder_device_system")
		local is_decoding_terminal = decoder_ext and decoder_ext:unit_is_enabled() and not decoder_ext:is_finished()
		local is_injectable_player = false

		if not is_decoding_terminal and Managers.player:player_by_unit(unit) then
			is_injectable_player = _is_player_downed_and_injectable(unit)
		end

		if not is_decoding_terminal and not is_injectable_player then
			return
		end

		local widget = marker.widget
		if not widget or not widget.style or not widget.style.background then
			return
		end

		marker.draw = false
		widget.alpha_multiplier = 0
		widget.visible = true

		marker.markers_aio_type = "servo_skull"

		mod.set_colour(widget.style.background.color, mod.lookup_colour(mod:get("marker_background_colour")))
		marker.template.check_line_of_sight = mod:get(marker.markers_aio_type .. "_require_line_of_sight")
		marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
		marker.template.screen_clamp = mod:get(marker.markers_aio_type .. "_keep_on_screen")
		marker.block_screen_clamp = false

		widget.content.icon = mod:get("servo_skull_icon")
		marker.template.icon_min_size = { 36, 36 }
		marker.template.icon_max_size = { 48, 48 }

		local decoder_extension = ScriptUnit.has_extension(unit, "decoder_device_system")
		local minigame_extension = ScriptUnit.has_extension(unit, "minigame_system")
		local colour_type = "servo_skull_default"
		local border_key = "servo_skull_border_colour"
		marker.servo_skull_pulse = false

		if is_decoding_terminal then
			if decoder_extension then
				if decoder_extension:wait_for_restart() then
					colour_type = "servo_skull_stalled"
					border_key = "servo_skull_stalled_border_colour"
					marker.servo_skull_pulse = mod:get("servo_skull_pulse_when_stalled")
				elseif
					decoder_extension:started_decode()
					and not decoder_extension:is_finished()
					and decoder_extension:is_minigame_active()
				then
					colour_type = "servo_skull_active"
					border_key = "servo_skull_active_border_colour"
					marker.servo_skull_pulse = false
				end
			else
				local player = Managers.player:local_player(1)
				local player_unit = player and player.player_unit

				if minigame_extension and _is_decoder_active(minigame_extension) then
					colour_type = "servo_skull_active"
					border_key = "servo_skull_active_border_colour"
					marker.servo_skull_pulse = false
				elseif player_unit and interactee_extension and interactee_extension:show_marker(player_unit) then
					colour_type = "servo_skull_stalled"
					border_key = "servo_skull_stalled_border_colour"
					marker.servo_skull_pulse = mod:get("servo_skull_pulse_when_stalled")
				end
			end
		elseif is_injectable_player then
			local inject = fs.inject_ally
			local injecting = fs.servo_skull_injecting

			if inject then
				if injecting then
					colour_type = "servo_skull_active"
					border_key = "servo_skull_active_border_colour"
					marker.servo_skull_pulse = false
				else
					colour_type = "servo_skull_stalled"
					border_key = "servo_skull_stalled_border_colour"
					marker.servo_skull_pulse = mod:get("servo_skull_pulse_when_stalled")
				end
			end
		end

		if widget.style.ring then
			mod.set_colour(widget.style.ring.color, mod.lookup_colour(mod:get(border_key)))
		end
		mod.set_colour_argb(
			widget.style.icon.color,
			255,
			mod:get(colour_type .. "_colour_R"),
			mod:get(colour_type .. "_colour_G"),
			mod:get(colour_type .. "_colour_B")
		)

		marker.draw = true
		if not widget.removed then
			widget.alpha_multiplier = 1
		end
	end
end
