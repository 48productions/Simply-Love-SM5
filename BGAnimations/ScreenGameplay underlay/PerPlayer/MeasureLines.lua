--local player = ...
local pn = ToEnumShortString(...)
local mods = SL[pn].ActiveModifiers

return Def.Actor{
	OnCommand=function(self)
		local player = SCREENMAN:GetTopScreen():GetChild("Player"..pn)

		local notefield = player:GetChild("NoteField")
		if mods.MeasureLines == "Off" then
		  notefield:SetBeatBars(false)
		  notefield:SetBeatBarsAlpha(0, 0, 0, 0)
		else
		  notefield:SetBeatBars(true)

		  if mods.MeasureLines == "Measure" then
			notefield:SetBeatBarsAlpha(0.75, 0, 0, 0)
		  elseif mods.MeasureLines == "Quarter" then
			notefield:SetBeatBarsAlpha(0.75, 0.5, 0, 0)
		  elseif mods.MeasureLines == "Eighth" then
			notefield:SetBeatBarsAlpha(0.75, 0.5, 0.25, 0)
		  end
		end
	end,
}