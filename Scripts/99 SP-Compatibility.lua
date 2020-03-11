-- Lua 5.3 (and thus SM5.3) isn't identical to previous Lua5 versions. Use this file to
-- write hacks compatible with multiple Lua versions.  - slaugaus

-- In 5.3, math.log10() was removed in favor of math.log(x, base)
-- This is only used in ScreenGameplay underlay\PerPlayer\StepStatistics\JudgmentNumbers.lua
function log10Hack(x)
	if ProductVersion():match("5.3") then return math.log(x, 10) end
	return math.log10(x)
end