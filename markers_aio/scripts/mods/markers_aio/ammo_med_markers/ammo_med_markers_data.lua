local mod = get_mod("ammo_med_markers")

return {
    name = mod:localize("mod_name"), description = mod:localize("mod_description"), is_togglable = false, options = {
        widgets = {
            {
                setting_id = "general_settings", type = "group", sub_widgets = {
                    {setting_id = "ammo_med_markers_alternate_large_ammo_icon", type = "checkbox", default_value = false},
                    {setting_id = "keep_on_screen", type = "checkbox", default_value = false},
                    {setting_id = "require_line_of_sight", type = "checkbox", default_value = true},
                    {setting_id = "max_distance", type = "numeric", default_value = 15, range = {15, 100}},
                    {setting_id = "min_size", type = "numeric", default_value = 0.2, range = {0.2, 1}, decimals_number = 2},
                    {setting_id = "max_size", type = "numeric", default_value = 1, range = {1, 2}, decimals_number = 2},
                    {setting_id = "alpha", type = "numeric", default_value = 1, range = {0.1, 1}, decimals_number = 2},
                    {setting_id = "display_med_charges", type = "checkbox", default_value = true},
                    {setting_id = "display_ammo_charges", type = "checkbox", default_value = true},
                }
            }, {
                setting_id = "ammo_small_colour", type = "group", sub_widgets = {
                    {setting_id = "ammo_small_colour_R", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "ammo_small_colour_G", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "ammo_small_colour_B", type = "numeric", default_value = 222, range = {0, 255}}
                }
            }, {
                setting_id = "ammo_large_colour", type = "group", sub_widgets = {
                    {setting_id = "ammo_large_colour_R", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "ammo_large_colour_G", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "ammo_large_colour_B", type = "numeric", default_value = 222, range = {0, 255}}
                }
            },
            {
                setting_id = "ammo_crate_colour", type = "group", sub_widgets = {
                    {setting_id = "ammo_crate_colour_R", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "ammo_crate_colour_G", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "ammo_crate_colour_B", type = "numeric", default_value = 222, range = {0, 255}}
                }
            },
            {
                setting_id = "med_crate_colour", type = "group", sub_widgets = {
                    {setting_id = "med_crate_colour_R", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "med_crate_colour_G", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "med_crate_colour_B", type = "numeric", default_value = 222, range = {0, 255}}
                }
            },
            {
                setting_id = "grenade_colour", type = "group", sub_widgets = {
                    {setting_id = "grenade_colour_R", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "grenade_colour_G", type = "numeric", default_value = 252, range = {0, 255}},
                    {setting_id = "grenade_colour_B", type = "numeric", default_value = 222, range = {0, 255}}
                }
            }
        }

    }
}
