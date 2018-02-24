local SPEED_MULTIPLIER = 5

function makePlayer(x, y)
    local player = {
        x = x,
        y = y,
        v_x = 0,
        v_y = 0,
        image = playerImage 
    }

    player.draw = function()
        love.graphics.draw(player.image, player.x, player.y)
    end

    player.move = function(dt)
        player.x = player.x + player.v_x * dt * SPEED_MULTIPLIER
        player.y = player.y + player.v_y * dt * SPEED_MULTIPLIER
    end

    player.setDirection = function(enemy)
        local dx = player.x - enemy.x
        local dy = player.y - enemy.y

        if dx > 16 then
            player.v_x = -1
        elseif dx < 16 then
            player.v_x = 1
        else
            player.v_x = 0
        end

        if dy > 16 then
            player.v_y = -1
        elseif dy < 16 then
            player.v_y = 1
        else
            player.v_y = 0
        end
    end

    return player
end
