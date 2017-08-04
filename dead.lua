

function deadClass()    -- Class displayed when player is dead
  local self = {}
  
  self.font1 = love.graphics.setNewFont('resources/escape_font.ttf', 100)
  self.font2 = love.graphics.setNewFont('resources/escape_font.ttf', 80)
  
  self.guiRect = {x=300, y=50, w=1000, h=700}
  
  self.buttons = {
    {
      text = "Restart", 
      onclick = function()
        waveHandler.restartGame()
      end
    },
    {
      text = "Main Menu",
      onclick = function()
        self.isOpen = false
        main.state = "main"
      end
    },
    {
      text = "Quit Game",
      onclick = function()
        love.event.quit()
      end
    }
  }
  
  self.render = function()

    -- Full screen darken
    love.graphics.setColor(0, 0, 0, 127)
    love.graphics.rectangle('fill', 0, 0, 1600, 900)
    
    -- Main background rectangle
    love.graphics.setColor(74, 74, 74, 150)
    love.graphics.rectangle('fill', self.guiRect.x, self.guiRect.y, self.guiRect.w, self.guiRect.h)
    love.graphics.setColor(171, 171, 171)
    love.graphics.rectangle('line', self.guiRect.x, self.guiRect.y, self.guiRect.w, self.guiRect.h)
    love.graphics.setColor(255, 255, 255)
    
    -- Paused title
    love.graphics.setFont(self.font1)
    love.graphics.setColor(200,200,200)
    love.graphics.printf("THE ZOMBIES ATE YOUR BRAINS!!!", self.guiRect.x, self.guiRect.y + 15, self.guiRect.w, "center")
    love.graphics.line( self.guiRect.x + 40, self.guiRect.y + 220, self.guiRect.x + self.guiRect.w - 40, self.guiRect.y + 220)
    
    -- Buttons
    love.graphics.setFont(self.font2)
    love.graphics.setColor(255, 255, 255)
    for i,button in ipairs(self.buttons) do
      local buttonRect = {x=self.guiRect.x, y=self.guiRect.y + 250 + (i-1)*150, w=self.guiRect.w, h=150}
      love.graphics.printf(button.text, buttonRect.x, buttonRect.y + 25, buttonRect.w, "center")
      if mouseInRect(buttonRect) then
        love.graphics.setColor(0, 0, 0, 100)
        love.graphics.rectangle("fill", buttonRect.x, buttonRect.y, buttonRect.w, buttonRect.h)
        love.graphics.setColor(255, 255, 255)
      end
    end

    
  end
  
  self.update = function()
    
    if mouseClicked then
      for i,button in ipairs(self.buttons) do
        local buttonRect = {x=self.guiRect.x, y=self.guiRect.y + 240 + (i-1)*150, w=self.guiRect.w, h=150}
        if mouseInRect(buttonRect) then
          button.onclick()
          mouseClicked = false
          buttonClickSound:setVolume(1)
          buttonClickSound:stop()
          buttonClickSound:play()
          break
        end
      end
    end
    
  end
  
  return self
end
