local mod = get_mod("markers_aio")

local fs = mod.frame_settings
local custom_name_by_key = {}
local base_localize

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

local localization_class = rawget(_G, "CLASS") and rawget(CLASS, "LocalizationManager")
if localization_class and type(localization_class.localize) == "function" then
	base_localize = localization_class.localize
end

if localization_class and type(localization_class.localize) == "function" then
	mod:hook(localization_class, "localize", function(func, self, key, ...)
		if not base_localize then
			base_localize = func
		end

		local custom = fs.pickup_names_enable ~= false and key and custom_name_by_key[key]

		if custom then
			return custom
		end

		return func(self, key, ...)
	end)
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
		local key = options[i].value
		local name = mod.get_pickup_base_name(key)

		if name then
			options[i].text = name
			options[i].display_name = name
		end
	end
end

mod.refresh_pickup_name_overrides = function()
	table.clear(custom_name_by_key)

	local options = mod.pickup_name_options

	if not options then
		return
	end

	for i = 1, #options do
		local key = options[i].value
		local custom = mod:get(key_setting_id(key))

		if type(custom) == "string" and custom ~= "" then
			custom_name_by_key[key] = custom
		end
	end
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

	mod.refresh_pickup_name_overrides()
end

mod.refresh_pickup_name_overrides()
