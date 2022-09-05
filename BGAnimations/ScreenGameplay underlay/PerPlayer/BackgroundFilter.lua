local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

return Def.ActorFrame{
    -- Check if we got a Full Combo as the OffCommand plays, play an animation if we did
    InitCommand=function(self) self:xy(GetNotefieldX(player), _screen.cy ) end,
    --OnCommand=function(self) self:sleep(3):playcommand("ComboFlash", SL.JudgmentColors[SL.Global.GameMode][1]) end, -- Debug: Force the FC animation in the OnCommand
    OffCommand=function(self) self:queuecommand("CheckCombo") end,
    CheckComboCommand=function(self)
        local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
        local FlashColor = nil
        local WorstAcceptableFC = SL.Preferences[SL.Global.GameMode].MinTNSToHideNotes:gsub("TapNoteScore_W", "")

        for i=1, tonumber(WorstAcceptableFC) do
            if pss:FullComboOfScore("TapNoteScore_W"..i) then
                FlashColor = SL.JudgmentColors[SL.Global.GameMode][i]
                break
            end
        end
    
        if (FlashColor ~= nil) then
            self:playcommand("ComboFlash", FlashColor)
        end
    end,
    Def.Quad{
        InitCommand=function(self)
            self:diffuse(Color.Black)
                :diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
                :zoomto( GetNotefieldWidth(player), _screen.h )
        end,
        ComboFlashCommand=function(self, FlashColor)
            self:fadeleft(1):faderight(1):accelerate(0.25):diffuse( FlashColor ):fadeleft(0.1):faderight(0.1)
                :accelerate(0.5):faderight(1):fadeleft(1)
                :accelerate(0.15):diffusealpha(0)
        end,
    },
    Def.BitmapText{
        Text=ScreenString("FullCombo"),
        Font="_upheaval_underline 80px.ini",
        InitCommand=function(self)
            self:diffusealpha(0):shadowlength(3):baserotationz(-20):zoom(0.1):y(_screen.h/5)
        end,
        ComboFlashCommand=function(self, FlashColor)
            self:bounceend(0.25):diffusealpha(1):zoom(0.5):decelerate(2):diffusealpha(0):zoom(0.55):addrotationz(5)
        end,
    },
}