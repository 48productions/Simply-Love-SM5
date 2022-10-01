return Def.ActorFrame{
    LoadActor("./assets/s.png")..{ OnCommand=function(self) self:zoom(0.85):sleep(2.6):smooth(0.4) end, },
}
