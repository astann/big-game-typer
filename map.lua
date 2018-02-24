function generateMap()
    local map = {}

    for y = 1, 18 do
        local row = {}
        local rowLength = 19
        local offset = y % 2

        if offset == 0 then
            rowLength = 18
        end

        for x = 1, rowLength do
            local tile = 1

            if x < 3 or x > rowLength - 2 then
                tile = 2
            end

            if y < 3 or y > 16 then
                tile = 2
            end

            table.insert(row, makeTile(x * 32 - offset * 16, y * 24, tile))
        end

        table.insert(map, row)
    end
    
    local trailX = 3
    local trailY = 3
    local dx
    local dy

    while (trailX < 32 or trailY < 32) do
        if trailY > #map or trailX > #map[trailY] then
            break
        end

        map[trailY][trailX].setTile(3)

        dy = math.random(0, 1)
        trailY = trailY + dy

        if trailY % 2 == 0 then
            dx = math.random(1, 2)
        else
            dx = 1
        end

        if trailY % 2 == 1 then
            trailX = trailX + dx
        end
    end

    for y = 1, #map do
        for x = 1, #map[y] do
            local tile = map[y][x].t

            if tile == 1 then
                local random = math.random()

                if random > 0.7 then
                    map[y][x].setTile(2)
                elseif random > 0.5 then
                    map[y][x].setTile(4)
                end
            end
        end
    end

    return map
end

