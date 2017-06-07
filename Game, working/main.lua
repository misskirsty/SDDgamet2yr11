function love.load()

	love.window.setMode(1600, 900, {resizable=true,vsync=true})

	backimage = love.graphics.newImage('resources/farm.jpg')
	--[[
	width = 160
	height = 100
	playerimage = love.graphics.newImage('resources/Stick_figure.png')
	playergun = love.graphics.newImage('resources/gun.png')
	playerx = 400
	playery = 600
	playergunx = playerx + 140
	--]]

	player = playerClass()
	inv = inventoryClass()
  coins = {coinClass(100)}
	--print(player.image.ox)
	--print(player.pos.x)
  gunList = {
    pistol={locked=false, maxammo='all of it', speed=10, price=0},
    machine={locked=true, maxammo=50, speed=100, price=100},
    ak47={locked=true, maxammo=30, speed=30, price=30}
  }
end

function playerClass()
	local self = {}
	self.pos = {x=100, y=620}
	self.size = {w=100, h=180}	-- width/height of player image in pixels
	self.speed = 200		-- Pixels per second

	self.gunImage = imageClass('gun.png', 100, 70, 0, 0.5)-- Default gun image is gun facing the right
	self.pImage = imageClass('player.png', self.size.w, self.size.h, 0, 0)		-- Default image is player looking to the right

	return self
end


function imageClass(src, width, height, originX, originY)	-- A class to handle images
	local self = {}
	self.image = love.graphics.newImage('resources/' .. src)
	self.w = width
	self.h = height
	self.sx = self.w/self.image:getWidth()
	self.sy = self.h/self.image:getHeight()
	self.ox = originX*self.image:getWidth() -- Offset as a decimal based on image width/height from the (0,0) render point and rotation pivot point
	self.oy = originY*self.image:getHeight()
	self.render = function(x, y, flipped, rotation) 	-- Renders image at position 'x','y' with rotation 'r'\
		--print("rendering")
		if (flipped == false) then
			love.graphics.draw(self.image, x, y, rotation, self.sx, self.sy, self.ox, self.oy)
		else
			love.graphics.draw(self.image, x + self.w, y, rotation, -self.sx, self.sy, self.ox, self.oy)
		end
	end
	return self
end

function inventoryClass()
	local self = {}
	self.coins = 0
	--self.coinpos = {x=100,y=620}
	self.health = 0
	self.gun = {gunList.pistol}
-- gunClass()
	--if self.coin == 5 then
		--print(coinamount)
	return self
end

function coinClass(xPos)
	local self = {} --just a couple things once zombies are added
	self.w = 20  	--this can be more in detail
	self.h = 20
	self.pos = {x=xPos, y=800-self.h}
	self.image = imageClass('coin1.png',self.w,self.h,0,0)
	return self
end


function shopClass()
  local self = {}
  self.items = 
end
function gunClass(guntype, gundamage, gundurability, gunprice)
  local self = {}
  self.dropped = {}
  self.available = {}
end
function love.draw()

	love.graphics.draw( backimage,0,0) -- background
  
  for i,v in ipairs(coins) do
    v.image.render(v.pos.x,v.pos.y,false,0)
  end

	love.graphics.setColor(0, 0, 255)
	love.graphics.rectangle( "fill", 0, 800, 1600, 100)	-- Render the ground
	love.graphics.setColor(255, 255, 255)


	-- Check where mouse is relative to player to render player orientation correctly
	--print(player.pos.x)
	mouseOffsetX = love.mouse.getX() - (player.pos.x + player.size.w/2)
	mouseOffsetY = love.mouse.getY() - (player.pos.y + player.size.w/2)

	mouseAngle = math.atan(mouseOffsetY/mouseOffsetX)	-- Angle from player to mouse pos
	--print(mouseAngle)

	if mouseOffsetX > 0 then -- Mouse is to the right of players center x

		player.pImage.render(player.pos.x, player.pos.y, false, 0)	-- Draw player looking right

		player.gunImage.render(player.pos.x + player.size.w, player.pos.y + player.size.h*0.3, false, mouseAngle)	-- Draw gun

	else -- Mouse is to the left of players center x
		player.pImage.render(player.pos.x, player.pos.y, true, 0)	-- Draw player looking left

		player.gunImage.render(player.pos.x - player.size.w, player.pos.y + player.size.h*0.3, true, mouseAngle)	-- Draw gun

	end

	--love.graphics.draw(playerimage, playerx, playery, 0, scalefactorx, scalefactory)
	--love.graphics.draw(playergun, playergunx, playery, radians, scalefactorx, scalefactory)


	-- Display FPS
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
  love.graphics.print("Coins: "..tostring(inv.coins), 10, 30)
end

function love.update(dt)
	--if (player.pos.x == inv.coinpos.x) then
		--print('player is on the coin')
  for i,v in ipairs(coins) do
    if (v.pos.x + v.w > player.pos.x) and (v.pos.x < player.pos.x + player.size.w) then
      table.remove(coins,i)
      inv.coins = inv.coins + 1
    end
  end
	-- Test for input and move player
	if love.keyboard.isDown('d') then
		player.pos.x = player.pos.x + player.speed*dt
	elseif love.keyboard.isDown('a') then
		player.pos.x = player.pos.x - player.speed*dt
	end
end

function love.keypressed(key)
  if key == 'k' then
    table.insert(coins, coinClass(math.floor(math.random()*1600)))
  end
end


