function makePlayer(x, y)
    local player = {
        x = x,
        y = y,
        image = playerImage 
    }

    player.draw = function()
        love.graphics.draw(player.image, player.x, player.y)
    end

    return player
end
