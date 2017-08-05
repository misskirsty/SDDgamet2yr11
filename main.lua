
function love.load()
  
  require("player")
  require("zombie")
  require("shop")
  require("inventory")
  require("escape")
  require("wave")
  require("droppedItem")
  require("gunList")
  require("dead")
  require("tutorial")
  
  love.window.setMode(1600, 900, {resizable=false,vsync=false})

	crosshair = love.mouse.newCursor(love.image.newImageData("resources/crosshair48.png"), 24, 24)
	love.mouse.setCursor(crosshair)

  cratePickupSound = love.audio.newSource("resources/sound/crate_pickup.ogg", "static")
  buttonClickSound = love.audio.newSource("resources/sound/button_click.ogg", "static")
  
  statsFont = love.graphics.setNewFont('resources/shop_font2.ttf', 20)     -- For stats in top left
  
  
  -- Lock Image for lower gun bar
  lockImageInv = imageClass("lock.png", 120, 120, 0, 0)
  lockImageShop = imageClass("lock.png", 160, 160, 0, 0)

  ammoDropImage = imageClass("ammo.png", 70, 70, 0, 0)
  crateDropImage = imageClass("crate.png", 120, 120, 0, 0)
	
	backgroundImage = imageClass("background.png", 1600, 900, 0, 0)
  mainBackgroundImage = imageClass("main_menu_background.jpg", 1600, 900, 0, 0)
  
  --- Menu stuff
  main = mainClass()
  esc = escapeMenuClass()
  tut = tutorialClass()
  dead = deadClass()
  
  player = playerClass()
	inv = inventoryClass()
  shop = shopClass()
  waveHandler = waveClass()

  
	droppedItems = {}	
  zombieList = {}
  mouseDown = false
  mouseClicked = false
  
  
  ITEM_DROP_CHANCE = 1/5

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


function mainClass()
  local self = {}

  self.state = "main"
  
  self.font1 = love.graphics.setNewFont('resources/main_font.ttf', 64)
  self.font2 = love.graphics.setNewFont('resources/main_font.ttf', 40)
  
  self.menu_music = love.audio.newSource("resources/sound/home_screen_music.ogg")
  self.playingMusic = false

  self.buttons = {
    {
      text = "Continue", 
      onclick = function()

        if player.health.cur > 0 then  -- Continue game if player is not dead
          main.state = "game"
          
          self.playingMusic = false
          self.menu_music:setVolume(0.2)
          --self.menu_music:stop()
        end
        
      end
    },
    {
      text = "New Game", 
      onclick = function()
        waveHandler.restartGame()
        self.playingMusic = false
        self.menu_music:setVolume(0.2)
        --self.menu_music:stop()
      end
    },
    {
      text = "Tutorial",
      onclick = function()
        waveHandler.restartGame()
        main.state = "tutorial"
        tut.stage = 1
      end
    },
    {
      text = "Quit Game",
      onclick = function()
        love.event.quit()
      end
    }
  }

  self.render = function()
   
    mainBackgroundImage.render(0, 0, false, 0)	-- Render the background
    
    love.graphics.setFont(self.font1)
    love.graphics.printf("Lua Zombie Game", 0, 50, 1600, "center")
    
    love.graphics.setFont(self.font2)
    for i,button in ipairs(self.buttons) do   -- Render each button in the main menu
      local buttonRect = {x=500, y= 220 + (i-1)*160, w=600, h=155}
      
      if button.text == "Continue" and player.health.cur <= 0 then
        love.graphics.setColor(127, 127, 127)
      else
        love.graphics.setColor(255, 255, 255)
      end
      love.graphics.printf(button.text, buttonRect.x, buttonRect.y + 30, buttonRect.w, "center")
      
      
      if mouseInRect(buttonRect) then
        love.graphics.setColor(0, 0, 0, 100)
        love.graphics.rectangle("fill", buttonRect.x, buttonRect.y, buttonRect.w, buttonRect.h)
        love.graphics.setColor(255, 255, 255)
      end
    end
    
  end

  self.update = function()    -- Runs every update when state is main
    
    if not self.playingMusic then
      self.playingMusic = true
      self.menu_music:setVolume(1)
      self.menu_music:stop()
      self.menu_music:play()
    end
    
    if mouseClicked then  
      
      for i,button in ipairs(self.buttons) do
        local buttonRect = {x=500, y= 220 + (i-1)*160, w=600, h=155}
        if mouseInRect(buttonRect) then
          button.onclick()
          mouseClicked = false
          
          if button.text ~= "Continue" or player.health.cur > 0 then    -- Play button click noise
            buttonClickSound:setVolume(1)
            buttonClickSound:stop()
            buttonClickSound:play()
          end
          break
        end
      end
      
    end
    
  end
   
  return self
end


function love.draw()

  if main.state == "main" then
    
    main.render()
    
  elseif main.state == "tutorial" then
    
    tut.render(dt)
    
  else  -- Either in game or dead
  

      --- Render background stuff ---
    backgroundImage.render(0, 0, false, 0)	-- Render the background


      --- Zombie Rendering ---
    for i,zombie in ipairs(zombieList) do
      zombie.render()
    end
    

      --- Player Rendering ---
    player.render()

    
      --- Dropped item rendering ---
    for i,item in ipairs(droppedItems) do
      item.render()
    end
    
    
      --- Inv Rendering ---
    inv.render()

      --- Render Wave Info ---
    waveHandler.render()
    
    
      --- Shop Rendering ---      done last to appear over the top of everything
    if shop.isOpen then
      shop.render()
    end

      --- Render escape menu ---
    esc.render()


    -- Display Stats --
    love.graphics.setFont(statsFont)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    --love.graphics.print("Zombie Count: " .. tostring(#zombieList), 10, 30)
    --love.graphics.print(player.shotCooldown, 10, 50)    -- Temporarily render shotCooldown


    -- Render stuff if player is dead
    if (main.state == "dead") then
      
      --love.graphics.setNewFont(100)
      --love.graphics.printf("Game Over", 0, 200, 1600, "center")
      
      dead.render()
      
    end
    
  end

end

function love.update(dt)
  
  -- mouseClicked is equal to if button was only just clicked that update
  -- mouseDown is equal to if mouse is being held down
  if love.mouse.isDown(1) then
    if not mouseDown then
      mouseClicked = true
    else
      mouseClicked = false
    end
    mouseDown = true
  else
    mouseDown = false
    mouseClicked = false
  end
  

  if main.state == "main" then
    
    main.update()
    
  end
    
  if main.state == "tutorial" then
    
    tut.update(dt)
    
  end
    
  if main.state == "game" then    -- Allows game to update the moment main.state is set to game
    
    esc.update()
    
    if not esc.isOpen then
      
      if shop.isOpen then   -- Only update shop if it is open
        
        shop.update()
      
      else   -- Otherwise update everything else (waves etc.)
      
        waveHandler.update(dt)

        --- Update all zombies ---
        for i,zombie in ipairs(zombieList) do
          zombie.update(dt)
        end
        -- Loop through zombieList backwards, removing any zombies that should be dead
        for i=#zombieList,1,-1 do
            if zombieList[i].deathTime >= zombieList[i].deathTurningTime + zombieList[i].deathSinkingTime then
              table.remove(zombieList, i)
            end
        end
        

          --- Dropped item updating ---       allows picking up and falling effect
        for i,item in ipairs(droppedItems) do
          item.update(dt)
        end
        -- Loop through droppedItems backwards, removing any items that have been picked up
        for i=#droppedItems,1,-1 do
            if droppedItems[i].deleteMe then
              table.remove(droppedItems, i)
            end
        end

        
        --- Update inv ---     allows switching betweeb guns in gun bar
        inv.update()

        --- Update player ---
        player.update(dt)
      
      end
    end
    
  elseif main.state == "dead" then    -- Player is dead, update other things
    
      --- Update all zombies ---
    for i,zombie in ipairs(zombieList) do
      zombie.update(dt)
    end
    
      --- Dropped item updating ---       allows picking up and falling effect
    for i,item in ipairs(droppedItems) do
      item.update(dt)
    end
    
    
    dead.update()
    
  end

end

function love.keypressed(key)	

	if key == 't' then
		--waveHandler.endWave()
	end
  
  if key == 'k' then
		--player.health.cur = 0
	end
  
end


function mouseInRect(rect)  -- Returns whether player clicked inside rectangle
  
  if (rect.x <= love.mouse.getX() and love.mouse.getX() <= rect.x + rect.w) then
    if (rect.y <= love.mouse.getY() and love.mouse.getY() <= rect.y + rect.h) then
      return true
    end
  end
  
end

