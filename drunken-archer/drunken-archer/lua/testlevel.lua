--at this point, main.lua has already been run, and also
--the game engine *should* have injected a whole bunch of extra
--functions that we now have access to

Ball = inherits(Object)

function Ball:update()

	--"Collision"
	if self.x > 800 - 32 then
		self.x = 800 - 32
		self.vx = self.vx * -0.8
	end

	if self.x < 0 then
		self.x = 0
		self.vx = self.vx * -0.8
	end

	if self.y > 480 - 32 then
		self.y = 480 - 32
		self.vy = self.vy * -0.8
	end

	if self.y < 0 then
		self.y = 0
		self.vy = self.vy * -0.8
	end
end

print("Creating several balls")

for i = 0, 10 do
	local test = Ball.create {
		x=math.random(10, 750),
		y=math.random(10, 350),
		vx = math.random(-2.0, 2.0),
		vy = math.random(-2.0, 2.0)}
	--note that at this point, we discard test; that's OK. The game engine keeps track of it on its own
	--(Lua keeps a copy in its global objects[] table) and continues to process it. We need to *explicitly*
	--destroy objects to make them go away.
	test.object:sprite_color(255, 0, 0, 255)
	test.object:sprite("art/sprites/triangle")
end

happy = Ball.create({vx=20,vy=10})
happy.object:sprite_color(255, 255, 255, 200)
happy.object:sprite("art/sprites/zero")

print("Left testlevel.lua without errors!")