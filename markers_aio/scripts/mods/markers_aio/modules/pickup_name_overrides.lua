local mod = get_mod("markers_aio")

local fs = mod.frame_settings
local class_table = rawget(_G, "CLASS")
local custom_name_by_key = {}
local base_localize
local reset_button_hook_installed = false

local function key_setting_id(key)
	local suffix = string.gsub(key or "", "^loc_pickup_", "")
	suffix = string.gsub(suffix, "^loc_", "")

	return "pickup_rename_" .. suffix .. "_custom_name"
end

local function clean_base_name(value)
	if type(value) ~= "string" or value == "" then
		return nil
	end

	value = string.gsub(value, "{#.-}", "")
	value = string.gsub(value, "{#reset%(%)%}", "")

	if value == "" or string.sub(value, 1, 13) == "<unlocalized " then
		return nil
	end

	return value
end

mod.get_pickup_base_name = function(key)
	local manager = Managers and rawget(Managers, "localization")

	if not key or not manager then
		return nil
	end

	if type(manager._lookup) == "function" then
		local raw = manager:_lookup(key)

		if type(raw) == "string" and raw ~= "" then
			if type(manager._process_string) == "function" then
				local processed = manager:_process_string(key, raw)

				if type(processed) == "string" and processed ~= "" then
					raw = processed
				end
			end

			return clean_base_name(raw)
		end
	end

	if not base_localize then
		return nil
	end

	return clean_base_name(base_localize(manager, key, true))
end

local function faded_name(value)
	local color_class = rawget(_G, "Color")
	local color = color_class and color_class.ui_grey_light and color_class.ui_grey_light(180, true)
	local bracketed = "(" .. value .. ")"

	if color and mod.apply_color_to_text then
		return mod.apply_color_to_text(bracketed, color[2], color[3], color[4])
	end

	return bracketed
end

mod.refresh_pickup_name_options = function()
	local options = mod.pickup_name_options

	if not options then
		return
	end

	local target = mod:get("pickup_name_target")
	local replacement = mod:get("pickup_name_replacement") or ""

	for i = 1, #options do
		local option = options[i]

		if option then
			local base_name = mod.get_pickup_base_name(option.value)
			local custom = mod:get(key_setting_id(option.value))

			if option.value == target and replacement ~= "" then
				custom = replacement
			end

			local name = type(custom) == "string" and custom ~= "" and custom or base_name

			if name and base_name then
				name = base_name .. " " .. faded_name(name)
			end

			if name then
				option.text = name
				option.display_name = name
			end
		end
	end
end

local function refresh_pickup_name_overrides()
	table.clear(custom_name_by_key)

	local options = mod.pickup_name_options

	if not options then
		return
	end

	for i = 1, #options do
		local option = options[i]

		if option then
			local custom = mod:get(key_setting_id(option.value))

			if type(custom) == "string" and custom ~= "" then
				custom_name_by_key[option.value] = custom
			end
		end
	end
end

local function refresh_pickup_names()
	refresh_pickup_name_overrides()
	mod.refresh_pickup_name_options()
end

mod.refresh_pickup_names = refresh_pickup_names

local function apply_reset_all_pickup_names()
	local options = mod.pickup_name_options

	if not options then
		return
	end

	for i = 1, #options do
		local option = options[i]

		if option and option.value then
			mod:set(key_setting_id(option.value), "")
		end
	end

	local default_target = options[1] and options[1].value

	if default_target and mod:get("pickup_name_target") ~= default_target then
		mod:set("pickup_name_target", default_target, true)
	end

	if (mod:get("pickup_name_replacement") or "") ~= "" then
		mod:set("pickup_name_replacement", "", true)
	end

	refresh_pickup_names()
end

mod.reset_all_pickup_names = function(view)
	local event_manager = Managers and Managers.event

	if not event_manager or type(event_manager.trigger) ~= "function" then
		return
	end

	event_manager:trigger("event_show_ui_popup", {
		title_text_unlocalized = mod:localize("pickup_name_reset_all"),
		description_text_unlocalized = mod:localize("pickup_name_reset_all_description"),
		type = "warning",
		options = {
			{
				text = "loc_popup_button_settings_reset_default",
				close_on_pressed = true,
				callback = function()
					apply_reset_all_pickup_names()

					if view then
						view._popup_id = nil
					end
				end,
			},
			{
				text = "loc_popup_button_cancel_settings_reset_default",
				template_type = "terminal_button_small",
				close_on_pressed = true,
				hotkey = "back",
				callback = function()
					if view then
						view._popup_id = nil
					end
				end,
			},
		},
	}, function(id)
		if view then
			view._popup_id = id
		end
	end)
end

mod.reset_pickup_name = function()
	local target = mod:get("pickup_name_target")

	if not target then
		return
	end

	local base_name = mod.get_pickup_base_name(target) or ""
	local per_key_id = key_setting_id(target)

	if mod:get(per_key_id) ~= nil then
		mod:set(per_key_id, "")
	end

	mod:set("pickup_name_replacement", base_name, true)
	refresh_pickup_names()
end

local function is_pickup_name_setting_id(setting_id)
	if type(setting_id) ~= "string" then
		return false
	end

	return setting_id == "pickup_name_target"
		or setting_id == "pickup_name_replacement"
		or (string.sub(setting_id, 1, 14) == "pickup_rename_" and string.sub(setting_id, -12) == "_custom_name")
end

mod.update_pickup_name_settings = function(setting_id)
	if setting_id and not is_pickup_name_setting_id(setting_id) then
		return
	end

	if setting_id ~= nil and setting_id ~= "pickup_name_target" and setting_id ~= "pickup_name_replacement" then
		refresh_pickup_names()
		return
	end

	local target = mod:get("pickup_name_target")

	if not target then
		refresh_pickup_names()
		return
	end

	local per_key_id = key_setting_id(target)

	if setting_id == "pickup_name_replacement" then
		local replacement = mod:get("pickup_name_replacement") or ""
		local base_name = mod.get_pickup_base_name(target)

		if replacement == "" or (base_name and replacement == base_name) then
			if mod:get(per_key_id) ~= nil then
				mod:set(per_key_id, "")
			end
		elseif mod:get(per_key_id) ~= replacement then
			mod:set(per_key_id, replacement)
		end
	else
		local stored = mod:get(per_key_id)
		local value = type(stored) == "string" and stored or ""

		if value == "" then
			value = mod.get_pickup_base_name(target) or ""
		end

		if (mod:get("pickup_name_replacement") or "") ~= value then
			mod:set("pickup_name_replacement", value)
		end
	end

	refresh_pickup_names()
end

local localization_class = class_table and rawget(class_table, "LocalizationManager")

if localization_class and type(localization_class.localize) == "function" then
	base_localize = localization_class.localize

	mod:hook(localization_class, "localize", function(func, self, key, ...)
		if not base_localize then
			base_localize = func
		end

		local custom = fs and fs.pickup_names_enable ~= false and key and custom_name_by_key[key]

		if custom then
			return custom
		end

		return func(self, key, ...)
	end)

	if type(localization_class.reset_cache) == "function" then
		mod:hook_safe(localization_class, "reset_cache", refresh_pickup_names)
	end

	if type(localization_class.append_backend_localizations) == "function" then
		mod:hook_safe(localization_class, "append_backend_localizations", refresh_pickup_names)
	end
end

local function install_reset_button_hook()
	if reset_button_hook_installed then
		return
	end

	local view_class = class_table and rawget(class_table, "DMFOptionsView")

	if not view_class or type(view_class.cb_on_settings_pressed) ~= "function" then
		return
	end

	mod:hook(view_class, "cb_on_settings_pressed", function(func, self, widget, entry)
		if entry and entry.widget_type == "button" then
			if entry.setting_id == "pickup_name_reset" then
				if entry.pressed_function then
					entry.pressed_function(self, widget, entry)
				end

				return
			elseif entry.setting_id == "pickup_name_reset_all" then
				if type(mod.reset_all_pickup_names) == "function" then
					mod.reset_all_pickup_names(self)
				end

				return
			end
		end

		return func(self, widget, entry)
	end)

	reset_button_hook_installed = true
end

local ui_manager_class = class_table and rawget(class_table, "UIManager")

if ui_manager_class then
	local function on_options_view_opened(self, view_name)
		if view_name ~= "dmf_options_view" then
			return
		end

		install_reset_button_hook()
		refresh_pickup_names()
	end

	mod:hook_safe(ui_manager_class, "load_view", on_options_view_opened)
	mod:hook_safe(ui_manager_class, "open_view", on_options_view_opened)
end

install_reset_button_hook()
refresh_pickup_names()
