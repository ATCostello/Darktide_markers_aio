local mod = get_mod("markers_aio")
local fs = mod.frame_settings

mod.update_objective_markers = function(self, marker)
    if not marker or not marker.type then
        return
    end

    -- Only base game objective/hub objective markers are handled here.
    if marker.type ~= "objective" and marker.type ~= "hub_objective" then
        local template = marker.template
        if not (template and (template.name == "objective" or template.name == "hub_objective")) then
            return
        end
    end

    local widget = marker.widget
    if not widget or not widget.style or not widget.content then
        return
    end

    -- Leave demolition/corruptor objective visuals largely untouched (they already have custom styling)
    if marker.ui_target_type == "demolition" or marker.ui_target_type == "corruptor" then
        return
    end

    marker.markers_aio_type = "objective"

    mod.set_colour(widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))

    local pt = fs.per_type.objective

    marker.template.check_line_of_sight = pt.require_line_of_sight

    marker.template.max_distance = pt.max_distance
    marker.max_distance = pt.max_distance

    marker.template.screen_clamp = pt.keep_on_screen
    marker.block_screen_clamp = false

    local colour = {
        255,
        pt.colour_R or 255,
        pt.colour_G or 255,
        pt.colour_B or 255,
    }

    if widget.style.icon then
        mod.set_colour(widget.style.icon.color, colour)
    end

    if widget.style.frame then
        mod.set_colour(widget.style.frame.color, colour)
    end

    if widget.style.arrow then
        mod.set_colour(widget.style.arrow.color, colour)
    end

    if widget.style.indicator then
        mod.set_colour(widget.style.indicator.color, colour)
    end
end
