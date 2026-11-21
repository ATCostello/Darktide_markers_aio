local mod = get_mod("markers_aio")

local PROXIMITY_SCAN_INTERVAL = 0.25

local message_format
local NAME_COLOUR_PREFIX = "{#color(232,188,109)}"
local REST_COLOUR_PREFIX = "{#color(169,191,153)}"
local COLOUR_RESET = "{#reset()}"
local CHAT_EVENT = "system_chat_message"
local COMBAT_FEED_EVENT = "event_add_combat_feed_message"

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

local function fallback_name(marker_type)
	local name = mod:localize("proximity_type_" .. marker_type)

	if not name or name == "" or string.sub(name, 1, 15) == "proximity_type_" or string.sub(name, 1, 1) == "<" then
		name = marker_type
	end

	return name
end

local function build_coloured_message(format, name)
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

	if not enabled then
		return
	end

	local player = mod.get_local_player()
	local player_unit = player and player.player_unit

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
							marker._aio_proximity_inside = true
							local name

							if mod.get_marker_interaction_name then
								name = mod.get_marker_interaction_name(self, marker, player_unit)
							end

							if not name or name == "" then
								name = fallback_name(marker_type)
							end

							if not entered[marker_type] then
								entered[marker_type] = name
							end
						end
					else
						marker._aio_proximity_inside = false
					end
				end
			else
				marker._aio_proximity_inside = false
			end
		end
	end

	if next(entered) then
		for _, name in pairs(entered) do
			send_proximity_message(name)
		end
	end
end
