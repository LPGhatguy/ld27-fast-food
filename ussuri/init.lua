local path = debug.getinfo(1).short_src:match("(.*/).*$"):gsub("/", ".")
local engine = require(path .. "core")

function love.run()
	engine:init()
	local engine_event = engine.event

	love.graphics.setFont(love.graphics.newFont())

    math.randomseed(os.time())
    math.random() math.random()

    engine:start(arg)

	local dt = 0
	local event, timer, graphics = love.event, love.timer, love.graphics

	while (true) do
		if (event) then
			event.pump()

			for e, a, b, c, d in event.poll() do
				if (e == "quit") then
					if (not love.quit or not love.quit()) then
						if (love.audio) then
							love.audio.stop()
						end

						engine:close()

						return
					end
				end

				love.handlers[e](a, b, c, d)
			end
		end

		if (timer) then
			timer.step()
			dt = timer.getDelta()
		end

		engine_event:fire_tick(dt)

		if (graphics) then
			graphics.clear()

			engine_event:fire_draw()
		end

		if (graphics) then
			graphics.present()
		end

		if (timer) then
			timer.sleep(0.01)
		end
	end
end

return engine