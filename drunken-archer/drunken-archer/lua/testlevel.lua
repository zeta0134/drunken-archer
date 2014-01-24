--at this point, main.lua has already been run, and also
--the game engine *should* have injected a whole bunch of extra
--functions that we now have access to

Ball = inherits(Object)

function Ball:update()

	--"Collision"
	if self.object.x > 800 - 32 then
		self.object.x = 800 - 32
		self.object.vx = self.object.vx * -0.7
	end

	if self.object.x < 0 then
		self.object.x = 0
		self.object.vx = self.object.vx * -0.7
	end

	if self.object.y > 480 - 32 then
		self.object.y = 480 - 32
		self.object.vy = self.object.vy * -0.7
	end

	if self.object.y < 0 then
		self.object.y = 0
		self.object.vy = self.object.vy * -0.7
	end
end

print("Creating several balls")

for i = 0, 250 do
	local test = Ball.create {
		x=math.random(10, 750),
		y=math.random(10, 350),
		vx = math.random(0.5, 2.0),
		vy = math.random(0.5, 2.0)}
	--note that at this point, we discard test; that's OK. The game engine keeps track of it on its own
	--(Lua keeps a copy in its global objects[] table) and continues to process it. We need to *explicitly*
	--destroy objects to make them go away.
end

happy = Ball.create({})
happy.y = 100

print("Left testlevel.lua without errors!")