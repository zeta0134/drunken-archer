Button = inherits(Object)

function button_init(self)
	self:sprite(self.released_art)
	self:body_type("static")
	self:set_group("button")
	self:add_target("arrow")
end

function button_update(self)
	if not self.triggered and stage.triggered[self.name] then
		self.triggered = true
		self:sprite(self.pressed_art)
		GameEngine.playSound("button-press")
	end

	if self.triggered and not stage.triggered[self.name] then
		self.triggered = false
		self:sprite(self.released_art)
		GameEngine.playSound("button-press")
	end
end

function button_handleCollision(self, target)
	stage.triggered[self.name] = not stage.triggered[self.name]
	target:destroy()
	print("Hit a button!")
end

ButtonLeft = inherits(Object)
ButtonLeft.pressed_art = "button-left-pressed"
ButtonLeft.released_art = "button-left-released"
ButtonLeft.init = button_init
ButtonLeft.update = button_update
ButtonLeft.handleCollision = button_handleCollision

ButtonRight = inherits(Object)
ButtonRight.pressed_art = "button-right-pressed"
ButtonRight.released_art = "button-right-released"
ButtonRight.init = button_init
ButtonRight.update = button_update
ButtonRight.handleCollision = button_handleCollision

ButtonTop = inherits(Object)
ButtonTop.pressed_art = "button-top-pressed"
ButtonTop.released_art = "button-top-released"
ButtonTop.init = button_init
ButtonTop.update = button_update
ButtonTop.handleCollision = button_handleCollision

ButtonBottom = inherits(Object)
ButtonBottom.pressed_art = "button-bottom-pressed"
ButtonBottom.released_art = "button-bottom-released"
ButtonBottom.init = button_init
ButtonBottom.update = button_update
ButtonBottom.handleCollision = button_handleCollision

registered_objects["ButtonTop"] = "button-top-released"
registered_objects["ButtonRight"] = "button-right-released"
registered_objects["ButtonBottom"] = "button-bottom-released"
registered_objects["ButtonLeft"] = "button-left-released"

