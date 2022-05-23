local tweentime = 0.5


local t = Def.ActorFrame{
	InitCommand=function(self)
		self:Center()--:draworder(101)
        SOUND:DimMusic(0.7, 60)
	end,
    OnCommand=function(self)
        --self:sleep(20) --Debug: Sleep a bit longer, uncomment if you're tweaking text/animations here
        self:sleep(tweentime):queuecommand("Load")
    end,
    LoadCommand=function(self)
		SCREENMAN:GetTopScreen():Continue()
    end,
	OffCommand=function(self)
		-- by the time this screen's OffCommand is called, player mods should already have been read from file
		-- and applied to the SL[pn].ActiveModifiers table, so it is now safe to call ApplyMods() on any human players
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			ApplyMods(player)
		end
	end,

	Def.BitmapText{
        --The "Loading" text's position can change (but currently doesn't) based on whether we're transitioning to the casual or pro music wheel
        --For casual, this text can optionally slide into the center top of the screen.
        --To enable this, comment out the TweenTime = 0 call in the if statement below and comment out the condition preventing this actor from loading in Casual Mode. Also uncomment the line for the LoadingTextAnimation at the bottom of ScreenSelectMusicCasual overlay
        --For pro, it slides into the center right of the screen (over the music wheel animation)
		Font="_upheaval_underline 80px",
		Text=THEME:GetString("ScreenProfileLoad","Loading Profiles..."),
        Condition=SL.Global.GameMode ~= "Casual", --Don't load the loading text in casual mode (Comment out to reenable casual's loading text)
		InitCommand=function(self)
			self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.5):diffusealpha(0):draworder(101):y(0)
                :x(SL.Global.GameMode ~= "Casual" and _screen.w * .75 or _screen.cx)
		end,
        OnCommand=function(self)
            self:decelerate(tweentime):diffusealpha(1)
                :y(SL.Global.GameMode ~= "Casual" and _screen.cy or _screen.h / 6)
        end
	}
}

if SL.Global.GameMode ~= "Casual" then --Going into a non-casual gamemode that uses the regular music wheel, play the first half of the music wheel intro animation
    
    -- AF 1: Slide right
    t[#t+1] = Def.ActorFrame{
        InitCommand=function(self) self:x(-_screen.w ) end,
        OnCommand=function(self) self:decelerate(tweentime):x(0) end,
        
        -- Background
        Def.Quad{
            InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black ):diffusealpha(0.5):zoomto(_screen.w, 150) end,
        },


        -- SELECT MUSIC text
        Def.BitmapText{
            Font="_upheaval_underline 80px",
            Text="SELECT MUSIC",
            InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.8):diffusealpha(1):y(-20) end,
        }
    }


    -- AF 2: Slide left
    t[#t+1] = Def.ActorFrame{
        InitCommand=function(self) self:x(_screen.w ) end,
        OnCommand=function(self) self:decelerate(tweentime):x(0) end,
        
        -- Stage counter text
        Def.BitmapText{
            Font="_upheaval_underline 80px",
            Text=THEME:GetString("ScreenProfileLoad","Loading Profiles..."),
            InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.5):diffusealpha(1):y(30) end,
        },


        -- Upper/lower borders
        Def.Quad{
            InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoomto(_screen.w, 5):y(-75) end,
        },
        
        Def.Quad{
            InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoomto(_screen.w, 5):y(75) end,
        }
    }
else --Transitioning to casual mode, set tweentime to 0 so we transition instantly (this also affects the sleep delay before we go to the next screen)
    tweentime = 0 --(Comment out to reenable casual's loading text)
end

return t