local appearDelay = 2.5

local noteskin = PREFSMAN:GetPreference("EditorNoteSkinP1") -- uses the editor noteskin because "default noteskin" isn't a real preference
-- TODO: give this its own theme preference???

-- Fall back to the "default" noteskin if the above noteskin can't be found (surprisingly easy to run into when switching between game modes, etc)
if not NOTESKIN:DoesNoteSkinExist(noteskin) then
    noteskin = "default"
    
    -- If "default" isn't a valid noteskin, all hope is lost in the world. Retreat!
    if not NOTESKIN:DoesNoteSkinExist(noteskin) then return Def.Actor{} end
end

return Def.ActorFrame{
    InitCommand=function(self)
        self:Center():diffusealpha(0)
    end,
    OnCommand=function(self)
        self:sleep(appearDelay):smooth(0.5):diffusealpha(1):smooth(0.6):addy(-20):sleep(5):smooth(0.5):diffusealpha(0)
    end,
    
    Def.Quad{
        InitCommand=function(self)
            self:zoomto(_screen.w, _screen.h * 1.2):diffuse(0,0,0,0)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay):smooth(0.5):diffusealpha(0.5):sleep(7):smooth(0.5):diffusealpha(0)
        end,
    },
    
    -- "HOW TO PLAY" Text
    LoadFont("_upheaval_underline 80px")..{
        Text=ScreenString("HowToPlay"),
        InitCommand=function(self)
            self:zoom(0.7)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 0.5):smooth(0.5):addy(-20)
        end,
    },
    -- Underline
    Def.Quad{
        InitCommand=function(self)
            self:zoomto(0, 2):y(20):diffusealpha(0)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 0.7):decelerate(0.3):zoomto(375, 3):diffusealpha(1)
        end,
    },
    
    -- Explaination text
    LoadFont("Common normal")..{
        Text=ScreenString("Tutorial"),
        InitCommand=function(self)
            self:zoom(0.7):y(40):diffusealpha(0):zoom(1.2):shadowlength(1)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 0.5):smooth(0.6):addy(30):diffusealpha(1)
        end,
    },
    
    -- Correct Outline
    NOTESKIN:LoadActorForNoteSkin("Left", "Receptor", noteskin)..{
        InitCommand=function(self)
            self:xy(-135, 70):diffusealpha(0)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 1.2):smooth(0.5):diffusealpha(1)
        end,
    },
    
    -- Correct Tap
    NOTESKIN:LoadActorForNoteSkin("Left", "Tap Note", noteskin)..{
        InitCommand=function(self)
            self:xy(-135, 70):addy(100):diffusealpha(0):zoom(0.9)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 2):linear(1):diffusealpha(1):addy(-100)
        end,
    },
    
    LoadActor(THEME:GetPathG("", "Checkmark (doubleres)"))..{
        InitCommand=function(self)
            self:xy(-135, 70):diffusealpha(0)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 3):decelerate(0.1):zoom(1.1):diffusealpha(1)
        end,
    },
    
    -- Incorrect Outline
    NOTESKIN:LoadActorForNoteSkin("Right", "Receptor", noteskin)..{
        InitCommand=function(self)
            self:xy(135, 70):diffusealpha(0)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 3.2):smooth(0.5):diffusealpha(1)
        end,
    },
    
    -- Incorrect Tap
    NOTESKIN:LoadActorForNoteSkin("Right", "Tap Note", noteskin)..{
        InitCommand=function(self)
            self:xy(135, 70):addy(100):diffusealpha(0):zoom(0.9)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 4):linear(1):diffusealpha(1):addy(-80)
        end,
    },
    
    Def.Sprite{
        Texture=THEME:GetPathG("", "HoldJudgment label 1x2 (doubleres)"),
        InitCommand=function(self)
            self:xy(135, 70):diffusealpha(0):animate(false):setstate(1)
        end,
        OnCommand=function(self)
            self:sleep(appearDelay + 5):decelerate(0.1):zoom(1.1):diffusealpha(1)
        end,
    },
}