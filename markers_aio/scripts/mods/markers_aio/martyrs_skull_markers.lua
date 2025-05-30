local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod.update_martyrs_skull_markers = function(self, marker)

    --mod.setup_walkthrough_markers(self)
    if marker and self then
        local unit = marker.unit

        local pickup_type = mod.get_marker_pickup_type(marker)

        if pickup_type == "collectible_01_pickup" then

            marker.draw = false
            marker.widget.alpha_multiplier = 0

            marker.markers_aio_type = "martyrs_skull"

            marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))

            marker.template.check_line_of_sight = mod:get(marker.markers_aio_type .. "_require_line_of_sight")

            marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
            marker.template.screen_clamp = mod:get(marker.markers_aio_type .. "_keep_on_screen")
            marker.block_screen_clamp = false

            marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/enemy"

            marker.widget.style.ring.color = mod.lookup_colour(mod:get(marker.markers_aio_type .. "_border_colour"))

            marker.widget.style.icon.color = {
                255,
                mod:get(marker.markers_aio_type .. "_colour_R"),
                mod:get(marker.markers_aio_type .. "_colour_G"),
                mod:get(marker.markers_aio_type .. "_colour_B")
            }

        end
    end
end


local maryrs_skull_walkthrough_markers = {

    ["km_enforcer"] = {
        ["markers"] = {
            {
                ["position"] = Vector3(-391.043, -57.3325, 18.7131),
                ["placed"] = false
            }
        }
    }

}

mod.setup_walkthrough_markers = function(self)
    self._level = Managers.state.mission:mission()
    local current_level_name = self._level.name

    for level_name, walkthrough_markers in pairs(maryrs_skull_walkthrough_markers) do
        if current_level_name == level_name then
            dbg_1 = walkthrough_markers

            for i, marker in ipairs(walkthrough_markers.markers) do
                if marker.placed == false then
                    -- Managers.event:trigger("add_world_marker_position", "objective", marker.position)
                    marker.placed = true
                end
            end
        end
    end
end


--[[ For future development
local HudElementSmartTagging = require("scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging")
local Vo = require("scripts/utilities/vo")

HudElementSmartTagging._add_smart_tag_presentation = function(self, tag_instance, is_hotjoin_synced)
    local presented_smart_tags_by_tag_id = self._presented_smart_tags_by_tag_id
    local tag_id = tag_instance:id()
    local target_location = tag_instance:target_location()
    local tag_template = tag_instance:template()
    local marker_type = tag_template.marker_type
    local parent = self._parent
    local player = parent:player()
    local tagger_player = tag_instance:tagger_player()
    local is_my_tag = tagger_player and tagger_player:unique_id() == player:unique_id()
    local data = {
        spawned = false,
        tag_template = tag_template,
        tag_instance = tag_instance,
        tag_id = tag_id,
        player = player,
        tagger_player = tagger_player,
        is_my_tag = is_my_tag
    }

    presented_smart_tags_by_tag_id[tag_id] = data

    if not is_hotjoin_synced then
        if is_my_tag then
            local sound_enter_tagger = tag_template.sound_enter_tagger

            if sound_enter_tagger then
                self:_play_tag_sound(tag_instance, sound_enter_tagger)
            end

            local voice_tag_concept = tag_template.voice_tag_concept

            if voice_tag_concept then
                local player_unit = parent:player_unit()

                if player_unit then
                    local voice_tag_id = tag_template.voice_tag_id
                    local target_unit

                    if not voice_tag_id then
                        target_unit = tag_instance:target_unit()

                        if target_unit then
                            local unit_data_extension = ScriptUnit.has_extension(target_unit, "unit_data_system")

                            if unit_data_extension then
                                local breed = unit_data_extension:breed()
                                local breed_name = breed.name

                                voice_tag_id = breed_name
                            end
                        end
                    end

                    if voice_tag_id then
                        Vo.on_demand_vo_event(player_unit, voice_tag_concept, voice_tag_id, target_unit)
                    end
                end
            end
        else
            local sound_enter_others = tag_template.sound_enter_others

            if sound_enter_others then
                self:_play_tag_sound(tag_instance, sound_enter_others)
            end
        end
    end

    if marker_type then
        if target_location then
            local callback = callback(self, "_cb_presentation_tag_spawned", tag_instance)

            --mod:echo(target_location)
            --Managers.event:trigger("add_world_marker_position", "objective", Vector3(-10, -10, 10))

            Managers.event:trigger("add_world_marker_position", marker_type, target_location, callback, data)
        else
            local target_unit = tag_instance:target_unit()
            local callback = callback(self, "_cb_presentation_tag_spawned", tag_instance)

            Managers.event:trigger("add_world_marker_unit", marker_type, target_unit, callback, data)
        end
    else
        data.spawned = true
    end
end

]]
