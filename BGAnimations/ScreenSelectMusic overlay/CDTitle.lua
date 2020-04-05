-- modified from 5.3 default

-- max height, max width
local maxh, maxw = 70, 70

local function CDTitleUpdate(self)
	local song = GAMESTATE:GetCurrentSong()
	local cdtitle = self:GetChild("CDTitle")
	local height = cdtitle:GetHeight()
	local width = cdtitle:GetWidth()

	if song then
		if song:HasCDTitle() then
			cdtitle:visible(true)
			cdtitle:Load(song:GetCDTitlePath())
		else
			cdtitle:visible(false)
		end
	else
		cdtitle:visible(false)
	end

    -- Zoom weird (large) CDTitles to maxh or maxw
	if height >= maxh and width >= maxw then
		if height >= width then
			cdtitle:zoom(maxh/height)
		else
			cdtitle:zoom(maxw/width)
		end;
	elseif height >= maxh then
		cdtitle:zoom(maxh/height)
	elseif width >= maxw then
		cdtitle:zoom(maxw/width)
	else 
		cdtitle:zoom(1)
	end
end


local t = Def.ActorFrame{
    OnCommand=function(self) self:SetUpdateFunction(CDTitleUpdate) end;
    Def.Sprite {
        Name="CDTitle";
        OnCommand=function(self) self:x(WideScale(276,382)):y(150):diffuseshift():effectperiod(6):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.4) end;
    }
}

return t