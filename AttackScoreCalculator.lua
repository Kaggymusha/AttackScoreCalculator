-- Gets the values of simple attributes like agility, strength etc.
local function GetNumber(line, attribute)
    if not (string.find(line, attribute) == nil) then
        local number = string.match(line, "%d+")
        return tonumber(number)
    end
    return nil
end

-- Gets the values of % hit and % crit that needs to parsed a bit more
local function GetEquipBonuses(line, attribute)
    -- string.find(line, "Equip") is to avoid set bonuses. I might implement this in the future.
    if (string.find(line, "Equip") and string.find(line, attribute)) then
        local number = string.match(line, "%d+")
        return tonumber(number)
    end
    return nil
end

-- This function returns the player class (rogue = 4) to avoid players getting numbers on other classes.
local function GetPlayerClass()
    local localizedClass, englishClass, classIndex = UnitClass("player");
    return classIndex;
end

-- This function collects all of the attributes on a tooltip and converts it into raw ap
GetAttributes = function(tooltip, itemLink_)
    local itemType = select(6, GetItemInfo(itemLink_));
    if (itemType == "Armor") then
        local tooltipName = tooltip:GetName()
        local attrs = {
            agi = 0,
            str = 0,
            crit = 0,
            hit = 0,
            rawAp = 0
        }
        for i = 1, tooltip:NumLines() do
            local line = _G[tooltipName .. "TextLeft" .. i]:GetText() or ""

            attrs.agi = attrs.agi + (GetNumber(line, "Agility") or 0)
            attrs.str = attrs.str + (GetNumber(line, "Strength") or 0)
            attrs.crit = attrs.crit + (GetEquipBonuses(line, "critical") or 0)
            attrs.hit = attrs.hit + (GetEquipBonuses(line, "hit") or 0)
            attrs.rawAp = attrs.rawAp + (GetEquipBonuses(line, "Attack Power") or 0)

        end
        local totalAp = attrs.agi * ( 1 + 23 / 29) + attrs.str + attrs.crit * 23 + attrs.hit * 18 + attrs.rawAp;
        local formattedAp = string.format("%.2f", totalAp);
        return formattedAp;
    else
        -- A simple return value for a check in the hookscript
        return -1;
    end
end

-- Creating a tooltip frame
CreateFrame( "GameTooltip", "ScanningTooltip", nil, "GameTooltipTemplate" );
local ap = 0;
-- Creating custom script that will run when a tooltip is shown in-game
GameTooltip:HookScript("OnTooltipSetItem",
function(self)
    local class = GetPlayerClass();
    if (class == 4) then
        local itemName, itemLink = self:GetItem();
        ap = GetAttributes(self, itemLink);
        if not (ap == -1) then
            self:AddLine("Total power score: " .. ap);
        end
    end
end)
