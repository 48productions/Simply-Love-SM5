local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualTheme")
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")

local SongOrCourse, banner

local t = Def.ActorFrame{
    CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
    CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
	OnCommand=function(self)
        self:y(112):zoom(0.7)
		if IsUsingWideScreen() then
			self:decelerate(0.25):zoom(0.7655)--:x(_screen.cx - 170)
		else
			self:decelerate(0.25):zoom(0.75)--:x(_screen.cx - 166)
		end
	end,

    Def.Quad{
        InitCommand=function(self)
            self:setsize(422,167):diffusealpha(0.3):glowramp():effectcolor1(0.1,0.1,0.1,0.35):effectcolor2(0.8,0.8,0.8,0.8):effectclock("beatnooffset")
        end,
    },
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
        -- background quad
		Def.Quad{
			InitCommand=function(self)
				self:diffuse(color_slate2)
					:zoomto( 418, 32 )

				--if ThemePrefs.Get("RainbowMode") then
					self:diffusealpha(0.85)
                --end
            end
        },

        -- Title/Artist
        LoadFont("Common Normal")..{
            InitCommand=function(self) self:zoom(1.2):maxwidth(WideScale(340,340)) end,
            SetCommand=function(self)
                if GAMESTATE:IsCourseMode() then
                    local course = GAMESTATE:GetCurrentCourse()
                    self:settext( course and #course:GetCourseEntries() or "" )
                else
                    local song = GAMESTATE:GetCurrentSong()
                    self:settext( song and song:GetDisplayFullTitle() .. " // " .. song:GetDisplayArtist() or "" )
                end
            end
        },
        
        
        -- "SELECT DIFFICULTY" popup
        Def.ActorFrame{
            InitCommand=function(self) self:diffusealpha(0.2):zoomy(0) end,
            SongChosenMessageCommand=function(self) self:decelerate(0.5):diffusealpha(1):zoomy(1):sleep(3):decelerate(0.5):zoomy(0) end,
            SongUnchosenMessageCommand=function(self) self:finishtweening():decelerate(0.5):diffusealpha(0):zoomy(0) end,
            -- Border (white) quad
            Def.Quad{
                InitCommand=function(self) self:zoomto( 418, 32 ) end
            },
            -- Background (slate) quad
            Def.Quad{
                InitCommand=function(self) self:diffuse(color_slate2):zoomto( 416, 30 ) end
            },
            -- Text
            Def.BitmapText {
                Font="_upheaval 80px",
                Text=ScreenString("SelectDifficulty"),
                InitCommand=function(self) self:zoomy(0.30):zoomx(0.3):y(-4) end,
                SongChosenMessageCommand=function(self) self:finishtweening():linear(4):zoomx(0.35):shadowlength(3) end,
                SongUnchosenMessageCommand=function(self) self:smooth(1):zoomx(0.3):shadowlength(0) end,
            },
        },
    },
    
    
    -- long/marathon version bubble graphic and text
    Def.ActorFrame{
        InitCommand=function(self)
            self:zoom(1.33):xy( IsUsingWideScreen() and 120 or 120 , 135):bob():effectclock('beat'):effectperiod(4):effectmagnitude(0,1,0)
        end,
        SetCommand=function(self)
            local song = GAMESTATE:GetCurrentSong()
            self:visible( song and (song:IsLong() or song:IsMarathon()) or false )
        end,
        SongChosenMessageCommand=function(self) self:stoptweening():decelerate(0.5):diffusealpha(0.3) end,
        SongUnchosenMessageCommand=function(self) self:stoptweening():decelerate(0.5):diffusealpha(1) end,

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