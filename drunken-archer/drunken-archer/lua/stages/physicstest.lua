GameEngine.playMusic("music/game-loop")

dofile("lua/objects/physicsbox.lua")
dofile("lua/objects/archer.lua")

--create a box! (it should fall)
player = Archer.create()
player.x = 10
player.y = 10

for i = 1, 5 do
	paddle = Box.create()
	paddle:sprite("art/sprites/paddle")
	paddle.x = math.random(1, 30)
	paddle.y = math.random(3, 15)
end

for i = 1, 5 do
	triangle = Box.create()
	triangle:sprite("art/sprites/triangle")
	triangle.x = math.random(1, 30)
	triangle.y = math.random(3, 15)
end



--try out some interesting things
dofile("lua/maps/editablemap.lua")
map = EditableMap.create()
map:mapSize(40,21)
map.y = 24 / 10.0

--edges
for x = 1, 38 do
	map:setTile(x, 0, 4, true)
	map:setTile(x, 20, 4, true)
end

for y = 1, 19 do
	map:setTile(0, y, 4, true)
	map:setTile(39, y, 4, true)
end

--fill
for y = 1, 19 do
	for x = 1, 38 do
		map:setTile(x, y, 8, false)
	end
end

--corners
map:setTile(0,0,4, true)
map:setTile(0,20,4, true)
map:setTile(39,0,4, true)
map:setTile(39,20,4, true)

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
selector.activeMap = map
selector.solid = true

function selector:scroll_up()
	if self.index > 0 then
		self.index = self.index - 1
		self:displayTile(self.index)
	end
end

function selector:scroll_down()
	if self.index < self.activeMap:maxIndex() then
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

--fun things!
function stage:update()
	if keys_down.F5 then
		persistence.store("lua/levels/test.level", map:save())
	end
	if keys_down.F6 then
		map:load(persistence.load("lua/levels/test.level"))
	end
end