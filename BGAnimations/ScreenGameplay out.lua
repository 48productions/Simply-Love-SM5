return Def.ActorFrame {
	Def.Quad{
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black):diffusealpha(0) end,
		StartTransitioningCommand=function(self) self:sleep(2):linear(1):diffusealpha(1) end,
	},

    Def.ActorFrame {
        Condition=not GAMESTATE:IsDemonstration(),
        LoadActor(THEME:GetPathG("", "cleared bg.png"))..{ --BG - left half (we render this in two halves so we can get a mirrored gradient across the whole background)
            InitCommand=function(self) self:zoom(0.8):xy(_screen.cx - self:GetZoomedWidth() / 2, _screen.cy):diffuseleftedge(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuserightedge(GetHexColor(SL.Global.ActiveColorIndex-1)):diffusealpha(0) end,
            StartTransitioningCommand=function(self) self:sleep(0.5):accelerate(0.4):diffusealpha(0.8) end
        },
        
        LoadActor(THEME:GetPathG("", "cleared bg.png"))..{ --BG - right half
            InitCommand=function(self) self:zoom(0.8):basezoomx(-1):xy(_screen.cx - self:GetZoomedWidth() / 2, _screen.cy):diffuseleftedge(GetHexColor(SL.Global.ActiveColorIndex+1)):diffuserightedge(GetHexColor(SL.Global.ActiveColorIndex-1)):diffusealpha(0) end,
            StartTransitioningCommand=function(self) self:sleep(0.5):accelerate(0.4):diffusealpha(0.8) end
        },
    
        LoadActor(THEME:GetPathG("", "cleared text-new.png"))..{ --Text
            InitCommand=function(self) self:Center():zoom(0.8):diffusealpha(0) end,
            StartTransitioningCommand=function(self) self:sleep(0.5):accelerate(0.4):diffusealpha(1) end
        },
    }
}