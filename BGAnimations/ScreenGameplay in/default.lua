-- code for setting the PlayerOptions string (needed to counteract ITG mod charts)
-- and the MeasureCounter has been abstracted out to a different file to keep this one simpler.
local InitializeMeasureCounterAndModsLevel = LoadActor("./MeasureCounterAndModsLevel.lua")

local text = ""
local SongNumberInCourse = 0
local style = ThemePrefs.Get("VisualTheme")

local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..style
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")

if AllowThonk() then
    text = THEME:GetString("Stage", "Thonk")
    
elseif GAMESTATE:IsDemonstration() then
    text = THEME:GetString("Stage", "Demonstration")
    
elseif GAMESTATE:IsCourseMode() then
	text = THEME:GetString("Stage", "Stage") .. " 1"

elseif not PREFSMAN:GetPreference("EventMode") then
	text = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)

else
	text = THEME:GetString("Stage", "Event")
end

InitializeMeasureCounterAndModsLevel(SongNumberInCourse)

-------------------------------------------------------------------------

local af = Def.ActorFrame{}

af[#af+1] = Def.ActorFrame{
	-- no need to keep drawing these during gameplay; set visible(false) once they're done and save a few clock cycles
	OnCommand=function(self)
		if SL.Global.GameplayReloadCheck then
			-- don't bother animating these visuals if ScreenGameplay was just reloaded by a mod chart
			-- just jump directly to hiding this lead in
			self:playcommand("Hide")
		else
			self:sleep(2):queuecommand("Hide")
                    -- Transition animations for the notefields
            for i = 1,2 do
                if(SCREENMAN:GetTopScreen():GetChild('PlayerP' .. i) ~= nil) then
                    columns = SCREENMAN:GetTopScreen():GetChild('PlayerP' .. i):GetChild('NoteField'):GetColumnActors()
                    for j = #columns, 1, -1 do
                        columnnum = j
                        if(i % 2 == 0) then
                            -- if playernum is even, make sure to reverse the order that the columns slide in at.
                            columnnum = #columns - j + 1
                        end
                        transitionspeed = 0.5
                        columns[j]:addy(200):diffusealpha(0):sleep(1.37):decelerate(transitionspeed + (columnnum / 3 * transitionspeed))
                                  :addy(-200):diffusealpha(1)
                    end
                end
            end
		end
	end,
	HideCommand=function(self)
		self:visible(false)
		SL.Global.GameplayReloadCheck = true
	end,
	OffCommand=function(self)
		SL.Global.GameplayReloadCheck = false
	end,

	Def.Quad{
		InitCommand=function(self) self:diffuse(Color.Black):Center():FullScreen() end,
		OnCommand=function(self) self:sleep(1.4):accelerate(0.6):diffusealpha(0) end
	},

	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn splode"))..{
		InitCommand=function(self) self:diffuse(GetCurrentColor()):Center():rotationz(10):zoom(0):diffusealpha(0.9) end,
		OnCommand=function(self) self:sleep(0.4):linear(0.6):rotationz(0):zoom(1.1):diffusealpha(0) end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn splode"))..{
		InitCommand=function(self) self:diffuse(GetCurrentColor()):Center():rotationy(180):rotationz(-10):zoom(0):diffusealpha(0.8) end,
		OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(0):zoom(1.3):diffusealpha(0) end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn minisplode"))..{
		InitCommand=function(self) self:diffuse(GetCurrentColor()):Center():rotationz(10):zoom(0) end,
		OnCommand=function(self) self:sleep(0.4):decelerate(0.8):rotationz(0):zoom(0.9):diffusealpha(0) end
	},
    
    -- Banner/jacket AF
    Def.ActorFrame{
        Condition=not GAMESTATE:IsDemonstration(),
        OnCommand=function(self)
            if SL.Global.GameMode=="Casual" then
                self:xy(_screen.cx,_screen.cy-140):sleep(1.5):accelerate(0.5):y(0):diffusealpha(0)
            else
                self:xy(_screen.cx,_screen.cy-126):zoom(0.84):sleep(1.5):accelerate(0.5):y(0):diffusealpha(0)
            end
        end,
        
        -- Banner 'splode particles
        -- Keep two AFs here - one set for the casual mode transition, and one set for the pro mode transition
        Def.ActorFrame{
            Condition=SL.Global.GameMode=="Casual",
            LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu flytop (doubleres).png"))..{ -- Left
                InitCommand=function(self) self:diffuse(GetCurrentColor()):x(70):rotationz(-10):zoom(0):diffusealpha(0.9) end,
                OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(20):xy(120,40):zoom(1.1):diffusealpha(0) end
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu flycenter (doubleres).png"))..{ -- Center
                InitCommand=function(self) self:diffuse(GetCurrentColor()):zoom(0):diffusealpha(0.9) end,
                OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(10):y(-80):zoom(1.1):diffusealpha(0) end
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu flytop (doubleres).png"))..{ -- Right
                InitCommand=function(self) self:diffuse(GetCurrentColor()):x(70):rotationy(180):rotationz(-10):zoom(0):diffusealpha(0.9) end,
                OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(20):xy(-120,40):zoom(1.1):diffusealpha(0) end
            },
        },
        
        Def.ActorFrame{
            Condition=SL.Global.GameMode~="Casual",
            LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu flytop (doubleres).png"))..{ -- Left
                InitCommand=function(self) self:diffuse(GetCurrentColor()):x(200):rotationz(-10):zoom(0):diffusealpha(0.9) end,
                OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(20):xy(230,40):zoom(1.1):diffusealpha(0) end
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu flycenter (doubleres).png"))..{ -- Center
                InitCommand=function(self) self:diffuse(GetCurrentColor()):y(-50):zoom(0):diffusealpha(0.9) end,
                OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(10):y(-120):zoom(1.1):diffusealpha(0) end
            },
            LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu flytop (doubleres).png"))..{ -- Right
                Condition=SL.Global.GameMode~="Casual",
                InitCommand=function(self) self:diffuse(GetCurrentColor()):x(-200):rotationy(180):rotationz(-10):zoom(0):diffusealpha(0.9) end,
                OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(20):xy(-230,40):zoom(1.1):diffusealpha(0) end
            },
        },
        
        -- Banner outline
        Def.Quad{
            InitCommand=function(self)
                if SL.Global.GameMode=="Casual" then
                    self:setsize(132,132)
                else
                    self:setsize(422,167)
                end
                self:diffuse(0.8,0.8,0.8,0.6)
            end,
        },
        -- Banner/jacket sprite
        Def.Sprite{
            InitCommand=function(self)
                local img_path
                local img_type
                local is_casual = SL.Global.GameMode=="Casual"
                local song = GAMESTATE:GetCurrentSong()
                self:glow(Color.White) -- Start of our white "blink" animation
                -- (Todo: The blink is only to mask the change from the engine banner preserving the banner aspect ratio and the sprite just scaling the image. If this can be changed, the blink should be removed)
                
                if is_casual then
                    -- Need the other half of this animation, first - 48
                    -- Banner loading routine lifted from Casual mode
                    if song:HasJacket() then
                        self.img_path = song:GetJacketPath()
                        self.img_type = "Jacket"
                    elseif song:HasBackground() then
                        self.img_path = song:GetBackgroundPath()
                        self.img_type = "Background"
                    elseif song:HasBanner() then
                        self.img_path = song:GetBannerPath()
                        self.img_type = "Banner"
                    else -- Fall back to the casual "no jacket" texture
                        self:Load( THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/no-jacket.png") )
                        return
                    end
                else
                    -- For pro mode, we only check if a banner is present. (The engine wheel, afaik, will only load banners, so this makes for a smoother transition)
                    
                    
                    if song:HasBanner() then
                        self.img_path = song:GetBannerPath()
                        self.img_type = "Banner"
                    else
                        self:Load(banner_directory.."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png")
                        return
                    end
                end

                -- thank you, based Jousway
                if (Sprite.LoadFromCached ~= nil) then
                    self:LoadFromCached(self.img_type, self.img_path)

                -- support SM5.0.12 begrudgingly
                else
                    self:LoadBanner(self.img_path)
                end
                
                
            end,
            OnCommand=function(self)
                if SL.Global.GameMode=="Casual" then
                    self:setsize(128,128)
                else
                    self:setsize(418,164)
                end
                self:smooth(0.4):glow(0,0,0,0) -- Second half of the intro flash animation
            end,
        },
        
    },
}

af[#af+1] = LoadFont("_upheaval_underline 80px")..{
	Text=text,
	InitCommand=function(self) self:Center():diffusealpha(0):shadowlength(1):zoom(0.6) end,
	OnCommand=function(self)
		-- don't animate the text tweening to the bottom of the screen if ScreenGameplay was just reloaded by a mod chart
		if not SL.Global.GameplayReloadCheck then
			self:accelerate(0.5):diffusealpha(1):sleep(0.66):accelerate(0.33)
            if AllowThonk() then self:addrotationz(1080) end
		end
		self:zoom(0.3):y(_screen.h-30)
	end,
	CurrentSongChangedMessageCommand=function(self)
		if GAMESTATE:IsCourseMode() then
			InitializeMeasureCounterAndModsLevel(SongNumberInCourse)
			SongNumberInCourse = SongNumberInCourse + 1
			self:settext( THEME:GetString("Stage", "Stage") .. " " .. SongNumberInCourse )
		end
	end
}

if ShowTutorial() then af[#af+1] = LoadActor("./tutorial.lua") end

return af