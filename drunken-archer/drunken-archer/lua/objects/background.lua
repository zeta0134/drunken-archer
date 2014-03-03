

Background = inherits(Object)

function Background:init()
	self:sprite("cave-back")
	self:color(128,128,128,255)
	self:camera_weight(0.5, 0.0) --no y movement
	self:body_type("static")
	self:shape("none")
	self:z_index(-10) --sit behind everything
end