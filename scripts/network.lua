NetworkMode = {}

function NetworkMode:setup()
  self.menu = {
        {label = "Start a Game",
        method = self.host},
        {label = "Join a Game",
        method = self.peer},
       }
  self.menuStack = {}
  self.menuIndexStack = {}
  self.menuIndex = 1
end

function NetworkMode:host()
  local enet = require "enet"
  local host = enet.host_create("localhost:6789")
  local connecting = true
  while connecting == true do --move this into update
    local event = host:service(100)
    while event do
      if event.type == "connect" then
        print(event.peer, "connected.")
        pop(currentMode)
        currentMode[#currentMode]:start(host, nil)
        connecting = false
      end
      event = host:service()
    end
  end
end

function NetworkMode:peer()
  local enet = require "enet"
  local host = enet.host_create()
  local server = host:connect("localhost:6789")
  local connecting = true
  while connecting == true do --move this into update
    local event = host:service(100)
    while event do
      if event.type == "connect" then
        print(event.peer, "connected.")
        pop(currentMode)
        currentMode[#currentMode]:start(host, event)
        connecting = false
      end
      event = host:service()
    end
  end
end

function NetworkMode:keypressed(key)
  if key == "z" then
    if self.menu[self.menuIndex].method ~= nil then
      self.menu[self.menuIndex].method(self)
    else
      push(self.menuStack, self.menu)
      push(self.menuIndexStack, self.menuIndex)
      self.menu = self.menu[self.menuIndex]
      self.menuIndex = 1
    end
  end
  if key == "x" then
    if #self.menuStack > 0 then
      self.menu = pop(self.menuStack)
      self.menuIndex = pop(self.menuIndexStack)
    else
      pop(currentMode)
    end
  end
  if key == "up" then
    self.menuIndex = math.max(1, self.menuIndex - 1)
  end
  if key == "down" then
    self.menuIndex = math.min(#self.menu, self.menuIndex + 1)
  end
end

function NetworkMode:update(dt)

end

function NetworkMode:draw()    
  local padding = 5
  local bottomMargin = 20
  local menuItemHeight = 18
  local totalMenuHeight = menuItemHeight * #self.menu + padding * (#self.menu-1)
  for i=1,#self.menu do
    local drawable = love.graphics.newText(font, formatMenuString(self.menu[i].label, self.menuIndex == i, self.menu[i].method ==  nil))
    local position = {math.floor(400/2 - drawable:getWidth()/2), 
    math.floor(240 - (totalMenuHeight + bottomMargin) + (menuItemHeight+padding)*(i-1))}
    love.graphics.draw(drawable, position[1], position[2])
  end
end

return NetworkMode
