io.stdout:setvbuf("no")
if arg[2] == "debug" then
    require("lldebugger").start()
end

local border = 50
local squareSize = 20
local gap = 1
local rows, columns = 20,20
local pathType = {LINEAR=1, EFFICIENT=2, RANDOM=3}

local tiles
local enter, exit

local function isWall(x,y, num)
    num = num or 1
    if x > 0 and y > 0 then
        return tiles[y][x] == num
    end
    return true
end

local function getDistance(x1,y1, x2,y2)
    return math.sqrt((x2-x1)^2+(y2-y1)^2)
end

local function generatePath(type, num)
    num = num or 4
    if type == pathType.LINEAR then     -- Assumes enter and exit are along upper and lower walls respectively
        local x,y=enter.x,enter.y
        while x ~= exit.x or y ~= exit.y do
            if x < exit.x and not isWall(x+1,y) then
                x = x + 1
            elseif x > exit.x and not isWall(x-1,y) then
                x = x - 1
            elseif y < exit.y and not isWall(x,y+1) then
                y = y + 1
            elseif y > exit.y and not isWall(x,y-1) then
                y = y - 1
            else
                print("The linear path is stuck.")
                break
            end
            if tiles[y][x] == 0 then
                tiles[y][x] = num
            end
        end
    elseif type == pathType.EFFICIENT then
        local x,y = enter.x,enter.y
        while x ~= exit.x or y ~= exit.y do
            local up =      getDistance(x,y-1, exit.x,exit.y)
            local down =    getDistance(x,y+1, exit.x,exit.y)
            local left =    getDistance(x-1,y, exit.x,exit.y)
            local right =   getDistance(x+1,y, exit.x,exit.y)
            local min = math.min(up, down, left, right)
            if min == up and not isWall(x,y-1) then
                y = y - 1
            elseif min == down and not isWall(x,y+1) then
                y = y + 1
            elseif min == left and not isWall(x-1,y) then
                x = x - 1
            elseif min == right and not isWall(x+1,y) then
                x = x + 1
            else
                print("The efficient path is stuck.")
            end
            if tiles[y][x] == 0 then
                tiles[y][x] = num
            end
        end
    elseif type == pathType.RANDOM then
        local x,y = enter.x,enter.y
        local directions = {UP=1, DOWN=2, LEFT=3, RIGHT=4}
        while x ~= exit.x or y ~= exit.y do
            local valid = {}
            if not (isWall(x,y-1) or isWall(x,y-1,num)) then
                table.insert(valid, directions.UP)
            end
            if not (isWall(x,y+1) or isWall(x,y+1,num)) then
                table.insert(valid, directions.DOWN)
            end
            if not (isWall(x-1,y) or isWall(x-1,y,num)) then
                table.insert(valid, directions.LEFT)
            end
            if not (isWall(x+1,y) or isWall(x+1,y,num)) then
                table.insert(valid, directions.RIGHT)
            end

            if #valid == 0 then
                return
            end

            local closest, distance
            for i=1,#valid do
                local d
                if valid[i] == directions.UP then
                    d = getDistance(x,y-1, exit.x,exit.y)
                elseif valid[i] == directions.DOWN then
                    d = getDistance(x,y+1, exit.x,exit.y)
                elseif valid[i] == directions.LEFT then
                    d = getDistance(x-1,y, exit.x,exit.y)
                elseif valid[i] == directions.RIGHT then
                    d = getDistance(x+1,y, exit.x, exit.y)
                end
                distance = distance or d
                if distance >= d then
                    closest = valid[i]
                    distance = d
                end
            end

            local move
            if love.math.random(2) == 1 then
                move = closest
            else
                move = valid[love.math.random(#valid)]
            end

            if move == directions.UP then
                y = y - 1
            elseif move == directions.DOWN then
                y = y + 1
            elseif move == directions.LEFT then
                x = x - 1
            elseif move == directions.RIGHT then
                x = x + 1
            else
                return
            end
            if tiles[y][x] == 0 then
                tiles[y][x] = num
            end
        end
    end
end

function love.load()
    love.window.setMode(border *2 + (squareSize + gap) * rows, border * 2 + (squareSize + gap) * columns)

    ---[[    TL -> BR
    enter = {x=2, y=1}
    exit = {x=columns-1,y=rows}
    --]]
    --[[    TR -> BL
    enter = {x=columns-1,y=1}
    exit = {x=2,y=rows}
    --]]
    --[[   LT-> RB
    enter = {x=1,y=2}
    exit = {x=columns,y=rows-1}
    --]]
    

    tiles = {}
    for i=1,rows do
        table.insert(tiles,{})
        for _=1,columns do
            table.insert(tiles[i],0)
        end
    end
    
    for i,_ in ipairs(tiles[1]) do
        tiles[1][i] = 1
    end
    for i,_ in ipairs(tiles[rows]) do
        tiles[rows][i] = 1
    end
    for i=2,rows-1 do
        tiles[i][1] = 1
        tiles[i][columns] = 1
    end
    
    tiles[enter.y][enter.x] = 2
    tiles[exit.y][exit.x] = 3
    generatePath(pathType.RANDOM)
end

function love.draw()
    for i,v in ipairs(tiles) do
        for j,w in ipairs(v) do
            if w == 1 then
                love.graphics.setColor(1,1,1)
            elseif w == 2 then
                love.graphics.setColor(1,0,0)
            elseif w == 3 then
                love.graphics.setColor(0,1,0)
            elseif w == 4 then
                love.graphics.setColor(0,0,1)
            elseif w == 5 then
                love.graphics.setColor(0.5,0.5,1)
            end
            if w ~= 0 then
                love.graphics.rectangle("fill", j * (squareSize + gap) + border, i * (squareSize + gap) + border, squareSize, squareSize)
            end
        end
    end
end
