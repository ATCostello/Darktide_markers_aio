local mod = get_mod("markers_aio")
local HudElementWorldMarkers = require("scripts/ui/hud/elements/world_markers/hud_element_world_markers")
local Pickups = require("scripts/settings/pickup/pickups")
local HUDElementInteractionSettings = require("scripts/ui/hud/elements/interaction/hud_element_interaction_settings")
local WorldMarkerTemplateInteraction =
	require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local UIWidget = require("scripts/managers/ui/ui_widget")

local expedition_pickup_types = {
	-- grenades/call-ins
	"expedition_grenade_airstrike_pocketable",
	"expedition_grenade_artillery_strike_pocketable",
	"expedition_grenade_big_pocketable",
	"expedition_grenade_valkyrie_hover_pocketable",
	"expedition_deployable_force_field_pocketable",

	-- loot crates
	"expedition_loot_crate_tier_1",
	"expedition_loot_crate_tier_2",
	"expedition_loot_crate_tier_3",

	-- TECH REMNANTS
	"expedition_loot_small_tier_1",
	"expedition_loot_small_tier_2",
	"expedition_loot_small_tier_3",
	"expedition_loot_player_drop",

	-- RELIQUARIES
	"expedition_loot_heavy_tier_1",
	"expedition_loot_heavy_tier_2",
	"expedition_loot_heavy_tier_3",

	-- SALVAGE
	"expedition_currency_small_tier_1",
	"expedition_currency_small_tier_2",

	-- SYRINGES
	"expedition_effective_sprinting",
	"expedition_max_toughness",
	"expedition_time_syringe_timed",

	-- keys
	"expedition_common_key",
	"expedition_deadsider_key",
	"expedition_dataslate_key",
}

mod.update_expedition_markers = function(self, marker)
	if marker and self then
		local unit = marker.unit

		local pickup_type = mod.get_marker_pickup_type(marker)

		-- filter out unwanted
		local pickup_found = false
		for i = 1, #expedition_pickup_types do
			if pickup_type == expedition_pickup_types[i] then
				pickup_found = true
			end
		end

		if not pickup_found then
			return
		end

		marker.pickup_type = pickup_type

		marker.draw = false
		marker.widget.alpha_multiplier = 0

		marker.markers_aio_type = "expedition"

		marker.widget.style.background.color = mod.lookup_colour(mod:get("marker_background_colour"))

		marker.template.check_line_of_sight = mod:get(marker.markers_aio_type .. "_require_line_of_sight")

		marker.template.max_distance = mod:get(marker.markers_aio_type .. "_max_distance")
		marker.max_distance = max_distance
		self.max_distance = max_distance

		marker.template.screen_clamp = mod:get(marker.markers_aio_type .. "_keep_on_screen")
		marker.block_screen_clamp = false

		-- set options based on grouping
		if
			pickup_type == "expedition_grenade_airstrike_pocketable"
			or pickup_type == "expedition_grenade_artillery_strike_pocketable"
			or pickup_type == "expedition_grenade_big_pocketable"
			or pickup_type == "expedition_grenade_valkyrie_hover_pocketable"
			or pickup_type == "expedition_deployable_force_field_pocketable"
		then
			-- PICKUPS/CALL INS
			marker.widget.style.icon.color = {
				255,
				mod:get("expedition_pickups_colour_R"),
				mod:get("expedition_pickups_colour_G"),
				mod:get("expedition_pickups_colour_B"),
			}
		elseif
			pickup_type == "expedition_currency_small_tier_1" or pickup_type == "expedition_currency_small_tier_2"
		then
			-- CURRENCY
			marker.widget.style.icon.color = {
				255,
				mod:get("expedition_currency_colour_R"),
				mod:get("expedition_currency_colour_G"),
				mod:get("expedition_currency_colour_B"),
			}
		elseif
			pickup_type == "expedition_loot_heavy_tier_1"
			or pickup_type == "expedition_loot_heavy_tier_2"
			or pickup_type == "expedition_loot_heavy_tier_3"
		then
			-- HEAVY RELIQUARIES
			marker.widget.style.icon.color = {
				255,
				mod:get("expedition_reliquary_colour_R"),
				mod:get("expedition_reliquary_colour_G"),
				mod:get("expedition_reliquary_colour_B"),
			}
			marker.widget.content.icon = mod:get("luggable_icon")
		elseif
			pickup_type == "expedition_loot_small_tier_1"
			or pickup_type == "expedition_loot_small_tier_2"
			or pickup_type == "expedition_loot_small_tier_3"
			or pickup_type == "expedition_loot_player_drop"
		then
			-- TECH REMNANTS
			marker.widget.style.icon.color = {
				255,
				mod:get("expedition_remnants_colour_R"),
				mod:get("expedition_remnants_colour_G"),
				mod:get("expedition_remnants_colour_B"),
			}
		elseif
			pickup_type == "expedition_loot_crate_tier_1"
			or pickup_type == "expedition_loot_crate_tier_2"
			or pickup_type == "expedition_loot_crate_tier_3"
		then
			-- LOOT CRATES
			marker.widget.style.icon.color = {
				255,
				mod:get("expedition_crate_colour_R"),
				mod:get("expedition_crate_colour_G"),
				mod:get("expedition_crate_colour_B"),
			}
			marker.widget.content.icon = mod:get("chest_icon")
		else
			marker.widget.style.icon.color = {
				255,
				mod:get("expedition_colour_R"),
				mod:get("expedition_colour_G"),
				mod:get("expedition_colour_B"),
			}
		end

		-- set border based on tier
		if string.find(pickup_type, "tier_1") then
			marker.widget.style.ring.color = mod.lookup_colour(mod:get("expedition_border_colour_1"))
		elseif string.find(pickup_type, "tier_2") then
			marker.widget.style.ring.color = mod.lookup_colour(mod:get("expedition_border_colour_2"))
		elseif string.find(pickup_type, "tier_3") then
			marker.widget.style.ring.color = mod.lookup_colour(mod:get("expedition_border_colour_3"))
		else
			marker.widget.style.ring.color = mod.lookup_colour(mod:get("expedition_border_colour"))
		end
	end
end
