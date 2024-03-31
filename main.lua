local border = 50
local squareSize = 10
local gap = 1
local rows, columns = 50,50
local tiles

function love.load()
    tiles = {}
    for i=1,rows do
        table.insert(tiles,{})
        for _=1,columns do
            table.insert(tiles[i],0)
        end
    end
    love.window.setMode(border * 2 + (squareSize + gap) * rows, border * 2 + (squareSize + gap) * columns)
end

function love.draw()
    for i,v in ipairs(tiles) do
        for j,w in ipairs(v) do
            love.graphics.rectangle("fill", j * (squareSize + gap) + border, i * (squareSize + gap) + border, squareSize, squareSize)
        end
    end
end
