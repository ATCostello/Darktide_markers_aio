local mod = get_mod("markers_aio")

mod:io_dofile("markers_aio/scripts/mods/markers_aio/ammo_med_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/chest_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/heretical_idol_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/material_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/stimm_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/tome_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/tainted_device_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/tainted_skull_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/luggable_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/martyrs_skull_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/stolen_rations_markers")


mod:io_dofile("markers_aio/scripts/mods/markers_aio/markers_aio_localization")

local HereticalIdolTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/heretical_idol_markers_template")
local MedMarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/ammo_med_markers_template")
local ChestMarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/chest_markers_template")
local MartyrsSkullMarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/martyrs_skull_markers_template")
local MartyrsSkullMarkerGuideTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/martyrs_skull_markers_guide_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIScenegraph = require("scripts/managers/ui/ui_scenegraph")
local HudElementSmartTagging = require("scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging")

mod:hook_safe(CLASS.HudElementWorldMarkers, "init", function(self)
	-- add new marker templates to templates table
	self._marker_templates[HereticalIdolTemplate.name] = HereticalIdolTemplate
	self._marker_templates["nurgle_totem"] = HereticalIdolTemplate
	self._marker_templates[MedMarkerTemplate.name] = MedMarkerTemplate
	self._marker_templates[ChestMarkerTemplate.name] = ChestMarkerTemplate
	self._marker_templates[MartyrsSkullMarkerTemplate.name] = MartyrsSkullMarkerTemplate
	self._marker_templates[MartyrsSkullMarkerGuideTemplate.name] = MartyrsSkullMarkerGuideTemplate

	mod.active_chests = {}
	mod.current_heretical_idol_markers = {}
	mod.reset_martyrs_skull_guides()
end)

mod:hook_safe(CLASS.MissionObjectiveSystem, "hot_join_sync", function(self, sender, channel)
	mod.reset_martyrs_skull_guides()
end)

totem_units = {}
-- add a marker to nurgle totems...
mod:hook_safe(CLASS.PropUnitDataExtension, "setup_from_component", function(self, prop_data_name)
	if prop_data_name == "nurgle_totem" then
		local totem_unit = self._unit
		Managers.event:trigger("add_world_marker_unit", "nurgle_totem", totem_unit)
		table.insert(totem_units, totem_unit)
	end
end)

mod.get_marker_pickup_type = function(marker)
	if
		marker.type ~= "interaction"
		or not marker.unit
		or not Unit
		or not Unit.alive(marker.unit)
		or not Unit.has_data(marker.unit, "pickup_type")
	then
		return
	end
	return Unit.get_data(marker.unit, "pickup_type")
end

mod.lookup_colour = function(colour_string)
	if colour_string then
		local colours = {
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
			["Black"] = {
				255,
				35,
				31,
				32,
			},
			["Terminal"] = Color.terminal_background(200, true),
			["Brass"] = {
				255,
				226,
				199,
				126,
			},
		}
		return colours[colour_string]
	else
		return {
			255,
			161,
			166,
			169,
		}
	end
end

HudElementWorldMarkers._get_scale = function(self, scale_settings, distance)
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
			local eased_distance_fade_fraction = easing_function(distance_fade_fraction)
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

local HudElementWorldMarkersSettings =
	require("scripts/ui/hud/elements/world_markers/hud_element_world_markers_settings")

HudElementWorldMarkers._draw_markers = function(self, dt, t, input_service, ui_renderer, render_settings)
	local camera = self._camera

	if camera then
		local markers_by_type = self._markers_by_type
		local layer_offset = 0

		for marker_type, markers in pairs(markers_by_type) do
			for i = 1, #markers do
				local marker = markers[i]
				local draw = marker.draw

				if draw then
					local widget = marker.widget
					local content = widget.content
					local distance = content.distance
					local template = marker.template
					local scale_settings = template.scale_settings
					local fade_settings = template.fade_settings

					local curr_alpha_mult = 1
					if marker.markers_aio_type then
						mod.adjust_scale(self, marker, ui_renderer)
						curr_alpha_mult = mod.fade_icon_not_in_los(marker, ui_renderer) or 1

						widget.alpha_multiplier = curr_alpha_mult

						local offset = widget.offset

						offset[3] = math.min(layer_offset, HudElementWorldMarkersSettings.max_marker_draw_layer)
						layer_offset = layer_offset + HudElementWorldMarkersSettings.marker_draw_layer_increment

						UIWidget.draw(widget, ui_renderer)
					else
						if scale_settings then
							marker.scale = self:_get_scale(scale_settings, distance)

							local new_scale = marker.ignore_scale and 1 or marker.scale

							self:_apply_scale(widget, new_scale)
						end

						local alpha_multiplier = 1

						if fade_settings and not marker.block_fade_settings then
							alpha_multiplier = self:_get_fade(fade_settings, distance)
						end

						if draw then
							local offset = widget.offset

							offset[3] = math.min(layer_offset, HudElementWorldMarkersSettings.max_marker_draw_layer)
							layer_offset = layer_offset + HudElementWorldMarkersSettings.marker_draw_layer_increment

							local previous_alpha_multiplier = widget.alpha_multiplier

							widget.alpha_multiplier = (previous_alpha_multiplier or 1) * alpha_multiplier

							UIWidget.draw(widget, ui_renderer)

							widget.alpha_multiplier = previous_alpha_multiplier
						end
					end
				end
			end
		end
	end
end

local DEBUG_MARKER = "objective"
local temp_array_markers_to_remove = {}
local temp_marker_raycast_queue = {}
local HudElementWorldMarkersSettings =
	require("scripts/ui/hud/elements/world_markers/hud_element_world_markers_settings")

HudElementWorldMarkers._calculate_markers = function(self, dt, t, input_service, ui_renderer, render_settings)
	local raycasts_allowed = self._raycast_frame_counter == 0

	self._raycast_frame_counter = (self._raycast_frame_counter + 1)
		% HudElementWorldMarkersSettings.raycasts_frame_delay

	local camera = self._camera

	if camera then
		local scale = ui_renderer.scale
		local inverse_scale = ui_renderer.inverse_scale
		local camera_position = Camera.local_position(camera)
		local camera_rotation = Camera.local_rotation(camera)
		local camera_forward = Quaternion.forward(camera_rotation)
		local camera_direction = Quaternion.forward(camera_rotation)
		local camera_position_center = camera_position + camera_forward
		local camera_pose = Camera.local_pose(camera)
		local camera_position_right = Matrix4x4.right(camera_pose)
		local camera_position_left = -camera_position_right
		local camera_position_up = Matrix4x4.up(camera_pose)
		local camera_position_down = -camera_position_up
		local root_size = UIScenegraph.size_scaled(self._ui_scenegraph, "screen")
		local markers_by_id = self._markers_by_id
		local markers_by_type = self._markers_by_type
		local ALIVE = ALIVE

		for marker_type, markers in pairs(markers_by_type) do
			for i = 1, #markers do
				local marker = markers[i]

				local id = marker.id
				local template = marker.template
				local update = markers_by_id[id] ~= nil
				local remove = marker.remove
				local widget = marker.widget
				local content = widget.content
				local screen_clamp = template.screen_clamp and not marker.block_screen_clamp
				local screen_margins = template.screen_margins
				local max_distance = template.max_distance

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
							local node = unit_node and Unit.has_node(unit, unit_node) and Unit.node(unit, unit_node)
								or 1

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

					local distance = Vector3.distance(marker_position, camera_position)

					content.distance = distance
					marker.distance = distance

					local out_of_reach = max_distance and max_distance < distance
					local draw = not out_of_reach

					if not out_of_reach then
						local marker_direction = Vector3.normalize(marker_position - camera_position)

						marker_direction = Vector3.normalize(marker_direction)

						local forward_dot_dir = Vector3.dot(camera_direction, marker_direction)
						local is_inside_frustum = Camera.inside_frustum(camera, marker_position) > 0
						local camera_left = Vector3.cross(camera_direction, Vector3.up())
						local left_dot_dir = Vector3.dot(camera_left, marker_direction)
						local angle = math.atan2(left_dot_dir, forward_dot_dir)
						local is_behind = forward_dot_dir < 0 and true or false
						local is_under = marker_position.z < camera_position.z
						local x, y, _ = self:_convert_world_to_screen_position(camera, marker_position)
						local pixel_offset = template.pixel_offset

						if pixel_offset then
							x = x + pixel_offset[1]
							y = y + pixel_offset[2]
						end

						local screen_x, screen_y = self:_get_screen_offset(scale)

						x = x - screen_x
						y = y - screen_y

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

						marker.raycast_frame_count = (marker.raycast_frame_count or 0) + 1

						if raycasts_allowed then
							temp_marker_raycast_queue[#temp_marker_raycast_queue + 1] = marker
						end
					end

					marker.draw = draw
				end

				marker.update = update
			end
		end

		if raycasts_allowed then
			self:_raycast_markers(temp_marker_raycast_queue)
		end

		dbg_markers = markers_by_type

		for marker_type, markers in pairs(markers_by_type) do
			for i = 1, #markers do
				local marker = markers[i]

				if marker and marker.update then
					local template = marker.template
					local update_function = template.update_function

					if update_function then
						update_function(self, ui_renderer, marker.widget, marker, template, dt, t)
						if mod:get("tome_enable") then
							mod.update_tome_markers(self, marker)
						end
						if mod:get("material_enable") then
							mod.update_material_markers(self, marker)
						end
						if mod:get("ammo_med_enable") then
							mod.update_ammo_med_markers(self, marker)
						end
						if mod:get("stimm_enable") then
							mod.update_stimm_markers(self, marker)
						end
						if mod:get("chest_enable") then
							mod.update_chest_markers(self, marker)
						end
						if mod:get("heretical_idol_enable") then
							mod.update_marker_icon(self, marker)
						end
						if mod:get("tainted_enable") then
							mod.update_TaintedDevices_markers(self, marker)
							mod.update_stolenrations_markers(self, marker)
						end
						if mod:get("tainted_skull_enable") then
							mod.update_tainted_skull_markers(self, marker)
						end
						if mod:get("luggable_enable") then
							mod.update_luggable_markers(self, marker)
						end
						if mod:get("martyrs_skull_enable") then
							mod.update_martyrs_skull_markers(self, marker)
						end

						mod.fade_icon_not_in_los(marker, ui_renderer)
						mod.adjust_scale(self, marker, ui_renderer)

						mod.adjust_los_requirement(marker)
						mod.adjust_distance_visibility(marker)

						if mod:get("tainted_skull_enable") then
							-- adjust any nurgle totems markers to have full opacity, and to be removed if destroyed...
							if marker.type and marker.type == "nurgle_totem" then
								local totem_exists = false

								for i, unit in pairs(totem_units) do
									if marker.unit == unit then
										totem_exists = true
									end
								end

								if totem_exists == false then
									Managers.event:trigger("remove_world_marker", marker.id)
								else
									marker.draw = true
									if marker.markers_aio_type then
										marker.widget.alpha_multiplier = mod:get(marker.markers_aio_type .. "_alpha")
									end
								end
							end
						end
					end
				end
			end
		end
	else
		self._camera = self._parent:player_camera()
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

-- Fade out markers that are behind objects, depending on the set "los_opacity"
mod.fade_icon_not_in_los = function(marker, ui_renderer)
	if marker.markers_aio_type then
		local curr_alpha_mult = 0

		-- reset to default opacity if marker is in sight. (helps fix if the opacity is "stuck")
		if marker.is_inside_frustum and marker.raycast_result == false then
			marker.widget.alpha_multiplier = mod:get(marker.markers_aio_type .. "_alpha")
		end

		if mod:get("los_fade_enable") == true then
			-- Calculate opacity from the mod setting
			local los_opacity = 50
			if mod:get("los_opacity") then
				los_opacity = mod:get("los_opacity") / 100
			end

			if mod:get(marker.markers_aio_type .. "_alpha") then
				-- true if not in los, false if in los
				if marker.raycast_result == true then
					marker.widget.alpha_multiplier = mod:get(marker.markers_aio_type .. "_alpha") * los_opacity
				elseif marker.raycast_result == false then
					marker.widget.alpha_multiplier = mod:get(marker.markers_aio_type .. "_alpha")
				else
					marker.widget.alpha_multiplier = 0
				end
			end
		else
			if mod:get(marker.markers_aio_type .. "_alpha") then
				-- true if not in los, false if in los
				if marker.raycast_result == true then
					marker.widget.alpha_multiplier = mod:get(marker.markers_aio_type .. "_alpha")
				elseif marker.raycast_result == false then
					marker.widget.alpha_multiplier = mod:get(marker.markers_aio_type .. "_alpha")
				else
					marker.widget.alpha_multiplier = 0
				end
			end
		end

		-- health station markers are placed INSIDE the medicae unit, causing the los to break constantly...
		if marker.data and marker.data._active_interaction_type == "health_station" then
			marker.widget.alpha_multiplier = mod:get(marker.markers_aio_type .. "_alpha")
		end

		curr_alpha_mult = marker.widget.alpha_multiplier

		return curr_alpha_mult
	end
end

local do_draw = function(marker)
	marker.draw = true
end

local dont_draw = function(marker)
	if marker then
		-- if the marker is tagged, always show.
		if
			marker.is_inside_frustum
			and marker.widget
			and marker.widget.content
			and marker.widget.content
			and marker.widget.content.tagged == true
		then
			do_draw(marker)
		else
			marker.draw = false
		end
	end
end

-- Adjust whether markers are shown behind objects or not, depending on which marker type and which settings are enabled.
mod.adjust_los_requirement = function(marker)
	if marker.markers_aio_type then
		if mod:get(marker.markers_aio_type .. "_require_line_of_sight") == true then
			if marker.is_inside_frustum then
				if marker.raycast_result == false then
					do_draw(marker)
				elseif marker.raycast_result == false and mod:get(marker.markers_aio_type .. "_keep_on_screen") then
					do_draw(marker)
				else
					dont_draw(marker)
				end
			elseif marker.raycast_result == false and mod:get(marker.markers_aio_type .. "_keep_on_screen") then
				do_draw(marker)
			else
				dont_draw(marker)
			end
		else
			if marker.is_inside_frustum then
				do_draw(marker)
			elseif mod:get(marker.markers_aio_type .. "_keep_on_screen") then
				do_draw(marker)
			else
				dont_draw(marker)
			end
		end
	end

	-- As health station is visible through objects, limit to only 30m distance.
	if
		marker.data
		and marker.data._active_interaction_type
		and marker.data._active_interaction_type == "health_station"
	then
		if marker.is_inside_frustum and marker.distance and marker.distance < 20 then
			do_draw(marker)
		else
			dont_draw(marker)
		end
	end
end

-- Adjust the scale of markers, according to their percentage scale setting.
mod.adjust_scale = function(self, marker, ui_renderer)
	marker.scale_original = marker.scale

	if not marker.markers_aio_type then
		return
	end

	local widget = marker.widget
	local content = widget.content
	local distance = content.distance
	local template = marker.template
	local scale_settings = template.scale_settings

	if not scale_settings then
		return
	end

	local scale = 1
	local scale_key = marker.markers_aio_type .. "_scale"
	local user_scale = mod:get(scale_key)
	if user_scale then
		scale = user_scale / 100
	end

	marker.scale = self:_get_scale(scale_settings, distance)
	local new_scale = marker.ignore_scale and 1 or marker.scale * scale
	marker.scale = new_scale

	self:_apply_scale(widget, new_scale)

	if marker.data and marker.data.type == "medical_crate_deployable" then
		local style = widget.style
		local lerp_multiplier = 1

		for _, pass_style in pairs(style) do
			local current_size = pass_style.area_size or pass_style.texture_size or pass_style.size
			if current_size then
				local default_size = 96

				if _ == "background" or _ == "ping" or _ == "ring" then
					default_size = 96
				else
					default_size = 48
				end

				current_size[1] = math.lerp(current_size[1], default_size * new_scale, lerp_multiplier)
				current_size[2] = math.lerp(current_size[2], default_size * new_scale, lerp_multiplier)
			end

			if pass_style.font_size then
				local font_size = math.lerp(pass_style.font_size, 16 * new_scale, lerp_multiplier)
				marker.widget.style.marker_text.font_size = font_size
			end
		end
	end
end

HudElementWorldMarkers._apply_scale = function(self, widget, scale)
	local style = widget.style
	local lerp_multiplier = 0.2

	for _, pass_style in pairs(style) do
		local default_size = pass_style.default_size

		if default_size then
			local current_size = pass_style.area_size or pass_style.texture_size or pass_style.size

			current_size[1] = math.lerp(current_size[1], default_size[1] * scale, lerp_multiplier)
			current_size[2] = math.lerp(current_size[2], default_size[2] * scale, lerp_multiplier)
		end

		local default_offset = pass_style.default_offset

		if default_offset then
			local offset = pass_style.offset

			offset[1] = math.lerp(offset[1], default_offset[1] * scale, lerp_multiplier)
			offset[2] = math.lerp(offset[2], default_offset[2] * scale, lerp_multiplier)
		end

		local default_pivot = pass_style.default_pivot

		if default_pivot then
			local pivot = pass_style.pivot

			pivot[1] = math.lerp(pivot[1], default_pivot[1] * scale, lerp_multiplier)
			pivot[2] = math.lerp(pivot[2], default_pivot[2] * scale, lerp_multiplier)
		end
	end
end

-- force hide the markers if the distance is greater than their max. (Helps ensure markers wont be "stuck" on the screen on rare occurances)
mod.adjust_distance_visibility = function(marker)
	if marker.markers_aio_type then
		local max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
		if max_distance and marker.distance > max_distance then
			dont_draw(marker)
		end
	end
end

-- override to let you tag any vanilla item marker that you can see.
HudElementSmartTagging._is_marker_valid_for_tagging = function(self, player_unit, marker, distance)
	local template = marker.template

	if not template.using_smart_tag_system then
		return false
	end

	local marker_unit = marker.unit
	local smart_tag_extension = marker_unit and ScriptUnit.has_extension(marker_unit, "smart_tag_system")

	if marker_unit and not smart_tag_extension then
		return false
	end

	if smart_tag_extension and not smart_tag_extension:can_tag(player_unit) then
		return false
	end

	if marker.draw == true then
		return true
	else
		return false
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

mod.tainted_toggle_los = function()
	mod.toggle_los("tainted")
end

mod.tainted_skull_toggle_los = function()
	mod.toggle_los("tainted_skull")
end

mod.luggable_toggle_los = function()
	mod.toggle_los("luggable")
end

mod.martyrs_skull_toggle_los = function()
	mod.toggle_los("martyrs_skull")
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
