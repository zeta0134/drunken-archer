﻿--setup a default map
dofile("lua/maps/editablemap.lua")
map = EditableMap.create()
map:mapSize(50,50)
map:z_index(2)

--set up a "borders" map; this is not editable, and is there to give a visual indicator of the map edges
--(We'll do weird things with it)

borders = TileMap.create()
function borders:update()
	local cycle = (self.frames_alive % 60) * 6 --this will be from (0-359)ish
	self:color(0, 0, 128 + 32 * math.sin(math.rad(cycle)), 255)
end

borders:mapSize(52,52)
borders:setTiles("art/tiles/testytest")
borders:z_index(1)
borders.x = -1.6
borders.y = -1.6

for x = 0, 51 do
	borders:setTile(x, 0, 1, false);
	borders:setTile(x, 51, 1, false);
end

for y = 0, 51 do
	borders:setTile(0, y, 1, false);
	borders:setTile(51, y, 1, false);
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

--here, expose console commands to run the editor
current_filename = ""
function save(filename)
	filename = filename or current_filename
	persistence.store(filename, map:save())
	current_filename = filename
end

function load(filename)
	filename = filename or current_filename
	map:load(persistence.load(filename))
	current_filename = filename
end