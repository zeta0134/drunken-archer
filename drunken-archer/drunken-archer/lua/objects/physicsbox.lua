--test object; no behaviors, simply acts as a dynamic physics object wherever it's placed

Box = inherits(Object)
function Box:init()
	self:set_group("box")
	self:add_target("arrow")
	self.health = 25
	self.hurtTimer = 0
	self:sprite("physicsbox")
end

function Box:update()
	if self.hurtTimer > 0 then
		self.hurtTimer = self.hurtTimer - 1
		self:color(255, 0, 0, 255)
	else
		self:color(255, 255, 255, 255)
	end
end

function Box:handleCollision(target)
	if target.get_group() == "arrow" then
		self.health = self.health - target.damage
		self.hurtTimer = 5
		if self.health <= 0 then
			self:destroy()
			GameEngine.playSound("ballout")
		end
		target:destroy()
	end
end

StrongBox = inherits(Object)
function StrongBox:init()
	self:set_group("strongbox")
	self:sprite("strongbox")
end

registered_objects["Box"] = "physicsbox"
registered_objects["StrongBox"] = "strongbox"