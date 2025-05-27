local mod = get_mod("markers_aio")
local MarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/ammo_med_markers/ammo_med_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")
mod.on_all_mods_loaded = function()
    FoundYa = get_mod("FoundYa") -- grab again incase of load order issues
end

local get_max_distance = function()
    local max_distance = mod:get("ammo_med_max_distance")

    -- foundya Compatibility
    if FoundYa ~= nil then
        max_distance = FoundYa:get("max_distance_supply") or mod:get("ammo_med_max_distance") or 30
    end

    if max_distance == nil then
        max_distance = mod:get("ammo_med_max_distance") or 30
    end

    return max_distance
end

mod.medical_crate_charges = {}

local ProximityHeal = require("scripts/extension_systems/proximity/side_relation_gameplay_logic/proximity_heal")
ProximityHeal._cb_world_markers_list_request = function(self, world_markers)
    self._world_markers_list = world_markers
end

mod:hook_safe(
    CLASS.ProximityHeal, "update", function(self, dt, t)
        if self then
            local med_crate_pos = POSITION_LOOKUP[self._unit]

            if not table.contains(mod.medical_crate_charges, tostring(med_crate_pos)) then

                local percentage = ((self._heal_reserve - self._amount_of_damage_healed) / self._heal_reserve) * 100
                mod.medical_crate_charges[tostring(med_crate_pos)] = tostring(string.format("%.0f", percentage)) .. "%"

                Managers.event:trigger("request_world_markers_list", callback(self, "_cb_world_markers_list_request"))

                local marker_exists = false
                if self._world_markers_list and not table.is_empty(self._world_markers_list) then
                    for _, marker in pairs(self._world_markers_list) do
                        if marker.type == "interaction" and marker.data._active_interaction_type == "health" then

                        end
                        if marker.unit == self._unit then
                            marker_exists = true
                        end
                    end
                end

                if not marker_exists then
                    Managers.event:trigger("add_world_marker_unit", MarkerTemplate.name, self._unit)
                end
            end
        end
    end
)

mod.update_ammo_med_markers = function(self, marker)
    local max_distance = get_max_distance()

    if marker and self then
        local unit = marker.unit

        local pickup_type = mod.get_marker_pickup_type(marker)

        if pickup_type and pickup_type == "small_clip" or pickup_type and pickup_type == "large_clip" or pickup_type and pickup_type ==
            "small_grenade" or pickup_type and pickup_type == "ammo_cache_pocketable" or pickup_type and pickup_type == "medical_crate_pocketable" or
            pickup_type and pickup_type == "medical_crate_deployable" or pickup_type and pickup_type == "ammo_cache_deployable" or marker.type ==
            MarkerTemplate.name or marker.data and marker.data.type == "small_clip" or marker.data and marker.data.type == "large_clip" or marker.data and
            marker.data.type == "small_grenade" or marker.data and marker.data.type == "ammo_cache_pocketable" or marker.data and marker.data.type ==
            "medical_crate_pocketable" or marker.data and marker.data.type == "medical_crate_deployable" or marker.data and marker.data.type ==
            "ammo_cache_deployable" then

            marker.widget.style.icon.color = {255, 255, 255, 242, 0}
            marker.widget.style.background.color = Color.citadel_abaddon_black(nil, true)
            marker.template.check_line_of_sight = mod:get("ammo_med_require_line_of_sight")

            marker.template.screen_clamp = mod:get("ammo_med_keep_on_screen")
            marker.block_screen_clamp = false

            marker.widget.content.is_clamped = false

            -- set scale
            local scale_settings = {}
            scale_settings["scale_from"] = 0.2
            scale_settings["scale_to"] = mod:get("ammo_med_max_size") or 1
            scale_settings["distance_max"] = 15
            scale_settings["distance_min"] = 1
            scale_settings["easing_function"] = math.easeCubic
            marker.scale = self._get_scale(self, scale_settings, marker.distance) or 1
            self._apply_scale(self, marker.widget, marker.scale)

            local max_spawn_distance_sq = max_distance * max_distance
            HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

            self.max_distance = max_distance

            if self.fade_settings then
                self.fade_settings.distance_max = max_distance
                self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
            end

            marker.template.max_distance = max_distance
            marker.template.fade_settings.distance_max = max_distance
            marker.template.fade_settings.distance_min = marker.template.max_distance - marker.template.evolve_distance * 2

            local med_crate_pos = POSITION_LOOKUP[marker.unit]

            if mod:get("display_med_charges") == true then
                if mod.medical_crate_charges[tostring(med_crate_pos)] ~= nil then
                    marker.widget.content.marker_text = mod.medical_crate_charges[tostring(med_crate_pos)]
                    marker.widget.style.icon.color = {
                        100, mod:get("med_crate_colour_R"), mod:get("med_crate_colour_G"), mod:get("med_crate_colour_B")
                    }
                    marker.widget.style.marker_text.font_size = 14

                end
            end

            if mod:get("display_ammo_charges") == true then
                if pickup_type == "ammo_cache_deployable" or marker.data and marker.data.type == "ammo_cache_deployable" then
                    local game_session = Managers.state.game_session:game_session()
                    local game_object_id = Managers.state.unit_spawner:game_object_id(unit)
                    local remaining_charges = GameSession.game_object_field(game_session, game_object_id, "charges")

                    marker.widget.content.marker_text = tostring(remaining_charges)

                    marker.widget.style.icon.color = {
                        100, mod:get("ammo_crate_colour_R"), mod:get("ammo_crate_colour_G"), mod:get("ammo_crate_colour_B")
                    }

                end
            end

            local max_distance = get_max_distance()

            if mod:get("ammo_med_require_line_of_sight") == true then
                if marker.widget.content.line_of_sight_progress == 1 then
                    if marker.widget.content.is_inside_frustum then
                        marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                        marker.draw = true
                    else
                        marker.widget.alpha_multiplier = 0
                        marker.draw = false
                    end
                end
            else
                if marker.widget.content.is_inside_frustum then
                    marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                    marker.draw = true

                else
                    marker.widget.alpha_multiplier = 0
                    marker.draw = false
                end
            end

            self.max_distance = max_distance

            if self.fade_settings then
                self.fade_settings.distance_max = max_distance
                self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
            end

            if pickup_type == "small_clip" or marker.data and marker.data.type == "small_clip" then
                marker.widget.style.ring.color = Color.citadel_stormhost_silver(nil, true)
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"
                marker.widget.style.icon.color = {255, mod:get("ammo_small_colour_R"), mod:get("ammo_small_colour_G"), mod:get("ammo_small_colour_B")}
            elseif pickup_type == "large_clip" or marker.data and marker.data.type == "large_clip" then
                marker.widget.style.ring.color = Color.citadel_auric_armour_gold(nil, true)
                if mod:get("ammo_med_markers_alternate_large_ammo_icon") == true then
                    marker.widget.content.icon = "content/ui/materials/icons/presets/preset_16"
                else
                    marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"
                end
                marker.widget.style.icon.color = {255, mod:get("ammo_large_colour_R"), mod:get("ammo_large_colour_G"), mod:get("ammo_large_colour_B")}
            elseif pickup_type == "small_grenade" or marker.data and marker.data.type == "small_grenade" then
                marker.widget.style.ring.color = Color.citadel_stormhost_silver(nil, true)
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/grenade"
                marker.widget.style.icon.color = {255, mod:get("grenade_colour_R"), mod:get("grenade_colour_G"), mod:get("grenade_colour_B")}
            elseif pickup_type == "ammo_cache_pocketable" or marker.data and marker.data.type == "ammo_cache_pocketable" then
                marker.widget.style.ring.color = Color.citadel_auric_armour_gold(nil, true)
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"
                marker.widget.style.icon.color = {255, mod:get("ammo_crate_colour_R"), mod:get("ammo_crate_colour_G"), mod:get("ammo_crate_colour_B")}
            elseif pickup_type == "ammo_cache_deployable" or marker.data and marker.data.type == "ammo_cache_deployable" then
                marker.widget.style.ring.color = Color.citadel_auric_armour_gold(nil, true)
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"
            elseif pickup_type == "medical_crate_pocketable" or marker.data and marker.data.type == "medical_crate_pocketable" then
                marker.widget.style.ring.color = Color.citadel_auric_armour_gold(nil, true)
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"
                marker.widget.style.icon.color = {255, mod:get("med_crate_colour_R"), mod:get("med_crate_colour_G"), mod:get("med_crate_colour_B")}
            elseif pickup_type == "medical_crate_deployable" or marker.type == MarkerTemplate.name or marker.data and marker.data.type ==
                "medical_crate_deployable" then
                marker.widget.style.ring.color = Color.citadel_auric_armour_gold(nil, true)
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"
            end
        end
    end
end

-- add new marker text widget to definitions
mod:hook(
    CLASS.HudElementWorldMarkers, "_create_widget", function(func, self, name, definition)

        local marker_text_style = table.clone(UIFontSettings.header_2)

        marker_text_style.horizontal_alignment = "center"
        marker_text_style.vertical_alignment = "center"
        marker_text_style.size = {64, 64}
        marker_text_style.color = Color.ui_hud_green_super_light(255, true)
        marker_text_style.font_size = 22
        marker_text_style.offset = {0, 0, 900}
        marker_text_style.text_color = Color.ui_hud_green_super_light(255, true)
        marker_text_style.text_horizontal_alignment = "center"
        marker_text_style.text_vertical_alignment = "center"

        local marker_text_pass = {
            pass_type = "text", style_id = "marker_text", value = "", value_id = "marker_text", style = marker_text_style,
            visibility_function = function(content, style)
                return content.marker_text ~= nil
            end
        }

        definition.passes[#definition.passes + 1] = table.clone(marker_text_pass)
        definition.style.marker_text = table.clone(marker_text_style)
        definition.content.marker_text = ""

        return func(self, name, definition)
    end
)

