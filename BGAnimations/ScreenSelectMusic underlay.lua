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
reloadGroupInfo() -- Group info parsing moved to SL-SelectMusicHelpers.lua - 48

local t = Def.ActorFrame{
    InitCommand=function(self) self:xy(_screen.w*1.5, _screen.cy + 16) end,
	OnCommand=function(self)
        self:sleep(0.5):decelerate(0.5):x(_screen.cx+_screen.w/4+14)
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
					:zoomto(_screen.w/2.1675, 32 )
                    :x(0)

				--if ThemePrefs.Get("RainbowMode") then
				--end
			end,
            OffCommand=function(self)
                self:linear(0.2):diffusealpha(0) -- Match the animation for the musicwheel in metrics
            end,
            SetCommand=function(self)
                if not GAMESTATE:GetCurrentSong() then
                    self:diffuse(color_slate)
                else
                    self:diffuse(color_slate4)
                end
            end,
		},
        
        -- background quad to hide some of the wheel animation jank
        Def.Quad{
			InitCommand=function(self)
				self:diffuse(color_slate2)
					:zoomto(_screen.w/2.1675, 93 )
                    :x(2)
				--if ThemePrefs.Get("RainbowMode") then
				--end
			end,
            OffCommand=function(self)
                self:linear(0.2):diffusealpha(0) -- Match the animation for the musicwheel in metrics
            end,
            SetCommand=function(self)
                if not GAMESTATE:GetCurrentSong() then
                    self:diffuse(color_slate)
                else
                    self:diffuse(color_slate4)
                end
            end,
		},

		Def.ActorFrame{

			InitCommand=function(self) self:x(-135):zoom(0.75) end,

			-- Artist Label
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					local text = GAMESTATE:IsCourseMode() and "NumSongs" or "Artist"
					self:settext( THEME:GetString("SongDescription", text) )
						:horizalign(right)--:xy(-20, 0)
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
				InitCommand=function(self) self:horizalign(left):xy(4,0):maxwidth(WideScale(186,186)) end,
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
					self:horizalign(right):x(232)
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
				InitCommand=function(self) self:horizalign(left):xy(234, 0):diffuse(1,1,1,1) end,
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
						:xy(354, 0)
						:diffuse(0.5,0.5,0.5,1)
				end
			},

			-- Song Duration Value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(358, 0) end,
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
			},
            
            
            -- folder info
            LoadFont("Common Normal")..{
                InitCommand=function(self) self:horizalign(left):xy(-40,-8):maxwidth(WideScale(275,310)) end,
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
                InitCommand=function(self) self:horizalign(left):xy(-38,9):zoom(0.75):diffuse(0.75,0.75,0.75,1) end,
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
		},
	}
}

return t
