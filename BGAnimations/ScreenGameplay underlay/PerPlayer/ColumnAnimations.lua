-- don't allow ColumnFlashOnMiss to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then return end

local player = ...
local popts = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Song')
local mods = SL[ToEnumShortString(player)].ActiveModifiers

local columnsMiss = {}
local columnsCue = {}

local curCueIndex = 1
local cueList = SL[ToEnumShortString(player)].Streams.ColumnCues
local breakLeft = {0, 0, 0, 0}


local y_offset = 80

-- Calculate receptor y-positions, applying the Split, Cross, Alternate, and Reverse mods found in player options
local function calculateSCAR(column)
	if popts == nil then return 1 end -- No player options for some reason = bail here
	if popts:Centered() == 1 then return 0.5 end -- Centered overrides all other SCAR mods... I think?
	
	local ypos = 1 -- Start with the standard receptor y position and invert it based on the selected mods
	if popts:Reverse() == 1 then ypos = ypos * -1 end -- Reverse inverts all columns
	if popts:Split() == 1 and (column == 3 or column == 4) then ypos = ypos * -1 end -- Split inverts columns 3 and 4
	if popts:Alternate() == 1 and (column == 2 or column == 4) then ypos = ypos * -1 end -- Alternate inverts columns 2 and 4
	if popts:Cross() == 1 and (column == 2 or column == 3) then ypos = ypos * -1 end -- Split inverts columns 2 and 3
	return ypos == 1 and 1 or -1
end

-- Check if we need to display a column cue
local Update=function(self)
	-- If there are cues left to show...
	if curCueIndex <= #cueList then
		local curTime = GAMESTATE:GetPlayerState(player):GetSongPosition():GetMusicSecondsVisible()
		local curCue = cueList[curCueIndex]
		
		-- Show the next cue!
		if curCue.startTime <= curTime then
			curCueIndex = curCueIndex + 1
			
			-- Correct duration for our rate mod
			local cueDuration = curCue.duration / SL.Global.ActiveModifiers.MusicRate
			
			-- Play the animation on the correct columns
			for column in ivalues(curCue.columns) do
				columnsCue[column.colNum]:playcommand("Cue", {duration=cueDuration, isMine=column.isMine})
			end
		end
	end
end

if mods.ColumnFlashOnMiss or mods.ColumnCues then

	local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
	local style = GAMESTATE:GetCurrentStyle(player)
	local width = style:GetWidth(player)

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:x( GetNotefieldX(player))
			-- Via empirical observation/testing, it seems that 200% mini is the effective cap.
			-- At 200% mini, arrows are effectively invisible; they reach a zoom_factor of 0.
			-- So, keeping that cap in mind, the spectrum of possible mini values in this theme
			-- becomes 0 to 2, and it becomes necessary to transform...
			-- a mini value like 35% to a zoom factor like 0.825, or
			-- a mini value like 150% to a zoom factor like 0.25
			local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
			self:zoomx( zoom_factor )
			
			-- Start checking for column cues, if enabled
			if mods.ColumnCues then
				local cue = cueList[1]
				local cueDuration = cue.duration / SL.Global.ActiveModifiers.MusicRate
			
				-- Play the first animation on the correct columns
				for column in ivalues(cue.columns) do
					columnsCue[column.colNum]:playcommand("FirstCue", {duration=cueDuration, isMine=column.isMine})
				end
				
				self:SetUpdateFunction(Update)
			end
		end,
		
		-- Show a column flash if we get a ~bad~ judgement
		JudgmentMessageCommand=function(self, params)
			if mods.ColumnFlashOnMiss then
				if params.Player == player and (params.Notes or params.Holds) then
					for i,col in pairs(params.Notes or params.Holds) do
						local tns = ToEnumShortString(params.TapNoteScore or params.HoldNoteScore)
						if tns == "Miss" or tns == "MissedHold" then
							columnsMiss[i]:playcommand("Flash")
						end
					end
				end
			end
		end
	}

	for ColumnIndex=1,NumColumns do
		local reversed = 1 - calculateSCAR(ColumnIndex) -- reversed is a float - 0 = normal, 1 = reverse, 0.5 = center
		
		-- Column Flash on Miss Actor
		af[#af+1] = Def.Quad{
			InitCommand=function(self)
				columnsMiss[ColumnIndex] = self

				self:diffuse(0,0,0,0)
					:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
					:y(80 + (reversed * 200))
					:vertalign(top)
					:setsize(width/NumColumns, _screen.h - y_offset)
				
				-- Fade direction should correspond to reverse
				if reversed <= 0.5 then
					self:fadebottom(0.333):vertalign(top)
				else
					self:fadetop(0.333):vertalign(bottom)
				end
	        end,
			FlashCommand=function(self)
				self:diffuse(1,0,0,0.66)
					:accelerate(0.165):diffuse(0,0,0,0)
			end
		}
		
		
		-- Column Cue Actor
		af[#af+1] = Def.ActorFrame{
			InitCommand=function(self)
				columnsCue[ColumnIndex] = self
				self:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
					:y(80 + (reversed * 200))
					:GetChild("Flash"):diffuse(0,0,0,0):setsize(width/NumColumns, _screen.h - y_offset)
				
				-- Fade direction should correspond to reverse
				if reversed <= 0.5 then
					self:GetChild("Flash"):fadebottom(0.333):vertalign(top)
				else
					self:GetChild("Flash"):fadetop(0.333):vertalign(bottom)
				end
	        end,
			
			-- Column cue animation (only used for the first cue)
			FirstCueCommand=function(self, params)
				local cueColor = params.isMine and color("1,0,0,0.2") or color("0.3,1,1,0.2")
				self:GetChild("Flash"):stoptweening()
					:sleep(2.2):accelerate(0.15):diffuse(cueColor)
			end,
			
			-- Column cue animation
			CueCommand=function(self, params)
				local cueColor = params.isMine and color("1,0,0,0.2") or color("0.3,1,1,0.2")
				self:GetChild("Flash"):stoptweening()
				
				-- Really short cues (namely the first one of a song) won't have time to fade on/off. The first one specifically is already faded on anyways, so just fade it off.
				if params.duration > 0.3 then
					self:GetChild("Flash"):accelerate(0.15):diffuse(cueColor):sleep(params.duration - 2*0.15):accelerate(0.15):diffuse(0,0,0,0)
				else
					self:GetChild("Flash"):accelerate(0.15):diffuse(0,0,0,0)
				end
				
				-- Long cues should display a countdown timer
				if params.duration > 3 then
					local bps = SCREENMAN:GetTopScreen():GetTrueBPS(player)
					breakLeft[ColumnIndex] = params.duration * bps
					self:GetChild("Timer"):playcommand("Break")
				end
			end,
			
			-- Animation quad for this column
			Def.Quad{
				Name="Flash",
			},
			
			-- Countdown timer for longer cues
			Def.BitmapText{
				Name="Timer",
				Font="_Combo Fonts/" .. mods.ComboFont .. "/",
				InitCommand=function(self)
					self:y(80 - (reversed * 110)):zoom(0.5)
				end,
				-- This is ran over and over to update the text for this break until there is no more break left
				BreakCommand=function(self)
					if breakLeft[ColumnIndex] < 1 then self:settext("") return end
					
					local bps = SCREENMAN:GetTopScreen():GetTrueBPS(player)
					self:settext(math.ceil((breakLeft[ColumnIndex] - 1) / 4)):sleep(1 / bps):queuecommand("Break")
					breakLeft[ColumnIndex] = breakLeft[ColumnIndex] - 1
				end,
			}
		}
	end

	return af

end