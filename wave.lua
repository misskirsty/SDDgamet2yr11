
function waveClass()   -- handles waves
	local self = {}

  self.font1 = love.graphics.setNewFont('resources/wave_font.ttf', 200)

  self.waveNum = 1
  self.startTime = 3   -- Time needed to wait before any zombie start spawning
  self.zombieSpawnTime = self.startTime


  self.waveInfo = {
      {count = 10, spawnTime = 1}
      --{count = 15, spawnTime = 0.9},
      --{count = 20, spawnTime = 0.8},
      --{count = 25, spawnTime = 0.7},
    --  {count = 30, spawnTime = 0.6}
  }
	self.countSpawnTime = 1

  self.waveTime = 0

  self.textFadeIn = 2
  self.textFadeOut = 1

  self.startNextWave = function()

    self.waveNum = self.waveNum + 1
    self.zombieSpawnTime = self.startTime
    self.waveTime = 0
		self.countSpawnTime = self.countSpawnTime - 0.1
		if self.countSpawnTime <= 0 then
			self.countSpawnTime = 0.1
		end
		table.insert(self.waveInfo, {count = 5 * (self.waveNum + 1), spawnTime = (self.countSpawnTime)} )
    shop.isOpen = true
    shop.clickedGun = "pistol"

    for gunName,gun in pairs(gunList) do

      if gunName ~= "pistol" then   -- Reset gun stats for every gun except pistol

        inv.selectedGun = "pistol"
        gun.holding = false


      end

    end



  end

  self.update = function(dt)    -- Runs every frame, spawns zombies when it should happen

    self.waveTime = self.waveTime + dt

    if (self.waveInfo[self.waveNum].count == 0) then -- If enough zombies have been spawned in wave
      if (#zombieList == 0) then

        self.startNextWave()

      end
    else  -- Start spawning zombies

      if self.zombieSpawnTime <= 0 then   -- Spawns a zombie if zombie spawn time has ran out

        self.zombieSpawnTime = self.waveInfo[self.waveNum].spawnTime    -- Set spawn time to the waves spawn time
        self.waveInfo[self.waveNum].count = self.waveInfo[self.waveNum].count - 1

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
