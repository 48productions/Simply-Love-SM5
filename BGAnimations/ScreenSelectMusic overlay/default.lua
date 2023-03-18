local t = Def.ActorFrame{
	InitCommand=function(self) SL.Global.GameplayReloadCheck = false end,
	ChangeStepsMessageCommand=function(self, params)
		self:playcommand("StepsHaveChanged", params)
	end,

	-- ---------------------------------------------------
	--  first, load files that contain no visual elements, just code that needs to run

	-- MenuButton code for backing out of SelectMusic when in EventMode
	LoadActor("./EscapeFromEventMode.lua"),
	-- MenuTimer code for preserving SSM's timer value
	LoadActor("./MenuTimer.lua"),
	-- Apply player modifiers from profile
	LoadActor("./PlayerModifiers.lua"),

	-- ---------------------------------------------------
	-- next, load visual elements; the order of the layers matters for most of these

	-- make the MusicWheel appear to cascade down; this should draw underneath P2's PaneDisplay
	LoadActor("./MusicWheelAnimation.lua"),

        
    -- Background quad to dim the screen when picking a difficulty
    Def.Quad{
        InitCommand=function(self) self:FullScreen():diffuse(color_black):diffusealpha(0) if AllowThonk() then self:rainbow():effectperiod(20) end end,
        SongChosenMessageCommand=function(self) self:finishtweening():decelerate(0.5):diffusealpha(0.5) end,
        SongUnchosenMessageCommand=function(self) self:finishtweening():decelerate(0.4):diffusealpha(0) end,
        OffCommand=function(self) self:finishtweening():decelerate(0.5):diffusealpha(1) end,
    },

    -- Organization for all elements we need to zoom in for two part difficulty select, for convenience
    Def.ActorFrame{
        InitCommand=function(self) self:x(_screen.cx - (IsUsingWideScreen() and 170 or 166)) if AllowThonk() then self:thump():effectmagnitude(1,1.01,0):effectclock("beat"):effectperiod(1) end end,
        SongChosenMessageCommand=function(self) self:stoptweening():decelerate(0.3):x(_screen.cx):smooth(0.3):zoom(1.2):y(-20) end,
        SongUnchosenMessageCommand=function(self) self:stoptweening():decelerate(0.4):zoom(1):xy(_screen.cx - (IsUsingWideScreen() and 170 or 166), 0) end,
        
		-- Another two-part difficulty animation grouping
        Def.ActorFrame{
            SongChosenMessageCommand=function(self) self:stoptweening():sleep(0.3):smooth(0.3):y(-20) end,
            SongUnchosenMessageCommand=function(self) self:stoptweening():decelerate(0.4):y(20) end,
            OffCommand=function(self) self:stoptweening():decelerate(0.3):diffusealpha(0):addy(50) end,
            -- elements we need two of (one for each player) that draw underneath the StepsDisplayList
            -- this includes the stepartist boxes and the PaneDisplays (number of steps, jumps, holds, etc.)
            --LoadActor("./PerPlayer/Under.lua"), (removed/consolidated to other files, lmao - 48)
            -- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
            LoadActor("./StepsDisplayList/default.lua"),
            -- elements we need two of that draw over the StepsDisplayList (just the bouncing cursors, really)
            LoadActor("./PerPlayer/Over.lua"),
            -- Song Artist, BPM, Duration (Referred to in other themes as "PaneDisplay")
            --LoadActor("./SongDescription.lua"),
        },
        
        -- Graphical Banner
        LoadActor("./Banner.lua"),
        -- CD Title (separate from banner so it doesn't get zoomed)
        LoadActor("./CDTitle.lua"),
    },
    	
    -- A "Hey you're currently playing a modfile" warning box
    LoadActor("./ModfileWarning.lua"),
    
    -- A display of the current sort mode
    LoadActor("./SortDisplay.lua"),

	-- ---------------------------------------------------
	-- finally, load the overlay used for sorting the MusicWheel (and more), hidden by default
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can (maybe) be accessed from the SortMenu
	LoadActor("./TestInput.lua"),
    
}

return t