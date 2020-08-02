DeckBuilder = {}

function DeckBuilder:setup()
  self.botList = {}
  local currentDeck = self:getCurrentDeck()

  for i=1,#AllBots do
    local entry = {}
    entry = {id=i, bot=AllBots[i]}
    push(self.botList, entry)
  end
  table.sort(self.botList, function (left, right) return left.bot.number < right.bot.number end)
  self.index = 1
  self.menu = {
    {label = "classic", method = self.setClassic},
    {label = "random", method = self.setRandom},
  }
  self.menuIndex = 0
end

function DeckBuilder:setClassic()
  local deck = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  self:setCurrentDeck(deck)
end

function DeckBuilder:setRandom()
  local map = {}
  for i=1,#self.botList do
    if map[self.botList[i].bot.number] == nil then
      map[self.botList[i].bot.number] = {}
    end
    push(map[self.botList[i].bot.number], self.botList[i].id)
  end
  local deck = {}
  for i=1,#map do
    local index = math.random(#(map[i]))
    push(deck, map[i][index])
  end
  self:setCurrentDeck(deck)
end

function DeckBuilder:getCurrentDeck()
  local deck = {}
  if saveData.deck ~= nil then
    return saveData.deck
  else
    for i=1,10 do
      push(deck, i)
    end
    saveData.deck = deck
    save(saveData)
  end
  return deck
end

function DeckBuilder:setCurrentDeck(deck)
  saveData.deck = deepCopy(deck)
  local message = "Setting Deck: "
  for i=1,#deck do
    message = message..deck[i]
  end
  log(message)
  save(saveData)
end

function DeckBuilder:keypressed(key)
  local deck = self:getCurrentDeck()

  if key == "up" then
    if self.menuIndex == 0 then
      self.index = math.max(1, self.index - 1)
    else
      self.menuIndex = math.max(1, self.menuIndex - 1)
    end
  end
  if key == "down" then
    if self.menuIndex == 0 then
      self.index = math.min(#self.botList, self.index + 1)
    else
      self.menuIndex = math.min(#self.menu, self.menuIndex + 1)
    end
  end
  if key == "right" and self.menuIndex == 0 then
    self.menuIndex = 1
  end
  if key == "left" and self.menuIndex ~= 0 then
    self.menuIndex = 0
  end
  if key == "z" then
    if self.menuIndex ~= 0 then
      self.menu[self.menuIndex].method(self)
    else
      if first(deck, self.index) == nil then
        for i=1,#deck do
          if AllBots[deck[i]].bot.number == self.botList[self.index].bot.number then
            deck[i] = self.botList[self.index].id
            self:setCurrentDeck(deck)
          end
        end
      end
    end
  end
  if key == "x" then
    pop(currentMode)
  end
end

function DeckBuilder:update(dt)

end

function DeckBuilder:draw()
  local padding = 5
  local itemHeight = 18

  local deck = self.getCurrentDeck()

  local windowSize = 10
  local firstIndex = math.min(math.max(1, self.index - windowSize/2), #self.botList - windowSize + 1)
  local lastIndex = math.min(#self.botList, firstIndex + windowSize - 1)

  drawBigCard(self.botList[self.index].bot)

  for i=firstIndex,lastIndex do
    local drawable = love.graphics.newText(font, self.botList[i].bot.number.." "..self.botList[i].bot.name)
    local position = {boardOffset[1], math.floor((itemHeight+padding)*(i-firstIndex))}
    if i == self.index and self.menuIndex == 0 then
      love.graphics.rectangle("line", position[1]-1, position[2]-1, 325-boardOffset[1]+1, 21)
    end
    love.graphics.rectangle("line", position[1], position[2], 325-boardOffset[1], 20)
    love.graphics.rectangle("line", position[1]+2, position[2]+2, 16, 16)
    if first(deck, self.botList[i].id) ~= nil then
      love.graphics.draw(checkmarkSmall, position[1]+2, position[2])
    end
    love.graphics.draw(drawable, position[1]+20, position[2])
  end

  --draw menu
  love.graphics.print("precon", 330, 0)
  for i=1,#self.menu do
    if self.menuIndex == i then
      love.graphics.rectangle("line", 328, 20*i, 398-328, 16)
    end
    love.graphics.print(self.menu[i].label, 330, 20*i)
  end
end

return DeckBuilder
