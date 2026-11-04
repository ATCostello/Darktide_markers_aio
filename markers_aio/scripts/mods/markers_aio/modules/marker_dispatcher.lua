local mod = get_mod("markers_aio")

local Dispatcher = {}
mod.marker_dispatcher = Dispatcher
Dispatcher.handlers = {}
Dispatcher.registered = false
Dispatcher._handler_map = {}

function Dispatcher.register(name, settings_key, callback, filter)
	Dispatcher.handlers[#Dispatcher.handlers + 1] = {
		name = name,
		settings_key = settings_key,
		callback = callback,
		filter = filter,
	}
end

function Dispatcher.initialize()
	if Dispatcher.registered then
		return
	end

	Dispatcher.registered = true

	Dispatcher.register("martyrs_skull", "martyrs_skull", function(self, marker, marker_type, dt, t)
		mod.update_martyrs_skull_markers(self, marker)
	end)

	Dispatcher.register("servo_skull", "servo_skull", function(self, marker, marker_type, dt, t)
		if marker_type ~= "objective" and marker_type ~= "player_assistance" then
			mod.update_servo_skull_markers(self, marker)
		end
	end)

	Dispatcher.register("player_assistance", "player_assistance", function(self, marker, marker_type, dt, t)
		if marker_type ~= "objective" and marker_type ~= "player_assistance" then
			mod.update_player_assistance_markers(self, marker)
		end
	end)

	Dispatcher.register("tainted_skull", "event", function(self, marker)
		mod.update_tainted_skull_markers(self, marker)
	end)

	Dispatcher.register("tainted_devices", "event", function(self, marker)
		mod.update_TaintedDevices_markers(self, marker)
	end)

	Dispatcher.register("stolen_rations", "event", function(self, marker)
		mod.update_stolenrations_markers(self, marker)
	end)

	Dispatcher.register("atonement", "event", function(self, marker)
		mod.update_atonement_markers(self, marker)
	end)

	Dispatcher.register("spillway_path", "spillway_path", function(self, marker)
		mod.update_spillway_path_markers(self, marker)
	end)

	Dispatcher._handler_map = {
		martyrs_skull = { "martyrs_skull" },
		servo_skull = { "servo_skull" },
		player_assistance = { "player_assistance" },
		event = { "tainted_skull", "tainted_devices", "stolen_rations", "atonement" },
		spillway_path = { "spillway_path" },
	}
end

function Dispatcher.dispatch(self, marker, marker_type, dt, t)
	local enable = mod.frame_settings.enable

	-- For markers aio markers, only call relevant handlers
	if marker_type == "martyrs_skull" then
		for _, handler_name in ipairs(Dispatcher._handler_map.martyrs_skull) do
			local handler = Dispatcher._find_handler_by_name(handler_name)
			if handler and enable[handler.settings_key] then
				handler.callback(self, marker, marker_type, dt, t)
			end
		end
	elseif marker_type == "servo_skull" then
		for _, handler_name in ipairs(Dispatcher._handler_map.servo_skull) do
			local handler = Dispatcher._find_handler_by_name(handler_name)
			if handler and enable[handler.settings_key] then
				handler.callback(self, marker, marker_type, dt, t)
			end
		end
	elseif marker_type == "player_assistance" then
		for _, handler_name in ipairs(Dispatcher._handler_map.player_assistance) do
			local handler = Dispatcher._find_handler_by_name(handler_name)
			if handler and enable[handler.settings_key] then
				handler.callback(self, marker, marker_type, dt, t)
			end
		end
	elseif marker_type == "event" or marker_type == "hub_objective" or marker_type == "objective" then
		for _, handler_name in ipairs(Dispatcher._handler_map.event) do
			local handler = Dispatcher._find_handler_by_name(handler_name)
			if handler and enable[handler.settings_key] then
				handler.callback(self, marker, marker_type, dt, t)
			end
		end
	elseif marker_type == "spillway_path" then
		for _, handler_name in ipairs(Dispatcher._handler_map.spillway_path) do
			local handler = Dispatcher._find_handler_by_name(handler_name)
			if handler and enable[handler.settings_key] then
				handler.callback(self, marker, marker_type, dt, t)
			end
		end
	else
		-- Fallback to general for unknown markers
		for i = 1, #Dispatcher.handlers do
			local handler = Dispatcher.handlers[i]

			if enable[handler.settings_key] then
				local filter = handler.filter

				if not filter or filter(self, marker, marker_type) then
					handler.callback(self, marker, marker_type, dt, t)
				end
			end
		end
	end
end

function Dispatcher._find_handler_by_name(name)
	for i = 1, #Dispatcher.handlers do
		if Dispatcher.handlers[i].name == name then
			return Dispatcher.handlers[i]
		end
	end
	return nil
end

return Dispatcher
