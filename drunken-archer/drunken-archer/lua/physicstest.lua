--GameEngine.playMusic("music/menu-loop")

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



--try out some interesting things
testytest = TileMap.create()

testytest:z_index(-2)
testytest:setTiles("art/tiles/testytest")
testytest:mapSize(40,30)

--edges
for x = 1, 38 do
	testytest:setTile(x, 0, 2)
	testytest:setTile(x, 29, 14)
end

for y = 1, 28 do
	testytest:setTile(0, y, 7)
	testytest:setTile(39, y, 9)
end

--fill
for y = 1, 28 do
	for x = 1, 38 do
		testytest:setTile(x, y, 8)
	end
end

--corners
testytest:setTile(0,0,1)
testytest:setTile(0,29,13)
testytest:setTile(39,0,3)
testytest:setTile(39,29,15)