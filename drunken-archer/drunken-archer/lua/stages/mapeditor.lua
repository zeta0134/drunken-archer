--setup a default map
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

borders:setTiles("testytest")
borders:z_index(1)
borders.x = -1.6
borders.y = -1.6

function setBorders()
	border_tile = 4
	borders:mapSize(map.width + 2, map.height + 2)
	for x = 0, map.width + 1 do
		borders:setTile(x, 0, border_tile, false);
		borders:setTile(x, map.height + 1, border_tile, false);
	end

	for y = 0, map.height + 1 do
		borders:setTile(0, y, border_tile, false);
		borders:setTile(map.width + 1, y, border_tile, false);
	end
end

setBorders()

--add a camera
dofile("lua/objects/WASDcamera.lua")
camera = WASDcamera.create()

--add a nice mouse cursor
dofile("lua/objects/cursor.lua")
cursor = Cursor.create()
cursor:z_index(10)
cursor:sprite("mousecursor")

selector = TileCursor.create()
selector:z_index(11)
selector:setTiles("testytest")
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
		cursor:sprite("mousecursor")
	else
		cursor:sprite("mousecursor_empty")
	end
end

--here, expose console commands to run the editor
current_filename = ""
function save(filename)
	filename = filename or current_filename
	persistence.store("lua/maps/"..filename..".map", map:save())
	if debug then
		persistence.store(debugpath.."lua/maps/"..filename..".map", map:save())
	end
	current_filename = filename
end

function load(filename)
	filename = filename or current_filename
	map:load(persistence.load("lua/maps/"..filename..".map"))
	current_filename = filename
	setBorders()
end

function resize(w, h)
	map:resizeMap(w, h)
	setBorders()
end

function clearmap(tile, solid)
	tile = tile or 0
	solid = solid or false
	for x = 0, map.width - 1 do
		for y = 0, map.height - 1 do
			map:setTile(x, y, tile, solid)
		end
	end
end

function stage.on_click()
	--cheat
	map:on_click()
end