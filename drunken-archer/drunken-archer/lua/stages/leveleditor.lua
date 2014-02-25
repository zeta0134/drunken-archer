--todo: find a nice way to automate this next block (later)
dofile("lua/objects/archer.lua")
dofile("lua/objects/physicsbox.lua")

gameObjects = {}
function registerObject(c, a)
	table.insert(gameObjects, {class=c,art=a})
end

registerObject(Archer, "art/sprites/blobby")
registerObject(Arrow, "art/sprites/arrowhead")
registerObject(Box, "art/sprites/triangle")

insert_index = 1
current_level = {
	maps={},
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

selected_object = 1
placeholders = {}
function select_object(index)
	placeholders[selected_object]:color(255, 255, 255, 128)
	selected_object = index
	placeholders[index]:color(255, 255, 255, 255)
end

Placeholder = inherits(Object)

function Placeholder:init()
	self:body_type("static")
	self.active = false
end

function Placeholder:right_click()
	select_object(self.index)
	print("got right click!")
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