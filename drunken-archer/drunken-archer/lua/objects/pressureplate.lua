PressurePlate = inherits(Object)

function PressurePlate:init()
	self:sprite("pressureplate")
	self:body_type("static")
	self.triggered = false
	self.cooldown = 0

	self:set_group("pressureplate")
	self:add_target("archer")
	self:add_target("box")
	self:add_target("strongbox")
	self:add_target("wreckingball")
	self:add_target("chain")
end

function PressurePlate:update()
	if not self.triggered and stage.triggered[self.name] then
		self.triggered = true
		self:sprite("pressureplate-pressed")
		GameEngine.playSound("button-press")
	end

	if self.triggered and not stage.triggered[self.name] then
		self.triggered = false
		self:sprite("pressureplate")
		GameEngine.playSound("button-press")
	end
	if self.cooldown > 0 then
		self.cooldown = self.cooldown - 1
		self:sprite("pressureplate") --force a collision check while we're being pressed
	else
		stage.triggered[self.name] = false
	end
	
end

function PressurePlate:handleCollision()
	self.cooldown = 20
	stage.triggered[self.name] = true
end

registered_objects["PressurePlate"] = "pressureplate"