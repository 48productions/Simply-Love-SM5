local t = Def.ActorFrame{
    InitCommand=function(self)
        self:diffusealpha(0)
    end,
    OnCommand=function(self)
        self:smooth(0.4):diffusealpha(1):queuecommand("Refresh")
    end,
    OffCommand=function(self)
        self:smooth(0.4):diffusealpha(0)
    end,
    
    -- Force the text to change if a USB drive's state changes
    StorageDevicesChangedMessageCommand=function(self) self:stoptweening():queuecommand("Refresh") end,
}

--Helper function to get the "Press Start" text for the title screen
local function getStartText()

    -- But which prompt to show? Change it depending on the USB state
    --SM(MEMCARDMAN:GetCardState("PlayerNumber_P1"))
    
    for i = 1,2 do
        local card_state = MEMCARDMAN:GetCardState("PlayerNumber_P"..i)
        
        if card_state == "MemoryCardState_error" then -- Either player in error state = Show card error
            return THEME:GetString("ScreenSelectStyle", "USB Error")
            
        elseif card_state == "MemoryCardState_checking" then -- Either player checking card = Show card checking
            return THEME:GetString("ScreenSelectStyle", "USB Check")
            
        elseif card_state == "MemoryCardState_ready" then -- Either player in ready state = Show ready
            return THEME:GetString("ScreenSelectStyle", "USB Ready")
        
        end
    end
            
    -- If none of the above conditions are met (probably no cards for either player), show Insert USB
    return THEME:GetString("ScreenSelectStyle", "Insert USB")
end

t[#t+1] = LoadFont("_upheaval 80px")..{
	InitCommand=function(self)
		self:xy(_screen.cx,_screen.h*0.75):zoom(0.2):shadowlength(0.7)
	end,
	OnCommand=function(self)
		self:diffuseshift():effectclock("bgm"):effectperiod(2)
		self:effectcolor1(1,1,1,0.5):effectcolor2(1,1,1,0.9)
	end,
	OffCommand=function(self) self:visible(false) end,

	RefreshCommand=function(self)
        self:settext( getStartText() )
	end
}

for i=1,2 do
    t[#t+1] = Def.Sprite{
        Texture=THEME:GetPathG("", "usbicon.png"),
        InitCommand=function(self)
            self:xy(_screen.cx * (i==1 and 0.75 or 1.25), _screen.h*0.88):zoom(0.2):baserotationz(90):bounce():effectmagnitude(0,-15,0):effectclock("bgm")
        end,
        RefreshCommand=function(self)
            -- Switch this icon's animation depending on the card state
            local card_state = MEMCARDMAN:GetCardState("PlayerNumber_P"..i)
            if card_state == "MemoryCardState_error" or (card_state == "MemoryCardState_ready" and AllowThonk()) then -- Error: Violently vibrate in place
                self:vibrate()
                if AllowThonk() then self:effectmagnitude(150,150,0) end
            
            elseif card_state == "MemoryCardState_checking" then -- Checking: Pause bounce animation
                self:wag():effectmagnitude(0,0,1)
            
            elseif card_state == "MemoryCardState_ready" then -- Ready: Slide into the USB port
                self:stopeffect():decelerate(0.4):y(_screen.h*0.9)
        
            else -- Default bouncing animation, also slide into the default y position in case the drive was just unplugged
                self:bounce():effectmagnitude(0,-15,0):decelerate(0.4):y(_screen.h*0.88)
            end
        end,
    }
    t[#t+1] = Def.Sprite{
        Texture=THEME:GetPathG("", "Checkmark (doubleres).png"),
        InitCommand=function(self)
            self:diffusealpha(0):xy(_screen.cx * (i==1 and 0.75 or 1.25), _screen.h*0.88):baserotationz(-30)
        end,
        RefreshCommand=function(self)
            -- Show the icon if we're in ready, otherwise hide it
            if MEMCARDMAN:GetCardState("PlayerNumber_P"..i) == "MemoryCardState_ready" then
                self:finishtweening():decelerate(0.3):diffusealpha(0.7):baserotationz(0)
            else
                self:decelerate(0.5):diffusealpha(0):addy(50):sleep(0.1):baserotationz(-30):addy(-50)
            end
        end,
    }
end

return t