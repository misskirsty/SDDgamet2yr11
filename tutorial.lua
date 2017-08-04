
function tutorialClass()
  local self = {}
  
  self.font1 = love.graphics.setNewFont('resources/shop_font2.ttf', 45) 
  self.font2 = love.graphics.setNewFont('resources/shop_font2.ttf', 30)
  self.font3 = love.graphics.setNewFont('resources/shop_font2.ttf', 50) 
  
  self.stage = 1
  self.stages = {
    {
      title = "Moving Around",
      text = "Used the 'A' and 'D' keys to move left and right across the screen.",
      test = function()
        return (player.walkTime > 1)
      end,
      setup = function()
      end
    },
    {
      title = "Shooting",
      text = "Shooting is a fundamental part of the game, move the mouse around and click to shoot.",
      test = function()
        return mouseClicked
      end,
      setup = function()
      end
    },
    {
      title = "Reloading",
      text = "After using up bullets, try reloading by pressing 'r'. The gun is also automatically reloaded when you run out of bullets in the clip.",
      test = function()
        return (love.keyboard.isDown('r') and gunList.pistol.ammo.cur < gunList.pistol.ammo.clip)
      end,
      setup = function()
      end
    },
    {
      title = "Zombies",
      text = "Zombies will appear from either the left or right side and will attempt to get to you, try shooting a zombie until it dies.",
      test = function()
        return (gunList.pistol.kills == 1)
      end,
      setup = function()
        gunList.ak47.locked = false
        table.insert(zombieList, zombieClass())
        zombieList[1].attackDmg = 0
      end
    },
    {
      title = "Gun Crate",
      text = "Collecting gun crates gives you the gun for the rest of the wave. Collect the AK47 crate on the ground and equip it with the number keys.",
      test = function()
        return (inv.selectedGun == "ak47")
      end,
      setup = function()

      end
    },
    {
      title = "Tutorial Complete!",
      text = "All done, click the button in the top left to head back to the main menu and start a game with the new game button.",
      test = function()
        return false
      end,
      setup = function()
      end
    }
  }
  
  
  self.render = function(dt)
    
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
    
    
    
    --self.image.render(0,0, false, 0)
    local backRect = {x=20, y=20, w=350, h=80}
    love.graphics.setColor(100, 100, 100)
    love.graphics.rectangle("fill", backRect.x, backRect.y, backRect.w, backRect.h)
    love.graphics.setColor(255, 255, 255)
    if mouseInRect(backRect) then
      love.graphics.setColor(0, 0, 0, 70)
      love.graphics.rectangle("fill", backRect.x, backRect.y, backRect.w, backRect.h)
      love.graphics.setColor(255, 255, 255)
    end
    love.graphics.setColor(150, 150, 150)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", backRect.x, backRect.y, backRect.w, backRect.h)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(self.font3)
    love.graphics.printf("Main Menu", backRect.x+20, backRect.y+20, backRect.w-40, "center")
    
    
    -- Render tutorial box
    local tutRect = {x=1050, y=120, w=500, h=270}
    love.graphics.setColor(100, 100, 100, 150)
    love.graphics.rectangle("fill", tutRect.x, tutRect.y, tutRect.w, tutRect.h)
    love.graphics.setColor(150, 150, 150)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", tutRect.x, tutRect.y, tutRect.w, tutRect.h)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(self.font1)
    love.graphics.printf(self.stages[self.stage].title, tutRect.x+20, tutRect.y+20, tutRect.w-40, "left")
    love.graphics.setFont(self.font2)
    love.graphics.printf(self.stages[self.stage].text, tutRect.x+20, tutRect.y+80, tutRect.w-40, "left")
    
  end
  
  self.update = function(dt)
    local backRect = {x=10, y=20, w=500, h=100}
    if love.mouse.isDown(1) and mouseInRect(backRect) then
      
      player.health.cur = 0
      main.state = "main"
      mouseClicked = false
      
    else
      if self.stages[self.stage].test() then
        self.stage = self.stage + 1
        self.stages[self.stage].setup()
      end
    
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
  
  return self
end