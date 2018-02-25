require "player"
require "map"
require "words"
require "enemy"
require "tile"

local WINDOW_W = 640
local WINDOW_H = 480
local BOOST_READY = 10

function loadAssets()
    playerImage = love.graphics.newImage('assets/player.png')
    grass = love.graphics.newImage('assets/grass.png')
    tree = love.graphics.newImage('assets/tree.png')
    trail = love.graphics.newImage('assets/trail.png')
    water = love.graphics.newImage('assets/water.png')
    enemy = love.graphics.newImage('assets/enemy.png')
    comicSans = love.graphics.newFont('assets/comicsans.ttf', 20)
end

function init()
    math.randomseed(os.time())
    love.window.setMode(WINDOW_W, WINDOW_H)
    love.graphics.setFont(comicSans)
end

function love.load()
    loadAssets()
    init()

    difficulty = 1
    player = makePlayer(100, 65)
    startLevel()
    enemies = {}
    printedWord = ""
    aimLine = {}
    boost = 0
end

function startLevel()
    map = generateMap(difficulty)
    player.x = 100
    player.y = 65
end

function startRound()
    table.insert(enemies, makeEnemy(math.random(0, 1) * WINDOW_W, math.random(0, WINDOW_H)))
    table.insert(enemies, makeEnemy(math.random(0, WINDOW_W), math.random(0, 1) * WINDOW_H))
end

function love.textinput(text)
    printedWord = printedWord .. text
end

function love.keypressed(key)
    if (
        key == "return" or 
        key == "escape" or 
        key == "delete" or 
        key == "clear"
    ) then
        if key == "return" then
            for i = 1, #enemies do
                if enemies[i].word == printedWord then
                    player.setDirection(enemies[i])
                    table.remove(enemies, i)
                    boost = boost + 1
                    break
                end
            end
        end

        printedWord = ""
    elseif key == "backspace" then
        printedWord = string.sub(printedWord, 1, -2)
    end

    if boost >= BOOST_READY and love.keyboard.isDown("left") then
        player.v_x = -1
        player.v_y = 0
        boost = 0
    end

    if boost >= BOOST_READY and love.keyboard.isDown("right") then
        player.v_x = 1
        player.v_y = 0
        boost = 0
    end

    if boost >= BOOST_READY and love.keyboard.isDown("up") then
        player.v_y = -1
        player.v_x = 0
        boost = 0
    end

    if boost >= BOOST_READY and love.keyboard.isDown("down") then
        player.v_y = 1
        player.v_x = 0
        boost = 0
    end
end

function handleEnemyMovement(dt)
    for i = 1, #enemies do
        enemies[i].move(dt)
    end
end

function collision(tile, dt)
   return (
        player.c_x < tile.c_x2 and
        player.c_x2 > tile.c_x and
        player.c_y < tile.c_y2 and
        player.c_y2 > tile.c_y
   )
end

function handlePlayerMovement(dt)
    for y = 1, #map do
        for x = 1, #map[y] do
            if collision(map[y][x], dt) then
                player.bounce()
            end
        end
    end

    player.move(dt)
end

function love.update(dt)
    if #enemies == 0 then
        startRound()
    end

    handleEnemyMovement(dt)
    handlePlayerMovement(dt)

    if player.c_x > 580 or player.c_y > 410 then
        difficulty = difficulty + 1
        player.v_x = 0
        player.v_y = 0
        startLevel()
    end
end

function drawMap()
    for row = 1, #map do
        local offset = row % 2

        for column = 1, #map[row] do
            local tile = map[row][column]
            local tileImage = grass

            if tile.t  > 0 then
                if tile.t == 3 then
                    tileImage = trail
                elseif tile.t == 4 then
                    tileImage = water
                end

                love.graphics.draw(tileImage, tile.x, tile.y)
                --love.graphics.rectangle("fill", tile.c_x, tile.c_y, tile.c_x2 - tile.c_x, tile.c_y2 - tile.c_y)
            end

            if tile.t == 2 then
                love.graphics.draw(tree, column * 32 - offset * 16 + 8, row * 24 - 28)
                --love.graphics.rectangle("fill", tile.c_x, tile.c_y, tile.c_x2 - tile.c_x, tile.c_y2 - tile.c_y)
            end
        end
    end
end

function love.draw()
    drawMap()

    --love.graphics.rectangle("fill", player.c_x, player.c_y, player.c_x2 - player.c_x, player.c_y2 - player.c_y)
    player.draw()

    for i = 1, #enemies do
        enemies[i].draw()
        if enemies[i].word == printedWord then
            love.graphics.line(player.c_x + 8, player.c_y - 2, enemies[i].x + 10, enemies[i].y + 10)
        end
    end

    love.graphics.print(printedWord, player.x - 30, player.y - 30)
    if boost >= BOOST_READY then
        love.graphics.print("boost ok", player.x - 30, player.y + 30)
    else
        love.graphics.print("boost " .. boost .. "/" .. BOOST_READY, player.x - 30, player.y + 30)
    end
end
