--the main player! this is important

Arrow = inherits(Object)

function Arrow:init()
	self:sprite("art/sprites/arrowhead") --everything else default
	self.framesToLive = 1000
	self:shape("circle")
	self:set_group("arrow")
end

function Arrow:update()
	self.framesToLive = self.framesToLive - 1
	if self.framesToLive <= 0 then
		self:destroy()
	end
end

local Bow = inherits(Object)

function Bow:init()
	self:sprite("art/sprites/bow")
	self.active = false;
	self:setRotationOrigin(21,21)
end

Archer = inherits(Object)

function Archer:init()
	self:sprite("art/sprites/blobby")
	self:set_group("archer")
	self.fixedRotation = true; --don't rotate at all

	--spawn in a bow and attach it to ourselves
	self.bow = Bow.create()
	self.firingAngle = 0.0
end

function Archer:update()
	if keys_held.Left then
		self.vx = -10
	end
	if keys_held.Right then
		self.vx = 10
	end

	--gamepad movement
	if gamepad_left:length() > 0.1 then
		self.vx = gamepad_left.x * 10
	end

	--jumping
	if gamepad_down.A or keys_down.Up then
		self.vy = -10
		GameEngine.playSound("sound/Jump20")
	end

	--learn to turn
	if gamepad_right:length() > 0.5 then
		self.firingAngle = math.deg(gamepad_right.angle)
	end

	if keys_held.O then
		self.firingAngle = self.firingAngle - 2
	end

	if keys_held.P then
		self.firingAngle = self.firingAngle + 2
	end

	--do weird things to the bow now
	--TODO: Fix this by defining a joint and using Box2D instead; this is awful!
	self.bow.x = self.x + 1.5
	self.bow.y = self.y + 1.2
	self.bow:setAngle(self.firingAngle)

	if keys_down.Space or gamepad_down.RB or gamepad_held.LB or keys_held.Y then
		--spawn an arrow!
		arrow = Arrow.create()
		
		arrow.x = self.x + 1.4 - 0.4
		arrow.y = self.y + 1.0 - 0.4

		--move the arrow toward the bow's angle
		arrow.x = arrow.x + math.cos(math.rad(self.firingAngle)) * 3.0
		arrow.y = arrow.y + math.sin(math.rad(self.firingAngle)) * 3.0

		--now set the arrow's velocity
		arrow.vx = math.cos(math.rad(self.firingAngle)) * 20.0
		arrow.vy = math.sin(math.rad(self.firingAngle)) * 20.0
	end
end

PlayerCamera = inherits(Object)

function PlayerCamera:init()
	self:body_type("static")
end

function PlayerCamera:update()
	--determine a target location; this should keep the player onscreen within a considerable margin (200 px?)
	

	--actually update the game camera based on this object's position
	GameEngine.setCamera(self.x, self.y)
end

--register the objects
registered_objects["Archer"] = "art/sprites/blobby"
registered_objects["Arrow"] = "art/sprites/arrowhead"