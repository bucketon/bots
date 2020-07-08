NetworkStart = {}

function NetworkStart:setup()
  local enet = require "enet"
  self.host = enet.host_create("*:6789")
end

function NetworkStart:keypressed(key)
  if key == "x" then
      pop(currentMode)
  end
end

function NetworkStart:update(dt)
  local event = self.host:service(100)
  while event do
    if event.type == "connect" then
      print(event.peer, "connected.")
      pop(currentMode)
      pop(currentMode)
      currentMode[#currentMode]:start(self.host, nil)
    end
    event = self.host:service()
  end
end

function NetworkStart:draw()    
  love.graphics.print("Now waiting for a player to join.\nThe joining player will need to "..
    "enter\nyour IP address.\n\n(You might need to forward port 6789\nin order for players to find you)", 0, 30)
  love.graphics.print("X: go back", 0, 200)
end

return NetworkStart
