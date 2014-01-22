print("Lua Started...")

--setup some object related stuff

function inherits(parent_class)
	local new_class = {}
	local new_mt = {__index=new_class}
	local base = parent_class

	if base then
		setmetatable(new_class, {__index=base})
	end
	
	function new_class.create(original)
		local o = original or {}
		if (base and base.create) then
			--call the parent class's constructor
			o = base.create(o)
		end
		setmetatable(o, new_mt)
		return o
	end

	return new_class
end

Object = {}

function Object.create(original)
	print("Attempting to spawn an object...")
	spawn_id = GameEngine.spawn() --returns the assigned object ID, which we need to keep track of

	local o = original or {}
	print("Spawned object ID:" .. spawn_id)
	o.object = object_to_bind
	objects[spawn_id] = o

	return o
end

function Object:destroy()
	print("Destroying an object...")
	GameEngine.destroy(self)
end

--table for GameEngine stuff
GameEngine = {}

--global collection of all game objects
objects = {}


GameEngine.update = function()
	for k, v in pairs(objects) do
		if objects[k].update then
			objects[k]:update()
		end
	end
end