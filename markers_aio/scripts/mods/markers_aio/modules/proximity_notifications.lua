local mod = get_mod("markers_aio")

local PROXIMITY_SCAN_INTERVAL = 0.25

local message_format
local NAME_COLOUR_PREFIX = "{#color(232,188,109)}"
local REST_COLOUR_PREFIX = "{#color(169,191,153)}"
local COLOUR_RESET = "{#reset()}"
local CHAT_EVENT = "system_chat_message"
local COMBAT_FEED_EVENT = "event_add_combat_feed_message"

local subtype_sets
local markers_inside = {}

local function get_subtype_sets()
	if subtype_sets then
		return subtype_sets
	end

	subtype_sets = {}

	for marker_type, subtypes in pairs(mod.proximity_subtypes or {}) do
		local set = {}

		for i = 1, #subtypes do
			set[subtypes[i]] = true
		end

		subtype_sets[marker_type] = set
	end

	return subtype_sets
end

local function marker_proximity_subtype(marker, marker_type)
	if not marker then
		return nil
	end

	local cached = rawget(marker, "aio_proximity_subtype")
	if cached ~= nil then
		return cached
	end

	local set = get_subtype_sets()[marker_type]
	if not set then
		return nil
	end

	local data = marker.data
	local pickup_type = mod.get_marker_pickup_type(marker)

	if not pickup_type then
		pickup_type = data and data.type
	end

	if not pickup_type then
		pickup_type = data and data.pickup_name
	end

	if not pickup_type and marker.pickup_type and set[marker.pickup_type] then
		pickup_type = marker.pickup_type
	end

	if pickup_type and set[pickup_type] then
		marker.aio_proximity_subtype = pickup_type
		return pickup_type
	end

	if marker_type == "ammo_med" then
		if
			data and data._active_interaction_type == "health_station"
			or mod.get_marker_extension(marker, "health_station_system")
		then
			marker.aio_proximity_subtype = "health_station"
			return "health_station"
		end
	end

	return nil
end

local function get_message_format()
	if message_format then
		return message_format
	end

	local fs = mod.frame_settings
	local format = fs.proximity_message_format

	if not format or format == "" or format == "proximity_message_default" then
		format = mod:localize("proximity_message_default")
	end

	if not format or format == "" or format == "proximity_message_default" then
		format = "{name} nearby"
	end

	message_format = format

	return message_format
end

local function fallback_name(marker_type, marker)
	local subtype = marker and rawget(marker, "aio_proximity_subtype")

	if subtype and marker_type then
		local key = mod.proximity_subtype_setting_id
			and mod.proximity_subtype_setting_id(marker_type, subtype)
			or ("proximity_" .. marker_type .. "_" .. subtype)
		local subtype_name = mod:localize(key)

		if subtype_name and subtype_name ~= key and string.sub(subtype_name, 1, 1) ~= "<" then
			return subtype_name
		end
	end

	local name = mod:localize("proximity_type_" .. marker_type)

	if not name or name == "" or string.sub(name, 1, 15) == "proximity_type_" or string.sub(name, 1, 1) == "<" then
		name = marker_type
	end

	return name
end

local function get_article(name)
	local first = string.sub(name or "", 1, 1):lower()

	if first == "" then
		return "a"
	end

	return string.find("aeiou", first, 1, true) and "an" or "a"
end

local function build_coloured_message(format, name)
	local article = get_article(name)

	format = string.gsub(format, "%{a/an%}", article)
	format = string.gsub(format, "a/an", article)

	local parts = {}
	local last = 1
	local from, to = string.find(format, "{name}", 1, true)

	while from do
		local text = string.sub(format, last, from - 1)

		if text ~= "" then
			parts[#parts + 1] = REST_COLOUR_PREFIX .. text .. COLOUR_RESET
		end

		parts[#parts + 1] = NAME_COLOUR_PREFIX .. name .. COLOUR_RESET
		last = to + 1
		from, to = string.find(format, "{name}", last, true)
	end

	local text = string.sub(format, last)

	if text ~= "" then
		parts[#parts + 1] = REST_COLOUR_PREFIX .. text .. COLOUR_RESET
	end

	return table.concat(parts)
end

local function send_proximity_message(name)
	local message = build_coloured_message(get_message_format(), name)
	local event_manager = Managers.event

	if not event_manager then
		return
	end

	local fs = mod.frame_settings
	local destination = fs and fs.proximity_message_destination

	if destination == "combat_feed" then
		event_manager:trigger(COMBAT_FEED_EVENT, message)
	else
		event_manager:trigger(CHAT_EVENT, message, "SYSTEM")
	end
end

mod.clear_proximity_name_cache = function()
	message_format = nil

	for marker in pairs(markers_inside) do
		marker._aio_proximity_inside = false
	end

	table.clear(markers_inside)
end

local function set_marker_inside(marker, inside)
	marker._aio_proximity_inside = inside

	if inside then
		markers_inside[marker] = true
	else
		markers_inside[marker] = nil
	end
end

mod.update_proximity_notifications = function(self, dt, t)
	local fs = mod.frame_settings

	if not fs.mod_enabled or not fs.proximity_enable then
		return
	end

	local next_scan = mod._proximity_next_scan or 0

	if t and t < next_scan then
		return
	end

	mod._proximity_next_scan = (t or 0) + PROXIMITY_SCAN_INTERVAL

	local enabled = fs.proximity_types
	local subtype_settings = fs.proximity_subtypes

	if not enabled then
		return
	end

	local player = mod.get_local_player()
	local player_unit = mod.get_player_unit(player)

	if not player_unit or not Unit.alive(player_unit) then
		return
	end

	local player_pos = Unit.world_position(player_unit, 1)

	if not player_pos then
		return
	end

	local range = fs.proximity_range or 15
	local range_sq = range * range
	local markers = self and self._markers

	if not markers then
		return
	end

	local entered = {}

	for i = 1, #markers do
		local marker = markers[i]
		local marker_type = marker and marker.markers_aio_type

		if marker_type then
			if enabled[marker_type] and not marker.aio_suppress then
				local subtype = marker_proximity_subtype(marker, marker_type)
				local subtype_map = subtype_settings and subtype_settings[marker_type]
				local subtype_enabled = not subtype_map or not subtype or subtype_map[subtype] ~= false

				if subtype_enabled then
					local position_box = marker.position
					local position = position_box

					if position_box and position_box.unbox then
						position = position_box:unbox()
					end

					if position then
						local dx = position.x - player_pos.x
						local dy = position.y - player_pos.y
						local dz = position.z - player_pos.z
						local distance_sq = dx * dx + dy * dy + dz * dz

						if distance_sq <= range_sq then
							if not marker._aio_proximity_inside then
								set_marker_inside(marker, true)
								local name

								if mod.get_marker_interaction_name then
									name = mod.get_marker_interaction_name(self, marker, player_unit)
								end

								if not name or name == "" then
									name = fallback_name(marker_type, marker)
								end

								if not entered[marker_type] then
									entered[marker_type] = name
								end
							end
						else
							set_marker_inside(marker, false)
						end
					end
				else
					set_marker_inside(marker, false)
				end
			else
				set_marker_inside(marker, false)
			end
		end
	end

	if next(entered) then
		for _, name in pairs(entered) do
			send_proximity_message(name)
		end
	end
end
