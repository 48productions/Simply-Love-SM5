local NumWheelItems = 15
local Selected = false

local displayingNews = false
local news_img = nil

local tipList = {
    -- UI Navigation
    "When picking a song folder,\nthe genre and difficulty scale\nare below the folder's name!",
    "DDR songs use a different\nrating scale for difficulties!",
	"Green songs use modern DDR difficulty ratings,\nYellow songs use old-school DDR/ITG difficulty ratings!",
	"A Green level 6 song is about as hard\nas a Yellow level 4 song",
	"For yellow songs, pick a lower\ndifficulty than usual.\nA Green 6 is about a Yellow 4!",
    "Press  &SELECT;  when picking a song\nto open the sorting menu",
    "Picked a song by accident?\nPress  &SELECT;  to go back!",
    "You can sort by song name\nusing the &SELECT; button sort menu",
    "From the  &SELECT;  button Sort menu,\nyou can sort by song genre/category!",
    "Using a USB drive? Press &SELECT; on the\nresults screen to save a screenshot",
    "Press UP + DOWN to\nclose the current folder",
    "A song's length is shown below its banner.\nSome harder songs test your stamina!",
    "Long songs eat up multiple stages!\nThey may not show up if you\ndon't have enough stages left.",
    "Hold  &START;  while playing a song to\nend the song early.",
    
    -- Charting meta
    "Some long, \"Hold\" notes are colored differently.\nTap these \"Roll\" notes repeatedly!",
    "DDR songs have a different step charting\nstyle from other folders.\nWhich do you like more?",
    "\"Tech\"-focused songs focus on\ntricky patterns and rhythms!",
    "\"Stamina\"-focused songs test your endurance, some\ncharts are several minutes long!",
    "If your arrows look like Skittles,\nthere's some funky rhythms afoot.\nStep the rainbow!",
    "Orange \"Modfile\" songs use insane scripted effects!\nUp for a challenge? Try \"Mawaruchi Surviver!\"",
    
    -- Get Involved!!!!
    "Use a USB drive to play\ncustom songs, save options, and more!",
    "You can write your own custom\nsongs/steps at home using programs like\n\"ArrowVortex\" or \"Stepmania/Project Outfox\"!",
    "Participate in local\nevents and tournaments!",
    "Thank your arcade staff!!!",
    "This game TRANSFORMS on APRIL FOOLS day.\nBE THERE!!!",
    "Simply Spud is community-ran!\nWe're always taking suggestions/feedback!",
    "Found an issue?\nTalk to the cabinet's maintainers!",
    
    -- Improvement tips!
    "Keep standing on the arrows when playing,\ntry not to return to the center!",
    "Stepping on panels when there are no arrows\nis a-okay!",
    "You don't lose life if\nyou step where there's no arrows!",
    "Alternating your feet after each arrow\ncan make some step patterns easier!",
    "Use either foot for any arrow!\nAdd your own flair to the dance!",
    "Practice makes perfect!\nKeep playing, and you'll improve fast!",
    "Dancing expert? Press  &START;  again after\npicking a song to change advanced options",
    "Arrows too dense to read? Try upping\nthe \"Speed Mod\" option a tad",
    "The \"Constant Arrow Speed\" option\nsets the note speed to be the same regardless\nof the song's BPM",
    "The \"Max Arrow Speed\" option\nsets the note speed automatically\nbased on the song's BPM",
    "The \"Screen Filter\" option darkens the\nbackground, so arrows are easier to see",
    "The \"Music Rate\" option speeds up/slows down\nthe song, great for practicing tricky steps",
    "Using only your heels/toes to hit\narrows can help with fast steps",
    "Don't be afraid to try something new!",

}

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()
		local overlay = topscreen:GetChild("Overlay")

        if event.GameButton == "Start" then
			Selected = true
            overlay:queuecommand("Finish")

		elseif event.GameButton == "Back" then
			topscreen:RemoveInputCallback(input)
			topscreen:Cancel()
		end
	end

	return false
end

local t = Def.ActorFrame{
    InitCommand=function(self) self:Center() end,
    OnCommand=function(self)
        --If we've figured out we're not displaying news (in casual mode, didn't find news to display, etc),
        --Automatically skip this screen - we don't need to initialize the other stuff here just GET OUT
        --self:sleep(30)
        if displayingNews == false then
            SCREENMAN:GetTopScreen():GetChild("Overlay"):playcommand("Finish")
        else
            SCREENMAN:GetTopScreen():AddInputCallback(input)
            if PREFSMAN:GetPreference("MenuTimer") then
                self:queuecommand("Listen")
            end
        end
        
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		if seconds <= 0 and not Selected then
			Selected = true
			--MESSAGEMAN:Broadcast("FinishNews")
            SCREENMAN:GetTopScreen():GetChild("Overlay"):playcommand("Finish")
		else
			self:sleep(0.25)
			self:queuecommand("Listen")
		end
	end,
    FinishCommand=function(self)
        self:sleep(1):queuecommand("Advance")
	end,
    AdvanceCommand=function(self)
        SCREENMAN:GetTopScreen():RemoveInputCallback(input)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
    end,
    LoadActor( THEME:GetPathS("common", "start") )..{
        Name="start_sound",
        SupportPan = false,
        IsAction = true,
        FinishCommand=function(self)
            if displayingNews then self:play() end
        end
    },
}

 --Going into a non-casual gamemode that uses the regular music wheel, play the first half of the music wheel intro animation
if SL.Global.GameMode ~= "Casual" then
    -- Background
    t[#t+1] = Def.Quad{
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black ):diffusealpha(0.5):zoomto(_screen.w, 150) end,
    }
    -- SELECT MUSIC text
    t[#t+1] = Def.BitmapText{
        Font="_upheaval_underline 80px",
        Text="SELECT MUSIC",
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.8):diffusealpha(1):y(-20) end,
    }
    -- Stage counter text
    t[#t+1] = Def.BitmapText{
        Font="_upheaval_underline 80px",
        Text=THEME:GetString("ScreenProfileLoad","Loading Profiles..."),
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.5):diffusealpha(1):y(30) end,
    }


    -- Upper/lower borders
    t[#t+1] = Def.Quad{
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoomto(_screen.w, 5):y(-75) end,
    }
    
    t[#t+1] = Def.Quad{
        InitCommand=function(self) self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoomto(_screen.w, 5):y(75) end,
    }
    
    
    --Tip text
    t[#t+1] = Def.BitmapText{
        Font="Common normal",
        Text="TIP: "..tipList[math.random(1, #tipList)],
        InitCommand=function(self)
            self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):y( _screen.cy * 0.5):diffusealpha(0):shadowlength(2)
        end,
        OnCommand=function(self) self:smooth(0.2):diffusealpha(0.7) end,
        OffCommand=function(self)
            self:smooth(0.1):diffusealpha(0)
        end,
    }
    
    
    
    --Get the highest max news seen values between both players
    local max_news = math.max(SL.P1.ActiveModifiers.MaxNewsSeen, SL.P2.ActiveModifiers.MaxNewsSeen)
    news_img = getNewsImg(max_news)
    --news_img = getNewsImg(nil) --Debug: Force a fetch of the latest attract mode news
    if news_img then
        displayingNews = true
    end
    
    if news_img then
        --News image
        t[#t+1] = Def.ActorFrame{
            InitCommand=function(self) self:xy(-_screen.cx, -_screen.cy) end,
            Def.Sprite{
                Texture=news_img and THEME:GetPathO("", news_img) or THEME:GetPathG("", "_blank.png"),
                InitCommand=function(self)
                    self:diffusealpha(0):draworder(104)
                    self:stretchto(_screen.w * 0.14 + 1, _screen.h * 0.10 + 1, _screen.w * 0.86 - 1, _screen.h * 0.82 - 1)
                end,
                OnCommand=function(self)
                    self:smooth(0.5):diffusealpha(1)
                end,
                FinishCommand=function(self)
                    self:smooth(0.15):diffusealpha(0)
                end,
            },
            
            --News BG
            Def.Quad{
                InitCommand=function(self)
                    self:zoomto(_screen.w * 0.8,0):Center():diffuse(color('#00000000')):draworder(103)
                end,
                OnCommand=function(self)
                    self:smooth(0.25):stretchto(_screen.w * 0.14, _screen.h * 0.10, _screen.w * 0.86, _screen.h * 0.82):diffusealpha(1)
                end,
                FinishCommand=function(self)
                    self:smooth(0.25):zoomto(_screen.w * 0.8,0)
                end,
            },
            
            --News BG Outline
            Def.Quad{
                InitCommand=function(self)
                    self:zoomto(_screen.w * 0.8,0):Center():diffuse(color('#cccccc00')):draworder(102)
                end,
                OnCommand=function(self)
                    self:smooth(0.25):stretchto(_screen.w * 0.14 - 1, _screen.h * 0.10 - 1, _screen.w * 0.86 + 1, _screen.h * 0.82 + 1):diffusealpha(1)
                end,
                FinishCommand=function(self)
                    self:smooth(0.25):zoomto(_screen.w * 0.8,0)
                end,
            },
            
            --"Press START to continue" text
            LoadFont("_upheaval_underline 80px")..{
                InitCommand=function(self)
                    self:xy(_screen.cx,_screen.h-65):zoom(0.5):shadowlength(1.7):settext("Press &START; to continue"):diffusealpha(0):draworder(105)
                end,
                OnCommand=function(self)
                    self:smooth(1):diffusealpha(1):diffuseshift():effectperiod(1.333):effectcolor1(1,1,1,0.3):effectcolor2(1,1,1,1)
                end,
                FinishCommand=function(self) self:smooth(0.3):diffusealpha(0) end,
            },
            
            --Screen BG
            Def.Quad{
                InitCommand=function(self)
                    self:FullScreen():draworder(101):diffuse(color('#00000000'))
                end,
                OnCommand=function(self)
                    self:smooth(0.1):diffusealpha(0.3)
                end,
                FinishCommand=function(self) self:smooth(0.1):diffusealpha(0) end,
            }
        }
    end
end

return t