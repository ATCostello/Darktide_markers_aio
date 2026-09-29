local mod = get_mod("markers_aio")
local MarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/modules/ammo_med/ammo_med_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISettings = require("scripts/settings/ui/ui_settings")

local fs = mod.frame_settings

local AmmoUtility = require("scripts/utilities/ammo")
local BuffSettings = require("scripts/settings/buff/buff_settings")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local medical_crate_config = require("scripts/settings/deployables/templates/medical_crate")

local STATIC_WEAPON_SLOTS = {
	"slot_primary",
	"slot_secondary",
}

local AMMO_STATUS_CIRCLE_SIZE = {
	30,
	30,
}

mod.ammo_status_colour_markup = function(text, kind)
	local ammo_fs = mod.frame_settings
	local r, g, b

	if kind == "waste" then
		r = ammo_fs and ammo_fs.ammo_status_waste_colour_R
		g = ammo_fs and ammo_fs.ammo_status_waste_colour_G
		b = ammo_fs and ammo_fs.ammo_status_waste_colour_B
	else
		r = ammo_fs and ammo_fs.ammo_status_gain_colour_R
		g = ammo_fs and ammo_fs.ammo_status_gain_colour_G
		b = ammo_fs and ammo_fs.ammo_status_gain_colour_B
	end

	return string.format("{#color(%d,%d,%d)}%s{#reset()}", r or 255, g or 255, b or 255, text)
end

local function read_weapon_ammo_slots(unit)
	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")

	if not unit_data_extension then
		return nil
	end

	local slots = {}

	for i = 1, #STATIC_WEAPON_SLOTS do
		local slot_name = STATIC_WEAPON_SLOTS[i]
		local ok, component = pcall(function()
			return unit_data_extension:read_component(slot_name)
		end)

		if ok and component and component.max_ammunition_reserve and component.max_ammunition_reserve > 0 then
			slots[#slots + 1] = {
				reserve = component.current_ammunition_reserve or 0,
				max_reserve = component.max_ammunition_reserve,
				clip = AmmoUtility.current_ammo_in_clips(component),
				max_clip = AmmoUtility.max_ammo_in_clips(component),
			}
		end
	end

	if #slots == 0 then
		return nil
	end

	return slots
end

local function player_ammo_percentage(unit)
	local slots = read_weapon_ammo_slots(unit)

	if not slots then
		return nil
	end

	local total = 0
	local max_total = 0

	for i = 1, #slots do
		total = total + slots[i].reserve
		max_total = max_total + slots[i].max_reserve
	end

	if max_total <= 0 then
		return nil
	end

	return total / max_total
end

local function predict_ammo_restore(unit, pickup_name)
	local slots = read_weapon_ammo_slots(unit)

	if not slots then
		return 0, 0
	end

	local pickup_data = Pickups.by_name[pickup_name]

	if not pickup_data or type(pickup_data.ammo_amount_func) ~= "function" then
		return 0, 0
	end

	local difficulty = Managers.state.difficulty
	local modifier = difficulty and difficulty:get_ammo_modifier() or 1
	local data = table.clone(pickup_data)
	data.modifier = modifier

	local total_restored = 0
	local total_potential = 0

	for i = 1, #slots do
		local slot = slots[i]
		local pickup_amount = pickup_data.ammo_amount_func(slot.max_reserve, slot.max_clip, data)

		if pickup_amount and pickup_amount > 0 then
			local missing_clip = math.max(0, slot.max_clip - slot.clip)
			local new_ammo_amount = math.min(slot.reserve + pickup_amount, slot.max_reserve + missing_clip)
			local restored = math.max(0, new_ammo_amount - slot.reserve)

			total_potential = total_potential + pickup_amount
			total_restored = total_restored + restored
		end
	end

	return total_restored, total_potential
end

local function find_most_needy_teammate(self_unit, local_percentage)
	local player_unit_spawn = Managers.state.player_unit_spawn
	local alive_players = player_unit_spawn and player_unit_spawn:alive_players()

	if not alive_players or not UISettings or not UISettings.archetype_font_icon then
		return nil
	end

	local most_needy = nil
	local lowest_percentage = math.huge

	for _, player in pairs(alive_players) do
		local player_unit = player.player_unit

		if player_unit and player_unit ~= self_unit then
			local ammo_percentage = player_ammo_percentage(player_unit)

			if ammo_percentage and ammo_percentage < lowest_percentage then
				lowest_percentage = ammo_percentage

				local profile = player:profile()
				local archetype_name = profile and profile.archetype and profile.archetype.name

				most_needy = {
					player = player,
					percentage = local_percentage and math.max(0, local_percentage - ammo_percentage)
						or ammo_percentage,
					icon = archetype_name and UISettings.archetype_font_icon[archetype_name] or "",
					slot = player:slot(),
				}
			end
		end
	end

	return most_needy
end

local function update_ammo_status(marker, unit, player_unit)
	marker.ammo_status = nil

	if not marker or not unit or not player_unit or not Unit.alive(player_unit) then
		return
	end

	if marker.widget and marker.widget.style and marker.widget.style.ammo_needy_icon then
		marker.widget.content.ammo_needy_icon = ""
	end

	if marker.widget and marker.widget.style and marker.widget.style.ammo_status_circle then
		marker.widget.content.ammo_status_circle_visible = false
	end

	if marker.widget and marker.widget.style and marker.widget.style.marker_text_ammo_med then
		marker.widget.content.marker_text_ammo_med = ""
	end

	local status_fs = mod.frame_settings

	if status_fs and status_fs.ammo_status_enable == false then
		return
	end

	if
		not status_fs.ammo_status_colours_enable
		and not status_fs.ammo_status_numeric_enable
		and not status_fs.ammo_status_show_most_needy
		and not status_fs.ammo_status_circle_enable
	then
		return
	end

	local pickup_type = marker.pickup_type or mod.get_marker_pickup_type(marker) or (marker.data and marker.data.type)

	if
		pickup_type ~= "small_clip"
		and pickup_type ~= "large_clip"
		and pickup_type ~= "ammo_cache_pocketable"
		and pickup_type ~= "ammo_cache_deployable"
	then
		return
	end

	local gain, potential = predict_ammo_restore(player_unit, pickup_type)

	if not gain or potential <= 0 then
		return
	end

	local waste = math.max(0, potential - gain)
	local local_percentage = player_ammo_percentage(player_unit)
	local status = "takeall"
	local needy_player = nil

	local margin = (status_fs.ammo_status_margin or 0) / 100

	local neediness_enabled = status_fs.ammo_status_show_most_needy or status_fs.ammo_status_circle_enable

	if neediness_enabled then
		needy_player = find_most_needy_teammate(player_unit, local_percentage)
	end

	local teammate_more_needy = needy_player and local_percentage and needy_player.percentage > margin

	if status_fs.ammo_status_show_most_needy and teammate_more_needy then
		status = "teammate"
	elseif waste > 0 then
		status = "wasted"
	end

	local status_colour

	if status == "wasted" then
		status_colour = {
			status_fs.ammo_status_red_colour_R,
			status_fs.ammo_status_red_colour_G,
			status_fs.ammo_status_red_colour_B,
		}
	elseif status == "teammate" then
		status_colour = {
			status_fs.ammo_status_orange_colour_R,
			status_fs.ammo_status_orange_colour_G,
			status_fs.ammo_status_orange_colour_B,
		}
	else
		status_colour = {
			status_fs.ammo_status_green_colour_R,
			status_fs.ammo_status_green_colour_G,
			status_fs.ammo_status_green_colour_B,
		}
	end

	marker.ammo_status = {
		gain = gain,
		waste = waste,
		potential = potential,
		status = status,
		needy_player = needy_player,
		teammate_more_needy = teammate_more_needy,
		local_percentage = local_percentage,
		colour = status_colour,
	}
end

local function apply_ammo_status_marker_visuals(marker)
	local status = marker.ammo_status
	local widget = marker.widget

	marker.ammo_status_dim = false

	if not status or not widget or not widget.style then
		return
	end

	local status_fs = mod.frame_settings

	if status_fs.ammo_status_dim_unwanted_enable and status.status ~= "takeall" then
		marker.ammo_status_dim = true
	end

	if status_fs.ammo_status_colours_enable and widget.style.ring then
		if status.status == "wasted" then
			mod.set_colour_argb(
				widget.style.ring.color,
				255,
				status_fs.ammo_status_red_colour_R,
				status_fs.ammo_status_red_colour_G,
				status_fs.ammo_status_red_colour_B
			)
		elseif status.status == "teammate" then
			mod.set_colour_argb(
				widget.style.ring.color,
				255,
				status_fs.ammo_status_orange_colour_R,
				status_fs.ammo_status_orange_colour_G,
				status_fs.ammo_status_orange_colour_B
			)
		else
			mod.set_colour_argb(
				widget.style.ring.color,
				255,
				status_fs.ammo_status_green_colour_R,
				status_fs.ammo_status_green_colour_G,
				status_fs.ammo_status_green_colour_B
			)
		end
	end

	local circle_style = widget.style.ammo_status_circle
	local needy_icon_style = widget.style.ammo_needy_icon

	if circle_style then
		widget.content.ammo_needy_icon = ""

		if status_fs.ammo_status_circle_enable then
			local circle_status = status.teammate_more_needy and "teammate" or status.status
			local teammate_status = status_fs.ammo_status_show_most_needy and circle_status == "teammate"
			local circle_colour

			if circle_status == "wasted" then
				circle_colour = {
					status_fs.ammo_status_red_colour_R,
					status_fs.ammo_status_red_colour_G,
					status_fs.ammo_status_red_colour_B,
				}
			elseif circle_status == "teammate" then
				circle_colour = {
					status_fs.ammo_status_orange_colour_R,
					status_fs.ammo_status_orange_colour_G,
					status_fs.ammo_status_orange_colour_B,
				}
			else
				circle_colour = {
					status_fs.ammo_status_green_colour_R,
					status_fs.ammo_status_green_colour_G,
					status_fs.ammo_status_green_colour_B,
				}
			end

			mod.set_colour_argb(circle_style.color, 255, circle_colour[1], circle_colour[2], circle_colour[3])
			widget.content.ammo_status_circle_visible = true

			local circle_size = AMMO_STATUS_CIRCLE_SIZE[1] * marker.scale
			local bg_size = widget.style.background and widget.style.background.size or {
				128,
				128,
			}
			local circle_offset_x = bg_size[1] * 0.4 - circle_size * 0.5
			local circle_offset_y = -bg_size[2] * 0.4 + circle_size * 0.5

			circle_style.offset[1] = circle_offset_x
			circle_style.offset[2] = circle_offset_y
			circle_style.offset[3] = 12

			local glow_style = widget.style.ammo_status_circle_glow
			if glow_style then
				glow_style.offset[1] = circle_offset_x
				glow_style.offset[2] = circle_offset_y
				glow_style.offset[3] = 11
				glow_style.visible = not teammate_status
			end

			local shadow_style = widget.style.ammo_status_circle_shadow
			if shadow_style then
				shadow_style.offset[1] = circle_offset_x
				shadow_style.offset[2] = circle_offset_y
				shadow_style.offset[3] = 13
				shadow_style.visible = not teammate_status
			end

			local needy = status.needy_player

			if
				status_fs.ammo_status_show_most_needy
				and teammate_status
				and needy
				and needy.icon
				and needy.icon ~= ""
				and needy_icon_style
			then
				local player_colour = UISettings.player_slot_colors[needy.slot]

				if player_colour then
					mod.set_colour(needy_icon_style.text_color, player_colour)
				end

				needy_icon_style.size[1] = circle_size
				needy_icon_style.size[2] = circle_size
				needy_icon_style.font_size = circle_size * 0.7
				needy_icon_style.offset[1] = circle_offset_x
				needy_icon_style.offset[2] = circle_offset_y
				needy_icon_style.offset[3] = 13

				widget.content.ammo_status_circle = "content/ui/materials/hud/interactions/frames/mission_back"
			end
		else
			widget.content.ammo_status_circle_visible = false
		end
	end

	--[[if status_fs.ammo_status_show_most_needy and widget.style.ammo_needy_icon then
		local needy = status.needy_player

		if status.status == "teammate" and needy and needy.icon and needy.icon ~= "" then
			local player_color = UISettings.player_slot_colors[needy.slot]

			if player_color then
				mod.set_colour(widget.style.ammo_needy_icon.text_color, player_color)
			end

			widget.content.ammo_needy_icon = needy.icon
			widget.style.ammo_needy_icon.font_size = 40 * marker.scale
		else
			widget.content.ammo_needy_icon = ""
		end
	end]]

	local is_direct_ammo_pickup = marker.pickup_type == "small_clip" or marker.pickup_type == "large_clip"
	local marker_text_style = widget.style.marker_text_ammo_med

	if not marker_text_style then
		return
	end

	if status_fs.ammo_status_numeric_enable and status_fs.ammo_status_marker_text_enable and is_direct_ammo_pickup then
		if (status_fs.ammo_status_show_gain and status.gain) or (status_fs.ammo_status_show_waste and status.waste) then
			local numeric_parts = {}

			if status.status == "teammate" and status.needy_player then
				local needy = status.needy_player
				local needy_slot = needy.player and needy.player:slot() or needy.slot
				local needy_colour = UISettings.player_slot_colors[needy_slot]

				numeric_parts[#numeric_parts + 1] = string.format(
					"{#color(%d,%d,%d)}%s{#reset()}",
					needy_colour and needy_colour[2] or 255,
					needy_colour and needy_colour[3] or 255,
					needy_colour and needy_colour[4] or 255,
					needy.icon
				) .. " (+" .. math.ceil((needy.percentage or 0) * 100) .. "%)"
			end

			if status_fs.ammo_status_show_gain and status.gain then
				numeric_parts[#numeric_parts + 1] = mod.ammo_status_colour_markup("+" .. status.gain, "gain")
			end

			if status_fs.ammo_status_show_waste and status.waste then
				numeric_parts[#numeric_parts + 1] = mod.ammo_status_colour_markup("(-" .. status.waste .. ")", "waste")
			end

			widget.content.marker_text_ammo_med = table.concat(numeric_parts, " ")

			local font_size = (status_fs.ammo_status_text_font_size or 22) * marker.scale

			marker_text_style.font_size = font_size
			marker_text_style.default_font_size = font_size
			-- Wide, non-wrapping text box so "+30 (-5)" stays on a single line.
			marker_text_style.size = {
				status_fs.ammo_status_text_width or 500,
				64,
			}
			marker_text_style.word_wrap = false
			marker_text_style.text_horizontal_alignment = "center"
			marker_text_style.text_vertical_alignment = "center"

			local position = status_fs.ammo_status_text_position or "Top"
			local extra_offset = status_fs.ammo_status_text_offset or 0
			local bg_size = widget.style.background and widget.style.background.size or {
				128,
				128,
			}

			marker_text_style.offset[1] = 0
			marker_text_style.offset[2] = 0
			marker_text_style.offset[3] = 10

			if position == "Bottom" then
				marker_text_style.offset[2] = bg_size[2] / 2 + extra_offset
			elseif position == "Top" then
				marker_text_style.offset[2] = -bg_size[2] / 2 - extra_offset
			elseif position == "Left" then
				marker_text_style.offset[1] = -bg_size[1] / 2 - extra_offset
			elseif position == "Right" then
				marker_text_style.offset[1] = bg_size[1] / 2 + extra_offset
			end
		else
			widget.content.marker_text_ammo_med = ""
		end
	elseif is_direct_ammo_pickup then
		widget.content.marker_text_ammo_med = ""
	end
end

local check_recolorstimms = function()
	if fs.recolor_stimm_compat_enable then
		local dmf = get_mod("DMF")
		local _disabled_mods = dmf:get("disabled_mods_list") or {}

		if _disabled_mods["RecolorStimms"] then
			mod.RecolorStimms = nil
			return
		end

		mod.RecolorStimms = get_mod("RecolorStimms") or nil
	else
		mod.RecolorStimms = nil
	end
end

mod.on_all_mods_loaded = function()
	local is_mod_loading = true
	mod:hook_require("scripts/extension_systems/unit_templates", function(instance)
		if is_mod_loading then
			-- live games
			mod:hook_safe(
				instance.medical_crate_deployable,
				"husk_init",
				function(unit, config, template_context, game_session, game_object_id, owner_id)
					mod.add_medkit_marker_and_proximity(nil, unit)
				end
			)

			-- private games
			mod:hook_safe(
				instance.medical_crate_deployable,
				"local_unit_spawned",
				function(
					unit,
					template_context,
					game_object_data,
					side_id,
					deployable,
					placed_on_unit,
					owner_unit_or_nil
				)
					mod.add_medkit_marker_and_proximity(nil, unit)
				end
			)

			is_mod_loading = false
		end
	end)

	local load_package = function(path, id)
		if not Managers.package:has_loaded(path) then
			Managers.package:load(path, id)
			return
		end
	end
	mod._ensure_icon_packages_loaded()

	load_package("content/levels/training_grounds/missions/mission_tg_basic_combat_01", "medkit_radius")
	load_package("packages/ui/views/options_view/options_view", "large_ammo1")
	load_package("packages/ui/views/inventory_background_view/inventory_background_view", "large_ammo2")

	check_recolorstimms()
end

mod:hook_safe(CLASS.UIViewHandler, "close_view", function(self, view_name, ...)
	if view_name == "dmf_options_view" or view_name == "options_view" then
		check_recolorstimms()
		mod.build_frame_settings()
	end
end)

local get_max_distance = function()
	local max_distance = fs.ammo_med_max_distance

	if max_distance == nil then
		max_distance = fs.ammo_med_max_distance
	end

	return max_distance
end

local med_crate_decals = mod:persistent_table("med_crate_decals")
local med_crate_units = mod:persistent_table("med_crate_units")

local ProximityHeal = require("scripts/extension_systems/proximity/side_relation_gameplay_logic/proximity_heal")

ProximityHeal._cb_world_markers_list_request = function(self, world_markers)
	self._world_markers_list = world_markers
end

mod:hook_safe(ProximityHeal, "update", function(self, dt, t)
	if self and self._unit then
		med_crate_units[self._unit] = true
	end
end)

local med_crate_estimates = mod:persistent_table("med_crate_estimates")

local function improved_medical_crate_modifier()
	if mod.check_players_talents_for_Field_Improvisation() then
		local improved_settings = BuffSettings.keyword_settings[BuffSettings.keywords.improved_medical_crate]

		if improved_settings and improved_settings.heal_multiplier then
			return improved_settings.heal_multiplier
		end
	end

	return 1
end

local function player_heal_multipliers(player_unit)
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return 1, 1, true
	end

	local ok_character_state, character_state_component = pcall(function()
		return unit_data_extension:read_component("character_state")
	end)

	if
		ok_character_state
		and character_state_component
		and PlayerUnitStatus.is_knocked_down(character_state_component)
	then
		return (medical_crate_config.knock_down_player_heal_speed_multiplier or 0.1),
			(medical_crate_config.knock_down_player_heal_cost_multiplier or 0.3),
			true
	end

	local ok_disabled_state, disabled_state_component = pcall(function()
		return unit_data_extension:read_component("disabled_character_state")
	end)

	if ok_disabled_state and disabled_state_component and PlayerUnitStatus.is_consumed(disabled_state_component) then
		return 1, 1, false
	end

	return 1, 1, true
end

-- The deployable settings moved proximity_radius into proximity_check_params, so read
-- both layouts to stay compatible with either game version.
local function get_med_crate_proximity_radius()
	local check_params = medical_crate_config.proximity_check_params

	if check_params and check_params.proximity_radius then
		return check_params.proximity_radius
	end

	return medical_crate_config.proximity_radius or 3
end

local function estimate_medcrate_consumption(unit, dt)
	if not dt or dt <= 0 then
		return 0
	end

	local player_unit_spawn = Managers.state.player_unit_spawn
	local alive_players = player_unit_spawn and player_unit_spawn:alive_players()

	if not alive_players then
		return 0
	end

	local crate_position = POSITION_LOOKUP and POSITION_LOOKUP[unit] or Unit.local_position(unit, 1)

	if not crate_position then
		return 0
	end

	local proximity_radius = get_med_crate_proximity_radius()
	local radius_squared = proximity_radius * proximity_radius
	local heal_rate_percentage = (
		medical_crate_config.proximity_init_data and medical_crate_config.proximity_init_data.heal_rate_percentage
	) or 0.05
	local heal_amount_modifier = improved_medical_crate_modifier()
	local total_consumed = 0

	for _, player in pairs(alive_players) do
		local player_unit = player.player_unit

		if player_unit and POSITION_LOOKUP and POSITION_LOOKUP[player_unit] then
			local player_position = POSITION_LOOKUP[player_unit]

			if Vector3.distance_squared(crate_position, player_position) <= radius_squared then
				local health_extension = ScriptUnit.has_extension(player_unit, "health_system")

				if health_extension and health_extension:is_alive() then
					local max_health = health_extension:max_health()

					if max_health and max_health > 0 then
						local current_health = health_extension:current_health() or 0
						local missing_health = math.max(0, max_health - current_health)

						if missing_health > 0 then
							local speed_multiplier, cost_multiplier, can_heal = player_heal_multipliers(player_unit)

							if can_heal and speed_multiplier > 0 then
								local heal_amount = max_health
									* heal_rate_percentage
									* dt
									* heal_amount_modifier
									* speed_multiplier
								local health_added = math.min(missing_health, heal_amount)

								total_consumed = total_consumed + health_added * cost_multiplier
							end
						end
					end
				end
			end
		end
	end

	return total_consumed
end

mod.update_med_crate_estimates = function(unit)
	if not unit or not Unit.alive(unit) then
		return
	end

	local has_proximity_extension = not not ScriptUnit.has_extension(unit, "proximity_system")

	if has_proximity_extension then
		return
	end

	local estimate_data = med_crate_estimates[unit]

	if not estimate_data then
		estimate_data = {
			amount_healed = 0,
			deployed_at = Managers.time:time("gameplay"),
		}
		med_crate_estimates[unit] = estimate_data
	end

	local gameplay_time = Managers.time:time("gameplay")

	if estimate_data.last_update_t == gameplay_time then
		return
	end

	estimate_data.last_update_t = gameplay_time

	local dt = Managers.time:delta_time("gameplay")
	local consumption = estimate_medcrate_consumption(unit, dt)

	if consumption and consumption > 0 then
		estimate_data.amount_healed =
			math.min(medical_crate_config.optional_heal_reserve or 600, estimate_data.amount_healed + consumption)
	end
end

mod.add_medkit_marker_and_proximity = function(self, unit)
	local marker_exists = false
	local world_markers = self and self._markers_by_id

	if world_markers then
		for _, marker in pairs(world_markers) do
			if marker.type == MarkerTemplate.name and marker.unit == unit then
				marker_exists = true
				break
			end
		end
	end

	if not marker_exists then
		Managers.event:trigger("add_world_marker_unit", MarkerTemplate.name, unit)
	end

	-- add proximity circle to medkits, thanks Raindish! (From NumericUI)
	if fs.display_med_ring == true and unit then
		local package_path = "content/levels/training_grounds/missions/mission_tg_basic_combat_01"

		if not Managers.package:has_loaded(package_path) then
			Managers.package:load(package_path, "ammo_med_markers")
			return
		end

		local decal_unit_name = "content/levels/training_grounds/fx/decal_aoe_indicator"

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
					local diameter = get_med_crate_proximity_radius() * 2 + 1.5
					Unit.set_local_scale(decal_unit, 1, Vector3(diameter, diameter, 1))

					-- Set color of unit
					local material_value = Quaternion.identity()

					local field_improv_active = mod.check_players_talents_for_Field_Improvisation()

					if field_improv_active and fs.display_field_improv_colour == true then
						local r = fs.field_improv_colour_R / 255
						local g = fs.field_improv_colour_G / 255
						local b = fs.field_improv_colour_B / 255
						Quaternion.set_xyzw(material_value, r, g, b, 0.5)
					else
						Quaternion.set_xyzw(material_value, 0, 1, 0, 0.5)
					end

					Unit.set_vector4_for_material(decal_unit, "projector", "particle_color", material_value, true)
					Unit.set_scalar_for_material(decal_unit, "projector", "color_multiplier", 0.07)

					med_crate_decals[position_string] = {
						decal_unit,
						unit,
					}
				end
			end
		end
	end
end

mod.check_players_talents_for_Field_Improvisation = function()
	local alive_players = Managers.state.player_unit_spawn:alive_players()

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
		local player = Managers.player:local_player_safe(1)
		local player_unit = player and player.player_unit

		local is_native_med_crate = marker.type == "interaction"
			and marker.data
			and marker.data._active_interaction_type == "deployable_marker"

		if is_native_med_crate then
			marker.markers_aio_type = "ammo_med"
			marker.aio_suppress = true
			return
		end

        local pickup_type = mod.get_marker_pickup_type(marker)

        if
            pickup_type and pickup_type == "small_clip"
			or pickup_type and pickup_type == "large_clip"
			or pickup_type and pickup_type == "small_grenade"
			or pickup_type and pickup_type == "ammo_cache_pocketable"
			or pickup_type and pickup_type == "medical_crate_pocketable"
			or pickup_type and pickup_type == "medical_crate_deployable"
			or pickup_type and pickup_type == "ammo_cache_deployable"
			or marker.type == MarkerTemplate.name
			or marker.data and marker.data.type == "small_clip"
			or marker.data and marker.data.type == "large_clip"
			or marker.data and marker.data.type == "small_grenade"
			or marker.data and marker.data.type == "ammo_cache_pocketable"
			or marker.data and marker.data.type == "medical_crate_pocketable"
			or marker.data and marker.data.type == "medical_crate_deployable"
			or marker.data and marker.data.type == "ammo_cache_deployable"
			or marker.data and marker.data._active_interaction_type == "health_station"
			or unit and ScriptUnit.has_extension(unit, "health_station_system")
		then
			marker.markers_aio_type = "ammo_med"

			marker.pickup_type = pickup_type

			marker.aio_check_line_of_sight = fs.ammo_med_require_line_of_sight

			update_ammo_status(marker, unit, player_unit)

			mod.set_colour_argb(marker.widget.style.icon.color, 255, 255, 255, 255)

			mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))

			marker.template.screen_clamp = fs.ammo_med_keep_on_screen
			marker.block_screen_clamp = false

			self._marker_templates[MarkerTemplate.name] = MarkerTemplate

			local max_spawn_distance_sq = max_distance * max_distance
			HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

			if self.fade_settings then
				self.fade_settings.distance_max = max_distance
				self.fade_settings.distance_min = max_distance - (self.evolve_distance or 0) * 4
			end

			marker.template.max_distance = max_distance
			marker.template.fade_settings.distance_max = max_distance
			marker.template.fade_settings.distance_min = max_distance - (marker.template.evolve_distance or 0) * 8

			local med_crate_pos = POSITION_LOOKUP[marker.unit]

			if
				marker.data and marker.data._active_interaction_type == "health_station"
				or unit and ScriptUnit.has_extension(unit, "health_station_system")
			then
				marker.aio_check_line_of_sight = fs.med_station_require_line_of_sight

				local health_station_extension = ScriptUnit.has_extension(unit, "health_station_system")

				local remaining_charges = health_station_extension and health_station_extension._charge_amount or 0

				if
					marker.widget
					and marker.widget.style
					and marker.widget.style.marker_text_ammo_med
					and marker.widget.style.icon
					and marker.widget.style.icon.size[1]
				then
					--marker.widget.style.marker_text.font_size = marker.widget.style.icon.size[1]
				end

				if marker.widget.style.marker_text_ammo_med then
					marker.widget.style.marker_text_ammo_med.font_size = 40 * marker.scale
					marker.widget.style.marker_text_ammo_med.default_font_size = 40 * marker.scale
				end

				if fs.display_med_charges == true then
					marker.widget.content.marker_text_ammo_med = tostring(remaining_charges)
				end

				if fs.change_colour_for_ammo_charges == true then
					if remaining_charges == 4 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_4_colour_R,
							fs.charges_4_colour_G,
							fs.charges_4_colour_B
						)
					elseif remaining_charges == 3 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_3_colour_R,
							fs.charges_3_colour_G,
							fs.charges_3_colour_B
						)
					elseif remaining_charges == 2 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_2_colour_R,
							fs.charges_2_colour_G,
							fs.charges_2_colour_B
						)
					elseif remaining_charges == 1 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_1_colour_R,
							fs.charges_1_colour_G,
							fs.charges_1_colour_B
						)
					end
				end

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					100,
					fs.med_crate_colour_R,
					fs.med_crate_colour_G,
					fs.med_crate_colour_B
				)
			end

			local field_improv_active = mod.check_players_talents_for_Field_Improvisation()

			if
				pickup_type == "ammo_cache_deployable"
				or marker.data and marker.data.type == "ammo_cache_deployable"
			then
				local game_session = Managers.state.game_session:game_session()
				local game_object_id = Managers.state.unit_spawner:game_object_id(unit)
				local remaining_charges = GameSession.game_object_field(game_session, game_object_id, "charges")

				if
					marker.widget
					and marker.widget.style
					and marker.widget.style.marker_text_ammo_med
					and marker.widget.style.icon
					and marker.widget.style.icon.size[1]
				then
					--marker.widget.style.marker_text.font_size = marker.widget.style.icon.size[1]
				end

				if fs.display_ammo_charges == true then
					marker.widget.content.marker_text_ammo_med = tostring(remaining_charges)
				end

				if fs.change_colour_for_ammo_charges == true then
					if remaining_charges == 4 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_4_colour_R,
							fs.charges_4_colour_G,
							fs.charges_4_colour_B
						)
					elseif remaining_charges == 3 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_3_colour_R,
							fs.charges_3_colour_G,
							fs.charges_3_colour_B
						)
					elseif remaining_charges == 2 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_2_colour_R,
							fs.charges_2_colour_G,
							fs.charges_2_colour_B
						)
					elseif remaining_charges == 1 then
						mod.set_colour_argb(
							marker.widget.style.background.color,
							255,
							fs.charges_1_colour_R,
							fs.charges_1_colour_G,
							fs.charges_1_colour_B
						)
					end
				end

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					100,
					fs.ammo_crate_colour_R,
					fs.ammo_crate_colour_G,
					fs.ammo_crate_colour_B
				)
			end

			local max_distance = get_max_distance()

			self.max_distance = max_distance
			marker.max_distance = max_distance

			if self.fade_settings then
				self.fade_settings.distance_max = max_distance
				self.fade_settings.distance_min = max_distance - (self.evolve_distance or 0) * 2
			end

			if pickup_type == "small_clip" or marker.data and marker.data.type == "small_clip" then
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.ammo_small_border_colour))
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					fs.ammo_small_colour_R,
					fs.ammo_small_colour_G,
					fs.ammo_small_colour_B
				)
			elseif pickup_type == "large_clip" or marker.data and marker.data.type == "large_clip" then
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.ammo_large_border_colour))
				if fs.ammo_med_markers_alternate_large_ammo_icon == true then
					marker.widget.content.icon = "content/ui/materials/icons/presets/preset_16"
				else
					marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"
				end

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					fs.ammo_large_colour_R,
					fs.ammo_large_colour_G,
					fs.ammo_large_colour_B
				)
			elseif pickup_type == "small_grenade" or marker.data and marker.data.type == "small_grenade" then
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.grenade_border_colour))
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/grenade"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					fs.grenade_colour_R,
					fs.grenade_colour_G,
					fs.grenade_colour_B
				)
			elseif
				pickup_type == "ammo_cache_pocketable"
				or marker.data and marker.data.type == "ammo_cache_pocketable"
			then
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.ammo_crate_border_colour))
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					fs.ammo_crate_colour_R,
					fs.ammo_crate_colour_G,
					fs.ammo_crate_colour_B
				)
				if field_improv_active then
					if fs.display_field_improv_colour == true then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if fs.display_field_improv_icon == true then
						marker.widget.content.field_improv_ammo_med =
							"content/ui/materials/hud/interactions/icons/cosmetics_store"
					else
						marker.widget.content.field_improv_ammo_med = ""
					end
				else
					marker.widget.content.field_improv_ammo_med = ""
				end

				if marker.widget.style.field_improv_ammo_med then
					marker.widget.style.field_improv_ammo_med.size[1] = marker.widget.style.icon.size[1]
					marker.widget.style.field_improv_ammo_med.size[2] = marker.widget.style.icon.size[2]

					marker.widget.style.field_improv_ammo_med.offset[1] = 35 * marker.scale
				end
			elseif
				pickup_type == "ammo_cache_deployable"
				or marker.data and marker.data.type == "ammo_cache_deployable"
			then
				if marker.widget.style.ring then
					mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.ammo_crate_border_colour))
				end
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"

				if field_improv_active then
					if fs.display_field_improv_colour == true and marker.widget.style.ring then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if fs.display_field_improv_icon == true then
						marker.widget.content.field_improv_ammo_med =
							"content/ui/materials/hud/interactions/icons/cosmetics_store"
					else
						marker.widget.content.field_improv_ammo_med = ""
					end
				else
					marker.widget.content.field_improv_ammo_med = ""
				end

				if marker.widget.style.marker_text_ammo_med then
					marker.widget.style.marker_text_ammo_med.font_size = 40 * marker.scale
					marker.widget.style.marker_text_ammo_med.default_font_size = 40 * marker.scale
				end

				if marker.widget.style.field_improv_ammo_med then
					marker.widget.style.field_improv_ammo_med.size[1] = marker.widget.style.icon.size[1]
					marker.widget.style.field_improv_ammo_med.size[2] = marker.widget.style.icon.size[2]

					marker.widget.style.field_improv_ammo_med.offset[1] = 35 * marker.scale
				end
			elseif
				pickup_type == "medical_crate_pocketable"
				or marker.data and marker.data.type == "medical_crate_pocketable"
			then
				if marker.widget.style.ring then
					mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.med_crate_border_colour))
				end
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					fs.med_crate_colour_R,
					fs.med_crate_colour_G,
					fs.med_crate_colour_B
				)
				if field_improv_active then
					if fs.display_field_improv_colour == true and marker.widget.style.ring then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if fs.display_field_improv_icon == true then
						marker.widget.content.field_improv_ammo_med =
							"content/ui/materials/hud/interactions/icons/cosmetics_store"
					else
						marker.widget.content.field_improv_ammo_med = ""
					end
				else
					marker.widget.content.field_improv_ammo_med = ""
				end

				if marker.widget.style.field_improv_ammo_med and marker.widget.style.icon then
					marker.widget.style.field_improv_ammo_med.size[1] = marker.widget.style.icon.size[1]
					marker.widget.style.field_improv_ammo_med.size[2] = marker.widget.style.icon.size[2]

					marker.widget.style.field_improv_ammo_med.offset[1] = 35 * marker.scale
				end
			elseif
				pickup_type == "medical_crate_deployable"
				or marker.type == MarkerTemplate.name
				or marker.data and marker.data.type == "medical_crate_deployable"
			then
				if marker.widget.style.ring then
					mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs.med_crate_border_colour))
				end
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"

				if field_improv_active then
					if fs.display_field_improv_colour == true and marker.widget.style.ring then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if fs.display_field_improv_icon == true then
						marker.widget.content.field_improv =
							"content/ui/materials/hud/interactions/icons/cosmetics_store"
					else
						marker.widget.content.field_improv = ""
					end
				else
					marker.widget.content.field_improv = ""
				end

				if fs.display_med_charges == true then
					local is_crate = pickup_type == "medical_crate_deployable"
						or (marker.data and marker.data.type == "medical_crate_deployable")
						or marker.type == MarkerTemplate.name

					if is_crate then
						-- Advance client-side estimate for crates without a local ProximityHeal logic
						mod.update_med_crate_estimates(unit)

						if not marker.data then
							marker.data = {}
						end
						marker.data.type = "medical_crate_deployable"
					end

					local charges, is_estimate = mod.get_proximityheal_medcrate_charges(unit)

					if charges then
						if charges == math.huge then
							-- infinite
						else
							-- Show charges (healing left)
							local max_heal_reserve = medical_crate_config.optional_heal_reserve or 600
							local percentage = math.max(0, math.min(100, (charges / max_heal_reserve) * 100))
							local percentage_text = ""

							if not is_estimate then
								percentage_text = tostring(string.format("%.0f", percentage)) .. "%"
							elseif fs.display_med_crate_estimate == true then
								local range_low = math.floor(percentage / 20) * 20
								--percentage_text = "~" ..
								--tostring(range_low) .. "-" .. tostring(math.min(100, range_low + 20)) .. "%"
								percentage_text = "~" .. tostring(math.min(100, range_low + 20)) .. "%"
							end

						marker.widget.content.marker_text = percentage_text

						mod.set_colour_argb(
								marker.widget.style.icon.color,
								100,
								fs.med_crate_colour_R,
								fs.med_crate_colour_G,
								fs.med_crate_colour_B
							)
						end
					end
				end

				marker.draw = true
				marker.widget.alpha_multiplier = 1
			end

			apply_ammo_status_marker_visuals(marker)
		end
	end

	-- Periodic maintenance: drop dead bookkeeping and re-add our med_marker if it went missing
	mod._med_scan_counter = (mod._med_scan_counter or 0) + 1
	if mod._med_scan_counter >= 60 then
		mod._med_scan_counter = 0

		for unit, _ in pairs(med_crate_units) do
			if not Unit.alive(unit) then
				med_crate_units[unit] = nil
			end
		end

		for unit, _ in pairs(med_crate_estimates) do
			if not Unit.alive(unit) then
				med_crate_estimates[unit] = nil
			end
		end

		local markers_by_id = self and self._markers_by_id
		if markers_by_id then
			for unit, _ in pairs(med_crate_units) do
				if Unit.alive(unit) then
					local has_marker = false
					for _, marker in pairs(markers_by_id) do
						if marker.type == MarkerTemplate.name and marker.unit == unit then
							has_marker = true
							break
						end
					end
					if not has_marker then
						Managers.event:trigger("add_world_marker_unit", MarkerTemplate.name, unit)
					end
				end
			end
		end
	end
end

mod:hook(CLASS.HudElementWorldMarkers, "_create_widget", function(func, self, name, definition)
	fs = mod.frame_settings
	-- add new marker text widget to definitions
	local marker_text_style = table.clone(UIFontSettings.header_2)

	marker_text_style.horizontal_alignment = "center"
	marker_text_style.vertical_alignment = "center"
	marker_text_style.size = {
		520,
		64,
	}
	marker_text_style.word_wrap = false
	marker_text_style.color = Color.terminal_text_header(255, true)
	marker_text_style.font_size = 20
	marker_text_style.offset = {
		0,
		0,
		10,
	}
	marker_text_style.text_color = Color.terminal_text_header(255, true)
	marker_text_style.text_horizontal_alignment = "center"
	marker_text_style.text_vertical_alignment = "center"
	marker_text_style.drop_shadow = true

	marker_text_style.font_type = fs.font_type

	local marker_text_pass = {
		pass_type = "text",
		style_id = "marker_text_ammo_med",
		value = "",
		value_id = "marker_text_ammo_med",
		style = marker_text_style,
		visibility_function = function(content, style)
			return content.marker_text_ammo_med ~= nil
		end,
	}

	definition.passes[#definition.passes + 1] = table.clone(marker_text_pass)
	definition.style.marker_text_ammo_med = table.clone(marker_text_style)
	definition.content.marker_text_ammo_med = ""

	-- add new icon for Field Improv talent
	local icon_size = {
		48,
		48,
	}
	local field_improv_style = {
		horizontal_alignment = "left",
		vertical_alignment = "center",
		size = icon_size,
		offset = {
			50,
			0,
			0,
		},
		color = {
			255,
			255,
			255,
			255,
		},
	}

	local field_improv_pass = {
		pass_type = "texture",
		style_id = "field_improv_ammo_med",
		value = "",
		value_id = "field_improv_ammo_med",
		style = field_improv_style,
		visibility_function = function(content, style)
			return content.field_improv_ammo_med ~= ""
		end,
	}

	definition.passes[#definition.passes + 1] = table.clone(field_improv_pass)
	definition.style.field_improv_ammo_med = table.clone(field_improv_style)
	definition.content.field_improv_ammo_med = ""

	local ammo_status_circle_glow_style = {
		horizontal_alignment = "center",
		vertical_alignment = "center",
		size = {
			AMMO_STATUS_CIRCLE_SIZE[1],
			AMMO_STATUS_CIRCLE_SIZE[2],
		},
		default_size = {
			AMMO_STATUS_CIRCLE_SIZE[1],
			AMMO_STATUS_CIRCLE_SIZE[2],
		},
		offset = {
			0,
			0,
			11,
		},
		color = {
			0,
			255,
			255,
			255,
		},
	}

	local ammo_status_circle_glow_pass = {
		pass_type = "texture",
		style_id = "ammo_status_circle_glow",
		value = "content/ui/materials/frames/inner_shadow_thin",
		value_id = "ammo_status_circle_glow",
		style = ammo_status_circle_glow_style,
		visibility_function = function(content, style)
			return content.ammo_status_circle_visible == true
		end,
	}

	local ammo_status_circle_style = {
		horizontal_alignment = "center",
		vertical_alignment = "center",
		size = {
			AMMO_STATUS_CIRCLE_SIZE[1],
			AMMO_STATUS_CIRCLE_SIZE[2],
		},
		default_size = {
			AMMO_STATUS_CIRCLE_SIZE[1],
			AMMO_STATUS_CIRCLE_SIZE[2],
		},
		offset = {
			0,
			0,
			12,
		},
		color = {
			255,
			255,
			255,
			255,
		},
	}

	local ammo_status_circle_pass = {
		pass_type = "texture",
		style_id = "ammo_status_circle",
		value = "content/ui/materials/hud/interactions/frames/mission_back",
		value_id = "ammo_status_circle",
		style = ammo_status_circle_style,
		visibility_function = function(content, style)
			return content.ammo_status_circle_visible == true
		end,
	}

	local ammo_status_circle_shadow_style = {
		horizontal_alignment = "center",
		vertical_alignment = "center",
		size = {
			AMMO_STATUS_CIRCLE_SIZE[1] * 0.5,
			AMMO_STATUS_CIRCLE_SIZE[2] * 0.5,
		},
		default_size = {
			AMMO_STATUS_CIRCLE_SIZE[1] * 0.5,
			AMMO_STATUS_CIRCLE_SIZE[2] * 0.5,
		},
		offset = {
			0,
			0,
			13,
		},
		color = {
			120,
			0,
			0,
			0,
		},
	}

	local ammo_status_circle_shadow_pass = {
		pass_type = "texture",
		style_id = "ammo_status_circle_shadow",
		value = "content/ui/materials/gradients/gradient_circular",
		value_id = "ammo_status_circle_shadow",
		style = ammo_status_circle_shadow_style,
		visibility_function = function(content, style)
			return content.ammo_status_circle_visible == true
		end,
	}

	definition.passes[#definition.passes + 1] = table.clone(ammo_status_circle_glow_pass)
	definition.style.ammo_status_circle_glow = table.clone(ammo_status_circle_glow_style)
	definition.content.ammo_status_circle_glow =
		"content/ui/materials/frames/achievements/wintrack_claimed_reward_display_background_glow"

	definition.passes[#definition.passes + 1] = table.clone(ammo_status_circle_pass)
	definition.style.ammo_status_circle = table.clone(ammo_status_circle_style)
	definition.content.ammo_status_circle = "content/ui/materials/hud/interactions/frames/mission_back"
	definition.content.ammo_status_circle_visible = false

	definition.passes[#definition.passes + 1] = table.clone(ammo_status_circle_shadow_pass)
	definition.style.ammo_status_circle_shadow = table.clone(ammo_status_circle_shadow_style)
	definition.content.ammo_status_circle_shadow = "content/ui/materials/gradients/gradient_circular"

	-- add text pass for the "most needy teammate" class icon (text glyph, tinted with the teammate's colour)
	local needy_icon_style = table.clone(UIFontSettings.header_2)

	needy_icon_style.horizontal_alignment = "center"
	needy_icon_style.vertical_alignment = "center"
	needy_icon_style.size = {
		64,
		64,
	}
	needy_icon_style.color = Color.terminal_text_header(255, true)
	needy_icon_style.font_size = 40
	needy_icon_style.offset = {
		40,
		0,
		11,
	}
	needy_icon_style.text_color = Color.terminal_text_header(255, true)
	needy_icon_style.text_horizontal_alignment = "center"
	needy_icon_style.text_vertical_alignment = "center"
	needy_icon_style.drop_shadow = true

	local needy_icon_pass = {
		pass_type = "text",
		style_id = "ammo_needy_icon",
		value = "",
		value_id = "ammo_needy_icon",
		style = needy_icon_style,
		visibility_function = function(content, style)
			return content.ammo_needy_icon ~= nil and content.ammo_needy_icon ~= ""
		end,
	}

	definition.passes[#definition.passes + 1] = table.clone(needy_icon_pass)
	definition.style.ammo_needy_icon = table.clone(needy_icon_style)
	definition.content.ammo_needy_icon = ""

	-- ADD NEW MARKER DISTANCE TEXT
	-- add new marker text widget to definitions
	local marker_distance_text_style = table.clone(UIFontSettings.header_2)

	marker_distance_text_style.horizontal_alignment = "center"
	marker_distance_text_style.vertical_alignment = "center"
	marker_distance_text_style.size = {
		64,
		64,
	}
	marker_distance_text_style.color = Color.terminal_text_header(255, true)
	marker_distance_text_style.font_size = 16
	marker_distance_text_style.offset = {
		0,
		marker_distance_text_style.size[1] / 2,
		1,
	}
	marker_distance_text_style.text_color = Color.terminal_text_header(255, true)
	marker_distance_text_style.text_horizontal_alignment = "center"
	marker_distance_text_style.text_vertical_alignment = "center"
	marker_distance_text_style.drop_shadow = true

	marker_distance_text_style.font_type = fs.font_type

	local marker_distance_text_pass = {
		pass_type = "text",
		style_id = "marker_distance_text",
		value = "",
		value_id = "marker_distance_text",
		style = marker_distance_text_style,
		visibility_function = function(content, style)
			return content.marker_distance_text ~= nil
		end,
	}

	definition.passes[#definition.passes + 1] = table.clone(marker_distance_text_pass)
	definition.style.marker_distance_text = table.clone(marker_distance_text_style)
	definition.content.marker_distance_text = ""

	return func(self, name, definition)
end)

mod.get_proximityheal_medcrate_charges = function(unit)
	local proximity_extension = ScriptUnit.has_extension(unit, "proximity_system")
	if proximity_extension and proximity_extension._relation_data then
		for _, data in pairs(proximity_extension._relation_data) do
			if data.logic then
				for _, logic in pairs(data.logic) do
					if logic and logic._heal_reserve ~= nil and logic._amount_of_damage_healed ~= nil then
						if logic._heal_reserve then
							local remaining = logic._heal_reserve - logic._amount_of_damage_healed
							return math.max(0, remaining)
						else
							return math.huge
						end
					end
				end
			end
		end
	end

	local game_session = Managers.state.game_session and Managers.state.game_session:game_session()
	local game_object_id = Managers.state.unit_spawner and Managers.state.unit_spawner:game_object_id(unit)
	if game_session and game_object_id then
		if
			GameSession.has_game_object_field(game_session, game_object_id, "heal_reserve")
			and GameSession.has_game_object_field(game_session, game_object_id, "amount_of_damage_healed")
		then
			local heal_reserve = GameSession.game_object_field(game_session, game_object_id, "heal_reserve")
			local amount_healed = GameSession.game_object_field(game_session, game_object_id, "amount_of_damage_healed")
			if heal_reserve and amount_healed then
				return math.max(0, heal_reserve - amount_healed)
			end
			local charges = GameSession.game_object_field(game_session, game_object_id, "charges")
			if charges then
				return charges
			end
		end
	end

	local estimate_data = med_crate_estimates[unit]

	if estimate_data and estimate_data.amount_healed ~= nil then
		local max_heal_reserve = medical_crate_config.optional_heal_reserve or 600
		local remaining = math.max(0, max_heal_reserve - estimate_data.amount_healed)

		local heal_time = medical_crate_config.optional_heal_time
		local deployed_at = estimate_data.deployed_at

		if heal_time and deployed_at then
			local elapsed = math.max(0, Managers.time:time("gameplay") - deployed_at)
			local life_fraction = math.max(0, math.min(1, 1 - elapsed / heal_time))
			remaining = math.min(remaining, max_heal_reserve * life_fraction)
		end

		return remaining, true
	end

	return nil
end
