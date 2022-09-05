local text = ScreenString("HeaderText")
local row = ...

local af = Def.ActorFrame{

	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#000000dd"))
			self:zoomto(_screen.w, row.h*0.5):valign(0):xy( _screen.cx, 0 )
		end,
        OffCommand=function(self) self:smooth(0.5):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self)
			self:sleep(0.1):linear(0.1):zoomtoheight(row.h*0.5)
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):zoomtoheight(32) end,
	},

	-- "Choose Your Song"
	Def.BitmapText{
		Name="HeaderText",
		Font="_upheaval_underline 80px",
		Text=text,
		InitCommand=function(self) self:diffuse(1,1,1,0):zoom(WideScale(0.305,0.365)):horizalign(left):xy(10, 15) end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToGroupsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end,
	},
    -- "Press SELECT to close group"
    Def.BitmapText{
        Font="Common normal",
        Text=ScreenString("HeaderBackText"),
        InitCommand=function(self) self:diffuse(1,1,1,0):zoom(WideScale(0.5,0.56)):horizalign(left):xy(124, 54) end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
		SwitchFocusToGroupsMessageCommand=function(self) self:finishtweening():linear(0.01):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self) self:sleep(0.7):linear(0.1):diffusealpha(0.55) end,
    },
}

-- Stage Number
if not PREFSMAN:GetPreference("EventMode") then
	af[#af+1] = Def.BitmapText{
		Font=PREFSMAN:GetPreference("EventMode") and "_wendy monospace numbers" or "_wendy small",
		Name="Stage Number",
		Text=SSM_Header_StageText(),
		InitCommand=function(self)
			self:diffusealpha(0):halign(1):zoom(0.5):x(_screen.w-8)
			if PREFSMAN:GetPreference("MenuTimer") then
				self:y(44)
			else
				self:y(34)
			end
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end,
	}
end

return af