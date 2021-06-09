local Players = GAMESTATE:GetHumanPlayers();

local using_mem_card = GAMESTATE:IsAnyHumanPlayerUsingMemoryCard()
local new_profile_written = PROFILEMAN:ProfileFromMemoryCardIsNew('PlayerNumber_P1') or PROFILEMAN:ProfileFromMemoryCardIsNew('PlayerNumber_P2') --If either player has a *new* memory card profile, note it

local t = Def.ActorFrame{
    
	--Player 1 Stats BG
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(160,_screen.h):xy(80, _screen.h/2):diffuse(color("#00000099"))
			if ThemePrefs.Get("RainbowMode") then self:diffuse(color("#000000dd")) end
		end,
	},

	--Player 2 Stats BG
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(160,_screen.h):xy(_screen.w-80, _screen.h/2):diffuse(color("#00000099"))
			if ThemePrefs.Get("RainbowMode") then self:diffuse(color("#000000dd")) end
		end,
	},
    
    --"Thanks for playing"/USB reminder text
    LoadFont("_upheaval_underline 80px")..{
		Text=ScreenString("ThanksForPlaying"),
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+150):diffuse(color("#aaaaaaff")):zoom(0.25) end,
		OnCommand=function(self)
			self:queuecommand("Pulse")
			if using_mem_card then
                if new_profile_written then --Display different messages if a new memory card profile was written
                    self:settext(ScreenString("NewProfile"))
                else
                    self:settext(ScreenString("USBReminder"))
                end
            end
		end,
		PulseCommand=function(self) self:smooth(1.5):zoom(0.35):smooth(1.5):zoom(0.34):queuecommand("Pulse") end,
	},
}

for player in ivalues(Players) do

	local line_height = 28
	local middle_line_y = 220
	local x_pos = player == PLAYER_1 and 80 or _screen.w-80
	local PlayerStatsAF = Def.ActorFrame{ Name="PlayerStatsAF_"..ToEnumShortString(player) }
	local stats

	-- first, check if this player is using a profile (local or MemoryCard)
	if PROFILEMAN:IsPersistentProfile(player) then

		-- if a profile is in use, grab gameplay stats for this session that are pertinent
		-- to this specific player's profile (highscore name, calories burned, total songs played)
		stats = LoadActor("PlayerStatsWithProfile.lua", player)

		-- loop through those stats, adding them to the ActorFrame for this player as BitmapText actors
		for i,stat in ipairs(stats) do
			PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("Common Normal")..{
				Text=stat,
				InitCommand=function(self)
					self:diffuse(PlayerColor(player))
						:xy(x_pos, (line_height*(i-1)) + 40)
						:maxwidth(150)
				end
			}
		end

	end

	-- draw a thin line (really just a Def.Quad) separating
	-- the upper (profile) stats from the lower (general) stats
	PlayerStatsAF[#PlayerStatsAF+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(120,1):xy(x_pos, middle_line_y)
				:diffuse( PlayerColor(player) )
		end
	}

	-- retrieve general gameplay session stats for which a profile is not needed
	stats = LoadActor("PlayerStatsWithoutProfile.lua", player)

	-- loop through those stats, adding them to the ActorFrame for this player as BitmapText actors
	for i,stat in ipairs(stats) do
		PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("Common Normal")..{
			Text=stat,
			InitCommand=function(self)
				self:diffuse(PlayerColor(player))
					:xy(x_pos, _screen.h - (line_height*i))
					:maxwidth(150)
			end
		}
	end

	t[#t+1] = PlayerStatsAF
end

if using_mem_card then --If any player is using a memory card, remind them to take it with them!
	t[#t+1] = LoadActor("usbicon.png")..{
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+215):zoom(0.35) end,
		OnCommand=function(self) self:glow(1,1,1,1):glowshift():queuecommand("Rotate") end,
		RotateCommand=function(self) self:smooth(1):rotationz(8):smooth(1):rotationz(-8):queuecommand("Rotate") end,
	}
end

--Background cover
t[#t+1] = Def.Quad{
    InitCommand=function(self) self:FullScreen():diffuse(color('#000000ff')) end,
    OnCommand=function(self) self:sleep(0.5):smooth(3):diffusealpha(0) end
}

 --"Game Over" text
t[#t+1] = Def.Sprite{
    Texture="GameOver.png",
    InitCommand=function(self) self:Center():zoom(0.4):diffusealpha(0) end,
    OnCommand=function(self) self:smooth(0.5):diffusealpha(1):linear(15):zoom(0.6) end,
    OffCommand=function(self) self:smooth(0.5):diffusealpha(0) end,
}

return t