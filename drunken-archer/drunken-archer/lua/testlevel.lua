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
ball.object:sprite("art/sprites/triangle")

paddle = Paddle.create()
paddle.x = 0
paddle.y = 200
paddle.object:sprite("art/sprites/paddle")

aipaddle = AIPaddle.create()
aipaddle.x = 630
aipaddle.y = 200
aipaddle.object:sprite("art/sprites/paddle")

player_score = 0
ai_score = 0

GameEngine.playMusic("music/zelda-overworld")