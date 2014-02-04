--create a box! (it should fall)

Box = inherits(Object)

function Box:update()
	--print("x: " .. box.x .. ", y: ", box.y)
	if keys_down.D then
		self.x = 10
		self.y = 10
	end
end

box = Box.create()
box:sprite("art/sprites/zero")
box.x = 10
box.y = 10
box.vx = 5

box2 = Box.create()
box2:sprite("art/sprites/zero")
box2.x = 40
box2.y = 20
box2.vx = -5