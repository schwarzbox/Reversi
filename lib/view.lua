#!/usr/bin/env love
-- Mon Mar 12 02:00:26 2018
-- (c) Alexander Veledzimovich

-- view REVERSI
local fc = require('lib/fct')
local gui = require('lib/lovui')
local model = require('lib/model')
local set = require('lib/set')
-- game manager
local Game = {}

function Game:init()
    gui.init()
    self.cel = {first='X', second='O'}
    self.turn = 'X'
    self.pause = false
    self.view_t = nil
    -- stop loop
    self.wait_loop = true
    self.delta_time = 0

    -- init model
    self.matrix = model.make_matrix()

    -- menu
    self.help = {bool = false}
    self.tile = {val='X'}
    self.ai1 = {val='HARD'}
    self.ai2 = {val='EASY'}
    self.player = {val='HUMAN'}
    -- update scores
    self.score_x = {val=string.format(' %-2.2d  %s ', 0,'X')}
    self.score_o = {val=string.format(' %s  %2.2d ', 'O', 0)}
    -- options
    self.number_games = {val=1}
    self.ai_dt = {val=1}
    -- statistic log
    self.stat_var = {['X WIN']=0,['O WIN']=0,['DRAW']=0}
    self.total_games = 0
    -- for tests AI only (don't use in final release)
    -- io.open('log/stat.txt','w'):close()

    self:set_menu_scr()
end

function Game:set_menu_scr()
    -- clear screen
    gui.Manager.clear()

    -- set up first screen
    self.now='menu_scr'

    gui.Label{text=' '..set.GAMENAME:upper()..' ',
                    x=set.MIDWID, y=set.MIDHEI-set.DIST*3,
                    fnt=set.TITLEFNT, anchor='s',frame=2,corner={4,4,2}}

    local xo_sel = gui.HBox{x=set.MIDWID, y=set.MIDHEI-set.DIST*2,
                    anchor='n', sep=10}

    xo_sel:add(
                gui.Selector{text='X', fnt=set.TITLEFNT,
                             variable=self.tile},
                gui.Selector{text='O', fnt=set.TITLEFNT,
                             variable=self.tile}
                )

    local dif_sel = gui.HBox{x=set.MIDWID, y=set.MIDHEI,
                    anchor='n', sep=10}

    dif_sel:add(
                gui.Selector{text='EASY', fnt=set.MENUFNT,
                     variable=self.ai2},
                gui.Selector{text='MEDIUM', fnt=set.MENUFNT,
                    variable=self.ai2},
                gui.Selector{text='HARD', fnt=set.MENUFNT, anchor='nw',
                     variable=self.ai2}
                )

    gui.CheckBox{text='HELP', x=set.MIDWID, y=set.MIDHEI+set.DIST,
        fnt=set.MENUFNT, anchor='n', frame=0,variable=self.help}

    gui.Button{text=' START ', x=set.MIDWID, y=set.MIDHEI+set.DIST*4,
                    fnt=set.MENUFNT, anchor='n',
                    command=function() self:set_game_scr() self:reset() end}

end

function Game:reset()
    if self.tile.val =='X' then
        self.cel.first = 'X'
        self.cel.second = 'O'
    else
        self.cel.first = 'O'
        self.cel.second = 'X'
    end
    -- clear matrix
    self.matrix = model.reset(self.matrix)

    self.view_t = nil
    self.turn = fc.randval(self.cel)

    self.delta_time = self.ai_dt.val
    self.wait_loop = true
    -- label to execute command
    gui.LabelExe{text=self.turn .. ' START', x=set.MIDWID, y=set.MIDHEI,
                    fnt=set.TITLEFNT, fntclr=set.TXTCLR,
                    command=function() self.wait_loop=false end}
end

function Game:set_game_scr()
    gui.Manager.clear()
    self.now='game_scr'

    gui.Label{text=self.score_x.val,x=set.DIST,y=set.DIST/2,
                    anchor='w', fnt=set.GAMEFNT,
                    variable=self.score_x,frame=2,corner={4,4,2}}

    gui.Label{text=self.score_o.val,x=set.WID-set.DIST-2,y=set.DIST/2,
                    anchor='e',fnt=set.GAMEFNT,
                    variable=self.score_o,frame=2,corner={4,4,2}}

    gui.Label{text='SCORE', x=set.MIDWID, y=set.DIST/2,fnt=set.MENUFNT}

    gui.Button{text=' MENU ', x=set.DIST, y=set.HEI-set.DIST/2,
                anchor='w', fnt=set.GAMEFNT,
                command=function() self:set_menu_scr() end}
    -- opt button
    gui.Button{image=love.image.newImageData('res/gear.png'),
                x=set.MIDWID, y=set.HEI-set.DIST/2, anchor='center',
                command=function() self:set_opt_scr() end, rot_dt=1}

    gui.Button{text=' RESTART ', x=set.WID-set.DIST-2, y=set.HEI-set.DIST/2,
        anchor='e', fnt=set.GAMEFNT,command=function() self:reset() end,
        frame=1}

    --  set game field
    for i=1, set.FIELD do
        for j=1, set.FIELD do
            local Cells=gui.Label{x=set.DIST+(set.SIZE+set.SEP)*(i-1),
                                y=set.DIST+(set.SIZE+set.SEP)*(j-1),
                                fnt=set.XOFNT, anchor='nw',fntclr=set.XOCLR,
                                frame=2, frmclr=set.SQCLR, corner={4,4,2},
                                mode='fill', wid=set.SIZE, hei=set.SIZE}
            Cells.type = 'cell'
        end
    end

    -- pause label
    gui.Label{text='PAUSE', x=set.MIDWID, y=set.MIDHEI,fnt=set.MENUFNT,
                    fntclr=set.TXTCLR}


end

function Game:set_fin_scr(scores)

    local win
    self.total_games = self.total_games + 1
    if scores['X'] > scores['O'] then
        win = 'X WIN'
        self.stat_var['X WIN'] = self.stat_var['X WIN'] + 1
    elseif scores['X'] < scores['O'] then
        win = 'O WIN'
        self.stat_var['O WIN'] = self.stat_var['O WIN'] + 1
    else
        win = 'DRAW'
        self.stat_var['DRAW'] = self.stat_var['DRAW'] + 1
    end

    local command
    if self.number_games.val > 1 then
        -- auto restart
        self.number_games.val = self.number_games.val - 1
        command = function() self:reset() end
    else
        command = function() return nil end
    end

    gui.PopUp{text=win, x=set.MIDWID, y=set.MIDHEI, fnt=set.TITLEFNT,
                            fntclr=set.TXTCLR, command=command}
    -- for tests AI only (don't use in final release)
    -- self:write_stat_log(scores)
end

function Game:write_stat_log(scores)
    -- save result to log file
    local new_file = io.open('log/stat.txt','a+')
    if self.total_games == 1 then
        local pl1,pl2
        if self.player.val == 'HUMAN' then
            pl1 = 'HUMAN'
        else
            pl1 = self.ai1.val
        end
        pl2 = self.ai2.val
        new_file:write(string.format('%s\n%s vs %s\n', os.date(),pl1,pl2))
    end
    new_file:write(string.format('X - %s O - %s\n', scores['X'], scores['O']))

    if self.number_games.val == 1 then
        for key, val in pairs(self.stat_var) do
            local victstat = val / self.total_games * 100
            local stat = string.format('%s - %d (%d%%) ', key, val, victstat)
            new_file:write(stat)
        end
        new_file:write('\n')
        self.total_games = 0
        self.stat_var = {['X WIN']=0,['O WIN']=0,['DRAW']=0}
    end
    new_file:close()
end

function Game:set_opt_scr()
    gui.Manager.clear()
    self.now='opt_scr'
    gui.Label{text=' OPTIONS ', x=set.MIDWID, y=set.MIDHEI-set.DIST*4,
                    fnt=set.TITLEFNT, anchor='s',frame=3}

    local hum_mach = gui.HBox{x=set.MIDWID,y=set.MIDHEI-set.DIST*3}

    hum_mach:add(
                gui.Selector{text='HUMAN', fnt=set.MENUFNT,
                     variable=self.player},
                gui.Selector{text='MACHINE',fnt=set.MENUFNT,
                     variable=self.player}
                    )

    gui.Label{text=string.format('%s MACHINE', self.cel.second),
                    x=set.MIDWID, y=set.MIDHEI-set.DIST*2, anchor='n',
                    fnt=set.GAMEFNT, frame=2}

    local dif_first_sel = gui.HBox{x=set.MIDWID,
                                        y=set.MIDHEI-set.DIST, anchor='n'}

    dif_first_sel:add(
                        gui.Selector{text='EASY',
                        fnt=set.GAMEFNT, variable=self.ai2},
                        gui.Selector{text='MEDIUM',
                        fnt=set.GAMEFNT, variable=self.ai2},
                        gui.Selector{text='HARD',
                        fnt=set.GAMEFNT, variable=self.ai2}
                        )

    gui.Label{text=string.format('%s MACHINE', self.cel.first),
                    x=set.MIDWID, y=set.MIDHEI, anchor='n',
                    fnt=set.GAMEFNT, frame=2}

    local dif_second_sel = gui.HBox{x=set.MIDWID, y=set.MIDHEI+set.DIST,
                                        anchor='n'}

    dif_second_sel:add(
                       gui.Selector{text='EASY',
                        fnt=set.GAMEFNT, variable=self.ai1},
                        gui.Selector{text='MEDIUM',
                        fnt=set.GAMEFNT, variable=self.ai1},
                        gui.Selector{text='HARD',
                        fnt=set.GAMEFNT, variable=self.ai1}
                        )

    gui.Counter{text='PAUSE ', x=set.MIDWID,
                    y=set.MIDHEI+set.DIST*2.5, anchor='n',
                    fnt=set.GAMEFNT,variable=self.ai_dt, modifier=0.2}

    gui.Counter{text='GAMES', x=set.MIDWID,
                    y=set.MIDHEI+set.DIST*3.5, anchor='n',
                    fnt=set.GAMEFNT, min=1, variable=self.number_games}

    gui.Button{text=' BACK ', x=set.MIDWID, y=set.MIDHEI+set.DIST*5,
                anchor='n', fnt=set.MENUFNT,
                command=function() self:set_game_scr() end, frame=1}
end

function Game:draw()
    if self.now == 'menu_scr' or self.now =='opt_scr' then
       gui.Manager.draw()
    elseif self.now == 'game_scr' then
       for _, item in pairs(gui.Manager.items) do
           if item.text == 'PAUSE' and not self.pause then
               goto continue
           end
           item:draw()
           ::continue::
       end
    end
end

function Game:update(dt)
    self.delta_time = self.delta_time + dt
    if self.now == 'menu_scr' or self.now =='opt_scr' then
        gui.Manager.update(dt)
    elseif self.now == 'game_scr' and not self.pause then
        local matrix
        local scores = model.scores(self.matrix)
        local x, y
        local initx, inity
        -- show prev turn
        local view_t = self.view_t
        -- update variables
        self.score_x.val = string.format(' %-2.2d  %s ', scores['X'],'X')
        self.score_o.val = string.format(' %s  %2.2d ', 'O', scores['O'])
        -- use  virtual copy of matrix
        if self.help.bool then
            matrix = model.HELP(self.matrix, self.cel.first)
        else
            matrix = self.matrix
        end

        -- update view
        for _, item in pairs(gui.Manager.items) do
            local upd = item:update(dt)
            if item.type == 'cell' then
                x = item.rect_posx
                y = item.rect_posy
                x = math.floor((x-set.DIST)/set.SIZE)
                y = math.floor((y-set.DIST)/set.SIZE)

                if matrix[x+1][y+1] == '.' then
                    item:set({deffrm=set.GRAYBLUE})
                else
                    item:set({defclr=item.fntclr,
                                text=matrix[x+1][y+1],
                                deffrm = item.frmclr})
                end

                local complex_eq = fc.partial(fc.equal, {x+1, y+1})
                if view_t then
                    local in_show = fc.map(complex_eq, view_t)
                    if fc.isval(true, in_show) then
                        item:set({defclr=item.onfrm})
                    end
                end
                item:setup()
                if upd then initx, inity = x+1, y+1 end
            end
        end
        -- pause before start game and at the end game
        if self.wait_loop then goto continue end
        -- update model
        -- player turn
        local change_turn
        if self.turn == self.cel.first then
            if self.player.val == 'HUMAN' then
                if initx and inity then
                    local xy = model[self.player.val](self.matrix,
                                              self.cel.first, initx, inity)
                    if xy then
                        -- to save self.view_t if wrong move
                        self.view_t = xy
                        change_turn = model.next_turn(self.matrix,
                                                    self.cel.second)
                    end
                end

            else
                -- ai1
                self.view_t = model[self.ai1.val](self.matrix, self.cel.first)
                change_turn = model.next_turn(self.matrix, self.cel.second)
            end
        end

        -- computer turn
        if self.delta_time >= self.ai_dt.val then
            self.delta_time = self.delta_time - self.ai_dt.val
            if self.turn == self.cel.second then
                -- ai2
                self.view_t = model[self.ai2.val](self.matrix,self.cel.second)
                change_turn = model.next_turn(self.matrix,self.cel.first)
            end

        end
        -- check if no valid cells and who next
        self.turn = self:is_over(change_turn)
        ::continue::
    end
end

function Game:is_over(change_turn)
    -- check if free move available
    local fin = model.next_turn(self.matrix, self.turn)
    if not change_turn and fin then return fin end

    if not change_turn then
        self.wait_loop = true
        self:set_fin_scr(model.scores(self.matrix))

    end
    return change_turn
end

return {['Game'] = Game}
