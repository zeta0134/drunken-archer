﻿--the main player! this is important

--timing defines
chargelevel = {}
chargelevel[1] = {
	frame=10,
	damage=5,
	speed=15
}
chargelevel[2] = {
	frame=40,
	damage=10,
	speed=30,
}
chargelevel[3] = {
	frame=70,
	damage=20,
	speed=45
}

Arrow = inherits(Object)

function Arrow:init()
	self:sprite("arrowhead") --everything else default
	self.framesToLive = 500
	self:shape("circle")
	self:set_group("arrow")
	self.damage = 5
	self:setDensity(10)
	self:add_target("level")
	self:add_target("door")
	self:add_target("arrow")
end

function Arrow:update()
	self.framesToLive = self.framesToLive - 1
	if self.framesToLive <= 0 then
		GameEngine.playSound("arrow-die")
		self:destroy()
	end

	--particles!
	if self.framesToLive % 6 == 0 then
		particle = Particle.create()
		particle.x = self.x
		particle.y = self.y
		particle.vx = (math.random() - 0.5) * 4
		particle.vy = (math.random() - 0.5) * 4
		particle.vr = (math.random() - 0.5) * 4
	end
end

function Arrow:handleCollision(target)
	if target:get_group() == "level" or target:get_group() == "arrow" or target:get_group() == "door" then
		GameEngine.playSound("arrow-die")
		self:destroy()
	end
end

Particle = inherits(Object)
function Particle:init()
	self:sprite("particle")
	self:body_type("kinematic")
	self:shape("none")
	self.framesToLive = 10
	self:z_index(-1)
end

function Particle:update()
	self.framesToLive = self.framesToLive - 1
	if self.framesToLive <= 0 then
		self:destroy()
	else
		self:color(self.framesToLive * 22, self.framesToLive * 22, self.framesToLive * 22, self.framesToLive)
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
	for i = 1,3 do
		if self.owner.charge > chargelevel[i].frame then
			--Fus, Roh, Dah!!
			self:sprite("bow"..i)
		end	
		if self.owner.charge == chargelevel[i].frame then
			GameEngine.playSound("charge"..i)
		end
	end
	if self.owner.charge < 0 then
		self:color(128,128,128,255)
	else
		self:color(255,255,255,255)
	end
end

Archer = inherits(Object)

function Archer:init()
	self:sprite("blobby")
	self:set_group("archer")
	self.fixedRotation = true; --don't rotate at all
	self:setFriction(1.5)

	--spawn in a bow and attach it to ourselves
	self.bow = Bow.create()
	self.bow.owner = self
	self.firingAngle = 0.0
	self.charge = 0

	self.camera = PlayerCamera.create()
	self.camera.target = self

	if self.bottomCamera then
		self.camera.y = self.y + 100
	end
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
	--if gamepad_down.A or keys_down.Up then
	--	self.vy = -10
	--	GameEngine.playSound("Jump20")
	--end

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

	if self.charge >= chargelevel[1].frame and (keys_up.Space or gamepad_up.RB or gamepad_held.LB or keys_held.Y) then
		--spawn an arrow!
		arrow = Arrow.create()
		
		arrow.x = self.x + 1.4 - 0.4
		arrow.y = self.y + 1.0 - 0.4

		--move the arrow toward the bow's angle
		firingdistance = 3.0
		arrow.x = arrow.x + math.cos(math.rad(self.firingAngle)) * firingdistance
		arrow.y = arrow.y + math.sin(math.rad(self.firingAngle)) * firingdistance

		--now set the arrow's velocity
		speed = chargelevel[1].speed
		arrow.damage = chargelevel[1].damage
		arrow:color(255,128,128,255);

		if self.charge >= chargelevel[2].frame then
			speed = chargelevel[2].speed
			arrow:color(255,255,128,255)
			arrow.damage = chargelevel[2].damage
		end

		if self.charge >= chargelevel[3].frame then
			speed = chargelevel[3].speed
			arrow:color(128,255,255,255);
			arrow.damage = chargelevel[3].damage
		end

		arrow.vx = math.cos(math.rad(self.firingAngle)) * speed
		arrow.vy = math.sin(math.rad(self.firingAngle)) * speed
		
		--apply some of the arrow's speed to the player
		--(we use this for recoil, and also for jumping :D)
		self.vx = self.vx - (arrow.vx / 2)
		self.vy = self.vy - (arrow.vy / 2)

		self.charge = -20 --cooldown
		GameEngine.playSound("fire")
	end

	if keys_held.Space or gamepad_held.RB or self.charge < 0 then
		self.charge = self.charge + 1
	else
		self.charge = 0
	end

	--detect and respond to death
	if self.x < current_map.x - 20 then
		GameEngine.playSound("death")
		self:destroy()
		loadlevel(current_filename)
		--print("off left")
	end
	if self.x > current_map.x + (current_map.width * 16 / 10) + 10 then
		GameEngine.playSound("death")
		self:destroy()
		loadlevel(current_filename)
		--print("off right")
	end
	if self.y > current_map.y + (current_map.height * 16 / 10) + 10 then
		GameEngine.playSound("death")
		self:destroy()
		loadlevel(current_filename)
		--print("off bottom")
	end
end

PlayerCamera = inherits(Object)

function PlayerCamera:init()
	self:body_type("static")
end

function PlayerCamera:update()
	--extra stuff: respond to the D-pad for player-controlled movement
	if gamepad_held.Up then
		self.y = self.y - 1
	end

	if gamepad_held.Down then
		self.y = self.y + 1
	end

	if gamepad_held.Left then
		self.x = self.x - 1
	end

	if gamepad_held.Right then
		self.x = self.x + 1
	end


	--determine a target location; this should keep the player onscreen within a considerable margin (200 px?)
	
	--64,36 -- max coords onscreen
	screen_width = 60
	screen_height = 36

	camera_max = {}
	camera_max.x = self.target.x - 22
	camera_max.y = self.target.y - 3

	camera_min = {}
	camera_min.x = self.target.x - screen_width + 22
	camera_min.y = self.target.y - screen_height + 10

	if self.x < camera_min.x then
		self.x = camera_min.x
	end
	if self.y < camera_min.y then
		self.y = camera_min.y
	end

	if self.x > camera_max.x then
		self.x = camera_max.x
	end
	if self.y > camera_max.y then
		self.y = camera_max.y
	end

	--actually update the game camera based on this object's position
	GameEngine.setCamera(self.x * 10, (self.y) * 10)
end

--register the objects
registered_objects["Archer"] = "blobby"
registered_objects["Arrow"] = "arrowhead"