local args = ...
local row = args[1]
local col = args[2]
local y_offset = args[3]

-- Max thresholds to consider "Easy" vs "Medium" vs "Hard" songs
local difficultyMax = ThemePrefs.Get("CasualMaxMeter")
local difficultyHard = difficultyMax * 0.66
local difficultyMedium = difficultyMax * 0.33

local song_bg_color = {0.18,0.18,0.18,1}
local transparent_color

local af = Def.ActorFrame{
	Name="SongWheelShared",
	InitCommand=function(self) self:y(y_offset) end,
    OffCommand=function(self) self:smooth(0.5):diffusealpha(0) end,
}

-----------------------------------------------------------------
-- black background quad
af[#af+1] = Def.Quad{
	Name="SongWheelBackground",
	InitCommand=function(self) self:zoomto(_screen.w, _screen.h/(row.how_many-2)):diffuse(0,0,0,0.75):cropbottom(1) end,
	OnCommand=function(self)
		self:xy(_screen.cx, math.ceil((row.how_many-2)/2) * row.h + 10):finishtweening()
		    :smooth(0.2):cropbottom(0)
	end,
	SwitchFocusToGroupsMessageCommand=function(self) self:smooth(0.3):cropright(1) end,
	SwitchFocusToSongsMessageCommand=function(self) self:smooth(0.3):cropright(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:smooth(0.3):cropright(1) end
}

-- song background sprite
af[#af+1] = Def.Sprite{
	Name="SongWheelBackground2",
	InitCommand=function(self) self:scaletoclipped(_screen.w, _screen.h/(row.how_many-2)):cropbottom(1) end,
	OnCommand=function(self)
		self:xy(_screen.cx, math.ceil((row.how_many-2)/2) * row.h + 10):finishtweening():diffuse(Color.Stealth)
		    :smooth(0.2):cropbottom(0):sleep(0.3):queuecommand("LoadBackground")
	end,
	CurrentSongChangedMessageCommand=function(self, params)
		self:stoptweening():smooth(0.2):diffuse(Color.Stealth)
		if params.song and params.song:HasBackground() then
			self:sleep(0.3):queuecommand("LoadBackground")
		end
	end,
	CloseThisFolderHasFocusMessageCommand=function(self) -- The above command doesn't run when we scroll over "Close This Folder"
		self:stoptweening():smooth(0.2):diffuse(Color.Stealth)
	end,
	LoadBackgroundCommand=function(self)
		self:smooth(0.2):diffuse(song_bg_color):LoadFromCurrentSongBackground()
	end,
	SwitchFocusToGroupsMessageCommand=function(self) self:smooth(0.3):cropright(1):diffuse(Color.Stealth) end,
	SwitchFocusToSongsMessageCommand=function(self) self:smooth(0.3):cropright(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:smooth(0.3):cropright(1):diffuse(Color.Stealth) end
}


-- glowing border top
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, 1):diffuse(1,1,1,0):xy(_screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2)*-0.5) end,
	OnCommand=function(self) self:sleep(0.3):diffusealpha(0.3) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:smooth(0.3):cropright(1):diffusealpha(0) end,
	SwitchFocusToSongsMessageCommand=function(self) self:smooth(0.3):cropright(0):diffusealpha(0.3) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:smooth(0.3):cropright(1):diffusealpha(0) end
}

-- glowing border bottom
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, 1):diffuse(1,1,1,0):xy(_screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2) * 0.5) end,
	OnCommand=function(self) self:sleep(0.3):diffusealpha(0.3) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:smooth(0.3):cropright(1):diffusealpha(0) end,
	SwitchFocusToSongsMessageCommand=function(self) self:smooth(0.3):cropright(0):diffusealpha(0.3) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:smooth(0.3):cropright(1):diffusealpha(0) end
}
-----------------------------------------------------------------
-- left/right UI arrows

af[#af+1] = Def.ActorFrame{
	Name="Arrows",
	InitCommand=function(self) self:diffusealpha(0):xy(_screen.cx, _screen.cy+30) end,
	OnCommand=function(self) self:sleep(0.1):linear(0.2):diffusealpha(1) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.2):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToSongsMessageCommand=function(self) self:sleep(0.2):linear(0.2):diffusealpha(1) end,

	-- right arrow
	Def.ActorFrame{
		Name="RightArrow",
		OnCommand=function(self) self:x(_screen.cx-50) end,
		PressCommand=function(self) self:decelerate(0.05):zoom(0.7):glow(color("#ffffff22")):accelerate(0.05):zoom(1):glow(color("#ffffff00")) end,

		LoadActor("./img/arrow_glow.png")..{
			Name="RightArrowGlow",
			InitCommand=function(self) self:zoom(0.25) end,
			OnCommand=function(self) self:diffuseshift():effectcolor1(1,1,1,0):effectcolor2(1,1,1,1):effectclock("beat") end
		},
		LoadActor("./img/arrow.png")..{
			Name="RightArrow",
			InitCommand=function(self) self:zoom(0.25):diffuse(Color.White) end,
		}
	},

	-- left arrow
	Def.ActorFrame{
		Name="LeftArrow",
		OnCommand=function(self) self:x(-_screen.cx+50) end,
		PressCommand=function(self) self:decelerate(0.05):zoom(0.7):glow(color("#ffffff22")):accelerate(0.05):zoom(1):glow(color("#ffffff00")) end,

		LoadActor("./img/arrow_glow.png")..{
			Name="LeftArrowGlow",
			InitCommand=function(self) self:zoom(0.25):rotationz(180) end,
			OnCommand=function(self) self:diffuseshift():effectcolor1(1,1,1,0):effectcolor2(1,1,1,1):effectclock("beat") end
		},
		LoadActor("./img/arrow.png")..{
			Name="LeftArrow",
			InitCommand=function(self) self:zoom(0.25):diffuse(Color.White):rotationz(180) end,

		}
	}
}
-----------------------------------------------------------------
-- text

af[#af+1] = Def.ActorFrame{
	Name="CurrentSongInfoAF",
	InitCommand=function(self) self:y( row.h * 2 + 10 ):x( col.w * (6 - 2.25) + 80):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.15):linear(0.15):diffusealpha(1) if AllowThonk() then self:bounce():effectclock("bgm"):effectmagnitude(0,-10,0) end end,

	SwitchFocusToGroupsMessageCommand=function(self)
		self:visible(false):runcommandsonleaves(function(leaf) if leaf.settext then leaf:settext("") end end)
	end,
	CloseThisFolderHasFocusMessageCommand=function(self)
		self:runcommandsonleaves(function(leaf) if leaf.settext then leaf:settext("") end end)
	end,
	SwitchFocusToSongsMessageCommand=function(self)
		self:visible(true):decelerate(0.3):zoom(1):y(row.h*2+10):x( col.w * (6 - 1.75) + 80)
		--self:runcommandsonleaves(function(leaf) leaf:diffuse(1,1,1,1) end)
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		self:decelerate(0.3):zoom(0.9):xy(col.w * (2.25)+WideScale(20,65), row.h+43)
		--self:runcommandsonleaves(function(leaf) leaf:diffuse(1,1,1,1) end)
	end,

	-- main title
	Def.BitmapText{
		Font="Common Normal",
		Name="Title",
		InitCommand=function(self) self:zoom(1.3):diffuse(Color.White):horizalign(left):y(-45):maxwidth(220):shadowlength(1) end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				self:settext( params.song:GetDisplayMainTitle() .. " " .. params.song:GetDisplaySubTitle())
			end
		end,
	},

	-- artist
	Def.BitmapText{
		Font="Common Normal",
		Name="Artist",
		InitCommand=function(self) self:zoom(0.85):diffuse(0.8,0.8,0.8,1):y(-20):horizalign(left):maxwidth(270):shadowlength(1) end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				self:settext( params.song:GetDisplayArtist() )
			end
		end,
	},

	-- difficulty
	Def.BitmapText{
		Font="Common Normal",
		Name="Difficulty",
		InitCommand=function(self)
			self:zoom(0.95):diffuse(Color.White):y(44):horizalign(left):maxwidth(400):shadowlength(1)
		end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				-- Get the easiest steps and display them along with BPM, length, etc
				-- Show a name next to the difficulty based SOLELY on the meter, and NOT the actual difficulty name
				-- (to prevent situations like a boss song having a novice 10 as their easiest difficulty and still showing novice...)
				-- todo: This blatantly assumes the easiest steps will be the first ones. This probably isn't a wise assumption...
				local easiestMeter = SongUtil.GetPlayableSteps(params.song)[1]:GetMeter()
				local difficultyText
				if easiestMeter >= difficultyHard then
					difficultyText = THEME:GetString("ScreenSelectMusic", "HardMeter")
					self:diffuse(DifficultyNameColor("Difficulty_Hard"))
				elseif easiestMeter >= difficultyMedium then
					difficultyText = THEME:GetString("ScreenSelectMusic", "MediumMeter")
					self:diffuse(DifficultyNameColor("Difficulty_Medium"))
				else
					difficultyText = THEME:GetString("ScreenSelectMusic", "EasyMeter")
					self:diffuse(DifficultyNameColor("Difficulty_Beginner"))
				end
				self:settext( difficultyText .. " " .. easiestMeter )
			end
		end,
		SwitchFocusToSongsMessageCommand=function(self) self:smooth(0.3):diffusealpha(1) end, -- Hide this difficulty text after selecting the song, we only want people reading the difficulty selection text once it shows
		SwitchFocusToSingleSongMessageCommand=function(self) self:smooth(0.3):diffusealpha(0) end
	}
}


return af