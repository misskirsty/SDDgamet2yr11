
function love.load()
	love.window.setMode(1600, 900, {resizable=true,vsync=true})
	width = 160
	height = 100
	image = love.graphics.newImage('farm.jpg')
	playerimage = love.graphics.newImage('Stick_figure.png')
  playergun = love.graphics.newImage('gun.png')
	playerx = 400
	playery = 600
  playergunx = playerx + 140
  scalefactorx = 1
  scalefactory = scalefactorx



end



function testmouse()

end

function love.keypressed(key)
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
  if scalefactorx == -1 then
    radians = math.pi - radians
  end
  if scalefactorx == -1 and love.mouse.getX() > playergunx then
    radians = 1/radians
  end
  trigdis = love.mouse.getX() - playergunx
  trigheight = love.mouse.getY() - playery
  radians = math.atan(trigheight/trigdis)
end


