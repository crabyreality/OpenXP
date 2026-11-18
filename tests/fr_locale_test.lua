local root = ...
local messages = {}
function GetLocale() return "frFR" end
function LibStub(name)
    if name == "AceAddon-3.0" then
        return { NewAddon = function(_, addon) return addon end }
    end
    assert(name == "AceLocale-3.0")
    return { NewLocale = function() return messages end, GetLocale = function() return messages end }
end
format = string.format
ACCEPT = "Accepter"

local addon = {}
for _, file in ipairs({
    "locale/enUS.lua", "locale/frFR.lua", "locale/frFR_guide.lua", "locale/NPCnames.lua", "Locale.lua",
}) do
    assert(loadfile(root .. "/" .. file))("OpenXP", addon)
end

local locale = addon.locale
local rudra = "Rudra Amberstill"
assert(locale.Get("You get this quest at this step") == "Vous obtenez cette quête à cette étape.")
assert(addon.GetCreatureName(rudra) == "Rudra Distillambre")

addon.game = "FOREVER"
assert(addon.GetCreatureName(rudra) == rudra)

local names = { [1265] = rudra, [1376] = "Beldin Steelgrill", [233] = "Saldean le fermier" }
LibQuestieDB = {
    Npc = { name = function(id) return names[id] end },
    Quest = { name = function(id) if id == 9 then return "Titre de QuestieDB" end end },
}
local function TalkTo(name)
    return "|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_" .. name .. "|r"
end
for _, name in ipairs({ rudra, "Beldin Steelgrill", "Saldean le fermier" }) do
    local original = name == "Saldean le fermier" and "Farmer Saldean" or name
    assert(addon.GetCreatureName(original) == name)
    assert(locale.GuideText(TalkTo(original)):find("Parlez à |cRXP_FRIENDLY_" .. name .. "|r", 1, true))
end
assert(addon.GetCreatureName("Farmer Saldean::233") == "Saldean le fermier::233")
assert(addon.GetCreatureName("Unknown NPC") == "Unknown NPC")
assert(locale.GuideQuestName(9) == "Titre de QuestieDB")
C_QuestLog = { GetTitleForQuestID = function(id) if id == 9 then return "Titre du journal" end end }
assert(locale.GuideQuestName(9) == "Titre du journal")
assert(locale.GuideQuestName(36) == "Le ragoût de la marche de l’Ouest")

print("French locale tests passed")
