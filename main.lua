require "player"
require "map"
require "words"

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
    word = ""
    printedWord = ""
end

function startRound()
    word = words[math.floor(math.random(#words + 1))]
end

function love.textinput(text)
    printedWord = printedWord .. text
end

function love.keypressed(key)
    if (
        key == "return" or 
        key == "escape" or 
        key == "delete" or 
        key == "backspace" or 
        key == "clear"
    ) then
        if key == "return" and printedWord == word then
            word = ""
        end

        printedWord = ""
    end
end

function love.update(dt)
    if word == "" then
        startRound()
    end
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

    love.graphics.print(word, 300, 300)
    love.graphics.print(printedWord, player.x, player.y - 20)
end
