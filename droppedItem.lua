
function droppedItemClass(zombie)     -- Set chance any item will drop (maybe 1/10)
  local self = {}
  
  self.deleteMe = false   -- Set to true once item has been collected
  
  self.size = {w=120, h=120}  
  self.pos = {x=zombie.pos.x, y=900-self.size.h-260}
  
  self.vel = -100
  self.accel = 200
  
  self.hitGround = false
  self.dropTime = 0
  
  
  -- Select random ammo or gun player has unlocked
  local itemDropList = {"ammo"}
  if main.state == "tutorial" then
    itemDropList = {}
  end
  for gunName,gun in pairs(gunList) do
    
    if not gun.locked and not gun.holding then  -- Only add guns that are unlocked and player is not already holding
    
      -- Check gun does not exist in dropped item list so that two of same gun cannot exist
      local alreadyDropped = false
      for i,item in ipairs(droppedItems) do
        if (item.name == gunName) then
          alreadyDropped = true
          break
        end
      end
      
      if not alreadyDropped then     -- Add guns that are unlocked and do not already exist
        table.insert(itemDropList, gunName)
      end
      
    end
  end
  
  self.name = itemDropList[math.random(#itemDropList)]    -- Selects random item
  
  if self.name == "ammo" then
    self.image = ammoDropImage
  else
    self.image = gunList[self.name].dropImage
  end
  
  self.render = function()
    
    local yBob = math.sin(self.dropTime) * 30
    
    local crateTransparency = 255   -- Apply transparency to crate as it reaches its 15 second limit
    if self.dropTime >= 10 then
      -- Complicated formula that basicially makes crateTransparency alternate from 0-255
      crateTransparency = math.floor(255 * (math.sin((self.dropTime-10)*(self.dropTime-10)/2)+1)/2)
      if self.dropTime >= 20 and main.state ~= "tutorial" then
        self.deleteMe = true
      end
    end
    love.graphics.setColor(255, 255, 255, crateTransparency)
    
    crateDropImage.render(self.pos.x, self.pos.y + yBob, false, 0)
    self.image.render(self.pos.x + 18, self.pos.y + 25 + yBob, false, 0)
    
    love.graphics.setColor(255, 255, 255)
  end
  
  self.update = function(dt)

    if not self.hitGround then    -- Apply velocity/acceleration if item has not hit ground yet
      self.pos.y = self.pos.y + self.vel*dt
      self.vel = self.vel + self.accel*dt
      
      if self.pos.y >= (800-self.size.h-100) then   -- If item reaches ground
        self.pos.y = 800-self.size.h-100
        self.hitGround = true
      end
    else    -- Otherwise apply sin wave to position

      self.dropTime = self.dropTime + dt    -- Bobbing animation if item has hit the ground
      
    end
    
    -- Allow player to collect item
    if (self.pos.x + self.size.w > player.pos.x + player.collisionBody.x) then    -- Right side of item is larger than left side of player
      if (self.pos.x < player.pos.x + player.collisionBody.x + player.collisionBody.w) then   -- Left side of item is less than than right side of player
        
        if self.name == "ammo" then
          
          gunList[inv.selectedGun].ammo.cur = gunList[inv.selectedGun].ammo.clip
          gunList[inv.selectedGun].ammo.backup = gunList[inv.selectedGun].ammo.max
          
          
          self.deleteMe = true
        
        else    -- Item type is gun
          
          gunList[self.name].holding = true
          self.deleteMe = true
          
        end
        
          -- Play crate pickup sound
        cratePickupSound:setVolume(1)
        cratePickupSound:stop()
        cratePickupSound:play()
        
      end
    end
  end
  
  return self
end