local t = Def.ActorFrame{
	OnCommand=function(self) self:diffusealpha(0):sleep(1.4):decelerate(0.2):diffusealpha(1) end
}

for player in ivalues({PLAYER_1, PLAYER_2}) do
	-- bouncing cursor inside the grid of difficulty blocks
	t[#t+1] = LoadActor("./Cursor.lua", player)
end

return t