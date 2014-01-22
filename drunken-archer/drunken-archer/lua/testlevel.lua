--at this point, main.lua has already been run, and also
--the game engine *should* have injected a whole bunch of extra
--functions that we now have access to

Ball = inherits(Object)

Ball.vx = 1
Ball.vy = 1

function Ball:update()
	
	--velocity
	self.object.x = self.object.x + self.vx
	self.object.y = self.object.y + self.vy

	--"Physics"
	if self.object.x > 800 - 32 then
		self.object.x = 800 - 32
		self.vx = self.vx * -1
	end

	if self.object.x < 0 then
		self.object.x = 0
		self.vx = self.vx * -1
	end

	if self.object.y > 480 - 32 then
		self.object.y = 480 - 32
		self.vy = self.vy * -1
	end

	if self.object.y < 0 then
		self.object.y = 0
		self.vy = self.vy * -1
	end

end

print("Creating several balls")

for i = 0, 100 do
	test = Ball.create()
	test.object.x = math.random(10, 750)
	test.object.y = math.random(10, 350)
	test.vx = math.random(0.5, 2.0)
	test.vy = math.random(0.5, 2.0)
	--note that at this point, we discard test; that's OK. The game engine keeps track of it on its own
	--(Lua keeps a copy in its global objects[] table) and continues to process it. We need to *explicitly*
	--destroy objects to make them go away.
end

print("Left testlevel.lua without errors!")