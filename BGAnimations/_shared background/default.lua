-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then
	return LoadActor( THEME:GetPathB("", "_shared background/Snow.lua") )
end

local af = Def.ActorFrame{}

-- use the "VisualTheme" ThemePrefs value to generate a proper filepath to the appropriate
-- SharedBackground texture and pass it to Normal.lua and RainbowMode.lua now as this file
-- is being initialized.

-- if the player chooses a different VisualTheme during runtime, MESSAGEMAN will broadcast
-- "BackgroundImageChanged" which we can use in Normal.lua and RainbowMode.lua to Load() the
-- newly-appropriate texture from disk into each Sprite; see also: ./BGAnimations/ScreenOptionsService overlay.lua
local file = THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualTheme") .. "/SharedBackground.png")
if AllowThonk() then
	file = THEME:GetPathG("", "_VisualStyles/Thonk/SharedBackground.png")
end

-- a simple Quad to serve as the backdrop
af[#af+1] = Def.Quad{
	InitCommand=function(self)
        self:FullScreen():Center()
        if ThemePrefs.Get("VisualTheme") == "Potato" then
            self:diffusetopedge(color("#1f1002")):diffusebottomedge(color("#201300"))
        else
            self:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
        end
    end,
	BackgroundImageChangedMessageCommand=function(self)
		THEME:ReloadMetrics()
		SL.Global.ActiveColorIndex = ThemePrefs.Get("RainbowMode") and 3 or ThemePrefs.Get("SimplyLoveColor")
		self:linear(1)
        if ThemePrefs.Get("VisualTheme") == "Potato" then
            self:diffusetopedge(color("#1f1002")):diffusebottomedge(color("#201300"))
        else
            self:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
        end
	end
}

af[#af+1] = LoadActor("./Normal.lua", file)
af[#af+1] = LoadActor("./RainbowMode.lua", file)

return af