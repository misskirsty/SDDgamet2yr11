
function love.load()
  
  require("player")
  require("zombie")
  
  gunShot = love.audio.newSource("resources/sound/pistol_shot.ogg", "static")
  
  -- Probably have 9 or less guns, one for each num key 1-9 and 0 for grenades
  gunList = {   -- Stats about each gun
  -- perclick is whether or not gun shoots once per click or if it can be held down to shoot
  -- speed is minimum time between bullet shots (doesn't matter whether perclick is true or not)
		pistol =	{num=1,   locked=false, dmg=10,    maxammo=100, speed=10, 	price=0,    perclick=true,    penetration=1,    imgSrc="lowerImage/glock.png",    name="Pistol"},
		ak47 =		{num=2,   locked=false, dmg=10,    maxammo=30, 	speed=30, 	price=30,   perclick=false,   penetration=1,    imgSrc="lowerImage/ak47.png",     name="AK47"},
    machine =	{num=3,   locked=false, dmg=10,   maxammo=50, 	speed=100, 	price=100,  perclick=false,   penetration=1,    imgSrc="lowerImage/machine.png",  name="Machine Gun"},
    sniper =	{num=4,   locked=true, 	dmg=10,    maxammo=10, 	speed=10, 	price=30,   perclick=true,    penetration=1,    imgSrc="lowerImage/ak47.png",     name="Sniper Rifle"},
    magnum =	{num=5,   locked=true, 	dmg=10,    maxammo=10, 	speed=10, 	price=30,   perclick=true,    penetration=1,    imgSrc="lowerImage/ak47.png",     name="Magnum"},
    rocket =	{num=6,   locked=true, 	dmg=10,    maxammo=10, 	speed=10, 	price=30,   perclick=true,    penetration=1,    imgSrc="lowerImage/ak47.png",     name="Rocket Launcher"}
	}
  
  for i,gun in pairs(gunList) do
    gun.lowerImage = imageClass(gun.imgSrc, 100, 100, 0, 0)
    gun.shopImage = imageClass(gun.imgSrc, 175, 175, 0, 0)
  end
  

	love.window.setMode(1600, 900, {resizable=false,vsync=false})

	crosshair = love.mouse.newCursor(love.image.newImageData("resources/crosshair48.png"), 24, 24)
	love.mouse.setCursor(crosshair)
	
	backgroundImage = imageClass("background.jpg", 1600, 900, 0, 0)
	groundImage = imageClass("ground.png", 1600, 300, 0, 0)
  groundLowerImage = imageClass("ground_lower.png", 1600, 190, 0, 0)

	droppedItems = {}

  main = mainClass()

	player = playerClass()

	inv = inventoryClass()
  shop = shopClass()
  waveHandler = waveClass()

	zombieList = {}

	coins = {coinClass(900)}
  
  
  -- Lock Image for lower gun bar
  lockImageInv = imageClass("lowerImage/lock.png", 100, 100, 0, 0)
  lockImageShop = imageClass("lowerImage/lock.png", 175, 175, 0, 0)

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
	self.render = function(x, y, flipped, rotation) 	-- Renders image at position 'x','y' with rotation 'r'
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
    
    
    
    for gunName,gun in pairs(gunList) do   -- for every gun in gunList, render in gunBar down below
      
      local imagePos = {x=300 + gun.num*110, y=785}
      
      love.graphics.setColor(105, 109, 114)
      love.graphics.rectangle("fill", imagePos.x, imagePos.y, 100, 100)
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("line", imagePos.x, imagePos.y, 100, 100)
      love.graphics.setColor(255, 255, 255)
      
      
      --local imagePos = {x=300 + gun.num*100, y=785}
        --- Render gun images ---
      if (gun.locked) then
        lockImageInv.render(imagePos.x, imagePos.y, false, 0)
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
    love.graphics.rectangle("fill",100, 100, 1400, 500)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Welcome to the shop", 150, 150, 0, 1.5, 1.5)
    love.graphics.setColor(255,255,255)
    
    
      --- Render Guns Images ---
    for gunName,gun in pairs(gunList) do   -- for every gun in gunList, render in gunBar down below
      
      local imagePos = {x=200 + (gun.num-1)*175, y=200}
      local imageSize = {w=175, h=175}
      
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("line", imagePos.x, imagePos.y, imageSize.w, imageSize.h)
      love.graphics.setColor(255, 255, 255)
      
      
    
        --- Render gun images ---
      if (gun.locked) then
        lockImageShop.render(imagePos.x, imagePos.y, false, 0)
      elseif (inv.guns[gunName] == nil) then
        love.graphics.setColor(0,0,0)
        gun.shopImage.render(imagePos.x, imagePos.y, false, 0)
        love.graphics.setColor(255,255,255)
      else
        gun.shopImage.render(imagePos.x, imagePos.y, false, 0)
      end
      
      -- Darken gun boxes on hover
      if (imagePos.x <= love.mouse.getX() and love.mouse.getX() <= imagePos.x + imageSize.w) then
        if (imagePos.y <= love.mouse.getY() and love.mouse.getY() <= imagePos.y + imageSize.h) then
          love.graphics.setColor(0, 0, 0, 100)
          love.graphics.rectangle("fill", imagePos.x, imagePos.y, imageSize.w, imageSize.h)
          love.graphics.setColor(255, 255, 255)
        end
      end
      
      
      if gun.locked then
        -- Gun is locked so say "Buy Gun"
        love.graphics.setNewFont(18)
        love.graphics.print("Buy \n" .. gun.name, imagePos.x + 10, imagePos.y + imageSize.w + 5)
      else
          -- Gun is unlocked so say "Bought Gun"
        love.graphics.setNewFont(18)
        love.graphics.print("Bought \n" .. gun.name, imagePos.x + 10, imagePos.y + imageSize.w + 5)
      end
      
    end
    
	end
  
  return self
end

function coinClass(xPos)
	local self = {} --just a couple things once zombies are added
	self.w = 20  	--this can be more in detail
	self.h = 20
	self.pos = {x=xPos, y=800-self.h-100}
	self.image = imageClass('coin.png', self.w, self.h, 0, 0)
	return self
end


function gunClass(name)   -- References "gunList" variable defined at the top for stats on each gun
	local self = {}
  
  self.name = name
  self.dmg = gunList[name].dmg
  
	return self
end

function waveClass()   -- handles waves
	local self = {}
  
  self.waveNum = 1
  self.startTime = 3   -- Time needed to wait before any zombie start spawning
  self.zombieSpawnTime = self.startTime
  
  self.waveInfo = {
      {count = 10, spawnTime = 1},
      {count = 15, spawnTime = 0.9},
      {count = 20, spawnTime = 0.8}
  }

  self.waveTime = 0
  
  self.textFadeIn = 2
  self.textFadeOut = 1
  


  self.update = function(dt)    -- Runs every frame, spawns zombies when it should happen
    
    self.waveTime = self.waveTime + dt
      
    if (self.waveInfo[self.waveNum].count == 0) then -- If enough zombies have been spawned in wave
      if (#zombieList == 0) then
        self.waveNum = self.waveNum + 1
        self.zombieSpawnTime = self.startTime
        self.waveTime = 0
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
        
      
      love.graphics.setNewFont(200)
      love.graphics.setColor(255, 255, 255, textTransparency)
      love.graphics.printf("Wave " .. self.waveNum, 0, 200, 1600, "center")
      love.graphics.setColor(255, 255, 255)
      
    end
    
  end
  
	return self
end


function mainClass()
  local self = {}
  
  self.state = "main"
  
  self.update = function()
  
    if love.mouse.isDown(1) then
      
      main.state = "game"
      
    end
    
  end
  
  self.render = function()
    
    love.graphics.setNewFont(100)
    love.graphics.print("Main Menu", 200, 200)
    
  end
  
  return self
end


function love.draw()

  if main.state == "main" then
    
    main.render()
    
  elseif main.state == "game" then
  

      --- Render background stuff ---
    backgroundImage.render(0, 0, false, 0)	-- Render the background
    groundImage.render(0, 600, false, 0)	-- Render the ground


      --- Zombie Rendering ---
    for i,zombie in ipairs(zombieList) do
      zombie.render()
    end
    
    groundLowerImage.render(0, 700, false, 0)	-- Render the second ground image
    

      --- Player Rendering ---
    player.render()
    
    
      --- Coin rendering ---
    for i,coin in ipairs(coins) do
      coin.image.render(coin.pos.x, coin.pos.y, false, 0)
    end

    
      --- Shop Rendering ---
    if shop.shopRender == (true ~= true ~= true) then
      shop.render()
    end
    
      --- Inv Rendering ---
    inv.render()

      --- Wave stats rendering ---
    waveHandler.render()


    -- Display Stats --
    love.graphics.setNewFont(16)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print("Coins: " .. tostring(inv.coins), 10, 30)
    love.graphics.print("Zombie Count: " .. tostring(#zombieList), 10, 50)

  end

end

function love.update(dt)

  if main.state == "main" then
    
    main.update()
    
  end
    
  if main.state == "game" then
    
    waveHandler.update(dt)

    -- Update all zombies --
    for i,zombie in ipairs(zombieList) do
      zombie.update(dt)
    end
    
    -- Loop through zombieList backwards, removing any zombies that should be dead
    for i=#zombieList,1,-1 do
        if zombieList[i].deathTime >= zombieList[i].deathTurningTime + zombieList[i].deathSinkingTime then
          table.remove(zombieList, i)
        end
    end


    player.update(dt)
  
  end

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


--[[

	3 layers for player rendering
		1. Player back hand
		2. Player head + torso + legs
		3. Player front arm + gun





--]]
