
function waveClass()   -- handles waves
	local self = {}
  
  self.font1 = love.graphics.setNewFont('resources/wave_font.ttf', 200)
  
  self.waveNum = 0
  self.startTime = 5   -- Time needed to wait before any zombie start spawning
  self.zombieSpawnTime = self.startTime
  
  self.waveInfo = {
      count = nil, 
      spawnTime = nil
  }

  self.waveTime = 0   -- Time in seconds wave has been going for
  
  self.textFadeIn = 2
  self.textFadeOut = 1
  
  self.waveStartSound = love.audio.newSource("resources/sound/wave_start.ogg", "static")
  self.waveEndSound = love.audio.newSource("resources/sound/wave_end.ogg", "static")

  
  self.restartGame = function()
    
    main.state = "game"
    
    player.health.cur = player.health.max
    player.pos.x = 800-player.size.w/2
    player.shotCooldown = 0
    player.flashCooldown = 0
    player.reloadCooldown = 0
    
    inv.selectedGun = "pistol"
    
    shop.isOpen = false
    shop.clickedGun = "pistol"
    
    for gunName,gun in pairs(gunList) do
      gun.ammo.cur = gun.ammo.clip
      gun.ammo.backup = gun.ammo.max
      gun.kills = 0
      if gunName ~= "pistol" then
        gun.locked = true
        gun.holding = false
      end
    end
    
    
    zombieList = {}
    droppedItems = {}	
    coins = {}
    
    self.waveNum = 0
    self.startNextWave()
    
  end
  
  self.startNextWave = function()
    
    player.health.cur = player.health.max

    -- Play wave starting sound
    self.waveStartSound:setVolume(0.2)
    self.waveStartSound:stop()
    self.waveStartSound:play()


    self.waveNum = self.waveNum + 1
    self.zombieSpawnTime = self.startTime
    self.waveTime = 0
    
    self.waveInfo.count = 10 * self.waveNum
    self.waveInfo.spawnTime = 2 - (0.1 * self.waveNum)
    if self.waveInfo.spawnTime < 0.5 then
      self.waveInfo.spawnTime = 0.5
    end
    
  end
    
  self.endWave = function()   -- Run at end of wave
    
    -- Play wave ending sounds
    self.waveEndSound:setVolume(0.2)
    self.waveEndSound:stop()
    self.waveEndSound:play()
        
    -- Open the shop
    shop.isOpen = true
    shop.clickedGun = "pistol"
    
    
    -- Reset all guns, temporary maybe
    inv.selectedGun = "pistol"
    for gunName,gun in pairs(gunList) do
      if gunName ~= "pistol" then   -- Reset gun stats for every gun except pistol
        gun.holding = false
        gun.ammo.cur = gun.ammo.clip
        gun.ammo.backup = gun.ammo.max
      end
    end
    
    -- Delete all items, temporary maybe
    droppedItems = {}
    
    
        
    -- Unlock any guns that should be allowed
    for gunName,gun in pairs(gunList) do
      if gun.num == self.waveNum then
        gun.locked = false
      end
    end
    
  end

  self.update = function(dt)    -- Runs every frame, spawns zombies when it should happen
    
    self.waveTime = self.waveTime + dt
      
    if (self.waveInfo.count == 0) then -- If enough zombies have been spawned in wave
      if (#zombieList == 0) then
        
        self.endWave()    -- Wave is over when all zombies have been killed
        
      end
    else  -- Start spawning zombies
    
      if self.zombieSpawnTime <= 0 then   -- Spawns a zombie if zombie spawn time has ran out
        
        self.zombieSpawnTime = self.waveInfo.spawnTime    -- Set spawn time to the waves spawn time
        self.waveInfo.count = self.waveInfo.count - 1
        
        table.insert(zombieList, zombieClass())
        
      else
        
        self.zombieSpawnTime = self.zombieSpawnTime - dt
        
      end
    end
  end

  self.render = function()
    
    if self.waveTime < 5 then
      
      local textTransparency = 255
      if self.waveTime < self.textFadeIn then
        textTransparency = math.floor(255*(self.waveTime/self.textFadeIn))
      elseif self.waveTime > 5 - self.textFadeOut then
        textTransparency = math.floor(255*(1 - (self.waveTime-(5-self.textFadeOut))/self.textFadeOut))
      end
        
      
      love.graphics.setFont(self.font1)
      
      love.graphics.setColor(255, 255, 255, textTransparency)
      love.graphics.printf("Wave " .. self.waveNum, 0, 200, 1600, "center")
      love.graphics.setColor(255, 255, 255)
      
    end
    
  end
  
	return self
end