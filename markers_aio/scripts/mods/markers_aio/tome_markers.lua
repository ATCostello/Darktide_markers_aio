local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")

local get_max_distance = function()
    local max_distance = mod:get("tome_max_distance")

    -- foundya Compatibility
    if FoundYa ~= nil then
        -- max_distance = FoundYa:get("max_distance_book") or mod:get("tome_max_distance") or 30
    end

    if max_distance == nil then
        max_distance = mod:get("tome_max_distance") or 30
    end

    return max_distance
end


mod.update_tome_markers = function(self, marker)
    if not (marker and self) then return end

    local pickup_type = mod.get_marker_pickup_type(marker)
    if not pickup_type then return end
    local pickup = Pickups.by_name[pickup_type]
    if not (pickup and pickup.is_side_mission_pickup) then return end

    marker.markers_aio_type = "tome"
    if not marker._aio_tome_inited then
        marker._aio_tome_inited = true
        marker.widget.alpha_multiplier = 0
        marker.draw = false
        marker._aio_last_ring = nil
        marker._aio_last_bg = nil
        marker._aio_last_icon_asset = nil
        marker._aio_last_icon_color = nil
        marker._aio_last_keep_on_screen = nil
        marker._aio_last_max_distance = nil
    end

    local ring_key = mod:get("tome_border_colour")
    if marker._aio_last_ring ~= ring_key then
        marker.widget.style.ring.color = mod.lookup_colour(ring_key)
        marker._aio_last_ring = ring_key
    end

    local bg_key = mod:get("marker_background_colour")
    if marker._aio_last_bg ~= bg_key then
        marker.widget.style.background.color = mod.lookup_colour(bg_key)
        marker._aio_last_bg = bg_key
    end

    local keep_on = mod:get("tome_keep_on_screen")
    if marker._aio_last_keep_on_screen ~= keep_on then
        marker.template.screen_clamp = keep_on
        marker.block_screen_clamp = false
        marker._aio_last_keep_on_screen = keep_on
    end

    local max_distance = get_max_distance()
    if marker._aio_last_max_distance ~= max_distance then
        local max_spawn_distance_sq = max_distance * max_distance
        HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

        self.max_distance = max_distance
        if self.fade_settings then
            self.fade_settings.distance_max = max_distance
            self.fade_settings.distance_min = max_distance - (self.evolve_distance or 0) * 2
        end
        marker.template.max_distance = max_distance
        marker.template.fade_settings.distance_max = max_distance
        marker.template.fade_settings.distance_min = marker.template.max_distance - (marker.template.evolve_distance or 0) * 2
        marker._aio_last_max_distance = max_distance
    end

    local icon_asset = "content/ui/materials/hud/interactions/icons/pocketable_default"
    if marker._aio_last_icon_asset ~= icon_asset then
        marker.widget.content.icon = icon_asset
        marker._aio_last_icon_asset = icon_asset
    end

    local icon_color
    if pickup.unit_name == "content/pickups/pocketables/side_mission/grimoire/grimoire_pickup_01" then
        icon_color = {255, mod:get("grim_colour_R"), mod:get("grim_colour_G"), mod:get("grim_colour_B")}
    else
        icon_color = {255, mod:get("script_colour_R"), mod:get("script_colour_G"), mod:get("script_colour_B")}
    end
    local last = marker._aio_last_icon_color
    if not last or last[2] ~= icon_color[2] or last[3] ~= icon_color[3] or last[4] ~= icon_color[4] then
        marker.widget.style.icon.color = icon_color
        marker._aio_last_icon_color = icon_color
    end
end

