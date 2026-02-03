local mod = get_mod("markers_aio")
local MarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/chest_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ChestExtension = require("scripts/extension_systems/chest/chest_extension")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")

local get_max_distance = function()
    local max_distance = mod:get("chest_max_distance")

    -- foundya Compatibility
    if FoundYa ~= nil then
        -- max_distance = FoundYa:get("max_distance_supply") or mod:get("chest_max_distance") or 30
    end

    if max_distance == nil then
        max_distance = mod:get("chest_max_distance") or 30
    end

    return max_distance
end


HudElementWorldMarkers._get_templates = function(self)
    return self._marker_templates
end

mod.active_chests = {}

mod.check_if_marker_exists_at_pos = function(pos, marker_list)
    for _, marker in pairs(marker_list) do
        if marker.world_position then
            if tostring(marker.world_position:unbox()) == tostring(pos) then
                return marker
            end
        elseif marker.position then
            if tostring(marker.position:unbox()) == tostring(pos) then
                return marker
            end
        end
    end
    return false
end


mod.remove_chest_markers = function(chest_unit, marker_list)
    for _, marker in pairs(marker_list) do
        -- if Unit.alive(chest_unit) then
        --    if marker.data and marker.data.chest_unit and marker.data.chest_unit == chest_unit then
        --    Managers.event:trigger("remove_world_marker", marker.id)
        --    end
        -- end
    end
    return false
end


mod.get_all_items_in_chest = function(self, chest_unit)
    local unit = chest_unit
    local pickup_spawner_extension = ScriptUnit.extension(unit, "pickup_system")
    local containing_pickups = self._chest_extension._containing_pickups
    local chest_size = pickup_spawner_extension:spawner_count()

    local chest_items = {}
    for i = 1, chest_size do
        if containing_pickups[i] or pickup_spawner_extension:request_rubberband_pickup(i) then
            chest_items[#chest_items + 1] = containing_pickups[i]
        end
    end

    return chest_items
end


mod.update_chest_markers = function(self, marker)
    if not (marker and self) then return end

    -- cleanup closed chests
    for key, chest in pairs(mod.active_chests) do
        if chest and chest._current_state ~= "closed" then
            mod.remove_chest_markers(chest._unit, self._markers)
            mod.active_chests[key] = nil
        end
    end

    if not (marker.data and marker.data._active_interaction_type == "chest") then return end

    local unit = marker.unit
    self._chest_extension = self._chest_extension or ScriptUnit.has_extension(unit, "chest_system")
    mod.active_chests[unit] = self._chest_extension

    local max_distance = get_max_distance()
    marker.markers_aio_type = "chest"

    -- initialize once per marker
    if not marker._aio_chest_inited then
        marker._aio_chest_inited = true
        marker._aio_last_ring = nil
        marker._aio_last_bg = nil
        marker._aio_last_icon_color = nil
        marker._aio_last_icon_asset = nil
        marker._aio_last_max_distance = nil
        marker._aio_last_keep_on_screen = nil
    end

    -- ring/background/icon static values
    local ring_colour_key = mod:get("chest_border_colour")
    if marker._aio_last_ring ~= ring_colour_key then
        marker.widget.style.ring.color = mod.lookup_colour(ring_colour_key)
        marker._aio_last_ring = ring_colour_key
    end

    local bg_colour_key = mod:get("marker_background_colour")
    if marker._aio_last_bg ~= bg_colour_key then
        marker.widget.style.background.color = mod.lookup_colour(bg_colour_key)
        marker._aio_last_bg = bg_colour_key
    end

    local icon_color = {255, mod:get("chest_icon_colour_R"), mod:get("chest_icon_colour_G"), mod:get("chest_icon_colour_B")}
    local last = marker._aio_last_icon_color
    if not last or last[2] ~= icon_color[2] or last[3] ~= icon_color[3] or last[4] ~= icon_color[4] then
        marker.widget.style.icon.color = icon_color
        marker._aio_last_icon_color = icon_color
    end

    local icon_asset = mod:get("chest_icon")
    if marker._aio_last_icon_asset ~= icon_asset then
        marker.widget.content.icon = icon_asset
        marker._aio_last_icon_asset = icon_asset
    end

    local keep_on = mod:get("chest_keep_on_screen")
    if marker._aio_last_keep_on_screen ~= keep_on then
        marker.template.screen_clamp = keep_on
        marker.block_screen_clamp = false
        marker._aio_last_keep_on_screen = keep_on
    end

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
end

