DeckBuilder = {}

function DeckBuilder:setup()
  self.botList = {}
  local currentDeck = self:getCurrentDeck()

  for i=1,#AllBots do
    local entry = {}
    entry = AllBots[i]
    push(self.botList, entry)
  end
  self.index = 1
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
    self.index = math.max(1, self.index - 1)
  end
  if key == "down" then
    self.index = math.min(#self.botList, self.index + 1)
  end
  if key == "z" then
    if first(deck, self.index) == nil then
      for i=1,#deck do
        if self.botList[deck[i]].number == self.botList[self.index].number then
          deck[i] = self.index
          self:setCurrentDeck(deck)
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

  love.graphics.draw(self.botList[self.index].image, 0, 0)

  for i=firstIndex,lastIndex do
    local drawable = love.graphics.newText(font, self.botList[i].number.." "..self.botList[i].name)
    local position = {boardOffset[1], math.floor((itemHeight+padding)*(i-firstIndex))}
    if i == self.index then
      love.graphics.rectangle("line", position[1]-1, position[2]-1, 400-boardOffset[1]+1, 21)
    end
    love.graphics.rectangle("line", position[1], position[2], 400-boardOffset[1], 20)
    love.graphics.rectangle("line", position[1]+2, position[2]+2, 16, 16)
    if first(deck, i) ~= nil then
      love.graphics.draw(checkmarkSmall, position[1]+2, position[2])
    end
    love.graphics.draw(drawable, position[1]+20, position[2])
  end
end

return DeckBuilder
