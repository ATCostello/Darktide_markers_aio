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
mod:io_dofile("markers_aio/scripts/mods/markers_aio/atonement_markers")

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

-- Per-frame computed settings (rebuilt once per frame)
mod.frame_settings = {}

-- Lazy per-marker-type cache (settings snapshot per frame)
mod.fc_typecache = {}

-- Ensure markers start fully transparent until their first transform has applied
local function ensure_invisible_until_ready(marker)
	if not marker.widget then
		return
	end

	-- Hide until transform + alpha + scale are ready
	if marker.markers_aio_type then
		if not marker._aio_transformed or not marker._aio_alpha_ready or not marker._aio_scale_ready then
			marker.widget.alpha_multiplier = 0
			marker.draw = false
		end
	end
end

-- Global colour lookup (no per-call table allocs)
local COLOUR_LOOKUP = {
	Gold = { 255, 232, 188, 109 },
	Silver = { 255, 187, 198, 201 },
	Steel = { 255, 161, 166, 169 },
	Black = { 255, 35, 31, 32 },
	Brass = { 255, 226, 199, 126 },
	Terminal = Color.terminal_background(200, true),
	Default = { 255, 161, 166, 169 },
}

mod:hook_safe(CLASS.HudElementWorldMarkers, "init", function(self)
	-- add new marker templates to templates table
	self._marker_templates[HereticalIdolTemplate.name] = HereticalIdolTemplate
	self._marker_templates["nurgle_totem"] = HereticalIdolTemplate
	self._marker_templates[MedMarkerTemplate.name] = MedMarkerTemplate
	self._marker_templates[ChestMarkerTemplate.name] = ChestMarkerTemplate
	self._marker_templates[MartyrsSkullMarkerTemplate.name] = MartyrsSkullMarkerTemplate
	self._marker_templates[MartyrsSkullMarkerGuideTemplate.name] = MartyrsSkullMarkerGuideTemplate

	-- reset runtime state on (re)init to avoid growth across missions/hot-joins
	mod.active_chests = {}
	mod.current_heretical_idol_markers = {}
	processed_idols = {}
	mod.reset_martyrs_skull_guides()
end)

mod:hook_safe(CLASS.MissionObjectiveSystem, "hot_join_sync", function(self, sender, channel)
	mod.reset_martyrs_skull_guides()
end)

local totem_units = {}
_G.totem_units = totem_units -- expose for other modules without polluting with multiple instances
-- add a marker to nurgle totems...
mod:hook_safe(CLASS.PropUnitDataExtension, "setup_from_component", function(self, prop_data_name)
	if prop_data_name == "nurgle_totem" then
		local totem_unit = self._unit
		Managers.event:trigger("add_world_marker_unit", "nurgle_totem", totem_unit)
		table.insert(totem_units, totem_unit)
	end
end)

local function get_type_cache(mod, marker_type)
	local cache = mod.fc_typecache
	local tc = cache[marker_type]

	if marker_type == nil then
		return
	end

	if tc then
		return tc
	end

	tc = {
		alpha = mod:get(marker_type .. "_alpha") or 1,
		scale = (mod:get(marker_type .. "_scale") or 100) / 100,
		max_distance = mod:get(marker_type .. "_max_distance"),
		require_los = mod:get(marker_type .. "_require_line_of_sight") == true,
		keep_on_screen = mod:get(marker_type .. "_keep_on_screen") == true,
	}

	cache[marker_type] = tc
	return tc
end

local function build_frame_settings(mod)
	local fs = mod.frame_settings

	-- ADS detection ONCE per frame
	local is_ads = false
	local player = Managers.player:local_player(1)
	if player then
		local unit = player.player_unit
		if unit then
			local ude = ScriptUnit.extension(unit, "unit_data_system")
			if ude then
				local af = ude:read_component("alternate_fire")
				is_ads = af and af.is_active or false
			end
		end
	end

	fs.is_ads = is_ads

	-- LOS global settings
	fs.los_enabled = mod:get("los_fade_enable") == true
	fs.los_opacity = (mod:get("los_opacity") or 100) / 100
	fs.ads_los_opacity = (mod:get("ads_los_opacity") or 100) / 100
	fs.ads_blend = math.lerp(fs.ads_blend or 0, is_ads and 1 or 0, 0.25)

	fs.med_station_max_distance = mod:get("med_station_max_distance") or 20

	-- Feature toggles (queried ONCE)
	fs.enable = {
		tome = mod:get("tome_enable"),
		material = mod:get("material_enable"),
		ammo_med = mod:get("ammo_med_enable"),
		stimm = mod:get("stimm_enable"),
		chest = mod:get("chest_enable"),
		heretical_idol = mod:get("heretical_idol_enable"),
		tainted = mod:get("tainted_enable"),
		tainted_skull = mod:get("tainted_skull_enable"),
		luggable = mod:get("luggable_enable"),
		martyrs_skull = mod:get("martyrs_skull_enable"),
		rations = mod:get("rations_enable"),
		atonement = mod:get("atonement_enable"),
	}
end

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
	return COLOUR_LOOKUP[colour_string] or COLOUR_LOOKUP.Default
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
	if not camera then
		return
	end

	local markers_by_type = self._markers_by_type
	local drawable_markers = {}

	for _, markers in pairs(markers_by_type) do
		for i = 1, #markers do
			local marker = markers[i]
			if marker.draw and marker.widget then
				drawable_markers[#drawable_markers + 1] = marker
			end
		end
	end

	table.sort(drawable_markers, function(a, b)
		-- Objectives always draw last (highest Z)
		if a.type == "objective" and b.type ~= "objective" then
			return false
		elseif b.type == "objective" and a.type ~= "objective" then
			return true
		end

		-- Vanilla vs AIO ordering
		if a.markers_aio_type and not b.markers_aio_type then
			return false
		elseif not a.markers_aio_type and b.markers_aio_type then
			return true
		end

		return (a.distance or 0) > (b.distance or 0)
	end)

	local BASE_Z = 0
	local Z_STRIDE = 4

	for i = 1, #drawable_markers do
		local marker = drawable_markers[i]
		local widget = marker.widget
		local offset = widget.offset

		offset[3] = BASE_Z + (i * Z_STRIDE)

		if widget.content.marker_text and widget.content.marker_text ~= "" then
			widget.style.marker_text.offset[3] = offset[3] + 2
		end

		UIWidget.draw(widget, ui_renderer)
	end
end

local DEBUG_MARKER = "objective"
local temp_array_markers_to_remove = {}
local temp_marker_raycast_queue = {}
local HudElementWorldMarkersSettings =
	require("scripts/ui/hud/elements/world_markers/hud_element_world_markers_settings")

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

	-- Counter BOTH widget + renderer alpha
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
	t = t * t * (3 - 2 * t) -- smoothstep

	return 1 - t
end

HudElementWorldMarkers._calculate_markers = function(self, dt, t, input_service, ui_renderer, render_settings)
	-- Build per-frame state
	build_frame_settings(mod)

	-- Clear per-type cache each frame
	table.clear(mod.fc_typecache)

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

				-- Never distance-cull base game objective markers
				if marker.type == "objective" or (template and template.name == "objective") then
					max_distance = nil
				end

				if marker.block_max_distance then
					max_distance = math.huge
				end

				local life_time = template.life_time
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
						local forward_dot_dir = Vector3.dot(camera_direction, marker_direction)
						local is_inside_frustum = Camera.inside_frustum(camera, marker_position) > 0
						local camera_left = Vector3.cross(camera_direction, Vector3.up())
						local left_dot_dir = Vector3.dot(camera_left, marker_direction)
						local angle = math.atan2(left_dot_dir, forward_dot_dir)
						local is_behind = forward_dot_dir < 0
						local is_under = marker_position.z < camera_position.z
						local x, y = self:_convert_world_to_screen_position(camera, marker_position)

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
							x, y, is_clamped_left, is_clamped_right, is_clamped_up, is_clamped_down =
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
						end

						if not is_clamped then
							if is_behind then
								draw = false
							elseif not is_inside_frustum then
								draw = false
							end
						end

						content.is_inside_frustum = is_inside_frustum
						content.is_clamped = is_clamped
						content.is_under = is_under
						content.angle = angle
						marker.is_inside_frustum = is_inside_frustum
						marker.is_clamped = is_clamped
						marker.is_under = is_under
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

		for _, markers in pairs(markers_by_type) do
			for i = 1, #markers do
				local marker = markers[i]
				if marker and marker.update then
					marker.markers_aio_type = nil
					ensure_invisible_until_ready(marker)

					local template = marker.template
					local update_function = template.update_function
					if update_function then
						update_function(self, ui_renderer, marker.widget, marker, template, dt, t)
					end

					local fs = mod.frame_settings
					if fs.enable.tome then
						mod.update_tome_markers(self, marker)
					end
					if fs.enable.material then
						mod.update_material_markers(self, marker)
					end
					if fs.enable.ammo_med then
						mod.update_ammo_med_markers(self, marker)
					end
					if fs.enable.stimm then
						mod.update_stimm_markers(self, marker)
					end
					if fs.enable.chest then
						mod.update_chest_markers(self, marker)
					end
					if fs.enable.heretical_idol then
						mod.update_marker_icon(self, marker)
					end
					if fs.enable.tainted then
						mod.update_TaintedDevices_markers(self, marker)
					end
					if fs.enable.tainted_skull then
						mod.update_tainted_skull_markers(self, marker)
					end
					if fs.enable.luggable then
						mod.update_luggable_markers(self, marker)
					end
					if fs.enable.martyrs_skull then
						mod.update_martyrs_skull_markers(self, marker)
					end
					if fs.enable.rations then
						mod.update_stolenrations_markers(self, marker)
					end
					if fs.enable.atonement then
						mod.update_atonement_markers(self, marker)
					end

					if marker.widget and marker.distance and not marker.markers_aio_type then
						local template = marker.template
						local max_distance = template and template.max_distance
							or (marker.markers_aio_type and get_type_cache(mod, marker.markers_aio_type).max_distance)

						if max_distance then
							local dist_alpha = compute_distance_alpha(marker, max_distance)

							marker.widget.alpha_multiplier = (marker.widget.alpha_multiplier or 1) * dist_alpha
						end
					end

					if marker.markers_aio_type then
						mod.adjust_los_requirement(marker)
						mod.adjust_distance_visibility(marker)
					end

					if marker.widget and marker.widget.offset and marker.distance then
						marker._aio_transformed = true
					end

					if marker.markers_aio_type and marker._aio_transformed then
						mod.fade_icon_not_in_los(marker, ui_renderer)
					end

					mod.adjust_scale(self, marker, ui_renderer)
				end
			end
		end
	else
		self._camera = self._parent:player_camera()
	end

	for i = 1, #temp_array_markers_to_remove do
		self:_unregister_marker(temp_array_markers_to_remove[i])
	end

	table.clear(temp_array_markers_to_remove)
	table.clear(temp_marker_raycast_queue)
end

-- Fade out markers that are behind objects, depending on the set "los_opacity"
mod.fade_icon_not_in_los = function(marker, ui_renderer)
	if not marker.markers_aio_type then
		return
	end

	local widget = marker.widget
	if not widget then
		return
	end

	local fs = mod.frame_settings
	local tc = get_type_cache(mod, marker.markers_aio_type)

	-- Pinged markers are always fully visible
	if widget.content and widget.content.tagged == true then
		widget.alpha_multiplier = tc.alpha
		marker._aio_alpha_ready = true
		return tc.alpha
	end

	-- Health station exception
	if marker.data and marker.data._active_interaction_type == "health_station" then
		widget.alpha_multiplier = tc.alpha
		marker._aio_alpha_ready = true
		return tc.alpha
	end

	-- No raycast yet = assume blocked LOS
	local has_raycast = marker.raycast_result ~= nil

	local base_alpha = tc.alpha
	local los_alpha

	if fs.is_ads then
		los_alpha = fs.ads_los_opacity or fs.los_opacity or 1
	else
		los_alpha = fs.los_opacity or 1
	end
	local ads_alpha = math.lerp(1, fs.ads_los_opacity or 1, fs.ads_blend)

	------------------------------------------------
	-- Distance-based alpha (ONLY for IN-LOS markers)
	------------------------------------------------
	local distance_factor = 1

	if tc.max_distance and marker.distance then
		local d = math.clamp(marker.distance / tc.max_distance, 0, 1)

		-- Remap [0.75 → 1.0] → [1 → 0]
		if d >= 0.75 then
			local t = (d - 0.75) / 0.25 -- 0 → 1
			t = math.clamp(t, 0, 1)

			-- Smoothstep (no pop-in)
			t = t * t * (3 - 2 * t)

			distance_factor = 1 - t
		else
			distance_factor = 1
		end
	end

	------------------------------------------------
	-- LOS logic
	------------------------------------------------
	local target_alpha = base_alpha

	-- Apply ADS opacity globally (both LOS and non-LOS)
	if fs.is_ads and (marker.raycast_result == false) then
		-- In LOS: ADS dim applies
		--target_alpha = target_alpha * ads_alpha
		target_alpha = (target_alpha * distance_factor) * ads_alpha
	end

	if fs.los_enabled then
		-- Out of LOS OR no raycast yet
		if not has_raycast or marker.raycast_result == true then
			--target_alpha = target_alpha * los_alpha
			target_alpha = (target_alpha * distance_factor) * los_alpha
		else
			-- In LOS → distance-shaped opacity
			target_alpha = target_alpha * distance_factor
		end
	end

	------------------------------------------------
	-- Init + smoothing
	------------------------------------------------
	if not marker._aio_alpha_ready then
		-- Initialize from ZERO to prevent flash
		widget.alpha_multiplier = 0
		marker._aio_alpha_ready = true
		return 0
	end

	local current = widget.alpha_multiplier or target_alpha
	widget.alpha_multiplier = math.lerp(current, target_alpha, 0.8)

	return target_alpha
end

local function can_draw(marker)
	return marker._aio_transformed == true and marker._aio_scale_ready == true and marker._aio_alpha_ready == true
end

local do_draw = function(marker)
	if can_draw(marker) then
		marker.draw = true
	else
		marker.draw = false
	end
end

local dont_draw = function(marker)
	if not marker then
		return
	end

	-- Tagged markers still must respect transform readiness
	if
		marker.is_inside_frustum
		and marker.widget
		and marker.widget.content
		and marker.widget.content.tagged == true
		and can_draw(marker)
	then
		marker.draw = true
	else
		marker.draw = false
	end
end

mod.adjust_los_requirement = function(marker)
	if not marker.markers_aio_type then
		return
	end

	local fs = mod.frame_settings
	local tc = get_type_cache(mod, marker.markers_aio_type)

	-- Absolute health station override
	if marker.data and marker.data._active_interaction_type == "health_station" then
		if marker.is_inside_frustum then
			do_draw(marker)
		else
			dont_draw(marker)
		end
		return
	end

	if tc.require_los then
		if marker.is_inside_frustum then
			if marker.raycast_result == false then
				do_draw(marker)
			else
				dont_draw(marker)
			end
		elseif marker.raycast_result == false and tc.keep_on_screen then
			do_draw(marker)
		else
			dont_draw(marker)
		end
	else
		if marker.is_inside_frustum or tc.keep_on_screen then
			do_draw(marker)
		else
			dont_draw(marker)
		end
	end

	-- Health station exception (cached distance)
	if marker.data and marker.data._active_interaction_type == "health_station" then
		if marker.is_inside_frustum and marker.distance and marker.distance < (fs.med_station_max_distance or 20) then
			do_draw(marker)
		else
			dont_draw(marker)
		end
	end
end

-- Adjust the scale of markers, according to their percentage scale setting.
mod.adjust_scale = function(self, marker, ui_renderer)
	marker.scale_original = marker.scale

	--if not marker.markers_aio_type then
	--	return
	--end

	local widget = marker.widget
	local content = widget.content
	local distance = content.distance
	local template = marker.template
	local scale_settings = template.scale_settings

	if not scale_settings then
		return
	end

	local scale = 1
	local tc = get_type_cache(mod, marker.markers_aio_type)

	if tc then
		scale = tc.scale or 1
	end

	marker.scale = self:_get_scale(scale_settings, distance)
	local new_scale = marker.ignore_scale and 1 or marker.scale * scale
	marker.scale = new_scale

	if not marker._aio_scale_initialized then
		-- Hard-apply scale instantly before first draw
		self:_apply_scale(widget, new_scale)
		marker._aio_scale_initialized = true
		marker._aio_scale_ready = true
		return
	end

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

	-- Health stations must always be scale-ready
	if marker.data and marker.data._active_interaction_type == "health_station" then
		marker._aio_scale_ready = true
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
	if not marker.markers_aio_type then
		return
	end

	local tc = get_type_cache(mod, marker.markers_aio_type)

	if tc.max_distance and marker.distance > tc.max_distance then
		dont_draw(marker)
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
