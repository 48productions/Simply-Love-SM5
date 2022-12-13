local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualTheme")
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")

local SongOrCourse, banner

local t = Def.ActorFrame{
    CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
    CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
	OnCommand=function(self)
        self:xy(-450, 112):zoom(0.7):sleep(0.75)
		if IsUsingWideScreen() then
			self:decelerate(0.5):zoom(0.7655):x(0)--:x(_screen.cx - 170)
		else
			self:decelerate(0.5):zoom(0.75):x(0)--:x(_screen.cx - 166)
		end
	end,
    OffCommand=function(self)
        self:decelerate(0.5):zoom(0.7)
         -- If we're not transitioning to gameplay (quit early via the sort menu etc), fade out the banner as well so it doesn't randomly linger
        if SCREENMAN:GetTopScreen():GetNextScreenName() ~= "ScreenGameplay" then self:visible(false) end
    end,

    -- Blinking gray banner outline
    Def.Quad{
        InitCommand=function(self)
            self:setsize(422,167):diffusealpha(0.3):glowramp():effectcolor1(0.1,0.1,0.1,0.35):effectcolor2(0.8,0.8,0.8,0.8):effectclock("beatnooffset")
        end,
    },
    
    -- Fallback banner (heart/arrow design, if song has no banner)
	Def.ActorFrame{
		CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		SetCommand=function(self)
			SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			if SongOrCourse and SongOrCourse:HasBanner() then
				self:visible(false)
			else
				self:visible(true)
			end
		end,

		LoadActor(banner_directory.."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png" )..{
			Name="FallbackBanner",
			OnCommand=function(self) self:rotationy(180):setsize(418,164):diffuseshift():effectoffset(3):effectperiod(6):effectcolor1(1,1,1,0):effectcolor2(1,1,1,1) end
		},

		LoadActor(banner_directory.."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png" )..{
			Name="FallbackBanner",
			OnCommand=function(self) self:diffuseshift():effectperiod(6):effectcolor1(1,1,1,0):effectcolor2(1,1,1,1):setsize(418,164) end
		},
	},

    -- Banner image
	Def.ActorProxy{
		Name="BannerProxy",
		BeginCommand=function(self)
			banner = SCREENMAN:GetTopScreen():GetChild('Banner')
			self:SetTarget(banner)
            if AllowThonk() then self:wag():effectmagnitude(0,0,1):effectclock("beat") end
		end
	},

	-- the MusicRate Quad and text
	Def.ActorFrame{
		InitCommand=function(self)
			self:visible( SL.Global.ActiveModifiers.MusicRate ~= 1 ):y(75)
		end,

		--quad behind the music rate text
		Def.Quad{
			InitCommand=function(self) self:diffuse( color("#1E282FCC") ):zoomto(418,14) end
		},

		--the music rate text
		LoadFont("Common Normal")..{
			InitCommand=function(self) self:shadowlength(1):zoom(0.85) end,
			OnCommand=function(self)
				self:settext(("%g"):format(SL.Global.ActiveModifiers.MusicRate) .. "x " .. THEME:GetString("OptionTitles", "MusicRate"))
			end
		}
	},
    
    
    
    -- Song name/artist box
    Def.ActorFrame{

        InitCommand=function(self) self:y(100) end,
        OffCommand=function(self) self:sleep(1.7):smooth(0.3):diffusealpha(0) end,
        -- background quad
		Def.Quad{
			InitCommand=function(self)
				self:diffuse(color_slate2)
					:zoomto( 418, 52 ):y(13)

				--if ThemePrefs.Get("RainbowMode") then
					self:diffusealpha(0.85)
                --end
            end
        },

        -- Title
        LoadFont("Common Normal")..{
            InitCommand=function(self) self:zoom(1.2):maxwidth(WideScale(340,340)) end,
            SetCommand=function(self)
                if GAMESTATE:IsCourseMode() then
                    local course = GAMESTATE:GetCurrentCourse()
                    self:settext( course and course:GetDisplayFullTitle() or "" )
                else
                    local song = GAMESTATE:GetCurrentSong()
                    if song then
                        self:settext( song:GetDisplayFullTitle() )
                        self:diffuse(getSongTitleColor(song:GetGroupName()))
                        if #song:GetDisplaySubTitle() > 0 then
                            self:AddAttribute(#song:GetDisplayMainTitle(), {Length = -1; Diffuse = color("#bbbbbb")})
                        end
                    else
                        self:settext("")
                    end
                end
            end
        },
        
        -- Artist
        LoadFont("Common Normal")..{
            InitCommand=function(self) self:y(24):maxwidth(WideScale(210,210)):diffuse(0.8,0.8,0.8,1) end,
            SetCommand=function(self)
                if GAMESTATE:IsCourseMode() then
                    local course = GAMESTATE:GetCurrentCourse()
                    self:settext( course and course:GetGroupName() or "" )
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
					self:horizalign(right):xy(-172,24):diffuse(0.5,0.5,0.5,1)
				end,
			},

			-- BPM value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(-168, 24):diffuse(1,1,1,1):maxwidth(50) end,
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
						:xy(158, 24)
						:diffuse(0.5,0.5,0.5,1)
				end
			},

			-- Song Duration Value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(162, 24):maxwidth(40) end,
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
        
        
        -- "SELECT DIFFICULTY" popup
        Def.ActorFrame{
            InitCommand=function(self) self:diffusealpha(0.2):zoomy(0):y(27) end,
            SongChosenMessageCommand=function(self) self:decelerate(0.5):diffusealpha(1):zoomy(1):sleep(3):decelerate(0.5):zoomy(0) end,
            SongUnchosenMessageCommand=function(self) self:finishtweening():decelerate(0.5):diffusealpha(0):zoomy(0) end,
            OffCommand=function(self) self:finishtweening():decelerate(0.3):diffusealpha(0) end,
            -- Border (white) quad
            Def.Quad{
                InitCommand=function(self) self:zoomto( 418, 23 ) end
            },
            -- Background (slate) quad
            Def.Quad{
                InitCommand=function(self) self:diffuse(color_slate2):zoomto( 416, 21 ) end
            },
            -- Text
            Def.BitmapText {
                Font="_upheaval 80px",
                Text=ScreenString("SelectDifficulty"),
                InitCommand=function(self) self:zoomy(0.20):zoomx(0.2):y(-2) end,
                SongChosenMessageCommand=function(self) self:finishtweening():linear(4):zoomx(0.25):shadowlength(3) end,
                SongUnchosenMessageCommand=function(self) self:smooth(1):zoomx(0.2):shadowlength(0) end,
            },
        },
    },
    
    
    -- long/marathon version bubble graphic and text
    Def.ActorFrame{
        InitCommand=function(self)
            self:zoom(1.33):xy( IsUsingWideScreen() and 180 or 180 , 155):bob():effectclock('beat'):effectperiod(4):effectmagnitude(0,1,0)
        end,
        SetCommand=function(self)
            local song = GAMESTATE:GetCurrentSong()
            self:visible( song and (song:IsLong() or song:IsMarathon()) or false )
        end,
        SongChosenMessageCommand=function(self) self:stoptweening():decelerate(0.5):diffusealpha(0.3) end,
        SongUnchosenMessageCommand=function(self) self:stoptweening():decelerate(0.5):diffusealpha(1) end,
        OffCommand=function(self) self:stoptweening():decelerate(0.5):diffusealpha(1):sleep(1.2):smooth(0.3):diffusealpha(0) end,

        LoadActor(THEME:GetPathG('bubble', ''))..{
            InitCommand=function(self) self:diffuse(GetCurrentColor()):zoom(0.455) end
        },

        LoadFont("Common Normal")..{
            InitCommand=function(self) self:diffuse(Color.Black):zoom(0.8):y(3) end,
            SetCommand=function(self)
                local song = GAMESTATE:GetCurrentSong()
                if not song then return end

                if song:IsMarathon() then
                    self:settext(THEME:GetString("SongDescription", "IsMarathon"))
                elseif song:IsLong() then
                    self:settext(THEME:GetString("SongDescription", "IsLong"))
                else
                --self:settext("3")
                end
            end
        },
    },
}

return t