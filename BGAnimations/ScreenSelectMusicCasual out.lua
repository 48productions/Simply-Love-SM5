-- The real animations are handled in the offcommands in overlay
return Def.Actor{ OnCommand=function(self) self:sleep(1) end }