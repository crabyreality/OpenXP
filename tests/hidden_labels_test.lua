-- A "#completewith <label>" step ends when the guide reaches that label. If
-- the labelled step is for another class ("step << Paladin"), the label goes
-- to the next step this character gets, so the step still ends (GitHub #43:
-- the Tirisfal sewers arrow stayed on screen for every class but Paladin).
local ROOT = ...

local f = assert(io.open(ROOT .. "/GuideWindow.lua", "r"))
local src = f:read("*a")
f:close()
local first = src:find("function addon.ProcessGuideTable(guide)", 1, true)
local last = src:find("function addon:FetchGuide(", 1, true)
assert(first and last, "ProcessGuideTable not found")

local addon = {
    settings = {ReplaceColors = function() end},
    comms = {PrettyDebug = function() end, PrettyPrint = function() end},
    labels = {},
}
local env = setmetatable({
    addon = addon, tinsert = table.insert,
    L = function(s) return s end,
    CopyTable = function(t) local c = {} for k, v in pairs(t) do c[k] = v end return c end,
}, {__index = _G})
local chunk = assert(load("local addon = ...\n" .. src:sub(first, last - 1), "ProcessGuideTable", "t", env))
chunk(addon)

addon.IsStepShown = function(step) return not step.paladin end

local failures = 0
local function check(ok, msg)
    print((ok and "ok   " or "FAIL ") .. msg)
    if not ok then failures = failures + 1 end
end

local guide = {name = "t", group = "g", steps = {
    {text = "sewers", completewith = "UCHome", elements = {{}}},
    {text = "mage stuff", elements = {{}}},
    {text = "paladin hearth", label = "UCHome", paladin = true, elements = {{}}},
    {text = "logout skip", label = "LogoutSkip1", elements = {}},
    {text = "exit undercity", elements = {{}}},
}}
local g = addon.ProcessGuideTable(guide)
check(#g.steps == 4, "the Paladin step is left out for a Rogue")
local s = g.steps[3]
check(s.text == "logout skip", "third step is the one after the Paladin step")
check(s.hiddenLabels and s.hiddenLabels[1] == "UCHome", "UCHome goes to the next step the Rogue gets")
check(g.steps[4].hiddenLabels == nil, "only that step gets it")

-- Reloading the same guide doesn't keep labels from the last load
addon.IsStepShown = function() return true end
g = addon.ProcessGuideTable(guide)
check(g.steps[4].hiddenLabels == nil, "a Paladin load has no handed-over labels")
check(g.steps[3].label == "UCHome", "a Paladin still gets the real UCHome step")

if failures > 0 then error(failures .. " failure(s)") end
