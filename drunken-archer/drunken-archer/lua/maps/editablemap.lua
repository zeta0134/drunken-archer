

EditableMap = inherits(TileMap)

function EditableMap:init()
	self:z_index(-2)
	self:setTiles("art/tiles/testytest")
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