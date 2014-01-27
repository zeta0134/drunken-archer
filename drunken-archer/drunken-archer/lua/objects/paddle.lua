
Paddle = inherits(Object)

function Paddle:update()
	if keys.up and self.y > 0 then
		self.y = self.y - 8
	end

	if keys.down and self.y < 380 then
		self.y = self.y + 8
	end
end

AIPaddle = inherits(Object)

function AIPaddle:update()
	if ball.vx > 0 then
		if ball.y < self.y + 50 - 16 then
			self.y = self.y - 8
		end
		if ball.y > self.y + 50 - 16 then
			self.y = self.y + 8
		end
	end
end