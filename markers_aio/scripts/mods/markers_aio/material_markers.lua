local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")

local get_max_distance = function()
    local max_distance = mod:get("material_max_distance")

    -- foundya Compatibility
    if FoundYa ~= nil then
        -- max_distance = FoundYa:get("max_distance_material") or mod:get("material_max_distance") or 30
    end

    if max_distance == nil then
        max_distance = mod:get("material_max_distance") or 30
    end

    return max_distance
end


mod.update_material_markers = function(self, marker)
    if not (marker and self) then return end

    local pickup_type = mod.get_marker_pickup_type(marker)
    local data_type = marker.data and marker.data.type
    if not (
        pickup_type == "small_metal" or pickup_type == "large_metal"
        or pickup_type == "small_platinum" or pickup_type == "large_platinum"
        or data_type == "small_metal" or data_type == "large_metal"
        or data_type == "small_platinum" or data_type == "large_platinum"
    ) then
        return
    end

    local max_distance = get_max_distance()
    marker.markers_aio_type = "material"

    if not marker._aio_material_inited then
        marker._aio_material_inited = true
        marker.widget.alpha_multiplier = 0
        marker.draw = false
        marker._aio_last_ring_small = nil
        marker._aio_last_bg = nil
        marker._aio_last_icon_color = nil
        marker._aio_last_icon_asset = nil
        marker._aio_last_max_distance = nil
        marker._aio_last_keep_on_screen = nil
        marker._aio_last_visibility = nil
    end

    -- ring: small vs large
    local is_small = (pickup_type == "small_metal" or pickup_type == "small_platinum" or data_type == "small_metal" or data_type == "small_platinum")
    local ring_key = is_small and mod:get("material_small_border_colour") or mod:get("material_large_border_colour")
    if marker._aio_last_ring_small ~= ring_key then
        marker.widget.style.ring.color = mod.lookup_colour(ring_key)
        marker._aio_last_ring_small = ring_key
    end

    -- background color
    local bg_key = mod:get("marker_background_colour")
    if marker._aio_last_bg ~= bg_key then
        marker.widget.style.background.color = mod.lookup_colour(bg_key)
        marker._aio_last_bg = bg_key
    end

    -- screen clamp
    local keep_on = mod:get("material_keep_on_screen")
    if marker._aio_last_keep_on_screen ~= keep_on then
        marker.template.screen_clamp = keep_on
        marker.block_screen_clamp = false
        marker._aio_last_keep_on_screen = keep_on
    end

    -- distances when changed
    if marker._aio_last_max_distance ~= max_distance then
        local max_sq = max_distance * max_distance
        HUDElementInteractionSettings.max_spawn_distance_sq = max_sq
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

    -- icon asset and color
    local icon_asset = "content/ui/materials/hud/interactions/icons/environment_generic"
    if marker._aio_last_icon_asset ~= icon_asset then
        marker.widget.content.icon = icon_asset
        marker._aio_last_icon_asset = icon_asset
    end
    local icon_color
    if pickup_type == "large_metal" or data_type == "large_metal" or pickup_type == "small_metal" or data_type == "small_metal" then
        icon_color = {255, mod:get("plasteel_icon_colour_R"), mod:get("plasteel_icon_colour_G"), mod:get("plasteel_icon_colour_B")}
    else
        icon_color = {255, mod:get("diamantine_icon_colour_R"), mod:get("diamantine_icon_colour_G"), mod:get("diamantine_icon_colour_B")}
    end
    local last = marker._aio_last_icon_color
    if not last or last[2] ~= icon_color[2] or last[3] ~= icon_color[3] or last[4] ~= icon_color[4] then
        marker.widget.style.icon.color = icon_color
        marker._aio_last_icon_color = icon_color
    end

    -- visibility toggles
    local toggle
    if pickup_type == "large_metal" or data_type == "large_metal" then
        toggle = mod:get("toggle_large_plasteel")
    elseif pickup_type == "small_metal" or data_type == "small_metal" then
        toggle = mod:get("toggle_small_plasteel")
    elseif pickup_type == "small_platinum" or data_type == "small_platinum" then
        toggle = mod:get("toggle_small_diamantine")
    elseif pickup_type == "large_platinum" or data_type == "large_platinum" then
        toggle = mod:get("toggle_large_diamantine")
    end

    local desired_visible = (toggle ~= false) and (marker.widget.content.line_of_sight_progress == 1)
    if marker._aio_last_visibility ~= desired_visible then
        marker.widget.visible = desired_visible
        marker._aio_last_visibility = desired_visible
    end
end


