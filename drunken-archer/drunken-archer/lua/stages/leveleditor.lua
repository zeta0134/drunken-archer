--todo: find a nice way to automate this next block (later)

GameEngine.loadAllObjects()

gameObjects = {}
function registerObject(c, a)
	table.insert(gameObjects, {class=c,art=a})
end

for k,v in pairs(registered_objects) do
	registerObject(k,v)
end

insert_index = 1
current_level = {
	objects={},
	joints={}
}

--objects to make the editor work

dofile("lua/objects/cursor.lua")
selector = Cursor.create()
selector.current_index = 1
selector:z_index(100) --no, really, in front of everything
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
function select_object(index, type)
	type = type or "object"
	if type == "object" then
		if selected_object then
			placeholders[selected_object]:color(255, 255, 255, 128)
			if current_level.objects[selected_object].color then
				placeholders[selected_object]:color(current_level.objects[selected_object].color.r, current_level.objects[selected_object].color.g, current_level.objects[selected_object].color.b, 128)
			end
		end
		selected_object = index
		property = current_level.objects[selected_object].defaults
		placeholders[index]:color(255, 255, 255, 255)
		if current_level.objects[index].color then
			placeholders[index]:color(current_level.objects[index].color.r, current_level.objects[index].color.g, current_level.objects[index].color.b, 255)
		end
	end

end

Placeholder = inherits(Object)

function Placeholder:init()
	self:body_type("static")
	self.active = false
end

function Placeholder:right_click()
	select_object(self.index, self.type)
	--print("got right click!")
end

function Placeholder:on_click()
	if mode == "joint" then
		table.insert(joint_queue, self.index)
		print("added " .. self.index .. " to queue")
	end
end

mode = "object"

joint_queue = {}

function stage.on_click(mx, my)
	if mode == "object" then
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
	if mode == "joint" then
		if #joint_queue > 1 then
			table.insert(current_level.joints, {objects=joint_queue,x=mx,y=my})
			print("Joint created!")
			--todo: add a placeholder for joints, so they can be selected and manipulated / destroyed

			joint_placeholder = Placeholder.create()
			joint_placeholder.index = "42" --todo: bad! store this!
			joint_placeholder:sprite("joint_marker")
			joint_placeholder.x = mx
			joint_placeholder.y = my
			joint_placeholder.type = "joint"
			joint_placeholder:z_index("3") --always on top
		else
			print("Could not add joint; not enough objects selected")
			print("Queue size: " .. #joint_queue)
		end
		joint_queue = {}
	end
end

function stage.update()
	--do a thing
	if keys_down.O then 
		mode = "object"
		selector:sprite(gameObjects[selector.current_index].art)
		selector:color(255,255,255,255)
	end
	if keys_down.J then 
		mode = "joint"
		selector:sprite("plain_cursor")
		selector:color(255,255,0,255)
	end
end

current_map = TileMap.create()
current_map:mapSize(1,1)
current_map:z_index(-1) --behind everything
current_map:setTiles("testytest")
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

function color(red, green, blue, alpha)
	if selected_object then
		current_level.objects[selected_object].color = {r=red,g=green,b=blue,a=alpha}
		placeholders[selected_object]:color(red,green,blue,255)
	else
		print("No object selected!")
	end
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
	if not current_level.joints then current_level.joints = {} end
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

	--populate the placeholders for objects
	selected_object = nil
	insert_index = 1
	for k,v in pairs(current_level.objects) do
		placeholders[k] = Placeholder.create()
		placeholders[k].index = k
		placeholders[k]:sprite(gameObjects[objectByName(v.class)].art)
		placeholders[k].x = v.defaults.x
		placeholders[k].y = v.defaults.y
		placeholders[k]:color(255,255,255,128)
		if v.color then
			placeholders[k]:color(v.color.r,v.color.g,v.color.b,128)
		end
		if k >= insert_index then
			insert_index = k + 1
		end
	end

	--populate the placeholders for joints
	for k,v in pairs(current_level.joints) do
		joint_placeholder = Placeholder.create()
		joint_placeholder.index = "42" --todo: bad! store this!
		joint_placeholder:sprite("joint_marker")
		joint_placeholder.x = v.x
		joint_placeholder.y = v.y
		joint_placeholder.type = "joint"
		joint_placeholder:z_index("3") --always on top
	end
end