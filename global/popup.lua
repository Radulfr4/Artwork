Button = File.LoadLua("button/button.lua")()
Global = File.LoadLua("global/global.lua")()
Fonts = File.LoadLua("global/fonts.lua")()

function create_simple_text_button(text, text_height)
	font = Font.Create("Verdana",text_height)
	button_normal_color = Color.Create(0.9, 0.9, 1, 0.8)
	button_hover_color 	= Color.Create(1, 0.9, 0.8, 0.8)

	button_image = Image.String(font, button_normal_color, 300, text, Justify.Left)
	button_image_highlight = Image.String(font, button_hover_color, 300, text, Justify.Left)

	button_credits = Button.create_image_button(button_image, button_image_highlight, button_image)

	return {
		image=button_credits.image,
		event_click=button_credits.events.click,
	}
end

function create_single_popup_manager(target_image_getter, opts)
	opts = {}
	controls = opts.control_maker or function (popup_is_open)
			close_btn = create_simple_text_button("X", 20)
			Event.OnEvent(popup_is_open, close_btn.event_click, function ()
				return false
			end)
			return 	Image.Translate(
						close_btn.image,
						Point.Create(popup_x - 40, 15)
					)
		end
	local popup_is_open = Boolean.CreateEventSink(false)

	function get_area(size)

		function create_popup_image()
			target_image = target_image_getter()
			target_image_size = Image.Size(target_image)
			target_x = Point.X(target_image_size)
			target_y = Point.X(target_image_size)

			margin = 40
			scrollbar_width = 20

			area_x = Point.X(size)
			area_y = Point.Y(size)

			target_container_maximum_x = area_x - 2 * margin
			target_container_maximum_y = area_y - 2 * margin

			target_container_x = Number.Min(target_container_maximum_x, target_x + scrollbar_width)
			target_container_y = Number.Min(target_container_maximum_y, target_y)

			popup_x = target_container_x + 2 * margin
			popup_y = target_container_y + 2 * margin

			target_container_offset = Point.Create(margin, margin)
			target_container_size = Point.Create(target_container_x, target_container_y)
			popup_size = Point.Create(popup_x, popup_y)

			return Image.Justify(
				Image.Group({
					Global.create_backgroundpane(popup_x, popup_y, {color=button_normal_color, src=Image.File("/global/images/backgroundpane_80pcOpacity.png")}),
					Image.Translate(
						Global.create_vertical_scrolling_container(target_image, target_container_size, button_normal_color),
						target_container_offset
					),
					controls(popup_is_open)
				}),
				size,
				Justify.Center
			)
		end

		return Image.Switch(popup_is_open, {
			[ false ] = Image.Empty(),
			[ true ] = Image.Lazy(create_popup_image),
		})
	end

	function get_is_open()
		return popup_is_open
	end

	return {
		get_area=get_area,
		get_is_open=get_is_open
	}
end

return {
	create_single_popup_manager=create_single_popup_manager,
	create_simple_text_button=create_simple_text_button
}