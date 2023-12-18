local af = Def.ActorFrame{ InitCommand=function(self) self:Center() end }

local SetThemeColor = function(color)
	SL.Global.ActiveColorIndex = color
	ThemePrefs.Set("SimplyLoveColor", color)
	ThemePrefs.Save()
	MESSAGEMAN:Broadcast("ColorSelected")
end

-- Fetch (and enforce) the correct simply love color if we're in potato (or thonk) mode
-- This should be 11, or 5 during Holiday Cheer
-- (This *probably* can't be in SL_Init, where the color is initially set, because I'm not sure if everything needed for this check will be fully loaded
local slc = SL.Global.ActiveColorIndex
if ThemePrefs.Get("VisualTheme") == "Potato" or ThemePrefs.Get("VisualTheme") == "Thonk" then
	if HolidayCheer() then
		if slc ~= 5 then SetThemeColor(5) end
	else
		if slc ~= 11 then SetThemeColor(11) end
	end
end


-- semitransparent black quad as background for 7 decorative arrows
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w,0):diffuse(Color.Black):Center() end,
	OnCommand=function(self) self:accelerate(0.3):zoomtoheight(128):diffusealpha(0.9):sleep(2.5) end,
	OffCommand=function(self) self:accelerate(0.3):zoomtoheight(0) end
}

-- loop to add 7 SM5 logo arrows to the primary ActorFrame
for i=1,7 do

	local arrow = Def.ActorFrame{
		InitCommand=function(self) self:xy(_screen.cx + (i-4) * 50, _screen.cy):diffusealpha(0) end,
		OnCommand=function(self)
			-- thonk
			if AllowThonk() then
				self:diffusealpha(1):rotationy(-90):sleep(i*0.1 + 0.2)
				self:smooth(0.25):rotationy(0):sleep(0.8):bouncebegin(0.8):y(_screen.h)
			-- everything else
			else
				self:sleep(i*0.1 + 0.2)
				self:linear(0.75):diffusealpha(1):linear(0.75):diffusealpha(0)
			end

			self:queuecommand("Hide")
		end,
		HideCommand=function(self) self:visible(false) end,
	}

	-- desaturated SM5 logo
	arrow[#arrow+1] = LoadActor("logo.png")..{
		InitCommand=function(self) self:zoom(0.1):diffuse(GetHexColor(slc-i-3)) end,
	}

	-- only add Thonk asset if needed
	if AllowThonk() then
		arrow[#arrow+1] = LoadActor("thonk.png")..{
			InitCommand=function(self) self:zoom(0.1):xy(6,-2) end,
		}
	end

	af[#af+1] = arrow
end

af[#af+1] = LoadFont("Common Normal")..{
	Text=ScreenString("ThemeDesign"),
	InitCommand=function(self) self:Center():diffuse(GetHexColor(slc)):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(3):linear(0.25):diffusealpha(1) end,
	OffCommand=function(self) self:linear(0.25):diffusealpha(0) end,
}

return af