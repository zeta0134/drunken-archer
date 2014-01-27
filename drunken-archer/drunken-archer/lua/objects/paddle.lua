
Paddle = inherits(Object)

function Paddle:update()
	if keys.up and self.y > 0 then
		self.y = self.y - 5
	end

	if keys.down and self.y < 380 then
		self.y = self.y + 5
	end
end

AIPaddle = inherits(Object)

function AIPaddle:update()
	if ball.vx > 0 then
		if ball.y < self.y then
			self.y = self.y - 5
		end
		if ball.y > self.y + 100 - 32 then
			self.y = self.y + 5
		end
	end
end