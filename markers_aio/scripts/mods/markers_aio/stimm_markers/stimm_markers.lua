local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")

local get_max_distance = function()
    local max_distance = mod:get("stimm_max_distance")

    -- foundya Compatibility
    if FoundYa ~= nil then
        max_distance = FoundYa:get("max_distance_supply") or mod:get("stimm_max_distance") or 30
    end

    if max_distance == nil then
        max_distance = mod:get("stimm_max_distance") or 30
    end

    return max_distance
end

mod.update_stimm_markers = function(self, marker)
    local max_distance = get_max_distance()

    if marker and self then
        local unit = marker.unit

        local pickup_type = mod.get_marker_pickup_type(marker)

        if pickup_type and pickup_type == "syringe_power_boost_pocketable" or pickup_type and pickup_type == "syringe_speed_boost_pocketable" or
            pickup_type and pickup_type == "syringe_ability_boost_pocketable" or pickup_type and pickup_type == "syringe_corruption_pocketable" or
            marker.data and marker.data.type == "syringe_power_boost_pocketable" or marker.data and marker.data.type ==
            "syringe_speed_boost_pocketable" or marker.data and marker.data.type == "syringe_ability_boost_pocketable" or marker.data and
            marker.data.type == "syringe_corruption_pocketable" then

            marker.draw = false
            marker.widget.alpha_multiplier = 0


            marker.widget.style.icon.color = {255, 95, 158, 160}
            marker.widget.style.background.color = Color.citadel_abaddon_black(nil, true)
            marker.template.check_line_of_sight = mod:get("stimm_require_line_of_sight")

            marker.template.screen_clamp = mod:get("stimm_keep_on_screen")
            marker.block_screen_clamp = false

            -- marker.widget.content.is_clamped = false

            -- set scale
            local scale_settings = {}
            scale_settings["scale_from"] = mod:get("stimm_min_size") or 0.4
            scale_settings["scale_to"] = mod:get("stimm_max_size") or 1
            scale_settings["distance_max"] = 15
            scale_settings["distance_min"] = 1
            scale_settings["easing_function"] = math.easeCubic

            marker.scale = self._get_scale(self, scale_settings, marker.distance) or 1
            self._apply_scale(self, marker.widget, marker.scale)

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

            if pickup_type == "syringe_power_boost_pocketable" or marker.data and marker.data.type == "syringe_power_boost_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("power_stimm_icon_colour_R"), mod:get("power_stimm_icon_colour_G"), mod:get("power_stimm_icon_colour_B")
                }
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("power_stimm_border_colour"))
                dbg_colour = mod.lookup_border_color(mod:get("power_stimm_border_colour"))
            elseif pickup_type == "syringe_speed_boost_pocketable" or marker.data and marker.data.type == "syringe_speed_boost_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("speed_stimm_icon_colour_R"), mod:get("speed_stimm_icon_colour_G"), mod:get("speed_stimm_icon_colour_B")
                }
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("speed_stimm_border_colour"))

            elseif pickup_type == "syringe_ability_boost_pocketable" or marker.data and marker.data.type == "syringe_ability_boost_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("boost_stimm_icon_colour_R"), mod:get("boost_stimm_icon_colour_G"), mod:get("boost_stimm_icon_colour_B")
                }
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("boost_stimm_border_colour"))

            elseif pickup_type == "syringe_corruption_pocketable" or marker.data and marker.data.type == "syringe_corruption_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("corruption_stimm_icon_colour_R"), mod:get("corruption_stimm_icon_colour_G"),
                    mod:get("corruption_stimm_icon_colour_B")
                }
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("corruption_stimm_border_colour"))

            end

            if mod:get("stimm_require_line_of_sight") == true then
                if marker.widget.content.line_of_sight_progress == 1 then
                    if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                        marker.widget.alpha_multiplier = mod:get("stimm_alpha")
                        marker.draw = true
                    else
                        marker.widget.alpha_multiplier = 0
                        marker.draw = false
                    end
                end
            else
                if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                    marker.widget.alpha_multiplier = mod:get("stimm_alpha")
                    marker.draw = true

                else
                    marker.widget.alpha_multiplier = 0
                    marker.draw = false
                end
            end
        end
    end
end

-- update player weapon stimm icon colour
mod:hook_safe(
    CLASS.HudElementPlayerWeapon, "update", function(self, dt, t, ui_renderer)

        local inventory_component = self._inventory_component

        local weapon_name = self._weapon_name
        local widget = self._widgets_by_name.icon

        if weapon_name == "content/items/pocketable/syringe_power_boost_pocketable" then
            local color = {255, mod:get("power_stimm_icon_colour_R"), mod:get("power_stimm_icon_colour_G"), mod:get("power_stimm_icon_colour_B")}
            widget.style.icon.color = color

        elseif weapon_name == "content/items/pocketable/syringe_speed_boost_pocketable" then
            local color = {255, mod:get("speed_stimm_icon_colour_R"), mod:get("speed_stimm_icon_colour_G"), mod:get("speed_stimm_icon_colour_B")}
            widget.style.icon.color = color

        elseif weapon_name == "content/items/pocketable/syringe_ability_boost_pocketable" then
            local color = {255, mod:get("boost_stimm_icon_colour_R"), mod:get("boost_stimm_icon_colour_G"), mod:get("boost_stimm_icon_colour_B")}
            widget.style.icon.color = color

        elseif weapon_name == "content/items/pocketable/syringe_corruption_pocketable" then
            local color = {
                255, mod:get("corruption_stimm_icon_colour_R"), mod:get("corruption_stimm_icon_colour_G"), mod:get("corruption_stimm_icon_colour_B")
            }
            widget.style.icon.color = color

        end
    end
)

-- update team panel stimm icon colour
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")

mod:hook_safe(
    CLASS.HudElementTeamPanelHandler, "update", function(self, dt, t, ui_renderer, render_settings, input_service)
        local weapon_name = ""
        local players = Managers.player:players()
        local player_panels_array = self._player_panels_array

        for _, player in pairs(players) do
            local player_unit = player.player_unit

            if ALIVE[player_unit] then
                -- grab slot_pocketable_small item
                local visual_loadout_extension = ScriptUnit.extension(player_unit, "visual_loadout_system")
                local item = visual_loadout_extension:item_from_slot("slot_pocketable_small")

                if item then
                    weapon_name = item.name

                    -- grab stim widget for player
                    for _, panel_array in pairs(player_panels_array) do
                        if panel_array.player._account_id == player._account_id then

                            local stimm_widget = panel_array.panel._widgets_by_name.pocketable_small

                            if stimm_widget and weapon_name ~= "" then
                                if weapon_name == "content/items/pocketable/syringe_power_boost_pocketable" then
                                    local color = {
                                        255, mod:get("power_stimm_icon_colour_R"), mod:get("power_stimm_icon_colour_G"),
                                        mod:get("power_stimm_icon_colour_B")
                                    }
                                    stimm_widget.style.texture.color = color

                                elseif weapon_name == "content/items/pocketable/syringe_speed_boost_pocketable" then
                                    local color = {
                                        255, mod:get("speed_stimm_icon_colour_R"), mod:get("speed_stimm_icon_colour_G"),
                                        mod:get("speed_stimm_icon_colour_B")
                                    }
                                    stimm_widget.style.texture.color = color

                                elseif weapon_name == "content/items/pocketable/syringe_ability_boost_pocketable" then
                                    local color = {
                                        255, mod:get("boost_stimm_icon_colour_R"), mod:get("boost_stimm_icon_colour_G"),
                                        mod:get("boost_stimm_icon_colour_B")
                                    }
                                    stimm_widget.style.texture.color = color

                                elseif weapon_name == "content/items/pocketable/syringe_corruption_pocketable" then
                                    local color = {
                                        255, mod:get("corruption_stimm_icon_colour_R"), mod:get("corruption_stimm_icon_colour_G"),
                                        mod:get("corruption_stimm_icon_colour_B")
                                    }
                                    stimm_widget.style.texture.color = color

                                end
                            end
                        end
                    end
                end
            end
        end
    end
)
