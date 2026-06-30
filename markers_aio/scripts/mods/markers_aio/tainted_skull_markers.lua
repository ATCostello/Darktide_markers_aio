local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local fs = mod.frame_settings
mod.update_tainted_skull_markers = function(self, marker)
	if marker and self then
		local unit = marker.unit

		local pickup_type = mod.get_marker_pickup_type(marker)

		if pickup_type then
			local pickup = Pickups.by_name[pickup_type]

			if pickup then
				if pickup.name and pickup.name == "skulls_01_pickup" then
					marker.draw = false
					marker.widget.alpha_multiplier = 0

					marker.markers_aio_type = "event"

					mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))
					marker.template.check_line_of_sight = fs.event_require_line_of_sight

					marker.template.max_distance = fs.per_type[marker.markers_aio_type].max_distance
					marker.template.screen_clamp = fs.event_keep_on_screen
					marker.block_screen_clamp = false

					marker.widget.content.icon = "content/ui/materials/icons/difficulty/flat/difficulty_skull_malice"

					mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.event_border_colour))
					mod.set_colour_argb(
						marker.widget.style.icon.color,
						255,
						fs.event_colour_R,
						fs.event_colour_G,
						fs.event_colour_B
					)
				end
			end
		end

		if marker.type and marker.type == "nurgle_totem" then
			marker.draw = false
			marker.widget.alpha_multiplier = 0

			marker.markers_aio_type = "event"

			mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))
			marker.template.check_line_of_sight = false

			marker.template.max_distance = fs.per_type[marker.markers_aio_type].max_distance
			marker.template.screen_clamp = fs.event_keep_on_screen
			marker.block_screen_clamp = false

			marker.widget.content.icon = "content/ui/materials/icons/circumstances/live_event_01"

			mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.event_border_colour))
			mod.set_colour_argb(
				marker.widget.style.icon.color,
				255,
				fs.event_colour_R,
				fs.event_colour_G,
				fs.event_colour_B
			)

			local max_distance = fs.event_max_distance

			marker.template.max_distance = max_distance
			marker.template.fade_settings.distance_max = max_distance
			marker.template.fade_settings.distance_min = max_distance - marker.template.evolve_distance * 2
			marker.template.scale_settings.distance_max = max_distance
		end
	end
end
