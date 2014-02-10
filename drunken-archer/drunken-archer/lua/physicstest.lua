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

	if keys_down.F3 then
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
dofile("lua/maps/editablemap.lua")
map = EditableMap.create()

--edges
for x = 1, 38 do
	map:setTile(x, 0, 2, false)
	map:setTile(x, 29, 14, false)
end

for y = 1, 28 do
	map:setTile(0, y, 7, false)
	map:setTile(39, y, 9, false)
end

--fill
for y = 1, 28 do
	for x = 1, 38 do
		map:setTile(x, y, 8, false)
	end
end

--corners
map:setTile(0,0,1, false)
map:setTile(0,29,13, false)
map:setTile(39,0,3, false)
map:setTile(39,29,15, false)

--weird stuff!

for x = 12, 27 do
	map:setTile(x, 19, 4, true)
end

--add a camera
dofile("lua/objects/WASDcamera.lua")
camera = WASDcamera.create()

--add a nice mouse cursor
dofile("lua/objects/cursor.lua")
cursor = Cursor.create()
cursor:z_index(10)
cursor:sprite("art/sprites/mousecursor")

selector = TileCursor.create()
selector:z_index(11)
selector:setTiles("art/tiles/testytest")
selector:displayTile(1)
selector.offset_x = 8
selector.offset_y = 7

selector.index = 1
selector.max_index = 16
selector.solid = true

function selector:scroll_up()
	if self.index > 0 then
		self.index = self.index - 1
		self:displayTile(self.index)
	end
end

function selector:scroll_down()
	if self.index < self.max_index then
		self.index = self.index + 1
		self:displayTile(self.index)
	end
end

function selector:scroll_click()
	selector.solid = not selector.solid
	if selector.solid then
		cursor:sprite("art/sprites/mousecursor")
	else
		cursor:sprite("art/sprites/mousecursor_empty")
	end
end