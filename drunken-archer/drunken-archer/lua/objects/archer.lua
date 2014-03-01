--the main player! this is important

Arrow = inherits(Object)

function Arrow:init()
	self:sprite("arrowhead") --everything else default
	self.framesToLive = 1000
	self:shape("circle")
	self:set_group("arrow")
	self.damage = 5
	self:setDensity(10)
end

function Arrow:update()
	self.framesToLive = self.framesToLive - 1
	if self.framesToLive <= 0 then
		self:destroy()
	end
end

local Bow = inherits(Object)

function Bow:init()
	self:sprite("bow")
	self.active = false;
	self:setRotationOrigin(21,21)
end

function Bow:update()
	self:sprite("bow")
	if self.owner.charge > 20 then
		--Fus
		self:sprite("bow1")
	end
	if self.owner.charge > 40 then
		--Roh
		self:sprite("bow2")
	end
	if self.owner.charge > 60 then
		--Dah!!
		self:sprite("bow3")
	end
end

Archer = inherits(Object)

function Archer:init()
	self:sprite("blobby")
	self:set_group("archer")
	self.fixedRotation = true; --don't rotate at all

	--spawn in a bow and attach it to ourselves
	self.bow = Bow.create()
	self.bow.owner = self
	self.firingAngle = 0.0
	self.charge = 0
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

	if self.charge > 20 and (keys_up.Space or gamepad_up.RB or gamepad_held.LB or keys_held.Y) then
		--spawn an arrow!
		arrow = Arrow.create()
		
		arrow.x = self.x + 1.4 - 0.4
		arrow.y = self.y + 1.0 - 0.4

		--move the arrow toward the bow's angle
		arrow.x = arrow.x + math.cos(math.rad(self.firingAngle)) * 3.0
		arrow.y = arrow.y + math.sin(math.rad(self.firingAngle)) * 3.0

		--now set the arrow's velocity
		speed = 10.0
		arrow.damage = 5
		arrow:color(255,128,128,255);
		if self.charge > 40 then
			speed = speed + 15
			arrow:color(255,255,128,255)
			arrow.damage = 10
		end
		if self.charge > 60 then
			speed = speed + 25
			arrow:color(128,255,255,255);
			arrow.damage = 20
		end

		arrow.vx = math.cos(math.rad(self.firingAngle)) * speed
		arrow.vy = math.sin(math.rad(self.firingAngle)) * speed
		
		--apply some of the arrow's speed to the player
		--(we use this for recoil, and also for jumping :D)
		self.vx = self.vx - (arrow.vx / 2)
		self.vy = self.vy - (arrow.vy / 2)
	end

	if keys_held.Space or gamepad_held.RB then
		self.charge = self.charge + 1
	 else
		self.charge = 0
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
registered_objects["Archer"] = "blobby"
registered_objects["Arrow"] = "arrowhead"