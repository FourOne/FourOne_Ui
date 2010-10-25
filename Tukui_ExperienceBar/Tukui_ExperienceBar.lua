-- Config ----------------
--------------------------
--Bar Height and Width
local barHeight, barWidth = 19, Minimap:GetWidth()+4

--Where you want the fame to be anchored
--------AnchorPoint, AnchorTo, RelativePoint, xOffset, yOffset
local Anchor = { "TOP", Minimap, "BOTTOM", 0, -25 }

--Fonts
local showText = false -- Set to false to hide text
local font,fontsize,flags = TukuiCF["media"].uffont, 14, "OUTLINE"

-----------------------------------------------------------
-- Don't edit past here unless you know what your doing! --
-----------------------------------------------------------
-- Tables ----------------
--------------------------
local saftXPBar = {}

local FactionInfo = {
	[1] = {{ 170/255, 70/255,  70/255 }, "Hated", "FFaa4646"},
	[2] = {{ 170/255, 70/255,  70/255 }, "Hostile", "FFaa4646"},
	[3] = {{ 170/255, 70/255,  70/255 }, "Unfriendly", "FFaa4646"},
	[4] = {{ 200/255, 180/255, 100/255 }, "Neutral", "FFc8b464"},
	[5] = {{ 75/255,  175/255, 75/255 }, "Friendly", "FF4baf4b"},
	[6] = {{ 75/255,  175/255, 75/255 }, "Honored", "FF4baf4b"},
	[7] = {{ 75/255,  175/255, 75/255 }, "Revered", "FF4baf4b"},
	[8] = {{ 155/255,  255/255, 155/255 }, "Exalted","FF9bff9b"},
}
-- Functions -------------
--------------------------
local ShortValue = function(value)
	if value >= 1e6 then
		return ("%.0fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.0fk"):format(value / 1e3):gsub("%.?+([km])$", "%1")
	else
		return value
	end
end

function CommaValue(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function colorize(r)
	return FactionInfo[r][3]
end

function saftXPBar:Initialize()
	local frame = self.frame
	
	--Create Background and Border
	local backdrop = CreateFrame("Frame", "saftXP_Backdrop", frame)
	backdrop:SetHeight(barHeight)
	backdrop:SetWidth(barWidth)
	backdrop:SetPoint(unpack(Anchor))
	backdrop:SetBackdrop{
		bgFile = TukuiCF["media"].blank, tile = true, tileSize = TukuiDB.Scale(16),
		edgeFile = TukuiCF["media"].blank, edgeSize = TukuiDB.mult,
		insets = {left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult},
	}
	backdrop:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	backdrop:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
	
	backdrop:SetFrameLevel(0)
	
	frame.backdrop = backdrop
	
	overlay = backdrop:CreateTexture(nil, "BORDER", backdrop)
	overlay:ClearAllPoints()
	overlay:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 2, -2)
	overlay:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -2, 2)
	overlay:SetTexture(TukuiCF.media.normTex)
	overlay:SetVertexColor(.1,.1,.1)
	
	--Create XP Status Bar
	local xpBar = CreateFrame("StatusBar", "saftXP_Bar", frame, "TextStatusBar")
	xpBar:SetWidth(barWidth-4)
	xpBar:SetHeight(barHeight-4)
	xpBar:SetPoint("CENTER", backdrop,"CENTER", 0, 0)
	xpBar:SetStatusBarTexture(TukuiCF.media.normTex)
	xpBar:SetFrameLevel(2)
	frame.xpBar = xpBar
	
	--Create Rested XP Status Bar
	local restedxpBar = CreateFrame("StatusBar", "saftrestedXP_Bar", frame, "TextStatusBar")
	restedxpBar:SetWidth(barWidth-4)
	restedxpBar:SetHeight(barHeight-4)
	restedxpBar:SetPoint("CENTER", backdrop,"CENTER", 0, 0)
	restedxpBar:SetStatusBarTexture(TukuiCF.media.normTex)
	restedxpBar:SetFrameLevel(1)
	restedxpBar:Hide()
	frame.restedxpBar = restedxpBar
	
	--Create Reputation Status Bar(Only used if not max level)
	local repBar = CreateFrame("StatusBar", "saftRep_Bar", frame, "TextStatusBar")
	repBar:SetWidth(barWidth-4)
	repBar:SetHeight(1)
	repBar:SetPoint("TOP",xpBar,"BOTTOM", 0, -1)
	repBar:SetStatusBarTexture(TukuiCF.media.normTex)
	repBar:SetFrameLevel(1)
	repBar:Hide()
	frame.repBar = repBar
	
	--Create frame used for mouseover and dragging
	local mouseFrame = CreateFrame("Frame", "saftXP_dragFrame", frame)
	mouseFrame:SetAllPoints(backdrop)
	mouseFrame:SetFrameLevel(3)
	mouseFrame:EnableMouse(true)
	frame.mouseFrame = mouseFrame
	
	--Create XP Text
	if showText == true then
		local xpText = mouseFrame:CreateFontString("saftXP_Text", "OVERLAY")
		xpText:SetFont(font, fontsize, flags)
		xpText:SetPoint("CENTER", backdrop, "CENTER", 0, 0.5)

		frame.xpText = xpText
	end
	
	--Event handling
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterEvent("PLAYER_XP_UPDATE")
	frame:RegisterEvent("UPDATE_EXHAUSTION")
	frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	frame:RegisterEvent("UPDATE_FACTION")
    frame:SetScript("OnEvent", function() 
		self:ShowBar() 
    end)
end

-- Setup bar info
function saftXPBar:ShowBar()
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		local XP, maxXP = UnitXP("player"), UnitXPMax("player")
		local restXP = GetXPExhaustion()
		local percXP = floor(XP/maxXP*100)
		local str
		--Setup Text
		if self.frame.xpText then
			if restXP then
				str = format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", ShortValue(XP), ShortValue(maxXP), percXP, restXP/maxXP*100)
			else
				str = format("%s/%s (%s%%)", ShortValue(XP), ShortValue(maxXP), percXP)
			end
			self.frame.xpText:SetText(str)
		end
		--Setup Bar
		if GetXPExhaustion() then 
			if not self.frame.restedxpBar:IsShown() then
				self.frame.restedxpBar:Show()
			end
			self.frame.restedxpBar:SetStatusBarColor(0, .4, .8)
			self.frame.restedxpBar:SetMinMaxValues(min(0, XP), maxXP)
			self.frame.restedxpBar:SetValue(XP+restXP)
		else
			if self.frame.restedxpBar:IsShown() then
				self.frame.restedxpBar:Hide()
			end
		end
		
		self.frame.xpBar:SetStatusBarColor(.5, 0, .75)
		self.frame.xpBar:SetMinMaxValues(min(0, XP), maxXP)
		self.frame.xpBar:SetValue(XP)	

		if GetWatchedFactionInfo() then
			local name, rank, min, max, value = GetWatchedFactionInfo()
			if not self.frame.repBar:IsShown() then self.frame.repBar:Show() end
			self.frame.repBar:SetStatusBarColor(unpack(FactionInfo[rank][1]))
			self.frame.repBar:SetMinMaxValues(min, max)
			self.frame.repBar:SetValue(value)
			self.frame.xpBar:SetHeight(barHeight-6)
			self.frame.restedxpBar:SetHeight(barHeight-6)
		else
			if self.frame.repBar:IsShown() then self.frame.repBar:Hide() end
			self.frame.xpBar:SetHeight(barHeight-4)
			self.frame.restedxpBar:SetHeight(barHeight-4)
		end
		
		--Setup Exp Tooltip
		self.frame.mouseFrame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.frame.mouseFrame, "ANCHOR_BOTTOMLEFT", -3, barHeight)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(string.format('XP: %s/%s (%d%%)', CommaValue(XP), CommaValue(maxXP), (XP/maxXP)*100))
			GameTooltip:AddLine(string.format('Remaining: %s', CommaValue(maxXP-XP)))	
			if restXP then
				GameTooltip:AddLine(string.format('|cff0090ffRested: %s (%d%%)', CommaValue(restXP), restXP/maxXP*100))
			end
			if GetWatchedFactionInfo() then
				local name, rank, min, max, value = GetWatchedFactionInfo()
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(string.format('Reputation: %s', name))
				GameTooltip:AddLine(string.format('Standing: |c'..colorize(rank)..'%s|r', FactionInfo[rank][2]))
				GameTooltip:AddLine(string.format('Rep: %s/%s (%d%%)', CommaValue(value-min), CommaValue(max-min), (value-min)/(max-min)*100))
				GameTooltip:AddLine(string.format('Remaining: %s', CommaValue(max-value)))
			end
			GameTooltip:Show()
		end)
		self.frame.mouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
		
		--Send experience info in chat
		self.frame.mouseFrame:SetScript("OnMouseDown", function()
			if IsShiftKeyDown() then
				if GetNumRaidMembers() > 0 then
					SendChatMessage("I'm currently at "..CommaValue(XP).."/"..CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.","RAID")
				elseif GetNumPartyMembers() > 0 then
					SendChatMessage("I'm currently at "..CommaValue(XP).."/"..CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.","PARTY")
				end
			end
			if IsControlKeyDown() then
				local activeChat = ChatFrame1EditBox:GetAttribute("chatType")
				if activeChat == "WHISPER" then 
					local target = GetChannelName(ChatFrame1EditBox:GetAttribute("channelTarget"))
				end
				SendChatMessage("I'm currently at "..CommaValue(XP).."/"..CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.",activeChat, nil, target or nil)
			end
		end)
	else
		if GetWatchedFactionInfo() then
			local name, rank, min, max, value = GetWatchedFactionInfo()
			local str
			--Setup Text
			if self.frame.xpText then
				str = format("%d / %d (%d%%)", value-min, max-min, (value-min)/(max-min)*100)
				self.frame.xpText:SetText(str)
			end
			--Setup Bar
			self.frame.xpBar:SetStatusBarColor(unpack(FactionInfo[rank][1]))
			self.frame.xpBar:SetMinMaxValues(min, max)
			self.frame.xpBar:SetValue(value)
			--Setup Exp Tooltip
			self.frame.mouseFrame:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self.frame.mouseFrame, "ANCHOR_BOTTOMLEFT", -3, barHeight)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(string.format('Reputation: %s', name))
				GameTooltip:AddLine(string.format('Standing: |c'..colorize(rank)..'%s|r', FactionInfo[rank][2]))
				GameTooltip:AddLine(string.format('Rep: %s/%s (%d%%)', CommaValue(value-min), CommaValue(max-min), (value-min)/(max-min)*100))
				GameTooltip:AddLine(string.format('Remaining: %s', CommaValue(max-value)))
				GameTooltip:Show()
			end)
			self.frame.mouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
			
			--Send reputation info in chat
			self.frame.mouseFrame:SetScript("OnMouseDown", function()
				if IsShiftKeyDown() then
					if GetNumRaidMembers() > 0 then
						SendChatMessage("I'm currently "..FactionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).."("..floor((((value-min)/(max-min))*100))..").","RAID")
					elseif GetNumPartyMembers() > 0 then
						SendChatMessage("I'm currently "..FactionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).."("..floor((((value-min)/(max-min))*100))..").","PARTY")
					end
				end
			end)

			if not self.frame:IsShown() then self.frame:Show() end
		else
			self.frame:Hide()
		end
	end
end

-- Event Stuff -----------
--------------------------
local frame = CreateFrame("Frame",nil,UIParent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	saftXPBar:Initialize()
	saftXPBar:ShowBar()
end)

saftXPBar.frame = frame