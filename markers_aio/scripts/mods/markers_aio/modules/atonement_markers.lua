local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local fs = mod.frame_settings
mod.update_atonement_markers = function(self, marker)
	if marker and self then
		local unit = marker.unit

		local pickup_type = mod.get_marker_pickup_type(marker)

		if pickup_type then
			local pickup = Pickups.by_name[pickup_type]

			if pickup then
				if
					pickup.name
					and (
						pickup.name == "live_event_saints_01_pickup_small"
						or pickup.name == "live_event_saints_01_pickup_medium"
						or pickup.name == "live_event_saints_01_pickup_large"
					)
				then
					marker.draw = false
					marker.widget.alpha_multiplier = 0

					marker.markers_aio_type = "event"

					mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))
					marker.template.check_line_of_sight = fs.event_require_line_of_sight

					marker.template.max_distance = fs.per_type[marker.markers_aio_type].max_distance
					marker.template.screen_clamp = fs.event_keep_on_screen
					marker.block_screen_clamp = false

					marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/objective_side"

					mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.event_border_colour))

					marker.widget.style.icon.size[1] = 32
					marker.widget.style.icon.size[2] = 32

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

		if
			marker
			and marker.data
			and marker.data._override_contexts
			and marker.data._override_contexts.default
			and marker.data._override_contexts.default.action_text
			and marker.data._override_contexts.default.action_text == "loc_saints_shrine_interaction_action_text"
		then
			marker.draw = false
			marker.widget.alpha_multiplier = 0

			marker.markers_aio_type = "event"

			mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))

			marker.template.check_line_of_sight = fs.event_require_line_of_sight

			marker.template.max_distance = fs.per_type[marker.markers_aio_type].max_distance
			marker.template.screen_clamp = false
			marker.block_screen_clamp = false

			marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/enemy"

			mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.event_border_colour))

			mod.set_colour_argb(
				marker.widget.style.icon.color,
				100,
				fs.event_colour_R,
				fs.event_colour_G,
				fs.event_colour_B
			)
		end
	end
end
