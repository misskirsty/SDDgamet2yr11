
function zombieClass()	-- Side is left/right 
	local self = {}
	self.size = {w=256, h=256}  -- Rendering image size of entire zombie
	self.pos = {x={-self.size.w, 1600}, y=800-356}
  self.pos.x = self.pos.x[math.random(1,2)]
  
	self.collisionBody = {x=60, y=106, w=130, h=150}	-- Rectangle that represents collision boundary of body for shooting (assume zombie is facing right)
  self.collisionHead = {x=91, y=40, w=100, h=100}   -- Rectangle that represents collision boundary of head for shooting (assume zombie is facing right)


  -- Image Rendering Variables --
  self.image_zombie_torso = imageClass('zombie/zombie_torso.png', self.size.w, self.size.h, 0, 0)		-- Default image is zombie looking to the right
	self.image_zombie_arm_back = imageClass('zombie/zombie_arm_back.png', self.size.w, self.size.h, 0.53, 0.53)		-- Default image is zombie looking to the right
	self.image_zombie_arm_front = imageClass('zombie/zombie_arm_front.png', self.size.w, self.size.h, 0.35, 0.56)		-- Default image is zombie looking to the right
  self.image_zombie_leg_back = imageClass('zombie/zombie_leg_back.png', self.size.w, self.size.h, 0, 0)		-- Default image is zombie looking to the right
  self.image_zombie_leg_front = imageClass('zombie/zombie_leg_front.png', self.size.w, self.size.h, 0, 0)		-- Default image is zombie looking to the right



	self.speed = 30 + math.random()*25	-- Speed in pixels per second
  self.health = {cur=100, max=100}  -- Current/Max HP
  
	self.facingDirection = nil
  
  -- Actual screen position of zombie collision boundaries when rendered on the screen
  self.collisionBodyScreenPos = {x=nil, y=nil}
  self.collisionHeadScreenPos = {x=nil, y=nil}
  
  -- Zombie knockback variables
  self.knockbackVelocity = 0    -- pixels moved per second due to knockback velocity
  self.knockbackFriction = 200    -- knockbackVelocity lost per second
  
  -- Zombie Attack Variables --
  self.attackTime = 2   -- Time between attack
  self.attackCooldown = 0   -- Current attack cooldown value, zombie can attack when this is less than or equal to zero
  self.attackDmg = 10
  self.attackSounds = {
    love.audio.newSource("resources/sound/zombie/hit1.wav", "static"),
    love.audio.newSource("resources/sound/zombie/hit2.wav", "static"),
    love.audio.newSource("resources/sound/zombie/hit3.wav", "static")
  }
  
  self.groanTimer = 0 + math.random() * 10
  self.groanSounds = {
    love.audio.newSource("resources/sound/zombie/groan1.ogg", "static"),
    love.audio.newSource("resources/sound/zombie/groan2.ogg", "static"),
    love.audio.newSource("resources/sound/zombie/groan3.ogg", "static"),
    love.audio.newSource("resources/sound/zombie/groan4.ogg", "static")
  }
  
  self.dieSounds = {
    love.audio.newSource("resources/sound/zombie/die1.ogg", "static"),
    love.audio.newSource("resources/sound/zombie/die2.ogg", "static"),
    love.audio.newSource("resources/sound/zombie/die3.ogg", "static")
  }
  
  self.hitSounds = {
    love.audio.newSource("resources/sound/hit_zombie1.ogg", "static"),
    love.audio.newSource("resources/sound/hit_zombie2.ogg", "static"),
    love.audio.newSource("resources/sound/hit_zombie3.ogg", "static")
  }
  
 
  self.aliveTime = 0    -- The number of seconds the since the zombie began updating (used for the walking sin waves)

  self.deathTime = 0   -- The number of seconds the zombie has been dead (health <= 0)
  self.deathTurningTime = 2
  self.deathSinkingTime = 1.5
  
  self.canvas = love.graphics.newCanvas(256, 256)

	self.render = function()
    
    local touchingPlayer = self.touchingPlayer()
    
    local armSwingFront = nil
    local armSwingBack = nil
    if touchingPlayer and self.health.cur > 0 then
      armSwingFront = math.sin(self.aliveTime*5) * 0.5 + 0.3
    else
      armSwingFront = math.sin(self.aliveTime*2) * 0.2
    end
    armSwingBack = -armSwingFront
    
    -- Apply effects for zombie death 'animation'
    local deathRotation = 0     -- Rotation amount of zombie after death
    local deathSink = 0     -- Pixel amount that zombie sinks into ground after death
    local deathTransparency = 255   -- Transparacy of zombie (get smaller after zombie dies)
    if (self.health.cur <= 0) then    -- Apply death effects if zombie has no health left
      
      -- Apply turning effect
      if (self.deathTime < self.deathTurningTime) then   
        --deathRotation = math.pi*0.5 * math.sin(math.pi*0.5 * self.deathTime/self.deathTurningTime)
        deathRotation = math.pi*0.5 * math.pow((-math.cos(math.pi*0.5 * self.deathTime/self.deathTurningTime)+1),2)
      else
        deathRotation = math.pi*0.5
      end
      if (self.facingDirection == "right") then
        deathRotation = -deathRotation
      end
      
      armSwingFront = armSwingFront + deathRotation
      armSwingBack = armSwingBack + deathRotation
      
      -- After zombie has finished turning, start sinking and disappearing
      if (self.deathTime >= self.deathTurningTime) then
        deathSink = (self.deathTime-self.deathTurningTime) * 30
        deathTransparency = math.floor((self.deathSinkingTime-(self.deathTime-self.deathTurningTime)) * 255)
        if (deathTransparency < 0) then
          deathTransparency = 0
        end
      end
      
    end

    love.graphics.setCanvas(self.canvas) -- Set drawing canvas to zombie canvas
    love.graphics.clear()   -- Clear zombie canvas
    love.graphics.setBlendMode("alpha")

		if (self.facingDirection == "right") then	-- Zombie is facing the right
      
      -- Draw main body parts
            
      -- Walking animation
      local backLegOffset = {x=-math.cos(self.aliveTime*2)*3, y=-math.sin(self.aliveTime*2)*2}
      self.image_zombie_leg_back.render(backLegOffset.x, backLegOffset.y, false, 0)
      local frontLegOffset = {x=math.cos(self.aliveTime*2)*3, y=math.sin(self.aliveTime*2)*2}
      self.image_zombie_leg_front.render(frontLegOffset.x, frontLegOffset.y, false, 0)
      
      self.image_zombie_arm_back.render(self.size.w*0.53, self.size.h*0.53, false, armSwingBack)	-- Draw back arm
			self.image_zombie_torso.render(0, 0, false, 0)	-- Draw zombie looking right
			self.image_zombie_arm_front.render(self.size.w*0.35, self.size.h*0.56, false, armSwingFront)	-- Draw front arm


    else -- Zombie is facing the left
    
      -- Draw main body parts
      
      -- Walking animation
      local backLegOffset = {x=-math.sin(self.aliveTime*2)*3, y=-math.cos(self.aliveTime*2)*2}
      self.image_zombie_leg_back.render(backLegOffset.x, backLegOffset.y, true, 0)
      local frontLegOffset = {x=math.sin(self.aliveTime*2)*3, y=math.cos(self.aliveTime*2)*2}
      self.image_zombie_leg_front.render(frontLegOffset.x, frontLegOffset.y, true, 0)
    
    
  
      self.image_zombie_arm_back.render(-self.size.w*0.53, self.size.h*0.53, true, armSwingBack)	-- Draw back arm
			self.image_zombie_torso.render(0, 0, true, 0)	-- Draw zombie looking right
			self.image_zombie_arm_front.render(-self.size.w*0.35, self.size.h*0.56, true, armSwingFront)	-- Draw front arm
      
      
		end
    
    -- Finally draw zombie canvas onto screen
    love.graphics.setCanvas()
    love.graphics.setColor(255, 255, 255, deathTransparency)
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(self.canvas, self.pos.x + self.size.w*0.5, self.pos.y + self.size.h*0.73 + deathSink, deathRotation, 1, 1, self.size.w*0.5, self.size.h*0.73)
    
    
      -- Render small circle at rotation point
  --  love.graphics.setColor(255, 0, 0)	
  --  love.graphics.circle("fill", self.pos.x + self.size.w*0.5, self.pos.y + self.size.h*0.73, 5)
  --  love.graphics.setColor(255, 255, 255)
    

    if false then
      -- Render collison boundary body rectangle
      love.graphics.setColor(255, 0, 0)
      love.graphics.rectangle( "line", self.collisionBodyScreenPos.x, self.collisionBodyScreenPos.y, self.collisionBody.w, self.collisionBody.h)
      love.graphics.setColor(255, 255, 255)
      
      -- Render collision boundary head rectangle
      love.graphics.setColor(255, 100, 0)
      love.graphics.rectangle( "line", self.collisionHeadScreenPos.x, self.collisionHeadScreenPos.y, self.collisionHead.w, self.collisionHead.h)
      love.graphics.setColor(255, 255, 255)
    end
    
    -- Render health box above head
    love.graphics.setColor(50, 0, 0)
		love.graphics.rectangle( "fill", self.pos.x+53, self.pos.y-20, 150, 20)   -- Background dark red fill
		love.graphics.setColor(255, 255, 255)
    barWidth = math.floor(150 * (self.health.cur/self.health.max))
    love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle( "fill", self.pos.x+53, self.pos.y-20, barWidth, 20)   -- Light red actual health fill
		love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(3)
    love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle( "line", self.pos.x+53, self.pos.y-20, 150, 20)   -- Black border around health bar
		love.graphics.setColor(255, 255, 255)
    
    
    
	end

	self.update = function(dt)
    
    self.aliveTime = self.aliveTime + dt
    
    --- Zombie knockback ---    applied regardless of whether or not zombie is alive
    self.pos.x = self.pos.x + self.knockbackVelocity * dt   -- Move zombie if it has knockback velocity
    if math.abs(self.knockbackVelocity) <= self.knockbackFriction * dt then    -- Remove all zombie knockback velocity if velocity is small enough
      self.knockbackVelocity = 0
    else
      if self.knockbackVelocity > 0 then   -- Slow down knockback velocity to the right
        self.knockbackVelocity = self.knockbackVelocity - self.knockbackFriction * dt
      elseif self.knockbackVelocity < 0 then   -- Slow down knockback velocity to the left
        self.knockbackVelocity = self.knockbackVelocity + self.knockbackFriction * dt
      end
    end
    
    
    if self.health.cur <= 0 then    -- Zombie is dead
      self.deathTime = self.deathTime + dt
    else
      
      local touchingPlayer = self.touchingPlayer()
      
        --- Zombie movement ---
      local moveSpeed = self.speed
      if touchingPlayer then
        moveSpeed = 0
      end

      if (self.pos.x + self.size.w/2 < player.pos.x + player.size.w/2) then		-- If zombie is to the left of player
        self.facingDirection = "right"
        self.pos.x = self.pos.x + moveSpeed*dt
      else    -- Zombie is to the right of player
        self.facingDirection = "left"
        self.pos.x = self.pos.x - moveSpeed*dt
      end
      
      
        --- Update Collision Boundary after moving ---
      -- Actual screen position of zombie collision boundaries must be updated each frame based on position of zombie and which way it is facing
      self.collisionBodyScreenPos = {x=nil, y=self.pos.y + self.collisionBody.y}
      self.collisionHeadScreenPos = {x=nil, y=self.pos.y + self.collisionHead.y}

      if (self.facingDirection == "right") then	-- Zombie is facing the right
        -- Set collision boundaries x for when zombie is facing right
        self.collisionBodyScreenPos.x = self.pos.x + self.collisionBody.x
        self.collisionHeadScreenPos.x = self.pos.x + self.collisionHead.x
      else -- Zombie is facing the left
        -- Set collision boundaries x for when zombie is facing left
        self.collisionBodyScreenPos.x = self.pos.x + self.size.w - self.collisionBody.x - self.collisionBody.w
        self.collisionHeadScreenPos.x = self.pos.x + self.size.w - self.collisionHead.x - self.collisionHead.w
      end


        --- Zombie attacking player ---
      if self.attackCooldown > 0 then
        self.attackCooldown = self.attackCooldown - dt
      else
        if touchingPlayer then
          self.attackCooldown = self.attackTime
          
          -- Deal damage to player
          player.health.cur = player.health.cur - self.attackDmg
          if player.health.cur < 0 then
            player.health.cur = 0
          end
          
          -- Play random attacking sound
          local randomAttackNoise = math.random(#self.attackSounds)   -- random noise index
          self.attackSounds[randomAttackNoise]:setVolume(0.5)
          self.attackSounds[randomAttackNoise]:stop()
          self.attackSounds[randomAttackNoise]:play()
          
        end
      end
      
      -- Playe zombie groaning noises
      self.groanTimer = self.groanTimer - dt
      if self.groanTimer <= 0 then
          self.groanTimer = 5 + math.random() * 10
          local randomGroanNoise = math.random(#self.groanSounds)   -- random noise index
          self.groanSounds[randomGroanNoise]:setVolume(0.2)
          self.groanSounds[randomGroanNoise]:stop()
          self.groanSounds[randomGroanNoise]:play()
      end
      
    end
	end
  
  self.isHit = function()  -- Returns either "body" or "head" or false depending on how players shootingLine is passing through it.
    --[[ 
          Both collision areas (head and body) are rectangles.
          If shooting line is colliding with head, return that collision
          Only if shooting line is NOT colliding with head, does the function return the collision of body.
    --]]
    
    local headRect = {x=self.collisionHeadScreenPos.x, y=self.collisionHeadScreenPos.y, w=self.collisionHead.w, h=self.collisionHead.h}
    local headCollision = player.shootingRect(headRect)
    if headCollision ~= false then    -- Head is collided, return this over body
      return {part="head", x=headCollision.x, y=headCollision.y}
    else   -- Only return body collision if head was NOT shot 
      local bodyRect = {x=self.collisionBodyScreenPos.x, y=self.collisionBodyScreenPos.y, w=self.collisionBody.w, h=self.collisionBody.h}
      local bodyCollision = player.shootingRect(bodyRect)
      if bodyCollision ~= false then
        return {part="body", x=bodyCollision.x, y=bodyCollision.y}
      end
    end
    
    return false

  end 

	self.touchingPlayer = function()	-- Returns true if zombie is colliding with the player, otherwise returns false
		if (player.pos.x + player.collisionBody.x + player.collisionBody.w > self.pos.x + self.collisionBody.x) then	-- If right of player > left of zombie
			if (player.pos.x + player.collisionBody.x < self.pos.x + self.collisionBody.x + self.collisionBody.w) then	-- If left of player < right of zombie
				return true
			end
		end
		return false
	end

	return self
end


