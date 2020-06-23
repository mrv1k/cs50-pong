WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    }

    player1Score = 0
    player2Score = 0
    winner = 0

    player1 = Paddle(5, 20, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    servingPlayer = math.random(2) == 1 and 1 or 2
    if servingPlayer == 1 then ball.dx = 100 else ball.dx = -100 end

    gameState = 'start'

   push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'play' then

        if ball.x <= 0 then
            player2Score = player2Score + 1
            sounds['score']:play()
            ball:reset()
            ball.dx = 100
            servingPlayer = 1

            if player2Score >= 10 then
                gameState = 'win'
                winner = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
            sounds['score']:play()
            ball:reset()
            ball.dx = -100
            servingPlayer = 2

            if player1Score >= 10 then
                gameState = 'win'
                winner = 1
            else
                gameState = 'serve'
            end
        end

        if ball:collides(player1) or ball:collides(player2) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx
        end

        -- handle top and bottom screen edges collisions
        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall_hit']:play()
        end
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            sounds['wall_hit']:play()
        end

        player1:update(dt)
        player2:update(dt)

        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end

        ball:update(dt)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'win' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        end
    end
end

function love.draw()
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    push:apply('start')
    displayScore()

    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        local message = "Player " .. tostring(servingPlayer) .. "'s turn"
        love.graphics.printf(message, 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'win' then
        love.graphics.setFont(victoryFont)
        local message = "Player " .. tostring(winner) .. " wins!"
        love.graphics.printf(message, 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to Restart!', 0, 42, VIRTUAL_WIDTH, 'center')
    end

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS :' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end