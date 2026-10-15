local mod = get_mod("markers_aio")

local fs = mod.frame_settings

local SPILLWAY_MARKER_TYPE = "spillway_path_marker"
local SPILLWAY_AIO_TYPE = "spillway_path"

local SPILLWAY_KEEP_MARKERS = { 11, 12, 19, 20 }

local spillway_markers_placed = false

local function is_route_marker(index)
	local routes = mod.spillway_routes

	if routes then
		for i = 1, #routes do
			local route = routes[i]

			for j = 1, #route do
				if route[j] == index then
					return true
				end
			end
		end
	end

	return false
end

local function should_keep_marker(index)
	if is_route_marker(index) then
		return true
	end

	if #SPILLWAY_KEEP_MARKERS == 0 then
		return true
	end

	for i = 1, #SPILLWAY_KEEP_MARKERS do
		if SPILLWAY_KEEP_MARKERS[i] == index then
			return true
		end
	end

	return false
end

mod.reset_spillway_path_markers = function()
	spillway_markers_placed = false
	mod._spillway_setup_frame = nil
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

local function get_active_path_markers()
	local main_path = Managers.state.main_path
	local path_markers = main_path and main_path._path_markers

	if not path_markers then
		return nil
	end

	local chosen_crossroads = main_path._chosen_crossroads
	local result = {}

	for i = 1, #path_markers do
		local path_marker = path_markers[i]
		local position = path_marker.position

		if position then
			local keep = true
			local crossroads = path_marker.crossroads

			if crossroads and crossroads ~= "" and chosen_crossroads then
				local crossroad_id, road_id = string.match(crossroads, "^(.-):(.*)$")

				if crossroad_id and road_id and chosen_crossroads[crossroad_id] ~= nil then
					if tostring(chosen_crossroads[crossroad_id]) ~= road_id then
						keep = false
					end
				end
			end

			if keep then
				result[#result + 1] = {
					position = position.unbox and position:unbox() or position,
					position_box = position.unbox and position or nil,
					order = path_marker.order or i,
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

local function create_spillway_markers()
	if spillway_markers_placed or not is_spillway_mission() then
		return
	end

	local active_markers = get_active_path_markers()

	if not active_markers or #active_markers == 0 then
		return
	end

	spillway_markers_placed = true

	local route_target_by_order
	local routes = mod.spillway_routes

	if routes then
		route_target_by_order = {}

		for i = 1, #routes do
			local route = routes[i]

			for j = 1, #route - 1 do
				route_target_by_order[route[j]] = route[j + 1]
			end
		end
	end

	for i = 1, #active_markers do
		if should_keep_marker(i) then
			local entry = active_markers[i]

			Managers.event:trigger("add_world_marker_position", SPILLWAY_MARKER_TYPE, entry.position, nil, {
				spillway_order = i,
				spillway_route_target = route_target_by_order and route_target_by_order[i],
			})
		end
	end
end

mod.update_spillway_path_markers = function(self, marker)
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
