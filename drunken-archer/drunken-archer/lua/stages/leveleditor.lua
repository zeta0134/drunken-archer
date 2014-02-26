--todo: find a nice way to automate this next block (later)

GameEngine.loadAllObjects()

gameObjects = {}
function registerObject(c, a)
	table.insert(gameObjects, {class=c,art=a})
end

--registerObject("Archer", "art/sprites/blobby")
--registerObject("Arrow", "art/sprites/arrowhead")
--registerObject("Box", "art/sprites/triangle")

for k,v in pairs(registered_objects) do
	registerObject(k,v)
end

insert_index = 1
current_level = {
	objects={}
}

current_filename = ""
function save(filename)
	
end

--objects to make the editor work

dofile("lua/objects/cursor.lua")
selector = Cursor.create()
selector.current_index = 1
selector:sprite(gameObjects[selector.current_index].art)

function selector:scroll_up()
	if self.current_index > 1 then
		self.current_index = self.current_index - 1
		self:sprite(gameObjects[self.current_index].art)
	end
end

function selector:scroll_down()
	if self.current_index < #gameObjects then
		self.current_index = self.current_index + 1
		self:sprite(gameObjects[self.current_index].art)
	end
end

selected_object = nil
property = nil --global for console editing
placeholders = {}
function select_object(index)
	if selected_object then
		placeholders[selected_object]:color(255, 255, 255, 128)
	end
	selected_object = index
	property = current_level.objects[selected_object].defaults
	placeholders[index]:color(255, 255, 255, 255)
end

Placeholder = inherits(Object)

function Placeholder:init()
	self:body_type("static")
	self.active = false
end

function Placeholder:right_click()
	select_object(self.index)
	--print("got right click!")
end

function stage.on_click(mx, my)
	current_level.objects[insert_index] = {
		class=gameObjects[selector.current_index].class,
		defaults={
			x=mx,
			y=my
		}
	}
	placeholders[insert_index] = Placeholder.create()
	placeholders[insert_index].index = insert_index
	placeholders[insert_index]:sprite(gameObjects[selector.current_index].art)
	placeholders[insert_index].x = mx
	placeholders[insert_index].y = my
	placeholders[insert_index]:color(255,255,255,128)

	insert_index = insert_index + 1
end

current_map = TileMap.create()
current_map:mapSize(1,1)
current_map:z_index(-1) --behind everything
current_map:setTiles("art/tiles/testytest")
current_map.debug = true

function current_map:load(input)
	self:mapSize(input.width, input.height)
	for x = 0, input.width - 1 do
		for y = 0, input.height - 1 do
			self:setTile(x, y, input.map[x][y].index, input.map[x][y].solid)
		end
	end
end

function map(name)
	current_map:load(persistence.load("lua/maps/"..name..".map"))
	current_level.map = name
end

--WASD camera, for moving around the level and stuff
dofile("lua/objects/WASDcamera.lua")
camera = WASDcamera.create()

--save/load functions for the level
current_filename = ""
function save(filename)
	filename = filename or current_filename
	persistence.store("lua/levels/"..filename..".data", current_level)
	if debug then
		persistence.store(debugpath.."lua/levels/"..filename..".data", current_level)
	end
	current_filename = filename
end

function objectByName(classname)
	for k,v in pairs(gameObjects) do
		if v.class == classname then
			return k
		end
	end
end

function load(filename)
	filename = filename or current_filename
	current_level = persistence.load("lua/levels/"..filename..".data")
	current_filename = filename

	--clear out the level state
	for k,v in pairs(placeholders) do
		v:destroy()
	end
	placeholders = {}
	selected_object = nil
	property = nil

	--load the map from the file specified
	if current_level.map then
		map(current_level.map)
		print("Loading a map!")
	else
		map:mapSize(1,1) --this will clear out the map on load if the level has none
		print("no map..." .. current_level.map)
	end

	--populate the placeholders
	selected_object = nil
	insert_index = 1
	for k,v in pairs(current_level.objects) do
		placeholders[k] = Placeholder.create()
		placeholders[k].index = k
		placeholders[k]:sprite(gameObjects[objectByName(v.class)].art)
		placeholders[k].x = v.defaults.x
		placeholders[k].y = v.defaults.y
		placeholders[k]:color(255,255,255,128)
		if k >= insert_index then
			insert_index = k + 1
		end
	end

end