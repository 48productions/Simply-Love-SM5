
local noteskinDDR = NOTESKIN:DoesNoteSkinExist("ddr-rainbow") and "ddr-rainbow" or "default"
local noteskinITG = NOTESKIN:DoesNoteSkinExist("metal") and "metal" or "default"



-- Get a category tag for a group
local getCategoryTag = function(group)
	-- First: Check if a group is stamina or tech (subsets of ITG, so should override ITG)
	local category = group_ratings[group]
	if category ~= 0 and category ~= nil then -- (rating 0 = no rating scale information, skip this check)
		if category:match("Stamina") then return "Stamina"
		elseif category:match("Tech") then return "Tech" end
	end
	
	-- Second: Check if a group is a USB Custom Song group (not in the song group list)
	if SONGMAN:GetSongsInGroup(group)[1]:IsCustomSong() then
		return "Customs"
	end
	
	-- Finally: Default to a category tag that matches the group's rating scale type
	local scale = group_rating_types[group]
	if scale == 1 then return "DDR"
	elseif scale == 2 then return "ITG"
	elseif scale == 3 then return "Mods" end
	
	-- No tags! Abort, abort!
	return nil
end



local af = Def.ActorFrame{
	InitCommand=function(self) self:y(_screen.cy-8) end,
	CurrentSongChangedMessageCommand=function(self)
		-- Check if we've highlighted a group, and set the group tag actors if so
		if not GAMESTATE:GetCurrentSong() and GAMESTATE:GetSortOrder() == "SortOrder_Group" then
			self:stoptweening():playcommand("GroupChanged", { group=SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection() }):diffusealpha(1)
		else
			self:diffusealpha(0)
		end
	end,
	


	-- CATEGORY TAG ACTORS
	Def.ActorFrame{
	
		InitCommand=function(self) self:diffusealpha(0):y(29) end,
		
		-- When we highlight a new group, check if we have a new tag to use
		GroupChangedCommand=function(self, params)
			local tag = getCategoryTag(params.group)
			if tag then
				self:stoptweening():playcommand("Set", {tag=tag, group=params.group}):diffusealpha(1)
			else
				self:stoptweening():diffusealpha(0)
			end
		end,

		-- Background left
		Def.Quad{
			InitCommand=function(self) self:zoomto(120, 27):x(-98):diffusealpha(0.2) end,
		},
		
		-- Background right
		Def.Quad{
			InitCommand=function(self) self:zoomto(196, 27):x(60):diffusealpha(0.1) end,
		},
		
		-- Tag
		Def.BitmapText{
			Font="_upheaval 80px",
			Text="",
			InitCommand=function(self) self:xy(-115, -4):zoom(0.3):horizalign('HorizAlign_Left'):maxwidth(240):shadowlengthy(2) end,
			SetCommand=function(self, params)
				self:settext(THEME:GetString("ScreenSelectMusic", "Desc"..params.tag))
					:diffuse(getSongTitleColor(params.group))
			end,
		},
		
		-- Tag description
		Def.BitmapText{
			Font="Common normal",
			Text="",
			InitCommand=function(self) self:x(-30):zoom(0.8):horizalign('HorizAlign_Left'):maxwidth(220) end,
			SetCommand=function(self, params)
				-- Special case the "Customs" tag to prepend the group (player's name) before the description
				-- "'s Custom Songs" -> "P1's Custom Songs"
				self:settext((params.tag == "Customs" and params.group or "")..THEME:GetString("ScreenSelectMusic", "Desc"..params.tag.."Info"))
				
				-- Special case Mods and Stamina to color the "For experienced dancers" text red.
				if params.tag == "Stamina" or params.tag == "Mods" then self:AddAttribute(27, {Length = -1, Diffuse = color("#FF3333")}) else self:ClearAttributes() end
			end,
		},	
		
		-- ITG Icon: Show for ITG, Tech, Stamina, or Mods
		NOTESKIN:LoadActorForNoteSkin("Up", "Tap Note", noteskinITG)..{
			InitCommand=function(self) self:xy(-138, -1):zoom(0.45):baserotationz(-135) end,
			SetCommand=function(self, params)
				self:stopeffect():stoptweening():smooth(0.1):baserotationz(-135)
				if params.tag == "ITG" or params.tag == "Tech" or params.tag == "Stamina" then
					self:diffusealpha(1)
				elseif params.tag == "Mods" then -- Make it do a little wiggle for mods :)
					self:diffusealpha(1):wag()
				else
					self:diffusealpha(0)
				end
			end,
		},
		
		-- DDR Icon: Show for DDR or Customs
		NOTESKIN:LoadActorForNoteSkin("Up", "Tap Note", noteskinDDR)..{
			InitCommand=function(self) self:xy(-138, -1):zoom(0.45):baserotationz(-135) end,
			SetCommand=function(self, params) self:stoptweening():smooth(0.1):diffusealpha((params.tag == "DDR" or params.tag == "Customs") and 1 or 0) end,
		},
	}
}



-- CONTENT TAG ACTORS
for i=1,2 do
	local afTag = Def.ActorFrame{
		InitCommand=function(self) self:diffusealpha(0):y(72) end,
		
		-- When we highlight a new group, check if we have a new tag to use
		GroupChangedCommand=function(self, params)
			self:stoptweening()
			local tags = group_tags[params.group]
			-- Yes there is a tag to show
			if tags and tags[i - 1] then
				local twoTags = tags[0] and tags[1]
--				self:stoptweening():smooth(0.1):diffusealpha(0):linear(0)
				
				-- Now to handle positioning - if there's two tags to show, make room for both
				if twoTags then
					self:x(i == 1 and -80 or 80)
				else -- For one tag, we grow to short
					self:x(0)
				end
				self:playcommand("Set", {tag=tags[i-1], twoTags=twoTags, group=params.group}):diffusealpha(1)
			else -- This tag goes unused
				self:diffusealpha(0):linear(0):x(0)
			end
		end,
		
		-- Background
		Def.Quad{
			InitCommand=function(self) self:diffusealpha(0.2) end,
			SetCommand=function(self, params)
				self:zoomto(params.twoTags and 150 or 280, 56)
			end,
		},
		
		-- Icon
		Def.Sprite{
			Texture=THEME:GetPathG("", "MusicNote.png"),
			InitCommand=function(self) self:x(0):zoomto(60, 60):shadowlength(1):diffusealpha(0.4) end,
		},
		
		-- Tag
		Def.BitmapText{
			Font="_upheaval 80px",
			Text="",
			InitCommand=function(self) self:xy(0, -4):zoom(0.3):maxwidth(240):shadowlengthy(2) end,
			SetCommand=function(self, params) self:settext(params.tag) end,
		},
	}
	
	af[#af+1] = afTag
end

return af