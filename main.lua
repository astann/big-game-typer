require "player"
require "map"
require "words"
require "enemy"

local WINDOW_W = 640
local WINDOW_H = 480

function loadAssets()
    playerImage = love.graphics.newImage('assets/player.png')
    grass = love.graphics.newImage('assets/grass.png')
    tree = love.graphics.newImage('assets/tree.png')
    trail = love.graphics.newImage('assets/trail.png')
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

    player = makePlayer(30, 30)
    enemies = {}
    printedWord = ""
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
                    break
                end
            end
        end

        printedWord = ""
    elseif key == "backspace" then
        printedWord = string.sub(printedWord, 1, -2)
    end
end

function handleEnemyMovement(dt)
    for i = 1, #enemies do
        enemies[i].move(dt)
    end
end

function handlePlayerMovement(dt)
    player.move(dt)
end

function love.update(dt)
    if #enemies == 0 then
        startRound()
    end

    handleEnemyMovement(dt)
    handlePlayerMovement(dt)
end

function drawMap()
    for row = 1, #map do
        local offset = row % 2

        for column = 1, #map[row] do
            local tile = map[row][column]
            local tileImage = grass

            if tile  > 0 then
               if tile == 3 then
                    tileImage = trail
                end

                love.graphics.draw(tileImage, column * 64 - offset * 32, row * 48)
            end

            if map[row][column] == 2 then
                love.graphics.draw(tree, column * 64 - offset * 32 + 24, row * 48 - 56)
            end

        end
    end
end

function love.draw()
    drawMap()

    player.draw()

    for i = 1, #enemies do
        enemies[i].draw()
    end

    love.graphics.print(printedWord, player.x, player.y - 20)
end
