print("Lua Started...")

--Object Inheretance; handles derived classes in a cleanish manner
function inherits(parent_class)
	local new_class = {}
	local base = parent_class

	if base then
		setmetatable(new_class, {__index=base})
	end
	
	function new_class.create(original)
		local o = original or {}
		local new_mt = {__index=new_class}
		setmetatable(o, new_mt)
		if (base and base.create) then
			--call the parent class's constructor
			o = base.create(o)
		end
		return o
	end

	return new_class
end

Object = {}

function process_defaults(o)
	if not type(o) == "table" then
		return
	end
	
	--important: do this for parents
	if (getmetatable(o)) then
		process_defaults(getmetatable(o).__index)
	end
	
	for k, v in pairs(o) do
		if object_to_bind[k] and type(object_to_bind[k]) ~= "string" then
			--print("setting default: ", k)
			object_to_bind[k] = v
		end
	end
	
end

function Object.create(original)
	--print("Spawning an object with parent: ", getmetatable(original).__index)

	local spawn_id = GameEngine.spawn() --returns the assigned object ID, which we need to keep track of

	local o = original or {}
	--print("Spawned object ID:" .. spawn_id)

	--set defaults; any keys that exist in the C# class will be set from their values in the original
	--object
	process_defaults(o)

	o.object = object_to_bind
	objects[spawn_id] = o
	
	--attempt fun things!
	local mt = getmetatable(o)
	mt.__newindex = function(t, k, v)
		if k ~= "object" and t.object and type(t.object[k]) ~= "string" then
			t.object[k] = v
		else
			--print("New index: ", k)
			rawset(t, k, v)
		end
	end

	--weird things now
	o.parentclass = mt.__index
	mt.__index = function(t, k)
		if rawget(t, k) then
			return rawget(t, k)
		end
		local object = rawget(t, "object")
		if object and object[k] and type(object[k]) ~= "string" then
			return object[k]
		end
		local parentclass = rawget(t, "parentclass")
		if type(parentclass) == "table" then
			return parentclass[k]
		else
			--print(type(parentclass))
		end
		return nil
	end

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