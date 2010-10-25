if not TukuiCF["unitframes"].enable == true then return end

------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local db = TukuiCF["unitframes"]
local font1 = TukuiCF["media"].uffont
local font2 = TukuiCF["media"].font
local normTex = TukuiCF["media"].normTex
local glowTex = TukuiCF["media"].glowTex
local bubbleTex = TukuiCF["media"].bubbleTex

local backdrop = {
	bgFile = TukuiCF["media"].blank,
	insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult},
}

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colors
	self.colors = TukuiDB.oUF_colors
	
	-- register click
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- menu? lol
	self.menu = TukuiDB.SpawnMenu

	-- backdrop for every units
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)

	-- border for all frames
	local FrameBorder = CreateFrame("Frame", nil, self)
	FrameBorder:SetPoint("TOPLEFT", self, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	TukuiDB.SetTemplate(FrameBorder)
	FrameBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
	FrameBorder:SetFrameLevel(2)
	self.FrameBorder = FrameBorder
	
	------------------------------------------------------------------------
	--	Player and Target units layout (mostly mirror'd)
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(39))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
				
		-- health bar background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
	
		health.value = TukuiDB.SetFontString(health, font1, 14, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
		health.PostUpdate = TukuiDB.PostUpdateHealth
		health.value:SetShadowColor(0, 0, 0)
		health.value:SetShadowOffset(1.25, -1.25)
				
		self.Health = health
		self.Health.bg = healthBG

		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end

		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		power:SetStatusBarTexture(normTex)
		
		-- border between health and power
		self.HealthBorder = CreateFrame("Frame", nil, power)
		self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, TukuiDB.mult)
		TukuiDB.SetTemplate(self.HealthBorder)
		self.HealthBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = TukuiDB.SetFontString(health, font1, 14, "THINOUTLINE")
		power.value:SetPoint("LEFT", health, "LEFT", TukuiDB.Scale(4), TukuiDB.Scale(1))
		power.value:SetShadowColor(0, 0, 0)
		power.value:SetShadowOffset(1.25, -1.25)
		power.PreUpdate = TukuiDB.PreUpdatePower
		power.PostUpdate = TukuiDB.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		if db.showsmooth == true then
			power.Smooth = true
		end
		
		if db.unicolor == true then
			power.colorTapping = true
			power.colorClass = true
			powerBG.multiplier = 0.1				
		else
			power.colorPower = true
		end

		-- portraits
		if (db.charportrait == true) then
			local PFrame = CreateFrame("Frame", nil, self)
			local pnt
			if unit == "player" then
				PFrame:SetPoint('RIGHT', self,'LEFT', TukuiDB.Scale(-6), 0)
				pnt = "LEFT"
			else
				PFrame:SetPoint('LEFT', self,'RIGHT', TukuiDB.Scale(6), 0)
				pnt = "RIGHT"
			end
			PFrame:SetWidth(44)
			PFrame:SetHeight(49)
			TukuiDB.SetTemplate(PFrame)
			PFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
			self.PFrame = PFrame
			
			local splitbartop = CreateFrame("Frame", nil, PFrame)
			TukuiDB.CreatePanel(splitbartop, (PFrame:GetWidth() * 1.5), TukuiDB.Scale(2), "CENTER", self, pnt, 0, 15)
			splitbartop:SetFrameLevel(PFrame:GetFrameLevel() - 1)
			
			local splitbarbottom = CreateFrame("Frame", nil, PFrame)
			TukuiDB.CreatePanel(splitbarbottom, (PFrame:GetWidth() * 1.5), TukuiDB.Scale(2), "CENTER", self, pnt, 0, -15)
			splitbarbottom:SetFrameLevel(PFrame:GetFrameLevel() - 1)
			
			local portrait = CreateFrame("PlayerModel", nil, PFrame)
			portrait:SetFrameLevel(2)
			if unit == "target" then
				portrait:SetPoint('TOPLEFT', PFrame, 'TOPLEFT', TukuiDB.mult*2.2, -TukuiDB.mult*2)
			else
				portrait:SetPoint('TOPLEFT', PFrame, 'TOPLEFT', TukuiDB.mult*2, -TukuiDB.mult*2)
			end
			portrait:SetPoint('BOTTOMRIGHT', PFrame, 'BOTTOMRIGHT', -TukuiDB.mult*2, TukuiDB.mult*2)			
			table.insert(self.__elements, TukuiDB.HidePortrait)
			self.Portrait = portrait
		end

		if (unit == "player") then
			-- combat icon
			local Combat = health:CreateTexture(nil, "OVERLAY")
			Combat:SetHeight(TukuiDB.Scale(19))
			Combat:SetWidth(TukuiDB.Scale(19))
			Combat:SetPoint("CENTER", health, "CENTER", 0, 1)
			Combat:SetVertexColor(0.69, 0.31, 0.31)
			self.Combat = Combat

			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "FlashInfo", self)
			FlashInfo:SetScript("OnUpdate", TukuiDB.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetToplevel(true)
			FlashInfo:SetAllPoints(panel)
			FlashInfo.ManaLevel = TukuiDB.SetFontString(FlashInfo, font1, 14, "THINOUTLINE")
			FlashInfo.ManaLevel:SetPoint("CENTER", health, "CENTER", 0, 1)
			self.FlashInfo = FlashInfo
			
			-- pvp status text
			local status = TukuiDB.SetFontString(health, font1, 14, "THINOUTLINE")
			status:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
			status:SetTextColor(0.69, 0.31, 0.31, 0)
			self.Status = status
			self:Tag(status, "[pvp]")
			
			-- leader icon
			local Leader = health:CreateTexture(nil, "OVERLAY")
			Leader:SetHeight(TukuiDB.Scale(14))
			Leader:SetWidth(TukuiDB.Scale(14))
			Leader:SetPoint("TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(8))
			self.Leader = Leader
			
			-- master looter
			local MasterLooter = health:CreateTexture(nil, "OVERLAY")
			MasterLooter:SetHeight(TukuiDB.Scale(14))
			MasterLooter:SetWidth(TukuiDB.Scale(14))
			self.MasterLooter = MasterLooter
			self:RegisterEvent("PARTY_LEADER_CHANGED", TukuiDB.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", TukuiDB.MLAnchorUpdate)
						
			-- the threat bar on info left panel ? :P
			if (db.showthreat == true) then
				local ThreatBar = CreateFrame("StatusBar", self:GetName()..'_ThreatBar', TukuiInfoLeft)
				ThreatBar:SetFrameLevel(5)
				ThreatBar:SetPoint("TOPLEFT", TukuiInfoLeft, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				ThreatBar:SetPoint("BOTTOMRIGHT", TukuiInfoLeft, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			  
				ThreatBar:SetStatusBarTexture(normTex)
				ThreatBar:GetStatusBarTexture():SetHorizTile(false)
				ThreatBar:SetBackdrop(backdrop)
				ThreatBar:SetBackdropColor(0, 0, 0, 0)
		   
				ThreatBar.Text = TukuiDB.SetFontString(ThreatBar, font1, 14)
				ThreatBar.Text:SetPoint("RIGHT", ThreatBar, "RIGHT", TukuiDB.Scale(-30), 0)
		
				ThreatBar.Title = TukuiDB.SetFontString(ThreatBar, font1, 14)
				ThreatBar.Title:SetText(tukuilocal.unitframes_ouf_threattext)
				ThreatBar.Title:SetPoint("LEFT", ThreatBar, "LEFT", TukuiDB.Scale(30), 0)
					  
				ThreatBar.bg = ThreatBar:CreateTexture(nil, 'BORDER')
				ThreatBar.bg:SetAllPoints(ThreatBar)
				ThreatBar.bg:SetTexture(0.1,0.1,0.1)
		   
				ThreatBar.useRawThreat = false
				self.ThreatBar = ThreatBar
			end
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if TukuiDB.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() TukuiDB.UpdateDruidMana(self) end)
				local DruidMana = TukuiDB.SetFontString(health, font1, 14, "THINOUTLINE")
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
				
				local eclipseBar = CreateFrame('Frame', nil, self)
				--eclipseBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(8))
				eclipseBar:SetPoint("CENTER", UIParent, "CENTER", 0, -170)
				eclipseBar:SetSize(TukuiDB.Scale(246), TukuiDB.Scale(8))
				TukuiDB.SetTemplate(eclipseBar)
				eclipseBar:SetBackdropBorderColor(0,0,0,0)
				eclipseBar:SetScript("OnShow", function() TukuiDB.EclipseDisplay(self, false) end)
				eclipseBar:SetScript("OnUpdate", function() TukuiDB.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				eclipseBar:SetScript("OnHide", function() TukuiDB.EclipseDisplay(self, false) end)
				
				eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
				TukuiDB.SetTemplate(eclipseBar.FrameBackdrop)
				eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)
				
				local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
				lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
				lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				lunarBar:SetStatusBarTexture(normTex)
				lunarBar:SetStatusBarColor(.30, .52, .90)
				eclipseBar.LunarBar = lunarBar

				local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
				solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
				solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				solarBar:SetStatusBarTexture(normTex)
				solarBar:SetStatusBarColor(.80, .82,  .60)
				eclipseBar.SolarBar = solarBar

				local eclipseBarText = solarBar:CreateFontString(nil, 'OVERLAY')
				eclipseBarText:SetPoint('TOP', panel)
				eclipseBarText:SetPoint('BOTTOM', panel)
				eclipseBarText:SetFont(font1, 12)
				eclipseBar.Text = eclipseBarText

				self.EclipseBar = eclipseBar
			end

			-- set holy power bar or shard bar
			if (TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "PALADIN") then
	
				local bars = CreateFrame("Frame", nil, self)
				bars:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(8))
				bars:SetWidth(TukuiDB.Scale(246))
				bars:SetHeight(TukuiDB.Scale(8))
				TukuiDB.SetTemplate(bars)
				bars:SetBackdropBorderColor(0,0,0,0)
				
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
					bars[i]:SetHeight(TukuiDB.Scale(8))
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					
					if TukuiDB.myclass == "WARLOCK" then
						bars[i]:SetStatusBarColor(255/255,101/255,101/255)
						bars[i].bg:SetTexture(255/255,101/255,101/255)
					elseif TukuiDB.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
					if i == 1 then
						bars[i]:SetPoint("LEFT", bars)
						bars[i]:SetWidth(TukuiDB.Scale(80)) -- setting SetWidth here just to fit fit 250 perfectly
						bars[i].bg:SetAllPoints(bars[i])
					else
						bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", TukuiDB.Scale(1), 0)
						bars[i]:SetWidth(TukuiDB.Scale(82)) -- setting SetWidth here just to fit fit 250 perfectly
						bars[i].bg:SetAllPoints(bars[i])
					end
					
					bars[i].bg:SetTexture(normTex)					
					bars[i].bg:SetAlpha(.15)
				end
				
				bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
				TukuiDB.SetTemplate(bars.FrameBackdrop)
				bars.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
				
				if TukuiDB.myclass == "WARLOCK" then
					bars.Override = TukuiDB.UpdateShards				
					self.SoulShards = bars
				elseif TukuiDB.myclass == "PALADIN" then
					bars.Override = TukuiDB.UpdateHoly
					self.HolyPower = bars
				end
			end

			-- deathknight runes
			if TukuiDB.myclass == "DEATHKNIGHT" and db.runebar == true then
				
				local Runes = CreateFrame("Frame", nil, self)
				Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(8))
				Runes:SetHeight(TukuiDB.Scale(8))
				Runes:SetWidth(TukuiDB.Scale(246))
				Runes:SetBackdrop(backdrop)
				Runes:SetBackdropColor(0, 0, 0)

				for i = 1, 6 do
					Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
					Runes[i]:SetHeight(TukuiDB.Scale(8))
					Runes[i]:SetWidth(TukuiDB.Scale(241) / 6)
					if (i == 1) then
						Runes[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(8))
					else
						Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", TukuiDB.Scale(1), 0)
					end
					Runes[i]:SetStatusBarTexture(normTex)
					Runes[i]:GetStatusBarTexture():SetHorizTile(false)
				end
				
				Runes.FrameBackdrop = CreateFrame("Frame", nil, Runes)
				TukuiDB.SetTemplate(Runes.FrameBackdrop)
				Runes.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				Runes.FrameBackdrop:SetFrameLevel(Runes:GetFrameLevel() - 1)
				self.Runes = Runes
			end
			
			-- shaman totem bar
			if TukuiDB.myclass == "SHAMAN" and db.totemtimer == true then
				
				local TotemBar = {}
				TotemBar.Destroy = true
				for i = 1, 4 do
					TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
					if (i == 1) then
					   TotemBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(8))
					else
					   TotemBar[i]:SetPoint("TOPLEFT", TotemBar[i-1], "TOPRIGHT", TukuiDB.Scale(1), 0)
					end
					TotemBar[i]:SetStatusBarTexture(normTex)
					TotemBar[i]:SetHeight(TukuiDB.Scale(8))
					TotemBar[i]:SetWidth(TukuiDB.Scale(243) / 4)
					TotemBar[i]:SetBackdrop(backdrop)
					TotemBar[i]:SetBackdropColor(0, 0, 0)
					TotemBar[i]:SetMinMaxValues(0, 1)

					TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
					TotemBar[i].bg:SetAllPoints(TotemBar[i])
					TotemBar[i].bg:SetTexture(normTex)
					TotemBar[i].bg.multiplier = 0.3
					
					TotemBar[i].FrameBackdrop = CreateFrame("Frame", nil, TotemBar[i])
					TukuiDB.SetTemplate(TotemBar[i].FrameBackdrop)
					TotemBar[i].FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
					TotemBar[i].FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
					TotemBar[i].FrameBackdrop:SetFrameLevel(TotemBar[i]:GetFrameLevel() - 1)
				end
					
				self.TotemBar = TotemBar
			end

			-- script for pvp status and low mana
			self:SetScript("OnEnter", function(self) 
				FlashInfo.ManaLevel:Hide() status:SetAlpha(1) UnitFrame_OnEnter(self) 
			end)
			self:SetScript("OnLeave", function(self) 
				FlashInfo.ManaLevel:Show() status:SetAlpha(0) UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("LEFT", health, "LEFT", 0, TukuiDB.Scale(1))
			Name:SetJustifyH("LEFT")
			Name:SetFont(font1, 14, "THINOUTLINE")
			Name:SetShadowColor(0, 0, 0)
			Name:SetShadowOffset(1.25, -1.25)

			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
			self.Name = Name

			-- combo points on target
			local CPoints = {}
			CPoints.unit = PlayerFrame.unit
			for i = 1, 5 do
				CPoints[i] = health:CreateTexture(nil, "OVERLAY")
				CPoints[i]:SetHeight(TukuiDB.Scale(12))
				CPoints[i]:SetWidth(TukuiDB.Scale(12))
				CPoints[i]:SetTexture(bubbleTex)
				if i == 1 then
					if TukuiDB.lowversion then
						CPoints[i]:SetPoint("TOPRIGHT", TukuiDB.Scale(15), TukuiDB.Scale(1.5))
					else
						CPoints[i]:SetPoint("TOPLEFT", TukuiDB.Scale(-15), TukuiDB.Scale(1.5))
					end
					CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
				else
					CPoints[i]:SetPoint("TOP", CPoints[i-1], "BOTTOM", TukuiDB.Scale(1))
				end
			end
			CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
			CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
			CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
			CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
			self.CPoints = CPoints
			self:RegisterEvent("UNIT_COMBO_POINTS", TukuiDB.UpdateCPoints)
		end

		if (unit == "target" and db.targetauras) or (unit == "player" and db.playerauras) then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			if (TukuiDB.myclass == "SHAMAN" or TukuiDB.myclass == "DEATHKNIGHT" or TukuiDB.myclass == "PALADIN" or TukuiDB.myclass == "WARLOCK") and (db.playerauras) and (unit == "player") then
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 48)
			else
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 32)
			end
			
			buffs:SetHeight(26)
			buffs:SetWidth(252)
			buffs.size = 26
			buffs.num = 9
			
			debuffs:SetHeight(26)
			debuffs:SetWidth(252)
			debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", -2, 2)
			debuffs.size = 26
			debuffs.num = 27
						
			buffs.spacing = 2
			buffs.initialAnchor = 'TOPLEFT'
			buffs.PostCreateIcon = TukuiDB.PostCreateAura
			buffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Buffs = buffs	
						
			debuffs.spacing = 2
			debuffs.initialAnchor = 'TOPRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
		end
		
		-- cast bar for player and target
		if (db.unitcastbar == true) then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetHeight(TukuiDB.Scale(20))
			castbar:SetWidth(TukuiDB.Scale(240))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			if unit == "player" then
				castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 280)
			elseif unit == "target" then
				castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 312)
			end
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			TukuiDB.SetTemplate(castbar.bg)
			castbar.bg:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar.time = TukuiDB.SetFontString(castbar, font1, 14)
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = CustomCastTimeText

			castbar.Text = TukuiDB.SetFontString(castbar, font1, 14)
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", TukuiDB.Scale(4), TukuiDB.Scale(1))
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomTimeText = TukuiDB.CustomCastTimeText
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.CheckCast
			castbar.PostChannelStart = TukuiDB.CheckChannel
			
			if db.cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(TukuiDB.Scale(26))
				castbar.button:SetWidth(TukuiDB.Scale(26))
				TukuiDB.SetTemplate(castbar.button)
				TukuiDB.CreateShadow(castbar.button)

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
				if unit == "player" then
					castbar.button:SetPoint("BOTTOM", 0, -40)
				elseif unit == "target" then
					castbar.button:SetPoint("TOP", 0, 40)					
				end
			end
			
			-- cast bar latency on player
			if unit == "player" and db.cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end
					
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		if db.healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetWidth(246)
			mhpb:SetStatusBarTexture(normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			mhpb:SetMinMaxValues(0,1)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetWidth(246)
			ohpb:SetStatusBarTexture(normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		-- player aggro
		if db.playeraggro == true then
			table.insert(self.__elements, TukuiDB.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
		end
	end
	
	------------------------------------------------------------------------
	--	Target of Target unit layout
	------------------------------------------------------------------------
	
	if (unit == "targettarget") then
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(24))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true			
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		power:SetStatusBarTexture(normTex)
		
		-- border between health and power
		self.HealthBorder = CreateFrame("Frame", nil, power)
		self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, TukuiDB.mult)
		TukuiDB.SetTemplate(self.HealthBorder)
		self.HealthBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
		
		power.frequentUpdates = true
		power.colorPower = true
		if db.showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
		Name:SetFont(font1, 12, "THINOUTLINE")
		Name:SetJustifyH("CENTER")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if db.totdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight(20)
			debuffs:SetWidth(127)
			debuffs.size = 20
			debuffs.spacing = 2
			debuffs.num = 6

			debuffs:SetPoint("TOPLEFT", health, "TOPLEFT", -2.5, 26)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
		end
	end
	
	------------------------------------------------------------------------
	--	Pet unit layout
	------------------------------------------------------------------------
	
	if (unit == "pet") then
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(24))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
				
		self.Health = health
		self.Health.bg = healthBG
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true	
			health.colorClass = true
			health.colorReaction = true	
			if TukuiDB.myclass == "HUNTER" then
				health.colorHappiness = true
			end
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		power:SetStatusBarTexture(normTex)
		
		-- border between health and power
		self.HealthBorder = CreateFrame("Frame", nil, power)
		self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, TukuiDB.mult)
		TukuiDB.SetTemplate(self.HealthBorder)
		self.HealthBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
		
		power.frequentUpdates = true
		power.colorPower = true
		if db.showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
				
		self.Power = power
		self.Power.bg = powerBG
				
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
		Name:SetFont(font1, 12, "THINOUTLINE")
		Name:SetJustifyH("CENTER")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level]')
		self.Name = Name
		
		-- update pet name, this should fix "UNKNOWN" pet names on pet unit.
		self:RegisterEvent("UNIT_PET", TukuiDB.UpdatePetInfo)
	end


	------------------------------------------------------------------------
	--	Focus unit layout
	------------------------------------------------------------------------
	
	if (unit == "focus") then
		
		-- create health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetPoint("TOPLEFT")
		health:SetPoint("BOTTOMRIGHT")
		health:SetStatusBarTexture(normTex)
		health:GetStatusBarTexture():SetHorizTile(false)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		health.value = TukuiDB.SetFontString(health, font1, 14, "OUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-4), 0)
		health.PostUpdate = TukuiDB.PostUpdateHealth
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("LEFT", health, "LEFT", TukuiDB.Scale(4), 0)
		Name:SetJustifyH("LEFT")
		Name:SetFont(font1, 14, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
		self.Name = Name

		-- create focus debuff feature
		if db.focusdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs:SetHeight(26)
			debuffs:SetWidth(TukuiCF["panels"].tinfowidth - 10)
			debuffs.size = 26
			debuffs.spacing = 2
			debuffs.num = 40
						
			debuffs:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 38)
			debuffs.initialAnchor = "TOPRIGHT"
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
		end
		
		-- focus cast bar in the center of the screen
		if db.unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetHeight(TukuiDB.Scale(20))
			castbar:SetWidth(TukuiDB.Scale(240))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 250)		
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			TukuiDB.SetTemplate(castbar.bg)
			castbar.bg:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar.time = TukuiDB.SetFontString(castbar, font1, 14)
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", TukuiDB.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = CustomCastTimeText

			castbar.Text = TukuiDB.SetFontString(castbar, font1, 14)
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", TukuiDB.Scale(4), 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.CheckCast
			castbar.PostChannelStart = TukuiDB.CheckChannel
			
			if db.cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(TukuiDB.Scale(40))
				castbar.button:SetWidth(TukuiDB.Scale(40))
				castbar.button:SetPoint("CENTER", 0, TukuiDB.Scale(50))
				TukuiDB.SetTemplate(castbar.button)

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				
				TukuiDB.CreateShadow(castbar.button)
			end

			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
	end
	
	------------------------------------------------------------------------
	--	Focus target unit layout
	------------------------------------------------------------------------

	if (unit == "focustarget") then
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(24))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true			
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		power:SetStatusBarTexture(normTex)
		
		-- border between health and power
		self.HealthBorder = CreateFrame("Frame", nil, power)
		self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, TukuiDB.mult)
		TukuiDB.SetTemplate(self.HealthBorder)
		self.HealthBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
		
		power.frequentUpdates = true
		power.colorPower = true
		if db.showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
		Name:SetFont(font1, 12, "THINOUTLINE")
		Name:SetJustifyH("CENTER")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level]')
		self.Name = Name
	end

	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and TukuiCF["arena"].unitframes == true) or (unit and unit:find("boss%d") and db.showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(24))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)

		health.value = TukuiDB.SetFontString(health, font1,12, "THINOUTLINE")
		health.value:SetPoint("LEFT", TukuiDB.Scale(2), TukuiDB.Scale(1))
		health.PostUpdate = TukuiDB.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		power:SetStatusBarTexture(normTex)
		
		-- border between health and power
		self.HealthBorder = CreateFrame("Frame", nil, power)
		self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, TukuiDB.mult)
		TukuiDB.SetTemplate(self.HealthBorder)
		self.HealthBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
		
		power.frequentUpdates = true
		power.colorPower = true
		if db.showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = TukuiDB.SetFontString(health, font1, 12, "THINOUTLINE")
		power.value:SetPoint("RIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(1))
		power.PreUpdate = TukuiDB.PreUpdatePower
		power.PostUpdate = TukuiDB.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, 12, "THINOUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name
				
		-- trinket feature via trinket plugin
		if (TukuiCF.arena.unitframes) and (unit and unit:find('arena%d')) then
			local Trinketbg = CreateFrame("Frame", nil, self)
			Trinketbg:SetHeight(34)
			Trinketbg:SetWidth(34)
			Trinketbg:SetPoint("LEFT", self, "RIGHT", 7, 0)
			TukuiDB.SetTemplate(Trinketbg)
			Trinketbg:SetFrameLevel(0)
			self.Trinketbg = Trinketbg
			
			local Trinket = CreateFrame("Frame", nil, Trinketbg)
			Trinket:SetAllPoints(Trinketbg)
			Trinket:SetPoint("TOPLEFT", Trinketbg, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			Trinket:SetFrameLevel(1)
			Trinket.trinketUseAnnounce = true
			self.Trinket = Trinket
		end
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"oUF_MainTank" or self:GetParent():GetName():match"oUF_MainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(20))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, 12, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
	end

	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	-- because we can only use self here, and self is under all elements.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("HIGH")
	InvFrame:SetFrameLevel(5)
	InvFrame:SetAllPoints()
	
	-- symbols, now put the symbol on the frame we created above.
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp") -- thx hankthetank for texture
	RaidIcon:SetHeight(20)
	RaidIcon:SetWidth(20)
	RaidIcon:SetPoint("TOP", 0, 8)
	self.RaidIcon = RaidIcon
	
	return self
end

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------

-- for lower reso
local adjustXY = 0
local totdebuffs = 0
if TukuiDB.lowversion then adjustXY = 24 end
if db.totdebuffs then totdebuffs = 24 end

oUF:RegisterStyle('Tukz', Shared)

-- player
local player = oUF:Spawn('player', "oUF_Tukz_player")
player:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", 2,10+adjustXY)
player:SetSize(TukuiDB.Scale(246), TukuiDB.Scale(45))

-- focus
local focus = oUF:Spawn('focus', "oUF_Tukz_focus")
focus:SetPoint("CENTER", TukuiInfoRight, "CENTER")
focus:SetSize(TukuiInfoRight:GetWidth() - TukuiDB.Scale(4), TukuiInfoRight:GetHeight() - TukuiDB.Scale(4))

-- target
local target = oUF:Spawn('target', "oUF_Tukz_target")
target:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", -2,10+adjustXY)
target:SetSize(TukuiDB.Scale(246), TukuiDB.Scale(45))

-- tot
local tot = oUF:Spawn('targettarget', "oUF_Tukz_targettarget")
tot:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0,10)
tot:SetSize(TukuiDB.Scale(127), TukuiDB.Scale(30))

-- pet
local pet = oUF:Spawn('pet', "oUF_Tukz_pet")
pet:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0,49+totdebuffs)
pet:SetSize(TukuiDB.Scale(127), TukuiDB.Scale(30))

if db.showfocustarget then 
	local focustarget = oUF:Spawn("focustarget", "oUF_Tukz_focustarget")
	focustarget:SetPoint("BOTTOM", 0, 224)
	focustarget:SetSize(TukuiDB.Scale(127), TukuiDB.Scale(30))
end

if TukuiCF.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
		if i == 1 then
			arena[i]:SetPoint("BOTTOMLEFT", TukuiInfoRight, "TOPLEFT", 2, 350)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 10)
		end
		arena[i]:SetSize(TukuiDB.Scale(200), TukuiDB.Scale(30))
	end
end

if db.showboss then
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = TukuiDB.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
		if i == 1 then
			boss[i]:SetPoint("BOTTOMLEFT", TukuiInfoRight, "TOPLEFT", 2, 350)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 10)             
		end
		boss[i]:SetSize(TukuiDB.Scale(200), TukuiDB.Scale(30))
	end
end

-- THIS NEED TO BE UPDATED FOR 4.0.1 BUT I'M RUNNING OUT OF TIME FOR A v12 RELEASE.
--[[
if db.maintank == true then
	local tank = oUF:SpawnHeader("oUF_MainTank", nil, 'raid, party, solo', 
		"showRaid", true, "groupFilter", "MAINTANK", "yOffset", 5, "point" , "BOTTOM",
		"template", "oUF_tukzMtt"
	)
	tank:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

if db.mainassist == true then
	local assist = oUF:SpawnHeader("oUF_MainAssist", nil, 'raid, party, solo', 
		"showRaid", true, "groupFilter", "MAINASSIST", "yOffset", 5, "point" , "BOTTOM",
		"template", "oUF_tukzMtt"
	)
	assist:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
end
--]]

-- this is just a fake party to hide Blizzard frame if no Tukui raid layout are loaded.
local party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)

------------------------------------------------------------------------
--	Just a command to test buffs/debuffs alignment
------------------------------------------------------------------------

local testui = TestUI or function() end
TestUI = function()
	testui()
	UnitAura = function()
		-- name, rank, texture, count, dtype, duration, timeLeft, caster
		return 'penancelol', 'Rank 2', 'Interface\\Icons\\Spell_Holy_Penance', random(5), 'Magic', 0, 0, "player"
	end
	if(oUF) then
		for i, v in pairs(oUF.units) do
			if(v.UNIT_AURA) then
				v:UNIT_AURA("UNIT_AURA", v.unit)
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"

------------------------------------------------------------------------
-- Right-Click on unit frames menu. 
-- Doing this to remove SET_FOCUS eveywhere.
-- SET_FOCUS work only on default unitframes.
-- Main Tank and Main Assist, use /maintank and /mainassist commands.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end