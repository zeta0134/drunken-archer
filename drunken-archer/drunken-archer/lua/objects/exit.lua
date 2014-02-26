
Exit = inherits(Object)

function Exit:init()
	self:body_type("static")
	self:set_group("exit")
	self:add_target("archer")
	self:sprite("exit")
end

function Exit:handleCollision(target)
	if self.targetLevel then
		loadlevel(self.targetLevel)
	end
end

registered_objects["Exit"] = "exit"