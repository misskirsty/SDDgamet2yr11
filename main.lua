
function love.load()

	love.window.setMode(1600, 900, {resizable=false,vsync=true})


	crosshair = love.mouse.newCursor(love.image.newImageData("resources/crosshair.png"), 32, 32)
	love.mouse.setCursor(crosshair)
	
	backgroundImage = imageClass("background.jpg", 1600, 900, 0, 0)
	groundImage = imageClass("ground.png", 1600, 200, 0, 0)

	droppedItems = {}

	player = playerClass()
	inv = inventoryClass()

	zombieList = {zombieClass(), zombieClass(), zombieClass()}


	--print(player.image.ox)
	--print(player.pos.x)

	coins = {coinClass(900)}

	gunList = {
		pistol =	{locked=false, 	maxammo=100, 	speed=10, 	price=0},
		machine =	{locked=true, 	maxammo=50, 	speed=100, 	price=100},
		ak47 =		{locked=true, 	maxammo=30, 	speed=30, 	price=30}
	}

end



function playerClass()
	local self = {}
	self.pos = {x=100, y=800-256}
	self.size = {w=256, h=256}	-- width/height of player image in pixels

	self.collisionBoundary = {x=80, y=36, w=94, h=220}		
	
	self.walkTime = 0		-- How long player has been walking for in seconds
	self.speed = 200		-- Pixels per second

	self.gunImage = imageClass('gun.png', 100, 100, 0, 0.5)	-- Default gun image is gun facing the right

	self.image_player_torso = imageClass('player_torso.png', self.size.w, self.size.h, 0, 0)		-- Default image is player looking to the right
	self.image_player_arm_front = imageClass('player_arm_front.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is player looking to the right
	self.image_player_arm_back = imageClass('player_arm_back.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is player looking to the right

	
	self.render = function()
		-- Check where mouse is relative to player to render player orientation correctly
		--print(player.pos.x)
		mouseOffsetX = love.mouse.getX() - (self.pos.x + self.size.w/2)
		mouseOffsetY = love.mouse.getY() - (self.pos.y + self.size.w/2)

		mouseAngle = math.atan(mouseOffsetY/mouseOffsetX)	-- Angle from player to mouse pos
		--print(mouseAngle)
		if (mouseAngle > 1) then	-- Stop player from looking too far up/down
			mouseAngle = 1
		elseif (mouseAngle < -1) then
			mouseAngle = -1
		end


		armBob = math.sin(self.walkTime * 8) * 3	-- How much the arm is currently bobbing from its original position (ranges from -3 to 3)

		if (mouseOffsetX > 0) then -- Mouse is to the right of players center x
			self.image_player_arm_back.render(self.pos.x + self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, false, mouseAngle)	-- Draw back arm
			self.image_player_torso.render(self.pos.x, self.pos.y, false, 0)	-- Draw player looking right
			self.image_player_arm_front.render(self.pos.x + self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, false, mouseAngle)	-- Draw front arm
		else -- Mouse is to the left of players center x
			self.image_player_arm_back.render(self.pos.x - self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, true, mouseAngle)	-- Draw back arm
			self.image_player_torso.render(self.pos.x, self.pos.y, true, 0)	-- Draw player looking left
			self.image_player_arm_front.render(self.pos.x - self.size.w/2, self.pos.y + self.size.h*0.6 + armBob, true, mouseAngle)	-- Draw front arm
		end

		-- Render collison boundary box
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle( "line", self.pos.x + self.collisionBoundary.x, self.pos.y + self.collisionBoundary.y, self.collisionBoundary.w, self.collisionBoundary.h)
		love.graphics.setColor(255, 255, 255)

	end

	self.update = function(dt)
	 	-- Check player collision with every coin --
		for i,coin in ipairs(coins) do
			if (coin.pos.x + coin.w > player.pos.x + player.collisionBoundary.x) and (coin.pos.x < player.pos.x + player.collisionBoundary.x + player.collisionBoundary.w) then
				table.remove(coins,i)
				inv.coins = inv.coins + 1
			end
		end

		-- Test for input and move player
		local moveSpeed = self.speed
		if self.touchingZombie() then
			moveSpeed = moveSpeed * 0.5
		end

		if love.keyboard.isDown('d') then
			player.pos.x = player.pos.x + moveSpeed*dt

			player.walkTime = player.walkTime + dt 	-- Bob arms up and down
		elseif love.keyboard.isDown('a') then
			player.pos.x = player.pos.x - moveSpeed*dt

			player.walkTime = player.walkTime + dt 	-- Bob arms up and down
		end
	end

	self.touchingZombie = function()	-- Returns true if player is colliding with a zombie, otherwise returns false
		for i,zombie in ipairs(zombieList) do
			if (zombie.pos.x + zombie.collisionBoundary.x + zombie.collisionBoundary.w > player.pos.x + player.collisionBoundary.x) then	-- If right of zombie > left of player
				if (zombie.pos.x + zombie.collisionBoundary.x < player.pos.x + player.collisionBoundary.x + player.collisionBoundary.w) then	-- If left of zombie < right of player
					return true
				end
			end
		end
		return false
	end

	return self
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

function zombieClass()	-- Side is left/right 
	local self = {}
	self.pos = {x=100, y=800-256}
	self.size = {w=256, h=256}
	self.collisionBoundary = {x=80, y=36, w=94, h=220}	

	--self.image = imageClass('zombie.jpg', self.size.w, self.size.h, 0, 0)

	self.image_zombie_arm_back = imageClass('zombie_arm_back.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is zombie looking to the right
	self.image_zombie_torso = imageClass('zombie_torso.png', self.size.w, self.size.h, 0, 0)		-- Default image is zombie looking to the right
	self.image_zombie_arm_front = imageClass('zombie_arm_front.png', self.size.w, self.size.h, 0.5, 0.6)		-- Default image is zombie looking to the right


	self.speed = 60	-- Speed in pixels per second

	self.facingDirection = "right"

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


		-- Render collison boundary box
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle( "line", self.pos.x + self.collisionBoundary.x, self.pos.y + self.collisionBoundary.y, self.collisionBoundary.w, self.collisionBoundary.h)
		love.graphics.setColor(255, 255, 255)
	end

	self.update = function(dt)
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

	self.touchingPlayer = function()	-- Returns true if zombie is colliding with the player, otherwise returns false
		if (player.pos.x + player.collisionBoundary.x + player.collisionBoundary.w > self.pos.x + self.collisionBoundary.x) then	-- If right of player > left of zombie
			if (player.pos.x + player.collisionBoundary.x < self.pos.x + self.collisionBoundary.x + self.collisionBoundary.w) then	-- If left of player < right of zombie
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
	self.gun = {pistol = gunClass("pistol")}    -- Player starts with pistol

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


function gunClass(name)   -- guntype, gundamage, gundurability, gunprice
	local self = {}
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


	-- Display Stats --
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print("Coins: "..tostring(inv.coins), 10, 30)
	love.graphics.print("Zombie Count: "..tostring(tableLength(zombieList)), 10, 50)


	-- Render Crosshair at mouse --


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
