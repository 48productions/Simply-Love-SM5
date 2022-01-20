-- before loading actors, pre-calculate each group's overall duration by
-- looping through its songs and summing their duration
-- store each group's overall duration in a lookup table, keyed by group_name
-- to be retrieved + displayed when actively hovering on a group (not a song)
--
-- I haven't checked, but I assume that continually recalculating group durations could
-- have performance ramifications when rapidly scrolling through the MusicWheel
--
-- a consequence of pre-calculating and storing the group_durations like this is that
-- live-reloading a song on ScreenSelectMusic via Control R might cause the group duration
-- to then be inaccurate, until the screen is reloaded.

local group_durations = {}
local stages_remaining = GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber())

for _,group_name in ipairs(SONGMAN:GetSongGroupNames()) do
	group_durations[group_name] = 0

	for _,song in ipairs(SONGMAN:GetSongsInGroup(group_name)) do
		local song_cost = song:IsMarathon() and 3 or song:IsLong() and 2 or 1

		if song_cost <= stages_remaining then
			group_durations[group_name] = group_durations[group_name] + song:MusicLengthSeconds()
		end
	end
end

-- ----------------------------------------

-- Preload the info.ini data for each group.
-- Doing this every time the MusicWheel scrolls by a group would surely be bad for performance.

local group_descriptions = {}
local group_ratings = {}
for _,group in ipairs(SONGMAN:GetSongGroupNames()) do
	local desc = 0
	local rates = 0
	local file = nil
	
	-- open info.ini if it exists
	if FILEMAN:DoesFileExist("./Songs/"..group.."/info.ini") then
		file = IniFile.ReadFile("./Songs/"..group.."/info.ini")
	-- check AdditionalSongs, too (this was easier than i thought it would be)
	elseif FILEMAN:DoesFileExist("./AdditionalSongs/"..group.."/info.ini") then
		file = IniFile.ReadFile("./AdditionalSongs/"..group.."/info.ini")
	end
	-- read info.ini if it loaded
	if file then
		if file.GroupInfo then
			if file.GroupInfo.Description then
				desc = file.GroupInfo.Description
			end
			if file.GroupInfo.Ratings then
				rates = file.GroupInfo.Ratings
			end
		end
	end
	-- copy to the arrays, leaving a 0 in place of nil or empty strings
	group_descriptions[group] = desc ~= "" and desc or 0
	group_ratings[group] = rates ~= "" and rates or 0
	
end

local t = Def.ActorFrame{

	OnCommand=function(self)
        self:y(_screen.cy - 28):sleep(0.03):decelerate(0.25)
	end,

	-- ----------------------------------------
	-- Actorframe for Artist, BPM, and Song length
	Def.ActorFrame{
		CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentTrailP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentTrailP2ChangedMessageCommand=function(self) self:playcommand("Set") end,

		-- background for Artist, BPM, and Song Length
		Def.Quad{
			InitCommand=function(self)
				self:diffuse(color_slate2)
					:zoomto( IsUsingWideScreen() and 320 or 310, 48 )

				--if ThemePrefs.Get("RainbowMode") then
					self:diffusealpha(0.85)
				--end
			end
		},

		Def.ActorFrame{

			InitCommand=function(self) self:x(-110) end,

			-- Artist Label
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					local text = GAMESTATE:IsCourseMode() and "NumSongs" or "Artist"
					self:settext( THEME:GetString("SongDescription", text) )
						:horizalign(right):y(-12)
						:maxwidth(44)
				end,
				OnCommand=function(self) self:diffuse(0.5,0.5,0.5,1) end,
				-- hide if folder has a description
				SetCommand=function(self)
					if not GAMESTATE:IsCourseMode() then
						local group_name = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection()
						if GAMESTATE:GetSortOrder() == "SortOrder_Group" and not GAMESTATE:GetCurrentSong() and group_descriptions[group_name] ~= 0 then
							self:diffusealpha(0)
						else
							self:diffusealpha(1)
						end
					end
				end
			},

			-- Song Artist
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(5,-12):maxwidth(WideScale(225,260)) end,
				SetCommand=function(self)
					if GAMESTATE:IsCourseMode() then
						local course = GAMESTATE:GetCurrentCourse()
						self:settext( course and #course:GetCourseEntries() or "" )
					else
						local song = GAMESTATE:GetCurrentSong()
						self:settext( song and song:GetDisplayArtist() or "" )
					end
				end
			},



			-- BPM Label
			LoadFont("Common Normal")..{
				Text=THEME:GetString("SongDescription", "BPM"),
				InitCommand=function(self)
					self:horizalign(right):y(8)
						:diffuse(0.5,0.5,0.5,1)
				end,
				-- hide if folder has rating info
				SetCommand=function(self)
					if not GAMESTATE:IsCourseMode() then
						local group_name = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection()
						if GAMESTATE:GetSortOrder() == "SortOrder_Group" and not GAMESTATE:GetCurrentSong() and group_ratings[group_name] ~= 0 then
							self:diffusealpha(0)
						else
							self:diffusealpha(1)
						end
					end
				end
			},

			-- BPM value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(5,8):diffuse(1,1,1,1) end,
				SetCommand=function(self)
					--defined in ./Scipts/SL-BPMDisplayHelpers.lua
					local text = GetDisplayBPMs()
					self:settext(text or "")
				end
			},

			-- Song Duration Label
			LoadFont("Common Normal")..{
				Text=THEME:GetString("SongDescription", "Length"),
				InitCommand=function(self)
					self:horizalign(right)
						:xy(190, 8)
						:diffuse(0.5,0.5,0.5,1)
				end
			},

			-- Song Duration Value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(195, 8) end,
				SetCommand=function(self)
					local duration

					if GAMESTATE:IsCourseMode() then
						local Players = GAMESTATE:GetHumanPlayers()
						local player = Players[1]
						local trail = GAMESTATE:GetCurrentTrail(player)

						if trail then
							duration = TrailUtil.GetTotalSeconds(trail)
						end
					else
						local song = GAMESTATE:GetCurrentSong()
						if song then
							duration = song:MusicLengthSeconds()
						else
							local group_name = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection()
							if group_name then
								duration = group_durations[group_name]
							end
						end
					end


					if duration then
						duration = duration / SL.Global.ActiveModifiers.MusicRate
						if duration == 105.0 then
							-- r21 lol
							self:settext( THEME:GetString("SongDescription", "r21") )
						else
							local hours = 0
							if duration > 3600 then
								hours = math.floor(duration / 3600)
								duration = duration % 3600
							end

							local finalText
							if hours > 0 then
								-- where's HMMSS when you need it?
								finalText = hours .. ":" .. SecondsToMMSS(duration)
							else
								finalText = SecondsToMSS(duration)
							end

							self:settext( finalText )
						end
					else
						self:settext("")
					end
				end
			}
		},
		
		-- folder info
		LoadFont("Common Normal")..{
			InitCommand=function(self) self:horizalign(left):xy(-150,-12):maxwidth(WideScale(275,310)) end,
			SetCommand=function(self)
				if not GAMESTATE:IsCourseMode() then
					if GAMESTATE:GetSortOrder() == "SortOrder_Group" and not GAMESTATE:GetCurrentSong() then
						local group_name = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection()
						self:diffusealpha(1)
                        
                        --For some reason, SONGMAN:GetSongGroupNames() doesn't return USB custom song groups (from when group descriptions are pre-loaded, above), and MusicWheel:GetCurrentSections() doesn't seem to work either,
                        --so let's detect custom groups when scrolling through the music wheel instead:
                        --If we've scrolled onto a USB custom group, detect it here and set the group description accordingly. Not ideal but it works - 48
						if SONGMAN:GetSongsInGroup(group_name)[1]:IsCustomSong() then
                            self:settext(group_name .. THEME:GetString("ScreenSelectMusic", "USBGroupDesc"))
                            
                        else --Otherwise, set the group description to what we've loaded, or blank if there is no description
                            self:settext(group_descriptions[group_name] ~= 0 and group_descriptions[group_name] or "")
                         end
					else
						self:diffusealpha(0)
					end
				end
			end
		},
		
		-- folder rating info
		LoadFont("Common Normal")..{
			InitCommand=function(self) self:horizalign(left):xy(-150,8) end,
			SetCommand=function(self)
				if not GAMESTATE:IsCourseMode() then
					if GAMESTATE:GetSortOrder() == "SortOrder_Group" and not GAMESTATE:GetCurrentSong() then
						local group_name = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection()
						self:diffusealpha(1)
						if group_ratings[group_name] and group_ratings[group_name] ~= 0 then
							self:settext(THEME:GetString("SongDescription", "GroupRatings") .. group_ratings[group_name])
                        else
                            self:settext("")
						end
					else
						self:diffusealpha(0)
					end
				end
			end
		},

		-- long/marathon version bubble graphic and text
		Def.ActorFrame{
			OnCommand=function(self)
				self:x( IsUsingWideScreen() and 102 or 97 )
			end,
			SetCommand=function(self)
				local song = GAMESTATE:GetCurrentSong()
				self:visible( song and (song:IsLong() or song:IsMarathon()) or false )
			end,

			LoadActor("bubble")..{
				InitCommand=function(self) self:diffuse(GetCurrentColor()):zoom(0.455):y(29) end
			},

			LoadFont("Common Normal")..{
				InitCommand=function(self) self:diffuse(Color.Black):zoom(0.8):y(34) end,
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()
					if not song then self:settext(""); return end

					if song:IsMarathon() then
						self:settext(THEME:GetString("SongDescription", "IsMarathon"))
					elseif song:IsLong() then
						self:settext(THEME:GetString("SongDescription", "IsLong"))
					else
						self:settext("")
					end
				end
			}
		},
        
        Def.ActorFrame{
            InitCommand=function(self) self:diffusealpha(0.2):zoomy(0) end,
            SongChosenMessageCommand=function(self) self:decelerate(0.5):diffusealpha(1):zoomy(1):sleep(3):decelerate(0.5):zoomy(0) end,
            SongUnchosenMessageCommand=function(self) self:finishtweening():decelerate(0.5):diffusealpha(0):zoomy(0) end,
            Def.Quad{
                InitCommand=function(self)
                    self:zoomto( IsUsingWideScreen() and 318 or 308, 46 )
                end
            },
            Def.Quad{
                InitCommand=function(self)
                    self:diffuse(color_slate2):zoomto( IsUsingWideScreen() and 316 or 306, 44 )
                end
            },
            Def.BitmapText {
                Font="_upheaval 80px",
                Text=ScreenString("SelectDifficulty"),
                InitCommand=function(self) self:zoomy(0.35):zoomx(0.3):y(-4) end,
                SongChosenMessageCommand=function(self) self:finishtweening():linear(4):zoomx(0.35):shadowlength(3) end,
                SongUnchosenMessageCommand=function(self) self:smooth(1):zoomx(0.3):shadowlength(0) end,
            },
        },
	}
}

return t
