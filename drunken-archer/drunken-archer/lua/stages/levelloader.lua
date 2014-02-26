--note: global "level_name" is passed in by the game engine

--objects!
GameEngine.loadAllObjects()

function load_map(name)
	--note: returns the tilemap in question
	map = TileMap.create()
	input = persistence.load("lua/maps/"..name..".map")

	map:mapSize(input.width, input.height)
	for x = 0, input.width - 1 do
		for y = 0, input.height - 1 do
			map:setTile(x, y, input.map[x][y].index, input.map[x][y].solid)
		end
	end
	return map
end

function load(name)
	current_level = persistence.load("lua/levels/"..name..".data")
	

	if current_level.map then
		map = load_map(current_level.map)
		map:z_index(-1)
		map:setTiles("art/tiles/testytest")
	end

	--load up all the objects
	for k,v in pairs(current_level.objects) do
		--sanity
		if _G[v.class] then
			_G[v.class].create(v.defaults)
		else
			print("Error loading object -- bad classname: " .. v.class);
		end
	end
end