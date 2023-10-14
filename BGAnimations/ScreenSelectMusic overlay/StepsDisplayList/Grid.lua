local num_rows    = 5
local num_columns = 20 -- Current number of columns (changes based on the current song's rating scale)
local num_columns_max = 20 -- Max number of columns (used for DDR X scale)
local GridZoomX = IsUsingWideScreen() and 0.4 or 0.31
local BlockZoomY = 0.275
local StepsToDisplay, SongOrCourse, StepsOrTrails

local GetStepsToDisplay = LoadActor("./StepsToDisplay.lua")

local t = Def.ActorFrame{
	Name="StepsDisplayList",
	InitCommand=function(self) self:vertalign(top):y(_screen.cy + 50):sleep(0.06):decelerate(0.25) end,
	-- - - - - - - - - - - - - -

	OnCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("UpdateRatingScale"):queuecommand("RedrawStepsDisplay") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,
	StepsHaveChangedCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,
    
    UpdateRatingScaleCommand=function(self)
        local song = GAMESTATE:GetCurrentSong()
        if song then
            local ratingType = group_rating_types[song:GetGroupName()]
            if ratingType == 1 then num_columns = num_columns_max return -- DDR Scale
            elseif ratingType == 2 then num_columns = 15 return -- ITG Scale
            elseif ratingType == 3 then num_columns = 12 return end -- Mods scale
        end
        
        num_columns = num_columns_max -- No rating scale specified or no song selected, use X scale
    end,
    
	-- - - - - - - - - - - - - -

	RedrawStepsDisplayCommand=function(self)

		SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()

		if SongOrCourse then
			StepsOrTrails = (GAMESTATE:IsCourseMode() and SongOrCourse:GetAllTrails()) or SongUtil.GetPlayableSteps( SongOrCourse )

			if StepsOrTrails then

				StepsAndIndexSplit = GetStepsToDisplay(StepsOrTrails)
				StepsToDisplay = StepsAndIndexSplit[1]
				ChartIndexSplit = StepsAndIndexSplit[2]

				-- Set the difficulty meter and blocks
				for RowNumber=1,num_rows do
					if StepsToDisplay[RowNumber] then
						-- if this particular song has a stepchart for this row, update the Meter
						-- and BlockRow coloring appropriately
						local meter = StepsToDisplay[RowNumber]:GetMeter()
						local difficulty = StepsToDisplay[RowNumber]:GetDifficulty()
						self:GetChild("Grid"):GetChild("Meter_"..RowNumber):playcommand("Set", {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Blocks_"..RowNumber):playcommand("Set", {Meter=meter, Difficulty=difficulty})
					else
						-- otherwise, set the meter to an empty string and hide this particular colored BlockRow
						self:GetChild("Grid"):GetChild("Meter_"..RowNumber):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Blocks_"..RowNumber):playcommand("Unset")

					end
				end

        -- Set the chart list split actors
        for i=1,3 do
          self:GetChild("Grid"):GetChild("Split_"..i):visible(ChartIndexSplit[i])
        end
			end
		else
			StepsOrTrails, StepsToDisplay = nil, nil
			self:playcommand("Unset")
		end
	end,

	-- - - - - - - - - - - - - -

	-- background
	Def.Quad{
		Name="Background",
		InitCommand=function(self)
			self:diffuse(color_slate2):zoomto(320, 96):diffusealpha(0.85)
		end
	},
}


local Grid = Def.ActorFrame{
	Name="Grid",
	InitCommand=function(self) self:horizalign(left):vertalign(top):xy(18, -52 ) end,
}


-- A grid of decorative faux-blocks that will exist
-- behind the changing difficulty blocks.
Grid[#Grid+1] = Def.Sprite{
	Name="BackgroundBlocks",
	Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/StepsDisplayList/_block.png"),

	InitCommand=function(self) self:diffuse(color("#182025")) end,
    UpdateRatingScaleCommand = function(self)
        local width = self:GetWidth()
		local height= self:GetHeight()
		self:zoomto(width * num_columns_max * GridZoomX, height * num_rows * BlockZoomY)
		self:y( 3 * height * BlockZoomY )
		self:customtexturerect(0, 0, num_columns, num_rows)
		
		if GAMESTATE:GetCurrentSong() then -- If we've scrolled over a song, show the grid. Otherwise, hide it to make room for the pack description
			self:finishtweening():smooth(0.1):diffusealpha(1)
		else
			self:finishtweening():smooth(0.1):diffusealpha(0)
		end
    end
}

for RowNumber=1,num_rows do

    -- The grid blocks themselves
	Grid[#Grid+1] =	Def.Sprite{
		Name="Blocks_"..RowNumber,
		Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/StepsDisplayList/_block.png"),

		InitCommand=function(self) self:diffusealpha(0) if AllowThonk() then self:bob():effectmagnitude(0,1,0):effectclock("beat"):effectoffset(0.1 * RowNumber) end end,
		OnCommand=function(self)
			local width = self:GetWidth()
			local height= self:GetHeight()
			self:y( RowNumber * height * BlockZoomY)
			self:zoomto(width * num_columns * GridZoomX, height * BlockZoomY)
		end,
		SetCommand=function(self, params)
			-- the engine's Steps::TidyUpData() method ensures that difficulty meters are positive
			-- (and does not seem to enforce any upper bound that I can see)
			self:customtexturerect(0, 0, num_columns, 1)
			self:stoptweening():smooth(0.1):cropright( 1 - (params.Meter * (1/num_columns)) )
			self:diffuse( DifficultyColor(params.Difficulty) )
		end,
		UnsetCommand=function(self)
			self:stoptweening():smooth(0.1):cropright(1):diffusealpha(0)
		end
	}

    -- The difficulty meter number
	Grid[#Grid+1] = LoadFont("_wendy small")..{
		Name="Meter_"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(right)
			self:y(RowNumber * height * BlockZoomY)
			self:x( IsUsingWideScreen() and -130 or -116 )
			self:zoom(0.3)
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:stoptweening():smooth(0.1):diffuse( DifficultyColor(params.Difficulty) )
			self:settext(params.Meter)
		end,
		UnsetCommand=function(self) self:stoptweening():smooth(0.1):diffusealpha(0) end,
	}
end

-- Chart list splits (there's more than 5 charts and we're hiding some)
for i=1,3 do
	Grid[#Grid+1]=Def.Quad{
		Name="Split_"..i,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..1):GetHeight()
			local width = self:GetParent():GetChild("Blocks_"..1):GetWidth()
			self:visible(false):zoomto(286, height * 0.4):x(-2):diffuse(0,0,0,1)
			if i == 1 then -- Split at top of list
				self:y(height * BlockZoomY * 0.3):croptop(0.57):fadebottom(0.5)
			elseif i == 2 then -- Split in middle
				self:y(height * BlockZoomY * 3.5):fadetop(0.5):fadebottom(0.5)
			else -- Split at bottom
				self:y(height * BlockZoomY * 5.5):fadetop(0.57):cropbottom(0.5)
			end
		end,
	}
end

t[#t+1] = Grid

-- Rating scale info side panel
t[#t+1] = Def.ActorFrame{
    InitCommand=function(self)
        self:x(-150)
    end,
    
	-- Rating scale text background
	--[[Def.Quad{
		InitCommand=function(self)
			self:diffuse(color_slate):diffusealpha(0.7):zoomto(20, 96):x(0)
		end,
	},]]
	
    -- Rating scale text
    LoadFont("_wendy small")..{
        InitCommand=function(self)
            self:zoom(0.2):baserotationz(-90):diffusealpha(0.6)
            self:settext("DDR Difficulty")
        end,
        UpdateRatingScaleCommand=function(self)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                self:stoptweening():smooth(0.1):diffuse(getSongTitleColor(song:GetGroupName())):diffusealpha(0.6)
            
                local ratingType = group_rating_types[song:GetGroupName()]
                if ratingType == 1 then self:settext(THEME:GetString("ScreenSelectMusic", "ScaleDDR")) return
                elseif ratingType == 2 then self:settext(THEME:GetString("ScreenSelectMusic", "ScaleITG")) return
                elseif ratingType == 3 then self:settext(THEME:GetString("ScreenSelectMusic", "ScaleMods")) return
				else self:settext(THEME:GetString("ScreenSelectMusic", "ScaleNone")) end -- No rating info
            else -- No song selected
				self:stoptweening():smooth(0.1):diffusealpha(0)
			end
        end,
    },
}

-- Grid outline
t[#t+1] = Def.ActorFrame{
	Def.Quad{ -- Top
		InitCommand=function(self)
			self:diffuse(0.1,0.1,0.1,0.7):zoomto(320, 4):y(-46)
		end,
	},
	Def.Quad{ -- Bottom
		InitCommand=function(self)
			self:diffuse(0.1,0.1,0.1,0.7):zoomto(320, 4):y(46)
		end,
	}
}

-- "Has Edit" Marker (next to steps list)
-- This is hidden by the new step info pane and I'm not sure where to move it
-- With the new chart split shadows, do we even need it any more? - 48
--t[#t+1] = LoadActor( THEME:GetPathG("", "Has Edit (doubleres).png") )..{
--[[t[#t+1] = LoadActor("./editbubble (doubleres).png")..{
	InitCommand=function(self)
		self:visible(false):xy(-130, 60):zoom(0.375):bounce():effectclock("beatnooffset"):effectmagnitude(0, 1.5, 0):effectperiod(2):effectoffset( -10 * PREFSMAN:GetPreference("GlobalOffsetSeconds"))
		if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,1) end
	end,
	CurrentSongChangedMessageCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		local stepstype = "StepsType_" .. GAMESTATE:GetCurrentGame():GetName():gsub("^%l", string.upper) .. "_" .. GAMESTATE:GetCurrentStyle():GetName():gsub("^%l", string.upper):gsub("Versus", "Single")
		self:visible(song and song:HasEdits(stepstype) or false)
	end
}]]

return t
