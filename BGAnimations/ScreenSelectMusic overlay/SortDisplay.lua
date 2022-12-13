return Def.ActorFrame{
    InitCommand=function(self)
        self:xy(_screen.w, 32)
    end,
    Def.Quad{
        InitCommand=function(self) self:zoomto(100,20):vertalign(top):horizalign(right):diffuse(color_slate2):diffusealpha(0.85) end
    },
    LoadFont("Common normal")..{
		InitCommand=function(self)
			self:horizalign(left):vertalign(top):xy(-96,3):zoomx(0.65):zoomy(0.7):queuecommand("Set")
		end,
        SortMessageCommand=function(self, args)
            self:queuecommand("Set")
        end,
        SetCommand=function(self)
            self:settext(THEME:GetString("ScreenSelectMusic", "CurrentSort") .. SortOrderToLocalizedString(GAMESTATE:GetSortOrder()))
        end,
	}
}