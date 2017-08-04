  

-- Probably have 9 or less guns, one for each num key 1-9 and 0 for grenades
-- perclick is whether or not gun shoots once per click or if it can be held down to shoot
-- speed is minimum time between bullet shots (doesn't matter whether perclick is true or not)

gunList = {   -- Stats about each gun


  pistol = {
    num=1, 
    holding=true,  
    locked=false, 
    dmg=20, 
    ammo={cur=10, clip=10, backup="Inf", max="Inf"}, 
    speed=1.5,  
    reloadTime=2, 
    price=0,  
    perclick=true,   
    penetration=1, 
    name="Pistol",
    flash={x=-0.479, y=0.181},
    sound={shootVol=1, reloadVol=1},
    player_speed_multiplier=1,
    kills=0
  },
  
  
  ak47 = {
    num=2, 
    holding=false, 
    locked=true, 
    dmg=15,   
    ammo={cur=30, clip=30, backup=120, max=120}, 
    speed=5,  
    reloadTime=2.5, 
    price=10, 
    perclick=false,  
    penetration=1, 
    name="AK47",
    flash={x=-0.594, y=0.144},   -- Amount of pixels moved from players gun rotation flash
    sound={shootVol=0.3, reloadVol=1},
    player_speed_multiplier=0.75,
    kills=0
  },
  
  
  machine =	{
    num=3, 
    holding=false, 
    locked=true, 
    dmg=10,   
    ammo= {cur=50, clip=50, backup=150, max=150}, 
    speed=10, 
    reloadTime=3.5, 
    price=15, 
    perclick=false,  
    penetration=1, 
    name="Machine Gun",
    flash={x=-0.592, y=0.143},
    sound={shootVol=0.6, reloadVol=1},
    player_speed_multiplier=0.6,
    kills=0
  },
  
  
  shotgun =	{
    num=4, 
    holding=false, 
    locked=true, 
    dmg=80,   
    ammo= {cur=4, clip=4, backup=30, max=30}, 
    speed=0.8, 
    reloadTime=2.5, 
    price=15, 
    perclick=true,  
    penetration=3, 
    name="Shotgun",
    flash={x=-0.592, y=0.104},
    sound={shootVol=0.4, reloadVol=1},
    player_speed_multiplier=0.8,
    kills=0
  },
  
  
  sniper =	{
    num=5, 
    holding=false, 
    locked=true, 
    dmg=50,   
    ammo= {cur=5, clip=5, backup=20, max=20}, 
    speed=0.5, 
    reloadTime=4, 
    price=15, 
    perclick=true,  
    penetration=10, 
    name="Sniper Rifle",
    flash={x=-0.592, y=0.134},
    sound={shootVol=0.5, reloadVol=1},
    player_speed_multiplier=0.75,
    kills=0
  },
  
  
  magnum =	{
    num=6, 
    holding=false, 
    locked=true, 
    dmg=30,   
    ammo= {cur=6, clip=6, backup=50, max=50}, 
    speed=0.7, 
    reloadTime=2.5, 
    price=15, 
    perclick=true,  
    penetration=5, 
    name=".44 Magnum",
    flash={x=-0.52, y=0.21},
    sound={shootVol=0.4, reloadVol=1},
    player_speed_multiplier=1,
    kills=0
  }

  --rocket =	{num=7, holding=false, locked=true,  dmg=10,  ammo={cur=20, clip=20, backup=100, max=100}, speed=10, reloadTime=3, price=50,   perclick=true,   penetration=1, name="Rocket Launcher"}
  
}

  -- Add image variables to each gun type ---
for gunName,gun in pairs(gunList) do
  gun.lowerImage = imageClass("guns/".. gunName .. "/lowerImage.png", 120, 120, 0, 0)
  gun.shopImage = imageClass("guns/".. gunName .. "/lowerImage.png", 160, 160, 0, 0)
  gun.dropImage = imageClass("guns/".. gunName .. "/lowerImage.png", 70, 70, 0, 0)
  
  gun.image_Front_Arm = imageClass("guns/".. gunName .. "/front_arm.png", 320, 320, 0.4, 0.65)
  gun.image_Back_Arm = imageClass("guns/".. gunName .. "/back_arm.png", 320, 320, 0.4, 0.65)
  
  
  gun.sound.shootSound = love.audio.newSource("resources/sound/guns/".. gunName .. "_shoot.ogg", "static")
  gun.sound.reloadSound = love.audio.newSource("resources/sound/guns/".. gunName .. "_reload.ogg", "static")
  
end

  
  
  
  
  
  
  