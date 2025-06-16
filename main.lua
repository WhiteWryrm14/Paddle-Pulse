-- Simple Pong Game using LÖVE 2D

function love.load()
    love.window.setTitle("Paddle Pulse (Lua, LÖVE 2D)")
    width, height = 800, 500
    paddleWidth, paddleHeight = 15, 100
    ballRadius = 10

    player = {x = 20, y = height/2 - paddleHeight/2, w = paddleWidth, h = paddleHeight, speed = 0}
    ai = {x = width - paddleWidth - 20, y = height/2 - paddleHeight/2, w = paddleWidth, h = paddleHeight, speed = 6}
    ball = {x = width/2, y = height/2, r = ballRadius, speed = 6, dx = 6, dy = 4}

    -- Randomize initial ball direction
    if math.random() > 0.5 then ball.dx = -ball.dx end
    if math.random() > 0.5 then ball.dy = -ball.dy end
end

function love.update(dt)
    -- Player paddle follows mouse
    local mx = love.mouse.getY()
    player.y = math.max(0, math.min(height - player.h, mx - player.h / 2))

    -- AI paddle tracks ball
    local aiCenter = ai.y + ai.h / 2
    if aiCenter < ball.y - 35 then
        ai.y = math.min(height - ai.h, ai.y + ai.speed)
    elseif aiCenter > ball.y + 35 then
        ai.y = math.max(0, ai.y - ai.speed)
    end

    -- Ball movement
    ball.x = ball.x + ball.dx
    ball.y = ball.y + ball.dy

    -- Top/bottom wall collision
    if ball.y - ball.r < 0 then
        ball.y = ball.r
        ball.dy = -ball.dy
    elseif ball.y + ball.r > height then
        ball.y = height - ball.r
        ball.dy = -ball.dy
    end

    -- Paddle collision
    if checkCollision(ball, player) then
        bounceBall(player)
    elseif checkCollision(ball, ai) then
        bounceBall(ai)
    end

    -- Out of bounds (left/right)
    if ball.x - ball.r < 0 or ball.x + ball.r > width then
        resetBall()
    end
end

function love.draw()
    love.graphics.clear(34/255, 34/255, 34/255)
    -- Net
    love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
    for y = 0, height, 25 do
        love.graphics.rectangle("fill", width/2 - 2, y, 4, 15)
    end

    -- Player paddle
    love.graphics.setColor(0, 1, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

    -- AI paddle
    love.graphics.setColor(1, 0, 1)
    love.graphics.rectangle("fill", ai.x, ai.y, ai.w, ai.h)

    -- Ball
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", ball.x, ball.y, ball.r)
end

function checkCollision(ball, paddle)
    return ball.x - ball.r < paddle.x + paddle.w and
           ball.x + ball.r > paddle.x and
           ball.y + ball.r > paddle.y and
           ball.y - ball.r < paddle.y + paddle.h
end

function bounceBall(paddle)
    -- Where did it hit relative to paddle center?
    local collidePoint = (ball.y - (paddle.y + paddle.h / 2)) / (paddle.h / 2)
    local angle = collidePoint * (math.pi / 4)
    local dir = (ball.x < width / 2) and 1 or -1
    ball.speed = math.min(ball.speed + 0.3, 15)
    ball.dx = dir * ball.speed * math.cos(angle)
    ball.dy = ball.speed * math.sin(angle)
end

function resetBall()
    ball.x = width/2
    ball.y = height/2
    ball.speed = 6
    ball.dx = (math.random() > 0.5 and 1 or -1) * ball.speed
    ball.dy = (math.random() > 0.5 and 1 or -1) * 4
end
