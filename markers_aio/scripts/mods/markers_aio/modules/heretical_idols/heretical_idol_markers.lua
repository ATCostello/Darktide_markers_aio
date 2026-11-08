local mod = get_mod("markers_aio")
local HereticalIdolTemplate =
	mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/heretical_idols/heretical_idol_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local DestructibleExtension = require("scripts/extension_systems/destructible/destructible_extension")
local UIWidget = require("scripts/managers/ui/ui_widget")

local fs = mod.frame_settings

local has_extension = ScriptUnit.has_extension

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

	if self._collectible_data and mod.frame_settings.mod_enabled then
		if self._collectible_data.unit and self._collectible_data.section_id then
			mod.add_heretical_idol_marker(self, self._collectible_data.unit, self._collectible_data.section_id)
		end
	end
end

DestructibleExtension._cb_world_markers_list_request = function(self, world_markers)
	self._world_markers_list = world_markers
end
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

	if self._collectible_data and mod.frame_settings.mod_enabled then
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

mod.current_heretical_idol_markers = {}

local add_templates = function()
	local ui_manager = Managers.ui
	local hud = ui_manager and ui_manager:get_hud()
	local world_markers = hud and hud:element("HudElementWorldMarkers")
	local markers = world_markers and world_markers._markers

	if not markers then
		return
	end

	local marker_templates = world_markers._marker_templates

	if HereticalIdolTemplate then
		if not marker_templates[HereticalIdolTemplate.name] then
			marker_templates[HereticalIdolTemplate.name] = HereticalIdolTemplate
		end
		if not marker_templates["nurgle_totem"] then
			marker_templates["nurgle_totem"] = HereticalIdolTemplate
		end
	end
end

mod.add_heretical_idol_marker = function(self, unit, section_id)
	if fs.heretical_idol_enable then
		HereticalIdolTemplate.section_id = section_id
		local marker_type = HereticalIdolTemplate.name

		add_templates()

		Managers.event:trigger("request_world_markers_list", callback(self, "_cb_world_markers_list_request"))

		if section_id then
			if Unit.alive(unit) then
				if mod.current_heretical_idol_markers[section_id] == nil then
					Managers.event:trigger("add_world_marker_unit", marker_type, unit)
					mod.current_heretical_idol_markers[section_id] = unit
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
					marker.draw = false
					marker.widget.visible = false
					marker.widget.alpha_multiplier = 0
					Managers.event:trigger("remove_world_marker", marker.id)
				end
			end
		end
	end
end

mod.update_marker_icon = function(self, marker)
	if not fs.mod_enabled then
		return
	end

	if marker then
		if marker.type and (marker.type == "heretical_idol") then
			local max_distance = get_max_distance()

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

			marker.template.check_line_of_sight = fs.event_require_line_of_sight

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

---- NURGLE TOTEMS
mod.totem_units = {}

mod.is_totem_unit = function(unit)
	if not unit or not Unit.alive(unit) then
		return false
	end
	local ude = has_extension(unit, "unit_data_system")
	if not ude then
		return false
	end
	if ude._breed and ude._breed.name == "nurgle_totem" then
		return true
	end
	local armor_name = Unit.get_data(unit, "armor_data_name")
	if armor_name == "nurgle_totem" then
		return true
	end
	return false
end

mod.find_totem_marker_by_unit = function(unit)
	local ui_manager = Managers.ui
	if not ui_manager then
		return
	end
	local hud = ui_manager:get_hud()
	if not hud then
		return
	end
	local world_markers = hud:element("HudElementWorldMarkers")
	if not world_markers then
		return
	end
	local markers = world_markers._markers_by_type and world_markers._markers_by_type["nurgle_totem"]
	if not markers then
		return
	end
	for i = 1, #markers do
		local marker = markers[i]
		if marker.unit == unit then
			return marker
		end
	end
end

mod.add_totem_marker = function(unit)
	if not unit or not Unit.alive(unit) then
		return
	end
	if not mod.totem_units then
		mod.totem_units = {}
	end
	if mod.totem_units[unit] then
		return
	end
	local existing = mod.find_totem_marker_by_unit(unit)
	if existing then
		mod.totem_units[unit] = existing.id
		return
	end

	add_templates()

	local marker_id
	Managers.event:trigger("add_world_marker_unit", "nurgle_totem", unit, function(id)
		marker_id = id
	end)
	mod.totem_units[unit] = marker_id
end

mod.remove_totem_from_tracking = function(unit)
	if not mod.totem_units or not unit then
		return
	end
	local marker_id = mod.totem_units[unit]
	if marker_id then
		Managers.event:trigger("remove_world_marker", marker_id)
	end
	mod.totem_units[unit] = nil
end

mod.scan_for_existing_totems = function()
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
		if Unit.alive(unit) and mod.is_totem_unit(unit) then
			mod.add_totem_marker(unit)
		end
	end
end

mod:hook_safe(CLASS.PropUnitDataExtension, "setup_from_component", function(self, prop_data_name)
	if prop_data_name == "nurgle_totem" then
		mod.add_totem_marker(self._unit)
	end
end)

mod:hook_safe(CLASS.DestructibleExtension, "destroy", function(self)
	mod.remove_totem_from_tracking(self._unit)
end)
