#!/usr/bin/env lua
-- Wed Feb 28 12:38:12 2018
-- (c) Alexander Veledzimovich
-- set REVERSI

local set = {
    APPNAME = 'Reversi',
    VER = '3.0',
    FULLSCR = false,
    WID = love.graphics.getWidth(),
    HEI = love.graphics.getHeight(),
    MIDWID = love.graphics.getWidth() / 2,
    MIDHEI = love.graphics.getHeight() / 2,
    BLACK = {0, 0, 30/255,1},
    DARKGRAY =  {30/255, 30/255, 30/255,1},
    GRAY = {128/255, 128/255, 128/255,1},
    WHITE = {1,1,1,1},
    GRAYBLUE = {80/255, 80/255, 84/255,1},
    -- Vera Sans
    TITLEFNT = {nil,64},
    XOFNT = {nil,48},
    MENUFNT = {nil,32},
    GAMEFNT = {nil,24},

    SEP = 6,
    DIST = 40,
    FIELD = 8
}
set.SIZE = ((set.HEI-set.DIST*2)/set.FIELD) - set.SEP
set.TXTCLR = set.WHITE
set.XOCLR =  set.DARKGRAY
set.SQCLR = set.GRAY

return set
