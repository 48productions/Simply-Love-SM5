local file

-- With thonk mode enabled, force the thonk background. Otherwise, find the background file for the current style
if AllowThonk() then
	file = "_VisualStyles/Thonk/SharedBackground-"
else
    file = "_VisualStyles/" .. ThemePrefs.Get("VisualTheme") .. "/SharedBackground-"
end

local af = Def.ActorFrame{
	OnCommand=function(self) self:Center() end,
	
	-- Background Gradient
	Def.Quad{
		OnCommand=function(self)
			self:zoomto(_screen.w, _screen.h)
			if ThemePrefs.Get("VisualTheme") == "Potato" or ThemePrefs.Get("VisualTheme") == "Thonk" then
				self:diffuseupperleft(color("#912c00")):diffuselowerright(color("#912c00"))
					:diffuseupperright(color("#a65900")):diffuselowerleft(color("#a65900"))
			else
				self:diffuseupperright(GetHexColor(SL.Global.ActiveColorIndex+2)):diffuseupperleft(GetHexColor(SL.Global.ActiveColorIndex+2))
					:diffuselowerleft(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuselowerright(GetHexColor(SL.Global.ActiveColorIndex+1))
					:diffusealpha(0.4)
			end
		end,
	},
	
	-- Fullscreen potatoes
	Def.Sprite{
		Texture=THEME:GetPathG("", file.."1.png"),
		OnCommand=function(self)
			self:zoom(0.45)
			:customtexturerect(0,0,1,1):texcoordvelocity(0.001, 0.03)
			
			if ThemePrefs.Get("VisualTheme") ~= "Potato" and ThemePrefs.Get("VisualTheme") ~= "Thonk" then -- Recolor sprites based on the current color, but only in non-potato modes
				self:diffuse(GetHexColor(SL.Global.ActiveColorIndex))
			end
			self:diffusealpha(0.75)
		end,
	},
	
	-- Left potatoes
	Def.Sprite{
		Texture=THEME:GetPathG("", file.."2.png"),
		--Texture=THEME:GetPathG("", "_VisualStyles/Potato/SharedBackground.png"),
		OnCommand=function(self)
			self:zoom(0.24):x(_screen.w * 0.13 - _screen.cx)
			:customtexturerect(0,0,1,1):texcoordvelocity(0.003, 0.04):faderight(0.2)
			
			if ThemePrefs.Get("VisualTheme") ~= "Potato" and ThemePrefs.Get("VisualTheme") ~= "Thonk" then -- Recolor sprites based on the current color, but only in non-potato modes
				self:diffuse(GetHexColor(SL.Global.ActiveColorIndex))
			end
			self:diffusealpha(0.7)
		end,
	},
	
	-- Right potatoes
	Def.Sprite{
		Texture=THEME:GetPathG("", file.."3.png"),
		OnCommand=function(self)
			self:zoom(0.24):x(_screen.w * 0.87 - _screen.cx)
			:customtexturerect(0,0,1,1):texcoordvelocity(0.003, 0.04):fadeleft(0.2)
			
			if ThemePrefs.Get("VisualTheme") ~= "Potato" and ThemePrefs.Get("VisualTheme") ~= "Thonk" then -- Recolor sprites based on the current color, but only in non-potato modes
				self:diffuse(GetHexColor(SL.Global.ActiveColorIndex))
			end
			self:diffusealpha(0.7)
		end,
	},
	
	-- Big Arrow:tm:
	LoadActor(THEME:GetPathG("","BigArrow.lua"), 1)
}

return af