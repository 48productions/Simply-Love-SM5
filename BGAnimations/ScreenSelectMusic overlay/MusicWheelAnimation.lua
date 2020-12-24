local t = Def.ActorFrame{}

-- NumWheelItems under [MusicWheel] in Metrics.ini needs to be 17.
-- Only 15 can be seen onscreen at once, but we use 1 extra on top and
-- 1 extra at bottom so that MusicWheelItems don't visually
-- appear/disappear too suddenly while quickly scrolling through the wheel.

-- For this file just use a hardcoded 15, for the sake of animating the
-- "downward cascade" effect that occurs when SelectMusic first appears.
local NumWheelItems = 15

-- Let's also define how long we want to tween each Quad's animation for
local TweenTime = 0.03

-- Let's also find out if we're on our first stage (and thus jankily find if we're transitioning from ScreenProfileLoad)
-- If we're transitioning from gameplay
local FirstStage = (SL.Global.Stages.PlayedThisGame == 0)

-- Each MusicWheelItem has two Quads drawn in front of it, blocking it from view.
-- Each of these Quads is half the height of the MusicWheelItem, and their y-coordinates
-- are such that there is an "upper" and a "lower" Quad.

-- The upper Quad has cropbottom applied while the lower Quad has croptop applied
-- resulting in a visual effect where the MusicWheelItems appear to "grow" out of the center to full-height.

for i=1,NumWheelItems-2 do
	-- upper bg
	t[#t+1] = Def.Quad{
        Condition=FirstStage,
		InitCommand=function(self)
			self:x( _screen.cx+_screen.w/4 - 1)
				:y( 8 + (_screen.h/NumWheelItems)*i )
				:zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
				:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White )
		end,
		OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):cropbottom(1):diffusealpha(0.25):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}
	-- lower bg
	t[#t+1] = Def.Quad{
        Condition=FirstStage,
		InitCommand=function(self)
			self:x( _screen.cx+_screen.w/4 - 1)
				:y( 24 + (_screen.h/NumWheelItems)*i )
				:zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
				:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White )
		end,
		OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):croptop(1):diffusealpha(0.25):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}
    -- upper
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:x( _screen.cx+_screen.w/4 )
				:y( 8 + (_screen.h/NumWheelItems)*i )
				:zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
				:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
		end,
		OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):cropbottom(1):diffusealpha(0.25):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}
	-- lower
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:x( _screen.cx+_screen.w/4 )
				:y( 24 + (_screen.h/NumWheelItems)*i )
				:zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
				:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
		end,
		OnCommand=function(self) self:sleep(i*(TweenTime/2)):linear(TweenTime):croptop(1):diffusealpha(0.25):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}
end

t[#t+1] = Def.BitmapText{
        Condition=FirstStage,
		Font="_upheaval_underline 80px",
		Text=THEME:GetString("ScreenProfileLoad","Loading Profiles..."),
		InitCommand=function(self)
			self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.5):diffusealpha(1):x(_screen.w * .75):y(_screen.cy):draworder(101)
		end,
        OnCommand=function(self)
            self:accelerate(TweenTime * (NumWheelItems - 4)):y(_screen.h):diffusealpha(0)
        end
	}

return t