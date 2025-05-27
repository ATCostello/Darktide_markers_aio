local mod = get_mod("markers_aio")
local MarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/chest_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ChestExtension = require("scripts/extension_systems/chest/chest_extension")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")

local get_max_distance = function()
    local max_distance = mod:get("chest_max_distance")

    -- foundya Compatibility
    if FoundYa ~= nil then
        max_distance = FoundYa:get("max_distance_supply") or mod:get("chest_max_distance") or 30
    end

    if max_distance == nil then
        max_distance = mod:get("chest_max_distance") or 30
    end

    return max_distance
end

HudElementWorldMarkers._get_templates = function(self)
    return self._marker_templates
end
mod.active_chests = {}

mod.check_if_marker_exists_at_pos = function(pos, marker_list)
    for _, marker in pairs(marker_list) do
        if marker.world_position then
            if tostring(marker.world_position:unbox()) == tostring(pos) then
                return marker
            end
        elseif marker.position then
            if tostring(marker.position:unbox()) == tostring(pos) then
                return marker
            end
        end
    end
    return false
end

mod.remove_chest_markers = function(chest_unit, marker_list)
    for _, marker in pairs(marker_list) do
        -- if Unit.alive(chest_unit) then
        --    if marker.data and marker.data.chest_unit and marker.data.chest_unit == chest_unit then
        --    Managers.event:trigger("remove_world_marker", marker.id)
        --    end
        -- end
    end
    return false
end

mod.get_all_items_in_chest = function(self, chest_unit)
    local unit = chest_unit
    local pickup_spawner_extension = ScriptUnit.extension(unit, "pickup_system")
    local containing_pickups = self._chest_extension._containing_pickups
    local chest_size = pickup_spawner_extension:spawner_count()

    local chest_items = {}
    for i = 1, chest_size do
        if containing_pickups[i] or pickup_spawner_extension:request_rubberband_pickup(i) then
            chest_items[#chest_items + 1] = containing_pickups[i]
        end
    end

    return chest_items
end

mod.update_chest_markers = function(self, marker)
    local max_distance = get_max_distance()

    for _, chest in pairs(mod.active_chests) do
        if chest and chest._current_state ~= "closed" then
            mod.remove_chest_markers(chest._unit, self._markers)
            mod.active_chests[_] = nil
        end
    end

    if marker and self then
        local unit = marker.unit
        if marker.data and marker.data._active_interaction_type == "chest" then

            self._chest_extension = ScriptUnit.has_extension(unit, "chest_system")

            mod.active_chests[unit] = self._chest_extension
            local chest_items = {}

            -- Retrieve all items within chests, only works in private lobbies... Disabled for now 
            --[[if self._chest_extension then
                chest_items = mod.get_all_items_in_chest(self, unit)

                local local_player = Managers.player:local_player(1)
                local local_player_unit = local_player.player_unit

                local chest_pos = POSITION_LOOKUP[unit]

                local tx, ty, tz = Vector3.to_elements(chest_pos)
                tx = tonumber(string.format("%.2f", tx))
                ty = tonumber(string.format("%.2f", ty))
                tz = tonumber(string.format("%.2f", tz))

                for _, pickup_name in pairs(chest_items) do

                    tz = tz + (0.2 * _)

                    local absolute_position = Vector3(tx, ty, tz)

                    local current_marker = mod.check_if_marker_exists_at_pos(absolute_position, self._markers)
                    if current_marker == false then
                        Managers.event:trigger("add_world_marker_position", MarkerTemplate.name, absolute_position)
                    else
                        current_marker.data.chest_unit = unit

                        local max_distance = get_max_distance()

                        -- force hide marker to start, to prevent "pop in" where the marker will briefly appear at max opacity
                        marker.widget.alpha_multiplier = 0
                        marker.draw = false
                        current_marker.widget.alpha_multiplier = 0
                        current_marker.draw = false

                        local max_spawn_distance_sq = max_distance * max_distance
                        HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

                        self.max_distance = max_distance

                        if self.fade_settings then
                            self.fade_settings.distance_max = max_distance
                            self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
                        end

                        current_marker.raycast_result = marker.raycast_result
                        current_marker.template.max_distance = max_distance
                        current_marker.template.fade_settings.distance_max = max_distance
                        current_marker.template.fade_settings.distance_min =
                            current_marker.template.max_distance - current_marker.template.evolve_distance * 2

                        self.max_distance = max_distance
                        if self.fade_settings then
                            self.fade_settings.distance_max = max_distance
                            self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
                        end

                        -- MARKER EXISTS, NEED TO CHANGE TO THE TYPE OF ITEM INSIDE (showing default icon styles)... (also update my other marker mods to work with this (update the icons properly))
                        if pickup_name == "large_metal" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/environment_generic"
                            current_marker.data.type = "large_metal"

                        elseif pickup_name == "small_metal" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/environment_generic"
                            current_marker.data.type = "small_metal"

                        elseif pickup_name == "large_platinum" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/environment_generic"
                            current_marker.data.type = "large_platinum"

                        elseif pickup_name == "small_platinum" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/environment_generic"
                            current_marker.data.type = "small_platinum"

                        elseif pickup_name == "small_clip" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"
                            current_marker.data.type = "small_clip"

                        elseif pickup_name == "large_clip" then
                            current_marker.widget.content.icon = "content/ui/materials/icons/presets/preset_16"
                            current_marker.data.type = "large_clip"

                        elseif pickup_name == "small_grenade" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/grenade"
                            current_marker.data.type = "small_grenade"

                        elseif pickup_name == "ammo_cache_pocketable" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"
                            current_marker.data.type = "ammo_cache_pocketable"

                        elseif pickup_name == "medical_crate_pocketable" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"
                            current_marker.data.type = "medical_crate_pocketable"

                        elseif pickup_name == "syringe_ability_boost_pocketable" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_syringe_ability"
                            current_marker.data.type = "syringe_ability_boost_pocketable"

                        elseif pickup_name == "syringe_corruption_pocketable" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_syringe_corruption"
                            current_marker.data.type = "syringe_corruption_pocketable"

                        elseif pickup_name == "syringe_power_boost_pocketable" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_syringe_power"
                            current_marker.data.type = "syringe_power_boost_pocketable"

                        elseif pickup_name == "syringe_speed_boost_pocketable" then
                            current_marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_syringe_speed"
                            current_marker.data.type = "syringe_speed_boost_pocketable"
                        end
                    end

                end

                if #chest_items == 0 then
                    mod.remove_chest_markers(unit, self._markers)
                end
            end]]

            marker.markers_aio_type = "chest"

            marker.widget.style.ring.color = mod.lookup_border_color(mod:get("chest_border_colour"))

            marker.widget.style.icon.color = {255, 95, 158, 160}
            marker.widget.style.background.color = Color.citadel_abaddon_black(nil, true)

            marker.template.screen_clamp = mod:get("chest_keep_on_screen")
            marker.block_screen_clamp = false

            -- marker.widget.content.is_clamped = false

            local max_spawn_distance_sq = max_distance * max_distance
            HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

            self.max_distance = max_distance

            if self.fade_settings then
                self.fade_settings.distance_max = max_distance
                self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
            end

            marker.template.max_distance = max_distance
            marker.template.fade_settings.distance_max = max_distance
            marker.template.fade_settings.distance_min = marker.template.max_distance - marker.template.evolve_distance * 2

            self.max_distance = max_distance
            if self.fade_settings then
                self.fade_settings.distance_max = max_distance
                self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
            end

            marker.widget.style.icon.color = {255, mod:get("chest_icon_colour_R"), mod:get("chest_icon_colour_G"), mod:get("chest_icon_colour_B")}
            marker.widget.content.icon = mod:get("chest_icon")
        end

    end
end
