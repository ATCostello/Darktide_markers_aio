local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

local fs = mod.frame_settings

local get_max_distance = function()
	local max_distance = fs.stimm_max_distance

	if max_distance == nil then
		max_distance = fs.stimm_max_distance
	end

	return max_distance
end

local set_stimm_colours = function(marker, stimm_name, border_setting, r_setting, g_setting, b_setting)
	local widget_icon_or_background = marker.widget.style.icon.color

	-- if toggle background colour, then set the background as is
	if fs.toggle_background_colour then
		if mod.RecolorStimms then
			local argb = mod.RecolorStimms.get_stimm_argb_255(stimm_name)
			mod.set_colour_argb(marker.widget.style.background.color, argb[1], argb[2], argb[3], argb[4])
		else
			mod.set_colour_argb(marker.widget.style.background.color, 255, fs[r_setting], fs[g_setting], fs[b_setting])
		end
	end

	-- if toggle background colour, then set icon to be the inverse...
	if fs.toggle_background_colour then
		mod.set_colour(marker.widget.style.icon.color, mod.lookup_colour(fs.marker_background_colour))
	else
		if mod.RecolorStimms then
			local argb = mod.RecolorStimms.get_stimm_argb_255(stimm_name)
			mod.set_colour_argb(marker.widget.style.icon.color, argb[1], argb[2], argb[3], argb[4])
		else
			mod.set_colour_argb(marker.widget.style.icon.color, 255, fs[r_setting], fs[g_setting], fs[b_setting])
		end
	end

	mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(fs[border_setting]))
end

local stimm_types = {
	syringe_power_boost_pocketable = true,
	syringe_speed_boost_pocketable = true,
	syringe_ability_boost_pocketable = true,
	syringe_corruption_pocketable = true,
	syringe_broker_pocketable = true,
}

mod.update_stimm_markers = function(self, marker)
	if not fs.mod_enabled then
		return
	end

	if marker and self then
		local unit = marker.unit

		local pickup_type = mod.get_marker_pickup_type(marker)
		local data_type = marker.data and marker.data.type

		if (pickup_type and stimm_types[pickup_type]) or (data_type and stimm_types[data_type]) then
			local max_distance = get_max_distance()

			marker.markers_aio_type = "stimm"
			marker.widget.alpha_multiplier = 0
			marker.draw = false

			marker.template.screen_clamp = fs.stimm_keep_on_screen
			marker.block_screen_clamp = false

			-- marker.widget.content.is_clamped = false

			local max_spawn_distance_sq = max_distance * max_distance
			HUDElementInteractionSettings.max_spawn_distance_sq = max_spawn_distance_sq

			if self.fade_settings then
				self.fade_settings.distance_max = max_distance
				self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
			end

			marker.template.max_distance = max_distance
			marker.template.fade_settings.distance_max = max_distance
			marker.template.fade_settings.distance_min = max_distance - marker.template.evolve_distance * 2

			self.max_distance = max_distance
			marker.max_distance = max_distance

			if self.fade_settings then
				self.fade_settings.distance_max = max_distance
				self.fade_settings.distance_min = max_distance - self.evolve_distance * 2
			end

			mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(fs.marker_background_colour))

			if pickup_type == "syringe_power_boost_pocketable" or data_type == "syringe_power_boost_pocketable" then
				marker.aio_check_line_of_sight = fs.power_stimm_require_line_of_sight
				set_stimm_colours(
					marker,
					pickup_type,
					"power_stimm_border_colour",
					"power_stimm_icon_colour_R",
					"power_stimm_icon_colour_G",
					"power_stimm_icon_colour_B"
				)
			elseif pickup_type == "syringe_speed_boost_pocketable" or data_type == "syringe_speed_boost_pocketable" then
				marker.aio_check_line_of_sight = fs.speed_stimm_require_line_of_sight
				set_stimm_colours(
					marker,
					pickup_type,
					"speed_stimm_border_colour",
					"speed_stimm_icon_colour_R",
					"speed_stimm_icon_colour_G",
					"speed_stimm_icon_colour_B"
				)
			elseif
				pickup_type == "syringe_ability_boost_pocketable" or data_type == "syringe_ability_boost_pocketable"
			then
				marker.aio_check_line_of_sight = fs.boost_stimm_require_line_of_sight
				set_stimm_colours(
					marker,
					pickup_type,
					"boost_stimm_border_colour",
					"boost_stimm_icon_colour_R",
					"boost_stimm_icon_colour_G",
					"boost_stimm_icon_colour_B"
				)
			elseif pickup_type == "syringe_corruption_pocketable" or data_type == "syringe_corruption_pocketable" then
				marker.aio_check_line_of_sight = fs.corruption_stimm_require_line_of_sight
				set_stimm_colours(
					marker,
					pickup_type,
					"corruption_stimm_border_colour",
					"corruption_stimm_icon_colour_R",
					"corruption_stimm_icon_colour_G",
					"corruption_stimm_icon_colour_B"
				)
			elseif pickup_type == "syringe_broker_pocketable" or data_type == "syringe_broker_pocketable" then
				if fs.broker_stimm_enable == true then
					marker.aio_check_line_of_sight = fs.broker_stimm_require_line_of_sight
					set_stimm_colours(
						marker,
						pickup_type,
						"broker_stimm_border_colour",
						"broker_stimm_icon_colour_R",
						"broker_stimm_icon_colour_G",
						"broker_stimm_icon_colour_B"
					)
				end
			end
		end
	end
end

-- update player weapon stimm icon colour
local STIMM_ITEM_COLOURS = {
	["content/items/pocketable/syringe_power_boost_pocketable"] = {
		pickup_name = "syringe_power_boost_pocketable",
		r = "power_stimm_icon_colour_R",
		g = "power_stimm_icon_colour_G",
		b = "power_stimm_icon_colour_B",
	},
	["content/items/pocketable/syringe_speed_boost_pocketable"] = {
		pickup_name = "syringe_speed_boost_pocketable",
		r = "speed_stimm_icon_colour_R",
		g = "speed_stimm_icon_colour_G",
		b = "speed_stimm_icon_colour_B",
	},
	["content/items/pocketable/syringe_ability_boost_pocketable"] = {
		pickup_name = "syringe_ability_boost_pocketable",
		r = "boost_stimm_icon_colour_R",
		g = "boost_stimm_icon_colour_G",
		b = "boost_stimm_icon_colour_B",
	},
	["content/items/pocketable/syringe_corruption_pocketable"] = {
		pickup_name = "syringe_corruption_pocketable",
		r = "corruption_stimm_icon_colour_R",
		g = "corruption_stimm_icon_colour_G",
		b = "corruption_stimm_icon_colour_B",
	},
	["content/items/pocketable/syringe_broker_pocketable"] = {
		pickup_name = "syringe_broker_pocketable",
		r = "broker_stimm_icon_colour_R",
		g = "broker_stimm_icon_colour_G",
		b = "broker_stimm_icon_colour_B",
		broker_only = true,
	},
}

local stimm_argb_cache = {}

local function get_stimm_argb(weapon_name)
	local entry = STIMM_ITEM_COLOURS[weapon_name]

	if not entry then
		return nil
	end

	if entry.broker_only and fs.broker_stimm_enable ~= true then
		return nil
	end

	local version = mod._settings_version
	local cached = stimm_argb_cache[weapon_name]

	if cached and cached.version == version then
		return cached[1], cached[2], cached[3], cached[4]
	end

	local a, r, g, b

	if mod.RecolorStimms then
		local argb = mod.RecolorStimms.get_stimm_argb_255(entry.pickup_name)

		if argb then
			a, r, g, b = argb[1], argb[2], argb[3], argb[4]
		end
	else
		a, r, g, b = 255, fs[entry.r], fs[entry.g], fs[entry.b]
	end

	if not a then
		return nil
	end

	if not cached then
		cached = { 0, 0, 0, 0 }
		stimm_argb_cache[weapon_name] = cached
	end

	cached[1], cached[2], cached[3], cached[4] = a, r, g, b
	cached.version = version

	return a, r, g, b
end

mod:hook_safe(CLASS.HudElementPlayerWeapon, "update", function(self, dt, t, ui_renderer)
	local widgets_by_name = self._widgets_by_name
	local widget = widgets_by_name and widgets_by_name.icon

	if not widget or not widget.style or not widget.style.icon then
		return
	end

	local a, r, g, b = get_stimm_argb(self._weapon_name)

	if a then
		mod.set_colour_argb(widget.style.icon.color, a, r, g, b)
	end
end)

-- update team panel stimm icon colour
local panel_by_account = {}

mod:hook_safe(
	CLASS.HudElementTeamPanelHandler,
	"update",
	function(self, dt, t, ui_renderer, render_settings, input_service)
		local players = Managers.player:players()
		local player_panels_array = self._player_panels_array

		if not players or not player_panels_array then
			return
		end

		table.clear(panel_by_account)

		for i = 1, #player_panels_array do
			local panel_array = player_panels_array[i]
			local player = panel_array and panel_array.player
			local account_id = mod.player_is_usable(player) and rawget(player, "_account_id") or nil
			local panel = panel_array and panel_array.panel

			if account_id and panel then
				panel_by_account[account_id] = panel
			end
		end

		for _, player in pairs(players) do
			local player_unit = mod.get_player_unit(player)
			local account_id = mod.player_is_usable(player) and rawget(player, "_account_id") or nil

			if player_unit and account_id and Unit.alive(player_unit) then
				local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
				local item = visual_loadout_extension
					and visual_loadout_extension:item_from_slot("slot_pocketable_small")

				if item and item.name then
					local panel = panel_by_account[account_id]
					local widgets_by_name = panel and panel._widgets_by_name
					local stimm_widget = widgets_by_name and widgets_by_name.pocketable_small

					if stimm_widget and stimm_widget.style and stimm_widget.style.texture then
						local a, r, g, b = get_stimm_argb(item.name)

						if a then
							mod.set_colour_argb(stimm_widget.style.texture.color, a, r, g, b)
						end
					end
				end
			end
		end
	end
)
