#!/usr/bin/env lua
-- Sun Mar 11 02:11:52 2018
-- (c) Alexander Veledzimovich

-- model REVERSI

local set = require('lib/set')
local fc = require('lib/fct')

local function reset(matrix)
    for i=1, set.FIELD do
        for j=1, set.FIELD do
            matrix[i][j] = ' '
        end
    end
    matrix[4][4] = 'X'
    matrix[4][5] = 'O'
    matrix[5][4] = 'O'
    matrix[5][5] = 'X'
    return matrix
end

local function make_matrix()
    local matrix = {}
    for _=1, set.FIELD do
        local row = {}
        for _=1, set.FIELD do
            table.insert(row, ' ')
        end
        table.insert(matrix, row)
    end
    return reset(matrix)
end

local function valid(matrix, tile, xst, yst)
    if matrix[xst][yst] ~= ' ' then return end
    matrix[xst][yst] = tile

    local other
    if tile == 'X' then other = 'O' else other = 'X' end

    local arr = {}

    local direct = {{0, 1}, {1, 1}, {1, 0}, {1, -1},
                       {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}}

    -- find all tiles to flip from start position
    for i = 1, #direct do
        local x = xst
        local y = yst
        local xdir = direct[i][1]
        local ydir = direct[i][2]

        x = xdir + x
        y = ydir + y

        while ((fc.isval(x, fc.range(1,set.FIELD)) and
                fc.isval(y, fc.range(1,set.FIELD))) and
            matrix[x][y] == other) do
            x = xdir + x
            y = ydir + y
        end

        if ((fc.isval(x, fc.range(1,set.FIELD)) and
            fc.isval(y, fc.range(1,set.FIELD))) and
            matrix[x][y] == tile) then
            while true do
                x=x-xdir
                y=y-ydir
                if x == xst and y == yst then break end
                table.insert(arr, {x, y})
            end
        end
    end

    matrix[xst][yst] = ' '
    if fc.len(arr) == 0 then return end
    return arr
end

local function valid_empty(matrix, tile)
    local arr = {}
    for i=1, set.FIELD do
        for j=1, set.FIELD do
            if valid(matrix, tile, i, j) then
                table.insert(arr, {i, j})
            end
        end
    end
    return arr
end

local function help(matrix, tile)
    local copy = fc.clone(matrix)
    local valid_empty_tiles = valid_empty(copy, tile)
    for _, v in pairs(valid_empty_tiles, tile) do
        copy[v[1]][v[2]] = '.'
    end
    return copy
end

local function make_move(matrix, tile, x, y)
    local flip = valid(matrix, tile, x, y)
    if not flip then return end
    matrix[x][y] = tile
    for _, v in pairs(flip) do
        matrix[v[1]][v[2]] = tile
    end
    return fc.join(flip,{{x,y}})
end

local function next_turn(matrix, tile)
    if #valid_empty(matrix,tile) > 0 then return tile end
    return false
end

local function player_move(matrix, tile, x, y)
    local move = valid(matrix, tile, x, y)
    if move then
        return make_move(matrix, tile, x, y)
    end
end

local function corner(x, y)
    return ((x == 1 and y == 1) or (x == 8 and y == 1) or
        (x == 1 and y == 8) or (x == 8 and y == 8))
end

local function scores(matrix)
    local sc = {['X'] = 0, ['O'] = 0}
    for i = 1, set.FIELD do
        for j = 1, set.FIELD do
            if matrix[i][j] == 'X' then sc['X'] = sc['X'] + 1 end
            if matrix[i][j] == 'O' then sc['O'] = sc['O'] + 1 end
        end
    end
    return sc
end

local function computer_move(matrix, tile)
    local valid_empty_tiles = valid_empty(matrix, tile)

    local possible = fc.shuffknuth(valid_empty_tiles)

    for i = 1, #possible do
        if corner(possible[i][1],possible[i][2]) then
            return {possible[i][1], possible[i][2]}
        end
    end

    local best = -1
    -- return valid move
    local best_move = {1, 1}
    for i = 1, #possible do
        local copy = fc.clone(matrix)

        make_move(copy, tile, possible[i][1], possible[i][2])
        local score = scores(copy)[tile]
        if score > best then
            best_move = {possible[i][1], possible[i][2]}
            best = score
        end
    end
    return best_move
end

local function easy_strategy(matrix, tile)
    local valid_empty_tiles = valid_empty(matrix, tile)
    local move = fc.randval(valid_empty_tiles)
    if move then
        return make_move(matrix, tile, move[1], move[2])
    end
end

local function medium_strategy(matrix, tile)
    local move = computer_move(matrix, tile)
    if move then
        return make_move(matrix, tile, move[1], move[2])
    end
end

local function twelve_games (matrix, tile)
    local other
    if tile == 'X' then other = 'O' else  other = 'X' end
    local valid_empty_tiles = valid_empty(matrix, tile)

    local possible = fc.shuffknuth(valid_empty_tiles)
    local best = -1
    local best_move = {1,1}

    for i = 1, #possible do
        local copy = fc.clone(matrix)
        local score = 0

        make_move(copy, tile, possible[i][1], possible[i][2])
        score = score + scores(copy)[tile]

        local function turns12( copy_, tile_, other_ )
            medium_strategy(copy_, other_)
            medium_strategy(copy_, tile_)
            return scores(copy_)[tile_]
        end

        for _ = 1, 12 do score = score +  turns12(copy, tile, other) end

        if score > best then
            best_move = {possible[i][1], possible[i][2]}
            best = score
        end

    end
    return best_move
end

local function hard_strategy(matrix, tile)
    local move = twelve_games(matrix, tile)
    if move then
        return make_move(matrix, tile, move[1], move[2])
    end
end

local model = {
    ['scores'] = scores,
    ['make_matrix'] = make_matrix,
    ['reset'] = reset,
    ['next_turn'] = next_turn,
    ['HELP'] = help,
    ['HUMAN'] = player_move,
    ['EASY'] = easy_strategy,
    ['MEDIUM'] = medium_strategy,
    ['HARD'] = hard_strategy
}
return model
