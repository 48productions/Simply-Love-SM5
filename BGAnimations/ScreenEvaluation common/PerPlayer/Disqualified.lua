if SL.Global.GameMode == "Casual" then return end

local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local disqualified = stats:IsDisqualified()

return LoadFont("_wendy small")..{
	Name="Disqualified"..ToEnumShortString(player),
	InitCommand=function(self) self:diffusealpha(0.7):zoom(0.23):y(_screen.cy+138):diffusealpha(0) end,
	OnCommand=function(self)
		if disqualified then
			self:settext(THEME:GetString("ScreenEvaluation","Disqualified")):sleep(1.7):smooth(0.5):diffusealpha(1)
		end
	end
}