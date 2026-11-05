local mod = get_mod("markers_aio")
local has_extension = ScriptUnit.has_extension
local UISettings = require("scripts/settings/ui/ui_settings")
local HudElementSmartTagging = require("scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging")

HudElementSmartTagging._is_marker_valid_for_tagging = function(self, player_unit, marker, distance)
	local template = marker.template

	if template.using_smart_tag_system and not template.get_smart_tag_id then
		return false
	end

	if not template.using_smart_tag_system then
		local unit = marker.unit
		if unit and type(unit) == "userdata" and Unit.alive(unit) then
			local ie = has_extension(unit, "interactee_system")
			if not (ie and ie:interaction_type() == "decoding") then
				return false
			end
		else
			return false
		end
	end

	local marker_unit = marker.unit
	local smart_tag_extension = marker_unit and has_extension(marker_unit, "smart_tag_system")
	local tag_id = template.get_smart_tag_id and template.get_smart_tag_id(marker)

	if marker_unit and not smart_tag_extension and not tag_id then
		if marker.markers_aio_type then
			--
		else
			local ie = has_extension(marker_unit, "interactee_system")
			if not (ie and ie:interaction_type() == "decoding") then
				return false
			end
		end
	end

	local in_line_of_sight = not marker.raycast_result

	if not tag_id and not in_line_of_sight then
		if marker.markers_aio_type then
			local check_los = marker.aio_check_line_of_sight
			if check_los == nil then
				local fs = mod.frame_settings
				local pt = fs.per_type[marker.markers_aio_type]
				check_los = pt and pt.require_line_of_sight
			end
			if check_los ~= false then
				return false
			end
		else
			local ie = has_extension(marker_unit, "interactee_system")
			if not (ie and ie:interaction_type() == "decoding") then
				return false
			end
		end
	end

	if not marker.is_inside_frustum or marker.is_clamped then
		return false
	end

	if not tag_id then
		if smart_tag_extension and not smart_tag_extension:can_tag(player_unit) then
			return false
		end

		local max_distance = template.max_distance

		if max_distance and distance and max_distance <= distance then
			return false
		end
	end

	return true
end

HudElementSmartTagging._handle_selected_marker = function(self, marker)
	local marker_template = marker.template
	local tag_id = marker_template.get_smart_tag_id and marker_template.get_smart_tag_id(marker)
	if tag_id then
		self:_trigger_smart_tag_interaction(tag_id)
	else
		local marker_unit = marker.unit
		if marker_unit then
			self:_trigger_smart_tag_unit_contextual(marker_unit)
		end
	end
end

HudElementSmartTagging._handle_interaction_draw = function(self, dt, t, input_service, ui_renderer, render_settings)
	local can_present_tag_interaction = self:_can_present_tag_interaction()

	if not can_present_tag_interaction then
		self._active_interaction_data = nil

		return
	end

	if self._interaction_scan_delay_duration > 0 then
		self._interaction_scan_delay_duration = self._interaction_scan_delay_duration - dt
	else
		local force_update_targets = false
		local best_marker, best_unit, _ =
			self:_find_best_smart_tag_interaction(ui_renderer, render_settings, force_update_targets)
		local parent = self._parent
		local player = parent:player()
		local player_unit = player.player_unit
		local smart_tag_system = Managers.state.extension:system("smart_tag_system")
		local previous_active_interaction_data = self._active_interaction_data

		if not best_marker and best_unit then
			local marker = self:_find_marker_by_unit(best_unit)

			best_marker = marker
		end

		if best_marker then
			if not previous_active_interaction_data or previous_active_interaction_data.marker ~= best_marker then
				local marker_id = best_marker.id
				local smart_tag_presentation_data = self._presented_smart_tags_by_marker_id[marker_id]
				local tag_id = smart_tag_presentation_data and smart_tag_presentation_data.tag_id
				local tag_template, display_name

				if tag_id then
					local tag = smart_tag_system:tag_by_id(tag_id)

					if tag then
						display_name = tag:display_name()
						tag_template = tag:template()
					end
				end

				if display_name == "n/a" then
					display_name = nil
				end

				if not display_name then
					local marker_unit = best_marker.unit
					local smart_tag_extension = marker_unit and has_extension(marker_unit, "smart_tag_system")

					if smart_tag_extension then
						tag_template = smart_tag_extension:contextual_tag_template(player_unit)
						display_name = smart_tag_extension:display_name(player_unit)

						if display_name == "n/a" then
							display_name = nil
						end
					end

					if not display_name and best_marker.markers_aio_type then
						local aio_type = best_marker.markers_aio_type

						if aio_type == "chest" then
							display_name = "mod_marker_chest_name"
						elseif aio_type == "ammo_med" then
							if
								best_marker.data and best_marker.data._active_interaction_type == "health_station"
								or best_marker.unit and has_extension(best_marker.unit, "health_station_system")
							then
								display_name = "mod_marker_medicae_station_name"
							else
								local pickup_type = mod.get_marker_pickup_type(best_marker)
									or (best_marker.data and best_marker.data.type)

								if pickup_type == "medical_crate_deployable" then
									display_name = "loc_pickup_pocketable_medical_crate_01"
								else
									display_name = "mod_marker_item_name"
								end
							end
						elseif aio_type == "heretical_idol" then
							display_name = "mod_marker_heretical_idol_name"
						elseif aio_type == "stimm" then
							local pickup_type = mod.get_marker_pickup_type(best_marker)
								or (best_marker.data and best_marker.data.type)

							if pickup_type == "syringe_power_boost_pocketable" then
								display_name = "mod_marker_power_stimm_name"
							elseif pickup_type == "syringe_speed_boost_pocketable" then
								display_name = "mod_marker_speed_stimm_name"
							elseif pickup_type == "syringe_ability_boost_pocketable" then
								display_name = "mod_marker_boost_stimm_name"
							elseif pickup_type == "syringe_corruption_pocketable" then
								display_name = "mod_marker_medic_stimm_name"
							elseif pickup_type == "syringe_broker_pocketable" then
								display_name = "mod_marker_broker_stimm_name"
							else
								display_name = "mod_marker_stimm_name"
							end
						elseif aio_type == "martyrs_skull" then
							display_name = best_marker.guide_step_text or "mod_marker_item_name"
						elseif aio_type == "tome" then
							display_name = "mod_marker_tome_name"
						elseif aio_type == "material" then
							display_name = "mod_marker_material_name"
						elseif aio_type == "luggable" then
							display_name = "mod_marker_luggable_name"
						elseif aio_type == "expedition" then
							display_name = "mod_marker_expedition_name"
						elseif aio_type == "event" then
							display_name = "mod_marker_event_name"
						elseif aio_type == "servo_skull" then
							display_name = "mod_marker_servo_skull_name"
						elseif aio_type == "unknown" then
							display_name = "mod_marker_unknown_name"
						elseif aio_type == "spillway_path" then
							display_name = "mod_marker_spillway_path_name"
						else
							display_name = "mod_marker_item_name"
						end

						tag_template = {}
					end
				end

				if not display_name then
					display_name = "mod_marker_item_name"
				end

				self._active_interaction_data = {
					display_name = display_name,
					intro_anim_duration = 0.2,
					intro_anim_progress = 0,
					intro_anim_time = 0,
					marker = best_marker,
					marker_id = best_marker.id,
					tag_id = tag_id,
					tag_template = tag_template,
					unit = best_unit or best_marker.unit,
				}
			end
		else
			self._active_interaction_data = nil
		end

		self._interaction_scan_delay_duration = self._interaction_scan_delay
	end

	self:_update_tags_interaction_hover_status()

	local active_interaction_data = self._active_interaction_data
	local marker = active_interaction_data and active_interaction_data.marker

	if marker and marker.deleted then
		self._active_interaction_data = nil
	elseif marker then
		self:_update_tag_interaction_information(active_interaction_data)
		self:_update_tag_interaction_animation(dt, t)
		self:_draw_active_interaction_line(dt, t, input_service, ui_renderer, render_settings)
	end
end

mod:hook_safe(HudElementSmartTagging, "_update_tag_interaction_information", function(self, data)
	if data and data.marker then
		local widget = self._interaction_line_widget
		if widget and widget.content then
			local ammo_fs = mod.frame_settings
			local status = data.marker.ammo_status
			local show_ammo_info = data.marker.markers_aio_type == "ammo_med"
				and status
				and ammo_fs
				and ammo_fs.ammo_status_enable
				and ammo_fs.ammo_status_numeric_enable
				and ammo_fs.ammo_status_popup_text_enable
				and (ammo_fs.ammo_status_show_gain or ammo_fs.ammo_status_show_waste)

			local description_style = widget.style and widget.style.description_text

			if show_ammo_info and status.colour and description_style and description_style.text_color then
				if not mod._tag_description_default_colour then
					mod._tag_description_default_colour = table.clone(description_style.text_color)
				end

				local color = description_style.text_color
				--color[1] = 255
				--color[2] = status.colour[1]
				--color[3] = status.colour[2]
				--color[4] = status.colour[3]
			elseif
				not show_ammo_info
				and mod._tag_description_default_colour
				and description_style
				and description_style.text_color
			then
				local color = description_style.text_color
				local default_colour = mod._tag_description_default_colour

				for i = 2, math.min(#color, #default_colour) do
					--color[i] = default_colour[i]
				end
			end

			if data.marker.guide_step_text then
				widget.content.description_text = data.marker.guide_step_text
			elseif data.marker.markers_aio_type and data.display_name then
				if show_ammo_info then
					local description_text = Localize(data.display_name)

					local numeric_parts = {}

					if status.status == "teammate" and status.needy_player then
						local needy = status.needy_player
						local needy_slot = needy.player and needy.player:slot() or needy.slot
						local needy_colour = UISettings.player_slot_colors[needy_slot]

						numeric_parts[#numeric_parts + 1] = string.format(
							"{#color(%d,%d,%d)}%s{#reset()}",
							needy_colour and needy_colour[2] or 255,
							needy_colour and needy_colour[3] or 255,
							needy_colour and needy_colour[4] or 255,
							needy.icon
						) .. " (+" .. math.ceil((needy.percentage or 0) * 100) .. "%)"
					end

					if ammo_fs.ammo_status_show_gain and status.gain then
						numeric_parts[#numeric_parts + 1] = mod.ammo_status_colour_markup("+" .. status.gain, "gain")
					end

					if ammo_fs.ammo_status_show_waste and status.waste then
						numeric_parts[#numeric_parts + 1] =
							mod.ammo_status_colour_markup("(-" .. status.waste .. ")", "waste")
					end

					if #numeric_parts > 0 then
						description_text = description_text .. "  " .. table.concat(numeric_parts, " ")
					end

					local marker_distance = data.marker and data.marker.distance
					local distance_text = marker_distance
							and marker_distance > 1
							and tostring(math.floor(marker_distance)) .. "m"
						or ""

					widget.content.description_text = Localize("loc_smart_tag_description_format_key", true, {
						distance = distance_text,
						description = description_text,
					})
				end
			end

			local style = widget.style and widget.style.description_text

			if style and not style.word_wrap then
				style.size = { 500, 100 }
				style.word_wrap = true
			end

			if not data.tag_template or data.tag_template == {} or not data.tag_template.name then
				widget.content.input_text = ""
			end
		end
	end
end)

HudElementSmartTagging._can_present_tag_interaction = function(self)
	local parent = self._parent
	local player = parent:player()

	if not player then
		return false
	end

	local player_unit = player.player_unit

	if not ALIVE[player_unit] then
		return false
	end

	local interactor_extension = has_extension(player_unit, "interactor_system")

	if interactor_extension then
		local interactee_unit = interactor_extension:target_unit()
		local focus_unit = interactor_extension:focus_unit()

		if ALIVE[focus_unit] and interactor_extension:hud_block_text() then
			return false
		end

		if ALIVE[interactee_unit] and interactor_extension:can_interact(interactee_unit) then
			if has_extension(interactee_unit, "smart_tag_system") then
				if self._world_markers_list then
					for i = 1, #self._world_markers_list do
						local marker = self._world_markers_list[i]

						if marker.unit == interactee_unit and marker.markers_aio_type then
							return true
						end
					end
				end

				return false
			end
		end
	end

	return true
end