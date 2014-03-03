background = Object.create()
background:sprite("title")
background:body_type("static")

GameEngine.playMusic("menu-loop")

function stage.update()
	if keys_up.Enter or gamepad_up.Start or gamepad_up.A  then
		GameEngine.playSound("press-start")
		loadlevel("wb-1")
	end
end