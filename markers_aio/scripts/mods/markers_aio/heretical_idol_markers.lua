local mod = get_mod("markers_aio")
local HereticalIdolTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/heretical_idol_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local DestructibleExtension = require("scripts/extension_systems/destructible/destructible_extension")
local UIWidget = require("scripts/managers/ui/ui_widget")
local AchievementCategories = require("scripts/settings/achievements/achievement_categories")

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


mod:hook_safe(
    CLASS.DestructibleExtension, "set_collectible_data", function(self, data)
        mod.add_heretical_idol_marker(self, data.unit, data.section_id)
        self._owner_system:enable_update_function(self.__class_name, "update", data.unit, self)
    end


)

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


mod:hook_safe(
    CLASS.DestructibleExtension, "update", function(self, unit, dt, t)
        if self._collectible_data then
            if self._collectible_data.unit and self._collectible_data.section_id then
                mod.add_heretical_idol_marker(self, self._collectible_data.unit, self._collectible_data.section_id)
            end
        end
    end
)

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

            for i, unit in pairs(totem_units) do
                if self._unit == unit then
                    table.remove(totem_units, i)
                end
            end

            if self._collectible_data then
                if self._collectible_data.unit and self._collectible_data.section_id then
                    mod.remove_heretical_idol_marker(self, self._collectible_data.unit, self._collectible_data.section_id)

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

    for i, unit in pairs(totem_units) do
        if self._unit == unit then
            table.remove(totem_units, i)
        end
    end

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


mod.current_heretical_idol_markers = {}

mod.add_heretical_idol_marker = function(self, unit, section_id)
    if mod:get("heretical_idol_enable") then

        HereticalIdolTemplate.section_id = section_id
        local marker_type = HereticalIdolTemplate.name

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
                    table.insert(markers_list_to_remove, marker)
                    Managers.event:trigger("remove_world_marker", marker.id)
                end
            end
        end
    end
end

local cached_zone_achievement = {
    ["dust"] = nil,
    ["entertainment"] = nil,
    ["operations"] = nil,
    ["hub"] = nil,
    ["placeholder"] = nil,
    ["prologue"] = nil,
    ["tank_foundry"] = nil,
    ["throneside"] = nil,
    ["training_grounds"] = nil,
    ["transit"] = nil,
    ["horde"] = nil,
    ["void"] = nil,
    ["watertown"] = nil,
}

mod.does_player_need_idols = function()
	local mission_manager = Managers.state.mission
    local current_mission = mission_manager and mission_manager:mission()
    local current_mission_zone = current_mission and current_mission.zone_id

    if not current_mission_zone then
        return true
    end

	local player_manager = Managers.player
	local player = player_manager and Managers.player:local_player(1)

    if not player then
        return true
    end

    local achievement_id = cached_zone_achievement[current_mission_zone]

    if achievement_id == nil then
        -- find achievement for destroying idols for current zone
        local achievement_manager = Managers.achievements

        if not achievement_manager then
            return true
        end

        local definitions = achievement_manager:achievement_definitions()

        for _, config in pairs(definitions) do
            local stat_name = config.stat_name
            local category = config.category
            local category_config = AchievementCategories[category]
            local parent_name = category_config.parent_name or category_config.name

            if
                parent_name == "exploration"
                and stat_name
                and stat_name:match(current_mission_zone)
                and stat_name:match("destructible")
                and config.next == nil
            then
                achievement_id = config.id
                break
            end
        end

        -- if there is no heretical idol penances for this zone
        if achievement_id == nil then
            achievement_id = false
        end

        cached_zone_achievement[current_mission_zone] = achievement_id
    end

    if not achievement_id then
        return true
    end

    if Managers.achievements:_achievement_completed(player._local_player_id, achievement_id) then
        return false
    else
        return true
    end
end

mod.update_marker_icon = function(self, marker)

    if marker then
        local max_distance = get_max_distance()

        if marker.type and marker.type == "heretical_idol" then

            marker.markers_aio_type = "heretical_idol"
            -- force hide marker to start, to prevent "pop in" where the marker will briefly appear at max opacity
            marker.widget.alpha_multiplier = 0
            marker.draw = false

            marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/enemy"

            local color_key = "icon"

			if not mod.does_player_need_idols() then
				color_key = marker.markers_aio_type .. "_completed"
			end

			marker.widget.style.icon.color = {
				255,
				mod:get(color_key .. "_colour_R"),
				mod:get(color_key .. "_colour_G"),
				mod:get(color_key .. "_colour_B"),
			}
            marker.widget.style.ring.color = mod.lookup_colour(mod:get("idol_border_colour"))
            marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))
            marker.template.screen_clamp = mod:get("heretical_idol_keep_on_screen")
            marker.block_screen_clamp = false

            local max_spawn_distance_sq = max_distance * max_distance
            HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

            marker.template.max_distance = max_distance
            marker.template.fade_settings.distance_max = max_distance
            marker.template.fade_settings.distance_min = marker.template.max_distance - marker.template.evolve_distance * 2

            -- for i = 0, #markers_list_to_remove do
            --    local remove_marker = markers_list_to_remove[i]
            --    if remove_marker and remove_marker.id == marker.id then
            --        marker.widget.style.icon.color = {255, 255, 0, 0}
            --        table.remove(markers_list_to_remove, i)
            --    end
            -- end
        end
    end
end


