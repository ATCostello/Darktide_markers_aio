local mod = get_mod("markers_aio")

local lookup_border_color = function(colour_string)
    local border_colours = {
        ["Gold"] = {
            255,
            232,
            188,
            109
        },
        ["Silver"] = {
            255,
            187,
            198,
            201
        },
        ["Steel"] = {
            255,
            161,
            166,
            169
        }
    }
    return border_colours[colour_string]
end


local apply_color_to_text = function(text, r, g, b)
    return "{#color(" .. r .. "," .. g .. "," .. b .. ")}" .. text .. "{#reset()}"
end


local Gold = lookup_border_color("Gold")
local Silver = lookup_border_color("Silver")
local Steel = lookup_border_color("Steel")

local border_colours = {
    {
        text = apply_color_to_text(mod:localize("Gold"), Gold[2], Gold[3], Gold[4]),
        value = "Gold"
    },
    {
        text = apply_color_to_text(mod:localize("Silver"), Silver[2], Silver[3], Silver[4]),
        value = "Silver"
    },
    {
        text = apply_color_to_text(mod:localize("Steel"), Steel[2], Steel[3], Steel[4]),
        value = "Steel"
    }
}

local chest_icons = {
    {
        text = "Default",
        value = "content/ui/materials/hud/interactions/icons/default"
    },
    {
        text = "Video",
        value = "content/ui/materials/icons/system/settings/category_video"
    },
    {
        text = "Loot",
        value = "content/ui/materials/icons/generic/loot"
    }
}

local luggable_icons = {
    {
        text = "Exclamation",
        value = "content/ui/materials/hud/interactions/icons/environment_alert"
    },
    {
        text = "Hands",
        value = "content/ui/materials/hud/communication_wheel/icons/thanks"
    },
    {
        text = "Fist",
        value = "content/ui/materials/icons/presets/preset_18"
    }
}

local background_colours = {
    {
        text = "Black",
        value = "Black"
    },
    {
        text = "Terminal",
        value = "Terminal"
    }
}

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = false,
    options = {
        widgets = {
            {
                setting_id = "aio_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "los_fade_enable",
                        type = "checkbox",
                        default_value = true
                    },
                    {
                        setting_id = "los_opacity",
                        type = "numeric",
                        default_value = 50,
                        range = {
                            0,
                            100
                        }
                    },
                    {
                        setting_id = "marker_background_colour",
                        type = "dropdown",
                        options = background_colours,
                        default_value = "Black"
                    }
                }
            },
            {
                setting_id = "ammo_med_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "ammo_med_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "ammo_med_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "ammo_med_markers_alternate_large_ammo_icon",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "ammo_med_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "ammo_med_require_line_of_sight",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "ammo_med_toggle_los",
                                type = "keybind",
                                default_value = {
                                    
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "ammo_med_toggle_los"
                            },
                            {
                                setting_id = "ammo_med_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    15,
                                    100
                                }
                            },
                            {
                                setting_id = "ammo_med_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "ammo_med_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            },

                            {
                                setting_id = "display_ammo_charges",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "display_med_charges",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "change_colour_for_ammo_charges",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "display_field_improv_colour",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "display_field_improv_icon",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "display_med_ring",
                                type = "checkbox",
                                default_value = true
                            }

                        }
                    },
                    {
                        setting_id = "ammo_small_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "ammo_small_colour_R",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_small_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_small_colour_B",
                                type = "numeric",
                                default_value = 222,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_small_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Silver"
                            }
                        }
                    },
                    {
                        setting_id = "ammo_large_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "ammo_large_colour_R",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_large_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_large_colour_B",
                                type = "numeric",
                                default_value = 222,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_large_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Silver"
                            }

                        }
                    },
                    {
                        setting_id = "ammo_crate_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "ammo_crate_colour_R",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_crate_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_crate_colour_B",
                                type = "numeric",
                                default_value = 222,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "ammo_crate_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "med_crate_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "med_crate_colour_R",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "med_crate_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "med_crate_colour_B",
                                type = "numeric",
                                default_value = 222,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "med_crate_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "grenade_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "grenade_colour_R",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "grenade_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "grenade_colour_B",
                                type = "numeric",
                                default_value = 222,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "grenade_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    }
                }
            },
            {
                setting_id = "chest_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "chest_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "chest_enable",
                                type = "checkbox",
                                default_value = true
                            },
                            -- {setting_id = "chest_alternative_icon", type = "checkbox", default_value = false},
                            {
                                setting_id = "chest_icon",
                                type = "dropdown",
                                options = chest_icons,
                                default_value = "content/ui/materials/icons/system/settings/category_video"
                            },

                            {
                                setting_id = "chest_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "chest_require_line_of_sight",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "chest_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "chest_toggle_los"
                            },
                            {
                                setting_id = "chest_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "chest_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "chest_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            }
                        }
                    },
                    {
                        setting_id = "chest_icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "chest_icon_colour_R",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "chest_icon_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "chest_icon_colour_B",
                                type = "numeric",
                                default_value = 222,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "chest_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    }
                }
            },
            {
                setting_id = "heretical_idol_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "heretical_idol_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "heretical_idol_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "heretical_idol_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "heretical_idol_require_line_of_sight",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "heretical_idol_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "heretical_idol_toggle_los"
                            },
                            {
                                setting_id = "heretical_idol_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "heretical_idol_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "heretical_idol_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            }
                        }
                    },
                    {
                        setting_id = "icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "icon_colour_R",
                                type = "numeric",
                                default_value = 132,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "icon_colour_G",
                                type = "numeric",
                                default_value = 156,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "icon_colour_B",
                                type = "numeric",
                                default_value = 99,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "idol_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Silver"
                            }

                        }
                    }
                }
            },
            {
                setting_id = "material_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "material_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "material_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "material_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "material_require_line_of_sight",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "material_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "material_toggle_los"
                            },
                            {
                                setting_id = "material_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "material_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "material_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            },
                            {
                                setting_id = "material_small_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Silver"
                            },
                            {
                                setting_id = "material_large_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }
                        }
                    },
                    {
                        setting_id = "marker_toggles",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "toggle_large_plasteel",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "toggle_small_plasteel",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "toggle_large_diamantine",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "toggle_small_diamantine",
                                type = "checkbox",
                                default_value = true
                            }
                        }
                    },
                    {
                        setting_id = "plasteel_icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "plasteel_icon_colour_R",
                                type = "numeric",
                                default_value = 243,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "plasteel_icon_colour_G",
                                type = "numeric",
                                default_value = 115,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "plasteel_icon_colour_B",
                                type = "numeric",
                                default_value = 85,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    },
                    {
                        setting_id = "diamantine_icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "diamantine_icon_colour_R",
                                type = "numeric",
                                default_value = 95,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "diamantine_icon_colour_G",
                                type = "numeric",
                                default_value = 158,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "diamantine_icon_colour_B",
                                type = "numeric",
                                default_value = 160,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    }
                }
            },
            {
                setting_id = "stimm_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "stimm_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "stimm_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "stimm_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "stimm_require_line_of_sight",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "stimm_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "stimm_toggle_los"
                            },
                            {
                                setting_id = "stimm_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "stimm_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "stimm_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            }
                        }
                    },
                    {
                        setting_id = "boost_stimm_icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "boost_stimm_icon_colour_R",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "boost_stimm_icon_colour_G",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "boost_stimm_icon_colour_B",
                                type = "numeric",
                                default_value = 30,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "boost_stimm_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }
                        }
                    },
                    {
                        setting_id = "corruption_stimm_icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "corruption_stimm_icon_colour_R",
                                type = "numeric",
                                default_value = 30,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "corruption_stimm_icon_colour_G",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "corruption_stimm_icon_colour_B",
                                type = "numeric",
                                default_value = 30,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "corruption_stimm_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "power_stimm_icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "power_stimm_icon_colour_R",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "power_stimm_icon_colour_G",
                                type = "numeric",
                                default_value = 30,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "power_stimm_icon_colour_B",
                                type = "numeric",
                                default_value = 30,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "power_stimm_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "speed_stimm_icon_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "speed_stimm_icon_colour_R",
                                type = "numeric",
                                default_value = 30,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "speed_stimm_icon_colour_G",
                                type = "numeric",
                                default_value = 150,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "speed_stimm_icon_colour_B",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "speed_stimm_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    }
                }
            },
            {
                setting_id = "tome_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "tome_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "tome_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "tome_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "tome_require_line_of_sight",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "tome_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "tome_toggle_los"
                            },
                            {
                                setting_id = "tome_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "tome_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "tome_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            },
                            {
                                setting_id = "tome_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "grim_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "grim_colour_R",
                                type = "numeric",
                                default_value = 150,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "grim_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "grim_colour_B",
                                type = "numeric",
                                default_value = 0,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    },
                    {
                        setting_id = "script_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "script_colour_R",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "script_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "script_colour_B",
                                type = "numeric",
                                default_value = 0,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    }
                }
            },
            {
                setting_id = "tainted_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "tainted_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "tainted_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "tainted_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "tainted_require_line_of_sight",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "tainted_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "tainted_toggle_los"
                            },
                            {
                                setting_id = "tainted_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "tainted_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "tainted_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            },
                            {
                                setting_id = "tainted_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "tainted_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "tainted_colour_R",
                                type = "numeric",
                                default_value = 150,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "tainted_colour_G",
                                type = "numeric",
                                default_value = 252,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "tainted_colour_B",
                                type = "numeric",
                                default_value = 0,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    }
                }
            },
            {
                setting_id = "tainted_skull_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "tainted_skull_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "tainted_skull_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "tainted_skull_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "tainted_skull_require_line_of_sight",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "tainted_skull_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "tainted_skull_toggle_los"
                            },
                            {
                                setting_id = "tainted_skull_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "tainted_skull_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "tainted_skull_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            },
                            {
                                setting_id = "tainted_skull_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "tainted_skull_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "tainted_skull_colour_R",
                                type = "numeric",
                                default_value = 150,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "tainted_skull_colour_G",
                                type = "numeric",
                                default_value = 200,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "tainted_skull_colour_B",
                                type = "numeric",
                                default_value = 0,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    }
                }
            },
            {
                setting_id = "luggable_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "luggable_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "luggable_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "luggable_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "luggable_require_line_of_sight",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "luggable_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "luggable_toggle_los"
                            },
                            {
                                setting_id = "luggable_icon",
                                type = "dropdown",
                                options = luggable_icons,
                                default_value = "content/ui/materials/hud/interactions/icons/environment_alert"
                            },

                            {
                                setting_id = "luggable_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "luggable_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "luggable_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            },
                            {
                                setting_id = "luggable_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }

                        }
                    },
                    {
                        setting_id = "luggable_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "luggable_colour_R",
                                type = "numeric",
                                default_value = 0,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "luggable_colour_G",
                                type = "numeric",
                                default_value = 240,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "luggable_colour_B",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    }
                }
            },
            {
                setting_id = "martyrs_skull_markers_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "martyrs_skull_general_settings",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "martyrs_skull_enable",
                                type = "checkbox",
                                default_value = true
                            },

                            {
                                setting_id = "martyrs_skull_keep_on_screen",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "martyrs_skull_require_line_of_sight",
                                type = "checkbox",
                                default_value = false
                            },
                            {
                                setting_id = "martyrs_skull_toggle_los",
                                type = "keybind",
                                default_value = {
                                },
                                keybind_global = true,
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "martyrs_skull_toggle_los"
                            },
                            {
                                setting_id = "martyrs_skull_max_distance",
                                type = "numeric",
                                default_value = 50,
                                range = {
                                    20,
                                    100
                                }
                            },
                            {
                                setting_id = "martyrs_skull_scale",
                                type = "numeric",
                                default_value = 100,
                                range = {
                                    50,
                                    150
                                }
                            },
                            {
                                setting_id = "martyrs_skull_alpha",
                                type = "numeric",
                                default_value = 1,
                                range = {
                                    0.1,
                                    1
                                },
                                decimals_number = 2
                            },
                            {
                                setting_id = "martyrs_skull_border_colour",
                                type = "dropdown",
                                options = border_colours,
                                default_value = "Gold"
                            }
                        }
                    },
                    {
                        setting_id = "martyrs_skull_colour",
                        type = "group",
                        sub_widgets = {
                            {
                                setting_id = "martyrs_skull_colour_R",
                                type = "numeric",
                                default_value = 255,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "martyrs_skull_colour_G",
                                type = "numeric",
                                default_value = 200,
                                range = {
                                    0,
                                    255
                                }
                            },
                            {
                                setting_id = "martyrs_skull_colour_B",
                                type = "numeric",
                                default_value = 0,
                                range = {
                                    0,
                                    255
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
