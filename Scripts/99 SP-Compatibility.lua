-- Lua 5.3 (and thus SM5.3) isn't identical to previous Lua5 versions. Use this file to
-- write hacks compatible with multiple Lua versions.  - slaugaus

-- In 5.3, math.log10() was removed in favor of math.log(x, base)
-- This is only used in ScreenGameplay underlay\PerPlayer\StepStatistics\JudgmentNumbers.lua
-- Now free of version checking (it won't have to be rewritten for SM5.4)
function log10Hack(x)
	if math.log10 == nil then return math.log(x, 10) end
	return math.log10(x)
end

-- We're gonna be using this a lot.
-- It's not the BEST solution (I'll have to rewrite it if 5.4 happens),
-- but it'll have to do for now.  - slaugaus
function IsSM53()
	return not not ProductVersion():match("5.3") -- (not not = cast to bool)
end