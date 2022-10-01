return Def.ActorFrame{
    LoadActor("./assets/minus.png")..{ OnCommand=function(self) self:zoom(0.85):diffusealpha(0):sleep(2.6):smooth(0.4):addx(60):diffusealpha(1) end, },
    LoadActor("./assets/b.png")..{ OnCommand=function(self) self:zoom(0.85):sleep(2.6):smooth(0.4):addx(-60) end, },
}
