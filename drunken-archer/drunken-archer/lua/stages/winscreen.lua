background = Object.create()
background:sprite("boring-win-screen")
background:body_type("static")

GameEngine.playMusic("menu-loop")

function stage.update()
	if keys_up.Enter or gamepad_up.Start or gamepad_up.A then
		GameEngine.playSound("press-start")
		loadstage("title")
	end
end