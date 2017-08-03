
function playerClass()
	local self = {}
  self.size = {w=320, h=320}	-- width/height of player image in pixels
	self.pos = {x=800-self.size.w/2, y=800-100-self.size.h}

	self.collisionBody = {x=105, y=80, w=110, h=240}		
	
	self.walkTime = 0		-- How long player has been walking for in seconds
	self.speed = 200		-- Pixels per second
  
  self.health = {cur=0, max=100}  -- Current/Max HP

	self.image_player_torso = imageClass('player/torso.png', self.size.w, self.size.h, 0, 0)		-- Default image is player looking to the right
  self.image_player_front_leg = imageClass('player/front_leg.png', self.size.w, self.size.h, 0, 0)		-- Default image is player looking to the right
  self.image_player_back_leg = imageClass('player/back_leg.png', self.size.w, self.size.h, 0, 0)		-- Default image is player looking to the right
  
  self.image_gun_flash = imageClass('flash.png', 64, 64, 0, 0)		-- Default image is player looking to the right
  
  self.font1 = love.graphics.setNewFont('resources/shop_font2.ttf', 50)     -- For ammo info in bottom right
  
  self.gameOverSound = love.audio.newSource("resources/sound/game_over.ogg", "static")

  self.shotCooldown = 0
  self.flashCooldown = 0
  self.reloadCooldown = 0
  self.reloading = false
  
  
  -- Variables to do with the player's mouse pos/gun (updated every time player.update() is called)
	self.linePoint = {x=nil, y=nil}    -- Point on screen->player where shooting originates (may move depending on gun)
  self.mouseOffset = {x=nil, y=nil}   -- Position of mouse relative to player's shooting origin
  self.mouseAngle = nil   -- Angle from player's linePoint to mouse position
  self.shootingLine = {m=nil, b=nil}  -- The line of player shooting in the form y=mx + b
  
	self.render = function()
    
    local flashTransparency = math.floor(255 * (self.flashCooldown/0.25) )
    
		armBob = math.sin(self.walkTime * 8) * 2	-- How much the arm is currently bobbing from its original position (ranges from -3 to 3)

		if (self.mouseOffset.x > 0) then -- Mouse is to the right of players center x
			gunList[inv.selectedGun].image_Back_Arm.render(self.pos.x + self.size.w*0.4, self.pos.y + self.size.h*0.65 + armBob, false, self.mouseAngle)	-- Draw back arm
      
      -- Walking animation
      local backLegOffset = {x=-math.cos(self.walkTime*5)*3, y=-math.sin(self.walkTime*5)*2}
      self.image_player_back_leg.render(self.pos.x + backLegOffset.x, self.pos.y + backLegOffset.y, false, 0)
      local frontLegOffset = {x=math.cos(self.walkTime*5)*3, y=math.sin(self.walkTime*5)*2}
      self.image_player_front_leg.render(self.pos.x + frontLegOffset.x, self.pos.y + frontLegOffset.y, false, 0)
      
			self.image_player_torso.render(self.pos.x, self.pos.y, false, 0)	-- Draw player looking right
      
      
      -- Render flash if bullet was shot
      love.graphics.setColor(255, 255, 255, flashTransparency)
      self.image_gun_flash.ox = self.size.w * gunList[inv.selectedGun].flash.x
      self.image_gun_flash.oy = self.size.h * gunList[inv.selectedGun].flash.y
      self.image_gun_flash.render(self.pos.x + self.size.w*0.4, self.pos.y + self.size.h*0.65 + armBob, false, self.mouseAngle)
      love.graphics.setColor(255, 255, 255)
      
      
      gunList[inv.selectedGun].image_Front_Arm.render(self.pos.x + self.size.w*0.4, self.pos.y + self.size.h*0.65 + armBob, false, self.mouseAngle)	-- Draw front arm + gun
      
      
		else -- Mouse is to the left of players center x
      
			gunList[inv.selectedGun].image_Back_Arm.render(self.pos.x - self.size.w*0.4, self.pos.y + self.size.h*0.65 + armBob, true, self.mouseAngle)	-- Draw back arm
      
      -- Walking animation
      local backLegOffset = {x=-math.sin(self.walkTime*5)*3, y=-math.cos(self.walkTime*5)*2}
      self.image_player_back_leg.render(self.pos.x + backLegOffset.x, self.pos.y + backLegOffset.y, true, 0)
      local frontLegOffset = {x=math.sin(self.walkTime*5)*3, y=math.cos(self.walkTime*5)*2}
      self.image_player_front_leg.render(self.pos.x + frontLegOffset.x, self.pos.y + frontLegOffset.y, true, 0)
      
			self.image_player_torso.render(self.pos.x, self.pos.y, true, 0)	-- Draw player looking left
      
      -- Render flash if bullet was shot
      love.graphics.setColor(255, 255, 255, flashTransparency)
      self.image_gun_flash.ox = self.size.w * gunList[inv.selectedGun].flash.x
      self.image_gun_flash.oy = self.size.h * gunList[inv.selectedGun].flash.y
      self.image_gun_flash.render(self.pos.x + self.size.w*0.4, self.pos.y + self.size.h*0.65 + armBob, true, self.mouseAngle)
      love.graphics.setColor(255, 255, 255)
      
      
      gunList[inv.selectedGun].image_Front_Arm.render(self.pos.x - self.size.w*0.4, self.pos.y + self.size.h*0.65 + armBob, true, self.mouseAngle)	-- Draw front arm + gun
      
		end
    

		-- Render collison boundary box
    if false then
      love.graphics.setColor(255, 0, 0)
      love.graphics.rectangle( "line", self.pos.x + self.collisionBody.x, self.pos.y + self.collisionBody.y, self.collisionBody.w, self.collisionBody.h)
      love.graphics.setColor(255, 255, 255)
    end

		--- Render shooting line ---
    
    if false then
      -- Render small circle at shooting line origin point
      love.graphics.setColor(255, 0, 0)	
      love.graphics.circle("fill", self.linePoint.x, self.linePoint.y, 5)
      love.graphics.setColor(255, 255, 255)

      -- Point off screen where line is rendered to
      renderPoint = {x=0, y=nil}
      if (self.mouseOffset.x > 0) then
        renderPoint.x = 1600
      end
      renderPoint.y = self.shootingLine.m * renderPoint.x + self.shootingLine.b

      -- Draw line itself
      love.graphics.setColor(0, 255, 0)
      love.graphics.line(self.linePoint.x, self.linePoint.y, renderPoint.x, renderPoint.y)
      love.graphics.setColor(255, 255, 255)
    end
    
    
    -- Render health box in top right
    local healthRect = {x=1220, y=30, w=350, h=40}
    love.graphics.setColor(50, 0, 0)
		love.graphics.rectangle( "fill", healthRect.x, healthRect.y, healthRect.w, healthRect.h)   -- Background dark red fill
    barWidth = math.floor(healthRect.w * (self.health.cur/self.health.max))
    love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle( "fill", healthRect.x, healthRect.y, barWidth, healthRect.h)   -- Light red actual health fill
    love.graphics.setLineWidth(3)
    love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle( "line", healthRect.x, healthRect.y, healthRect.w, healthRect.h)   -- Black border around health bar
		love.graphics.setColor(255, 255, 255)
    
    
    -- Render ammo stats in bottom right
    love.graphics.setFont(self.font1)
    local ammoText = gunList[inv.selectedGun].ammo.cur .. " | " .. gunList[inv.selectedGun].ammo.backup
    love.graphics.printf(ammoText, 1300, 820, 250, "right")

	end

	self.update = function(dt)
    
    -- Firstly check if player is dead
    if self.health.cur <= 0 then
      
      main.state = "dead"   -- Player is dead
      
      -- Play game over sound
      self.gameOverSound:setVolume(1)
      self.gameOverSound:stop()
      self.gameOverSound:play()
      
      
    else
    
      -- Check player collision with every coin --
      for i,coin in ipairs(coins) do
        if (coin.pos.x + coin.w > player.pos.x + player.collisionBody.x) and (coin.pos.x < player.pos.x + player.collisionBody.x + player.collisionBody.w) then
          table.remove(coins,i)
          inv.coins = inv.coins + 1
          print("Picked up coin")
        end
      end


      local moveSpeed = self.speed 
      moveSpeed = moveSpeed * gunList[inv.selectedGun].player_speed_multiplier
      
      -- Limit player speed if touching zombie
      if self.touchingZombie() then
        moveSpeed = moveSpeed * 0.5
      end

      -- Test for input and move player
      if love.keyboard.isDown('d') then
        player.pos.x = player.pos.x + moveSpeed*dt

        player.walkTime = player.walkTime + dt 	-- Bob arms up and down
      elseif love.keyboard.isDown('a') then
        player.pos.x = player.pos.x - moveSpeed*dt

        player.walkTime = player.walkTime + dt 	-- Bob arms up and down
      end
      
      
      --- Handle Shooting ---
      
      -- Limit shooting speed
      if (self.shotCooldown > 0) then
        self.shotCooldown = self.shotCooldown - dt
      end
      if (self.shotCooldown < 0) then
        self.shotCooldown = 0
      end
      
      -- Flash effect cooldown
      if (self.flashCooldown > 0) then
        self.flashCooldown = self.flashCooldown - dt
      end
      if (self.flashCooldown < 0) then
        self.flashCooldown = 0
      end
      
      
      
      -- Update shooting origin position
      self.linePoint = {x=(self.pos.x + self.size.w/2), y=(self.pos.y + self.size.h*0.6)}    -- Point on screen/player where shooting originates (may move depending on gun)
      self.mouseOffset.x = love.mouse.getX() - self.linePoint.x   -- Update mouse offset x and y
      self.mouseOffset.y = love.mouse.getY() - self.linePoint.y
      
      -- Update angle from shooting pos to mouse pos
      self.mouseAngle = math.atan(self.mouseOffset.y / self.mouseOffset.x)
      --print(mouseAngle)
      if (self.mouseAngle > 0.6) then	-- Stop player from looking too far up/down
        self.mouseAngle = 0.6
      elseif (self.mouseAngle < -0.6) then
        self.mouseAngle = -0.6
      end
      
      -- y = mx + b    form of shooting line
      self.shootingLine.m = math.tan(self.mouseAngle)    -- gradient of line
      self.shootingLine.b = self.linePoint.y - (self.shootingLine.m * self.linePoint.x)  -- y intercept of line


      -- When player actually clicks to shoot
      if love.mouse.isDown(1) then   -- If mouse is being held down
        
        if not gunList[inv.selectedGun].perclick or (gunList[inv.selectedGun].perclick and mouseClicked) then  -- If the gun is automatic or (the gun is single shot and mouseClicked is true)
          mouseClicked = true
          
          if (gunList[inv.selectedGun].ammo.cur > 0) and (self.shotCooldown <= 0) and (self.reloadCooldown <= 0) then
            self.shoot()
          end
          
        end
      end
      
      
      -- Handle reloading
      
      if (self.reloading) then    -- If player is currently reloading gun
        self.reloadCooldown = self.reloadCooldown - dt    -- Bring down reloadCooldown
        
        if (self.reloadCooldown <= 0) then
          self.reloadCooldown = 0
          self.reloading = false
          
          -- Actually give player ammo
          local ammoGained = gunList[inv.selectedGun].ammo.clip - gunList[inv.selectedGun].ammo.cur     -- How far gun clip is from full ammo
          if inv.selectedGun ~= "pistol" then
            if (ammoGained > gunList[inv.selectedGun].ammo.backup) then   -- If backup does not contain enough ammo for the reload, just add backup to the ammo
              ammoGained = gunList[inv.selectedGun].ammo.backup
            end
            gunList[inv.selectedGun].ammo.backup = gunList[inv.selectedGun].ammo.backup - ammoGained    -- Remove the ammo moved from backup to cur
            gunList[inv.selectedGun].ammo.cur = gunList[inv.selectedGun].ammo.cur + ammoGained    -- Add the ammo to cur
          else
            gunList[inv.selectedGun].ammo.cur = gunList[inv.selectedGun].ammo.clip    -- If using a pistol, just set cur to clip and nothing more
          end
          print("Finished reloading")
          
        end
        
      else   -- Allow player to start reloading only if they are currently NOT reloading
        if (gunList[inv.selectedGun].ammo.cur ~= gunList[inv.selectedGun].ammo.clip) then   -- AND they have bullets that need reloading
          if (gunList[inv.selectedGun].ammo.backup ~= 0) then  -- AND they dont have zero backup bullets (either more than zero or infinity)
            if love.keyboard.isDown('r') then   -- AND they press "r"
              self.reload()
            end
          end
        end
      end
    end
	end


  self.shoot = function()
    
    gunList[inv.selectedGun].ammo.cur = gunList[inv.selectedGun].ammo.cur - 1       -- Remove a bullet
    
    -- Auto reload when player has zero ammo in cur but still ammo in backup
    if (gunList[inv.selectedGun].ammo.cur == 0 and gunList[inv.selectedGun].ammo.backup ~= 0) then    
      self.reload()
    end
      
    self.shotCooldown = 1 / gunList[inv.selectedGun].speed      -- Limit bullets shot per second
    self.flashCooldown = 0.25     -- Make flash appear for 0.25 seconds
    
    -- Player gun shooting noise
    gunList[inv.selectedGun].sound.shootSound:setVolume(gunList[inv.selectedGun].sound.shootVol)
    gunList[inv.selectedGun].sound.shootSound:stop()
    gunList[inv.selectedGun].sound.shootSound:play()
    
    
      --- Hit closest n zombies ---
    local hitZombies = {}   -- Table of all zombies that have been hit set out like:  {index=index of zombie in zombieList, hitX=x pos of where it was hit, dist=dist from player}
    for i,zombie in ipairs(zombieList) do    -- Add all zombies that were inline of players gun to hitZombies
      local zombieHit = zombie.isHit()    -- Returns either false, or table with {part="head" or "body", x=x pos of collision, y=y pos of collision}
      if zombieHit ~= false and zombie.health.cur > 0 then  -- If zombie was hit and they are still alive then do things to the zombie
        table.insert(hitZombies, {index=i, hitInfo=zombieHit, dist=math.abs(zombieHit.x - self.pos.x) })
      end
    end
    
    -- Sort all that zombies that were hit from closest to player to furthest from player
    table.sort(hitZombies, function(a, b)
      return a.dist < b.dist
    end)
  
    for i,zombieStats in ipairs(hitZombies) do   -- If atleast 1 zombie was hit
      if (gunList[inv.selectedGun].penetration < i) then    -- Only allow certain number of zombies to be hit depending on guns penetration
        break
      end
      
      local canShoot = true   -- Just a couple of limitations on shooting the zombie
      canShoot = (inv.selectedGun ~= "shotgun" or zombieStats.dist < 650)   -- Either we are NOT using shotgun or zombie is closer than 650 pixels
      
      if canShoot then
        local zombiePart = hitZombies[i].hitInfo.part   -- Part that zombie was hit in
        local zombieIndex = hitZombies[i].index     -- Index of zombie that was hit
        print("Hitting zombie in " .. zombiePart)
        
        -- Zombies can only be given knockback if they were still alive at the time of being shot
        if self.mouseOffset.x >= 0 then   -- Player shooting to right, push zombie to right
          zombieList[zombieIndex].knockbackVelocity = 150    -- Push zombie to right because because he was hit from left
        else
          zombieList[zombieIndex].knockbackVelocity = -150
        end
      
        -- Apply damage to zombie only while he is alive
        if (zombiePart == "head") then
          zombieList[zombieIndex].health.cur = zombieList[zombieIndex].health.cur - gunList[inv.selectedGun].dmg*2
        elseif (zombiePart == "body") then
          zombieList[zombieIndex].health.cur = zombieList[zombieIndex].health.cur - gunList[inv.selectedGun].dmg
        end
        
        
        -- Play random death noise when zombie dies
        local randomHitNoise = math.random(#zombieList[zombieIndex].hitSounds)   -- random noise index
        zombieList[zombieIndex].hitSounds[randomHitNoise]:setVolume(0.5)
        zombieList[zombieIndex].hitSounds[randomHitNoise]:stop()
        zombieList[zombieIndex].hitSounds[randomHitNoise]:play()
        
        
          -- Things that happen ONCE when zombie dies
        if (zombieList[zombieIndex].health.cur <= 0) then
          print("Zombie has died")
          gunList[inv.selectedGun].kills = gunList[inv.selectedGun].kills + 1
          
          -- Play random death noise when zombie dies
          local randomDeathNoise = math.random(#zombieList[zombieIndex].dieSounds)   -- random noise index
          zombieList[zombieIndex].dieSounds[randomDeathNoise]:setVolume(0.5)
          zombieList[zombieIndex].dieSounds[randomDeathNoise]:stop()
          zombieList[zombieIndex].dieSounds[randomDeathNoise]:play()

          -- Add new item on to dropped items table
          if (math.random() < 0.3) then
            table.insert(droppedItems, droppedItemClass(zombieList[zombieIndex]))
          end
        end
      end
    end
  end
  
  self.reload = function()
    
    self.reloadCooldown = gunList[inv.selectedGun].reloadTime
    self.reloading = true
    
    print("Starting reload")
    
    -- Play reload noises with a length approximately equal to the guns reloadTime
    gunList[inv.selectedGun].sound.reloadSound:setVolume(gunList[inv.selectedGun].sound.reloadVol)
    gunList[inv.selectedGun].sound.reloadSound:stop()
    gunList[inv.selectedGun].sound.reloadSound:play()
    
  end


	self.touchingZombie = function()	-- Returns true if player is colliding with a zombie, otherwise returns false
		for i,zombie in ipairs(zombieList) do
      if (zombie.health.cur > 0) then   -- Only touching zombies that are alive
        if (zombie.pos.x + zombie.collisionBody.x + zombie.collisionBody.w > player.pos.x + player.collisionBody.x) then	-- If right of zombie > left of player
          if (zombie.pos.x + zombie.collisionBody.x < player.pos.x + player.collisionBody.x + player.collisionBody.w) then	-- If left of zombie < right of player
            return true
          end
        end
      end
		end
		return false
	end
  
  self.shootingRect = function(rect)   -- Returns closest coordinates that the players shooting line is colliding with a rectangle, if rect is not hit then false is returned
    --- Instructions ---
    -- If shooting origin is inside rectangle, simply return shooting origin as that must be closest collision point
    -- Only need to test 2 sides of rectangle (one vertical and one horizontal) as only two are visible by the shooting raycast at any time
    
    -- First test for shooting origin inside/touching rect
    if (rect.x <= self.linePoint.x) and (self.linePoint.x <= rect.x + rect.w) then  -- Colliding on x axis
      if (rect.y <= self.linePoint.y) and (self.linePoint.y <= rect.y + rect.h) then  -- Colliding on y axis
        return self.linePoint
      end
    end

    
    -- Shooting line can only hit if the player is facing the right way compared to the box
    if (player.mouseOffset.x >= 0 and rect.x + rect.w >= self.linePoint.x) or (player.mouseOffset.x < 0 and rect.x <= self.linePoint.x) then

        --- Calculate collision of either left/right side (whatever is closer) ---
      -- Calculate collision point using the closest left/right side of rect to the shooting origin
      local verticalSideCollision = {x=rect.x, y=nil}
      if ( math.abs(self.linePoint.x - rect.x) > math.abs(self.linePoint.x - (rect.x + rect.w)) ) then    -- If right side is closer, use that instead
        verticalSideCollision.x = rect.x + rect.w
      end
      verticalSideCollision.y = self.shootingLine.m * verticalSideCollision.x + self.shootingLine.b   -- Y Intercept of shooting line on vertical side (calculated with y=mx+b) 
      if (rect.y <= verticalSideCollision.y) and (verticalSideCollision.y <= rect.y + rect.h) then  -- If y intercept of line is withing the rectangle's side's y boundaries
        return verticalSideCollision    -- Vertical side must be closest collision point, return this
      end
      
        --- Calculate collision of either top/bottom side (whatever is closer) ---
      -- Calculate collision point using the closest top/bottom side of rect to the shooting origin
      local horizontalSideCollision = {x=nil, y=rect.y}
      if ( math.abs(self.linePoint.y - rect.y) > math.abs(self.linePoint.y - (rect.y + rect.h)) ) then    -- If bottom side is closer, use that instead
        horizontalSideCollision.y = rect.y + rect.h
      end
      if (self.shootingLine.m == 0) then   -- If m is zero, return closest point to avoid dividing by zero in the next step
        if (self.linePoint.y == horizontalSideCollision.y) then  -- Can only be shooting horizontal point on box if y coord of shooting origin equals y coord of rectangle's side
          if (player.mouseOffset.x >= 0) then   -- If facing right, return left most point on line
            horizontalSideCollision.x = rect.x
          else  -- Facing left, return right most point on line
            horizontalSideCollision.x = rect.x + rect.w
          end
          return horizontalSideCollision
        else
          return false
        end
      end
      horizontalSideCollision.x = (horizontalSideCollision.y - self.shootingLine.b) / self.shootingLine.m   -- X Intercept of shooting line on horizontal side (calculated with x=(y-b)/m) 
      if (rect.x <= horizontalSideCollision.x) and (horizontalSideCollision.x <= rect.x + rect.w) then
        return horizontalSideCollision
      end
    end
    
    return false
  end

	return self
end

