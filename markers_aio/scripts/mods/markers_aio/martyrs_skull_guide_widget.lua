local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local Text = require("scripts/utilities/ui/text")

require("scripts/ui/hud/elements/hud_element_base")

local PANEL_WIDTH = 430
local SKULL_WIDTH = 140
local CONTENT_INSET = 14

local text_style_content_width = PANEL_WIDTH - CONTENT_INSET * 2

local scenegraph_definition = {
	screen = {
		scale = "fit",
		size = UIWorkspaceSettings.screen.size,
		position = { 0, 0, 0 },
	},
	guide_panel = {
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = { PANEL_WIDTH, 100 },
		position = { UIWorkspaceSettings.screen.size[1] - 482, 104, 0 },
	},
}

local function make_scenegraph_with_offset(x_offset, y_offset)
	local base_x = UIWorkspaceSettings.screen.size[1] - 482
	return {
		screen = scenegraph_definition.screen,
		guide_panel = {
			vertical_alignment = "top",
			horizontal_alignment = "left",
			size = { PANEL_WIDTH, 100 },
			position = { base_x + (x_offset or 0), 104 + (y_offset or 0), 0 },
		},
	}
end

local function make_widget_definitions()
	local wd = {}
	wd.guide = UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = Color.terminal_grid_background(180, true),
				offset = { 0, 0, 0 },
				size = { PANEL_WIDTH, 100 },
			},
		},
		{
			pass_type = "texture",
			style_id = "top_bar",
			value = "content/ui/materials/dividers/horizontal_dynamic_upper",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = Color.terminal_text_header(255, true),
				offset = { -3, -6, 3 },
				size = { PANEL_WIDTH + 6, 10 },
			},
		},
		{
			pass_type = "texture",
			style_id = "skull",
			value = "content/ui/materials/dividers/skull_rendered_center_01",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = Color.terminal_text_header(255, true),
				offset = { ((PANEL_WIDTH - SKULL_WIDTH) / 2) -3, -9, 4 },
				size = { SKULL_WIDTH, 22 },
			},
		},
		{
			pass_type = "text",
			style_id = "guide_title",
			value_id = "guide_title",
			value = "",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				font_size = 18,
				font_type = get_mod("markers_aio"):get("font_type"),
				offset = { CONTENT_INSET, 0, 3 },
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = Color.terminal_text_header(255, true),
				color = Color.terminal_text_header(255, true),
				drop_shadow = true,
				size = { text_style_content_width, 50 },
			},
			visibility_function = function(content, style)
				return content.visible and content.guide_title ~= nil and content.guide_title ~= ""
			end,
		},
		{
			pass_type = "text",
			style_id = "header_text",
			value_id = "header_text",
			value = "",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				font_size = 16,
				font_type = get_mod("markers_aio"):get("font_type"),
				offset = { CONTENT_INSET, 0, 3 },
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = Color.terminal_text_header(200, true),
				color = Color.terminal_text_header(200, true),
				drop_shadow = true,
				size = { text_style_content_width, 200 },
			},
			visibility_function = function(content, style)
				return content.visible and content.header_text ~= nil and content.header_text ~= ""
			end,
		},
		{
			pass_type = "text",
			style_id = "body_text",
			value_id = "body_text",
			value = "",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				font_size = 14,
				font_type = get_mod("markers_aio"):get("font_type"),
				offset = { CONTENT_INSET, 0, 3 },
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = Color.terminal_text_body(255, true),
				color = Color.terminal_text_body(255, true),
				drop_shadow = true,
				size = { text_style_content_width, 200 },
			},
			visibility_function = function(content, style)
				return content.visible and content.body_text ~= nil and content.body_text ~= ""
			end,
		},
		{
			pass_type = "text",
			style_id = "steps_text",
			value_id = "steps_text",
			value = "",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				font_size = 14,
				font_type = get_mod("markers_aio"):get("font_type"),
				offset = { CONTENT_INSET + 8, 0, 3 },
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = Color.terminal_text_body(255, true),
				color = Color.terminal_text_body(255, true),
				drop_shadow = true,
				size = { text_style_content_width - 8, 500 },
			},
			visibility_function = function(content, style)
				return content.visible and content.steps_text ~= nil and content.steps_text ~= ""
			end,
		},
		{
			pass_type = "texture",
			style_id = "bottom_bar",
			value = "content/ui/materials/dividers/horizontal_dynamic_lower",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = Color.terminal_text_header(255, true),
				offset = { -3, 0, 3 },
				size = { PANEL_WIDTH + 6, 10 },
			},
		},
	}, "guide_panel")
	return wd
end

local function apply_element_positions(widget, title_y, header_y, body_y, steps_y, bottom_bar_y, panel_h)
	widget.style.guide_title.offset[2] = title_y
	widget.style.header_text.offset[2] = header_y
	widget.style.body_text.offset[2] = body_y
	widget.style.steps_text.offset[2] = steps_y
	widget.style.background.size[2] = panel_h
	widget.style.bottom_bar.offset[2] = bottom_bar_y
	widget.content.size = { PANEL_WIDTH, panel_h }
end

local MartyrsSkullGuideElement = class("MartyrsSkullGuideElement", "HudElementBase")

function MartyrsSkullGuideElement:init(parent, draw_layer, start_scale, context)
	local mod = get_mod("markers_aio")
	local x_offset = mod:get("martyrs_skull_guide_x_offset") or 0
	local y_offset = mod:get("martyrs_skull_guide_y_offset") or 0
	self._guide_x_offset = x_offset
	self._guide_y_offset = y_offset

	MartyrsSkullGuideElement.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = make_scenegraph_with_offset(x_offset, y_offset),
		widget_definitions = make_widget_definitions(),
	})
	self._guide_widget = self._widgets_by_name.guide
	self._guide_widget.content.visible = false
	self._guide_widget.content.guide_title = mod:localize("martyrs_skull_guide_title")
end

function MartyrsSkullGuideElement:set_guide_offset(x_offset, y_offset)
	self._guide_x_offset = x_offset
	self._guide_y_offset = y_offset
	local base_x = UIWorkspaceSettings.screen.size[1] - 482
	self:set_scenegraph_position("guide_panel", base_x + x_offset, 104 + y_offset)
end

function MartyrsSkullGuideElement:_measure_text_height(ui_renderer, text, style)
	if not text or text == "" then
		return 0
	end
	local _, height = Text.text_size(ui_renderer, text, style, style.size)
	return height or 0
end

function MartyrsSkullGuideElement:_compute_and_apply_layout(widget, ui_renderer)
	local content = widget.content
	local title_h = self:_measure_text_height(ui_renderer, content.guide_title, widget.style.guide_title)
	local header_h = self:_measure_text_height(ui_renderer, content.header_text, widget.style.header_text)
	local body_h = self:_measure_text_height(ui_renderer, content.body_text, widget.style.body_text)
	local steps_h = self:_measure_text_height(ui_renderer, content.steps_text, widget.style.steps_text)

	local title_y = 24
	local header_y = title_y + title_h + 4
	local body_y = header_y + header_h + 4
	local steps_y = body_y + body_h + 4
	local bottom_bar_y = steps_y + steps_h + 12
	local panel_h = bottom_bar_y + 14
	apply_element_positions(widget, title_y, header_y, body_y, steps_y, bottom_bar_y, panel_h)
	return panel_h
end

function MartyrsSkullGuideElement:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
	local widget = self._guide_widget
	if not widget or not widget.content.visible then
		return
	end

	if self._needs_layout then
		self._needs_layout = false
		local new_h = self:_compute_and_apply_layout(widget, ui_renderer)
		self:_set_scenegraph_size("guide_panel", nil, new_h)
		widget.dirty = true
	end

	UIWidget.draw(widget, ui_renderer)
end

function MartyrsSkullGuideElement:set_content(header, body, steps)
	local w = self._guide_widget
	if not w then
		return
	end
	if not header and not body and not steps then
		self._last_header, self._last_body, self._last_steps = nil, nil, nil
		w.content.visible = false
		return
	end
	if self._last_header == header and self._last_body == body and self._last_steps == steps then
		w.content.visible = true
		return
	end
	self._last_header, self._last_body, self._last_steps = header, body, steps
	w.content.header_text = header or ""
	w.content.body_text = body or ""
	w.content.steps_text = steps or ""
	w.content.visible = true
	self._needs_layout = true
end

function MartyrsSkullGuideElement:clear()
	local w = self._guide_widget
	if not w then
		return
	end
	self._last_header, self._last_body, self._last_steps = nil, nil, nil
	w.content.visible = false
	w.content.header_text = ""
	w.content.body_text = ""
	w.content.steps_text = ""
end

return MartyrsSkullGuideElement
