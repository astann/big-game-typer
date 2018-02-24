function makeTile(x, y, t)
    local tile = {
        x = x,
        y = y,
        t = t
    }

    tile.update = function()
        if tile.t == 2 or tile.t == 4 then
            tile.c_x = tile.x + 4
            tile.c_x2 = tile.c_x + 28
            tile.c_y = tile.y + 8
            tile.c_y2 = tile.c_y + 20
        else
            tile.c_x = 0
            tile.c_x2 = 0
            tile.c_y = 0
            tile.c_y2 = 0
        end
    end

    tile.setTile = function(t)
        tile.t = t
        tile.update()
    end

    tile.update()

    return tile
end
