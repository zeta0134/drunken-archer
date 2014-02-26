
Exit = inherits(Object)

function Exit:init()
	self:body_type("static")
	self:set_group("exit")
	self:add_target("archer")
	self:sprite("art/sprites/exit")
	print("init'd an exit?")
end

function Exit:handleCollision(target)
	if self.targetLevel then
		loadlevel(self.targetLevel)
	end
	print("collide!")
end

registered_objects["Exit"] = "art/sprites/exit"