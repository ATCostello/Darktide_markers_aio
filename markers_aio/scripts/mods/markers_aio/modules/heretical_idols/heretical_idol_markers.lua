local mod = get_mod("markers_aio")
local HereticalIdolTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/heretical_idols/heretical_idol_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local DestructibleExtension = require("scripts/extension_systems/destructible/destructible_extension")
local UIWidget = require("scripts/managers/ui/ui_widget")

local fs = mod.frame_settings

local function remove_totem_from_tracking_safe(unit)
	if mod.remove_totem_from_tracking then
		mod.remove_totem_from_tracking(unit)
	end
end

mod.heretical_idols = {}
mod._world_markers_list = {}

local get_max_distance = function()
	local max_distance = fs.heretical_idol_max_distance

	if max_distance == nil then
		max_distance = fs.heretical_idol_max_distance
	end

	return max_distance
end

mod:hook_safe(CLASS.DestructibleExtension, "set_collectible_data", function(self, data)
	mod.add_heretical_idol_marker(self, data.unit, data.section_id)
	self._owner_system:enable_update_function(data.unit, "update")
end)

DestructibleExtension.update = function(self, unit, dt, t)
	if self._timer_to_despawn then
		self._timer_to_despawn = self._timer_to_despawn - dt
		self._timer_to_despawn = math.max(self._timer_to_despawn, 0)

		if self._timer_to_despawn == 0 then
			-- self._owner_system:disable_update_function(self.__class_name, "update", self._unit, self)
			Managers.state.unit_spawner:mark_for_deletion(unit)
		end
	end
end

DestructibleExtension._cb_world_markers_list_request = function(self, world_markers)
	self._world_markers_list = world_markers
end

mod:hook_safe(CLASS.DestructibleExtension, "update", function(self, unit, dt, t)
	if self._collectible_data then
		if self._collectible_data.unit and self._collectible_data.section_id then
			mod.add_heretical_idol_marker(self, self._collectible_data.unit, self._collectible_data.section_id)
		end
	end
end)

DestructibleExtension._add_damage = function(self, damage_amount, attack_direction, force_destruction, attacking_unit)
	Managers.event:trigger("request_world_markers_list", callback(self, "_cb_world_markers_list_request"))

	local destruction_info = self._destruction_info
	local unit = self._unit
	local current_stage_index = destruction_info.current_stage_index

	if current_stage_index > 0 and damage_amount > 0 then
		local health_after_damage
		local health_extension = ScriptUnit.has_extension(unit, "health_system")

		if health_extension and self._use_health_extension_health then
			health_after_damage = health_extension:current_health()
		else
			health_after_damage = destruction_info.health - damage_amount
		end

		destruction_info.health = math.max(0, health_after_damage)

		if health_after_damage <= 0 then
			remove_totem_from_tracking_safe(self._unit)

			if self._collectible_data then
				if self._collectible_data.unit and self._collectible_data.section_id then
					mod.remove_heretical_idol_marker(
						self,
						self._collectible_data.unit,
						self._collectible_data.section_id
					)
				end
			end

			self:_dequeue_stage(attack_direction, false)

			if self._collectible_data then
				local collectibles_manager = Managers.state.collectibles

				collectibles_manager:collectible_destroyed(self._collectible_data, attacking_unit)
			end
		elseif self._is_server then
			Unit.flow_event(unit, "lua_damage_taken")

			local is_level_unit, unit_id = Managers.state.unit_spawner:game_object_id_or_level_index(unit)

			Managers.state.game_session:send_rpc_clients("rpc_destructible_damage_taken", unit_id, is_level_unit)
		end
	end
end

DestructibleExtension.rpc_destructible_last_destruction = function(self)
	Managers.event:trigger("request_world_markers_list", callback(self, "_cb_world_markers_list_request"))

	Unit.flow_event(self._unit, "lua_last_destruction")

	remove_totem_from_tracking_safe(self._unit)

	if self._collectible_data then
		if self._collectible_data.unit and self._collectible_data.section_id then
			mod.remove_heretical_idol_marker(self, self._collectible_data.unit, self._collectible_data.section_id)
		end
	end
end

mod.get_marker_pickup_type_by_unit = function(marker_unit)
	if not marker_unit then
		return
	end
	return Unit.get_data(marker_unit, "pickup_type")
end

mod.is_heretical_idol_unit = function(unit)
	if not unit or type(unit) ~= "userdata" then
		return false
	end

	if not ScriptUnit.has_extension(unit, "destructible_system") then
		return false
	end

	local destructible_extension = ScriptUnit.extension(unit, "destructible_system")

	return destructible_extension ~= nil and destructible_extension._collectible_data ~= nil
end

mod.current_heretical_idol_markers = {}

mod.get_world_markers_element = function()
	local ui_manager = Managers.ui

	if not ui_manager then
		return nil
	end

	local hud = ui_manager:get_hud()

	if not hud then
		return nil
	end

	return hud:element("HudElementWorldMarkers")
end

mod.find_collectible_marker_by_unit = function(unit)
	local world_markers = mod.get_world_markers_element()

	if not world_markers then
		return nil
	end

	local markers_by_type = world_markers._markers_by_type

	if not markers_by_type then
		return nil
	end

	-- the idol template is registered under both type keys
	for _, marker_type in ipairs({ HereticalIdolTemplate.name, "nurgle_totem" }) do
		local markers = markers_by_type[marker_type]

		if markers then
			for i = 1, #markers do
				if markers[i].unit == unit then
					return markers[i]
				end
			end
		end
	end
end

mod.add_heretical_idol_marker = function(self, unit, section_id)
	if fs.heretical_idol_enable then
		HereticalIdolTemplate.section_id = section_id
		local marker_type = HereticalIdolTemplate.name

		Managers.event:trigger("request_world_markers_list", callback(self, "_cb_world_markers_list_request"))

		if section_id then
			if Unit.alive(unit) then
				-- nil means the section has not been handled yet, a false marker id means the
				-- collectible has been destroyed, so only a missing entry should be retried
				if mod.current_heretical_idol_markers[section_id] == nil then
					local existing = mod.find_collectible_marker_by_unit(unit)

					if existing then
						mod.current_heretical_idol_markers[section_id] = existing.id
					else
						local marker_id

						Managers.event:trigger("add_world_marker_unit", marker_type, unit, function(id)
							marker_id = id
						end)

						-- the callback only runs when a world markers element took the marker,
						-- so a dropped trigger leaves the section open for the next attempt
						mod.current_heretical_idol_markers[section_id] = marker_id
					end
				end
			end
		end
	end
end

mod.scan_for_existing_idols = function()
	if not Managers.world then
		return
	end
	local world = Managers.world:world("level_world")
	if not world then
		return
	end
	local units = World.units(world)
	if not units then
		return
	end
	for i = 1, #units do
		local unit = units[i]
		if mod.is_heretical_idol_unit(unit) then
			local destructible_extension = ScriptUnit.extension(unit, "destructible_system")
			local collectible_data = destructible_extension and destructible_extension._collectible_data
			if collectible_data and collectible_data.section_id then
				mod.add_heretical_idol_marker(destructible_extension, collectible_data.unit or unit, collectible_data.section_id)
			end
		end
	end
end

mod.remove_heretical_idol_marker = function(self, unit, section_id)
	if self and self._world_markers_list and unit then
		for _, marker in pairs(self._world_markers_list) do
			if marker.markers_aio_type and marker.markers_aio_type == "heretical_idol" then
				if marker.unit and marker.unit == unit then
					marker.draw = false
					marker.widget.visible = false
					marker.widget.alpha_multiplier = 0
					Managers.event:trigger("remove_world_marker", marker.id)
				end
			end
		end
	end

	-- keep the section flagged so the idle update loop does not bring the
	-- marker back for a collectible that has already been destroyed
	if section_id and mod.current_heretical_idol_markers[section_id] == nil then
		mod.current_heretical_idol_markers[section_id] = false
	end
end

mod.update_marker_icon = function(self, marker)
	if marker then
		local max_distance = get_max_distance()

		if
			marker.type
			and marker.type == "interaction"
			and (mod.is_heretical_idol_unit(marker.unit) or mod.is_totem_unit(marker.unit))
		then
			-- only hide the vanilla interaction marker once the custom marker is really on screen,
			-- otherwise the collectible would have no marker at all
			if mod.find_collectible_marker_by_unit(marker.unit) then
				marker.markers_aio_type = "heretical_idol"
				marker.aio_suppress = true
			end
		end

		if marker.type and (marker.type == "heretical_idol") then
			marker.markers_aio_type = "heretical_idol"
			marker.widget.alpha_multiplier = 0
			marker.draw = false

			marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/enemy"

			mod.set_colour_argb(
				marker.widget.style.icon.color,
				255,
				fs.icon_colour_R,
				fs.icon_colour_G,
				fs.icon_colour_B
			)
			mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.idol_border_colour))

			mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))
			marker.template.screen_clamp = fs.heretical_idol_keep_on_screen
			marker.block_screen_clamp = false

			local max_spawn_distance_sq = max_distance * max_distance
			HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

			marker.template.max_distance = max_distance
			marker.template.fade_settings.distance_max = max_distance
			marker.template.fade_settings.distance_min = max_distance - marker.template.evolve_distance * 2
		end
	end
end
