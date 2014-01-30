--at this point, main.lua has already been run, and also
--the game engine *should* have injected a whole bunch of extra
--functions that we now have access to

dofile("lua/objects/ball.lua")
dofile("lua/objects/paddle.lua")

ball = Ball.create()
ball.x = math.random(100, 400)
ball.y = math.random(100, 400)
ball.vx = 6
ball.vy = 6
ball:sprite("art/sprites/triangle")

paddle = Paddle.create()
paddle.x = 0
paddle.y = 200
paddle:sprite("art/sprites/paddle")

aipaddle = AIPaddle.create()
aipaddle.x = 630
aipaddle.y = 200
aipaddle:sprite("art/sprites/paddle")

player_score = 0
ai_score = 0

--GameEngine.playMusic("music/game-loop")

--test things out
zero1 = Ball.create()
zero1.x = 200
zero1.y = 200
zero1.vx = 0
zero1.vy = 0
zero1:sprite("art/sprites/zero")
zero1:z_index(-1)
zero1:camera_weight(0.75, 0.75)

zero2 = Ball.create()
zero2.x = 200
zero2.y = 200
zero2.vx = 0
zero2.vy = 0
zero2:sprite("art/sprites/zero")
zero2:z_index(1)
zero2:color(255, 0, 255, 50);
zero2:camera_weight(1.5, 1.5)

--more testing things, yay

Camera = inherits(Object)

function Camera:update()
	if keys_held.W then
		self.y = self.y - 5
	end
	if keys_held.S then
		self.y = self.y + 5
	end
	if keys_held.D then
		self.x = self.x + 5
	end
	if keys_held.A then
		self.x = self.x - 5
	end

	--actually update the game camera based on this object's position
	GameEngine.setCamera(self.x, self.y)
end

camera = Camera.create()

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