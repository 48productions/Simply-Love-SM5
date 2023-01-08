local args = ...
local row = args[1]
local col = args[2]
local Input = args[3]

local bg_color = {0,0,0,0.8}
local divider_color = {1,1,1,0.75}

local af = Def.ActorFrame{
	--InitCommand=function(self) self:diffusealpha(0) end,
	--SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(1) end,
	--SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(1) end,
	--SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
    OffCommand=function(self) self:smooth(0.5):diffusealpha(0) end,

	-- Song Info - Outline
	Def.Quad{
		Name="SongInfoBGOutline",
		InitCommand=function(self) self:diffuse({1, 1, 1, 0.3}):zoomto(_screen.w/WideScale(1.145,1.495), row.h*1.02) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy - row.h/1.6 ) end,
        SwitchFocusToSongsMessageCommand=function(self) self:decelerate(0.1):croptop(1) end,
        SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.2):decelerate(0.3):croptop(0) end,
	},

	-- Song Info - Background
	Def.Sprite{
		Name="SongInfoBG",
		InitCommand=function(self) self:diffuse({0.18, 0.18, 0.18, 0.9}):scaletoclipped(_screen.w/WideScale(1.15,1.5), row.h) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy - row.h/1.6 ) end,
        SwitchFocusToSongsMessageCommand=function(self) self:decelerate(0.1):croptop(1) end,
        SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.2):decelerate(0.3):croptop(0):LoadFromCurrentSongBackground() end,
	},

	-- Player Options - Outline
	Def.Quad{
		Name="PlayerOptionsBGOutline",
		InitCommand=function(self) self:diffuse({1, 1, 1, 0.3}):zoomto(_screen.w/WideScale(1.145,1.495), row.h*1.52) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy + row.h/1.5 ) end,
        SwitchFocusToSongsMessageCommand=function(self) self:decelerate(0.1):cropbottom(1) end,
        SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.2):decelerate(0.3):cropbottom(0) end,
	},

	-- Player Options - Background
	Def.Quad{
		Name="PlayerOptionsBG",
		InitCommand=function(self) self:diffuse(bg_color):zoomto(_screen.w/WideScale(1.15,1.5), row.h*1.5) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy + row.h/1.5 ) end,
        SwitchFocusToSongsMessageCommand=function(self) self:decelerate(0.1):cropbottom(1) end,
        SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.2):decelerate(0.3):cropbottom(0) end,
	},

	-- Player Options - Divider Line
	Def.Quad{
		Name="PlayerOptionsDivider",
		InitCommand=function(self) self:diffuse(divider_color):zoomto(2, row.h*.85) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy + row.h/1.5 ) end,
        SwitchFocusToSongsMessageCommand=function(self) self:decelerate(0.1):cropbottom(1) end,
        SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.2):decelerate(0.3):cropbottom(0) end,
	},
}

for player in ivalues( {PLAYER_1, PLAYER_2} ) do
	if not GAMESTATE:IsSideJoined(player) and Input.AllowLateJoin() then
		af[#af+1] = LoadFont("Common Normal")..{
			Text=THEME:GetString("ScreenSelectMusicCasual", "PressStartToLateJoin"),
			InitCommand=function(self)
				self:xy( _screen.cx + 150 * (player==PLAYER_1 and -1 or 1), _screen.cy + 80 )
					:diffuseshift():effectcolor1(1,1,1,1):effectcolor1(1,1,1,0.5)
			end,
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == player then
					self:smooth(0.15):zoom(1.4):smooth(0.15):zoom(0)
				end
			end,
            SwitchFocusToSongsMessageCommand=function(self) self:decelerate(0.1):diffusealpha(0) end,
            SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.352):decelerate(0.3):diffusealpha(1) end,
		}
	end
end

return af