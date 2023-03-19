
-- Stage counter/select music animation
local t = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(_screen.cx, _screen.cy)
    end,
}


-- AF 1: Slide right
t[#t+1] = Def.ActorFrame{
    OnCommand=function(self) self:sleep(0.5):accelerate(0.3):x(_screen.w) end,
    
    -- Background
    Def.Quad{
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black ):diffusealpha(0.5):zoomto(_screen.w, 150) end,
    },


    -- SELECT MUSIC text
    Def.BitmapText{
        Font="_upheaval_underline 80px",
        Text="SELECT MUSIC",
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.8):diffusealpha(1):y(-20) end,
        OnCommand=function(self) if not ThemePrefs.Get("RainbowMode") then self:smooth(0.2):diffuse(color('#b5e6e8')):smooth(0.4):diffuse(Color.White) if AllowThonk() then self:accelerate(0.2):addrotationz(-760) end end end,
    }
}


-- AF 2: Slide left
t[#t+1] = Def.ActorFrame{
    OnCommand=function(self) self:sleep(0.5):accelerate(0.3):x(-_screen.w) end,
    
    -- Stage counter text
    Def.BitmapText{
        Font="_upheaval_underline 80px",
        Text=THEME:GetString("Stage","Stage") .. ' ' .. (SL.Global.Stages.PlayedThisGame + 1),
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.5):diffusealpha(0):y(30) end,
        OnCommand=function(self) self:smooth(0.3):diffusealpha(1) if AllowThonk() then self:sleep(0.2):accelerate(0.3):addrotationz(180):zoom(2) end end,
        --ChangeTextCommand=function(self) self:settext(THEME:GetString("Stage","Stage") .. ' ' .. (SL.Global.Stages.PlayedThisGame + 1)):smooth(0.5):diffusealpha(1) end,
    },


    -- Upper/lower borders
    Def.Quad{
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoomto(_screen.w, 5):y(-75) end,
		OnCommand=function(self) if AllowThonk() then self:sleep(0.5):accelerate(0.3):addrotationz(90):addy(50) end end,
    },
    
    Def.Quad{
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoomto(_screen.w, 5):y(75) end,
		OnCommand=function(self) if AllowThonk() then self:sleep(0.5):accelerate(0.3):addrotationz(-90):addy(-50) end end,
    }   
}

return t