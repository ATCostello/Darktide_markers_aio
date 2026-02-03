local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod.update_atonement_markers = function(self, marker)
	if not (marker and self) then return end

	local pt = mod.get_marker_pickup_type(marker)
	local is_atonement_pickup = false
	if pt then
		local pickup = Pickups.by_name[pt]
		if pickup and pickup.name and (pickup.name == "live_event_saints_01_pickup_small"
			or pickup.name == "live_event_saints_01_pickup_medium"
			or pickup.name == "live_event_saints_01_pickup_large") then
			is_atonement_pickup = true
		end
	end
	local is_shrine = marker.data and marker.data._override_contexts and marker.data._override_contexts.default
		and marker.data._override_contexts.default.action_text == "loc_saints_shrine_interaction_action_text"
	if not (is_atonement_pickup or is_shrine) then return end

	marker.markers_aio_type = "event"
	if not marker._aio_event_atonement_inited then
		marker._aio_event_atonement_inited = true
		marker.draw = false
		marker.widget.alpha_multiplier = 0
		marker._aio_last_bg = nil
		marker._aio_last_ring = nil
		marker._aio_last_icon_color = nil
		marker._aio_last_icon_asset = nil
		marker._aio_last_keep_on_screen = nil
		marker._aio_last_max_distance = nil
		marker._aio_last_los_req = nil
		marker._aio_last_icon_size = {0,0}
	end

	local bg_key = mod:get("marker_background_colour")
	if marker._aio_last_bg ~= bg_key then
		marker.widget.style.background.color = mod.lookup_colour(bg_key)
		marker._aio_last_bg = bg_key
	end

	local los_req = mod:get("event_require_line_of_sight")
	if marker._aio_last_los_req ~= los_req then
		marker.template.check_line_of_sight = los_req
		marker._aio_last_los_req = los_req
	end

	local max_distance = mod:get("event_max_distance")
	if marker._aio_last_max_distance ~= max_distance then
		marker.template.max_distance = max_distance
		marker._aio_last_max_distance = max_distance
	end

	local keep_on = is_shrine and false or mod:get("event_keep_on_screen")
	if marker._aio_last_keep_on_screen ~= keep_on then
		marker.template.screen_clamp = keep_on
		marker.block_screen_clamp = false
		marker._aio_last_keep_on_screen = keep_on
	end

	local icon_asset = is_shrine and "content/ui/materials/hud/interactions/icons/enemy"
		or "content/ui/materials/hud/interactions/icons/objective_side"
	if marker._aio_last_icon_asset ~= icon_asset then
		marker.widget.content.icon = icon_asset
		marker._aio_last_icon_asset = icon_asset
	end

	local ring_key = mod:get("event_border_colour")
	if marker._aio_last_ring ~= ring_key then
		marker.widget.style.ring.color = mod.lookup_colour(ring_key)
		marker._aio_last_ring = ring_key
	end

	local icon_color = {255, mod:get("event_colour_R"), mod:get("event_colour_G"), mod:get("event_colour_B")}
	local last = marker._aio_last_icon_color
	if not last or last[2] ~= icon_color[2] or last[3] ~= icon_color[3] or last[4] ~= icon_color[4] then
		marker.widget.style.icon.color = icon_color
		marker._aio_last_icon_color = icon_color
	end

	if not is_shrine then
		local size = marker.widget.style.icon.size
		if marker._aio_last_icon_size[1] ~= 32 or marker._aio_last_icon_size[2] ~= 32 then
			size[1] = 32; size[2] = 32
			marker._aio_last_icon_size[1], marker._aio_last_icon_size[2] = 32, 32
		end
	end
end
