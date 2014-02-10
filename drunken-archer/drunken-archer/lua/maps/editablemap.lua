

EditableMap = inherits(TileMap)

function EditableMap:init()
	self:z_index(-2)
	self:setTiles("art/tiles/testytest")
	self:mapSize(40,30)
end

function EditableMap:on_click(x, y)
	--figure out tile position based on click coordinates

end