local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod.update_unknown_markers = function(self, marker)
	if marker and marker.type and marker.type == "interaction" then
		-- filter out unwanted
		if marker.ui_interaction_type and (marker.ui_interaction_type == "player_interaction") then
			return
		end
		if
			marker.ui_interaction_type
			and (marker.ui_interaction_type == "default" or marker.ui_interaction_type == "point_of_interest")
		then
			marker.widget.style.icon.color = {
				255,
				mod:get("unknown_colour_R"),
				mod:get("unknown_colour_G"),
				mod:get("unknown_colour_B"),
			}

			marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))
			marker.widget.style.ring.color = mod.lookup_colour(mod:get("unknown_border_colour"))

			return
		end

		marker.draw = false
		marker.widget.alpha_multiplier = 0

		marker.markers_aio_type = "unknown"

		marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))

		marker.template.check_line_of_sight = mod:get(marker.markers_aio_type .. "_require_line_of_sight")

		marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
		marker.template.screen_clamp = mod:get(marker.markers_aio_type .. "_keep_on_screen")
		marker.block_screen_clamp = false

		marker.widget.style.icon.color = {
			255,
			mod:get("unknown_colour_R"),
			mod:get("unknown_colour_G"),
			mod:get("unknown_colour_B"),
		}

		marker.widget.style.ring.color = mod.lookup_colour(mod:get("unknown_border_colour"))
	end
end
