------------------------------------------------------------
-- global theme colors

--- header/footer light/dark


-- pro tip: on linux to find out where these are used, cd to your themes folder and grep -rnw 'Simply-Potato-SM5' -e '#'
header_light = {0.4,0.4,0.4,1}
header_dark = {0,0,0,0.9}


color_black = color("#000000")

--default #283239, used for folders (closed) and nothing else
color_slate = color("#283239")

--default #4c565d, used for folders (open) and nothing else
color_openfolder = color("#4c565d")

--default #1E282F, used for step info box background and results
color_slate2 = color("#1E282F")

--default #192025, used for the pips on the song difficulty chart
color_slate3 = color("#182025")

--default (10/255, 20/255, 27/255, 1) -- #0a141b, no clue why. used for songs and not much else?
color_slate4 = color("#0a141b")

--default (0, 10/255, 17/255, 0.5) -- #000a11, used exclusively between songs, because it's very important to have near-black and not black
color_betweensongs = {0, 0.1, 0.12, 0.4}

-- default #101519, dark color behind judgement graph/percentage
color_slate5 = color("#101519")

--set a diffuse to this if you don't know what it does and you'll know when your eyeballs go on vacation
color_test = color("#ff00ff")


------------------------------------------------------------
-- global functions related to colors in Simply Love

function GetHexColor( n )
	-- if we were passed nil or a non-number, return white
	if n == nil or type(n) ~= "number" then return Color.White end

	-- use the number passed in to lookup a color in the SL.Colors
	-- ensure the index is kept in bounds via modulo operation
	local clr = ((n - 1) % #SL.Colors) + 1
	if SL.Colors[clr] then
		return color(SL.Colors[clr])
	end

	return Color.White
end

-- convenience function to return the current color from SL.Colors
function GetCurrentColor()
	return GetHexColor( SL.Global.ActiveColorIndex )
end

function PlayerColor( pn )
	if pn == PLAYER_1 then return GetHexColor(SL.Global.ActiveColorIndex+1) end
	if pn == PLAYER_2 then return GetHexColor(SL.Global.ActiveColorIndex-1) end
	return Color.White
end

function DifficultyColor( difficulty )
	if (difficulty == nil or difficulty == "Difficulty_Edit") then return color("#B4B7BA") end

	local index = GetDifficultyIndex(difficulty)
	local clr = SL.Global.ActiveColorIndex + (index-2)
	return GetHexColor(clr)
end

function SortMenuColor(kind)
	if kind == "SortBy" then
		return color("#777747")
	elseif kind == "ChangeStyle" then
		return color("#7C4A4A")
	elseif kind == "ChangeMode" then
		return color("#7F634C")
	elseif kind == "FeelingSalty" then --Input tester lol
		return color("#4C7747")
	else
		return color("#888888")
	end
end
