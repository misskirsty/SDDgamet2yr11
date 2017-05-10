
function love.load()
	love.window.setMode(1600, 900, {resizable=true,vsync=true})
	width = 160
	height = 100
	image = love.graphics.newImage('resources/farm.jpg')
	playerimage = love.graphics.newImage('resources/Stick_figure.png')
  playergun = love.graphics.newImage('resources/gun.png')
	playerx = 400
	playery = 600
  playergunx = playerx + 140



end



function testmouse()

end

function love.keypressed(key)
	scalefactorx = 1
	scalefactory = scalefactorx
	if key == 'a' then
		playerx = playerx - 20
    scalefactorx = -1
    playergunx = playerx - 140
  elseif key == 'd' then
		playerx = playerx + 20
    scalefactorx = 1
    playergunx = playerx + 140
  end
end


function drawplayer()

end


function love.draw()

	love.graphics.draw( image,0,0) --image, x, y, r, sx, sy, ox, oy, kx, ky
	love.graphics.draw(playerimage, playerx, playery, 0, scalefactorx, scalefactory)
  love.graphics.draw(playergun, playergunx, playery, radians, scalefactorx, scalefactory)
end

function love.update()
	trigdis = love.mouse.getX() - playergunx
	trigheight = love.mouse.getY() - playery
	radians = math.atan(trigheight/trigdis)
  if scalefactorx == -1 then
    radians = math.pi - radians
		radians = math.atan(trigheight/trigdis)
		if playergunx < love.mouse.getX() then
		radians = -radians
		end
  end
end
