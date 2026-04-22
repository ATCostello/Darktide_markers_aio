local mod = get_mod("markers_aio")
local MarkerTemplate = mod:io_dofile("markers_aio/scripts/mods/markers_aio/ammo_med_markers_template")

local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local check_recolorstimms = function()
	if mod:get("recolor_stimm_compat_enable") then
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
			-- works in live games
			mod:hook_safe(
				instance.medical_crate_deployable,
				"husk_init",
				function(unit, config, template_context, game_session, game_object_id, owner_id)
					mod.add_medkit_marker_and_proximity(nil, unit)
				end
			)

			-- works in private games
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

	load_package("content/levels/training_grounds/missions/mission_tg_basic_combat_01", "medkit_radius")
	load_package("packages/ui/views/options_view/options_view", "large_ammo1")
	load_package("packages/ui/views/inventory_background_view/inventory_background_view", "large_ammo2")

	check_recolorstimms()
end

mod:hook_safe(CLASS.UIViewHandler, "close_view", function(self, view_name, ...)
	if view_name == "dmf_options_view" or view_name == "options_view" then
		check_recolorstimms()
	end
end)

local get_max_distance = function()
	local max_distance = mod:get("ammo_med_max_distance")

	if max_distance == nil then
		max_distance = mod:get("ammo_med_max_distance")
	end

	return max_distance
end

mod.medical_crate_charges = {}

local med_crate_decals = mod:persistent_table("med_crate_decals")

local ProximityHeal = require("scripts/extension_systems/proximity/side_relation_gameplay_logic/proximity_heal")

ProximityHeal._cb_world_markers_list_request = function(self, world_markers)
	self._world_markers_list = world_markers
end

mod:hook_safe(ProximityHeal, "update", function(self, dt, t)
	if self and self._unit then
		local med_crate_pos = POSITION_LOOKUP[self._unit]

		if not table.contains(mod.medical_crate_charges, tostring(med_crate_pos)) then
			local percentage = ((self._heal_reserve - self._amount_of_damage_healed) / self._heal_reserve) * 100
			mod.medical_crate_charges[tostring(med_crate_pos)] = tostring(string.format("%.0f", percentage)) .. "%"
		end
	end
end)

mod.add_medkit_marker_and_proximity = function(self, unit)
	local marker_exists = false

	if self and self._world_markers_list and not table.is_empty(self._world_markers_list) then
		for _, marker in pairs(self._world_markers_list) do
			if marker.type == "med_marker" then
				if marker.unit == self._unit then
					marker_exists = true
				end
			end
		end
	end

	if not marker_exists then
		Managers.event:trigger("add_world_marker_unit", MarkerTemplate.name, unit)
	end

	-- add proximity circle to medkits, thanks Raindish! (From NumericUI)
	if mod:get("display_med_ring") == true and unit then
		local package_path = "content/levels/training_grounds/missions/mission_tg_basic_combat_01"

		if not Managers.package:has_loaded(package_path) then
			Managers.package:load(package_path, "ammo_med_markers")
			return
		end

		local decal_unit_name = "content/levels/training_grounds/fx/decal_aoe_indicator"
		local medical_crate_config = require("scripts/settings/deployables/templates/medical_crate")

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
					local diameter = medical_crate_config.proximity_radius * 2 + 1.5
					Unit.set_local_scale(decal_unit, 1, Vector3(diameter, diameter, 1))

					-- Set color of unit
					local material_value = Quaternion.identity()

					local field_improv_active = mod.check_players_talents_for_Field_Improvisation()

					if field_improv_active and mod:get("display_field_improv_colour") == true then
						local r = mod:get("field_improv_colour_R") / 255
						local g = mod:get("field_improv_colour_G") / 255
						local b = mod:get("field_improv_colour_B") / 255
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
	alive_players = Managers.state.player_unit_spawn:alive_players()

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

pickup_types = {}
local function add_to_list_if_not_present(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return false -- Already present, do not add
		end
	end
	table.insert(list, value)
	return true -- Added successfully
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

		local pickup_type = mod.get_marker_pickup_type(marker)

		if pickup_type then
			add_to_list_if_not_present(pickup_types, pickup_type)
		end

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
		then
			marker.markers_aio_type = "ammo_med"

			-- force hide marker to start, to prevent "pop in" where the marker will briefly appear at max opacity
			marker.widget.alpha_multiplier = 0
			marker.draw = false

			mod.set_colour_argb(marker.widget.style.icon.color, 255, 255, 255, 255)

			mod.set_colour(marker.widget.style.background.color, mod.lookup_colour(mod:get("marker_background_colour")))

			marker.template.screen_clamp = mod:get("ammo_med_keep_on_screen")
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

			if marker.data and marker.data._active_interaction_type == "health_station" then
				local health_station_extension = ScriptUnit.fetch_component_extension(unit, "health_station_system")

				local remaining_charges = health_station_extension._charge_amount

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

				if mod:get("display_med_charges") == true then
					marker.widget.content.marker_text_ammo_med = tostring(remaining_charges)
				end

				if mod:get("change_colour_for_ammo_charges") == true then
					if remaining_charges == 4 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 0, 150, 0)
					elseif remaining_charges == 3 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 150, 150, 0)
					elseif remaining_charges == 2 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 150, 100, 0)
					elseif remaining_charges == 1 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 150, 0, 0)
					end
				end

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					100,
					mod:get("med_crate_colour_R"),
					mod:get("med_crate_colour_G"),
					mod:get("med_crate_colour_B")
				)

				if marker.position then
					local current_position = marker.position:unbox()
					local movement = Vector3(5, 5, 5)
					local new_position = current_position + movement
					marker.position:store(new_position)
				end
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

				if mod:get("display_ammo_charges") == true then
					if marker.widget.content.marker_text_ammo_med then
						marker.widget.content.marker_text_ammo_med = tostring(remaining_charges)
					end
				end

				if mod:get("change_colour_for_ammo_charges") == true then
					if remaining_charges == 4 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 0, 150, 0)
					elseif remaining_charges == 3 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 150, 150, 0)
					elseif remaining_charges == 2 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 150, 100, 0)
					elseif remaining_charges == 1 then
						mod.set_colour_argb(marker.widget.style.background.color, 255, 150, 0, 0)
					end
				end

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					100,
					mod:get("ammo_crate_colour_R"),
					mod:get("ammo_crate_colour_G"),
					mod:get("ammo_crate_colour_B")
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
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(mod:get("ammo_small_border_colour")))
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					mod:get("ammo_small_colour_R"),
					mod:get("ammo_small_colour_G"),
					mod:get("ammo_small_colour_B")
				)
			elseif pickup_type == "large_clip" or marker.data and marker.data.type == "large_clip" then
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(mod:get("ammo_large_border_colour")))
				if mod:get("ammo_med_markers_alternate_large_ammo_icon") == true then
					marker.widget.content.icon = "content/ui/materials/icons/presets/preset_16"
				else
					marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/ammunition"
				end

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					mod:get("ammo_large_colour_R"),
					mod:get("ammo_large_colour_G"),
					mod:get("ammo_large_colour_B")
				)
			elseif pickup_type == "small_grenade" or marker.data and marker.data.type == "small_grenade" then
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(mod:get("grenade_border_colour")))
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/grenade"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					mod:get("grenade_colour_R"),
					mod:get("grenade_colour_G"),
					mod:get("grenade_colour_B")
				)
			elseif
				pickup_type == "ammo_cache_pocketable"
				or marker.data and marker.data.type == "ammo_cache_pocketable"
			then
				mod.set_colour(marker.widget.style.ring.color, mod.lookup_colour(mod:get("ammo_crate_border_colour")))
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					mod:get("ammo_crate_colour_R"),
					mod:get("ammo_crate_colour_G"),
					mod:get("ammo_crate_colour_B")
				)
				if field_improv_active then
					if mod:get("display_field_improv_colour") == true then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if mod:get("display_field_improv_icon") == true then
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
					mod.set_colour(
						marker.widget.style.ring.color,
						mod.lookup_colour(mod:get("ammo_crate_border_colour"))
					)
				end
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_ammo"

				if field_improv_active then
					if mod:get("display_field_improv_colour") == true and marker.widget.style.ring then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if mod:get("display_field_improv_icon") == true then
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
					mod.set_colour(
						marker.widget.style.ring.color,
						mod.lookup_colour(mod:get("med_crate_border_colour"))
					)
				end
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"

				mod.set_colour_argb(
					marker.widget.style.icon.color,
					255,
					mod:get("med_crate_colour_R"),
					mod:get("med_crate_colour_G"),
					mod:get("med_crate_colour_B")
				)
				if field_improv_active then
					if mod:get("display_field_improv_colour") == true and marker.widget.style.ring then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if mod:get("display_field_improv_icon") == true then
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
					mod.set_colour(
						marker.widget.style.ring.color,
						mod.lookup_colour(mod:get("med_crate_border_colour"))
					)
				end
				marker.widget.content.icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit"

				if field_improv_active then
					if mod:get("display_field_improv_colour") == true and marker.widget.style.ring then
						mod.set_colour(marker.widget.style.ring.color, Color.citadel_wild_rider_red(nil, true))
					end
					if mod:get("display_field_improv_icon") == true then
						marker.widget.content.field_improv =
							"content/ui/materials/hud/interactions/icons/cosmetics_store"
					else
						marker.widget.content.field_improv = ""
					end
				else
					marker.widget.content.field_improv = ""
				end

				if mod:get("display_med_charges") == true then
					local charges = mod.get_proximityheal_medcrate_charges(unit)

					if charges then
						if charges == math.huge then
						-- infinite
						else
							-- Show charges (healing left)
							local percentage = (charges / 500) * 100

							marker.widget.content.marker_text = tostring(string.format("%.0f", percentage)) .. "%"

							if not marker.data then
								marker.data = {}
							end
							marker.data.type = "medical_crate_deployable"

							mod.set_colour_argb(
								marker.widget.style.icon.color,
								100,
								mod:get("med_crate_colour_R"),
								mod:get("med_crate_colour_G"),
								mod:get("med_crate_colour_B")
							)
						end
					end
				end
			end
		end
	end
end

mod:hook(CLASS.HudElementWorldMarkers, "_create_widget", function(func, self, name, definition)
	-- add new marker text widget to definitions
	local marker_text_style = table.clone(UIFontSettings.header_2)

	marker_text_style.horizontal_alignment = "center"
	marker_text_style.vertical_alignment = "center"
	marker_text_style.size = {
		64,
		64,
	}
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

	marker_text_style.font_type = mod:get("font_type")

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

	marker_distance_text_style.font_type = mod:get("font_type")

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
	-- Try extension first
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

	-- Fallback: Try to get from networked fields
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
			-- Or, if there's a "charges" field:
			local charges = GameSession.game_object_field(game_session, game_object_id, "charges")
			if charges then
				return charges
			end
		end
	end

	return nil
end
