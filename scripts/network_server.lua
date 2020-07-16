NetworkJoin = {}

function NetworkJoin:setup()
  local enet = require "enet"
  self.host = enet.host_create()
  self.host:connect("130.211.205.231:6789")
  self.connecting = true
  self.blink = 0
  self.error = nil
end

function NetworkJoin:keypressed(key)
  if self.connecting and key == "x" then
    pop(currentMode)
  end
end

function NetworkJoin:update(dt)
  if frameCount % 25 == 0 then
    self.blink = self.blink + 1
    if self.blink > 3 then self.blink = 0 end
  end

  if self.connecting == true then
    local status = false
    self.error = ""
    status, event = pcall(self.host.service, self.host, 100)
    if status == false then 
      self.connecting = false
      self.error = event
    end
    while event do
      if event.type == "connect" then
        print(event.peer, "connected.")
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

function NetworkJoin:draw()
  local ellipses = ""
  for i=0,self.blink do
    ellipses = ellipses.."."
  end
  love.graphics.print("Connecting to server"..ellipses.."\nX: Go back", 0, 30)
end

return NetworkJoin