#!/usr/bin/env love
-- REVERSI
-- 3.0
-- Game (love2d)
-- main.lua

-- MIT License
-- Copyright (c) 2018 Alexander Veledzimovich veledz@gmail.com

-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

local view = require('lib/view')
local set = require('lib/set')

io.stdout:setvbuf('no')
function love.load()
    if arg[1] then print(set.VER, set.GAMENAME, 'Game (love2d)', arg[1]) end
    local icon = love.image.newImageData('res/icon.png')
    love.window.setIcon(icon)

    love.window.setFullscreen(set.FULLSCR, 'desktop')
    love.graphics.setBackgroundColor(set.XOCLR)
    -- make first scr and init model
    view.Game:init()
end

function love.update(dt)
    local upd_title = string.format('%s %s fps %.2d', set.GAMENAME, set.VER,
                                    love.timer.getFPS())
    love.window.setTitle(upd_title)

    view.Game:update(dt)
end

function love.draw()
    view.Game:draw()
end

function love.keypressed(key,unicode,isrepeat)
    if key == 'escape' then
        love.event.quit()
    end

    if (key == 'lgui') then love.event.quit('restart') end
    if key == 'p' then view.Game.pause = not view.Game.pause end
end
function love.keyreleased(key,unicode) end
function love.mousepressed(x,y,button,istouch) end
function love.mousereleased(x,y,button,istouch) end
function love.mousemoved(x,y,dx,dy,istouch) end
function love.wheelmoved(x, y) end
function love.focus(f)
    if not f then view.Game.pause = true
    else view.Game.pause = false end
end
function love.quit() print('game over') end
