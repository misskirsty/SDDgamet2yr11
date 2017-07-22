
function love.load()
  
  
  -- Probably have 9 or less guns, one for each num key 1-9 and 0 for grenades
  gunList = {   -- Stats about each gun
  -- perclick is whether or not gun shoots once per click or if it can be held down to shoot
  -- speed is minimum time between bullet shots (doesn't matter whether perclick is true or not)
		pistol =	{num=1,   locked=false, dmg=10,    maxammo=100, speed=10, 	price=0,    perclick=true,    penetration=1,    lowerImage="lowerImage/glock.png"},
		ak47 =		{num=2,   locked=false, dmg=10,    maxammo=30, 	speed=30, 	price=30,   perclick=false,   penetration=1,    lowerImage="lowerImage/ak47.png"},
    machine =	{num=3,   locked=false, 	dmg=10,  maxammo=50, 	speed=100, 	price=100,  perclick=false,   penetration=1,    lowerImage="lowerImage/machine.png"},
    sniper =	{num=4,   locked=true, 	dmg=10,    maxammo=10, 	speed=10, 	price=30,   perclick=true,    penetration=1,    lowerImage="lowerImage/ak47.png"},
    magnum =	{num=5,   locked=true, 	dmg=10,    maxammo=10, 	speed=10, 	price=30,   perclick=true,    penetration=1,    lowerImage="lowerImage/ak47.png"},
    rocket =	{num=6,   locked=true, 	dmg=10,    maxammo=10, 	speed=10, 	price=30,   perclick=true,    penetration=1,    lowerImage="lowerImage/ak47.png"}
	}
  
  for i,gun in pairs(gunList) do
    gun.lowerImage = imageClass(gun.lowerImage, 100, 100, 0, 0)
  end
  

	love.window.setMode(1600, 900, {resizable=false,vsync=false})

	crosshair = love.mouse.newCursor(love.image.newImageData("resources/crosshair48.png"), 24, 24)
	love.mouse.setCursor(crosshair)
	
	backgroundImage = imageClass("background.jpg", 1600, 900, 0, 0)
	groundImage = imageClass("ground.png", 1600, 200, 0, 0)

	droppedItems = {}

	player = playerClass()
	inv = inventoryClass()
  shop = shopClass()

	zombieList = {zombieClass()}--, zombieClass(), zombieClass()}

	coins = {coinClass(900)}
  
  
  -- Lock Image for lower gun bar
  lockImage = imageClass("lowerImage/lock.png", 100, 100, 0, 0)

end

function imageClass(src, width, height, originX, originY)	-- A class to handle images
	local self = {}
	self.image = love.graphics.newImage('resources/' .. src)
	self.w = width
	self.h = height
	self.sx = self.w/self.image:getWidth()
	self.sy = self.h/self.image:getHeight()
	self.ox = originX*self.image:getWidth()	-- Offset as a decimal based on image width/height from the (0,0) render point and rotation pivot point
	self.oy = originY*self.image:getHeight()
	self.render = function(x, y, flipped, rotation) 	-- Renders image at position 'x','y' with rotation 'r'\
		if (flipped == false) then
			love.graphics.draw(self.image, x, y, rotation, self.sx, self.sy, self.ox, self.oy)
		else
			love.graphics.draw(self.image, x + self.w, y, rotation, -self.sx, self.sy, self.ox, self.oy)
		end
	end

	return self
end

function playerClass()
	local self = {}
	self.pos = {x=1200, y=800-256}
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
        
        for i,zombie in ipairs(zombieList) do
          zombieHit = zombie.isHit()    -- Returns either false, or table with {part="head" or "body", x=x pos of collision, y=y pos of collision}
          if zombieHit ~= false then  -- If zombie was hit
            print("Hitting zombie in " .. zombieHit.part)
            
            if (zombieHit.part == "head") then
              zombie.health.cur = zombie.health.cur - inv.guns[inv.selectedGun].dmg*2
            elseif (zombieHit.part == "body") then
              zombie.health.cur = zombie.health.cur - inv.guns[inv.selectedGun].dmg
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

function zombieClass()	-- Side is left/right 
	local self = {}
	self.pos = {x=256, y=800-256}
	self.size = {w=256, h=256}  -- Rendering image size of entire zombie
	self.collisionBody = {x=60, y=106, w=130, h=150}	-- Rectangle that represents collision boundary of body for shooting (assume zombie is facing right)
  self.collisionHead = {x=91, y=40, w=100, h=100}   -- Rectangle that represents collision boundary of head for shooting (assume zombie is facing right)


  -- Image Rendering Variables --
	self.image_zombie_arm_back = imageClass('zombie_arm_back.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is zombie looking to the right
	self.image_zombie_torso = imageClass('zombie_torso.png', self.size.w, self.size.h, 0, 0)		-- Default image is zombie looking to the right
	self.image_zombie_arm_front = imageClass('zombie_arm_front.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is zombie looking to the right


	self.speed = 50 + math.random()*25	-- Speed in pixels per second
  self.health = {cur=100, max=100}  -- Current/Max HP
  
	self.facingDirection = "right"
  
  -- Actual screen position of zombie collision boundaries when rendered on the screen
  self.collisionBodyScreenPos = {x=nil, y=nil}
  self.collisionHeadScreenPos = {x=nil, y=nil}
  

	self.render = function()

		if (self.facingDirection == "right") then	-- Zombie is facing the right
			self.image_zombie_arm_back.render(self.pos.x + self.size.w*0.5, self.pos.y + self.size.h*0.6, false, 0)	-- Draw back arm
			self.image_zombie_torso.render(self.pos.x, self.pos.y, false, 0)	-- Draw zombie looking right
			self.image_zombie_arm_front.render(self.pos.x + self.size.w*0.5, self.pos.y + self.size.h*0.6, false, 0)	-- Draw front arm

		else -- Mouse is to the left of players center x
			self.image_zombie_arm_back.render(self.pos.x - self.size.w*0.5, self.pos.y + self.size.h*0.6, true, 0)	-- Draw back arm
			self.image_zombie_torso.render(self.pos.x, self.pos.y, true, 0)	-- Draw zombie looking left
			self.image_zombie_arm_front.render(self.pos.x - self.size.w*0.5, self.pos.y + self.size.h*0.6, true, 0)	-- Draw front arm
		end


		-- Render collison boundary body rectangle
		love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle( "line", self.collisionBodyScreenPos.x, self.collisionBodyScreenPos.y, self.collisionBody.w, self.collisionBody.h)
		love.graphics.setColor(255, 255, 255)
    
    -- Render collision boundary head rectangle
    love.graphics.setColor(255, 100, 0)
		love.graphics.rectangle( "line", self.collisionHeadScreenPos.x, self.collisionHeadScreenPos.y, self.collisionHead.w, self.collisionHead.h)
		love.graphics.setColor(255, 255, 255)
    
    
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
    
    
    
		local moveSpeed = self.speed
		if self.touchingPlayer() then
			moveSpeed = 0
		end

		if (self.pos.x + self.size.w/2 < player.pos.x + player.size.w/2) then		-- If zombie is to the left of player
			self.facingDirection = "right"
			self.pos.x = self.pos.x + moveSpeed*dt
		else
			self.facingDirection = "left"
			self.pos.x = self.pos.x - moveSpeed*dt
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


function inventoryClass()
	local self = {}
	self.coins = 0
	self.healthKits = 0
  
  --[[
    Gun stats are stored in global "gunList" table
    Each wave, player starts with a single pistol gun, they can pick up more guns as they go
    These temporary gun class instances are stored in inv.guns table.
  --]]
	self.guns = {pistol = gunClass("pistol")}    -- Player starts with pistol and with gun 1 selected 
  self.selectedGun = "pistol"
  
  print(self.guns["pistol"])
  print(self.guns["ak47"])
  
	self.inventoryRender = false

	self.render = function()
    love.graphics.setColor(0,0,0,150)
    love.graphics.rectangle("fill",100, 100, 1200,500)
    love.graphics.setColor(255,255,255)
    love.graphics.print("Your inventory", 150, 150, 0, 1.5, 1.5)
	end
  
	return self
end

function shopClass()
  local self = {}
  self.shopRender = false
	
  
  --self.shopImage1 = love.graphics.newImage("resources/ak47.png")
  self.ak47Image = imageClass('ak47.png', 150, 150, 0, 0)
  
  
  --src, width, height, originX, originY
  
  
  self.render = function()
    --- main area ---
    love.graphics.setColor(255,255,255,100)
    love.graphics.rectangle("fill",100, 100, 1200,500)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Welcome to the shop", 150, 150, 0, 1.5, 1.5)
    love.graphics.setColor(255,255,255)
    
    
    --- ak47 part ---
    --love.graphics.draw(self.shopImage1, 200, 200, 0, 0.30, 0.30)
    self.ak47Image.render(200, 200, false, 0)	
    
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", 200, 200, 160, 160)
    love.graphics.setColor(255,255,255)
    love.graphics.print("Buy: ak47", 210, 370)
    if love.mouse.getX() > 200 and love.mouse.getX() < 360 and love.mouse.getY() > 200 and love.mouse.getY() < 360 then
      love.graphics.setColor(131,131,131, 100)
      love.graphics.rectangle("fill", 200, 200, 160, 160)
      love.graphics.setColor(255,255,255)
    end
    --- machine gun part ---
	end
  
  return self
end

function coinClass(xPos)
	local self = {} --just a couple things once zombies are added
	self.w = 20  	--this can be more in detail
	self.h = 20
	self.pos = {x=xPos, y=800-self.h}
	self.image = imageClass('coin.png', self.w, self.h, 0, 0)
	return self
end


function gunClass(name)   -- References "gunList" variable defined at the top for stats on each gun
	local self = {}
  
  self.name = name
  self.dmg = gunList[name].dmg
  
	return self
end


function love.draw()

	backgroundImage.render(0, 0, false, 0)	-- Render the background
	groundImage.render(0, 700, false, 0)	-- Render the ground


    --- Zombie Rendering ---
	for i,zombie in ipairs(zombieList) do
		zombie.render()
	end
	

    --- Player Rendering ---
	player.render()
  
  
  	--- Coin rendering ---
	for i,coin in ipairs(coins) do
		coin.image.render(coin.pos.x, coin.pos.y, false, 0)
	end
  
  
    --- Lower Gun Bar Rendering ---
  for gunName,gun in pairs(gunList) do   -- for every gun in gunList, render in gunBar down below
    local imagePos = {x=300 + gun.num*100, y=785}
    
    if (gun.locked) then
      lockImage.render(imagePos.x, imagePos.y, false, 0)
    elseif (inv.guns[gunName] == nil) then
      love.graphics.setColor(0,0,0)
      gun.lowerImage.render(imagePos.x, imagePos.y, false, 0)
      love.graphics.setColor(255,255,255)
    else
      gun.lowerImage.render(imagePos.x, imagePos.y, false, 0)
      
      -- Render number used to select gun
      love.graphics.setNewFont(24)
      love.graphics.print(gun.num, imagePos.x + 10, imagePos.y)
    end
  end

  
    --- Shop Rendering ---
  if shop.shopRender == (true ~= true ~= true) then
    shop.render()
  end
  
    --- Inv Rendering ---
  if inv.inventoryRender then
    inv.render()
  end
	
	


	-- Display Stats --
  love.graphics.setNewFont(16)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print("Coins: " .. tostring(inv.coins), 10, 30)
	love.graphics.print("Zombie Count: " .. tostring(tableLength(zombieList)), 10, 50)



end

function love.update(dt)

	-- Update all zombies --
	for i,zombie in ipairs(zombieList) do
		zombie.update(dt)
	end

	player.update(dt)
  

end

function love.keypressed(key)	
	if key == 'k' then	-- Add coin to random x value when "k" is pressed
		table.insert(coins, coinClass(math.floor(math.random()*1600)))
	end
  
  if key == 't' then
		shop.shopRender = not shop.shopRender
    inv.inventoryRender = false
	end

	if key == 'i' then
		inv.inventoryRender = not inv.inventoryRender
    shop.shopRender = false
	end
end



function tableLength(table)
	local count = 0
	for i in pairs(table) do
		count = count + 1
	end
	return count
end


--[[

	3 layers for player rendering
		1. Player back hand
		2. Player head + torso + legs
		3. Player front arm + gun





--]]
