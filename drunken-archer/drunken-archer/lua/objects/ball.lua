Ball = inherits(Object)

function Ball:update()
	--"Collision"
	if self.x > 630 - 32 then
		self.x = 630 - 32
		self.vx = self.vx * -1.01

		--"collision check"
		if self.y < aipaddle.y or self.y > aipaddle.y + 100 then
			self.x = 200
			self.y = 200
			self.vx = 6
			self.vy = 6
			player_score = player_score + 1
			--print("Player Scores! So far: " .. player_score)
			GameEngine.playSound("sound/ballout")
		else 
			GameEngine.playSound("sound/paddlehit")
		end
	end

	if self.x < 10 then
		self.x = 10
		self.vx = self.vx * -1.01
		
		--"collision check"
		if self.y < paddle.y or self.y > paddle.y + 100 then
			self.x = 200
			self.y = 200
			self.vx = 6
			self.vy = 6
			ai_score = ai_score + 1
			--print("AI Scores! So far: " .. ai_score)
			GameEngine.playSound("sound/ballout")
		else
			GameEngine.playSound("sound/paddlehit")
		end
	end

	if self.y > 480 - 32 then
		self.y = 480 - 32
		self.vy = self.vy * -1.01
		GameEngine.playSound("sound/wallhit")
	end

	if self.y < 0 then
		self.y = 0
		self.vy = self.vy * -1.01
		GameEngine.playSound("sound/wallhit")
	end
end
