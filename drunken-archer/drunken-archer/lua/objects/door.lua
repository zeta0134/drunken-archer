Door = inherits(Object)
registered_objects["Door"] = "door-closed"

function Door:init()
	self:sprite("door-closed")
	self:body_type("static")
	self.triggered = false
end

function Door:update()
	if not self.triggered and stage.triggered[self.name] then
		self.triggered = true
		self:sprite("door-opened")
		self:shape("none")
		GameEngine.playSound("sound/door-open")
	end

	if self.triggered and not stage.triggered[self.name] then
		self.triggered = false
		self:sprite("door-closed")
		self:shape("box")
		GameEngine.playSound("sound/door-close")
	end
end