local numStages = SL.Global.Stages.PlayedThisGame

local page = 1
local pages = math.ceil(numStages/4)
local next_page

-- assume that the player has dedicated MenuButtons
local buttons = {
	-- previous page
	MenuLeft = -1,
	MenuUp = -1,
	-- next page
	MenuRight = 1,
	MenuDown = 1,
}

-- if OnlyDedicatedMenuButtons is disabled, add in support for navigating this screen with gameplay buttons
if not PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
	-- previous page
	buttons.Left=-1
	buttons.Up=-1
	buttons.DownLeft=-1
	-- next page
	buttons.Right=1
	buttons.Down=1
	buttons.DownRight=1
end

local page_text = THEME:GetString("ScreenEvaluationSummary", "Page")

local t = Def.ActorFrame{
	CodeMessageCommand=function(self, param)
		if param.Name == "Screenshot" then

			-- organize Screenshots taken using Simply Love into directories, like...
			-- ./Screenshots/Simply_Love/2015/06-June/2015-06-05_121708.png
			local prefix = "Simply_Love/" .. Year() .. "/"
			prefix = prefix .. string.format("%02d", tostring(MonthOfYear()+1)) .. "-" .. THEME:GetString("Months", "Month"..MonthOfYear()+1) .. "/"

			SaveScreenshot(param.PlayerNumber, false, true, prefix)
		end

		if pages > 1 and buttons[param.Name] ~= nil then
			next_page = page + buttons[param.Name]

			if next_page > 0 and next_page < pages+1 then
				page = next_page
				self:stoptweening():queuecommand("Hide")
			end
		end
	end,

	LoadActor( THEME:GetPathB("", "Triangles.lua") ),

	LoadFont("_upheaval_underline 80px")..{
		Name="PageNumber",
		Text=("%s %i/%i"):format(page_text, page, pages),
		InitCommand=function(self) self:diffusealpha(0):zoom(WideScale(0.305,0.365)):xy(_screen.cx, 12) end,
		OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1) end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
		HideCommand=function(self) self:sleep(0.5):settext( ("%s %i/%i"):format(page_text, page, pages) ) end
	},
    
    -- Memory card prompt (show if no players using cards)
    Def.ActorFrame{
        Condition=GAMESTATE:IsAnyHumanPlayerUsingMemoryCard() == false and PREFSMAN:GetPreference("MemoryCards") == true,
        InitCommand=function(self) self:xy(_screen.w + 105, _screen.h - 50):draworder(9999) end,
        OnCommand=function(self) self:sleep(0.2):decelerate(0.4):x(_screen.w - 105) end,
        OffCommand=function(self) self:accelerate(0.4):x(_screen.w + 105) end,
        Def.Quad{
            InitCommand=function(self)
                self:zoomto(210, 50):diffuse(color_slate4):fadeleft(0.1)
            end,
        },
        Def.Quad{
            InitCommand=function(self)
                self:zoomto(210, 1):y(25):fadeleft(0.3)
            end,
        },
        LoadFont("Common normal")..{
            Text=THEME:GetString("ScreenEvaluationSummary", "USBPrompt"),
            InitCommand=function(self) self:horizalign(2):xy(97, -2):maxwidth(140):diffuseshift():effectcolor1(color('#ffffffff')):effectcolor2(color('#ddddaaff')):effectperiod(2) end,
        },
        Def.Sprite{
            Texture=THEME:GetPathG("","usbicon.png"),
            InitCommand=function(self) self:zoom(0.15):baserotationz(-40):x(-67) end,
        },
    }
}

if SL.Global.GameMode ~= "StomperZ" then
	t[#t+1] = LoadActor("./LetterGrades.lua")
end

-- i will increment so that we progress down the screen from top to bottom
-- first song of the round at the top, more recently played song at the bottom
for i=1,4 do

	t[#t+1] = LoadActor("StageStats.lua", i)..{
		Name="StageStats_"..i,
		InitCommand=function(self) self:diffusealpha(0) end,
		OnCommand=function(self)
			self:xy(_screen.cx, ((_screen.h/4.75) * i))
				:queuecommand("Hide")
		end,
		ShowCommand=function(self)
			self:sleep(i*0.05):linear(0.15):diffusealpha(1)
		end,
		HideCommand=function(self)
			self:playcommand("DrawPage", {Page=page})
		end,
	}

end

return t