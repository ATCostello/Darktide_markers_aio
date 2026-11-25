local mod = get_mod("markers_aio")

mod.category_toggles = mod.category_toggles or {}

local category_toggle_state = {}
local category_toggle_widget_set = nil
local category_ranges = {}

mod.set_frame_value = function(frame_settings, key, value)
	local parent_key, child_key = string.match(key, "^(.-)%.(.+)$")

	if parent_key and child_key then
		local parent = frame_settings[parent_key]

		if type(parent) == "table" then
			parent[child_key] = value
		end
	else
		frame_settings[key] = value
	end
end

local function get_widget_set(options_templates)
	local dynamic_widget_sets = options_templates and rawget(options_templates, "dynamic_widget_sets")

	return dynamic_widget_sets and rawget(dynamic_widget_sets, "markers_aio") or nil
end

local function build_category_ranges(widget_set)
	local widgets = rawget(widget_set, "widgets") or {}
	local ranges = {}

	for c = 1, #mod.category_toggles do
		local entry = mod.category_toggles[c]
		local start_index

		for i = 1, #widgets do
			local widget = widgets[i]

			if widget and widget.depth == 0 and widget.setting_id == entry.group_setting_id then
				start_index = i
				break
			end
		end

		if start_index then
			local end_index = #widgets

			for i = start_index + 1, #widgets do
				local widget = widgets[i]

				if widget and widget.depth == 0 then
					end_index = i - 1
					break
				end
			end

			ranges[c] = { start_index = start_index, end_index = end_index }
		end
	end

	return ranges
end

local function ensure_category_ranges(widget_set)
	if category_toggle_widget_set ~= widget_set then
		category_toggle_widget_set = widget_set
		category_toggle_state = {}
		category_ranges = build_category_ranges(widget_set)
	end
end

mod.apply_category_toggle_visibility = function(options_templates)
	local widget_set = get_widget_set(options_templates)

	if not widget_set then
		return false
	end

	ensure_category_ranges(widget_set)

	local widgets = rawget(widget_set, "widgets")
	local templates = rawget(widget_set, "templates")

	if not widgets or not templates then
		return false
	end

	local changed = false

	for c = 1, #mod.category_toggles do
		local entry = mod.category_toggles[c]
		local range = category_ranges[c]

		if range then
			local hidden = mod:get(entry.setting_id) == false

			for i = range.start_index, range.end_index do
				local widget = widgets[i]
				local template = templates[widget and widget.index or i]

				if template then
					local new_hidden

					if hidden then
						new_hidden = true
					elseif i == range.start_index then
						new_hidden = false
					else
						new_hidden = template.hidden
					end

					if new_hidden ~= template.hidden then
						template.hidden = new_hidden
						changed = true
					end
				end
			end
		end
	end

	return changed
end

local function update_options_view(self)
	if not self or self.view_name ~= "dmf_options_view" then
		return
	end

	local options_templates = self._options_templates
	local widget_set = get_widget_set(options_templates)

	if not options_templates or not widget_set then
		return
	end

	ensure_category_ranges(widget_set)

	local state_changed = false

	for _, entry in ipairs(mod.category_toggles) do
		local enabled = mod:get(entry.setting_id) ~= false

		if category_toggle_state[entry.setting_id] ~= enabled then
			category_toggle_state[entry.setting_id] = enabled
			state_changed = true
		end
	end

	if state_changed then
		local dmf = get_mod("DMF")

		if dmf and type(dmf.update_mod_options_visibility) == "function" then
			dmf:update_mod_options_visibility(options_templates, "markers_aio")
		end
	end

	mod.apply_category_toggle_visibility(options_templates)

	if state_changed then
		self._dynamic_options_changed_entry = {
			setting_id = "category_toggles_settings",
			mod_name = "markers_aio",
		}
	end
end

if CLASS and CLASS.BaseView then
	mod:hook_safe(CLASS.BaseView, "on_enter", function(self)
		update_options_view(self)
	end)

	mod:hook_safe(CLASS.BaseView, "update", function(self)
		update_options_view(self)
	end)
end
