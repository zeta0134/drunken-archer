

EditableMap = inherits(TileMap)

function EditableMap:init()
	self:z_index(-2)
	self:setTiles("art/tiles/testytest")
	self.debug = true
end

function EditableMap:save()
	output = {}
	output.width = self.width
	output.height = self.height
	output.map = {}
	for x = 0, self.width - 1 do
		output.map[x] = {}
		for y = 0, self.height - 1 do
			output.map[x][y] = {index=self:getTile(x, y),solid=self:isSolid(x, y)}
		end
	end
	return output
end

function EditableMap:load(input)
	--note: input should be in the same format as save() returns
	--any other objects will exhibit undefined behavior

	self:mapSize(input.width, input.height)
	for x = 0, input.width - 1 do
		for y = 0, input.height - 1 do
			self:setTile(x, y, input.map[x][y].index, input.map[x][y].solid)
		end
	end
end

function EditableMap:on_click()
	--adjust mouse for self position
	x = mouse.x - self.x
	y = mouse.y - self.y

	--note: camera coordinates are automatically handled by the game engine
	--camera WEIGHT is not; keep this in mind

	--convert mouse coordinates into tile coordinates
	x = x * 10.0 / self.tile_width
	y = y * 10.0 / self.tile_height

	--floor to get an integer value
	x = math.floor(x)
	y = math.floor(y)

	if x >= 0 and x < self.width and y >= 0 and y < self.height then
		self:setTile(x, y, selector.index, selector.solid)
	end
end

function EditableMap:update()
	--adjust mouse for self position
	x = mouse.x - self.x
	y = mouse.y - self.y

	--convert mouse coordinates into tile coordinates
	x = x * 10.0 / self.tile_width
	y = y * 10.0 / self.tile_height

	--floor to get an integer value
	x = math.floor(x)
	y = math.floor(y)

	if x >= 0 and x < self.width and y >= 0 and y < self.height then
		self.highlight_x = x
		self.highlight_y = y
	else
		self.highlight_x = -1
		self.highlight_y = -1
	end
end