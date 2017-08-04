

function escapeMenuClass()
  local self = {}

  self.isOpen = false
  self.justChanged = false
  
  self.font1 = love.graphics.setNewFont('resources/escape_font.ttf', 100)
  self.font2 = love.graphics.setNewFont('resources/escape_font.ttf', 64)
  
  self.guiRect = {x=600, y=200, w=400, h=500}
  
  self.buttons = {
    {
      text = "Back to Game", 
      onclick = function()
        self.isOpen = false
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
    
    if self.isOpen then
      -- Full screen darken
      love.graphics.setColor(0, 0, 0, 127)
      love.graphics.rectangle('fill', 0, 0, 1600, 900)
      
      -- Main background rectangle
      love.graphics.setColor(74,74,74)
      love.graphics.rectangle('fill', self.guiRect.x, self.guiRect.y, self.guiRect.w, self.guiRect.h)
      love.graphics.setColor(171, 171, 171)
      love.graphics.rectangle('line', self.guiRect.x, self.guiRect.y, self.guiRect.w, self.guiRect.h)
      love.graphics.setColor(255, 255, 255)
      
      -- Paused title
      love.graphics.setFont(self.font1)
      love.graphics.setColor(200,200,200)
      love.graphics.printf("Paused", self.guiRect.x, self.guiRect.y + 15, self.guiRect.w, "center")
      love.graphics.line( self.guiRect.x + 40, self.guiRect.y + 120, self.guiRect.x + self.guiRect.w - 40, self.guiRect.y + 120)
      
      -- Buttons
      love.graphics.setFont(self.font2)
      love.graphics.setColor(255, 255, 255)
      for i,button in ipairs(self.buttons) do
        local buttonRect = {x=self.guiRect.x, y=self.guiRect.y + 140 + (i-1)*120, w=self.guiRect.w, h=120}
        love.graphics.printf(button.text, buttonRect.x, buttonRect.y + 20, buttonRect.w, "center")
        if mouseInRect(buttonRect) then
          love.graphics.setColor(0, 0, 0, 100)
          love.graphics.rectangle("fill", buttonRect.x, buttonRect.y, buttonRect.w, buttonRect.h)
          love.graphics.setColor(255, 255, 255)
        end
      end
      
    end
    
  end
  
  self.update = function()
    
    if love.keyboard.isDown('escape') then    -- Alternates isOpen from true/false every time escape is pressed
      if not self.justChanged then
        self.isOpen = not self.isOpen
      end
      self.justChanged = true
    else
      self.justChanged = false
    end
    
    if self.isOpen and mouseClicked then
      for i,button in ipairs(self.buttons) do
        local buttonRect = {x=self.guiRect.x, y=self.guiRect.y + 140 + (i-1)*120, w=self.guiRect.w, h=120}
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
