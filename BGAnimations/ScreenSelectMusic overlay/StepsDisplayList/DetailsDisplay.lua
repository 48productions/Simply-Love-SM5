local player = ...
local textZoom = 0.75
local text_table, marquee_index

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
			score = string.format("%.2f%%", 0)
			name = "????"
		end
	end

	return score, name
    --return '100.00%', 'WWWW' -- Positioning test
end

local PaneItems = {}

PaneItems[THEME:GetString("RadarCategory","Taps")] = {
	-- "rc" is RadarCategory
	rc = 'RadarCategory_TapsAndHolds',
    data = {
		x = -10,
		y = 22
	}
}

PaneItems[THEME:GetString("RadarCategory","Jumps")] = {
	rc = 'RadarCategory_Jumps',
	data = {
		x = 40,
		y = 22
	}
}

PaneItems[THEME:GetString("RadarCategory","Holds")] = {
	rc = 'RadarCategory_Holds',
	data = {
		x = 90,
		y = 22,
	}
}


local af = Def.ActorFrame{
    InitCommand=function(self)
        self:xy(player == PLAYER_1 and -80 or 80, _screen.cy+122):visible(GAMESTATE:IsHumanPlayer(player))
    end,
    SetCommand=function(self)
		local machine_score, machine_name = GetNameAndScore( PROFILEMAN:GetMachineProfile() )

		self:GetChild("MachineHighScore"):settext(machine_score)
		self:GetChild("MachineHighScoreName"):settext(machine_name):diffuse({0,0,0,1})

		DiffuseEmojis(self, machine_name)

		if PROFILEMAN:IsPersistentProfile(player) then
			local player_score, player_name = GetNameAndScore( PROFILEMAN:GetProfile(player) )

			self:GetChild("PlayerHighScore"):settext(player_score)
			self:GetChild("PlayerHighScoreName"):settext(player_name):diffuse({0,0,0,1})

			DiffuseEmojis(self, player_name)
		end
	end,
    PlayerJoinedMessageCommand=function(self, params)
        if player==params.Player then
            self:GetChild("PlayerHighScoreLabel"):visible(PROFILEMAN:IsPersistentProfile(player))
            self:visible(true):playcommand("Set")
        end
    end,
    PlayerUnjoinedMessageCommand=function(self, params)
        if player==params.Player then
            self:visible(false)
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
					self:settext("")
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
	LoadFont("Common Normal")..{
		OnCommand=function(self) self:xy(-76, 8):zoom(textZoom):diffuse(color_slate2):horizalign(left):settext(Screen.String("HighScores")):maxwidth(50) end
	},


    --"Personal" label
	LoadFont("Common Normal")..{
        Name="PlayerHighScoreLabel",
		OnCommand=function(self) self:xy(-19, 2):zoom(textZoom * 0.7):diffuse(color_slate2):horizalign(left):settext(Screen.String("HighScorePersonal")):visible(PROFILEMAN:IsPersistentProfile(player)) end
	},
    --PLAYER PROFILE high score
    LoadFont("Common Normal")..{
        Name="PlayerHighScore",
        InitCommand=function(self) self:xy(-8, 11):zoom(textZoom * 0.8):diffuse(Color.Black):horizalign(right):maxwidth(45) end
    },

    --PLAYER PROFILE highscore name
    LoadFont("Common Normal")..{
        Name="PlayerHighScoreName",
        InitCommand=function(self) self:xy(-6, 11):zoom(textZoom * 0.8):diffuse(Color.Black):horizalign(left):maxwidth(40) end
    },
    
    
        
    --"Machine" label
	LoadFont("Common Normal")..{
		OnCommand=function(self) self:xy(38, 2):zoom(textZoom * 0.7):diffuse(color_slate2):horizalign(left):settext(Screen.String("HighScoreMachine")) end
	},
    --MACHINE high score
    LoadFont("Common Normal")..{
        Name="MachineHighScore",
        InitCommand=function(self) self:xy(48, 11):zoom(textZoom * 0.8):diffuse(Color.Black):horizalign(right):maxwidth(45) end
    },
    --MACHINE highscore name
    LoadFont("Common Normal")..{
        Name="MachineHighScoreName",
        InitCommand=function(self) self:xy(50, 11):zoom(textZoom * 0.8):diffuse(Color.Black):horizalign(left):maxwidth(40) end
    },
    
    
    -- Foreground quad (dim box when difficulty is chosen)
    Def.Quad{
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
    },
    -- Ready icon (when player has chosen difficulty)
    Def.Sprite{
        Texture=THEME:GetPathG("", "Checkmark (doubleres).png"),
        InitCommand=function(self) self:zoom(0.8):diffusealpha(0):rotationz(-50):y(8) end,
        StepsChosenMessageCommand=function(self, args) if args.Player == player then self:finishtweening():decelerate(0.3):rotationz(0):diffusealpha(1) end end,
        StepsUnchosenMessageCommand=function(self, args) if args.Player == player then self:finishtweening():decelerate(0.15):rotationz(-50):diffusealpha(0) end end,
        SongUnchosenMessageCommand=function(self) self:finishtweening():decelerate(0.15):rotationz(-50):diffusealpha(0) end
    }
}


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
			InitCommand=function(self) self:zoom(textZoom * 0.8):xy(item.data.x, item.data.y):diffuse(Color.Black) end,
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


return af