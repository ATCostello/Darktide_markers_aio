local mod = get_mod("markers_aio")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- FoundYa Compatibility (Adds relevant marker categories and uses FoundYa distances instead.)
local FoundYa = get_mod("FoundYa")

local get_max_distance = function()
	local max_distance = mod:get("stimm_max_distance")

	-- foundya Compatibility
	if FoundYa ~= nil then
		-- max_distance = FoundYa:get("max_distance_supply") or mod:get("stimm_max_distance") or 30
	end

	if max_distance == nil then
		max_distance = mod:get("stimm_max_distance") or 30
	end

	return max_distance
end

mod.update_stimm_markers = function(self, marker)
	if not (marker and self) then
		return
	end

	local pickup_type = mod.get_marker_pickup_type(marker)
	local data_type = marker.data and marker.data.type
	if not (
		pickup_type == "syringe_power_boost_pocketable"
		or pickup_type == "syringe_speed_boost_pocketable"
		or pickup_type == "syringe_ability_boost_pocketable"
		or pickup_type == "syringe_corruption_pocketable"
		or pickup_type == "syringe_broker_pocketable"
		or data_type == "syringe_power_boost_pocketable"
		or data_type == "syringe_speed_boost_pocketable"
		or data_type == "syringe_ability_boost_pocketable"
		or data_type == "syringe_corruption_pocketable"
	) then
		return
	end

	local max_distance = get_max_distance()
	marker.markers_aio_type = "stimm"

	-- init once
	if not marker._aio_stimm_inited then
		marker.widget.alpha_multiplier = 0
		marker.draw = false
		marker._aio_stimm_inited = true
		marker._aio_last_bg = nil
		marker._aio_last_ring = nil
		marker._aio_last_icon_color = nil
		marker._aio_last_max_distance = nil
		marker._aio_last_keep_on_screen = nil
	end

	-- keep on screen and background
	local keep_on = mod:get("stimm_keep_on_screen")
	if marker._aio_last_keep_on_screen ~= keep_on then
		marker.template.screen_clamp = keep_on
		marker.block_screen_clamp = false
		marker._aio_last_keep_on_screen = keep_on
	end
	local bg_colour_key = mod:get("marker_background_colour")
	if marker._aio_last_bg ~= bg_colour_key then
		marker.widget.style.background.color = mod.lookup_colour(bg_colour_key)
		marker._aio_last_bg = bg_colour_key
	end

	-- distances only when changed
	if marker._aio_last_max_distance ~= max_distance then
		local max_sq = max_distance * max_distance
		HUDElementInteractionSettings.max_spawn_distance_sq = max_sq
		self.max_distance = max_distance
		if self.fade_settings then
			self.fade_settings.distance_max = max_distance
			self.fade_settings.distance_min = max_distance - (self.evolve_distance or 0) * 2
		end
		marker.template.max_distance = max_distance
		marker.template.fade_settings.distance_max = max_distance
		marker.template.fade_settings.distance_min = marker.template.max_distance - (marker.template.evolve_distance or 0) * 2
		marker._aio_last_max_distance = max_distance
	end

	-- color selection
	local icon_color
	local ring_color
	if pickup_type == "syringe_power_boost_pocketable" or data_type == "syringe_power_boost_pocketable" then
		icon_color = {255, mod:get("power_stimm_icon_colour_R"), mod:get("power_stimm_icon_colour_G"), mod:get("power_stimm_icon_colour_B")}
		ring_color = mod.lookup_colour(mod:get("power_stimm_border_colour"))
	elseif pickup_type == "syringe_speed_boost_pocketable" or data_type == "syringe_speed_boost_pocketable" then
		icon_color = {255, mod:get("speed_stimm_icon_colour_R"), mod:get("speed_stimm_icon_colour_G"), mod:get("speed_stimm_icon_colour_B")}
		ring_color = mod.lookup_colour(mod:get("speed_stimm_border_colour"))
	elseif pickup_type == "syringe_ability_boost_pocketable" or data_type == "syringe_ability_boost_pocketable" then
		icon_color = {255, mod:get("boost_stimm_icon_colour_R"), mod:get("boost_stimm_icon_colour_G"), mod:get("boost_stimm_icon_colour_B")}
		ring_color = mod.lookup_colour(mod:get("boost_stimm_border_colour"))
	elseif pickup_type == "syringe_corruption_pocketable" or data_type == "syringe_corruption_pocketable" then
		icon_color = {255, mod:get("corruption_stimm_icon_colour_R"), mod:get("corruption_stimm_icon_colour_G"), mod:get("corruption_stimm_icon_colour_B")}
		ring_color = mod.lookup_colour(mod:get("corruption_stimm_border_colour"))
	elseif pickup_type == "syringe_broker_pocketable" or data_type == "syringe_broker_pocketable" then
		if mod:get("broker_stimm_enable") == true then
			icon_color = {255, mod:get("broker_stimm_icon_colour_R"), mod:get("broker_stimm_icon_colour_G"), mod:get("broker_stimm_icon_colour_B")}
			ring_color = mod.lookup_colour(mod:get("broker_stimm_border_colour"))
		end
	end

	-- apply only if changed
	if icon_color then
		local lc = marker._aio_last_icon_color
		if not lc or lc[2] ~= icon_color[2] or lc[3] ~= icon_color[3] or lc[4] ~= icon_color[4] then
			marker.widget.style.icon.color = icon_color
			marker._aio_last_icon_color = icon_color
		end
	end
	if ring_color and marker.widget.style.ring then
		if marker._aio_last_ring ~= ring_color then
			marker.widget.style.ring.color = ring_color
			marker._aio_last_ring = ring_color
		end
	end
end

-- update player weapon stimm icon colour
mod:hook_safe(CLASS.HudElementPlayerWeapon, "update", function(self, dt, t, ui_renderer)
	local weapon_name = self._weapon_name
	if not weapon_name then return end
	local widget = self._widgets_by_name and self._widgets_by_name.icon
	if not widget then return end

	local color
	if weapon_name == "content/items/pocketable/syringe_power_boost_pocketable" then
		color = {255, mod:get("power_stimm_icon_colour_R"), mod:get("power_stimm_icon_colour_G"), mod:get("power_stimm_icon_colour_B")}
	elseif weapon_name == "content/items/pocketable/syringe_speed_boost_pocketable" then
		color = {255, mod:get("speed_stimm_icon_colour_R"), mod:get("speed_stimm_icon_colour_G"), mod:get("speed_stimm_icon_colour_B")}
	elseif weapon_name == "content/items/pocketable/syringe_ability_boost_pocketable" then
		color = {255, mod:get("boost_stimm_icon_colour_R"), mod:get("boost_stimm_icon_colour_G"), mod:get("boost_stimm_icon_colour_B")}
	elseif weapon_name == "content/items/pocketable/syringe_corruption_pocketable" then
		color = {255, mod:get("corruption_stimm_icon_colour_R"), mod:get("corruption_stimm_icon_colour_G"), mod:get("corruption_stimm_icon_colour_B")}
	elseif weapon_name == "content/items/pocketable/syringe_broker_pocketable" then
		if mod:get("broker_stimm_enable") == true then
			color = {255, mod:get("broker_stimm_icon_colour_R"), mod:get("broker_stimm_icon_colour_G"), mod:get("broker_stimm_icon_colour_B")}
		end
	end
	if color then
		widget.style.icon.color = color
	end
end)

-- update team panel stimm icon colour
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")

mod:hook_safe(
	CLASS.HudElementTeamPanelHandler,
	"update",
	function(self, dt, t, ui_renderer, render_settings, input_service)
		local weapon_name = ""
		local players = Managers.player:players()
		local player_panels_array = self._player_panels_array

		for _, player in pairs(players) do
			local player_unit = player.player_unit
			if not ALIVE[player_unit] then goto continue_player end
			local visual_loadout_extension = ScriptUnit.extension(player_unit, "visual_loadout_system")
			local item = visual_loadout_extension and visual_loadout_extension:item_from_slot("slot_pocketable_small")
			if not item then goto continue_player end
			weapon_name = item.name
			if weapon_name == "" then goto continue_player end
			for _, panel_array in pairs(player_panels_array) do
				if panel_array.player._account_id == player._account_id then
					local stimm_widget = panel_array.panel._widgets_by_name.pocketable_small
					if stimm_widget then
						local color
						if weapon_name == "content/items/pocketable/syringe_power_boost_pocketable" then
							color = {255, mod:get("power_stimm_icon_colour_R"), mod:get("power_stimm_icon_colour_G"), mod:get("power_stimm_icon_colour_B")}
						elseif weapon_name == "content/items/pocketable/syringe_speed_boost_pocketable" then
							color = {255, mod:get("speed_stimm_icon_colour_R"), mod:get("speed_stimm_icon_colour_G"), mod:get("speed_stimm_icon_colour_B")}
						elseif weapon_name == "content/items/pocketable/syringe_ability_boost_pocketable" then
							color = {255, mod:get("boost_stimm_icon_colour_R"), mod:get("boost_stimm_icon_colour_G"), mod:get("boost_stimm_icon_colour_B")}
						elseif weapon_name == "content/items/pocketable/syringe_corruption_pocketable" then
							color = {255, mod:get("corruption_stimm_icon_colour_R"), mod:get("corruption_stimm_icon_colour_G"), mod:get("corruption_stimm_icon_colour_B")}
						elseif weapon_name == "content/items/pocketable/syringe_broker_pocketable" then
							if mod:get("broker_stimm_enable") == true then
								color = {255, mod:get("broker_stimm_icon_colour_R"), mod:get("broker_stimm_icon_colour_G"), mod:get("broker_stimm_icon_colour_B")}
							end
						end
						if color then stimm_widget.style.texture.color = color end
					end
					break
				end
			end
			::continue_player::
		end
	end
)
