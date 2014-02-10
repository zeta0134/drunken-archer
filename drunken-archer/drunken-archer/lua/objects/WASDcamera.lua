--this is a simple camera for debugging; using the WASD keys
--will move this camera around the stage.

WASDcamera = inherits(Object)
WASDcamera.moveSpeed = 5 --sensible default, in pixels per frame

function WASDcamera:init()
	self:body_type("static")
end

function WASDcamera:update()
	if keys_held.W then
		self.y = self.y - self.moveSpeed
	end
	if keys_held.S then
		self.y = self.y + self.moveSpeed
	end
	if keys_held.D then
		self.x = self.x + self.moveSpeed
	end
	if keys_held.A then
		self.x = self.x - self.moveSpeed
	end

	--actually update the game camera based on this object's position
	GameEngine.setCamera(self.x, self.y)
end

