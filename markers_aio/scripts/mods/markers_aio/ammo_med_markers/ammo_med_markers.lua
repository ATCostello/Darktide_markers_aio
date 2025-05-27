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
    local is_mod_loading = true
    mod:hook_require(
        "scripts/extension_systems/unit_templates", function(instance)
            if is_mod_loading then
                -- works in live games
                mod:hook_safe(
                    instance.medical_crate_deployable, "husk_init", function(unit, config, template_context, game_session, game_object_id, owner_id)
                        mod.add_medkit_marker_and_proximity(nil, unit)
                    end
                )

                -- works in private games
                mod:hook_safe(
                    instance.medical_crate_deployable, "local_unit_spawned",
                    function(unit, template_context, game_object_data, side_id, deployable, placed_on_unit, owner_unit_or_nil)
                        mod.add_medkit_marker_and_proximity(nil, unit)
                    end
                )

                is_mod_loading = false
            end
        end
    )

    FoundYa = get_mod("FoundYa") -- grab again incase of load order issues

    local load_package = function(path, id)
        if not Managers.package:has_loaded(path) then
            Managers.package:load(path, id)
            return
        end
    end

    load_package("content/levels/training_grounds/missions/mission_tg_basic_combat_01", "medkit_radius")
    load_package("packages/ui/views/options_view/options_view", "large_ammo1")
    load_package("packages/ui/views/inventory_background_view/inventory_background_view", "large_ammo2")

end

local get_max_distance = function()
    local max_distance = mod:get("ammo_med_max_distance")

    -- foundya Compatibility
    if FoundYa ~= nil then
        max_distance = FoundYa:get("max_distance_supply") or mod:get("ammo_med_max_distance")
    end

    if max_distance == nil then
        max_distance = mod:get("ammo_med_max_distance")
    end

    return max_distance
end

mod.medical_crate_charges = {}

local med_crate_decals = mod:persistent_table("med_crate_decals")

local ProximityHeal = require("scripts/extension_systems/proximity/side_relation_gameplay_logic/proximity_heal")

ProximityHeal._cb_world_markers_list_request = function(self, world_markers)
    self._world_markers_list = world_markers
end

mod:hook_safe(
    ProximityHeal, "update", function(self, dt, t)
        if self and self._unit then
            local med_crate_pos = POSITION_LOOKUP[self._unit]

            if not table.contains(mod.medical_crate_charges, tostring(med_crate_pos)) then
                local percentage = ((self._heal_reserve - self._amount_of_damage_healed) / self._heal_reserve) * 100
                mod.medical_crate_charges[tostring(med_crate_pos)] = tostring(string.format("%.0f", percentage)) .. "%"
            end
        end
    end
)

mod.add_medkit_marker_and_proximity = function(self, unit)
    local marker_exists = false
    if self and self._world_markers_list and not table.is_empty(self._world_markers_list) then
        for _, marker in pairs(self._world_markers_list) do
            if marker.type == "interaction" and marker.data._active_interaction_type == "health" then

            end
            if marker.unit == self._unit then
                marker_exists = true
            end
        end
    end

    if not marker_exists then
        Managers.event:trigger("add_world_marker_unit", MarkerTemplate.name, unit)
    end

    -- add proximity circle to medkits, thanks Raindish! (From NumericUI)
    if mod:get("display_med_ring") == true and unit then
        local package_path = "content/levels/training_grounds/missions/mission_tg_basic_combat_01"
        if not Managers.package:has_loaded(package_path) then
            Managers.package:load(package_path, "ammo_med_markers")
            return
        end

        local decal_unit_name = "content/levels/training_grounds/fx/decal_aoe_indicator"
        local medical_crate_config = require("scripts/settings/deployables/templates/medical_crate")        
        
        local world = Unit.world(unit)
        local position = Unit.local_position(unit, 1)
        if world and position then
            local tx, ty, tz = Vector3.to_elements(position)
            tx = tonumber(string.format("%.2f", tx))
            ty = tonumber(string.format("%.2f", ty))
            tz = tonumber(string.format("%.2f", tz))
            local position_string = tostring(tx) .. "," .. tostring(ty) .. "," .. tostring(tz)

            if not med_crate_decals[position_string] or med_crate_decals[position_string] == nil then
                -- Create decal unit
                local decal_unit = World.spawn_unit_ex(world, decal_unit_name, nil, position + Vector3(0, 0, 0.1))
                if decal_unit then
                    -- Set size of unit
                    local diameter = medical_crate_config.proximity_radius * 2 + 1.5
                    Unit.set_local_scale(decal_unit, 1, Vector3(diameter, diameter, 1))

                    -- Set color of unit
                    local material_value = Quaternion.identity()

                    local field_improv_active = mod.check_players_talents_for_Field_Improvisation()

                    if field_improv_active and mod:get("display_field_improv_colour") == true then
                        Quaternion.set_xyzw(material_value, 1, 0.1, 1, 0.5)
                    else
                        Quaternion.set_xyzw(material_value, 0, 1, 0, 0.5)
                    end
                    Unit.set_vector4_for_material(decal_unit, "projector", "particle_color", material_value, true)

                    -- Set low opacity
                    Unit.set_scalar_for_material(decal_unit, "projector", "color_multiplier", 0.06)
                    med_crate_decals[position_string] = {decal_unit, unit}
                end
            end
        end
    end
end

mod.check_players_talents_for_Field_Improvisation = function()
    alive_players = Managers.state.player_unit_spawn:alive_players()

    if alive_players then
        for _, player in pairs(alive_players) do
            if player and player._profile and player._profile.talents then
                for talent, boolean in pairs(player._profile.talents) do
                    if talent == "veteran_better_deployables" and boolean == 1 then
                        return true
                    end
                end
            end
        end
    end

end

mod.update_ammo_med_markers = function(self, marker)
    local max_distance = get_max_distance()

    -- remove med proximity circle 
    for posstr, array in pairs(med_crate_decals) do
        local unit = array[2]
        local decal_unit = array[1]
        local world

        if not Unit.alive(unit) and Unit.alive(decal_unit) then
            world = Unit.world(decal_unit)
        end

        if decal_unit and world then
            World.destroy_unit(world, decal_unit)
            med_crate_decals[posstr] = nil
        end

        if not Unit.alive(unit) and not Unit.alive(decal_unit) then
            med_crate_decals[posstr] = nil
        end
    end

    if marker and self then
        local unit = marker.unit

        local pickup_type = mod.get_marker_pickup_type(marker)

        if pickup_type and pickup_type == "small_clip" or pickup_type and pickup_type == "large_clip" or pickup_type and pickup_type ==
            "small_grenade" or pickup_type and pickup_type == "ammo_cache_pocketable" or pickup_type and pickup_type == "medical_crate_pocketable" or
            pickup_type and pickup_type == "medical_crate_deployable" or pickup_type and pickup_type == "ammo_cache_deployable" or marker.type ==
            MarkerTemplate.name or marker.data and marker.data.type == "small_clip" or marker.data and marker.data.type == "large_clip" or marker.data and
            marker.data.type == "small_grenade" or marker.data and marker.data.type == "ammo_cache_pocketable" or marker.data and marker.data.type ==
            "medical_crate_pocketable" or marker.data and marker.data.type == "medical_crate_deployable" or marker.data and marker.data.type ==
            "ammo_cache_deployable" or marker.data and marker.data._active_interaction_type == "health_station" then

            marker.draw = false
            marker.widget.alpha_multiplier = 0

            marker.widget.style.icon.color = {255, 255, 255, 242, 0}
            marker.widget.style.background.color = Color.citadel_abaddon_black(nil, true)
            marker.template.check_line_of_sight = mod:get("ammo_med_require_line_of_sight")

            marker.template.screen_clamp = mod:get("ammo_med_keep_on_screen")
            marker.block_screen_clamp = false

            -- set scale
            local scale_settings = {}
            scale_settings["scale_from"] = mod:get("ammo_med_min_size") or 0.4
            scale_settings["scale_to"] = mod:get("ammo_med_max_size") or 1
            scale_settings["distance_max"] = 30
            scale_settings["distance_min"] = 1
            scale_settings["easing_function"] = math.easeCubic
            marker.template.scale_settings = scale_settings

            MarkerTemplate.scale_settings = scale_settings
            self._marker_templates[MarkerTemplate.name] = MarkerTemplate
            self._apply_scale(self, marker.widget, marker.scale)

            local max_spawn_distance_sq = max_distance * max_distance
            HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

            self.max_distance = max_distance

            if self.fade_settings then
                self.fade_settings.distance_max = max_distance
                self.fade_settings.distance_min = max_distance - self.evolve_distance * 4
            end

            marker.template.max_distance = max_distance
            marker.template.fade_settings.distance_max = max_distance
            marker.template.fade_settings.distance_min = marker.template.max_distance - marker.template.evolve_distance * 8

            local med_crate_pos = POSITION_LOOKUP[marker.unit]

            if mod:get("display_med_charges") == true then
                if mod.medical_crate_charges[tostring(med_crate_pos)] ~= nil then
                    marker.widget.content.marker_text = mod.medical_crate_charges[tostring(med_crate_pos)]
                    marker.widget.style.icon.color = {
                        100, mod:get("med_crate_colour_R"), mod:get("med_crate_colour_G"), mod:get("med_crate_colour_B")
                    }
                    marker.widget.style.marker_text.font_size = 14
                end

                if marker.data and marker.data._active_interaction_type == "health_station" then
                    local health_station_extension = ScriptUnit.fetch_component_extension(unit, "health_station_system")

                    local remaining_charges = health_station_extension._charge_amount
                    marker.widget.style.marker_text.font_size = marker.widget.style.icon.size[1]

                    marker.widget.content.marker_text = tostring(remaining_charges)

                    if mod:get("change_colour_for_ammo_charges") == true then
                        if remaining_charges == 4 then
                            marker.widget.style.background.color = {255, 0, 150, 0}
                        elseif remaining_charges == 3 then
                            marker.widget.style.background.color = {255, 150, 150, 0}
                        elseif remaining_charges == 2 then
                            marker.widget.style.background.color = {255, 150, 100, 0}
                        elseif remaining_charges == 1 then
                            marker.widget.style.background.color = {255, 150, 0, 0}
                        end
                    end

                    marker.widget.style.icon.color = {
                        100, mod:get("med_crate_colour_R"), mod:get("med_crate_colour_G"), mod:get("med_crate_colour_B")
                    }


                    if mod:get("ammo_med_require_line_of_sight") == true then
                        if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                            marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                            marker.draw = true
                        else
                            marker.widget.alpha_multiplier = 0
                            marker.draw = false
                        end
                    else
                        if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                            marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                            marker.draw = true
                        else
                            marker.widget.alpha_multiplier = 0
                            marker.draw = false
                        end
                    end

                end
            end

            local field_improv_active = mod.check_players_talents_for_Field_Improvisation()

            if mod:get("display_ammo_charges") == true then
                if pickup_type == "ammo_cache_deployable" or marker.data and marker.data.type == "ammo_cache_deployable" then
                    local game_session = Managers.state.game_session:game_session()
                    local game_object_id = Managers.state.unit_spawner:game_object_id(unit)
                    local remaining_charges = GameSession.game_object_field(game_session, game_object_id, "charges")

                    marker.widget.style.marker_text.font_size = marker.widget.style.icon.size[1]

                    marker.widget.content.marker_text = tostring(remaining_charges)

                    if mod:get("change_colour_for_ammo_charges") == true then
                        if remaining_charges == 4 then
                            marker.widget.style.background.color = {255, 0, 150, 0}
                        elseif remaining_charges == 3 then
                            marker.widget.style.background.color = {255, 150, 150, 0}
                        elseif remaining_charges == 2 then
                            marker.widget.style.background.color = {255, 150, 100, 0}
                        elseif remaining_charges == 1 then
                            marker.widget.style.background.color = {255, 150, 0, 0}
                        end
                    end

                    marker.widget.style.icon.color = {
                        100, mod:get("ammo_crate_colour_R"), mod:get("ammo_crate_colour_G"), mod:get("ammo_crate_colour_B")
                    }
                    dbg_1 = mod:get("ammo_med_require_line_of_sight")
                    if mod:get("ammo_med_require_line_of_sight") == true then
                        if marker.widget.content.line_of_sight_progress == 1 then
                            if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                                marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                                marker.draw = true
                            else
                                marker.widget.alpha_multiplier = 0
                                marker.draw = false
                            end
                        end
                    else
                        if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                            marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                            marker.draw = true
                        else
                            marker.widget.alpha_multiplier = 0
                            marker.draw = false
                        end
                    end
                end
            end

            local max_distance = get_max_distance()

            self.max_distance = max_distance

            if self.fade_settings then
                self.fade_settings.distance_max = max_distance
                self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
            end

            if pickup_type == "small_clip" or marker.data and marker.data.type == "small_clip" then
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("ammo_small_border_colour"))
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"
                marker.widget.style.icon.color = {255, mod:get("ammo_small_colour_R"), mod:get("ammo_small_colour_G"), mod:get("ammo_small_colour_B")}
            elseif pickup_type == "large_clip" or marker.data and marker.data.type == "large_clip" then
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("ammo_large_border_colour"))
                if mod:get("ammo_med_markers_alternate_large_ammo_icon") == true then
                    marker.widget.content.icon = "content/ui/materials/icons/presets/preset_16"
                else
                    marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"
                end
                marker.widget.style.icon.color = {255, mod:get("ammo_large_colour_R"), mod:get("ammo_large_colour_G"), mod:get("ammo_large_colour_B")}
            elseif pickup_type == "small_grenade" or marker.data and marker.data.type == "small_grenade" then
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("grenade_border_colour"))
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/grenade"
                marker.widget.style.icon.color = {255, mod:get("grenade_colour_R"), mod:get("grenade_colour_G"), mod:get("grenade_colour_B")}
            elseif pickup_type == "ammo_cache_pocketable" or marker.data and marker.data.type == "ammo_cache_pocketable" then
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("ammo_crate_border_colour"))
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"
                marker.widget.style.icon.color = {255, mod:get("ammo_crate_colour_R"), mod:get("ammo_crate_colour_G"), mod:get("ammo_crate_colour_B")}

                if field_improv_active then
                    if mod:get("display_field_improv_colour") == true then
                        marker.widget.style.ring.color = Color.citadel_wild_rider_red(nil, true)
                    end
                    if mod:get("display_field_improv_icon") == true then
                        marker.widget.content.field_improv = "content/ui/materials/hud/interactions/icons/cosmetics_store"
                    end
                else
                    marker.widget.content.field_improv = ""
                end

                marker.widget.style.field_improv.size[1] = marker.widget.style.icon.size[1]
                marker.widget.style.field_improv.size[2] = marker.widget.style.icon.size[2]

                marker.widget.style.field_improv.offset[1] = 35 * marker.scale
            elseif pickup_type == "ammo_cache_deployable" or marker.data and marker.data.type == "ammo_cache_deployable" then

                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("ammo_crate_border_colour"))

                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"

                if field_improv_active then
                    if mod:get("display_field_improv_colour") == true then
                        marker.widget.style.ring.color = Color.citadel_wild_rider_red(nil, true)
                    end
                    if mod:get("display_field_improv_icon") == true then
                        marker.widget.content.field_improv = "content/ui/materials/hud/interactions/icons/cosmetics_store"
                    end
                else
                    marker.widget.content.field_improv = ""
                end

                marker.widget.style.field_improv.size[1] = marker.widget.style.icon.size[1]
                marker.widget.style.field_improv.size[2] = marker.widget.style.icon.size[2]

                marker.widget.style.field_improv.offset[1] = 35 * marker.scale
            elseif pickup_type == "medical_crate_pocketable" or marker.data and marker.data.type == "medical_crate_pocketable" then
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("med_crate_border_colour"))
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"
                marker.widget.style.icon.color = {255, mod:get("med_crate_colour_R"), mod:get("med_crate_colour_G"), mod:get("med_crate_colour_B")}

                if field_improv_active then
                    if mod:get("display_field_improv_colour") == true then
                        marker.widget.style.ring.color = Color.citadel_wild_rider_red(nil, true)
                    end
                    if mod:get("display_field_improv_icon") == true then
                        marker.widget.content.field_improv = "content/ui/materials/hud/interactions/icons/cosmetics_store"
                    end
                else
                    marker.widget.content.field_improv = ""
                end

                marker.widget.style.field_improv.size[1] = marker.widget.style.icon.size[1]
                marker.widget.style.field_improv.size[2] = marker.widget.style.icon.size[2]

                marker.widget.style.field_improv.offset[1] = 35 * marker.scale
            elseif pickup_type == "medical_crate_deployable" or marker.type == MarkerTemplate.name or marker.data and marker.data.type ==
                "medical_crate_deployable" then
                marker.widget.style.ring.color = mod.lookup_border_color(mod:get("med_crate_border_colour"))
                marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"

                if field_improv_active then
                    if mod:get("display_field_improv_colour") == true then
                        marker.widget.style.ring.color = Color.citadel_wild_rider_red(nil, true)
                    end
                    if mod:get("display_field_improv_icon") == true then
                        marker.widget.content.field_improv = "content/ui/materials/hud/interactions/icons/cosmetics_store"
                    end
                else
                    marker.widget.content.field_improv = ""
                end

                marker.scale = self._get_scale(self, scale_settings, marker.distance) or 1
                self._apply_scale(self, marker.widget, marker.scale)

                marker.widget.style.background.size[1] = marker.widget.style.background.size[1] * marker.scale
                marker.widget.style.background.size[2] = marker.widget.style.background.size[2] * marker.scale

                marker.widget.style.icon.size[1] = marker.widget.style.icon.size[1] * marker.scale
                marker.widget.style.icon.size[2] = marker.widget.style.icon.size[2] * marker.scale

                marker.widget.style.field_improv.size[1] = marker.widget.style.icon.size[1]
                marker.widget.style.field_improv.size[2] = marker.widget.style.icon.size[2]

                marker.widget.style.field_improv.offset[1] = 35 * marker.scale

                marker.widget.style.ring.size[1] = marker.widget.style.ring.size[1] * marker.scale
                marker.widget.style.ring.size[2] = marker.widget.style.ring.size[2] * marker.scale

                marker.widget.style.marker_text.font_size = marker.widget.style.icon.size[1] / 3

            end

            if mod:get("ammo_med_require_line_of_sight") == true then
                if marker.widget.content.line_of_sight_progress == 1 then
                    if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                        marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                        marker.draw = true
                    else
                        marker.widget.alpha_multiplier = 0
                        marker.draw = false
                    end
                end
            else
                if marker.widget.content.is_inside_frustum or marker.template.screen_clamp then
                    marker.widget.alpha_multiplier = mod:get("ammo_med_alpha")
                    marker.draw = true
                else
                    marker.widget.alpha_multiplier = 0
                    marker.draw = false
                end
            end

        end
    end
end

mod:hook(
    CLASS.HudElementWorldMarkers, "_create_widget", function(func, self, name, definition)

        -- add new marker text widget to definitions
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
        marker_text_style.drop_shadow = true

        local marker_text_pass = {
            pass_type = "text", style_id = "marker_text", value = "", value_id = "marker_text", style = marker_text_style,
            visibility_function = function(content, style)
                return content.marker_text ~= nil
            end
        }

        definition.passes[#definition.passes + 1] = table.clone(marker_text_pass)
        definition.style.marker_text = table.clone(marker_text_style)
        definition.content.marker_text = ""

        -- add new icon for Field Improv talent
        local icon_size = {48, 48}
        local field_improv_style = {
            horizontal_alignment = "left", vertical_alignment = "center", size = icon_size, offset = {50, 0, 0}, color = {255, 255, 255, 255}
        }

        local field_improv_pass = {
            pass_type = "texture", style_id = "field_improv", value = "", value_id = "field_improv", style = field_improv_style,
            visibility_function = function(content, style)
                return content.field_improv ~= ""
            end
        }

        definition.passes[#definition.passes + 1] = table.clone(field_improv_pass)
        definition.style.field_improv = table.clone(field_improv_style)
        definition.content.field_improv = ""

        return func(self, name, definition)
    end
)

