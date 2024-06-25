
local function GetNumber(line, attribute)
    if not (string.find(line, attribute) == nil) then
        local number = string.match(line, "%d+")
        return tonumber(number)
    end
    return nil
end

local function GetEquipBonuses(line, attribute)
    if (string.find(line, "Equip") and string.find(line, attribute)) then
        local number = string.match(line, "%d+")
        return tonumber(number)
    end
    return nil
end

GetAttributes = function(tooltip, msg)
    local itemType = select(6, GetItemInfo(msg));
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
        return -1;
    end
end

CreateFrame( "GameTooltip", "ScanningTooltip", nil, "GameTooltipTemplate" );
ScanningTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
ScanningTooltip:AddFontStrings(ScanningTooltip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ), ScanningTooltip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ) );

local ap = 0;
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    local itemName, itemLink = self:GetItem();
    ap = GetAttributes(self, itemLink);
    if not (ap == -1) then
        self:AddLine("Total power score: " .. ap);
    end
end)
