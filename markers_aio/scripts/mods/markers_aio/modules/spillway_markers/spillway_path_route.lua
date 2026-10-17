local mod = get_mod("markers_aio")

local fs = mod.frame_settings

local NavQueries = require("scripts/utilities/nav_queries")
local Navigation = require("scripts/extension_systems/navigation/utilities/navigation")

local RUN_CACHE = false

local FX_DASHED = "dashed"
local FX_ARROWS = "arrows"
local FX_DOTS = "dots"
local FX_SMOKE = "smoke"
local FX_FIRE = "fire"
local FX_ARC = "arc"
local FX_WARP = "warp"
local FX_BEACON = "beacon"
local FX_OFF = "off"

local SOLID_SUBDIVISIONS = 6
local DASH_GAP = 40
local DASH_SUBDIVISIONS = 24
local DOT_RADIUS = 0.45
local DOT_SPACING = 2.5
local ARROW_SPACING = 3
local ARROW_SIZE = 0.8
local ARROW_GAP = 10
local ARROW_SUBDIVISIONS = 4

local PARTICLE_FX = {
	[FX_SMOKE] = {
		path = "content/fx/particles/weapons/grenades/gas_grenade_gas",
		spacing = 3,
		refresh = 8,
		z = 0.2,
	},
	[FX_FIRE] = {
		path = "content/fx/particles/enemies/renegade_flamer/renegade_flamer_fire_lingering",
		spacing = 2.5,
		refresh = 5,
		z = 0.1,
	},
	[FX_ARC] = {
		path = "content/fx/particles/abilities/chainlightning_charge_loop",
		spacing = 4,
		refresh = 6,
		z = 0.6,
	},
	[FX_WARP] = {
		path = "content/fx/particles/abilities/psyker_venting",
		spacing = 3,
		refresh = 6,
		z = 0.3,
	},
	[FX_BEACON] = {
		path = "content/fx/particles/weapons/grenades/shock_mine/shock_mine_idle_01",
		spacing = 5,
		refresh = 6,
		z = 0.3,
	},
}

local ROUTE_Z_OFFSET = 0.5
local PACKAGE_REFERENCE = "markers_aio_spillway_route"
local PACKAGE_LOAD_TIMEOUT = 10
local MIN_POINT_SPACING = 0.5
local NAV_CHECK_ABOVE = 2
local NAV_CHECK_BELOW = 4
local NAV_WAIT_MAX = 20
local SPARSE_GRACE = 8
local ROUTE_MAX_ATTEMPTS = 6
local ROUTE_RETRY_DELAY = 1
local CACHE_KEY = "spillway_route_cache"
local CACHE_VERSION = 1
local CACHE_MAX_ENTRIES = 64
local CACHE_TOLERANCE = 10
local SEED_MODULE = "markers_aio/scripts/mods/markers_aio/modules/spillway_markers/spillway_route_seed"
local SEED_WRITE_PATH = "./../mods/markers_aio/scripts/mods/markers_aio/modules/spillway_markers/spillway_route_seed.lua"
local WAYPOINT_KEY = "spillway_route_waypoints"
local WAYPOINT_VERSION = 1
local WAYPOINT_SEED_MODULE = "markers_aio/scripts/mods/markers_aio/modules/spillway_markers/spillway_route_waypoints_seed"
local WAYPOINT_SEED_WRITE_PATH = "./../mods/markers_aio/scripts/mods/markers_aio/modules/spillway_markers/spillway_route_waypoints_seed.lua"
local DRIVE_NAV_ASYNC = true
local state

local function get_world()
	local player = mod.get_local_player()
	local unit = player and player.player_unit

	if unit and Unit.alive(unit) then
		return Unit.world(unit)
	end
end

local function requires_package(fx)
	return PARTICLE_FX[fx] ~= nil
end

local function package_path_for(fx)
	local config = PARTICLE_FX[fx]

	return config and config.path
end

local function get_route_rgba()
	local pt = fs.per_type and fs.per_type.spillway_path
	local r = math.max(0, math.min(255, pt and pt.colour_R or 161))
	local g = math.max(0, math.min(255, pt and pt.colour_G or 166))
	local b = math.max(0, math.min(255, pt and pt.colour_B or 169))
	local alpha = pt and pt.alpha or 1
	local a = math.max(0, math.min(255, math.floor(alpha * 255)))

	return r, g, b, a
end

local function get_route_color()
	local r, g, b, a = get_route_rgba()

	return Color(a, r, g, b)
end

local _fallback_traverse_logic
local _fallback_nav_tag_cost_table
local _fallback_nav_world

local function destroy_fallback_traverse_logic()
	if _fallback_traverse_logic then
		GwNavTraverseLogic.destroy(_fallback_traverse_logic)
		_fallback_traverse_logic = nil
	end

	if _fallback_nav_tag_cost_table then
		GwNavTagLayerCostTable.destroy(_fallback_nav_tag_cost_table)
		_fallback_nav_tag_cost_table = nil
	end

	_fallback_nav_world = nil
end

local function get_nav_context()
	local nav_mesh = Managers.state.nav_mesh

	if not nav_mesh then
		return
	end

	local nav_world = nav_mesh:nav_world()

	if not nav_world then
		return
	end

	local traverse_logic = nav_mesh.client_traverse_logic and nav_mesh:client_traverse_logic()

	if not traverse_logic then
		destroy_fallback_traverse_logic()

		_fallback_traverse_logic, _fallback_nav_tag_cost_table =
			Navigation.create_traverse_logic(nav_world, {}, nil, false)
		_fallback_nav_world = nav_world

		traverse_logic = _fallback_traverse_logic
	end

	if nav_world and traverse_logic then
		return nav_world, traverse_logic
	end
end

local function entry_position(entry)
	if entry.position_box then
		return entry.position_box:unbox()
	end

	return entry.position
end

local function destroy_line_object()
	if state and state.line_object and state.world and state.world == get_world() then
		pcall(function()
			LineObject.reset(state.line_object)
			LineObject.dispatch(state.world, state.line_object)
			World.destroy_line_object(state.world, state.line_object)
		end)
	end

	if state then
		state.line_object = nil
	end
end

local function destroy_units()
	if not (state and state.units) then
		return
	end

	local world = state.world

	if not (world and world == get_world()) then
		for i = #state.units, 1, -1 do
			state.units[i] = nil
		end

		return
	end

	for i = #state.units, 1, -1 do
		local unit = state.units[i]

		if unit and Unit.alive(unit) then
			World.destroy_unit(world, unit)
		end

		state.units[i] = nil
	end
end

local function destroy_particles()
	if not (state and state.particle_group) then
		return
	end

	local world = state.world

	if world and world == get_world() then
		pcall(World.destroy_particle_group, world, state.particle_group)
	end

	state.particle_group = nil

	if state.particles then
		table.clear(state.particles)
	end
end

local function destroy_state()
	if state then
		if state.astar then
			GwNavAStar.destroy(state.astar)
		end

		destroy_line_object()
		destroy_units()
		destroy_particles()

		if state.package_id then
			Managers.package:release(state.package_id)
		end
	end

	state = nil

	destroy_fallback_traverse_logic()
end

mod.reset_spillway_path_route = function()
	destroy_state()
end

local function get_mission_name()
	local mission = Managers.state.mission

	return mission and mission:mission_name() or "unknown"
end

local function vec_to_table(v)
	return {
		x = v.x,
		y = v.y,
		z = v.z,
	}
end

local function pos_matches(a, b)
	if not (a and b) or not a.x or not b.x then
		return false
	end

	return math.abs(a.x - b.x) <= CACHE_TOLERANCE
		and math.abs(a.y - b.y) <= CACHE_TOLERANCE
		and math.abs(a.z - b.z) <= CACHE_TOLERANCE * 2
end

local function cache_entries()
	local ok, cache = pcall(mod.get, mod, CACHE_KEY)

	if not ok or type(cache) ~= "table" or cache.version ~= CACHE_VERSION then
		return {}
	end

	return type(cache.entries) == "table" and cache.entries or {}
end

local _seed_entries

local function seed_entries()
	if _seed_entries == nil then
		local data = mod:io_dofile(SEED_MODULE)

		if type(data) == "table" and data.version == CACHE_VERSION and type(data.entries) == "table" then
			_seed_entries = data.entries
		else
			_seed_entries = {}
		end

		if #_seed_entries > 0 then
			mod:info("[spillway_route] loaded %d pre-calculated route(s) from the seed file", #_seed_entries)
		end
	end

	return _seed_entries
end

local function find_in(entries, from_table, to_table)
	for i = 1, #entries do
		local entry = entries[i]

		if
			entry
			and pos_matches(entry.from, from_table)
			and pos_matches(entry.to, to_table)
			and type(entry.points) == "table"
			and #entry.points >= 2
		then
			return entry
		end
	end

	return nil
end

local function cache_lookup(from_table, to_table)
	local seeded = find_in(seed_entries(), from_table, to_table)

	if seeded then
		return seeded
	end

	return find_in(cache_entries(), from_table, to_table)
end

local function cache_store(from_table, to_table, points, metadata)
	if not RUN_CACHE then
		return
	end

	local old = cache_entries()
	local entries = {}
	local mission = get_mission_name()

	for i = 1, #old do
		local entry = old[i]

		if
			not (
				entry
				and entry.mission == mission
				and pos_matches(entry.from, from_table)
				and pos_matches(entry.to, to_table)
			)
		then
			entries[#entries + 1] = entry
		end
	end

	local stored = {
		mission = mission,
		from = from_table,
		to = to_table,
		points = points,
	}

	if type(metadata) == "table" then
		if metadata.path_label then
			stored.path_label = metadata.path_label
		end
		if metadata.label then
			stored.label = metadata.label
		end
		if metadata.crossroad_id then
			stored.crossroad_id = metadata.crossroad_id
		end
		if metadata.road_id then
			stored.road_id = metadata.road_id
		end
		if metadata.from_order then
			stored.from_order = metadata.from_order
		end
		if metadata.to_order then
			stored.to_order = metadata.to_order
		end
		if metadata.route_index then
			stored.route_index = metadata.route_index
		end
	end

	entries[#entries + 1] = stored

	while #entries > CACHE_MAX_ENTRIES do
		table.remove(entries, 1)
	end

	pcall(mod.set, mod, CACHE_KEY, {
		version = CACHE_VERSION,
		entries = entries,
	})
end

local function merged_entries()
	local result = {}

	local function add(entries)
		for i = 1, #entries do
			local entry = entries[i]

			if entry and entry.from and entry.to and type(entry.points) == "table" and #entry.points >= 2 then
				local duplicate = false

				for j = 1, #result do
					if pos_matches(result[j].from, entry.from) and pos_matches(result[j].to, entry.to) then
						duplicate = true

						break
					end
				end

				if not duplicate then
					result[#result + 1] = entry
				end
			end
		end
	end

	add(seed_entries())
	add(cache_entries())

	return result
end

local _waypoint_seed_entries

local function waypoint_entries()
	local ok, data = pcall(mod.get, mod, WAYPOINT_KEY)

	if not ok or type(data) ~= "table" or data.version ~= WAYPOINT_VERSION then
		return {}
	end

	return type(data.entries) == "table" and data.entries or {}
end

local function waypoint_seed_entries()
	if _waypoint_seed_entries == nil then
		local data = mod:io_dofile(WAYPOINT_SEED_MODULE)

		if type(data) == "table" and data.version == WAYPOINT_VERSION and type(data.entries) == "table" then
			_waypoint_seed_entries = data.entries
		else
			_waypoint_seed_entries = {}
		end

		if #_waypoint_seed_entries > 0 then
			mod:info("[spillway_route] loaded %d mapped waypoint override(s) from the seed file", #_waypoint_seed_entries)
		end
	end

	return _waypoint_seed_entries
end

local function find_waypoint_entry(entries, from_table, to_table)
	for i = 1, #entries do
		local entry = entries[i]

		if entry and pos_matches(entry.from, from_table) and pos_matches(entry.to, to_table) then
			return entry, i
		end
	end

	return nil
end

local function save_waypoint_entries(entries)
	pcall(mod.set, mod, WAYPOINT_KEY, {
		version = WAYPOINT_VERSION,
		entries = entries,
	})
end

local function leg_waypoints(from_table, to_table)
	local entry = find_waypoint_entry(waypoint_seed_entries(), from_table, to_table)

	if not entry then
		entry = find_waypoint_entry(waypoint_entries(), from_table, to_table)
	end

	if entry and type(entry.points) == "table" and #entry.points > 0 then
		return entry.points
	end

	return nil
end

local function format_vec(v)
	return string.format("{ x = %.3f, y = %.3f, z = %.3f }", v.x, v.y, v.z)
end

local function format_points(points)
	local parts = {}

	for i = 1, #points do
		parts[#parts + 1] = format_vec(points[i])
	end

	return "{ " .. table.concat(parts, ", ") .. " }"
end

local function build_seed_source(entries, version)
	local lines = {
		"return {",
		"\tversion = " .. (version or CACHE_VERSION) .. ",",
		"\tentries = {",
	}

	for i = 1, #entries do
		local entry = entries[i]

		lines[#lines + 1] = "\t\t{"
		lines[#lines + 1] = "\t\t\tmission = " .. string.format("%q", entry.mission or "unknown") .. ","

		local label = entry.label or entry.path_label
		if not label then
			if entry.crossroad_id and entry.road_id then
				label = tostring(entry.crossroad_id) .. ":" .. tostring(entry.road_id)
			elseif entry.from_order and entry.to_order then
				label = tostring(entry.from_order) .. "->" .. tostring(entry.to_order)
			end
		end
		if label then
			lines[#lines + 1] = "\t\t\tlabel = " .. string.format("%q", label) .. ","
		end

		if entry.crossroad_id then
			lines[#lines + 1] = "\t\t\tcrossroad_id = " .. string.format("%q", entry.crossroad_id) .. ","
		end
		if entry.road_id ~= nil then
			lines[#lines + 1] = "\t\t\troad_id = " .. entry.road_id .. ","
		end
		if entry.from_order ~= nil then
			lines[#lines + 1] = "\t\t\tfrom_order = " .. entry.from_order .. ","
		end
		if entry.to_order ~= nil then
			lines[#lines + 1] = "\t\t\tto_order = " .. entry.to_order .. ","
		end

		lines[#lines + 1] = "\t\t\tfrom = " .. format_vec(entry.from) .. ","
		lines[#lines + 1] = "\t\t\tto = " .. format_vec(entry.to) .. ","
		lines[#lines + 1] = "\t\t\tpoints = " .. format_points(entry.points) .. ","
		lines[#lines + 1] = "\t\t},"
	end

	lines[#lines + 1] = "\t},"
	lines[#lines + 1] = "}"
	lines[#lines + 1] = ""

	return table.concat(lines, "\n")
end

mod.export_spillway_route_cache = function()
	if not RUN_CACHE then
		return
	end

	local entries = merged_entries()

	if #entries == 0 then
		mod:echo("No cached Spillway routes to export yet.")

		return
	end

	local source = build_seed_source(entries)
	local ok, err = pcall(function()
		local file = Mods.lua.io.open(SEED_WRITE_PATH, "w")

		if not file then
			error("could not open " .. SEED_WRITE_PATH)
		end

		file:write(source)
		file:close()
	end)

	if ok then
		mod:info("[spillway_route] exported %d route(s) to %s", #entries, SEED_WRITE_PATH)
		mod:echo(string.format("Exported %d Spillway route(s) to the mod's seed file.", #entries))
	else
		mod:info("[spillway_route] export failed (%s); dumping source below", tostring(err))
		mod:echo("Could not write the seed file; dumping route source to the log instead.")

		for line in string.gmatch(source, "[^\n]+") do
			mod:info("[spillway_route][seed] %s", line)
		end
	end
end

if RUN_CACHE then
	mod:command("spillway_route_export", "Export cached Spillway route paths so they can ship with the mod", function()
		mod.export_spillway_route_cache()
	end)
end

mod.clear_spillway_route_cache = function()
	if not RUN_CACHE then
		return
	end

	local cached_count = #cache_entries()
	local seeded_count = #seed_entries()

	pcall(mod.set, mod, CACHE_KEY, {
		version = CACHE_VERSION,
		entries = {},
	})

	_seed_entries = {}

	local file_ok = pcall(function()
		local file = Mods.lua.io.open(SEED_WRITE_PATH, "w")

		if not file then
			error("could not open " .. SEED_WRITE_PATH)
		end

		file:write(build_seed_source({}))
		file:close()
	end)

	mod.reset_spillway_path_route()

	mod:info("[spillway_route] cleared %d cached and %d seeded route(s)", cached_count, seeded_count)

	if file_ok then
		mod:echo(string.format("Cleared %d cached and %d seeded Spillway route(s).", cached_count, seeded_count))
	else
		mod:echo(
			string.format(
				"Cleared %d cached and %d seeded Spillway route(s). Could not reset the seed file (in-memory only).",
				cached_count,
				seeded_count
			)
		)
	end
end

if RUN_CACHE then
	mod:command("spillway_route_clear", "Clear all stored Spillway route paths and start fresh", function()
		mod.clear_spillway_route_cache()
	end)
end

local function get_player_position()
	local player = mod.get_local_player()
	local unit = player and player.player_unit

	if not (unit and Unit.alive(unit)) then
		return nil
	end

	local position = Unit.local_position(unit, 1)

	if not position then
		return nil
	end

	return Vector3(position.x, position.y, position.z)
end

local function distance_to_segment(point, a, b)
	local ab = b - a
	local ab_len_sq = Vector3.dot(ab, ab)

	if ab_len_sq <= 0.0001 then
		return Vector3.distance(point, a)
	end

	local t = Vector3.dot(point - a, ab) / ab_len_sq

	t = math.max(0, math.min(1, t))

	return Vector3.distance(point, a + ab * t)
end

local function select_leg(legs, point, arg1, arg2)
	local first = tonumber(arg1)
	local second = tonumber(arg2)

	local function leg_distance(leg)
		return distance_to_segment(point, entry_position(leg.from), entry_position(leg.to))
	end

	if first and second then
		for i = 1, #legs do
			local candidate = legs[i]

			if
				candidate
				and candidate.from
				and candidate.to
				and tonumber(candidate.from_order) == first
				and tonumber(candidate.to_order) == second
			then
				return candidate, i, leg_distance(candidate)
			end
		end
	end

	local leg = first and legs[first]

	if leg and leg.from and leg.to then
		return leg, first, leg_distance(leg)
	end

	local best, best_dist, best_index

	for i = 1, #legs do
		local candidate = legs[i]

		if candidate and candidate.from and candidate.to then
			local dist = leg_distance(candidate)

			if not best_dist or dist < best_dist then
				best, best_dist, best_index = candidate, dist, i
			end
		end
	end

	return best, best_index, best_dist
end

local function describe_leg(leg, leg_index)
	return string.format("leg %s (marker %s -> %s)", tostring(leg_index), tostring(leg.from_order), tostring(leg.to_order))
end

if RUN_CACHE then
	mod:command(
		"spillway_route_waypoint",
		"Pin a waypoint at your current position onto the nearest Spillway route leg (optional: leg index, or from/to marker orders)",
		function(arg1, arg2)
			local legs = mod.get_spillway_route_legs()

			if not legs or #legs == 0 then
				mod:echo("No Spillway route legs available right now.")

				return
			end

			local point = get_player_position()

			if not point then
				mod:echo("Player position is not available.")

				return
			end

			local leg, leg_index, dist = select_leg(legs, point, arg1, arg2)

			if not leg then
				mod:echo("Could not find a route leg to attach the waypoint to.")

				return
			end

			local from_key = vec_to_table(entry_position(leg.from))
			local to_key = vec_to_table(entry_position(leg.to))
			local entries = waypoint_entries()
			local entry = find_waypoint_entry(entries, from_key, to_key)

			if not entry then
				entry = {
					mission = get_mission_name(),
					from = from_key,
					to = to_key,
					points = {},
				}

				entries[#entries + 1] = entry
			end

			if type(entry.points) ~= "table" then
				entry.points = {}
			end

			entry.points[#entry.points + 1] = vec_to_table(point)
			save_waypoint_entries(entries)

			mod.reset_spillway_path_route()

			mod:info(
				"[spillway_route] waypoint #%d pinned to %s at (%.3f, %.3f, %.3f), %.1fm off the leg line",
				#entry.points,
				describe_leg(leg, leg_index),
				point.x,
				point.y,
				point.z,
				dist or 0
			)
			mod:echo(
				string.format(
					"Waypoint #%d pinned to %s, %.1fm off the line.",
					#entry.points,
					describe_leg(leg, leg_index),
					dist or 0
				)
			)
		end
	)

	mod:command(
		"spillway_route_waypoint_undo",
		"Remove the last pinned waypoint from the nearest Spillway route leg (optional: leg index, or from/to marker orders)",
		function(arg1, arg2)
			local legs = mod.get_spillway_route_legs()

			if not legs or #legs == 0 then
				mod:echo("No Spillway route legs available right now.")

				return
			end

			local point = get_player_position() or entry_position(legs[1].from)
			local leg, leg_index = select_leg(legs, point, arg1, arg2)

			if not leg then
				mod:echo("Could not find a route leg.")

				return
			end

			local from_key = vec_to_table(entry_position(leg.from))
			local to_key = vec_to_table(entry_position(leg.to))
			local entries = waypoint_entries()
			local entry, entry_index = find_waypoint_entry(entries, from_key, to_key)

			if not (entry and type(entry.points) == "table" and #entry.points > 0) then
				if find_waypoint_entry(waypoint_seed_entries(), from_key, to_key) then
					mod:echo("That leg's waypoints come from the seed file, not from this session.")
				else
					mod:echo("No saved waypoints on that leg.")
				end

				return
			end

			table.remove(entry.points)

			local remaining = #entry.points

			if remaining == 0 then
				table.remove(entries, entry_index)
			end

			save_waypoint_entries(entries)

			mod.reset_spillway_path_route()

			mod:echo(string.format("Removed last waypoint from %s. %d waypoint(s) remain.", describe_leg(leg, leg_index), remaining))
		end
	)

	mod:command(
		"spillway_route_waypoints_clear",
		"Remove every waypoint pinned this session (seed-file waypoints are kept)",
		function()
			local count = #waypoint_entries()

			save_waypoint_entries({})

			mod.reset_spillway_path_route()

			mod:echo(string.format("Cleared %d saved waypoint group(s). Seed-file waypoints are untouched.", count))
		end
	)

	mod:command("spillway_route_waypoints_list", "List every saved Spillway waypoint group", function()
		local entries = waypoint_entries()

		if #entries == 0 then
			mod:echo("No saved waypoint groups.")

			return
		end

		for i = 1, #entries do
			local entry = entries[i]
			local points = type(entry.points) == "table" and #entry.points or 0

			mod:echo(
				string.format(
					"[%d] %s: %s -> %s (%d waypoint(s))",
					i,
					tostring(entry.mission),
					format_vec(entry.from),
					format_vec(entry.to),
					points
				)
			)
		end
	end)

	mod:command("spillway_route_legs_list", "List the current Spillway route legs with their index, marker orders and pinned waypoint count", function()
		local legs = mod.get_spillway_route_legs()

		if not legs or #legs == 0 then
			mod:echo("No Spillway route legs available right now.")

			return
		end

		for i = 1, #legs do
			local leg = legs[i]
			local count = 0

			if leg and leg.from and leg.to then
				local waypoints = leg_waypoints(vec_to_table(entry_position(leg.from)), vec_to_table(entry_position(leg.to)))

				count = waypoints and #waypoints or 0
			end

			mod:echo(
				string.format(
					"leg %d: marker %s -> %s (%d waypoint(s))",
					i,
					tostring(leg and leg.from_order),
					tostring(leg and leg.to_order),
					count
				)
			)
		end
	end)
end

mod.export_spillway_route_waypoints = function()
	local entries = waypoint_entries()

	if #entries == 0 then
		mod:echo("No saved Spillway waypoints to export yet.")

		return
	end

	local source = build_seed_source(entries, WAYPOINT_VERSION)
	local ok, err = pcall(function()
		local file = Mods.lua.io.open(WAYPOINT_SEED_WRITE_PATH, "w")

		if not file then
			error("could not open " .. WAYPOINT_SEED_WRITE_PATH)
		end

		file:write(source)
		file:close()
	end)

	if ok then
		_waypoint_seed_entries = nil

		mod:info("[spillway_route] exported %d waypoint group(s) to %s", #entries, WAYPOINT_SEED_WRITE_PATH)
		mod:echo(string.format("Exported %d waypoint group(s) to the mod's waypoint seed file.", #entries))
	else
		mod:info("[spillway_route] waypoint export failed (%s); dumping source below", tostring(err))
		mod:echo("Could not write the waypoint seed file; dumping source to the log instead.")

		for line in string.gmatch(source, "[^\n]+") do
			mod:info("[spillway_route][waypoints] %s", line)
		end
	end
end

if RUN_CACHE then
	mod:command(
		"spillway_route_waypoints_export",
		"Write saved Spillway waypoints to the mod's waypoint seed file so they ship with the mod",
		function()
			mod.export_spillway_route_waypoints()
		end
	)

	mod:command(
		"spillway_route_save_current_to_waypoints",
		"Save currently cached/generated routes as waypoint overrides (and export them)",
		function()
			local cached = cache_entries()
			if #cached == 0 then
				mod:echo("No cached routes to save.")
				return
			end
			local entries = waypoint_entries()
			local added = 0
			for i = 1, #cached do
				local c = cached[i]
				if c and c.from and c.to and type(c.points) == "table" and #c.points > 0 then
					local exists = false
					for j = 1, #entries do
						if pos_matches(entries[j].from, c.from) and pos_matches(entries[j].to, c.to) then
							exists = true
							entries[j].points = c.points
							break
						end
					end
					if not exists then
						entries[#entries + 1] = {
							mission = c.mission or get_mission_name(),
							from = c.from,
							to = c.to,
							points = c.points,
							label = c.label,
							crossroad_id = c.crossroad_id,
							road_id = c.road_id,
							from_order = c.from_order,
							to_order = c.to_order,
						}
					end
					added = added + 1
				end
			end
			save_waypoint_entries(entries)
			mod.reset_spillway_path_route()
			mod:echo(string.format("Saved %d cached route(s) to session waypoints.", added))
			mod.export_spillway_route_waypoints()
		end
	)

	mod:command(
		"spillway_route_save_current_to_seed",
		"Overwrite route seed with currently cached/generated routes (clean)",
		function()
			local cached = cache_entries()
			if #cached == 0 then
				mod:echo("No cached routes to save.")
				return
			end
			local source = build_seed_source(cached)
			local ok, err = pcall(function()
				local file = Mods.lua.io.open(SEED_WRITE_PATH, "w")
				if not file then error("could not open " .. SEED_WRITE_PATH) end
				file:write(source)
				file:close()
			end)
			if ok then
				_seed_entries = nil
				mod:echo(string.format("Exported %d cached route(s) to route seed.", #cached))
			else
				mod:echo("Export failed: " .. tostring(err))
			end
		end
	)
end

local function boxes_from_points(points)
	local boxes = {}

	for i = 1, #points do
		local point = points[i]

		if point and point.x then
			boxes[#boxes + 1] = Vector3Box(Vector3(point.x, point.y, point.z))
		end
	end

	return boxes
end

local function points_from_boxes(boxes)
	local points = {}

	for i = 1, #boxes do
		points[i] = vec_to_table(boxes[i]:unbox())
	end

	return points
end

local function advance_route(points)
	state.route_points[state.route_index] = points or {}
	state.route_index = state.route_index + 1
	state.attempts = 0
	state.wait_t = 0
	state.cache_checked = false
	state.nav_wait_logged = false
	state.nav_wait_logged_out = false

	state.anchors = nil
	state.leg_points = nil
	state.sub_index = nil
	state.sub_count = nil
	state.sub_cache_checked = false
end

local function append_points(target, points)
	local last = target[#target] and target[#target]:unbox()

	for i = 1, #points do
		local box = points[i]
		local pos = box:unbox()

		if not last or Vector3.distance(last, pos) > MIN_POINT_SPACING then
			target[#target + 1] = box
			last = pos
		end
	end
end

local function leg_anchor_positions(leg)
	local from_pos = vec_to_table(entry_position(leg.from))
	local to_pos = vec_to_table(entry_position(leg.to))
	local anchors = { from_pos }
	local waypoints = leg_waypoints(from_pos, to_pos)
	local waypoint_count = 0

	if waypoints then
		for i = 1, #waypoints do
			local point = waypoints[i]

			if point and point.x then
				waypoint_count = waypoint_count + 1

				anchors[#anchors + 1] = {
					x = point.x,
					y = point.y,
					z = point.z,
				}
			end
		end
	end

	anchors[#anchors + 1] = to_pos

	if waypoint_count > 0 then
		local leg_label = leg.path_label or (leg.crossroad_id and leg.road_id and (tostring(leg.crossroad_id) .. ":" .. tostring(leg.road_id))) or string.format("marker %s -> %s", tostring(leg.from_order), tostring(leg.to_order))
		local from_str_pos = leg.from and entry_position(leg.from)
		local to_str_pos = leg.to and entry_position(leg.to)
		local from_str = from_str_pos and string.format("(%.3f,%.3f,%.3f)", from_str_pos.x, from_str_pos.y, from_str_pos.z) or "?"
		local to_str = to_str_pos and string.format("(%.3f,%.3f,%.3f)", to_str_pos.x, to_str_pos.y, to_str_pos.z) or "?"
		
		mod:info(
			"[spillway_route] leg %d (%s) %s -> %s using %d mapped waypoint(s)",
			state.route_index,
			leg_label,
			from_str,
			to_str,
			waypoint_count
		)
	end

	return anchors
end

local function begin_leg(leg)
	state.leg_points = {}
	state.anchors = leg_anchor_positions(leg)
	state.sub_count = #state.anchors - 1
	state.sub_index = 1
	state.sub_cache_checked = false

	state.query_from = state.anchors[1]
	state.query_to = state.anchors[#state.anchors]
end

local function reset_sub_wait()
	state.attempts = 0
	state.wait_t = 0
	state.nav_wait_logged = false
	state.nav_wait_logged_out = false
end

local function update_astar_stage(legs, dt)
	dt = dt or 0.016

	if state.astar then
		local nav_mesh = Managers.state.nav_mesh

		if DRIVE_NAV_ASYNC and nav_mesh and nav_mesh.kick_async_update then
			nav_mesh:kick_async_update(dt)
		end

		if not GwNavAStar.processing_finished(state.astar) then
			return
		end

		local points = {}
		local path_found = GwNavAStar.path_found(state.astar)

		if path_found then
			local count = GwNavAStar.node_count(state.astar)

			for i = 1, count do
				points[i] = Vector3Box(GwNavAStar.node_at_index(state.astar, i))
			end

		local leg = state.legs and state.legs[state.route_index]
		local leg_label = leg and (leg.path_label or (leg.crossroad_id and leg.road_id and (tostring(leg.crossroad_id) .. ":" .. tostring(leg.road_id))))
		if leg_label then
			mod:info(
				"[spillway_route] route %d sub-leg %d/%d (%s) finished: path_found=%s, nodes=%d",
				state.route_index,
				state.sub_index,
				state.sub_count,
				leg_label,
				tostring(path_found),
				#points
			)
		else
			mod:info(
				"[spillway_route] route %d sub-leg %d/%d finished: path_found=%s, nodes=%d",
				state.route_index,
				state.sub_index,
				state.sub_count,
				tostring(path_found),
				#points
			)
		end
		end

		GwNavAStar.destroy(state.astar)

		state.astar = nil

		if path_found then
			if #points >= 2 and state.query_from and state.query_to then
				local leg = state.legs and state.legs[state.route_index]
				local meta

				if leg then
					meta = {
						path_label = leg.path_label,
						crossroad_id = leg.crossroad_id,
						road_id = leg.road_id,
						from_order = leg.from_order,
						to_order = leg.to_order,
						route_index = state.route_index,
					}

					if not meta.path_label then
						if meta.crossroad_id and meta.road_id then
							meta.path_label = tostring(meta.crossroad_id) .. ":" .. tostring(meta.road_id)
						end
					end
				end

				if state.sub_count == 1 then
					cache_store(state.query_from, state.query_to, points_from_boxes(points), meta)
				end
			end

			append_points(state.leg_points, points)

			state.sub_index = state.sub_index + 1
			state.sub_cache_checked = false

			reset_sub_wait()

			return
		end

		state.attempts = state.attempts + 1

		if state.attempts >= ROUTE_MAX_ATTEMPTS then
			mod:info(
				"[spillway_route] route %d sub-leg %d: no path found after %d attempts, giving up on leg",
				state.route_index,
				state.sub_index,
				state.attempts
			)

			advance_route(nil)

			return
		end

		state.retry_delay = ROUTE_RETRY_DELAY

		mod:info(
			"[spillway_route] route %d sub-leg %d: no path found, retrying %d/%d in %.1fs",
			state.route_index,
			state.sub_index,
			state.attempts + 1,
			ROUTE_MAX_ATTEMPTS,
			ROUTE_RETRY_DELAY
		)

		return
	end

	if state.route_index > #legs then
		state.stage = requires_package(state.fx) and "package" or "render"

		return
	end

	if state.retry_delay > 0 then
		state.retry_delay = state.retry_delay - dt

		return
	end

	local leg = legs[state.route_index]

	if not (leg and leg.from and leg.to) then
		mod:info(
			"[spillway_route] skipping leg %d (from=%s, to=%s, legs=%d)",
			state.route_index,
			tostring(leg and leg.from ~= nil),
			tostring(leg and leg.to ~= nil),
			#legs
		)

		advance_route(nil)

		return
	end

	if not state.anchors then
		begin_leg(leg)
	end

	if state.sub_index > state.sub_count then
		if state.leg_points and #state.leg_points >= 2 and state.sub_count > 1 and state.anchors then
			local leg = state.legs and state.legs[state.route_index]
			local meta
			if leg then
				meta = {
					path_label = leg.path_label,
					crossroad_id = leg.crossroad_id,
					road_id = leg.road_id,
					from_order = leg.from_order,
					to_order = leg.to_order,
					route_index = state.route_index,
				}
				if not meta.path_label then
					if meta.crossroad_id and meta.road_id then
						meta.path_label = tostring(meta.crossroad_id) .. ":" .. tostring(meta.road_id)
					end
				end
			end
			cache_store(state.anchors[1], state.anchors[#state.anchors], points_from_boxes(state.leg_points), meta)
		end

		advance_route(state.leg_points)

		return
	end

	local from_key = state.anchors[state.sub_index]
	local to_key = state.anchors[state.sub_index + 1]
	local from_pos = Vector3(from_key.x, from_key.y, from_key.z)
	local to_pos = Vector3(to_key.x, to_key.y, to_key.z)

	if not state.sub_cache_checked then
		state.sub_cache_checked = true

		local cached = cache_lookup(from_key, to_key)

		if cached then
		local leg = state.legs and state.legs[state.route_index]
		local leg_label = leg and (leg.path_label or (leg.crossroad_id and leg.road_id and (tostring(leg.crossroad_id) .. ":" .. tostring(leg.road_id))))
		if leg_label then
			mod:info(
				"[spillway_route] route %d sub-leg %d/%d (%s) loaded from cache (%d points)",
				state.route_index,
				state.sub_index,
				state.sub_count,
				leg_label,
				#cached.points
			)
		else
			mod:info(
				"[spillway_route] route %d sub-leg %d/%d loaded from cache (%d points)",
				state.route_index,
				state.sub_index,
				state.sub_count,
				#cached.points
			)
		end

			append_points(state.leg_points, boxes_from_points(cached.points))

			state.sub_index = state.sub_index + 1
			state.sub_cache_checked = false

			return
		end
	end

	if not RUN_CACHE then
		mod:info("[spillway_route] route %d sub-leg %d: no seed/cache entry, skipping generation (RUN_CACHE off)", state.route_index, state.sub_index)
		advance_route(nil)

		return
	end

	local nav_world, traverse_logic = get_nav_context()

	if not nav_world or not traverse_logic then
		state.wait_t = state.wait_t + dt

		if not state.nav_wait_logged and state.wait_t > 1 then
			state.nav_wait_logged = true

			mod:info("[spillway_route] waiting for a nav world before route %d", state.route_index)
		end

		return
	end

	local from_mesh = NavQueries.position_on_mesh(nav_world, from_pos, NAV_CHECK_ABOVE, NAV_CHECK_BELOW, traverse_logic)
	local to_mesh = NavQueries.position_on_mesh(nav_world, to_pos, NAV_CHECK_ABOVE, NAV_CHECK_BELOW, traverse_logic)
	local meshes_ready = from_mesh ~= nil and to_mesh ~= nil

	local nav_mesh = Managers.state.nav_mesh
	local sparse_ok = not (nav_mesh and nav_mesh.is_sparse_graph_connected) or nav_mesh:is_sparse_graph_connected()

	local ready = meshes_ready and (sparse_ok or state.wait_t > SPARSE_GRACE)

	if not ready then
		state.wait_t = state.wait_t + dt

		if not state.nav_wait_logged and state.wait_t > 1 then
			state.nav_wait_logged = true

			mod:info(
				"[spillway_route] waiting for navmesh before route %d (from_on_mesh=%s, to_on_mesh=%s, sparse_graph=%s)",
				state.route_index,
				tostring(from_mesh ~= nil),
				tostring(to_mesh ~= nil),
				tostring(sparse_ok)
			)
		end

		if state.wait_t < NAV_WAIT_MAX then
			return
		end

		if not state.nav_wait_logged_out then
			state.nav_wait_logged_out = true

			mod:info("[spillway_route] navmesh still not ready after %ds, querying anyway", NAV_WAIT_MAX)
		end
	end

	local from = from_mesh
		or NavQueries.position_on_mesh_guaranteed(nav_world, from_pos, NAV_CHECK_ABOVE, NAV_CHECK_BELOW, traverse_logic)
		or from_pos
	local to = to_mesh
		or NavQueries.position_on_mesh_guaranteed(nav_world, to_pos, NAV_CHECK_ABOVE, NAV_CHECK_BELOW, traverse_logic)
		or to_pos
	local astar = GwNavAStar.create(nav_world)

	state.query_from = from_key
	state.query_to = to_key

	local leg_label = leg.path_label or (leg.crossroad_id and leg.road_id and (tostring(leg.crossroad_id) .. ":" .. tostring(leg.road_id))) or string.format("marker %s -> %s", tostring(leg.from_order), tostring(leg.to_order))
	local from_pos = leg.from and entry_position(leg.from)
	local to_pos = leg.to and entry_position(leg.to)
	local from_str = from_pos and string.format("(%.3f,%.3f,%.3f)", from_pos.x, from_pos.y, from_pos.z) or "?"
	local to_str = to_pos and string.format("(%.3f,%.3f,%.3f)", to_pos.x, to_pos.y, to_pos.z) or "?"

	mod:info(
		"[spillway_route] querying leg %d (%s) %s -> %s sub-leg %d/%d (attempt %d)",
		state.route_index,
		leg_label,
		from_str,
		to_str,
		state.sub_index,
		state.sub_count,
		state.attempts + 1
	)

	GwNavAStar.start(astar, nav_world, from, to, traverse_logic)

	state.astar = astar
end

local function update_package_stage(dt)
	local package_path = package_path_for(state.fx)

	if not package_path then
		state.stage = "render"

		return
	end

	if state.package_loaded then
		state.stage = "render"

		return
	end

	if state.package_requested then
		state.package_wait = (state.package_wait or 0) + (dt or 0)

		if state.package_wait >= PACKAGE_LOAD_TIMEOUT then
			mod:info("[spillway_route] timed out loading package '%s'", package_path)

			state.package_failed = true
		end
	end

	if state.package_failed then
		mod:info("[spillway_route] falling back to '%s' (package unavailable)", FX_DASHED)

		state.fx = FX_DASHED
		state.stage = "render"

		return
	end

	if state.package_requested then
		return
	end

	state.package_requested = true

	if Managers.package and Managers.package.has_loaded and Managers.package:has_loaded(package_path) then
		mod:info("[spillway_route] package '%s' is already loaded", package_path)

		state.package_loaded = true
		state.stage = "render"

		return
	end

	if not Application.can_get_resource("package", package_path) then
		state.package_failed = true

		mod:info("[spillway_route] '%s' is not available as a package", package_path)

		return
	end

	mod:info("[spillway_route] loading package '%s'", package_path)

	state.package_id = Managers.package:load(package_path, PACKAGE_REFERENCE, function()
		if state then
			state.package_loaded = true
		end
	end)
end

local function thin_points(points)
	local count = #points

	if count < 3 then
		return points
	end

	local thinned = { points[1] }
	local last = points[1]:unbox()

	for i = 2, count - 1 do
		local point = points[i]
		local position = point:unbox()

		if Vector3.distance(last, position) >= MIN_POINT_SPACING then
			thinned[#thinned + 1] = point
			last = position
		end
	end

	thinned[#thinned + 1] = points[count]

	return thinned
end

local function walk_points(points, spacing, callback)
	local count = #points

	if count < 2 then
		if count == 1 then
			callback(points[1]:unbox())
		end

		return
	end

	local prev = points[1]:unbox()

	callback(prev)

	for i = 2, count do
		local cur = points[i]:unbox()
		local diff = cur - prev
		local distance = Vector3.length(diff)

		if distance > 0.01 then
			local direction = diff / distance
			local travelled = spacing

			while travelled < distance do
				callback(prev + direction * travelled)

				travelled = travelled + spacing
			end
		end

		prev = cur
	end
end

local function ensure_line_object()
	local world = state.world

	if not world then
		return
	end

	if state.line_object and state.line_object_world ~= world then
		state.line_object = nil
	end

	if state.line_object then
		return
	end

	local ok, line_object = pcall(World.create_line_object, world)

	if ok and line_object then
		state.line_object = line_object
		state.line_object_world = world
	end
end

local function draw_line_route()
	ensure_line_object()

	local world = state.world
	local line_object = state.line_object

	if not (world and line_object) then
		return
	end

	local dashed = state.fx == FX_DASHED
	local color = get_route_color()

	pcall(function()
		LineObject.reset(line_object)

		for r = 1, #state.route_points do
			local points = state.route_points[r]

			if points then
				for i = 1, #points - 1 do
					local a = points[i]:unbox() + Vector3(0, 0, ROUTE_Z_OFFSET)
					local b = points[i + 1]:unbox() + Vector3(0, 0, ROUTE_Z_OFFSET)

					if dashed then
						LineObject.add_segmented_line(line_object, color, a, b, DASH_GAP, DASH_SUBDIVISIONS)
					else
						LineObject.add_segmented_line(line_object, color, a, b, 0, SOLID_SUBDIVISIONS)
					end
				end
			end
		end

		LineObject.dispatch(world, line_object)
	end)
end

local function draw_dot_route()
	ensure_line_object()

	local world = state.world
	local line_object = state.line_object

	if not (world and line_object) then
		return
	end

	local color = get_route_color()
	local up = Vector3.up()

	pcall(function()
		LineObject.reset(line_object)

		for r = 1, #state.route_points do
			local points = state.route_points[r]

			if points then
				walk_points(points, DOT_SPACING, function(position)
					LineObject.add_circle(
						line_object,
						color,
						position + Vector3(0, 0, ROUTE_Z_OFFSET),
						DOT_RADIUS,
						up,
						16
					)
				end)
			end
		end

		LineObject.dispatch(world, line_object)
	end)
end

local function draw_arrow_route()
	ensure_line_object()

	local world = state.world
	local line_object = state.line_object

	if not (world and line_object) then
		return
	end

	local color = get_route_color()
	local up = Vector3.up()

	pcall(function()
		LineObject.reset(line_object)

		for r = 1, #state.route_points do
			local points = state.route_points[r]

			if points then
				for i = 1, #points - 1 do
					local a = points[i]:unbox()
					local b = points[i + 1]:unbox()
					local diff = b - a
					local distance = Vector3.length(diff)

					if distance > 0.01 then
						local direction = diff / distance
						local perpendicular = Vector3.normalize(Vector3.cross(direction, up))
						local half = ARROW_SIZE * 0.5
						local travelled = ARROW_SPACING * 0.5

						while travelled < distance do
							local center = a + direction * travelled + Vector3(0, 0, ROUTE_Z_OFFSET)
							local tip = center + direction * half
							local back_left = center - direction * half + perpendicular * half
							local back_right = center - direction * half - perpendicular * half

							LineObject.add_segmented_line(
								line_object,
								color,
								back_left,
								tip,
								ARROW_GAP,
								ARROW_SUBDIVISIONS
							)
							LineObject.add_segmented_line(
								line_object,
								color,
								back_right,
								tip,
								ARROW_GAP,
								ARROW_SUBDIVISIONS
							)

							travelled = travelled + ARROW_SPACING
						end
					end
				end
			end
		end

		LineObject.dispatch(world, line_object)
	end)
end

local function ensure_particle_group(world)
	if state.particle_group then
		return state.particle_group
	end

	local ok, group = pcall(World.create_particle_group, world)

	if ok and group then
		state.particle_group = group
	end

	return state.particle_group
end

local function spawn_particle_route()
	local config = PARTICLE_FX[state.fx]
	local world = state.world

	if not (config and world) then
		return
	end

	destroy_particles()

	local group = ensure_particle_group(world)

	if not group then
		mod:info("[spillway_route] could not create a particle group for '%s'", state.fx)

		return
	end

	local spawned = 0

	for r = 1, #state.route_points do
		local points = state.route_points[r]

		if points then
			walk_points(points, config.spacing, function(position)
				local ok, id = pcall(
					World.create_particles,
					world,
					config.path,
					position + Vector3(0, 0, config.z),
					nil,
					nil,
					group
				)

				if ok and id then
					spawned = spawned + 1
				end
			end)
		end
	end

	state.particle_timer = 0

	if spawned > 0 then
		mod:info("[spillway_route] spawned %d '%s' effects", spawned, state.fx)

		state.stage = "done"

		return
	end

	state.particle_wait = (state.particle_wait or 0) + 1

	if state.particle_wait >= 5 then
		mod:info("[spillway_route] '%s' effects unavailable, falling back to '%s'", state.fx, FX_DASHED)

		state.fx = FX_DASHED
		state.stage = "render"
	end
end

local function update_render_stage(dt)
	state.world = state.world or get_world()

	if not state.world then
		return
	end

	local fx = state.fx

	if fx == FX_DASHED then
		draw_line_route()
	elseif fx == FX_ARROWS then
		draw_arrow_route()
	elseif fx == FX_DOTS then
		draw_dot_route()
	elseif PARTICLE_FX[fx] then
		spawn_particle_route()
	else
		state.stage = "done"
	end
end

local function update_done_stage(dt)
	local config = PARTICLE_FX[state.fx]

	if config then
		state.particle_timer = (state.particle_timer or 0) + (dt or 0)

		if state.particle_timer >= config.refresh then
			state.particle_timer = 0

			spawn_particle_route()
		end
	end
end

local function normalize_fx(fx)
	if
		fx == FX_DASHED
		or fx == FX_ARROWS
		or fx == FX_DOTS
		or fx == FX_SMOKE
		or fx == FX_FIRE
		or fx == FX_ARC
		or fx == FX_WARP
		or fx == FX_BEACON
		or fx == FX_OFF
	then
		return fx
	end

	return FX_DASHED
end

local function start_state(legs, fx)
	state = {
		world = get_world(),
		legs = legs,
		route_index = 1,
		route_points = {},
		units = {},
		particles = {},
		particle_group = nil,
		particle_timer = 0,
		particle_wait = 0,
		astar = nil,
		stage = "astar",
		requested_fx = fx,
		fx = fx,
		line_object = nil,
		line_object_world = nil,
		package_requested = false,
		package_wait = 0,
		package_loaded = false,
		package_failed = false,
		package_id = nil,
		attempts = 0,
		wait_t = 0,
		retry_delay = 0,
		cache_checked = false,
		nav_wait_logged = false,
		nav_wait_logged_out = false,
		query_from = nil,
		query_to = nil,
		anchors = nil,
		leg_points = nil,
		sub_index = nil,
		sub_count = nil,
		sub_cache_checked = false,
	}
end

mod.update_spillway_path_route = function(dt)
	mod.ensure_spillway_mission()

	local enable = fs.enable
	local fx = normalize_fx(fs.spillway_route_fx)

	if not (enable and enable.spillway_path and enable.spillway_path_route) then
		if state then
			mod.reset_spillway_path_route()
		end

		return
	end

	if fx == FX_OFF then
		if state then
			mod.reset_spillway_path_route()
		end

		return
	end

	if state and state.requested_fx ~= fx then
		mod.reset_spillway_path_route()
	end

	if not state then
		local legs = mod.get_spillway_route_legs()

		if not legs or #legs == 0 then
			return
		end

		local leg_summaries = {}
		for i = 1, math.min(#legs, 5) do
			local leg = legs[i]
			local lbl = leg and (leg.path_label or (leg.crossroad_id and leg.road_id and (tostring(leg.crossroad_id) .. ":" .. tostring(leg.road_id))) or string.format("%s->%s", tostring(leg.from_order), tostring(leg.to_order)))
			if lbl then
				leg_summaries[#leg_summaries + 1] = lbl
			end
		end
		local summary = #leg_summaries > 0 and table.concat(leg_summaries, ", ") or "n/a"
		mod:info("[spillway_route] starting route generation with %d path legs (fx=%s, legs=[%s])", #legs, fx, summary)

		start_state(legs, fx)
	end

	state.world = state.world or get_world()

	if state.stage == "astar" then
		update_astar_stage(state.legs, dt)
	elseif state.stage == "package" then
		update_package_stage(dt)
	elseif state.stage == "render" then
		update_render_stage(dt)
	elseif state.stage == "done" then
		update_done_stage(dt)
	end
end
