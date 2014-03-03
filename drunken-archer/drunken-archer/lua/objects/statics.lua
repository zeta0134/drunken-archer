ExitSign = inherits(Object)
function ExitSign:init()
	self:sprite("exitsign")
end
registered_objects["ExitSign"] = "exitsign"

SignPole = inherits(Object)
function SignPole:init()
	self:sprite("signpole")
	self:body_type("static")
end
registered_objects["SignPole"] = "signpole"

SignHook = inherits(Object)
function SignHook:init()
	self:sprite("signhook")
end
registered_objects["SignHook"] = "signhook"