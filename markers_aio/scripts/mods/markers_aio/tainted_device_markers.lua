local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end


mod.update_TaintedDevices_markers = function(self, marker)

    if marker and self then
        local unit = marker.unit

        local pickup_type = mod.get_marker_pickup_type(marker)

        if pickup_type then
            local pickup = Pickups.by_name[pickup_type]

            if pickup then
                local is_hack_device = false

                if pickup.name and pickup.name == "communications_hack_device" then
                    is_hack_device = true
                end
                if is_hack_device then

                    -- force hide marker to start, to prevent "pop in" where the marker will briefly appear at max opacity
                    marker.widget.alpha_multiplier = 0
                    marker.draw = false

                    marker.markers_aio_type = "tainted"

                    marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))

                    marker.template.check_line_of_sight = mod:get(marker.markers_aio_type .. "_require_line_of_sight")

                    marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")

                    marker.template.screen_clamp = mod:get("tainted_keep_on_screen")
                    marker.block_screen_clamp = false

                    marker.widget.content.icon = "content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner"
                    marker.widget.style.ring.color = mod.lookup_colour(mod:get("tainted_border_colour"))
                    marker.widget.style.icon.color = {
                        255,
                        mod:get("tainted_colour_R"),
                        mod:get("tainted_colour_G"),
                        mod:get("tainted_colour_B")
                    }

                end
            end
        end
    end
end


