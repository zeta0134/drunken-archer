GameEngine.playMusic("music/menu-loop")

--create a box! (it should fall)
Box = inherits(Object)

box = Box.create()
box:sprite("art/sprites/zero")
box.x = 10
box.y = 10
box.vx = 5

function box:update()
	if keys_held.Up then
		self.vy = -10
	end
	if keys_held.Down then
		self.vy = 10
	end
	if keys_held.Left then
		self.vx = -10
	end
	if keys_held.Right then
		self.vx = 10
	end

	if keys_down.D then
		self.x = 10
		self.y = 10
		GameEngine.playMusic("music/game-loop2")
	end
end

for i = 1, 10 do
	paddle = Box.create()
	paddle:sprite("art/sprites/paddle")
	paddle.x = math.random(1, 60)
	paddle.y = math.random(1, 30)
end

for i = 1, 10 do
	triangle = Box.create()
	triangle:sprite("art/sprites/triangle")
	triangle.x = math.random(1, 60)
	triangle.y = math.random(1, 30)
end