NetworkJoin = {}

function NetworkJoin:setup()
  local enet = require "enet"
  self.host = enet.host_create()
  self.connecting = false
  self.IP = ""
  self.blink = false
  self.error = nil
end

function NetworkJoin:keypressed(key)
  local utf8 = require("utf8")
  if self.connecting and key == "x" then
    pop(currentMode)
  end
  if key == "return" then
    if self.IP ~= "" then
      self.host:connect(self.IP..":6789")
      self.connecting = true
    end
  end
  if key == "backspace" then
    local byteoffset = utf8.offset(self.IP, -1)
    if byteoffset then
        self.IP = string.sub(self.IP, 1, byteoffset - 1)
    end
  end
end

function NetworkJoin:textinput(text)
  text = self:filter(text)
  self.IP = self.IP..text
end

function NetworkJoin:filter(text)
  --remove anything that isn't a . or a number
  text = text:gsub('[^%d%.]', '')
  return text
end

function NetworkJoin:update(dt)
  if frameCount % 25 == 0 then
    self.blink = not self.blink
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
        pop(currentMode)
        pop(currentMode)
        currentMode[#currentMode]:start(self.host, event.peer)
      end
      status, event = pcall(self.host.service, self.host, 100)
    end
  end
end

function NetworkJoin:draw()
  local cursor = ""
  if self.blink == true and self.connecting == false then cursor = "_" end
  love.graphics.print("Connect to: "..self.IP..cursor.."\n(Press enter once the other player\nhas started the game)", 0, 30)
  if self.error ~= nil then
    love.graphics.print(self.error, 0, 100)
  end
  if self.connecting then
    love.graphics.print("X: go back", 0, 200)
  end
end

return NetworkJoin
