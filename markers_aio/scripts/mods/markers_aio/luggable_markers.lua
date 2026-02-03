local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod.update_luggable_markers = function(self, marker)
    if not (marker and self) then return end

    local pt = mod.get_marker_pickup_type(marker)
    if not (
        pt == "battery_01_luggable" or pt == "battery_02_luggable" or pt == "container_01_luggable" or
        pt == "container_02_luggable" or pt == "container_03_luggable" or pt == "control_rod_01_luggable" or
        pt == "prismata_case_01_luggable"
    ) then return end

    marker.markers_aio_type = "luggable"

    if not marker._aio_luggable_inited then
        marker._aio_luggable_inited = true
        marker.draw = false
        marker.widget.alpha_multiplier = 0
        marker._aio_last_bg = nil
        marker._aio_last_ring = nil
        marker._aio_last_icon_color = nil
        marker._aio_last_icon_asset = nil
        marker._aio_last_keep_on_screen = nil
        marker._aio_last_max_distance = nil
        marker._aio_last_los_req = nil
    end

    -- colors/background
    local bg_key = mod:get("marker_background_colour")
    if marker._aio_last_bg ~= bg_key then
        marker.widget.style.background.color = mod.lookup_colour(bg_key)
        marker._aio_last_bg = bg_key
    end

    local ring_key = mod:get("luggable_border_colour")
    if marker._aio_last_ring ~= ring_key then
        marker.widget.style.ring.color = mod.lookup_colour(ring_key)
        marker._aio_last_ring = ring_key
    end

    local icon_color = {255, mod:get("luggable_colour_R"), mod:get("luggable_colour_G"), mod:get("luggable_colour_B")}
    local last = marker._aio_last_icon_color
    if not last or last[2] ~= icon_color[2] or last[3] ~= icon_color[3] or last[4] ~= icon_color[4] then
        marker.widget.style.icon.color = icon_color
        marker._aio_last_icon_color = icon_color
    end

    -- icon asset
    local icon_asset = mod:get("luggable_icon")
    if marker._aio_last_icon_asset ~= icon_asset then
        marker.widget.content.icon = icon_asset
        marker._aio_last_icon_asset = icon_asset
    end

    -- screen clamp / los / distance
    local keep_on = mod:get("luggable_keep_on_screen")
    if marker._aio_last_keep_on_screen ~= keep_on then
        marker.template.screen_clamp = keep_on
        marker.block_screen_clamp = false
        marker._aio_last_keep_on_screen = keep_on
    end

    local los_req = mod:get("luggable_require_line_of_sight")
    if marker._aio_last_los_req ~= los_req then
        marker.template.check_line_of_sight = los_req
        marker._aio_last_los_req = los_req
    end

    local max_distance = mod:get("luggable_max_distance")
    if marker._aio_last_max_distance ~= max_distance then
        marker.template.max_distance = max_distance
        marker._aio_last_max_distance = max_distance
    end
end

