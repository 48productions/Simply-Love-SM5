--ModfileWarning is a script that displays a popup warning if the player has highlighted a modfile
--It isn't always clear what songs might have mods, or what "mods" even means in the first place,
--so this aims to hopefully help mid-tier players just starting to get into pro mode to avoid playing taro's megalovania file

function AllPlayersSeenModfileWarning()
    local P1Seen = (not GAMESTATE:IsSideJoined(PLAYER_1) and true or SL.P1.ActiveModifiers.PlayerSeenModfileWarning) --Check if each "player" has seen the warning
    local P2Seen = (not GAMESTATE:IsSideJoined(PLAYER_2) and true or SL.P2.ActiveModifiers.PlayerSeenModfileWarning) --If a player is joined, check whether they've actually seen it. If a player isn't joined, default to true (logic inverted as a lua workaround)
    --SM(P1Seen)
    return P1Seen and P2Seen
end

local t = Def.ActorFrame{
    InitCommand=function(self)
        --The modfile warning is not displayed if any of the following is true:
        -- - It is disabled in ThemePrefs
        -- - All players have seen it before.
        --    - The "player saw the modfile warning" flag is saved in the player prefs and will persist across game cycles if a player is using a profile.
        --    - If a player doesn't have a profile, this flag is reset after every game cycle
        
        if not ThemePrefs.Get("AllowModfileWarning") or AllPlayersSeenModfileWarning() then
            self:visible(false)
        else
            self:xy(610, 150):diffusealpha(0):bob():effectperiod(4):effectmagnitude(0,4,0)
        end
    end,
    OnCommand=function(self)
       --self:playcommand("Bob")
    end,
    FadeCommand=function(self)
        self:smooth(1.5):diffusealpha(0.6):smooth(1.5):diffusealpha(0.9):queuecommand("Fade")
    end,
    CurrentSongChangedMessageCommand=function(self)
        local song = GAMESTATE:GetCurrentSong()
		if song and song:GetGroupName():match("%[Mods%]") then --Highlighted a modfile? Wait a second, then start fading the warning in/out
            self:stoptweening():sleep(0.5):smooth(0.4):diffusealpha(0.9):queuecommand("Fade")
            --SL.Global.SeenModfileWarning = true -- Set the flag that the modfile warning has been seen and should be hidden in future sets
            if GAMESTATE:IsSideJoined(PLAYER_1) then SL.P1.ActiveModifiers.PlayerSeenModfileWarning = true end --Also set this flag for all joined players
            if GAMESTATE:IsSideJoined(PLAYER_2) then SL.P2.ActiveModifiers.PlayerSeenModfileWarning = true end
        else
            self:stoptweening():smooth(0.2):diffusealpha(0)
        end
	end,
    OffCommand=function(self)
        self:finishtweening():smooth(0.2):diffusealpha(0)
    end,
}

--Background outline
t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(270, 62):diffuse(color("#492915"))
	end,
}

--Background
t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(266, 58):diffuse(color("#111111"))
	end,
}

--Text
t[#t+1] = LoadFont("Common Normal")..{
    Text=ScreenString("ModfileWarning"),
    InitCommand=function(self)
        self:diffuse(ThemePrefs.Get("RainbowMode") and color("#563F32") or color("#FF9B66"))
    end,
    OnCommand=function(self)
        
    end,
}

return t

--Delay in case they're scrolling through songs fast and only briefly go by a song without staying on it