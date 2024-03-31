local border = 50
local squareSize = 10
local gap = 1
local rows, columns = 50,50
local pathType = {LINEAR=0, EFFICIENT=1, RANDOM=2}

local tiles
local enter, exit

local function generatePath(type)
    if type == pathType.LINEAR then     -- Assumes enter and exit are along upper and lower walls respectively
        for y=enter.y+1,exit.y-1 do
            tiles[y][enter.x] = 4
        end
        for x=enter.x,exit.x do
            tiles[exit.y-1][x] = 4
        end
    end
end

function love.load()
    love.window.setMode(border *2 + (squareSize + gap) * rows, border * 2 + (squareSize + gap) * columns)

    enter = {x=2, y=1}
    exit = {x=columns-1,y=rows}

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
    generatePath(pathType.LINEAR)
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
            end
            if w ~= 0 then
                love.graphics.rectangle("fill", j * (squareSize + gap) + border, i * (squareSize + gap) + border, squareSize, squareSize)
            end
        end
    end
end
