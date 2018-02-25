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
    boostImage = love.graphics.newImage('assets/boost.png')

    enemy = love.graphics.newImage('assets/enemy.png')
    bloodImage = love.graphics.newImage('assets/blood.png')

    grass = love.graphics.newImage('assets/grass.png')
    tree = love.graphics.newImage('assets/tree.png')
    trail = love.graphics.newImage('assets/trail.png')
    water = love.graphics.newImage('assets/water.png')

    intro1 = love.graphics.newImage('assets/intro1.png')
    intro2 = love.graphics.newImage('assets/intro2.png')
    intro3 = love.graphics.newImage('assets/intro3.png')
    goodend = love.graphics.newImage('assets/goodend.png')
    badend = love.graphics.newImage('assets/badend.png')
    tutorial = love.graphics.newImage('assets/tutorial.png')

    comicSans = love.graphics.newFont('assets/comicsans.ttf', 20)

    music = love.audio.newSource('assets/typehunter.ogg')
    music:setLooping(true)
    shot = love.audio.newSource('assets/shot.ogg')
    boostSound = love.audio.newSource('assets/boost.ogg')
end

function init()
    math.randomseed(os.time())
    love.window.setMode(WINDOW_W, WINDOW_H)
    love.graphics.setFont(comicSans)
end

function love.load()
    state = 0
    musicOn = true
    loadAssets()
    init()

    if musicOn then
        love.audio.play(music)
    end

    assistMode = false
    menuImage = intro1
    menuPosition = 480
    selectedMenu = 0
    timer = 0
    difficulty = 1
    gameLength = 3
    targetDifficulty = 3
    player = makePlayer(100, 65)
    enemies = {}
    blood = {}
    printedWord = ""
    aimLine = {}
    boost = 0
end

function startLevel()
    blood = {}
    map = generateMap(difficulty)
    player.x = 100
    player.y = 65
end

function startRound()
    table.insert(enemies, makeEnemy(math.random(0, 1) * WINDOW_W, math.random(0, WINDOW_H), true))
    table.insert(enemies, makeEnemy(math.random(0, WINDOW_W), math.random(0, 1) * WINDOW_H))
end

function love.textinput(text)
    printedWord = printedWord .. text
end

function handleKeyIntro(key)
    state = 1
end

function handleKeyTutorial(key)
    if key == "return" then
        state = 2
    end
end

function handleKeyMenu(key)
    if key == "down" then
        selectedMenu = selectedMenu + 1

        if selectedMenu > 5 then
            selectedMenu = 0
        end
    end

    if key == "up" then
        selectedMenu = selectedMenu - 1

        if selectedMenu < 0 then
            selectedMenu = 5
        end
    end

    if key == "left" then
        if selectedMenu == 1 and gameLength > 2 then
            gameLength = gameLength - 1
            targetDifficulty = difficulty + gameLength - 1
        end

        if selectedMenu == 2 and difficulty > 1 then
            difficulty = difficulty - 1
            targetDifficulty = difficulty + gameLength - 1
        end

        if selectedMenu == 5 then
            assistMode = not assistMode
        end
    end

    if key == "right" then
        if selectedMenu == 1 and gameLength < 10 then
            gameLength = gameLength + 1
            targetDifficulty = difficulty + gameLength - 1
        end

        if selectedMenu == 2 and difficulty < 5 then
            difficulty = difficulty + 1
            targetDifficulty = difficulty + gameLength - 1
        end

        if selectedMenu == 5 then
            assistMode = not assistMode
        end
    end

    if key == "return" then
        if selectedMenu == 0 or selectedMenu == 1 or selectedMenu == 2 then
            state = 3
            startLevel()
            startRound()
            printedWord = ""
        elseif selectedMenu == 3 then
            state = 1
        elseif selectedMenu == 4 then
            menuImage = intro1
            menuPosition = 480
            state = 0
        end

        if selectedMenu == 5 then
            assistMode = not assistMode
        end
    end
end

function handleKeyGame(key)
    if (
        key == "return" or 
        key == "escape" or 
        key == "delete" or 
        key == "clear"
    ) then
        if key == "return" then
            for i = 1, #enemies do
                if enemies[i].word == printedWord then
                    love.audio.play(shot)
                    player.setDirection(enemies[i])
                    enemies[i].image = bloodImage
                    enemies[i].word = ""
                    table.insert(blood, enemies[i])
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
        love.audio.play(boostSound)
        player.v_x = -1
        player.v_y = 0
        boost = 0
    end

    if boost >= BOOST_READY and love.keyboard.isDown("right") then
        love.audio.play(boostSound)
        player.v_x = 1
        player.v_y = 0
        boost = 0
    end

    if boost >= BOOST_READY and love.keyboard.isDown("up") then
        love.audio.play(boostSound)
        player.v_y = -1
        player.v_x = 0
        boost = 0
    end

    if boost >= BOOST_READY and love.keyboard.isDown("down") then
        love.audio.play(boostSound)
        player.v_y = 1
        player.v_x = 0
        boost = 0
    end
end

function love.keypressed(key)
    if state == 0 then
        handleKeyIntro(key)
    elseif state == 1 then
        handleKeyTutorial(key)
    elseif state == 2 then
        handleKeyMenu(key)
    elseif state == 3 then
        handleKeyGame(key)
    else
        handleKeyTutorial(key)
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
 
    if #enemies > 0 then
        for i = 1, #enemies do
            if collision(enemies[i], dt) then
                state = 4
                enemies = {}
                break
            end
        end
    end

    player.move(dt)
end

function updateIntro(dt)
    timer = timer + dt

    if menuPosition > 0 then
        menuPosition = menuPosition - 1 * timer
    end

    if timer > 7  then
        menuPosition = 480
        
        if menuImage == intro1 then
            menuImage = intro2
        elseif menuImage == intro2 then
            menuImage = intro3
        elseif menuImage == intro3 then
            menuImage = tutorial
            state = 1
        end

        timer = 0
    end
end

function updateGame(dt)
    if assistMode then
        boost = 10
    end

    if #enemies == 0 then
        startRound()
    end

    handleEnemyMovement(dt)
    handlePlayerMovement(dt)

    if player.c_x > 580 or player.c_y > 410 then
        if difficulty == targetDifficulty then
            state = 5
            enemies = {}
            difficulty = 1
            gameLength = 3
            targetDifficulty = 3
        else
            difficulty = difficulty + 1
            player.v_x = 0
            player.v_y = 0
            startLevel()
        end
    end
end

function love.update(dt)
    if state == 0 then
        updateIntro(dt)
    elseif state == 3 then
        updateGame(dt)
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

function drawIntro()
   love.graphics.draw(menuImage, 0, menuPosition) 
   love.graphics.print("any key to skip animated intro", 360, 440)
end

function drawMenu()
    local selectedMenuY = 150 + selectedMenu * 30

    love.graphics.print("TYPEHUNTER", 230, 100)
    love.graphics.print("START", 60, 150)
    love.graphics.print("GAME LENGTH: < " .. gameLength .. " > MAPS", 60, 180)
    love.graphics.print("STARTING DIFFICULTY: < " .. difficulty .. " >", 60, 210)
    love.graphics.print("TUTORIAL", 60, 240)
    love.graphics.print("INTRO", 60, 270)
    if assistMode then
        love.graphics.print("ASSIST MODE: ON", 60, 300)
        love.graphics.print("YOU HAVE BEEN EQUIPPED WITH INFINITE BOOST", 60, 350)
        love.graphics.print("ONLY USE IF YOU ARE HAVING TROUBLE", 60, 380)
        love.graphics.print("BUT WANT TO SEE THE ENDING", 60, 410)
    else
        love.graphics.print("ASSIST MODE: OFF", 60, 300)
    end

    love.graphics.print(">", 30, selectedMenuY)

    love.graphics.print("arrows and Enter to navigate", 360, 440)
end

function drawTutorial()
    love.graphics.draw(tutorial, 0, 0) 
    love.graphics.print("press Enter to open menu", 400, 440)
end

function drawGame()
    --love.graphics.rectangle("fill", player.c_x, player.c_y, player.c_x2 - player.c_x, player.c_y2 - player.c_y)
    drawMap()

    for i = 1, #blood do
        blood[i].draw()
    end

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

function drawBadend()
    love.graphics.draw(badend, 0, 0)
    love.graphics.print("press Enter to open menu", 400, 440)
end

function drawGoodend()
    love.graphics.draw(goodend, 0, 0)
    love.graphics.print("press Enter to open menu", 400, 440)
end

function love.draw()
    if state == 0 then
        drawIntro()
    elseif state == 1 then
        drawTutorial()
    elseif state == 2 then
        drawMenu()
    elseif state == 3 then
        drawGame()
    elseif state == 4 then
        drawBadend()
    else
        drawGoodend()
    end

end
