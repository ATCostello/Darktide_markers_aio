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

	if not key or not manager or not base_localize then
		return nil
	end

	return clean_base_name(base_localize(manager, key))
end

mod.refresh_pickup_name_options = function()
	local options = mod.pickup_name_options

	if not options then
		return
	end

	for i = 1, #options do
		local option = options[i]

		if option then
			local custom = mod:get(key_setting_id(option.value))
			local name = type(custom) == "string" and custom ~= "" and custom or mod.get_pickup_base_name(option.value)

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

mod.reset_pickup_name = function()
	local target = mod:get("pickup_name_target")

	if not target then
		return
	end

	local base_name = mod.get_pickup_base_name(target) or ""
	local per_key_id = key_setting_id(target)

	if mod:get(per_key_id) ~= nil then
		mod:set(per_key_id, nil)
	end

	mod:set("pickup_name_replacement", base_name, true)
	refresh_pickup_names()
end

mod.update_pickup_name_settings = function(setting_id)
	if setting_id and setting_id ~= "pickup_name_target" and setting_id ~= "pickup_name_replacement" then
		return
	end

	local target = mod:get("pickup_name_target")

	if not target then
		return
	end

	local per_key_id = key_setting_id(target)

	if setting_id == "pickup_name_replacement" then
		local replacement = mod:get("pickup_name_replacement") or ""
		local base_name = mod.get_pickup_base_name(target)

		if replacement == "" or (base_name and replacement == base_name) then
			if mod:get(per_key_id) ~= nil then
				mod:set(per_key_id, nil)
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
		if entry and entry.widget_type == "button" and entry.setting_id == "pickup_name_reset" then
			if entry.pressed_function then
				entry.pressed_function(self, widget, entry)
			end

			return
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
