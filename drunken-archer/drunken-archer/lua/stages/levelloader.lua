--note: global "level_name" is passed in by the game engine

--objects!
GameEngine.loadAllObjects()

--setup some things
stage.triggered = {}

current_filename = ""

current_map = {}

function load_map(name)
	print("Called load map...")
	--note: returns the tilemap in question
	map = TileMap.create()
	input = persistence.load("lua/maps/"..name..".map")

	print("loaded the map data")
	map:mapSize(input.width, input.height)
	for x = 0, input.width - 1 do
		for y = 0, input.height - 1 do
			map:setTile(x, y, input.map[x][y].index, input.map[x][y].solid)
		end
	end
	print("Successfully initialized the map")
	current_map = map
	return map
end

function load(name)
	print("Called load level")
	current_filename = name
	current_level = persistence.load("lua/levels/"..name..".data")
	
	--load up the background
	background = Background.create()

	--ok, this is DEFINITELY a hack
	background2 = Background.create()
	background2.x = -89.3
	background3 = Background.create()
	background3.x = 89.3

	if current_level.map then
		map = load_map(current_level.map)
		map:z_index(-1)
		map:setTiles("testytest")
		map:set_group("level")
	end

	loaded_objects = {}

	print("starting an object load...")
	--load up all the objects
	for k,v in pairs(current_level.objects) do
		--sanity
		if _G[v.class] then
			loaded_objects[k] = _G[v.class].create(v.defaults)
			if v.color then
				loaded_objects[k]:color(v.color.r, v.color.g, v.color.b, v.color.a)
			end
		else
			print("Error loading object -- bad classname: " .. v.class);
		end
	end
	print("Loaded all objects")
	
	if current_level.joints then
		print("starting joint processing...")
		for k,v in pairs(current_level.joints) do
			for i = 2, #v.objects do
				if loaded_objects[v.objects[i]] and loaded_objects[v.objects[1]] then
					target_id = loaded_objects[v.objects[i]].ID()
					type_string = "revolute"
					loaded_objects[v.objects[1]]:addJoint(target_id,type_string,v.x,v.y)
				else
					print("BAD JOINT: " .. k)
				end
			end
		end
	end
end

function stage.update()
	--TODO: on F12, load this level up in the editor


	if keys_up.R or gamepad_up.Back then
		--restart this level
		loadlevel(current_filename)
	end
end