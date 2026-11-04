local mod = get_mod("markers_aio")

local Dispatcher = {}
mod.marker_dispatcher = Dispatcher

Dispatcher.handlers = {}
Dispatcher.registered = false

Dispatcher._routes = {}
Dispatcher._handler_map = {}
Dispatcher._handlers_by_name = {}
Dispatcher._fallback_handlers = {}
Dispatcher._compiled = false

function Dispatcher.register(name, settings_key, callback, filter)
	Dispatcher.handlers[#Dispatcher.handlers + 1] = {
		name = name,
		settings_key = settings_key,
		callback = callback,
		filter = filter,
	}

	Dispatcher._compiled = false
end

function Dispatcher._compile()
	local handlers = Dispatcher.handlers
	local handlers_by_name = {}
	local fallback = {}

	for i = 1, #handlers do
		local handler = handlers[i]

		if handlers_by_name[handler.name] == nil then
			handlers_by_name[handler.name] = handler
		end

		fallback[#fallback + 1] = handler
	end

	local handler_map = Dispatcher._handler_map
	local routes = {}

	local function build_route(names)
		local result = {}

		for i = 1, #names do
			local handler = handlers_by_name[names[i]]

			if handler then
				result[#result + 1] = handler
			end
		end

		return result
	end

	routes.martyrs_skull = build_route(handler_map.martyrs_skull)
	routes.servo_skull = build_route(handler_map.servo_skull)
	routes.player_assistance = build_route(handler_map.player_assistance)
	routes.event = build_route(handler_map.event)
	routes.spillway_path = build_route(handler_map.spillway_path)

	routes.hub_objective = routes.event
	routes.objective = routes.event

	Dispatcher._handlers_by_name = handlers_by_name
	Dispatcher._fallback_handlers = fallback
	Dispatcher._routes = routes
	Dispatcher._compiled = true
end

function Dispatcher.initialize()
	if Dispatcher.registered then
		return
	end

	Dispatcher.registered = true

	Dispatcher.register("martyrs_skull", "martyrs_skull", function(self, marker)
		mod.update_martyrs_skull_markers(self, marker)
	end)

	Dispatcher.register("servo_skull", "servo_skull", function(self, marker, marker_type)
		if marker_type ~= "objective" and marker_type ~= "player_assistance" then
			mod.update_servo_skull_markers(self, marker)
		end
	end)

	Dispatcher.register("player_assistance", "player_assistance", function(self, marker, marker_type)
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
		martyrs_skull = {
			"martyrs_skull",
		},

		servo_skull = {
			"servo_skull",
		},

		player_assistance = {
			"player_assistance",
		},

		event = {
			"tainted_skull",
			"tainted_devices",
			"stolen_rations",
			"atonement",
		},

		spillway_path = {
			"spillway_path",
		},
	}

	Dispatcher._compile()
end

-- Main per-marker dispatch function.
function Dispatcher.dispatch(self, marker, marker_type, dt, t)
	local enable = mod.frame_settings.enable

	-- Direct route lookup instead of repeated name searches.
	local handlers = Dispatcher._routes[marker_type]

	if handlers then
		for i = 1, #handlers do
			local handler = handlers[i]

			if enable[handler.settings_key] then
				handler.callback(self, marker, marker_type, dt, t)
			end
		end

		return
	end

	-- Fallback for marker types without a dedicated route.
	handlers = Dispatcher._fallback_handlers

	for i = 1, #handlers do
		local handler = handlers[i]

		if enable[handler.settings_key] then
			local filter = handler.filter

			if not filter or filter(self, marker, marker_type) then
				handler.callback(self, marker, marker_type, dt, t)
			end
		end
	end
end

function Dispatcher._find_handler_by_name(name)
	return Dispatcher._handlers_by_name[name]
end

return Dispatcher
