
function love.load()
	love.window.setMode(800, 800, {resizable=true,vsync=true})
	width = 160
	height = 100
	image = love.graphics.newImage('farm.jpg')
	playerimage = love.graphics.newImage('Stick_figure.png')

end



function testmouse()

end


function drawplayer()

end


function love.draw()

	love.graphics.draw( image,0,0) --image, x, y, r, sx, sy, ox, oy, kx, ky
	love.graphics.draw(playerimage, 400, 600)
end

function love.update()

end



