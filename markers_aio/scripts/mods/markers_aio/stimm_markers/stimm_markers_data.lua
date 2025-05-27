local mod = get_mod("stimm_markers")

return {
    name = mod:localize("mod_name"), description = mod:localize("mod_description"), is_togglable = false, options = {
        widgets = {
            {
                setting_id = "general_settings", type = "group", sub_widgets = {
                    {setting_id = "keep_on_screen", type = "checkbox", default_value = false},
                    {setting_id = "require_line_of_sight", type = "checkbox", default_value = true},
                    {setting_id = "max_distance", type = "numeric", default_value = 30, range = {20, 100}},
                    {setting_id = "min_size", type = "numeric", default_value = 0.4, range = {0.2, 1}, decimals_number = 2},
					{setting_id = "max_size", type = "numeric", default_value = 1, range = {1, 2}, decimals_number = 2},
                    {setting_id = "alpha", type = "numeric", default_value = 1, range = {0.1, 1}, decimals_number = 2}
                }
            }, {
                setting_id = "boost_stim_icon_colour", type = "group", sub_widgets = {
                    {setting_id = "boost_stim_icon_colour_R", type = "numeric", default_value = 30, range = {0, 255}},
                    {setting_id = "boost_stim_icon_colour_G", type = "numeric", default_value = 255, range = {0, 255}},
                    {setting_id = "boost_stim_icon_colour_B", type = "numeric", default_value = 30, range = {0, 255}}
                }
            }, {
                setting_id = "corruption_stimm_icon_colour", type = "group", sub_widgets = {
                    {setting_id = "corruption_stimm_icon_colour_R", type = "numeric", default_value = 255, range = {0, 255}},
                    {setting_id = "corruption_stimm_icon_colour_G", type = "numeric", default_value = 255, range = {0, 255}},
                    {setting_id = "corruption_stimm_icon_colour_B", type = "numeric", default_value = 30, range = {0, 255}}
                }
            }, {
                setting_id = "power_stimm_icon_colour", type = "group", sub_widgets = {
                    {setting_id = "power_stimm_icon_colour_R", type = "numeric", default_value = 255, range = {0, 255}},
                    {setting_id = "power_stimm_icon_colour_G", type = "numeric", default_value = 30, range = {0, 255}},
                    {setting_id = "power_stimm_icon_colour_B", type = "numeric", default_value = 30, range = {0, 255}}
                }
            }, {
                setting_id = "speed_stimm_icon_colour", type = "group", sub_widgets = {
                    {setting_id = "speed_stimm_icon_colour_R", type = "numeric", default_value = 30, range = {0, 255}},
                    {setting_id = "speed_stimm_icon_colour_G", type = "numeric", default_value = 30, range = {0, 255}},
                    {setting_id = "speed_stimm_icon_colour_B", type = "numeric", default_value = 255, range = {0, 255}}
                }
            }
        }

    }
}
