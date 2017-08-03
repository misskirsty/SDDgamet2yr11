
function shopClass()
  local self = {}
  
  self.isOpen = false
  self.clickedGun = "pistol"
  
  
  self.font1 = love.graphics.setNewFont('resources/shop_font.ttf', 70)
  self.font2 = love.graphics.setNewFont('resources/shop_font.ttf', 26)
  self.font3 = love.graphics.setNewFont('resources/shop_font2.ttf', 30)
  self.font4 = love.graphics.setNewFont('resources/shop_font2.ttf', 24)
  self.font5 = love.graphics.setNewFont('resources/shop_font.ttf', 50)
  self.font6 = love.graphics.setNewFont('resources/shop_font.ttf', 34)
  
  self.font_NextWave = love.graphics.setNewFont('resources/shop_font.ttf', 50)

  
  self.continueButton = {
    rect = {x=1080, y=650, w=370, h=100},
    onclick = function()
      self.isOpen = false
      
      waveHandler.startNextWave()
      
    end
  }
  
  
  self.render = function()
    
    --- Shop Background ---
    love.graphics.setColor(255,255,255,200)
    love.graphics.rectangle("fill", 100, 100, 1400, 700)
    love.graphics.setColor(100, 100, 100)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", 100, 100, 1400, 700)
    
    
    love.graphics.setFont(self.font1)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Wave " .. waveHandler.waveNum .. " Complete", 0, 120, 1600, "center")
    love.graphics.setColor(255,255,255)
    
    -- Next wave button
    love.graphics.setColor(111, 111, 111)
    love.graphics.rectangle("fill", self.continueButton.rect.x, self.continueButton.rect.y, self.continueButton.rect.w, self.continueButton.rect.h)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", self.continueButton.rect.x, self.continueButton.rect.y, self.continueButton.rect.w, self.continueButton.rect.h)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(self.font_NextWave)
    love.graphics.printf("Next Wave...", self.continueButton.rect.x, self.continueButton.rect.y + 25, self.continueButton.rect.w, "center")
    if mouseInRect(self.continueButton.rect) then
      love.graphics.setColor(0, 0, 0, 80)
      love.graphics.rectangle("fill", self.continueButton.rect.x, self.continueButton.rect.y, self.continueButton.rect.w, self.continueButton.rect.h)
    end
    love.graphics.setColor(255,255,255)
    
    
      --- Render Guns Images ---
    love.graphics.setFont(self.font2)
    for gunName,gun in pairs(gunList) do   -- for every gun in gunList, render in gunBar down below
      
      local imageRect = {x=170 + (gun.num-1)*210 + 25, y=250, w=160, h=160}
    
        --- Render gun image ---
      if (gun.locked) then
        love.graphics.setColor(0,0,0)
        gun.shopImage.render(imageRect.x, imageRect.y, false, 0)
        love.graphics.setColor(255,255,255)
        lockImageShop.render(imageRect.x, imageRect.y, false, 0)
      else
        gun.shopImage.render(imageRect.x, imageRect.y, false, 0)
      end
      
      --- Darker boxes on gun images ---
      if mouseInRect(imageRect) then   -- Darken gun boxes on hover
        love.graphics.setColor(0, 0, 0, 100)
        love.graphics.rectangle("fill", imageRect.x, imageRect.y, imageRect.w, imageRect.h)
        love.graphics.setColor(255, 255, 255)
      elseif gunName == self.clickedGun then   -- Darken gun box slightly on selected gun
        love.graphics.setColor(0, 0, 0, 50)
        love.graphics.rectangle("fill", imageRect.x, imageRect.y, imageRect.w, imageRect.h)
        love.graphics.setColor(255, 255, 255)
      end
      
      --- Borders around gun images ---
      if gunName == self.clickedGun then      -- Add different looking border around selected guns image
        love.graphics.setColor(100, 100, 100)
        love.graphics.setLineWidth(8)
      else
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(4)
      end
      love.graphics.rectangle("line", imageRect.x, imageRect.y, imageRect.w, imageRect.h)
      love.graphics.setColor(255, 255, 255)
      
      -- Render gun names above image
      love.graphics.setColor(0, 0, 0)
      love.graphics.printf(gun.name, imageRect.x, imageRect.y + imageRect.h + 5, imageRect.w, "center")
      love.graphics.setColor(255,255,255)

    end
    
    
      --- Render little gun specific info box ---
    love.graphics.setColor(100, 100, 100)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 180, 500, 800, 230)
    love.graphics.setColor(255, 255, 255)
    
    -- Inner stats --
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(self.font3)
    love.graphics.printf(gunList[self.clickedGun].name, 200, 520, 600, "left")
    love.graphics.setFont(self.font4)
    love.graphics.printf("Damage: " .. gunList[self.clickedGun].dmg, 200, 570, 600, "left")
    love.graphics.printf("Fire Rate: " .. gunList[self.clickedGun].speed, 200, 605, 600, "left")
    love.graphics.printf("Ammo: " .. gunList[self.clickedGun].ammo.clip .. " | " .. gunList[self.clickedGun].ammo.max, 200, 640, 600, "left")
    if (gunList[self.clickedGun].perclick) then
      love.graphics.printf("Type: Semi-automatic", 200, 675, 600, "left")
    else
      love.graphics.printf("Type: Automatic", 200, 675, 600, "left")
    end
    
    -- Coloured Locked/unlocked words --
    love.graphics.setFont(self.font5)
    if gunList[self.clickedGun].locked then
      love.graphics.setColor(255, 0, 0)
      love.graphics.printf("LOCKED", 500, 535, 430, "center")
      
      love.graphics.setFont(self.font6)
      love.graphics.printf("Unlocked at Wave " .. gunList[self.clickedGun].num, 500, 620, 430, "center")
    else
      
      love.graphics.setColor(0, 150, 0)
      love.graphics.printf("UNLOCKED", 500, 535, 430, "center")
      
      love.graphics.setFont(self.font6)
      love.graphics.printf("Kills with gun: " .. gunList[self.clickedGun].kills, 500, 620, 430, "center")
      
    end
    love.graphics.setColor(255,255,255)
    
    

	end
  
  self.update = function()
    
    if love.mouse.isDown(1) then
      
      if mouseInRect(self.continueButton.rect) then   -- Player wants to go to next wave
        self.continueButton.onclick()
        
        buttonClickSound:setVolume(1)
        buttonClickSound:stop()
        buttonClickSound:play()
        
      else
        for gunName,gun in pairs(gunList) do   -- for every gun in gunList
          local imageRect = {x=170 + (gun.num-1)*210 + 25, y=250, w=160, h=160}
          if mouseInRect(imageRect) then
            
            self.clickedGun = gunName
            
            buttonClickSound:setVolume(1)
            buttonClickSound:stop()
            buttonClickSound:play()
            
          end
        end
      end
    end
  end
  
  return self
end