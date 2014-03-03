DeathField = inherits(Object)
function DeathField:init()
	self:sprite("deathfield")
	self:body_type("static")
	self:set_group("deathfield")
	self:add_target("archer")
	self.isSensor = true
	self.framesAlive = 0
	self.triggered = false
end

function DeathField:handleCollision()
	if not stage.triggered[self.name] then
		loadlevel(current_filename)
	end
end

function DeathField:update()
	if not self.triggered and stage.triggered[self.name] then
		self.triggered = true
		self:sprite("deathfield-disabled")
		self.isSensor = true
	end

	if self.triggered and not stage.triggered[self.name] then
		self.triggered = false
		self:sprite("deathfield")
		self.isSensor = true
	end
end

registered_objects["DeathField"] = "deathfield"