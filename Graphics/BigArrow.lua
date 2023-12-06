local colorStroke = color('#FF121DFF')
local colorFill = color('#45301775')

local mode = ...

local vertsFill = {
	-- Front
	{ {34.19, 9.42, 5}, colorFill },
	{ {63.1, 38.34, 5}, colorFill },
	{ {100, 0, 5}, colorFill },
	
	{ {100, 0, 5}, colorFill },
	{ {0, -100, 5}, colorFill },
	{ {-100, 0, 5}, colorFill },
	
	{ {100, 0, 5}, colorFill },
	{ {34.19, 9.42, 5}, colorFill },
	{ {-34.19, 9.42, 5}, colorFill },
	
	{ {-100, 0, 5}, colorFill },
	{ {100, 0, 5}, colorFill },
	{ {-34.19, 9.42, 5}, colorFill },
	
	{ {34.19, 9.42, 5}, colorFill },
	{ {34.19, 95.69, 5}, colorFill },
	{ {-34.19, 9.42, 5}, colorFill },
	
	{ {-34.19, 9.42, 5}, colorFill },
	{ {34.19, 95.69, 5}, colorFill },
	{ {-34.19, 95.69, 5}, colorFill },
	
	{ {-34.19, 9.42, 5}, colorFill },
	{ {-63.1, 38.34, 5}, colorFill },
	{ {-100, 0, 5}, colorFill },
	
	-- Edge
	{ {0, -100, 5}, colorFill },
	{ {0, -100, -5}, colorFill },
	{ {100, 0, 5}, colorFill },
	
	{ {0, -100, -5}, colorFill },
	{ {100, 0, 5}, colorFill },
	{ {100, 0, -5}, colorFill },
	
	{ {100, 0, 5}, colorFill },
	{ {100, 0, -5}, colorFill },
	{ {63.1, 38.34, 5}, colorFill },
	
	{ {100, 0, -5}, colorFill },
	{ {63.1, 38.34, 5}, colorFill },
	{ {63.1, 38.34, -5}, colorFill },
	
	{ {63.1, 38.34, 5}, colorFill },
	{ {63.1, 38.34, -5}, colorFill },
	{ {34.19, 9.42, 5}, colorFill },
	
	{ {63.1, 38.34, -5}, colorFill },
	{ {34.19, 9.42, 5}, colorFill },
	{ {34.19, 9.42, -5}, colorFill },
	
	{ {34.19, 9.42, 5}, colorFill },
	{ {34.19, 9.42, -5}, colorFill },
	{ {34.19, 95.69, 5}, colorFill },
	
	{ {34.19, 9.42, -5}, colorFill },
	{ {34.19, 95.69, 5}, colorFill },
	{ {34.19, 95.69, -5}, colorFill },
	
	{ {34.19, 95.69, 5}, colorFill },
	{ {34.19, 95.69, -5}, colorFill },
	{ {-34.19, 95.69, 5}, colorFill },
	
	{ {34.19, 95.69, -5}, colorFill },
	{ {-34.19, 95.69, 5}, colorFill },
	{ {-34.19, 95.69, -5}, colorFill },
	
	{ {-34.19, 95.69, 5}, colorFill },
	{ {-34.19, 95.69, -5}, colorFill },
	{ {-34.19, 9.42, -5}, colorFill },
	
	{ {-34.19, 95.69, 5}, colorFill },
	{ {-34.19, 9.42, -5}, colorFill },
	{ {-34.19, 9.42, 5}, colorFill },
	
	{ {-34.19, 9.42, -5}, colorFill },
	{ {-34.19, 9.42, 5}, colorFill },
	{ {-63.1, 38.34, -5}, colorFill },
	
	{ {-34.19, 9.42, 5}, colorFill },
	{ {-63.1, 38.34, 5}, colorFill },
	{ {-63.1, 38.34, -5}, colorFill },
	
	{ {-63.1, 38.34, 5}, colorFill },
	{ {-63.1, 38.34, -5}, colorFill },
	{ {-100, 0, -5}, colorFill },
	
	{ {-63.1, 38.34, 5}, colorFill },
	{ {-100, 0, 5}, colorFill },
	{ {-100, 0, -5}, colorFill },
	
	{ {-100, 0, 5}, colorFill },
	{ {-100, 0, -5}, colorFill },
	{ {0, -100, 5}, colorFill },
	
	{ {-100, 0, -5}, colorFill },
	{ {0, -100, 5}, colorFill },
	{ {0, -100, -5}, colorFill },
	
	
	-- Rear
	{ {34.19, 9.42, -5}, colorFill },
	{ {63.1, 38.34, -5}, colorFill },
	{ {100, 0, -5}, colorFill },
	{ {100, 0, -5}, colorFill },
	{ {0, -100, -5}, colorFill },
	{ {-100, 0, -5}, colorFill },
	{ {100, 0, -5}, colorFill },
	{ {34.19, 9.42, -5}, colorFill },
	{ {-34.19, 9.42, -5}, colorFill },
	{ {-100, 0, -5}, colorFill },
	{ {100, 0, -5}, colorFill },
	{ {-34.19, 9.42, -5}, colorFill },
	{ {34.19, 9.42, -5}, colorFill },
	{ {34.19, 95.69, -5}, colorFill },
	{ {-34.19, 9.42, -5}, colorFill },
	{ {-34.19, 9.42, -5}, colorFill },
	{ {34.19, 95.69, -5}, colorFill },
	{ {-34.19, 95.69, -5}, colorFill },
	{ {-34.19, 9.42, -5}, colorFill },
	{ {-63.1, 38.34, -5}, colorFill },
	{ {-100, 0, -5}, colorFill },
}

local vertsStroke = {
	-- Alternate between the front and back, switch sides after each edge
	{ {0, -100, 5}, colorStroke },
	{ {100, 0, 5}, colorStroke },
	{ {100, 0, -5}, colorStroke },
	{ {63.1, 38.34, -5}, colorStroke },
	{ {63.1, 38.34, 5}, colorStroke },
	{ {34.19, 9.42, 5}, colorStroke },
	{ {34.19, 9.42, -5}, colorStroke },
	{ {34.19, 95.69, -5}, colorStroke },
	{ {34.19, 95.69, 5}, colorStroke },
	{ {-34.19, 95.69, 5}, colorStroke },
	{ {-34.19, 95.69, -5}, colorStroke },
	{ {-34.19, 9.42, -5}, colorStroke },
	{ {-34.19, 9.42, 5}, colorStroke },
	{ {-63.1, 38.34, 5}, colorStroke },
	{ {-63.1, 38.34, -5}, colorStroke },
	{ {-100, 0, -5}, colorStroke },
	{ {-100, 0, 5}, colorStroke },
	{ {0, -100, 5}, colorStroke },
	
	-- Second loop for the other lines
	{ {0, -100, -5}, colorStroke },
	{ {100, 0, -5}, colorStroke },
	{ {100, 0, 5}, colorStroke },
	{ {63.1, 38.34, 5}, colorStroke },
	{ {63.1, 38.34, -5}, colorStroke },
	{ {34.19, 9.42, -5}, colorStroke },
	{ {34.19, 9.42, 5}, colorStroke },
	{ {34.19, 95.69, 5}, colorStroke },
	{ {34.19, 95.69, -5}, colorStroke },
	{ {-34.19, 95.69, -5}, colorStroke },
	{ {-34.19, 95.69, 5}, colorStroke },
	{ {-34.19, 9.42, 5}, colorStroke },
	{ {-34.19, 9.42, -5}, colorStroke },
	{ {-63.1, 38.34, -5}, colorStroke },
	{ {-63.1, 38.34, 5}, colorStroke },
	{ {-100, 0, 5}, colorStroke },
	{ {-100, 0, -5}, colorStroke },
	{ {0, -100, -5}, colorStroke },
}

return Def.ActorFrame{
	OnCommand=function(self)
		self:spin():effectmagnitude(0,10,4)
		 -- The mode passed to us from LoadActor() defines out behavior
		if mode == 1 then -- Mode 1 = Gameplay (factor in the header when centering and zoom out slightly)
			self:y(32):zoom(1.3)
		else -- This is used on the title screen
			self:zoom(1.5)
		end
	end,
	OffCommand=function(self)
		self:smooth(0.5):diffusealpha(0)
	end,
	
	-- Background fill
	Def.ActorMultiVertex{
		OnCommand=function(self)
			self:SetDrawState{Mode="Triangles"}:SetVertices(vertsFill)
			if AllowThonk() then
				self:spin():effectmagnitude(0,-40,-16)
			end
		end,
	},
	
	-- Stroke
	Def.ActorMultiVertex{
		OnCommand=function(self)
			self:SetDrawState{Mode="LineStrip"}:SetVertices(vertsStroke)
			if AllowThonk() then
				self:spin():effectmagnitude(50,0,0)
			end
		end,
	},
}