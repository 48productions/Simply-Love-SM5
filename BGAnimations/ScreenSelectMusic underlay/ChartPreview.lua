local prefoptions = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Preferred")

local af = Def.ActorFrame{
    --OnCommand=function(self) self:diffusealpha(1) end,
    Def.NoteField{
        AutoPlay=true,
        Player=PLAYER_1,
        NoteSkin=prefoptions:NoteSkin(),
        InitCommand=function(self)
            self:xy(-_screen.cx*1.2, 0)
        end,
        OnCommand=function(self)
            local plroptions = self:GetPlayerOptions("ModsLevel_Current")
            local prefoptionsstr = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptionsString("ModsLevel_Preferred")
            SM(prefoptionsstr)
            plroptions:FromString(prefoptionsstr)
            if AllowThonk() then
                plroptions:TanDrunk(5, 1)
            else
                plroptions:Stealth(0.9, 1)
                plroptions:Dark(0.9, 1)
            end
            plroptions:DrawSizeBack(-0.9)
        end,
        SetCommand=function(self)
            self:visible(false):stoptweening():sleep(0.55):queuecommand("ReloadNotefield")
        end,
        ReloadNotefieldCommand=function(self)
            self:stoptweening()
            local chartindex
            for index, chart in ipairs(GAMESTATE:GetCurrentSong():GetAllSteps()) do
                if chart == GAMESTATE:GetCurrentSteps(PLAYER_1) then
                    chartindex = index
                end
            end
            if not chartindex then SM("bruh") return end
            local noteData = GAMESTATE:GetCurrentSong():GetNoteData(chartindex)
            if not noteData then SM("bRUH") return end
            self:SetNoteDataFromLua(noteData)
            self:visible(true)
            --[[local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
            if steps then
                self:ChangeReload( steps )
            end]]
        end,
    }
}

return af