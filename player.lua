
function playerClass()
	local self = {}
	self.pos = {x=1200, y=800-356}
	self.size = {w=256, h=256}	-- width/height of player image in pixels

	self.collisionBody = {x=80, y=36, w=94, h=220}		
	
	self.walkTime = 0		-- How long player has been walking for in seconds
	self.speed = 200		-- Pixels per second
  
  self.health = {cur=100, max=100}  -- Current/Max HP

	self.gunImage = imageClass('gun.png', 100, 100, 0, 0.5)	-- Default gun image is gun facing the right

	self.image_player_torso = imageClass('player_torso.png', self.size.w, self.size.h, 0, 0)		-- Default image is player looking to the right
	self.image_player_arm_front = imageClass('player_arm_front.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is player looking to the right
	self.image_player_arm_back = imageClass('player_arm_back.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is player looking to the right

  self.mouseDown = false
  
  -- Variables to do with the player's mouse pos/gun (updated every time player.update() is called)
	self.linePoint = {x=nil, y=nil}    -- Point on screen->player where shooting originates (may move depending on gun)
  self.mouseOffset = {x=nil, y=nil}   -- Position of mouse relative to player's shooting origin
  self.mouseAngle = nil   -- Angle from player's linePoint to mouse position
  self.shootingLine = {m=nil, b=nil}  -- The line of player shooting in the form y=mx + b
  
	self.render = function()
    
		armBob = math.sin(self.walkTime * 8) * 3	-- How much the arm is currently bobbing from its original position (ranges from -3 to 3)

		if (self.mouseOffset.x > 0) then -- Mouse is to the right of players center x
			self.image_player_arm_back.render(self.pos.x + self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, false, self.mouseAngle)	-- Draw back arm
			self.image_player_torso.render(self.pos.x, self.pos.y, false, 0)	-- Draw player looking right
			self.image_player_arm_front.render(self.pos.x + self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, false, self.mouseAngle)	-- Draw front arm
		else -- Mouse is to the left of players center x
			self.image_player_arm_back.render(self.pos.x - self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, true, self.mouseAngle)	-- Draw back arm
			self.image_player_torso.render(self.pos.x, self.pos.y, true, 0)	-- Draw player looking left
			self.image_player_arm_front.render(self.pos.x - self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, true, self.mouseAngle)	-- Draw front arm
		end

		-- Render collison boundary box
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle( "line", self.pos.x + self.collisionBody.x, self.pos.y + self.collisionBody.y, self.collisionBody.w, self.collisionBody.h)
		love.graphics.setColor(255, 255, 255)


		--- Render shooting line ---
    
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
    
    
    -- Render health box in top right
    love.graphics.setColor(50, 0, 0)
		love.graphics.rectangle( "fill", 1270, 30, 300, 30)   -- Background dark red fill
    barWidth = math.floor(300 * (self.health.cur/self.health.max))
    love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle( "fill", 1270, 30, barWidth, 30)   -- Light red actual health fill
    love.graphics.setLineWidth(3)
    love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle( "line", 1270, 30, 300, 30)   -- Black border around health bar
		love.graphics.setColor(255, 255, 255)

	end

	self.update = function(dt)
	 	-- Check player collision with every coin --
		for i,coin in ipairs(coins) do
			if (coin.pos.x + coin.w > player.pos.x + player.collisionBody.x) and (coin.pos.x < player.pos.x + player.collisionBody.x + player.collisionBody.w) then
				table.remove(coins,i)
				inv.coins = inv.coins + 1
        print("Picked up coin")
			end
		end

    -- Limit player speed if touching zombie
		local moveSpeed = self.speed
		if self.health.cur > 0 and self.touchingZombie() then
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
    
    -- Update shooting origin position
    self.linePoint = {x=(self.pos.x + self.size.w/2), y=(self.pos.y + self.size.h*0.6)}    -- Point on screen/player where shooting originates (may move depending on gun)
		self.mouseOffset.x = love.mouse.getX() - self.linePoint.x   -- Update mouse offset x and y
		self.mouseOffset.y = love.mouse.getY() - self.linePoint.y
    
    -- Update angle from shooting pos to mouse pos
    self.mouseAngle = math.atan(self.mouseOffset.y / self.mouseOffset.x)
		--print(mouseAngle)
		if (self.mouseAngle > 1) then	-- Stop player from looking too far up/down
			self.mouseAngle = 1
		elseif (self.mouseAngle < -1) then
			self.mouseAngle = -1
		end
    
    -- y = mx + b    form of shooting line
		self.shootingLine.m = math.tan(self.mouseAngle)    -- gradient of line
		self.shootingLine.b = self.linePoint.y - (self.shootingLine.m * self.linePoint.x)  -- y intercept of line


    -- When player actually clicks to shoot
    if love.mouse.isDown(1) then   -- If mouse is being held down
      if not self.mouseDown then  -- Run's once per mouse down (for single shot weapons & buttons?)
        self.mouseDown = true
        
        --print("Player clicked")
        gunShot:setVolume(0.5)
        gunShot:stop()
        gunShot:play()

        
        for i,zombie in ipairs(zombieList) do
          zombieHit = zombie.isHit()    -- Returns either false, or table with {part="head" or "body", x=x pos of collision, y=y pos of collision}
          if zombieHit ~= false then  -- If zombie was hit
            print("Hitting zombie in " .. zombieHit.part)
            
            if (zombie.health.cur > 0) then   -- only do this stuff if zombie is still alive
              
              -- Zombies can only be given knockback if they were still alive at the time of being shot
              if self.mouseOffset.x >= 0 then   -- Player shooting to right, push zombie to right
                zombie.knockbackVelocity = 200    -- Push zombie to right because because he was hit from left
              else
                zombie.knockbackVelocity = -200
              end
            
              -- Apply damage to zombie only while he is alive
              if (zombieHit.part == "head") then
                zombie.health.cur = zombie.health.cur - inv.guns[inv.selectedGun].dmg*2
              elseif (zombieHit.part == "body") then
                zombie.health.cur = zombie.health.cur - inv.guns[inv.selectedGun].dmg
              end
              
            end

            -- Make zombie die maybe
            if (zombie.health.cur <= 0) then
              print("Zombie has died")
            end
            
          end
        end
        
      end
    else    -- When mouse is let go, set mouseDown to false
      self.mouseDown = false
    end
	end

	self.touchingZombie = function()	-- Returns true if player is colliding with a zombie, otherwise returns false
		for i,zombie in ipairs(zombieList) do
			if (zombie.pos.x + zombie.collisionBody.x + zombie.collisionBody.w > player.pos.x + player.collisionBody.x) then	-- If right of zombie > left of player
				if (zombie.pos.x + zombie.collisionBody.x < player.pos.x + player.collisionBody.x + player.collisionBody.w) then	-- If left of zombie < right of player
					return true
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

