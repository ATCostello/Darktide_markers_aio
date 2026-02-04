local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod.update_luggable_markers = function(self, marker)

    if marker and self then
        local unit = marker.unit

        local pickup_type = mod.get_marker_pickup_type(marker)

        if pickup_type and pickup_type == "battery_01_luggable" or pickup_type == "battery_02_luggable" or pickup_type == "container_01_luggable" or pickup_type == "container_02_luggable" or pickup_type == "container_03_luggable" or pickup_type == "control_rod_01_luggable" or pickup_type == "prismata_case_01_luggable" then

            marker.draw = false
            marker.widget.alpha_multiplier = 0

            marker.markers_aio_type = "luggable"

            marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))

            marker.template.check_line_of_sight = mod:get(marker.markers_aio_type .. "_require_line_of_sight")

            marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
            marker.template.screen_clamp = mod:get(marker.markers_aio_type .. "_keep_on_screen")
            marker.block_screen_clamp = false

            marker.widget.content.icon = mod:get("luggable_icon")

            marker.widget.style.ring.color = mod.lookup_colour(mod:get(marker.markers_aio_type .. "_border_colour"))

            marker.widget.style.icon.color = {
                255,
                mod:get(marker.markers_aio_type .. "_colour_R"),
                mod:get(marker.markers_aio_type .. "_colour_G"),
                mod:get(marker.markers_aio_type .. "_colour_B")
            }
        end
    end
end

