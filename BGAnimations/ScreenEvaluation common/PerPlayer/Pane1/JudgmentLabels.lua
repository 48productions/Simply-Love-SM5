local player = ...
local pn = ToEnumShortString(player)
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)

local firstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

local getStringFromTheme = function( arg )
	return THEME:GetString(tns_string, arg);
end

--Values above 0 means the user wants to be shown or told they are nice.
local nice = ThemePrefs.Get("nice") > 0 and SL.Global.GameMode ~= "Casual"

local showFAPlus = SL[pn].ActiveModifiers.ShowFaPlusWindow
local showEX = showFAPlus

-- Iterating through the enum isn't worthwhile because the sequencing is so bizarre...
local TapNoteScores = {}
TapNoteScores.Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
TapNoteScores.Names = map(getStringFromTheme, TapNoteScores.Types)

-- Add W0 to this table if needed
if showFAPlus then
	table.insert(TapNoteScores.Types, 1, 'W0')
	table.insert(TapNoteScores.Names, 1, THEME:GetString("TapNoteScoreFA+", "W1"))
end

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Hands'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}

local EnglishRadarCategories = {
	[THEME:GetString("ScreenEvaluation", 'Holds')] = "Holds",
	[THEME:GetString("ScreenEvaluation", 'Mines')] = "Mines",
	[THEME:GetString("ScreenEvaluation", 'Hands')] = "Hands",
	[THEME:GetString("ScreenEvaluation", 'Rolls')] = "Rolls",
}

local t = Def.ActorFrame{
	InitCommand=function(self) self:xy(50, _screen.cy-24) end,
	OnCommand=function(self)
		if player == PLAYER_2 then
			self:x( self:GetX() * -1)
		end
	end
}

local windows = table.copy(SL[pn].ActiveModifiers.TimingWindows)
if showFAPlus then table.insert(windows, 1, windows[1]) end -- If FA+ is enabled, add in an extra value to account for the extra window, here

--  labels: W1 ---> Miss
for i=1, #TapNoteScores.Types do
	-- no need to add BitmapText actors for TimingWindows that were turned off
	if windows[i] or i==#TapNoteScores.Types then

		local window = TapNoteScores.Types[i]
		local label = TapNoteScores.Names[i]

		t[#t+1] = LoadFont("Common Normal")..{
			Text=label:upper(),
			InitCommand=function(self) self:zoom(0.833):horizalign(right):maxwidth(76) end,
			BeginCommand=function(self)
				self:x( (player == PLAYER_1 and 28) or -28 )
				self:y(showFAPlus and ((i-1)*24.8 -17) or ((i-1)*28 -13))

				-- diffuse the JudgmentLabels the appropriate colors for the current FA+ setting
				self:diffuse( SL.JudgmentColors[showFAPlus and 'FA+' or 'ITG'][i] ):diffusealpha(0)
                if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(0.2 * i) end
                self:sleep(1 + 0.07 * i):smooth(0.1):diffusealpha(1)
			end
		}
	end
end

-- labels: holds, mines, hands, rolls
for index, label in ipairs(RadarCategories) do

	local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )
	local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )

	t[#t+1] = LoadFont("Common Normal")..{
		-- lua ternary operators are adorable -ian5v
		Text=(nice and (performance == 69 or possible == 69)) and 'nice' or label,
		InitCommand=function(self) self:zoom(0.833):horizalign(right):zoomy(showEX and 0.7 or 0.833) end,
		BeginCommand=function(self)
			self:x( (player == PLAYER_1 and -160) or 90 )
			self:y(showEX and ((index-1)*22.4 + 68) or ((index-1)*28 + 41))
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(0.2 * index) end
            self:diffusealpha(0):sleep(1 + 0.07 * index):smooth(0.1):diffusealpha(1)
		end
	}
end

return t
