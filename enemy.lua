local SPEED_MULTIPLIER = 15

function makeEnemy(x, y)
    local enemy = {
        x = x,
        y = y,
        image = enemy 
    }

    enemy.word = words[math.floor(math.random(#words))]

    enemy.draw = function()
        love.graphics.draw(enemy.image, enemy.x, enemy.y)
        love.graphics.print(enemy.word, enemy.x - 10, enemy.y - 20)
    end

    enemy.move = function(dt)
        local dx = enemy.x - player.x
        local dy = enemy.y - player.y

        if dx > 16 then
            enemy.v_x = -1
        elseif dx < -16 then
            enemy.v_x = 1
        else
            enemy.v_x = 0
        end

        if dy > 16 then
            enemy.v_y = -1
        elseif dy < 16 then
            enemy.v_y = 1
        else
            enemy.v_y = 0
        end

        enemy.x = enemy.x + enemy.v_x * dt * SPEED_MULTIPLIER
        enemy.y = enemy.y + enemy.v_y * dt * SPEED_MULTIPLIER
    end

    return enemy
end
