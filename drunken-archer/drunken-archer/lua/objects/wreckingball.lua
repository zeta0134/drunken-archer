
WreckingBall = inherits(Object)
function WreckingBall:init()
	self:set_group("wreckingball")
	self:sprite("wrecking-ball")
	self:shape("circle")
end

Chainlink = inherits(Object)
function Chainlink:init()
	self:set_group("chain")
	self:sprite("chainlink")
end

BreakableChainlink = inherits(Object)
function BreakableChainlink:init()
	self:set_group("chain")
	self:sprite("chainlink-cracked")
	self.health = 15
	self.hurtTimer = 0
	self:add_target("arrow")
end

function BreakableChainlink:update()
	if self.hurtTimer > 0 then
		self.hurtTimer = self.hurtTimer - 1
		self:color(255, 0, 0, 255)
	else
		self:color(255, 255, 255, 255)
	end
end

function BreakableChainlink:handleCollision(target)
	if target.get_group() == "arrow" then
		self.health = self.health - target.damage
		self.hurtTimer = 5
		if self.health <= 0 then
			self:destroy()
			--GameEngine.playSound("sound/ballout")
		end
		target:destroy()
	end
end

ChainlinkHook = inherits(Object)
function ChainlinkHook:init()
	self:body_type("static")
	self:set_group("chain")
	self:sprite("chainlink-hook")
end

registered_objects["WreckingBall"] = "wrecking-ball"
registered_objects["Chainlink"] = "chainlink"
registered_objects["BreakableChainlink"] = "chainlink-cracked"
registered_objects["ChainlinkHook"] = "chainlink-hook"