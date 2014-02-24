--todo: find a nice way to automate this next block (later)
dofile("lua/objects/archer.lua")
dofile("lua/objects/physicsbox.lua")

gameObjects = {}
function registerObject(c, a)
	table.insert(gameObjects, {class=c,art=a})
end

registerObject(Archer, "art/sprites/blobby")
registerObject(Arrow, "art/sprites/arrowhead")
registerObject(Box, "art/sprites/arrowhead")



current_level = {
	maps={},
	objects={}
}

