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

function process_defaults(o, keep)
	if not type(o) == "table" then
		return
	end
	
	--important: do this for parents
	if (getmetatable(o) and getmetatable(o).__index) then
		process_defaults(getmetatable(o).__index, true)
	end
	
	for k, v in pairs(o) do
		if object_to_bind[k] and type(object_to_bind[k]) ~= "string" then
			--print("setting default: ", k)
			object_to_bind[k] = v
			if not keep then
				o[k] = nil
			end
		end
	end
end

function process_metatables(o)
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
		local object = rawget(t, "object")
		if type(object[k]) ~= "string" then
			if type(object[k]) == "userdata" then
				return function(self, ...)
					return object[k](object, ...)
				end
			else
				return object[k]
			end
		end
		local parentclass = rawget(t, "parentclass")
		if type(parentclass) == "table" then
			return parentclass[k]
		end
		return rawget(t, k)
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
	o.body = body_to_bind
	objects[spawn_id] = o
	
	process_metatables(o)

	if o.init then
		o:init()
	end

	return o
end

function Object:destroy()
	print("Destroying an object...")
	GameEngine.destroy(self)
end

--same as objects, now for TileMaps

TileMap = {}

function TileMap.create(original)
	local spawn_id = GameEngine.tilemap()

	local o = setmetatable({}, {})
	if original then
		o = original
	end
	print(type(o))

	process_defaults(o)

	o.object = object_to_bind
	tilemaps[spawn_id] = o
	
	process_metatables(o)

	if o.init then
		o:init()
	end

	return o
end

function TileMap:destroy()
	print("Destroying a tilemap...")
	GameEngine.destroy(self)
end

--table for GameEngine stuff
GameEngine = {}

--global collection of all game objects
--TODO: Do we really need tilemaps and objects to be separated?
objects = {}
tilemaps = {}

GameEngine.processEvent = function(event)
	for k, v in pairs(objects) do
		if objects[k][event] then
			objects[k][event](v)
		end
	end

	for k, v in pairs(tilemaps) do
		if tilemaps[k][event] then
			tilemaps[k][event](v)
		end
	end

	--debug code
	if event == "update" and keys_up.R then
		--reload the current level
		GameEngine.loadLevel(current_level)
	end
end

--These are filled by the game engine
prev_keys_held = {}
keys_held = {}

prev_gamepad_held = {}
gamepad_held = {}

mouse = {}

--These here let us do *sane things* with key polling
_key_down = function(t, k)
	return keys_held[k] and not prev_keys_held[k]
end

_gamepad_down = function(t, k)
	return keys_held[k] and not prev_keys_held[k]
end

_key_up = function(t, k)
	return prev_keys_held[k] and not keys_held[k]
end

_gamepad_up = function(t, k)
	return prev_keys_held[k] and not keys_held[k]
end

keys_down = setmetatable({}, {__index=_key_down})
gamepad_down = setmetatable({}, {__index=_gamepad_down})
keys_up = setmetatable({}, {__index=_key_up})
gamepad_up = setmetatable({}, {__index=_gamepad_up})

--this is filled by the game engine, and is used in debug mode for restarts
current_level = ""