
function inventoryClass()
	local self = {}
  
  --[[
    Gun stats are stored in global "gunList" table
    Each wave, player starts with a single pistol gun, they can pick up more guns as they go
    These temporary gun class instances are stored in inv.guns table.
  --]]
  self.selectedGun = "pistol"
  
  self.font1 = love.graphics.setNewFont('resources/shop_font2.ttf', 24)
  
	self.render = function()

    for gunName,gun in pairs(gunList) do   -- for every gun in gunList, render in gunBar down below
      
      local imagePos = {x=400 + (gun.num-1)*136, y=750}
      
      love.graphics.setColor(90, 90, 90)
      love.graphics.rectangle("fill", imagePos.x, imagePos.y, 120, 120)
      
      if (gunName == self.selectedGun) then
        love.graphics.setColor(70, 70, 70)
        love.graphics.setLineWidth(8)
      else
        love.graphics.setColor(30, 30, 30)
        love.graphics.setLineWidth(5)
      end
      love.graphics.rectangle("line", imagePos.x, imagePos.y, 120, 120)
      love.graphics.setColor(255, 255, 255)
      
      
      --local imagePos = {x=300 + gun.num*100, y=785}
        --- Render gun images ---
      if (gun.locked) then
        lockImageInv.render(imagePos.x, imagePos.y, false, 0)
      elseif (not gunList[gunName].holding) then
        love.graphics.setColor(0,0,0)
        gun.lowerImage.render(imagePos.x, imagePos.y, false, 0)
        love.graphics.setColor(255,255,255)
      else
        gun.lowerImage.render(imagePos.x, imagePos.y, false, 0)
        
        -- Render number used to select gun
        love.graphics.setFont(self.font1)
        love.graphics.print(gun.num, imagePos.x + 10, imagePos.y + 5)
        
        -- Render ammo stats on each image
        local ammoText = gunList[gunName].ammo.cur .. "|" .. gunList[gunName].ammo.backup
        love.graphics.printf(ammoText, imagePos.x, imagePos.y + 136 - 44, 136 - 22, "right")
      
      end
    end
	end
  
  self.update = function()
    
    for gunName,gun in pairs(gunList) do
      
      if love.keyboard.isDown(gun.num) and not player.reloading then
        
        if (gun.locked) then
          print("Cannot switch to a gun that is locked.")
        elseif (not gunList[gunName].holding) then
          print("Cannot switch to a gun you dont own.")
        else
          print("Switching to " .. gunName)
          inv.selectedGun = gunName
        end
      end
    end
  end
  
	return self
end

