local TweenTime = 0.03
local NumWheelItems = 15


local t = Def.ActorFrame{
	InitCommand=function(self)
		--self:Center():draworder(101)
        SOUND:DimMusic(0.7, 60)
	end,
    OnCommand=function(self)
        --self:sleep(5) --Debug: Sleep a bit longer, uncomment if you're tweaking text/animations here
        self:sleep(TweenTime * NumWheelItems):queuecommand("Load")
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
            self:decelerate(TweenTime * NumWheelItems):diffusealpha(1)
                :y(SL.Global.GameMode ~= "Casual" and _screen.cy or _screen.h / 6)
        end
	}
}

if SL.Global.GameMode ~= "Casual" then --Going into a non-casual gamemode that uses the regular music wheel, play the first half of the music wheel intro animation
    
    --This animation is a reversed version of the one in BGAnimations/ScreenSelectMusic overlay/MusicWheelAnimation.lua, see there for documentation
    for i=1,NumWheelItems-2 do
    -- upper bg
        t[#t+1] = Def.Quad{
            InitCommand=function(self)
                self:x( _screen.cx+_screen.w/4 - 1)
                    :y( 8 + (_screen.h/NumWheelItems)*i )
                    :zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
                    :diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White )
                    :cropbottom(1)
            end,
            OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):cropbottom(0) end,
        }
        -- lower bg
        t[#t+1] = Def.Quad{
                InitCommand=function(self)
                self:x( _screen.cx+_screen.w/4 - 1 )
                    :y( 24 + (_screen.h/NumWheelItems)*i )
                    :zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
                    :diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White )
                    :croptop(1)
            end,
            OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):croptop(0) end,
        }
        -- upper
        t[#t+1] = Def.Quad{
            InitCommand=function(self)
                self:x( _screen.cx+_screen.w/4 )
                    :y( 8 + (_screen.h/NumWheelItems)*i )
                    :zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
                    :diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
                    :cropbottom(1)
            end,
            OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):cropbottom(0) end,
        }
        -- lower
        t[#t+1] = Def.Quad{
                InitCommand=function(self)
                self:x( _screen.cx+_screen.w/4 )
                    :y( 24 + (_screen.h/NumWheelItems)*i )
                    :zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
                    :diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
                    :croptop(1)
            end,
            OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):croptop(0) end,
        }
    end
else --Transitioning to casual mode, set tweentime to 0 so we transition instantly (this also affects the sleep delay before we go to the next screen)
    tweentime = 0 --(Comment out to reenable casual's loading text)
end

return t