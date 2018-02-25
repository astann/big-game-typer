local SPEED_MULTIPLIER = 15

function makeEnemy(x, y, up)
    local enemy = {
        x = x,
        y = y,
        image = enemy 
    }

    enemy.c_x = enemy.x + 4
    enemy.c_x2 = enemy.c_x + 9
    enemy.c_y = enemy.y + 20
    enemy.c_y2 = enemy.c_y + 6

    enemy.word = words[math.floor(math.random(#words))]

    enemy.draw = function()
        if enemy.v_x > 0 then
            love.graphics.draw(enemy.image, enemy.x + 20, enemy.y, 0, -1, 1)
        else
            love.graphics.draw(enemy.image, enemy.x, enemy.y)
        end

        if up then
            love.graphics.print(enemy.word, enemy.x - 10, enemy.y + 20)
        else
            love.graphics.print(enemy.word, enemy.x - 10, enemy.y - 20)
        end
    end

    enemy.move = function(dt)
        local dx = enemy.x - player.x
        local dy = enemy.y - player.y

        if dx > 4 then
            enemy.v_x = -1
        elseif dx < -4 then
            enemy.v_x = 1
        else
            enemy.v_x = 0
        end

        if dy > 4 then
            enemy.v_y = -1
        elseif dy < 4 then
            enemy.v_y = 1
        else
            enemy.v_y = 0
        end

        enemy.x = enemy.x + enemy.v_x * dt * SPEED_MULTIPLIER
        enemy.y = enemy.y + enemy.v_y * dt * SPEED_MULTIPLIER
        enemy.c_x = enemy.x + 4
        enemy.c_x2 = enemy.c_x + 9
        enemy.c_y = enemy.y + 20
        enemy.c_y2 = enemy.c_y + 6
    end

    return enemy
end
