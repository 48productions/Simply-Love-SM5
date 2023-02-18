return Def.ActorFrame{
    InitCommand=function(self)
        self:xy(_screen.cx, 0)
    end,
    Def.Quad{
        Name="Header",
        InitCommand=function(self)
            self:diffuse(0,0,0,0.85):zoomtowidth(_screen.w):valign(0)
    
            if SL.Global.GameMode == "StomperZ" then
                self:zoomtoheight(40)
            else
                self:zoomtoheight(80)
            end
        end
    },
    Def.ActorFrame{
        Def.Sprite{
            Texture=THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualTheme") .. "/SharedBackground-1"),
            InitCommand=function(self) 
                self:cropto(_screen.w, 80):customtexturerect(0,0,5,0.5):texcoordvelocity(0, -0.02)
                :diffusealpha(1):valign(0):fadebottom(0.3):diffusealpha(0.4)
				if AllowThonk() then self:rainbow() end
            end,
        },
    },
}