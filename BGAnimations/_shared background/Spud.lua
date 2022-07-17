-- --------------------------------------------------------
-- Spud-specific visual style handling

local file = "_VisualStyles/Potato/SharedBackground-"

local anim_data = {
	color_add = {0,0,0,0,0,0,1,1,1,1},
	diffusealpha = {0.8,0.7,0.75,0.1,0.1,0.1,0.1,0.05,0.1,0.1},
	texcoordvelocity = {{0.001,0.03},{0.002,0.04},{-0.0005,0.02},{0.02,0.02},{0.03,0.03},{0.02,0.02},{0.03,0.01},{-0.03,0.01},{0.05,0.03},{0.03,0.04}}
}

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:visible(ThemePrefs.Get("VisualTheme") == "Potato")
	end,
	OnCommand=function(self) self:accelerate(0.8):diffusealpha(1) end,
	HideCommand=function(self) self:visible(false) end,

	BackgroundImageChangedMessageCommand=function(self)
		if ThemePrefs.Get("VisualTheme") == "Potato" then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end
}

for i=1,3 do
	t[#t+1] = Def.Sprite {
		Texture=THEME:GetPathG("", file..i),
		OnCommand=function(self)
			self:zoom(0.4):Center()
			:customtexturerect(0,0,1,1):texcoordvelocity(anim_data.texcoordvelocity[i][1], anim_data.texcoordvelocity[i][2])
			:diffusealpha(anim_data.diffusealpha[i])
		end,
	}
end

t[#t+1] = Def.Sprite {
    Texture=THEME:GetPathG("", file.."Accent"),
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