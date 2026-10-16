local mod = get_mod("markers_aio")

local fs = mod.frame_settings

local SPILLWAY_MARKER_TYPE = "spillway_path_marker"
local SPILLWAY_AIO_TYPE = "spillway_path"

local spillway_markers_placed = false
local tracked_main_path = nil

local function spillway_path_id(entry)
	local crossroads = entry and entry.crossroads

	if type(crossroads) == "string" and crossroads ~= "" then
		return crossroads
	end

	local crossroads_id = entry and entry.crossroads_id

	if type(crossroads_id) == "string" and crossroads_id ~= "" then
		return crossroads_id
	end

	return nil
end

local function is_crossroad_break(entry)
	return entry ~= nil and entry.marker_type == "crossroad_break"
end

mod.is_spillway_kept_marker = function(entry)
	return is_crossroad_break(entry) or spillway_path_id(entry) ~= nil
end

local function collect_spillway_paths(kept)
	local paths = {}
	local path = nil
	local path_id = nil

	local function close_path()
		if path and #path > 1 then
			paths[#paths + 1] = path
		end

		path = nil
		path_id = nil
	end

	for i = 1, #kept do
		local entry = kept[i]
		local entry_id = spillway_path_id(entry)

		if path then
			if is_crossroad_break(entry) and entry_id == nil then
				close_path()
			elseif path_id ~= nil and entry_id ~= path_id then
				close_path()
			end
		end

		if not path then
			path = {}
			path_id = nil
		end

		path[#path + 1] = entry

		if entry_id then
			path_id = entry_id
		end

		if is_crossroad_break(entry) and entry_id ~= nil then
			close_path()
		end
	end

	close_path()

	return paths
end

mod.reset_spillway_path_markers = function()
	spillway_markers_placed = false
	mod._spillway_setup_frame = nil
end

mod.ensure_spillway_mission = function()
	local main_path = Managers.state and Managers.state.main_path

	if main_path == tracked_main_path then
		return
	end

	tracked_main_path = main_path
	mod.reset_spillway_path_markers()

	if mod.reset_spillway_path_route then
		mod.reset_spillway_path_route()
	end
end

local function is_spillway_mission()
	local mission = Managers.state.mission
	local mission_name = mission and mission:mission_name()

	if mission_name and string.find(mission_name, "spillway", 1, true) then
		return true
	end

	local main_path = Managers.state.main_path
	local resource_name = main_path and main_path._main_path_resource_name

	return resource_name ~= nil and string.find(resource_name, "spillway", 1, true) ~= nil
end

local function is_road_available(main_path, crossroad_id, road_id)
	if crossroad_id == nil or road_id == nil then
		return false
	end

	if main_path.is_crossroad_segment_available then
		return main_path:is_crossroad_segment_available(crossroad_id, road_id)
	end

	local chosen_crossroads = main_path._chosen_crossroads
	local chosen = chosen_crossroads and chosen_crossroads[crossroad_id]

	return chosen ~= nil and tostring(chosen) == tostring(road_id)
end

local SPILLWAY_MARKER_ALLOWLIST = {
	A = {
		[1] = { 11, 12 },
		[2] = { 11, 17 },
	},
	B = {
		[1] = { 23, 24},
		[2] = { 23, 27 },
		[3] = { 23, 30 },
	},
}

local function get_active_path_markers()
	local main_path = Managers.state.main_path
	local path_markers = main_path and main_path._path_markers

	if not path_markers then
		return nil
	end

	local result = {}

	for i = 1, #path_markers do
		local path_marker = path_markers[i]
		local position = path_marker.position

		if position then
			local keep = true
			local crossroad_id = path_marker.crossroads_id
			local road_id = tonumber(path_marker.road_id)

			if crossroad_id == nil then
				local crossroads = path_marker.crossroads

				if type(crossroads) == "string" and crossroads ~= "" then
					local parsed_id, parsed_road = string.match(crossroads, "^(.-):(.*)$")
					crossroad_id = parsed_id
					road_id = tonumber(parsed_road)
				end
			end

			if crossroad_id ~= nil and not is_road_available(main_path, crossroad_id, road_id) then
				keep = false
			end

			if keep and is_spillway_mission() and crossroad_id ~= nil and road_id ~= nil then
				local allow = SPILLWAY_MARKER_ALLOWLIST[crossroad_id]
				local list = allow and allow[road_id]

				if list then
					local allowed = false
					local order = path_marker.order

					for j = 1, #list do
						if list[j] == order then
							allowed = true

							break
						end
					end

					if not allowed then
						keep = false
					end
				end
			end

			if keep then
				result[#result + 1] = {
					position = position.unbox and position:unbox() or position,
					position_box = position.unbox and position or nil,
					order = path_marker.order or i,
					marker_type = path_marker.marker_type,
					crossroads = path_marker.crossroads,
					crossroads_id = path_marker.crossroads_id,
				}
			end
		end
	end

	table.sort(result, function(a, b)
		return a.order < b.order
	end)

	return result
end

mod.get_spillway_path_markers = function()
	if not is_spillway_mission() then
		return nil
	end

	return get_active_path_markers()
end

local function collect_kept_markers(active_markers)
	local kept = {}

	if active_markers then
		for i = 1, #active_markers do
			local entry = active_markers[i]

			if mod.is_spillway_kept_marker(entry) then
				kept[#kept + 1] = entry
			end
		end
	end

	return kept
end

mod.get_spillway_route_legs = function()
	if not is_spillway_mission() then
		return nil
	end

	local paths = collect_spillway_paths(collect_kept_markers(get_active_path_markers()))
	local legs = {}

	for i = 1, #paths do
		local path = paths[i]

		for j = 1, #path - 1 do
			local from_entry = path[j]
			local to_entry = path[j + 1]

			legs[#legs + 1] = {
				from = from_entry,
				to = to_entry,
				from_order = from_entry.order,
				to_order = to_entry.order,
			}
		end
	end

	return legs
end

local function create_spillway_markers()
	if spillway_markers_placed or not is_spillway_mission() then
		return
	end

	local active_markers = get_active_path_markers()

	if not active_markers or #active_markers == 0 then
		return
	end

	spillway_markers_placed = true

	local kept = collect_kept_markers(active_markers)
	local paths = collect_spillway_paths(kept)
	local route_target_by_order = {}

	for i = 1, #paths do
		local path = paths[i]

		for j = 1, #path - 1 do
			route_target_by_order[path[j].order] = path[j + 1].order
		end
	end

	for i = 1, #kept do
		local entry = kept[i]

		Managers.event:trigger("add_world_marker_position", SPILLWAY_MARKER_TYPE, entry.position, nil, {
			spillway_order = entry.order,
			spillway_route_target = route_target_by_order[entry.order],
		})
	end
end

mod.update_spillway_path_markers = function(self, marker)
	mod.ensure_spillway_mission()

	local enabled = fs.enable and fs.enable.spillway_path
	local frame = mod._aio_frame

	if mod._spillway_setup_frame ~= frame then
		mod._spillway_setup_frame = frame

		if enabled then
			create_spillway_markers()
		end
	end

	if marker and marker.type == SPILLWAY_MARKER_TYPE then
		if not enabled then
			marker.aio_suppress = true
			return
		end

		local pt = fs.per_type and fs.per_type[SPILLWAY_AIO_TYPE]

		if pt then
			marker.template.max_distance = pt.max_distance
			marker.max_distance = pt.max_distance
			marker.template.screen_clamp = pt.keep_on_screen
			marker.block_screen_clamp = false

			if pt.require_line_of_sight ~= nil then
				marker.template.check_line_of_sight = pt.require_line_of_sight
			end
		end

		marker.aio_suppress = nil
		marker.markers_aio_type = SPILLWAY_AIO_TYPE

		local order = marker.data and marker.data.spillway_order

		if order and marker.widget and marker.widget.content then
			marker.widget.content.marker_text = tostring(order)
		end
	end
end
