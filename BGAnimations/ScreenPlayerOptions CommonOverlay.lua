-- this prepares and returns a string to be used by the helper BitmapText
-- at the top of the screen (one for each player)
local GetSpeedModHelperText = function(player)

	local mods = SL[ToEnumShortString(player)].ActiveModifiers

	-- if using an xmod
	if mods.SpeedModType == "x" then
		return "x" .. StringifyDisplayBPMs(player, GAMESTATE:GetCurrentSteps(player), SL.Global.ActiveModifiers.MusicRate, mods.SpeedMod)

	-- otherwise, the player is using a Cmod or an Mmod
	else
		return mods.SpeedModType .. tostring(mods.SpeedMod)
	end
end

-- ----------------------------------------------------------

local af = Def.ActorFrame{
	Name="CommonOverlay",
	-- InitCommand=function(self) self:xy(_screen.cx,0) end,

	-- this is broadcast from [OptionRow] TitleGainFocusCommand in metrics.ini
	-- we use it to color the active OptionRow's title appropriately by PlayerColor()
	OptionRowChangedMessageCommand=function(self, params)
		local CurrentRowIndex = {'P1', 'P2'}

		-- There is always the possibility that a diffuseshift is still active;
		-- cancel it now (and re-apply below, if applicable).
		params.Title:stopeffect()

		-- get the index of PLAYER_1's current row
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			CurrentRowIndex.P1 = SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_1)
		end

		-- get the index of PLAYER_2's current row
		if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			CurrentRowIndex.P2 = SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_2)
		end

		local optionRow = params.Title:GetParent():GetParent();

		-- color the active optionrow's title appropriately
		if optionRow:HasFocus(PLAYER_1) then
			params.Title:diffuse(PlayerColor(PLAYER_1))
		end

		if optionRow:HasFocus(PLAYER_2) then
			params.Title:diffuse(PlayerColor(PLAYER_2))
		end

		if CurrentRowIndex.P1 and CurrentRowIndex.P2 then
			if CurrentRowIndex.P1 == CurrentRowIndex.P2 then
				params.Title:diffuseshift()
				params.Title:effectcolor1(PlayerColor(PLAYER_1))
				params.Title:effectcolor2(PlayerColor(PLAYER_2))
			end
		end

	end
}

local props = {
	w = WideScale(270,330),
	h = 50,
	padding = 5,
}

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)

	local frame = Def.ActorFrame{
		Name="ActiveMods"..pn,
		InitCommand=function(self)
			self:horizalign(left):y(59.5)
			    :x(player==PLAYER_1 and 321 or 655.5)
		end
	}
	-- per-player Quad at the top of the screen behind list of active modifiers
	frame[#frame+1] = Def.Quad{
		Name="Background",
		InitCommand=function(self)
			self:diffuse(0,0,0,0)
			    :setsize(props.w, props.h)
		end,
		OnCommand=function(self) self:linear(0.2):diffusealpha(0.8) end,
	}

	-- the large block text at the top that shows each player their current scroll speed
	frame[#frame+1] = LoadFont("_wendy small")..{
		Name="SpeedModHelper",
		InitCommand=function(self)
			self:diffuse(PlayerColor(player)):diffusealpha(0)
			    :horizalign(left)
				 :zoom(0.425):y(-12)
				 :x(-props.w/2 + props.padding)
			    :shadowlength(0.55)
			    :queuecommand("Refresh")

		end,
		OnCommand=function(self) self:linear(0.4):diffusealpha(1) end,
		RefreshCommand=function(self)
			self:settext( GetSpeedModHelperText(player):gsub("%s+", "") )
		end
	}

	-- noteskin preview
	frame[#frame+1] = Def.ActorProxy{
		InitCommand=function(self) self:zoom(0.4):horizalign(left):xy(-props.w/2+props.padding,10) end,
		NoteSkinChangedMessageCommand=function(self, params)
			if player == params.Player then
				-- attempt to find the hidden NoteSkin actor added by ./BGAnimations/ScreenPlayerOptions overlay.lua
				local noteskin_actor = SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("NoteSkin_"..params.NoteSkin)
				-- ensure that that NoteSkin actor exists before attempting to set it as the target of this ActorProxy
				if noteskin_actor then self:SetTarget( noteskin_actor ) end
			end
		end
	}

	-- judgment graphic preview
	frame[#frame+1] = Def.ActorProxy{
		InitCommand=function(self) self:zoom(0.4):horizalign(left):xy(-props.w/2+props.padding,10) end,
		JudgmentGraphicChangedMessageCommand=function(self, params)
			if player == params.Player then
				-- attempt to find the hidden NoteSkin actor added by ./BGAnimations/ScreenPlayerOptions overlay.lua
				local judgment_sprite = SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("JudgmentGraphic_"..params.JudgmentGraphic)
				-- ensure that that NoteSkin actor exists before attempting to set it as the target of this ActorProxy
				if judgment_sprite then self:SetTarget( judgment_sprite ) end
			end
		end
	}

	af[#af+1] = frame
end

return af
