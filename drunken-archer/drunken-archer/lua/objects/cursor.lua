
Cursor = inherits(Object)

function Cursor:init()
	self:body_type("static")
	self.active = false
end

function Cursor:update()
	self.x = mouse.x
	self.y = mouse.y
end

TileCursor = inherits(TileMap)

function TileCursor:init()
	self:body_type("static")
	self.active = false
	self:mapSize(1, 1)
end

TileCursor.offset_x = 0
TileCursor.offset_y = 0

function TileCursor:update()
	self.x = mouse.x + self.offset_x / 10.0
	self.y = mouse.y + self.offset_y / 10.0
end

function TileCursor:displayTile(index)
	self:setTile(0, 0, index, false)
end

