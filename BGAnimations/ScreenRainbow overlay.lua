--ScreenRainbow: Now displays configurable news!

local img = getNewsImg(nil) --Defined in 06 SL-Utilities.lua

if img == nil then img = THEME:GetPathG("", "_blank.png") end --No news to display, default to blank

return Def.Sprite{
    Texture=img,
    InitCommand=function(self) self:FullScreen():diffusealpha(0) end,
    OnCommand=function(self) self:smooth(1):diffusealpha(1) end,
    OffCommand=function(self) self:smooth(1):diffusealpha(0) end,
}