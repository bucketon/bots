NetworkServer = {}

function NetworkServer:setup()
  local enet = require "enet"
  self.host = enet.host_create()
  self.host:connect("130.211.205.231:6789")
  self.connecting = true
  self.blink = 0
  self.error = ""
  self.waitingForPlayer = false
  self.serverWaitTime = 0
end

function NetworkServer:keypressed(key)
  if self.connecting and key == "x" then
    pop(currentMode)
  end
end

function NetworkServer:update(dt)
  if self.waitingForPlayer == false and self.connecting == true then
    self.serverWaitTime = self.serverWaitTime + dt
    if self.serverWaitTime > 10 then
      self.error = "Server is not responding."
    end
  end
  if frameCount % 5 == 0 then
    self.blink = self.blink + 1
    if self.blink > 3 then self.blink = 0 end
  end

  if self.connecting == true then
    local status = false
    status, event = pcall(self.host.service, self.host, 100)
    if status == false then 
      self.connecting = false
      self.error = event
    end
    while event do
      if event.type == "connect" then
        print(event.peer, "connected.")
        self.waitingForPlayer = true
      end
      if event.type == "receive" then
        print(event.peer, "sent data.")
        if event.data == "host" then
          pop(currentMode)
          pop(currentMode)
          currentMode[#currentMode]:start(self.host, nil)
        elseif event.data == "peer" then
          pop(currentMode)
          pop(currentMode)
          currentMode[#currentMode]:start(self.host, event.peer)
        end
      end
      status, event = pcall(self.host.service, self.host, 100)
    end
  end

end

function NetworkServer:draw()
  local ellipses = ""
  if self.error == "" then
    for i=0,self.blink do
      ellipses = ellipses.."."
    end
  end
  if self.waitingForPlayer == false then
    if self.error == "" then
      love.graphics.print("Connecting to server"..ellipses.."\nX: Go back", 0, 30)
    else
      love.graphics.print("Could not connect to server.\nX: Go back", 0, 30)
    end
  else
    love.graphics.print("Waiting for player"..ellipses.."\nX: Go back", 0, 30)
  end
  love.graphics.print(self.error, 0, 100)
end

return NetworkServer
