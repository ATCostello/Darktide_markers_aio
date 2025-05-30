local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod.update_tainted_skull_markers = function(self, marker)

    if marker and self then
        local unit = marker.unit

        local pickup_type = mod.get_marker_pickup_type(marker)

        if pickup_type then
            local pickup = Pickups.by_name[pickup_type]

            if pickup then
                local is_tainted_skull = false
                if pickup.name and pickup.name == "skulls_01_pickup" then
                    is_tainted_skull = true
                end
                if is_tainted_skull then

                    marker.draw = false
                    marker.widget.alpha_multiplier = 0

                    marker.markers_aio_type = "tainted_skull"

                    marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))
                    marker.template.check_line_of_sight = mod:get("tainted_skull_require_line_of_sight")

                    marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
                    marker.template.screen_clamp = mod:get("tainted_skull_keep_on_screen")
                    marker.block_screen_clamp = false

                    marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/enemy"

                    marker.widget.style.ring.color = mod.lookup_colour(mod:get("tainted_skull_border_colour"))
                    marker.widget.style.icon.color = {
                        255,
                        mod:get("tainted_skull_colour_R"),
                        mod:get("tainted_skull_colour_G"),
                        mod:get("tainted_skull_colour_B")
                    }

                end
            end
        end

        if marker.type and marker.type == "nurgle_totem" then

            marker.draw = false
            marker.widget.alpha_multiplier = 0

            marker.markers_aio_type = "tainted_skull"

            marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))
            marker.template.check_line_of_sight = false

            marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
            marker.template.screen_clamp = true
            marker.block_screen_clamp = false

            marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/enemy"

            marker.widget.style.ring.color = mod.lookup_colour(mod:get("tainted_skull_border_colour"))
            marker.widget.style.icon.color = {
                255,
                mod:get("tainted_skull_colour_R"),
                mod:get("tainted_skull_colour_G"),
                mod:get("tainted_skull_colour_B")
            }
        end
    end
end

