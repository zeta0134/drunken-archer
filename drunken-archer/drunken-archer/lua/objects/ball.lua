
Ball = inherits(Object)

function Ball:update()

	--"Collision"
	if self.x > 630 - 32 then
		self.x = 630 - 32
		self.vx = self.vx * -1.01

		--"collision check"
		if self.y < aipaddle.y or self.y > aipaddle.y + 100 then
			 ball.x = 200
			 ball.y = 200
			 ball.vx = 6
			 ball.vy = 6
			 player_score = player_score + 1
			 print("Player Scores! So far: " .. player_score)
		end
	end

	if self.x < 10 then
		self.x = 10
		self.vx = self.vx * -1.01
		
		--"collision check"
		if self.y < paddle.y or self.y > paddle.y + 100 then
			ball.x = 200
			ball.y = 200
			ball.vx = 6
			ball.vy = 6
			ai_score = ai_score + 1
			print("AI Scores! So far: " .. ai_score)
			
		end
	end

	if self.y > 480 - 32 then
		self.y = 480 - 32
		self.vy = self.vy * -1.01
	end

	if self.y < 0 then
		self.y = 0
		self.vy = self.vy * -1.01
	end
end
