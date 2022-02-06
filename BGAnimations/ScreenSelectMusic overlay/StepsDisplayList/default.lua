local af = Def.ActorFrame{
    Name="StepsDisplayListAF"
}
local paneAF = Def.ActorFrame{
    CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Set") end,
	StepsHaveChangedCommand=function(self) self:queuecommand("Set") end,
}


if GAMESTATE:IsCourseMode() then
	af[#af+1] = LoadActor("./CourseContentsList.lua")
else
	af[#af+1] = LoadActor("./Grid.lua")
end

for player in ivalues({PLAYER_1, PLAYER_2}) do
    -- colored background for chart statistics
    paneAF[#paneAF+1] = LoadActor("./DetailsDisplay.lua", player)
end


af[#af+1] = paneAF
return af