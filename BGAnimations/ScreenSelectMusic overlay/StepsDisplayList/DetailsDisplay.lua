local player = ...
local pn = ToEnumShortString(player)
local textZoom = 0.75
local text_table, marquee_index

-- Returns the name and score of the highest score a profile has on the current song/chart
local GetNameAndScore = function(profile)
	local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local score = ""
	local name = ""

	if profile and song and steps then
		local scorelist = profile:GetHighScoreList(song,steps)
		local scores = scorelist:GetHighScores()
		local topscore = scores[1]

		if topscore then
			score = string.format("%.2f%%", topscore:GetPercentDP()*100.0)
			name = topscore:GetName()
		else
			score = "??.??%"
			name = "----"
		end
	end

	return score, name
    --return '100.00%', 'WWWW' -- Test text for high score label positioning
end


-- Set up positioning for the detail labels
local PaneItems = {}

PaneItems[THEME:GetString("RadarCategory","Taps")] = {
	-- "rc" is RadarCategory
	rc = 'RadarCategory_TapsAndHolds',
    data = {
		x = 96,
		y = -2
	}
}

PaneItems[THEME:GetString("RadarCategory","Jumps")] = {
	rc = 'RadarCategory_Jumps',
	data = {
		x = 96,
		y = 12
	}
}

PaneItems[THEME:GetString("RadarCategory","Holds")] = {
	rc = 'RadarCategory_Holds',
	data = {
		x = 96,
		y = 26,
	}
}

local HighScoreItems = {}

HighScoreItems["PlayerHighScore"] = {
	labelx = -5,
	scorex = -6,
	y = -6,
}

HighScoreItems["MachineHighScore"] = {
	labelx = -5,
	scorex = -6,
	y = 16,
}

HighScoreItems["Rival1HighScore"] = {
	labelx = 51,
	scorex = 50,
	y = -6,
}

HighScoreItems["Rival2HighScore"] = {
	scorex = 50,
	y = 5,
}

HighScoreItems["Rival3HighScore"] = {
	scorex = 50,
	y = 16,
}


local af = Def.ActorFrame{
	Name="DetailsDisplay"..pn,
    InitCommand=function(self)
        self:xy(player == PLAYER_1 and -80 or 80, _screen.cy+122):visible(GAMESTATE:IsHumanPlayer(player))
    end,
	
    PlayerJoinedMessageCommand=function(self, params)
        if player==params.Player then
			local show_rivals = PROFILEMAN:IsPersistentProfile(player)
            self:GetChild("PlayerHighScore"):visible(show_rivals)
			self:GetChild("Rival1HighScore"):visible(show_rivals)
			self:GetChild("Rival2HighScore"):visible(show_rivals)
			self:GetChild("Rival3HighScore"):visible(show_rivals)
            self:visible(true):playcommand("Set")
        end
    end,
    PlayerUnjoinedMessageCommand=function(self, params)
        if player==params.Player then
            self:visible(false)
        end
    end,
    
	
	-- Current steps have changed - update the personal/machine high scores, clear the rival scores, and queue this chart to be parsed
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		local machine_score, machine_name = GetNameAndScore( PROFILEMAN:GetMachineProfile() )

		-- Update the machine high score
		-- The label text should be set to "Machine" here as well, since it might've gotten set by default.lua to display a world record instead
		local machine_score_af = self:GetChild("MachineHighScore")
		machine_score_af:GetChild("HighScore"):settext(machine_score)
		machine_score_af:GetChild("HighScoreName"):settext(machine_name):diffuse({0,0,0,1})
		machine_score_af:GetChild("HighScoreLabel"):settext(THEME:GetString("ScreenSelectMusic", "MachineHighScore"))

		DiffuseEmojis(self, machine_name)

		-- If the player has a profile, get their top score (if they have one)
		if PROFILEMAN:IsPersistentProfile(player) then
			local player_score, player_name = GetNameAndScore( PROFILEMAN:GetProfile(player) )

			local player_score_af = self:GetChild("PlayerHighScore")
			player_score_af:GetChild("HighScore"):settext(player_score)
			player_score_af:GetChild("HighScoreName"):settext(player_name):diffuse({0,0,0,1})

			DiffuseEmojis(self, player_name)
		end
		
		-- Blank the rival high scores until we load them in
		for i=1,3 do
			local score_af = self:GetChild("Rival"..i.."HighScore")
			score_af:GetChild("HighScore"):settext("??.??%")
			score_af:GetChild("HighScoreName"):settext("----"):diffuse({0,0,0,1})
		end
		--self:queuecommand("Hide")
		self:stoptweening()
		self:sleep(0.4) -- Wait a bit, then parse the current chart if we haven't immediately changed charts again
		self:queuecommand("ParseChart")
	end,
	
	ParseChartCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			MESSAGEMAN:Broadcast(pn.."ChartParsing")
			ParseChartInfo(steps, pn)
			self:queuecommand("ParsingDone")
		end
	end,
	ParsingDoneCommand=function(self)
		if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(player) then
			MESSAGEMAN:Broadcast(pn.."ChartParsed") -- Signal to the GS code in default.lua that we should fetch high scores from GrooveStats
		end
	end,
	
	
	
    -- Background Quad
    Def.Quad{
        Name="BackgroundQuad",
        InitCommand=function(self)
            self:zoomto(158, 62):y(8)
        end,
        SetCommand=function(self, params)
            if GAMESTATE:IsHumanPlayer(player) then
                local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
    
                if StepsOrTrail then
                    local difficulty = StepsOrTrail:GetDifficulty()
                    self:diffuse( DifficultyColor(difficulty) )
                else
                    self:diffuse( PlayerColor(player) )
                end
            end
        end
    },
    
    
    -- STEP ARTIST TEXT
    
    --"Steps by" label
	LoadFont("Common Normal")..{
		OnCommand=function(self) self:zoom(textZoom):diffuse(color_slate2):horizalign(left):xy(-76, -14):settext(Screen.String("STEPS")) end
	},

	--stepartist text
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(textZoom):diffuse(0,0,0,1):horizalign(left):xy(-36, -14):maxwidth(148) end,
		SetCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSteps(player)

			-- always stop tweening when steps change in case a MarqueeCommand is queued
			self:stoptweening()

			if SongOrCourse and StepsOrCourse then
				text_table = GetStepsCredit(player)
                --SM(player)
                --SM(text_table)
				marquee_index = 0

				-- only queue a marquee if there are things in the text_table to display
				if #text_table > 0 then
					self:queuecommand("Marquee")
				else
					-- no credit information was specified in the simfile for this stepchart, so just set to an empty string
					self:settext(THEME:GetString( "ScreenSelectMusic", "StepsUnknown" ))
				end
			else
				-- there wasn't a song/course or a steps object, so the MusicWheel is probably hovering
				-- on a group title, which means we want to set the stepartist text to an empty string for now
				self:settext("")
			end
		end,
		MarqueeCommand=function(self)
			-- increment the marquee_index, and keep it in bounds
			marquee_index = (marquee_index % #text_table) + 1
			-- retrieve the text we want to display
			local text = text_table[marquee_index]

			-- set this BitmapText actor to display that text
			self:settext( text )

			-- account for the possibility that emojis shouldn't be diffused to Color.Black
			DiffuseEmojis(self, text)

			-- sleep 2 seconds before queueing the next Marquee command to do this again
			if #text_table > 1 then
				self:sleep(2):queuecommand("Marquee")
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	},
    
    
    -- HIGH SCORES TEXT
    
    --"High Scores" label
	--[[LoadFont("Common Normal")..{
		OnCommand=function(self) self:xy(-76, 16):zoom(textZoom):diffuse(color_slate2):horizalign(left):settext(Screen.String("HighScores")):maxwidth(50) end
	},]]
}




-- Load all the pane items (step count, etc)
for key, item in pairs(PaneItems) do

	af[#af+1] = Def.ActorFrame{

		Name=key,
		OnCommand=function(self) self:xy(-_screen.w/20, 6) end,

		-- label
		--LoadFont("Common Normal")..{
--			Text=key,
			--InitCommand=function(self) self:zoom(textZoom * 0.8):xy(item.label.x, item.label.y):diffuse(Color.Black):horizalign(left) end
		--},
		--  numerical value
		LoadFont("Common Normal")..{
			InitCommand=function(self) self:zoom(textZoom * 0.8):xy(item.data.x, item.data.y):diffuse(Color.Black):maxwidth(60) end,
			OnCommand=function(self) self:playcommand("Set") end,
			SetCommand=function(self)
				local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
				if not SongOrCourse then self:settext("?"); return end

				local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
				if steps then
					rv = steps:GetRadarValues(player)
					local val = rv:GetValue( item.rc )

					-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
					self:settext( val >= 0 and val .. " " .. key or "?" )
				else
					self:settext( "" )
				end
			end
		}
	}
end

-- Next, all the high score labels
for key, item in pairs(HighScoreItems) do
	af[#af+1] = Def.ActorFrame{
		Name=key,
		OnCommand=function(self)
			self:xy(-_screen.w/20, 6)
			-- Machine high scores should ALWAYS be shown
			-- Personal high scores should only be shown if the player has a profile
			-- Rival high scores should only be shown if the player has a profile AND groovestats is connected
			if key == "MachineHighScore" then
			elseif key == "PersonalHighScore" then
				self:visible(PROFILEMAN:IsPersistentProfile(player))
			else
				self:visible(PROFILEMAN:IsPersistentProfile(player))
			end
		end,
		-- Label (Personal, Machine, etc)
		LoadFont("Common Normal")..{
			Condition=item.labelx ~= nil,
			Name="HighScoreLabel",
			OnCommand=function(self)
				self:xy(item.labelx, item.y):zoom(textZoom * 0.7):diffuse(color_slate2):horizalign(center)
				if key == "Rival1HighScore" then -- The Rival 1 label is our GrooveStats status display, we may need to show a message if GrooveStats won't work for this player
					if not SL.GrooveStats.IsConnected then -- Check if GS is not connected (probably disabled)
						self:settext(THEME:GetString("ScreenSelectMusic", "GSDisabled"))
					elseif SL[pn].ApiKey == "" then -- Check if the player doesn't have an API key (not configured for online)
						self:settext(THEME:GetString("ScreenSelectMusic", "GSNoAccount"))
					end
				else
					self:settext(Screen.String(key))
				end
			end
		},
		-- Score
		LoadFont("Common Normal")..{
			Name="HighScore",
			InitCommand=function(self) self:xy(item.scorex, item.y+10):zoom(textZoom * 0.8):diffuse(Color.Black):horizalign(right):maxwidth(45) end
		},
	
		-- Score name
		LoadFont("Common Normal")..{
			Name="HighScoreName",
			InitCommand=function(self) self:xy(item.scorex+2, item.y+10):zoom(textZoom * 0.8):diffuse(Color.Black):horizalign(left):maxwidth(40) end
		},
	}
end

    
-- Display foreground quad (dim box when difficulty is chosen)
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(158, 62):y(8):diffuse(0, 0, 0, 0)
	end,
	StepsChosenMessageCommand=function(self, args)
		if args.Player == player then
			self:smooth(0.3):diffusealpha(0.5)
		end
	end,
	StepsUnchosenMessageCommand=function(self, args)
		if args.Player == player then
			self:smooth(0.15):diffusealpha(0)
		end
	end,
	SongUnchosenMessageCommand=function(self)
		self:smooth(0.15):diffusealpha(0)
	end,
}

-- Ready icon (when player has chosen difficulty)
af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("", "Checkmark (doubleres).png"),
	InitCommand=function(self) self:zoom(0.8):diffusealpha(0):rotationz(-50):y(8) end,
	StepsChosenMessageCommand=function(self, args) if args.Player == player then self:finishtweening():decelerate(0.3):rotationz(0):diffusealpha(1) end end,
	StepsUnchosenMessageCommand=function(self, args) if args.Player == player then self:finishtweening():decelerate(0.15):rotationz(-50):diffusealpha(0) end end,
	SongUnchosenMessageCommand=function(self) self:finishtweening():decelerate(0.15):rotationz(-50):diffusealpha(0) end
}

return af