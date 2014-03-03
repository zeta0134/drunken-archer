BouncepadHoriz = inherits(Object)
function BouncepadHoriz:init()
	self:sprite("bouncy-horiz")
	self:body_type("static")
	self:set_group("bouncepad")
	self:setRestitution(1.2)
	self:add_target("arrow")
	self:add_target("archer")
end

function BouncepadHoriz:handleCollision()
	GameEngine.playSound("bounce")
end

BouncepadVert = inherits(Object)
function BouncepadVert:init()
	self:sprite("bouncy-vert")
	self:body_type("static")
	self:set_group("bouncepad")
	self:setRestitution(1.2)
	self:add_target("arrow")
	self:add_target("archer")
end

function BouncepadVert:handleCollision()
	GameEngine.playSound("bounce")
end

registered_objects["BouncepadVert"] = "bouncy-vert"
registered_objects["BouncepadHoriz"] = "bouncy-horiz"