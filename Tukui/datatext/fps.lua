--------------------------------------------------------------------
-- FPS
--------------------------------------------------------------------

if TukuiCF["datatext"].fps and TukuiCF["datatext"].fps > 0 then
	local Stat = CreateFrame("Frame")
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(TukuiCF.media.uffont, TukuiCF["datatext"].fontsize)
	TukuiDB.PP(TukuiCF["datatext"].fps, Text)

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			Text:SetText(floor(GetFramerate())..tukuilocal.datatext_fps)
			int = 1
		end	
	end

	Stat:SetScript("OnUpdate", Update) 
	Update(Stat, 10)
end