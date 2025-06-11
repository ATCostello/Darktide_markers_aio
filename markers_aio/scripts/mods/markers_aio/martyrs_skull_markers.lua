local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local AchievementCategories = require("scripts/settings/achievements/achievement_categories")

mod.update_martyrs_skull_markers = function(self, marker)

    if mod:get("martyrs_skull_guide_enable") == true then
        mod.setup_walkthrough_markers(self)
    end

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


local function round(num, n)
    return math.floor(num * 10 ^ n + 0.5) / 10 ^ n
end


local function vector3_equals_4dp(v1, v2)
    return round(v1.x, 4) == round(v2.x, 4) and round(v1.y, 4) == round(v2.y, 4) and round(v1.z, 4) == round(v2.z, 4)
end


local maryrs_skull_walkthrough_markers = {
    ["cm_habs"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Player 1 = A, Player 2 = B",
        ["markers"] = {
            {
                ["position"] = {
                    144.047,
                    -157.039,
                    -13.2339
                },
                ["placed"] = false,
                ["marker_text"] = "A1",
                ["objective_placed"] = false,
                ["objective_text"] = "Input code: 213\nPress middle button"
            },
            {
                ["position"] = {
                    143.583,
                    -157.536,
                    -13.2339
                },
                ["placed"] = false,
                ["marker_text"] = "A2",
                ["objective_placed"] = false,
                ["objective_text"] = "Press left button"
            },
            {
                ["position"] = {
                    144.455,
                    -156.568,
                    -13.2339
                },
                ["placed"] = false,
                ["marker_text"] = "A3",
                ["objective_placed"] = false,
                ["objective_text"] = "Press right button"
            },
            {
                ["position"] = {
                    142.731,
                    -161.856,
                    -12.6046
                },
                ["placed"] = false,
                ["marker_text"] = "A4",
                ["objective_placed"] = false,
                ["objective_text"] = "Hold lever for second player to complete B1"
            },
            {
                ["position"] = {
                    142.321,
                    -170.079,
                    -12.5168
                },
                ["placed"] = false,
                ["marker_text"] = "B1",
                ["objective_placed"] = false,
                ["objective_text"] = "Second player, press button whilst first player holds A4"
            },
            {
                ["position"] = {
                    144.302,
                    -173.317,
                    -13.5472
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }

        }
    },
    ["km_station"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    9.48675,
                    -229.291,
                    -5.81418
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Turn first valve"
            },
            {
                ["position"] = {
                    -6.0481,
                    -204.741,
                    -10.5335
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = "Turn second valve"
            },
            {
                ["position"] = {
                    -1.13165,
                    -176.711,
                    -8.63197
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = "Turn third valve"
            },
            {
                ["position"] = {
                    51.1744,
                    -219.396,
                    -1.46932
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = "Turn fourth valve"
            },
            {
                ["position"] = {
                    44.1537,
                    -214.407,
                    2.14541
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = "Turn final valve"
            },
            {
                ["position"] = {
                    53.913,
                    -225.67,
                    1.03233
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["lm_rails"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo (Parkour)",
        ["markers"] = {
            {
                ["position"] = {
                    -49.0317,
                    254.465,
                    -52.550
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Follow number sequence"
            },
            {
                ["position"] = {
                    -50.8852,
                    249.336,
                    -52.0019
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -58.1852,
                    248.664,
                    -52.0019
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -59.6025,
                    257.001,
                    -50.903
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -58.2405,
                    264.306,
                    -53.0389
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -58.6364,
                    271.696,
                    -53.8103
                },
                ["placed"] = false,
                ["marker_text"] = "6",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -69.5756,
                    270.68,
                    -52.7098
                },
                ["placed"] = false,
                ["marker_text"] = "7",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -77.846,
                    260.838,
                    -52.2614
                },
                ["placed"] = false,
                ["marker_text"] = "8",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -83.0373,
                    259.106,
                    -50.7316
                },
                ["placed"] = false,
                ["marker_text"] = "9",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -82.3622,
                    253.095,
                    -51.0299
                },
                ["placed"] = false,
                ["marker_text"] = "10",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -76.5173,
                    249.036,
                    -49.4847
                },
                ["placed"] = false,
                ["marker_text"] = "11",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -75.2506,
                    253.76,
                    -49.6751
                },
                ["placed"] = false,
                ["marker_text"] = "12",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -68.7915,
                    256.348,
                    -48.2053
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["dm_rise"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Player 1 = A, Player 2 = B",
        ["markers"] = {
            {
                ["position"] = {
                    -130.516,
                    -94.579,
                    -22.6548
                },
                ["placed"] = false,
                ["marker_text"] = "A1",
                ["objective_placed"] = false,
                ["objective_text"] = "Grab the power cell"
            },
            {
                ["position"] = {
                    -120.339,
                    -81.5401,
                    -21.9049
                },
                ["placed"] = false,
                ["marker_text"] = "A2",
                ["objective_placed"] = false,
                ["objective_text"] = "Insert the power cell"
            },
            {
                ["position"] = {
                    -117.865,
                    -72.5469,
                    -21.1979
                },
                ["placed"] = false,
                ["marker_text"] = "B1",
                ["objective_placed"] = false,
                ["objective_text"] = "Player two, enter elevator"
            },
            {
                ["position"] = {
                    -119.894,
                    -79.5738,
                    -21.4522
                },
                ["placed"] = false,
                ["marker_text"] = "A3",
                ["objective_placed"] = false,
                ["objective_text"] = "Player one, hold the power switch once player 2 is in the elevator"
            },
            {
                ["position"] = {
                    -128.818,
                    -81.2019,
                    -10.4809
                },
                ["placed"] = false,
                ["marker_text"] = "B2",
                ["objective_placed"] = false,
                ["objective_text"] = "Grab the next power cell"
            },
            {
                ["position"] = {
                    -122.264,
                    -81.8673,
                    -10.0012
                },
                ["placed"] = false,
                ["marker_text"] = "B3",
                ["objective_placed"] = false,
                ["objective_text"] = "Throw power cell down to player one"
            },
            {
                ["position"] = {
                    -123.822,
                    -85.1736,
                    -21.9671
                },
                ["placed"] = false,
                ["marker_text"] = "A4",
                ["objective_placed"] = false,
                ["objective_text"] = "Player one, insert second power cell"
            },
            {
                ["position"] = {
                    -125.83,
                    -85.4738,
                    -21.3926
                },
                ["placed"] = false,
                ["marker_text"] = "A5",
                ["objective_placed"] = false,
                ["objective_text"] = "Hold the next lever for player two"
            },
            {
                ["position"] = {
                    -134.092,
                    -87.867,
                    -9.91844
                },
                ["placed"] = false,
                ["marker_text"] = "B4",
                ["objective_placed"] = false,
                ["objective_text"] = "Player two, press the elevator button"
            },
            {
                ["position"] = {
                    -131.771,
                    -71.1188,
                    -23.000
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["hm_cartel"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo (Parkour)",
        ["markers"] = {
            {
                ["position"] = {
                    -33.304,
                    -240.328,
                    13.9544
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Follow number sequence"
            },
            {
                ["position"] = {
                    -33.3945,
                    -242.741,
                    15.6742
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -44.869,
                    -239.578,
                    15.5392
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -52.8824,
                    -235.826,
                    17.2655
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -58.6911,
                    -232.226,
                    17.7927
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -61.8918,
                    -232.968,
                    18.0485
                },
                ["placed"] = false,
                ["marker_text"] = "6",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -63.7194,
                    -229.822,
                    18.5642
                },
                ["placed"] = false,
                ["marker_text"] = "7",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -64.4813,
                    -227.044,
                    18.0485
                },
                ["placed"] = false,
                ["marker_text"] = "8",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -63.2562,
                    -224.957,
                    18.7124
                },
                ["placed"] = false,
                ["marker_text"] = "9",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -59.8498,
                    -222.662,
                    18.2994
                },
                ["placed"] = false,
                ["marker_text"] = "10",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -56.8131,
                    -226.723,
                    18.0436
                },
                ["placed"] = false,
                ["marker_text"] = "11",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -47.8984,
                    -223.39,
                    18.84
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["km_enforcer"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Player 1 = A, Player 2 = B",
        ["markers"] = {
            {
                ["position"] = {
                    -391.043,
                    -57.3325,
                    18.7131
                },
                ["placed"] = false,
                ["marker_text"] = "A",
                ["objective_placed"] = false,
                ["objective_text"] = "First player, press button to start sequence"
            },
            {
                ["position"] = {
                    -341.099,
                    -66.9554,
                    19.7615
                },
                ["placed"] = false,
                ["marker_text"] = "B",
                ["objective_placed"] = false,
                ["objective_text"] = "Second player, head through this door"
            },
            {
                ["position"] = {
                    -392.463,
                    -63.873,
                    18.7893
                },
                ["placed"] = false,
                ["marker_text"] = "A1",
                ["objective_placed"] = false,
                ["objective_text"] = "Press once to open first door"
            },
            {
                ["position"] = {
                    -391.925,
                    -63.2681,
                    18.7981
                },
                ["placed"] = false,
                ["marker_text"] = "A2",
                ["objective_placed"] = false,
                ["objective_text"] = "Press once to open second door"
            },
            {
                ["position"] = {
                    -394.032,
                    -65.6985,
                    18.8017
                },
                ["placed"] = false,
                ["marker_text"] = "A3",
                ["objective_placed"] = false,
                ["objective_text"] = "Press once to open third door"
            },
            {
                ["position"] = {
                    -365.949,
                    -34.786,
                    19.1993
                },
                ["placed"] = false,
                ["marker_text"] = "B1",
                ["objective_placed"] = false,
                ["objective_text"] = "Press first button to light up corresponding button in control room for player one for the fourth door"
            },
            {
                ["position"] = {
                    -375.002,
                    -26.8904,
                    19.2669
                },
                ["placed"] = false,
                ["marker_text"] = "B2",
                ["objective_placed"] = false,
                ["objective_text"] = "Press second button to light up corresponding button in control room for player one for the final door"
            },
            {
                ["position"] = {
                    -393.072,
                    -64.9167,
                    18.79664
                },
                ["placed"] = false,
                ["marker_text"] = "A4",
                ["objective_placed"] = false,
                ["objective_text"] = "Press button that lights up when player two completes B1 or B2"
            },
            {
                ["position"] = {
                    -404.931,
                    -48.5359,
                    19.7036
                },
                ["placed"] = false,
                ["marker_text"] = "B3",
                ["objective_placed"] = false,
                ["objective_text"] = "Open door for other players"
            },
            {
                ["position"] = {
                    -399.203,
                    -10.8523,
                    19.2549
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["dm_stockpile"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    -140.433,
                    168.14,
                    8.14095
                },
                ["placed"] = false,
                ["marker_text"] = "A",
                ["objective_placed"] = false,
                ["objective_text"] = "Climb up"
            },
            {
                ["position"] = {
                    -123.789,
                    155.205,
                    11.9466
                },
                ["placed"] = false,
                ["marker_text"] = "B",
                ["objective_placed"] = false,
                ["objective_text"] = "Head to the control panel and try move the platform along the rails infront of you. The default pattern in the following order: \nDOWN, RIGHT, RIGHT, DOWN, LEFT"
            },
            {
                ["position"] = {
                    -121.065,
                    155.776,
                    13.5151
                },
                ["placed"] = false,
                ["marker_text"] = "1+4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -122.071,
                    157.062,
                    13.5126
                },
                ["placed"] = false,
                ["marker_text"] = "2+3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -122.572,
                    157.69,
                    13.5084
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -116.322,
                    161.084,
                    14.2671

                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["fm_cargo"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    -92.0841,
                    -40.4035,
                    2.31921
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Turn on all showers with the red inquisition symbol quickly."
            },
            {
                ["position"] = {
                    -97.3683,
                    -35.7082,
                    2.31437
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -102.788,
                    -37.3489,
                    2.24087
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -114.142,
                    -33.6827,
                    2.27126
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },

            {
                ["position"] = {
                    -97.7419,
                    -51.6034,
                    1.7982
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["dm_forge"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo (Parkour)",
        ["markers"] = {
            {
                ["position"] = {
                    54.0019,
                    -38.5088,
                    -11.7775
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Follow number sequence"
            },
            {
                ["position"] = {
                    56.1339,
                    -38.8388,
                    -9.76837
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    58.6614,
                    -47.045,
                    -8.5
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    66.8627,
                    -33.9783,
                    -8.5
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    62.5192,
                    -25.6308,
                    -8.6423
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    61.1417,
                    -18.8286,
                    -8.5
                },
                ["placed"] = false,
                ["marker_text"] = "6",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    57.7718,
                    -12.6109,
                    -8.31547
                },
                ["placed"] = false,
                ["marker_text"] = "7",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    59.068,
                    -6.43525,
                    -8.54622
                },
                ["placed"] = false,
                ["marker_text"] = "8",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    57.9652,
                    -4.22372,
                    -8.59072
                },
                ["placed"] = false,
                ["marker_text"] = "9",
                ["objective_placed"] = false,
                ["objective_text"] = "Destroy all nurgle growths holding the door shut."
            },
            {
                ["position"] = {
                    60.8165,
                    -5.23639,
                    -11.9852
                },
                ["placed"] = false,
                ["marker_text"] = "10",
                ["objective_placed"] = false,
                ["objective_text"] = "Open door"
            },
            {
                ["position"] = {
                    56.737,
                    -2.32158,
                    -12.0376
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["lm_cooling"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    -39.6885,
                    -177.888,
                    -21.9441
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Climb up boxes to reach the top"
            },
            {
                ["position"] = {
                    -39.3581,
                    -181.058,
                    -18.9269
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = "Pick up the key in the body's hand"
            },
            {
                ["position"] = {
                    -40.1927,
                    -215.309,
                    -22.9966
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = "Head back over the bridge and use the key on the locked locker."
            },
            {
                ["position"] = {
                    -41.3789,
                    -215.758,
                    -22.8999
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["lm_scavenge"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Player 1 = A, Player 2 = B",
        ["markers"] = {
            {
                ["position"] = {
                    101.029,
                    124.002,
                    -11.95
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Head into room across the bridge"
            },
            {
                ["position"] = {
                    111.971,
                    119.148,
                    -10.5401
                },
                ["placed"] = false,
                ["marker_text"] = "B1",
                ["objective_placed"] = false,
                ["objective_text"] = "Player one, climb into the right elevator"
            },
            {
                ["position"] = {
                    111.749,
                    124.679,
                    -11.359
                },
                ["placed"] = false,
                ["marker_text"] = "A1",
                ["objective_placed"] = false,
                ["objective_text"] = "Player two, climb into the left elevator to send player one upwards"
            },
            {
                ["position"] = {
                    116.81,
                    126.844,
                    -2.2988
                },
                ["placed"] = false,
                ["marker_text"] = "B2",
                ["objective_placed"] = false,
                ["objective_text"] = "Player one, grab the battery cell on the crate, and bring it back down in the elevator"
            },
            {
                ["position"] = {
                    104.514,
                    116.837,
                    -10.8471
                },
                ["placed"] = false,
                ["marker_text"] = "B3",
                ["objective_placed"] = false,
                ["objective_text"] = "Place the battery cell into the socket on the wall"
            },
            {
                ["position"] = {
                    106.996,
                    112.85,
                    -11.1217
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["hm_strain"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    2.67112,
                    92.2232,
                    -49.75
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Head to control room, and open the door"
            },
            {
                ["position"] = {
                    16.1998,
                    93.0178,
                    -44.3638
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = "Look above the door for the symbols, remember these"
            },
            {
                ["position"] = {
                    7.83506,
                    88.7064,
                    -48.6994
                },
                ["placed"] = false,
                ["marker_text"] = "3A",
                ["objective_placed"] = false,
                ["objective_text"] = "Press the button until you see the right hand symbol from step 2 on the door through the window"
            },
            {
                ["position"] = {
                    7.62147,
                    96.8728,
                    -48.6711
                },
                ["placed"] = false,
                ["marker_text"] = "3B",
                ["objective_placed"] = false,
                ["objective_text"] = "Press the button until you see the left hand symbol from step 2 on the door through the window"
            },
            {
                ["position"] = {
                    16.1814,
                    90.4923,
                    -48.4598
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = "Once the symbols match, press the final button"
            },
            {
                ["position"] = {
                    26.3363,
                    93.1066,
                    -48.8857
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["dm_propaganda"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    22.7077,
                    33.0377,
                    2.11663
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Interact with the dumpster and pick up the 'skull weight' from the ground"
            },
            {
                ["position"] = {
                    2.75122,
                    -2.58131,
                    2.17641
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = "Head to the Martyr's Skull door and place the skull weight on the chain"
            },
            {
                ["position"] = {
                    3.58246,
                    -9.20994,
                    2.94454
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["fm_resurgence"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    147.33,
                    121.798,
                    -3.5
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Head to control panel, you need to line up the pipes on the wall opposite, using the valves infront of you.\nThe default number of times you will need to turn the valves from left to right are as follows:\nx3,x1,x2,x3"
            },
            {
                ["position"] = {
                    145.624,
                    118.25,
                    -2.75
                },
                ["placed"] = false,
                ["marker_text"] = "x3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    145.05,
                    118.711,
                    -2.75
                },
                ["placed"] = false,
                ["marker_text"] = "x1",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    144.596,
                    119.379,
                    -2.75
                },
                ["placed"] = false,
                ["marker_text"] = "x2",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    144.012,
                    119.951,
                    -2.75
                },
                ["placed"] = false,
                ["marker_text"] = "x3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    125.52,
                    108.431,
                    -10.4594
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["hm_complex"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    -262.88,
                    102.764,
                    -20.3531
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Remember the two symbols in the bottom right corner on the back of the panel"
            },
            {
                ["position"] = {
                    -246.135,
                    102.809,
                    -21.9572
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = "Head to the chaos rune circle, and light the candles around the edge that match the two symbols from step 1"
            },
            {
                ["position"] = {
                    -245.004,
                    73.8988,
                    -19.9618
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["cm_archives"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Player 1 = A, Player 2 = B",
        ["markers"] = {
            {
                ["position"] = {
                    -82.6096,
                    103.277,
                    -200.54911
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "This puzzle involves player one pulling the levers on the ground, whilst player two completes a parkour puzzle."
            },
            {
                ["position"] = {
                    -82.6096,
                    103.277,
                    3.54911
                },
                ["placed"] = false,
                ["marker_text"] = "AB",
                ["objective_placed"] = false,
                ["objective_text"] = "Player one, begin by pulling this lever to bring the chandelier to the ground, player two jump on, and player one pull the lever again to raise player two back up, then follow the 'B' sequence of markers."
            },
            {
                ["position"] = {
                    -68.6121,
                    96.5633,
                    10.625
                },
                ["placed"] = false,
                ["marker_text"] = "B1",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -65.2662,
                    103.109,
                    2.45702
                },
                ["placed"] = false,
                ["marker_text"] = "A1",
                ["objective_placed"] = false,
                ["objective_text"] = "Raise"
            },
            {
                ["position"] = {
                    -56.4835,
                    98.7008,
                    10.625
                },
                ["placed"] = false,
                ["marker_text"] = "B2",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -54.8303,
                    86.2133,
                    6.625
                },
                ["placed"] = false,
                ["marker_text"] = "B3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -60.4433,
                    80.6373,
                    7.125
                },
                ["placed"] = false,
                ["marker_text"] = "B4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -65.9746,
                    77.5751,
                    2.54207
                },
                ["placed"] = false,
                ["marker_text"] = "A2",
                ["objective_placed"] = false,
                ["objective_text"] = "Lower then raise"
            },
            {
                ["position"] = {
                    -76.4718,
                    84.0549,
                    10.625
                },
                ["placed"] = false,
                ["marker_text"] = "B5",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -87.1827,
                    86.221,
                    10.625
                },
                ["placed"] = false,
                ["marker_text"] = "B6",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -87.1194,
                    94.3057,
                    10.625
                },
                ["placed"] = false,
                ["marker_text"] = "B7",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -92.4196,
                    96.5517,
                    7.625
                },
                ["placed"] = false,
                ["marker_text"] = "B8",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -99.0863,
                    102.921,
                    4.59083
                },
                ["placed"] = false,
                ["marker_text"] = "A3",
                ["objective_placed"] = false,
                ["objective_text"] = "Lower then raise"
            },
            {
                ["position"] = {
                    -102.45,
                    98.3271,
                    10.4324
                },
                ["placed"] = false,
                ["marker_text"] = "B9",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -101.964,
                    82.254,
                    11.0645
                },
                ["placed"] = false,
                ["marker_text"] = "B10",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -95.9735,
                    82.495,
                    10.4027
                },
                ["placed"] = false,
                ["marker_text"] = "B11",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -96.3399,
                    76.4126,
                    4.67571
                },
                ["placed"] = false,
                ["marker_text"] = "A4",
                ["objective_placed"] = false,
                ["objective_text"] = "Climb up boxes and jump over to chandelier to grab martyr's skull, once player two has completed the puzzle"
            },
            {
                ["position"] = {
                    -95.014,
                    82.1929,
                    5.75208
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["fm_armoury"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo (Parkour)",
        ["markers"] = {
            {
                ["position"] = {
                    -270.316,
                    -123.106,
                    -13
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Enter the building"
            },
            {
                ["position"] = {
                    -257.865,
                    -119.344,
                    -11.7579
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = "Turn the valve"
            },
            {
                ["position"] = {
                    -290.687,
                    -113.581,
                    -11.8457
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = "Climb up to begin parkour, continue up the stairs"
            },
            {
                ["position"] = {
                    -283.647,
                    -113.799,
                    -9.07132
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -273.965,
                    -114.355,
                    -7.03672
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = "Grab the power cell"
            },
            {
                ["position"] = {
                    -268.203,
                    -114.417,
                    -11.7436
                },
                ["placed"] = false,
                ["marker_text"] = "6",
                ["objective_placed"] = false,
                ["objective_text"] = "Place the power cell into the socket, and pull the lever"
            },
            {
                ["position"] = {
                    -265.003,
                    -117.74,
                    -11.6682
                },
                ["placed"] = false,
                ["marker_text"] = "7",
                ["objective_placed"] = false,
                ["objective_text"] = "Head back inside and press the button to open the gate to the skull"
            },
            {
                ["position"] = {
                    -264.375,
                    -113.233,
                    -12.75
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["cm_raid"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    -309.691,
                    -248,
                    228,
                    -24
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Head into alleyway"
            },
            {
                ["position"] = {
                    -313.454,
                    -239.799,
                    -24
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = "Grab the key on the dead body"
            },
            {
                ["position"] = {
                    -288.832,
                    -277.334,
                    -26.6003
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = "Head into the bar, and use the key to open the locked gate"
            },
            {
                ["position"] = {
                    -291.353,
                    -298.638,
                    -22.8588
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = "Go up the stairs, climb over the boxes and plant the breaching charge"
            },
            {
                ["position"] = {
                    -292.015,
                    -290.862,
                    -21.8126
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = "Pickup the key, then head back out to the bar"
            },
            {
                ["position"] = {
                    -295.313,
                    -289.455,
                    -28.4838
                },
                ["placed"] = false,
                ["marker_text"] = "6",
                ["objective_placed"] = false,
                ["objective_text"] = "Use the key to open the gate behind the bar"
            },
            {
                ["position"] = {
                    -301.209,
                    -299.051,
                    -27.684
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["km_heresy"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo (Parkour)",
        ["markers"] = {
            {
                ["position"] = {
                    -25.5652,
                    -98.8414,
                    -3.5002
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Follow number sequence"
            },
            {
                ["position"] = {
                    -28.763,
                    -101.068,
                    -3.67494
                },
                ["placed"] = false,
                ["marker_text"] = "2",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -33.1855,
                    -104.697,
                    -5.07141
                },
                ["placed"] = false,
                ["marker_text"] = "3",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -28.5006,
                    -113.185,
                    -4.39601
                },
                ["placed"] = false,
                ["marker_text"] = "4",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -19.3675,
                    -124.945,
                    -3.57397
                },
                ["placed"] = false,
                ["marker_text"] = "5",
                ["objective_placed"] = false,
                ["objective_text"] = ""
            },
            {
                ["position"] = {
                    -16.1788,
                    -131.041,
                    -3.21764
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    },
    ["template"] = {
        ["title_placed"] = false,
        ["title"] = "MARTYR'S SKULL GUIDE",
        ["players_required"] = "Solo",
        ["markers"] = {
            {
                ["position"] = {
                    9.48675,
                    -229.291,
                    -5.81418
                },
                ["placed"] = false,
                ["marker_text"] = "1",
                ["objective_placed"] = false,
                ["objective_text"] = "Input code: 213\nPress middle button"
            },
            {
                ["position"] = {
                    -399.203,
                    -10.8523,
                    19.2549
                },
                ["placed"] = false,
                ["marker_text"] = "",
                ["objective_placed"] = false,
                ["objective_text"] = "Collect Martyr's Skull!"
            }
        }
    }
}

mod.does_player_need_skull = function()
    local characters_needing = {}

    -- Grab current players in-game
    local player_manager = Managers.player
    local player = Managers.player:local_player(1)

    -- only show players needing skull if players are detected
    if player_manager and player then

        -- find achievement for collecting skull on current map
        local current_mission_martyrskull_achievement_id
        local achievement_manager = Managers.achievements

        if achievement_manager then
            local definitions = achievement_manager:achievement_definitions()
            for _, config in pairs(definitions) do
                local id = config.id
                local category = config.category
                local category_config = AchievementCategories[category]
                local parent_name = category_config.parent_name or category_config.name

                if parent_name == "exploration" then
                    if config.icon and config.icon:match("missions_achievement_puzzle") then
                        local current_mission = Managers.state.mission:mission_name()
                        if config.stat_name:match(current_mission) then
                            current_mission_martyrskull_achievement_id = config.id
                        end
                    end
                end

            end
        end

        local player_id = player._local_player_id
        local player_character_name = player._profile.name

        local collected = false

        if player_character_name then

            -- set collected to achievement status

            if player and current_mission_martyrskull_achievement_id then
                if Managers.achievements:_achievement_completed(player_id, current_mission_martyrskull_achievement_id) then
                    collected = true
                end
            end

            if collected == false then
                -- need to collect
                characters_needing[#characters_needing + 1] = player_character_name
            end

        end

        if collected == false then
            return true
        end

    end

    return false

end


mod.check_guide_marker_exists = function(self, guide_position)
    local markers_by_type = self._markers_by_type

    for marker_type, markers in pairs(markers_by_type) do
        for i = 1, #markers do
            local marker = markers[i]

            if vector3_equals_4dp(Vector3Box.unbox(marker.position), guide_position) then
                return marker
            end
        end
    end

    return nil
end


local MissionObjectiveGoal = require("scripts/extension_systems/mission_objective/utilities/mission_objective_goal")

local function _create_objective(objective_name, localization_key, marker_units, is_side_mission, localized_header)
    local icon = is_side_mission and "content/ui/materials/icons/objectives/bonus" or "content/ui/materials/icons/objectives/main"
    local objective_data = {
        locally_added = true,
        marker_type = "martyrs_skull_guide",
        name = objective_name,
        header = localization_key,
        objective_category = is_side_mission and "side_mission" or "default",
        icon = icon,
        localized_header = localized_header
    }
    local objective = MissionObjectiveGoal:new()

    objective:start_objective(objective_data)

    if marker_units then
        for i = 1, #marker_units do
            local unit = marker_units[i]

            objective:add_marker(unit)
        end
    end

    return objective
end


local apply_color_to_text = function(text, r, g, b)
    return "{#color(" .. r .. "," .. g .. "," .. b .. ")}" .. text .. "{#reset()}"
end


mod.is_player_near_marker = function(self, marker, threshold)

    if marker then
        threshold = threshold or 2

        local player = Managers.player:local_player(1)
        if not player then
            return false
        end

        local player_unit = player.player_unit
        if not player_unit or not Unit.alive(player_unit) then
            return false
        end

        local player_pos = Unit.local_position(player_unit, 1)
        local marker_pos = marker.position

        if marker_pos and marker_pos.unbox then
            marker_pos = marker_pos:unbox()
        end

        if not marker_pos then
            return false
        end

        local dx = player_pos.x - marker_pos.x
        local dy = player_pos.y - marker_pos.y
        local dz = player_pos.z - marker_pos.z
        local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

        return distance <= threshold
    else
        return false
    end
end


local remove_objective = function(objective_name)
    if objective_name then
        Managers.event:trigger("event_remove_mission_objective", objective_name)
    end
end


local player_near_skull = false

mod.setup_walkthrough_markers = function(self)
    self._level = Managers.state.mission:mission()
    local current_level_name = self._level.name
    dbg_lvl = self._level
    player_near_skull = false

    for level_name, walkthrough_markers in pairs(maryrs_skull_walkthrough_markers) do
        if current_level_name == level_name then
            dbg_1 = walkthrough_markers

            -- First, check if player is near ANY guide marker
            for i = #walkthrough_markers.markers, 1, -1 do
                local wmarker = walkthrough_markers.markers[i]
                local marker = mod.check_guide_marker_exists(self, Vector3(wmarker.position[1], wmarker.position[2], wmarker.position[3] + 1))

                if mod:is_player_near_marker(marker, 30) then
                    player_near_skull = true
                    break -- No need to check further, one is enough
                end
            end

            -- Now, process marker/objective placement logic
            for i = #walkthrough_markers.markers, 1, -1 do
                local wmarker = walkthrough_markers.markers[i]
                local marker = mod.check_guide_marker_exists(self, Vector3(wmarker.position[1], wmarker.position[2], wmarker.position[3] + 1))

                -- check using the position data if a marker is already placed at the same place
                if wmarker.placed == false and marker == nil then
                    if mod:get("martyrs_skull_guide_markers_enable") == true then
                        Managers.event:trigger("add_world_marker_position", "martyrs_skull_guide", Vector3(wmarker.position[1], wmarker.position[2], wmarker.position[3]))
                        wmarker.placed = true
                    end
                end

                if marker and marker.widget and marker.widget.style.marker_text and marker.widget.style.icon then
                    marker.widget.style.marker_text.font_size = marker.widget.style.icon.size[1] / 2
                end

                if player_near_skull == true then
                    if wmarker.objective_placed == false and marker ~= nil then
                        marker.markers_aio_type = "martyrs_skull"
                        marker.widget.content.marker_text = wmarker.marker_text
                    end

                    -- check if the objective is already placed at the same place

                    if wmarker.objective_placed == false then

                        if wmarker.objective_text ~= nil and wmarker.objective_text ~= "" then

                            local objective_name = i .. "_" .. current_level_name .. "_marker_guide_" .. wmarker.marker_text
                            local objective = _create_objective(objective_name, nil, nil, true, apply_color_to_text(wmarker.marker_text .. ": ", 255, 170, 30) .. apply_color_to_text(wmarker.objective_text, 204, 204, 204))

                            objective._icon = "content/ui/materials/hud/communication_wheel/icons/location"
                            Managers.event:trigger("event_add_mission_objective", objective)
                        end

                        wmarker.objective_placed = true
                    end

                    -- add maryr's skull guide header to objectives
                    if i == 1 and walkthrough_markers.title_placed == false and marker ~= nil then

                        local needed = ""
                        if mod.does_player_need_skull() == true then
                            needed = "\nYou haven't collected this skull before."
                        else
                            needed = "\nYou have already collected this skull."

                        end

                        local objective = _create_objective(0 .. "_" .. current_level_name .. "_marker_guide_0", nil, nil, true, apply_color_to_text(Localize(self._level.mission_name) .. "\n" .. walkthrough_markers.title, 216, 229, 207) .. "\n" .. apply_color_to_text(walkthrough_markers.players_required, 169, 191, 153) .. needed)
                        objective._icon = "content/ui/materials/hud/communication_wheel/icons/enemy"
                        Managers.event:trigger("event_add_mission_objective", objective)
                        walkthrough_markers.title_placed = true
                    end
                end
            end

            -- If player is not near any guide marker, remove all objectives
            if player_near_skull == false then
                -- Remove header objective if placed
                if walkthrough_markers.title_placed == true then
                    local header_objective_name = 0 .. "_" .. current_level_name .. "_marker_guide_0"
                    remove_objective(header_objective_name)
                    walkthrough_markers.title_placed = false
                end

                -- Remove all marker objectives if placed
                for i = #walkthrough_markers.markers, 1, -1 do
                    local wmarker = walkthrough_markers.markers[i]
                    if wmarker.objective_placed == true then
                        local objective_name = i .. "_" .. current_level_name .. "_marker_guide_" .. wmarker.marker_text
                        remove_objective(objective_name)
                        wmarker.objective_placed = false
                    end
                end
            end
        end
    end
end


local HudElementMissionObjectiveFeedSettings = require("scripts/ui/hud/elements/mission_objective_feed/hud_element_mission_objective_feed_settings")
local HudElementMissionObjectiveFeed = require("scripts/ui/hud/elements/mission_objective_feed/hud_element_mission_objective_feed")

HudElementMissionObjectiveFeed._align_objective_widgets = function(self)
    local ui_renderer = self._parent:ui_renderer()
    local entry_spacing_by_category = HudElementMissionObjectiveFeedSettings.entry_spacing_by_category
    local entry_order_by_objective_category = HudElementMissionObjectiveFeedSettings.entry_order_by_objective_category
    local offset_y = 0
    local objective_widgets_by_name = self._objective_widgets_by_name
    local total_background_height = 0
    local objectives_counter = self._objective_widgets_counter
    local index_counter = 0
    local hud_objectives = self._hud_objectives

    dbg_obj = self

    local function mission_objective_sort_function(a, b)
        local a_objective = hud_objectives[a]
        local b_objective = hud_objectives[b]

        local a_is_marker_guide = string.find(a, "marker_guide") ~= nil
        local b_is_marker_guide = string.find(b, "marker_guide") ~= nil

        -- Helper to extract numeric part from the marker name (e.g., "10_x_marker_guide_10" -> 10)
        local function extract_number(str)
            -- Try to find a number at the start or after underscores
            local num = string.match(str, "^%d+")
            if not num then
                num = string.match(str, "_(%d+)_marker_guide")
            end
            if not num then
                num = string.match(str, "(%d+)$")
            end
            return num and tonumber(num) or nil
        end


        if a_is_marker_guide and b_is_marker_guide then
            local a_num = extract_number(a)
            local b_num = extract_number(b)
            if a_num and b_num then
                return a_num < b_num
            else
                -- Fallback to string comparison if numbers not found
                return a < b
            end
        elseif a_is_marker_guide then
            return true
        elseif b_is_marker_guide then
            return false
        else
            -- Neither is marker_guide, use original priority logic
            local a_priority = a_objective:sort_order() or entry_order_by_objective_category[a_objective:objective_category()]
            local b_priority = b_objective:sort_order() or entry_order_by_objective_category[b_objective:objective_category()]

            if a_priority == b_priority then
                return false
            elseif b_priority < a_priority then
                return false
            end

            return true
        end
    end


    local hud_objectives_names_array = self._hud_objectives_names_array

    -- Deduplicate the array in-place
    do
        local seen = {}
        local new_array = {}
        for i = 1, #hud_objectives_names_array do
            local name = hud_objectives_names_array[i]
            if not seen[name] then
                seen[name] = true
                new_array[#new_array + 1] = name
            end
        end
        -- Replace the original array contents
        for i = 1, #new_array do
            hud_objectives_names_array[i] = new_array[i]
        end
        for i = #new_array + 1, #hud_objectives_names_array do
            hud_objectives_names_array[i] = nil
        end
    end

    if #hud_objectives_names_array > 1 then
        table.sort(hud_objectives_names_array, mission_objective_sort_function)
    end

    for i = 1, #hud_objectives_names_array do
        local objective_name = hud_objectives_names_array[i]
        local widget = objective_widgets_by_name[objective_name]

        if widget then
            local hud_objective = hud_objectives[objective_name]
            local objective_category = hud_objective:objective_category()
            local entry_spacing = entry_spacing_by_category[objective_category] or entry_spacing_by_category.default

            index_counter = index_counter + 1

            local widget_offset = widget.offset

            widget_offset[2] = offset_y

            local widget_height = self:_get_objectives_height(widget, ui_renderer)

            offset_y = offset_y + widget_height + entry_spacing
            total_background_height = total_background_height + widget_height

            if index_counter < objectives_counter then
                total_background_height = total_background_height + entry_spacing
            end
        end
    end

    local background_scenegraph_id = "background"

    self:_set_scenegraph_size(background_scenegraph_id, nil, total_background_height)
end


-- Debug teleport command
mod:command(
    "teleport_marker", "Teleport to a Martyr's Skull marker by index or marker_text", function(args)
        local current_level = Managers.state.mission and Managers.state.mission:mission()

        if not current_level then
            mod:echo("No mission loaded.")
            return
        end

        local current_level_name = current_level.name
        local walkthrough_markers = maryrs_skull_walkthrough_markers[current_level_name]

        if not walkthrough_markers then
            mod:echo("No markers for this level.")
            return
        end

        if not args then
            mod:echo("Usage: /teleport_marker <index or marker_text>")
            -- return
        end

        local target_marker = nil
        local arg = args

        for i, wmarker in ipairs(walkthrough_markers.markers) do
            if tostring(i) == arg or tostring(wmarker.marker_text) == arg then
                target_marker = wmarker
                break
            end
        end

        if not target_marker then
            mod:echo("Marker not found.")
            return
        end

        local player = Managers.player:local_player(1)
        if not player or not player.player_unit or not Unit.alive(player.player_unit) then
            mod:echo("Player not available.")
            return
        end

        local PlayerMovement = require("scripts/utilities/player_movement")
        local pos = Vector3(target_marker.position[1], target_marker.position[2], target_marker.position[3])

        PlayerMovement.teleport_fixed_update(player.player_unit, pos)
        mod:echo("Teleported to marker " .. (target_marker.marker_text or arg))
    end


)

mod.reset_martyrs_skull_guides = function()
    for level_name, walkthrough_markers in pairs(maryrs_skull_walkthrough_markers) do
        walkthrough_markers.title_placed = false
        for i, wmarker in ipairs(walkthrough_markers.markers) do
            wmarker.placed = false
            wmarker.objective_placed = false
        end
    end
end


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

            self._level = Managers.state.mission:mission()
            local current_level_name = self._level.name

            mod:echo(current_level_name)
            mod:echo(target_location)
            -- Managers.event:trigger("add_world_marker_position", "objective", Vector3(-10, -10, 10))

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


