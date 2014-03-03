
Exit = inherits(Object)

function Exit:init()
	self:body_type("static")
	self:set_group("exit")
	self:add_target("archer")
	self:sprite("exit")
end

function Exit:handleCollision(target)
	if self.targetLevel then
		GameEngine.playSound("enter-door")
		loadlevel(self.targetLevel)
	end
	if self.targetStage then
		GameEngine.playSound("enter-door")
		loadstage(self.targetStage)
	end
end

registered_objects["Exit"] = "exit"