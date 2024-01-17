local player = ...
local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local startDelay = 1.2

local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	-- x values for P1 and P2
	x = { P1=64, P2=94 }
}

local RadarCategories = {
	Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
	-- x values for P1 and P2
	x = { P1=-180, P2=218 }
}


local t = Def.ActorFrame{
	InitCommand=function(self)self:zoom(0.8):xy(90,_screen.cy-24) end,
	OnCommand=function(self)
		-- shift the x position of this ActorFrame to -90 for PLAYER_2
		if player == PLAYER_2 then
			self:x( self:GetX() * -1 )
		end
	end
}

local showEX = SL.Global.GameMode == "FA+"

-- do "regular" TapNotes first
for i=1,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = pss:GetTapNoteScores( "TapNoteScore_"..window )

	-- actual numbers
	t[#t+1] = Def.RollingNumbers{
		Font="_ScreenEvaluation numbers",
		InitCommand=function(self)
			self:zoom(0.5):horizalign(right)

			if SL.Global.GameMode ~= "ITG" then
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
			end

			-- if some TimingWindows were turned off, the leading 0s should not
			-- be colored any differently than the (lack of) JudgmentNumber,
			-- so load a unique Metric group.
			if SL[pn].ActiveModifiers.TimingWindows[i]==false and i ~= #TapNoteScores.Types then
				self:Load("RollingNumbersEvaluationNoDecentsWayOffs")
				self:diffuse(color("#444444"))

			-- Otherwise, We want leading 0s to be dimmed, so load the Metrics
			-- group "RollingNumberEvaluationA"	which does that for us.
			else
				self:Load("RollingNumbersEvaluationA")
			end
		end,
		BeginCommand=function(self)
			self:x( TapNoteScores.x[pn] )
			self:y((i-1)*35 -20)
			self:diffusealpha(0)
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(0.2 * i) end
            self:sleep(startDelay + 0.08 * i):queuecommand("StartRolling")
		end,
        StartRollingCommand=function(self)
            self:targetnumber(number):smooth(0.1):diffusealpha(1)
        end,
	}

end


-- then handle holds, mines, hands, rolls
for index, RCType in ipairs(RadarCategories.Types) do

	local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
	local possible = pss:GetRadarPossible():GetValue( "RadarCategory_"..RCType )

	-- player performace value
	t[#t+1] = Def.RollingNumbers{
		Font="_ScreenEvaluation numbers",
		InitCommand=function(self) self:zoom(0.5):zoomy(showEX and 0.4 or 0.5):horizalign(right):Load("RollingNumbersEvaluationB") end,
		BeginCommand=function(self)
			self:y(showEX and ((index-1)*27 + 88) or ((index-1)*35 + 53))
			self:x( RadarCategories.x[pn] ):diffusealpha(0)
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(0.2 * index) end
            self:sleep(startDelay + 0.08 * (index)):queuecommand("StartRolling")
		end,
        StartRollingCommand=function(self)
            self:targetnumber(performance):smooth(0.1):diffusealpha(1)
        end,
	}

	--  slash
	t[#t+1] = LoadFont("Common Normal")..{
		Text="/",
		InitCommand=function(self) self:diffuse(color("#5A6166")):zoom(1.25):zoomy(showEX and 1.15 or 1.25):horizalign(right) end,
		BeginCommand=function(self)
			self:y(showEX and ((index-1)*27 + 87) or ((index-1)*35 + 53))
			self:x( ((player == PLAYER_1) and -168) or 230 )
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(0.2 * index) end
            self:diffusealpha(0):sleep(startDelay + 0.08 * (index)):smooth(0.1):diffusealpha(1)
		end
	}

	-- possible value
	t[#t+1] = LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=function(self) self:zoom(0.5):zoomy(showEX and 0.4 or 0.5):horizalign(right) end,
		BeginCommand=function(self)
			self:y(showEX and ((index-1)*27 + 88) or ((index-1)*35 + 53))
			self:x( ((player == PLAYER_1) and -114) or 286 )
			self:settext(("%03.0f"):format(possible))
			local leadingZeroAttr = { Length=3-tonumber(tostring(possible):len()), Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(0.2 * index) end
            self:diffusealpha(0):sleep(startDelay + 0.08 * (index)):smooth(0.1):diffusealpha(1)
		end,
	}
end

return t