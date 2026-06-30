local mod = get_mod("markers_aio")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")

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

local function _is_decoder_active(minigame_extension)
	if not minigame_extension then
		return false
	end
	return minigame_extension:is_active()
end

mod.update_servo_skull_markers = function(self, marker)
	if marker and self then
		local fs = mod.frame_settings
		local unit = marker.unit
		if not unit or type(unit) ~= "userdata" or not Unit.alive(unit) then
			return
		end

		local interactee_extension = ScriptUnit.has_extension(unit, "interactee_system")
		local interaction_type = interactee_extension and interactee_extension:interaction_type()
		local decoder_ext = ScriptUnit.has_extension(unit, "decoder_device_system")
		local is_decoding_terminal = decoder_ext and decoder_ext:unit_is_enabled() and not decoder_ext:is_finished()

		local needs_help = false
		local is_assisted = false
		local skull_is_injecting = false

		local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")

		if not is_decoding_terminal then
			if unit_data_extension and Managers.player:player_by_unit(unit) then
				needs_help = _player_needs_help(unit_data_extension)
				is_assisted = _player_is_assisted(unit_data_extension)
			end

			if fs and fs.servo_skull_equipped and fs.inject_ally and fs.servo_skull_injecting then
				skull_is_injecting = true
			end
		end

		if not is_decoding_terminal and not needs_help and not skull_is_injecting then
			return
		end

		if
			not is_decoding_terminal
			and (needs_help or is_assisted)
			and (fs and not fs.enable.servo_skull_enable_assistance_module)
		then
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

		local character_state_component = unit_data_extension and unit_data_extension:read_component("character_state")
			or nil
		if character_state_component and PlayerUnitStatus.is_ledge_hanging(character_state_component) then
			--
		elseif not is_decoding_terminal and fs and fs.servo_skull_equipped then
			widget.content.icon = mod:get("servo_skull_icon")
		elseif is_decoding_terminal then
			widget.content.icon = mod:get("decoding_icon")
		end

		marker.template.icon_min_size[1] = 36
		marker.template.icon_min_size[2] = 36
		marker.template.icon_max_size[1] = 48
		marker.template.icon_max_size[2] = 48

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
					if fs and fs.servo_skull_equipped then
						widget.content.icon = mod:get("servo_skull_icon")
					end
				elseif
					decoder_extension:started_decode()
					and not decoder_extension:is_finished()
					and decoder_extension:is_minigame_active()
				then
					colour_type = "servo_skull_active"
					border_key = "servo_skull_active_border_colour"
					marker.servo_skull_pulse = false
					if fs and fs.servo_skull_equipped then
						widget.content.icon = mod:get("servo_skull_icon")
					end
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
		elseif skull_is_injecting or is_assisted then
			colour_type = "servo_skull_active"
			border_key = "servo_skull_active_border_colour"
			marker.servo_skull_pulse = false
		elseif needs_help then
			colour_type = "servo_skull_stalled"
			border_key = "servo_skull_stalled_border_colour"
			marker.servo_skull_pulse = mod:get("servo_skull_pulse_when_stalled")
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
