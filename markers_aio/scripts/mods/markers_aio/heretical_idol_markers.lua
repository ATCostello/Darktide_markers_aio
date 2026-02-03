local mod = get_mod("markers_aio")
local HereticalIdolTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/heretical_idol_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local DestructibleExtension = require("scripts/extension_systems/destructible/destructible_extension")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod.heretical_idols = {}
mod._world_markers_list = {}
local markers_list_to_remove = {}
local processed_idols = {}

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")

local get_max_distance = function()
	local max_distance = mod:get("heretical_idol_max_distance")

	-- foundya Compatibility
	if FoundYa ~= nil then
		-- max_distance = FoundYa:get("max_distance_penance") or mod:get("heretical_idol_max_distance") or 30
	end

	if max_distance == nil then
		max_distance = mod:get("heretical_idol_max_distance") or 30
	end

	return max_distance
end

mod:hook_safe(CLASS.DestructibleExtension, "set_collectible_data", function(self, data)
	mod.add_heretical_idol_marker(self, data.unit, data.section_id)
	self._owner_system:enable_update_function(self.__class_name, "update", data.unit, self)
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
			for i, unit in pairs(totem_units) do
				if self._unit == unit then
					table.remove(totem_units, i)
					break
				end
			end

			if self._collectible_data then
				if self._collectible_data.unit and self._collectible_data.section_id then
					Managers.event:trigger(
						"request_world_markers_list",
						callback(self, "_cb_world_markers_list_request")
					)
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
	Unit.flow_event(self._unit, "lua_last_destruction")

	for i, unit in pairs(totem_units) do
		if self._unit == unit then
			table.remove(totem_units, i)
			break
		end
	end

	if self._collectible_data then
		if self._collectible_data.unit and self._collectible_data.section_id then
			Managers.event:trigger("request_world_markers_list", callback(self, "_cb_world_markers_list_request"))
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

mod.current_heretical_idol_markers = {}

mod.add_heretical_idol_marker = function(self, unit, section_id)
	if mod:get("heretical_idol_enable") then
		HereticalIdolTemplate.section_id = section_id
		local marker_type = HereticalIdolTemplate.name

		-- removed request_world_markers_list here to avoid unnecessary overhead; we only request when removing

		if section_id then
			if processed_idols[section_id] then
				return
			end
			if Unit.alive(unit) then
				if mod.current_heretical_idol_markers[section_id] == nil then
					Managers.event:trigger("add_world_marker_unit", marker_type, unit)
					mod.current_heretical_idol_markers[section_id] = unit
					processed_idols[section_id] = true
				end
			end
		end
	end
end

mod.remove_heretical_idol_marker = function(self, unit, section_id)
	if self and self._world_markers_list and unit then
		for _, marker in pairs(self._world_markers_list) do
			if marker.markers_aio_type and marker.markers_aio_type == "heretical_idol" then
				if marker.unit and marker.unit == unit then
					if marker.widget then
						marker.widget.visible = false
						marker.widget.alpha_multiplier = 0
					end
					Managers.event:trigger("remove_world_marker", marker.id)
					-- clear caches to avoid leaks and duplicates
					if section_id then
						mod.current_heretical_idol_markers[section_id] = nil
						processed_idols[section_id] = nil
					end
					break
				end
			end
		end
	end
end

mod.update_marker_icon = function(self, marker)
	if marker then
		local max_distance = get_max_distance()

		if marker.template and marker.template.name == HereticalIdolTemplate.name then
			marker.markers_aio_type = "heretical_idol" 
            -- initialize visual/static properties once
			if not marker._aio_heretical_inited then
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/enemy"
				marker.widget.style.icon.color = {
					255,
					mod:get("icon_colour_R"),
					mod:get("icon_colour_G"),
					mod:get("icon_colour_B"),
				}
				marker.widget.style.ring.color = mod.lookup_colour(mod:get("idol_border_colour"))
				marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))
				marker.template.screen_clamp = mod:get("heretical_idol_keep_on_screen")
				marker.block_screen_clamp = false
				marker._aio_heretical_inited = true
			end

			if marker._aio_heretical_max_distance ~= max_distance then
				marker.template.max_distance = max_distance
				marker.template.fade_settings.distance_max = max_distance
				marker.template.fade_settings.distance_min = marker.template.max_distance
					- marker.template.evolve_distance * 2
				marker._aio_heretical_max_distance = max_distance
			end
		end
	end
end
