local t = Def.ActorFrame{}


--Helper function to get the "Press Start" text for the title screen
local function getStartText()

    -- But which prompt to show? Change it depending on the USB state
    --SM(MEMCARDMAN:GetCardState("PlayerNumber_P1"))
    
    for i = 1,2 do
        local card_state = MEMCARDMAN:GetCardState("PlayerNumber_P"..i)
        
        if card_state == "MemoryCardState_error" then -- Either player in error state = Show card error
            return THEME:GetString("ScreenTitleJoin", "USB Error")
            
        elseif card_state == "MemoryCardState_checking" then -- Either player checking card = Show card checking
            return THEME:GetString("ScreenTitleJoin", "USB Check")
            
        elseif card_state == "MemoryCardState_ready" then -- Either player in ready state = Show ready
            return THEME:GetString("ScreenTitleJoin", "USB Ready")
        
        end
    end
            
    -- If none of the above conditions are met (probably no cards for either player), show Insert USB
    return THEME:GetString("ScreenTitleJoin", "Insert USB")
end


-- PRESS START text
t[#t+1] = LoadFont("_upheaval 80px")..{
	InitCommand=function(self)
		self:xy(_screen.cx,_screen.h-80):zoom(0.35):shadowlength(0.75)
		self:visible(false):queuecommand("Refresh")
	end,
	OnCommand=function(self)
        self:visible( not IsHome() )
		self:diffuseshift():effectperiod(1.333)
		self:effectcolor1(1,1,1,0):effectcolor2(1,1,1,1)
	end,
	OffCommand=function(self) self:visible(false) end,
    
    -- Force the Start text to instantly change if:
    --  - A coin is inserted
    --  - We change between coin and free play mode
	CoinsChangedMessageCommand=function(self) self:stoptweening():queuecommand("Refresh") end,
	CoinModeChangedMessageCommand=function(self) self:stoptweening():queuecommand("Refresh") end,

	RefreshCommand=function(self)
		if GAMESTATE:GetCoinMode() == "CoinMode_Free" then
		 	self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
		else

            if GetCredits().Credits <= 0 then
                self:settext( THEME:GetString("ScreenLogo", "EnterCreditsToPlay") )
            else
                self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
            end
        end
        
	end
}

-- USB Helper Text
t[#t+1] = LoadFont("_upheaval 80px")..{
    Condition=PREFSMAN:GetPreference("MemoryCards") == true,
	InitCommand=function(self)
		self:xy(_screen.cx,_screen.h-50):zoom(0.2):shadowlength(0.7)
		self:visible(false):queuecommand("Refresh")
	end,
	OnCommand=function(self)
        self:visible( not IsHome() )
		self:diffuseshift():effectperiod(1.333)
		self:effectcolor1(1,1,1,0):effectcolor2(1,1,1,1)
	end,
	OffCommand=function(self) self:visible(false) end,

    -- Force the text to instantly change if:
    --  - A coin is inserted
    --  - We change between coin and free play mode
    --  - A USB drive's state changes
	CoinsChangedMessageCommand=function(self) self:stoptweening():queuecommand("Refresh") end,
	CoinModeChangedMessageCommand=function(self) self:stoptweening():queuecommand("Refresh") end,
    StorageDevicesChangedMessageCommand=function(self) self:stoptweening():queuecommand("Refresh") end,

	RefreshCommand=function(self)
		if GAMESTATE:GetCoinMode() == "CoinMode_Free" then
		 	self:settext( getStartText() )
		else

            if GetCredits().Credits <= 0 then
                self:settext( THEME:GetString("ScreenLogo", "EnterCreditsToPlay") )
            else
                self:settext( getStartText() )
            end
        end
	end
}

return t
