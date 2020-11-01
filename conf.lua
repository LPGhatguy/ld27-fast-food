function love.conf(t)
	t.title = ":Fast :Food - Ludum Dare #27 Jam"
	t.author = "Cassassin-LPGhatguy"
	t.url = "https://lpghatguy.com/"

	t.identity = "ld-ff"
	t.version = "0.8.0"
	t.console = false
	t.release = true

	t.screen.width = 100
	t.screen.height = 100
	t.screen.fullscreen = false
	t.screen.vsync = true
	t.screen.fsaa = 0

	t.modules.joystick = true
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.physics = true
end