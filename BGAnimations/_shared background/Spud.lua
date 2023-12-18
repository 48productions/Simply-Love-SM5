-- --------------------------------------------------------
-- Spud-specific visual style handling

local file = ...

local anim_data = {
	color_add = {0,0,0},
	diffusealpha = {0.8,0.7,0.75},
	texcoordvelocity = {{0.001,0.03},{0.002,0.04},{-0.0005,0.02}}
}

local t = Def.ActorFrame {
	OnCommand=function(self) self:accelerate(0.8):diffusealpha(1) end,
	HideCommand=function(self) self:visible(false) end,

	BackgroundImageChangedMessageCommand=function(self)
		if not ThemePrefs.Get("RainbowMode") then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end
}

-- Scrolling sprites
if not HolidayCheer() then
	for i=1,3 do
		t[#t+1] = Def.Sprite {
			Texture=THEME:GetPathG("", file..i..".png"),
			OnCommand=function(self)
				self:zoom(0.45):Center()
				:customtexturerect(0,0,1,1):texcoordvelocity(anim_data.texcoordvelocity[i][1], anim_data.texcoordvelocity[i][2])
				
				if ThemePrefs.Get("VisualTheme") ~= "Potato" and ThemePrefs.Get("VisualTheme") ~= "Thonk" then -- Recolor sprites based on the current color, but only in non-potato modes
					self:diffuse(GetHexColor(SL.Global.ActiveColorIndex))
				end
				self:diffusealpha(anim_data.diffusealpha[i])
			end,
			ColorSelectedMessageCommand=function(self)
				if ThemePrefs.Get("VisualTheme") ~= "Potato" and ThemePrefs.Get("VisualTheme") ~= "Thonk" then -- Recolor sprites based on the current color, but only in non-potato modes
					self:linear(0.5)
					:diffuse(GetHexColor(SL.Global.ActiveColorIndex))
					:diffusealpha(anim_data.diffusealpha[i])
				end
			end
		}
	end
end

-- Accent image
t[#t+1] = Def.Sprite {
    Texture=THEME:GetPathG("", "_VisualStyles/Potato/SharedBackground-Accent"), -- Only Spud has the accent image at this time
		OnCommand=function(self)
			self:zoom(0.4):Center()
			:diffusealpha(0.9)
            :spin()
            if AllowThonk() then
                self:effectmagnitude(0,75,1)
            else
                self:effectmagnitude(0,0,2)
            end
		end,
}

return t