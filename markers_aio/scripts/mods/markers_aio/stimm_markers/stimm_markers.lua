local mod = get_mod("markers_aio")


local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")
mod.on_all_mods_loaded = function()
    FoundYa = get_mod("FoundYa") -- grab again incase of load order issues
end

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

            marker.widget.style.ring.color = Color.citadel_auric_armour_gold(nil, true)

            marker.widget.style.icon.color = {255, 95, 158, 160}
            marker.widget.style.background.color = Color.citadel_abaddon_black(nil, true)
            marker.template.check_line_of_sight = mod:get("stimm_require_line_of_sight")

            marker.template.screen_clamp = mod:get("stimm_keep_on_screen")
            marker.block_screen_clamp = false

            marker.widget.content.is_clamped = false

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

            if mod:get("stimm_require_line_of_sight") == true then
                if marker.widget.content.line_of_sight_progress == 1 then
                    if marker.widget.content.is_inside_frustum then
                        marker.widget.alpha_multiplier = mod:get("stimm_alpha")
                        marker.draw = true
                    else
                        marker.widget.alpha_multiplier = 0
                        marker.draw = false
                    end
                end
            else
                if marker.widget.content.is_inside_frustum then
                    marker.widget.alpha_multiplier = mod:get("stimm_alpha")
                    marker.draw = true

                else
                    marker.widget.alpha_multiplier = 0
                    marker.draw = false
                end
            end

            if pickup_type == "syringe_power_boost_pocketable" or marker.data and marker.data.type == "syringe_power_boost_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("power_stimm_icon_colour_R"), mod:get("power_stimm_icon_colour_G"), mod:get("power_stimm_icon_colour_B")
                }

            elseif pickup_type == "syringe_speed_boost_pocketable" or marker.data and marker.data.type == "syringe_speed_boost_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("speed_stimm_icon_colour_R"), mod:get("speed_stimm_icon_colour_G"), mod:get("speed_stimm_icon_colour_B")
                }
            elseif pickup_type == "syringe_ability_boost_pocketable" or marker.data and marker.data.type == "syringe_ability_boost_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("boost_stim_icon_colour_R"), mod:get("boost_stim_icon_colour_G"), mod:get("boost_stim_icon_colour_B")
                }
            elseif pickup_type == "syringe_corruption_pocketable" or marker.data and marker.data.type == "syringe_corruption_pocketable" then
                marker.widget.style.icon.color = {
                    255, mod:get("corruption_stimm_icon_colour_R"), mod:get("corruption_stimm_icon_colour_G"),
                    mod:get("corruption_stimm_icon_colour_B")
                }
            end
        end
    end
end