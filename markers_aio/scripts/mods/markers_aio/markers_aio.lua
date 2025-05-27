local mod = get_mod("markers_aio")

mod:io_dofile("markers_aio/scripts/mods/markers_aio/ammo_med_markers/ammo_med_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/chest_markers/chest_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/heretical_idol_markers/heretical_idol_marker")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/material_markers/material_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/stimm_markers/stimm_markers")
mod:io_dofile("markers_aio/scripts/mods/markers_aio/tome_markers/tome_markers")

local HereticalIdolTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/heretical_idol_markers/heretical_idol_marker_template")
local MedMarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/ammo_med_markers/ammo_med_markers_template")
local ChestMarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/chest_markers/chest_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod:hook_safe(
    CLASS.HudElementWorldMarkers, "init", function(self)
        -- add new marker templates to templates table
        self._marker_templates[HereticalIdolTemplate.name] = HereticalIdolTemplate
        self._marker_templates[MedMarkerTemplate.name] = MedMarkerTemplate
        self._marker_templates[ChestMarkerTemplate.name] = ChestMarkerTemplate
        mod.active_chests = {}
        mod.current_heretical_idol_markers = {}

    end
)

mod:hook_safe(
    CLASS.HudElementWorldMarkers, "_calculate_markers", function(self, dt, t, input_service, ui_renderer, render_settings)

        if self then
            local markers_by_type = self._markers_by_type

            for marker_type, markers in pairs(markers_by_type) do
                for i = 1, #markers do
                    local marker = markers[i]
                    if not marker.scale then
                        marker.scale = 1
                    end
                    if mod:get("tome_enable") then
                        mod.update_tome_markers(self, marker)
                    end
                    if mod:get("material_enable") then
                        mod.update_material_markers(self, marker)
                    end
                    if mod:get("ammo_med_enable") then
                        mod.update_ammo_med_markers(self, marker)
                    end
                    if mod:get("stimm_enable") then
                        mod.update_stimm_markers(self, marker)
                    end
                    if mod:get("chest_enable") then
                        mod.update_chest_markers(self, marker)
                    end
                    if mod:get("heretical_idol_enable") then
                        mod.update_marker_icon(self, marker)
                    end
                end
            end
        end
    end
)

mod.get_marker_pickup_type = function(marker)
    if marker.type ~= "interaction" or not marker.unit or not Unit or not Unit.alive(marker.unit) or not Unit.has_data(marker.unit, "pickup_type") then
        return
    end
    return Unit.get_data(marker.unit, "pickup_type")
end

mod.lookup_border_color = function(colour_string)
    local border_colours = {
        ["Gold"] = {255, 232, 188, 109},
        ["Silver"] = {255, 187, 198, 201},
        ["Steel"] = {255, 161, 166, 169}
    }
    return border_colours[colour_string]
end

HudElementWorldMarkers._get_scale = function(self, scale_settings, distance)

    if distance and scale_settings then
        local easing_function = scale_settings.easing_function

        if distance > scale_settings.distance_max then
            return scale_settings.scale_from
        elseif distance < scale_settings.distance_min then
            return scale_settings.scale_to
        else
            local distance_fade_fraction = 1 - (distance - scale_settings.distance_min) / (scale_settings.distance_max - scale_settings.distance_min)
            local eased_distance_scale_fraction = easing_function and easing_function(distance_fade_fraction) or distance_fade_fraction
            local adjusted_fade = scale_settings.scale_from + eased_distance_scale_fraction * (scale_settings.scale_to - scale_settings.scale_from)

            return adjusted_fade
        end
    else
        return 1
    end
end

HudElementWorldMarkers._get_fade = function(self, fade_settings, distance)
    if fade_settings and distance then
        local easing_function = fade_settings.easing_function
        local return_value

        if distance > fade_settings.distance_max then
            return_value = fade_settings.fade_from
        elseif distance < fade_settings.distance_min then
            return_value = fade_settings.fade_to
        else
            local distance_fade_fraction = 1 - (distance - fade_settings.distance_min) / (fade_settings.distance_max - fade_settings.distance_min)
            local eased_distance_fade_fraction = easing_function(distance_fade_fraction)
            local adjusted_fade = fade_settings.fade_from + eased_distance_fade_fraction * (fade_settings.fade_to - fade_settings.fade_from)

            return_value = adjusted_fade
        end

        if fade_settings.invert then
            return 1 - return_value
        else
            return return_value
        end
    else
        return 1
    end
end

HudElementWorldMarkers._draw_markers = function(self, dt, t, input_service, ui_renderer, render_settings)
    local camera = self._camera

    if camera then
        local markers_by_type = self._markers_by_type

        for marker_type, markers in pairs(markers_by_type) do
            for i = 1, #markers do
                local marker = markers[i]
                local draw = marker.draw

                if draw then
                    local widget = marker.widget
                    local content = widget.content
                    local distance = content.distance
                    local template = marker.template
                    local scale_settings = template.scale_settings
                    local fade_settings = template.fade_settings

                    if scale_settings then
                        marker.scale = self:_get_scale(scale_settings, distance)

                        local new_scale = marker.ignore_scale and 1 or marker.scale

                        self:_apply_scale(widget, new_scale)
                    end

                    local alpha_multiplier = 1

                    if fade_settings and not marker.block_fade_settings and distance then
                        alpha_multiplier = self:_get_fade(fade_settings, distance)
                    end

                    if draw then
                        local previous_alpha_multiplier = widget.alpha_multiplier

                        widget.alpha_multiplier = (previous_alpha_multiplier or 1) * alpha_multiplier

                        UIWidget.draw(widget, ui_renderer)

                        widget.alpha_multiplier = previous_alpha_multiplier
                    end
                end
            end
        end
    end
end
