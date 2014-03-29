require('libs.Utils')
require('libs.VectorOp')
require('libs.HotkeyConfig')
require('libs.DrawManager3D')
require('libs.TickCounter')
require('libs.SideMessage')

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("AIOGUI")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("slowDown","Performance",SGC_TYPE_NUMCYCLE,false,5,nil,1,15,1)
ScriptConfig:AddParam("roshBox","Roshan Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("roshTime","Roshan Time to Chat",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("roshRe","Roshan Respawn Message",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("runeBox","Rune Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("missingMonitor","Missing Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("hmPredict","Predict HP/MP Regen",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("cours","Enemy Couriers",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("scMon","Score Board Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("glMon","Enemy Glyph Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("items","Enemy Items Purchased",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("creeps","Last Hit Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("creepsNear","Only Show Nearby Creeps",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("selfVis","Self Visibility",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("allyVis","Allied Visibility",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("shIllu","Show Illusion",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("shEffs","Show Effects",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("allyTow","Ally Tower Range",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("enemyTow","Enemy Tower Range",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("manaBar","Mana Bars",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("hpMon","HP Monitor",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("advMon","Advanced Monitor",SGC_TYPE_TOGGLE,false,false,109)

defaultFont = drawMgr:CreateFont("defaultFont","Arial",14,500)

--Minimap Constants
MapLeft = -8000
MapTop = 7350
MapRight = 7500
MapBottom = -7200
MapWidth = math.abs(MapLeft - MapRight)
MapHeight = math.abs(MapBottom - MapTop)
--Settings Table for 15 resolution
ResTable = 
{
	-- Settings for 4:3
	{800,600,{
		rosh       = {x = 640, y = 3},
		rune       = {x = 730, y = 3},
		minimap    = {px = 4, py = 5, h = 146, w = 151},
		ssMonitor  = {x = 172, y = 488, h = 19, w =84, size = 12},
		bars       = {manaOffset = Vector2D(-1,-10), size = Vector2D(58,4)},
		scoreboard = {gap = 0.09375, width = 0.04625, height = 0.0383333}
		}
	},
	{1024,768,{
		rosh       = {x = 820, y = -1},
		rune       = {x = 820 , y = 13},
		minimap    = {px = 5, py = 7, h = 186, w = 193},
		ssMonitor  = {x = 222, y = 625, h = 25, w = 104, size = 12},
		bars       = {manaOffset = Vector2D(-1,-12), size = Vector2D(74,6)},
		scoreboard = {gap = 0.09375, width = 0.04625, height = 0.0383333}
		}
	}, 
	{1152,864,{
		rosh       = {x = 930, y = 0},
		rune       = {x = 930 , y = 16},
		minimap    = {px = 6, py = 7, h = 211, w = 217},
		ssMonitor  = {x = 249, y = 703, h = 27, w = 115, size = 13},
		bars       = {healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-14), hpOffset = Vector2D(-1,-19), size = Vector2D(82,6)},
		scoreboard = {gap = 0.09375, width = 0.04625, height = 0.0383333}
		}
	},
	{1280,960,{
		rosh       = {x = 1030, y = 1},
		rune       = {x = 1030 , y = 19},
		minimap    = {px = 6, py = 9, h = 233, w = 241},
		ssMonitor  = {x = 277, y = 782, h = 30, w = 130, size = 14},
		bars       = {healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-16), hpOffset = Vector2D(-1,-22), size = Vector2D(92,6)},
		scoreboard = {gap = 0.09375, width = 0.04625, height = 0.0383333}
		}
	},
	{1280,1024,{
		rosh       = {x = 1030, y = 3},
		rune       = {x = 1030 , y = 21},
		minimap    = {px = 6, py = 9, h = 233, w = 241},
		ssMonitor  = {x = 277, y = 845, h = 30, w = 130, size = 14},
		bars       = {healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-18), hpOffset = Vector2D(-1,-24), size = Vector2D(98,6)},
		scoreboard = {gap = 0.09375, width = 0.04625, height = 0.0383333}
		}
	},
	{1600,1200,{
		rosh       = {x = 1395, y = 6},
		rune       = {x = 1395 , y = 24},
		minimap    = {px = 8, py = 14, h = 288, w = 304},
		ssMonitor  = {x = 346, y = 978, h = 37, w = 156, size = 15},
		bars       = {manaFont = drawMgr:CreateFont("manaFont","Arial",10,500), healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-20), hpOffset = Vector2D(-1,-28), size = Vector2D(114,8)},
		scoreboard = {gap = 0.09375, width = 0.04625, height = 0.0383333}
		}
	},
	-- Settings for 16:9
	{1280,720,{
		rosh       = {x = 150, y = 4},
		rune       = {x = 241 , y = 4},
		minimap    = {px = 8, py = 8, h = 174, w = 181},
		ssMonitor  = {x = 200, y = 605, h = 21, w = 90, size = 12},
		bars       = {healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-12), hpOffset = Vector2D(-1,-17), size = Vector2D(70,6)},
		scoreboard = {gap = 0.070833, width = 0.034375, height = 0.03981}
		}
	},
	{1360,768,{
		rosh       = {x = 167, y = 6},
		rune       = {x = 258 , y = 6},
		minimap    = {px = 8, py = 8, h = 186, w = 193},
		ssMonitor  = {x = 213, y = 645, h = 23, w = 95, size = 13},
		bars       = {healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-12), hpOffset = Vector2D(-1,-17), size = Vector2D(74,6)},
		scoreboard = {gap = 0.070833, width = 0.034375, height = 0.03981}
		}
	},
	{1366,768,{
		rosh       = {x = 167, y = 6},
		rune       = {x = 258 , y = 6},
		minimap    = {px = 8, py = 8, h = 186, w = 193},
		ssMonitor  = {x = 213, y = 645, h = 23, w = 95, size = 13},
		bars       = {healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-12), hpOffset = Vector2D(-1,-17), size = Vector2D(74,6)},
		scoreboard = {gap = 0.070833, width = 0.034375, height = 0.03981}
		}
	},
	{1600,900,{
		rosh       = {x = 202, y = 9},
		rune       = {x = 293 , y = 9},
		minimap    = {px = 9, py = 9, h = 217, w = 227},
		ssMonitor  = {x = 250, y = 756, h = 27, w = 100, size = 14},
		bars       = {healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-15), hpOffset = Vector2D(-1,-21), size = Vector2D(86,6)},
		scoreboard = {gap = 0.070833, width = 0.034375, height = 0.03981}
		}
	},
	{1920,1080,{
		rosh       = {x = 212, y = 3},
		rune       = {x = 212 , y = 21},
		minimap    = {px = 11, py = 11, h = 261, w = 272},
		ssMonitor  = {x = 300, y = 907, h = 32, w = 100, size = 14},
		bars       = {manaFont = drawMgr:CreateFont("manaFont","Arial",10,500), healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-19), hpOffset = Vector2D(-1,-27), size = Vector2D(104,8)},
		scoreboard = {gap = 0.070833, width = 0.034375, height = 0.03981}
		}
	},
	-- Settings for 16:10
	{1280,768,{
		rosh       = {x = 146, y = 6},
		rune       = {x = 236 , y = 6},
		minimap    = {px = 8, py = 8, h = 186, w = 193},
		ssMonitor  = {x = 283, y = 620, h = 25, w = 103, size = 13},
		bars       = {manaOffset = Vector2D(-1,-12), size = Vector2D(74,6)},
		scoreboard = {gap = 0.0784722, width = 0.038194, height = 0.0388}
		}
	},
	{1280,800,{
		rosh       = {x = 1020, y = 6},
		rune       = {x = 1110 , y = 6},
		minimap    = {px = 8, py = 10, h = 192, w = 203},
		ssMonitor  = {x = 283, y = 652, h = 25, w = 103, size = 13},
		bars       = {healthFont = drawMgr:CreateFont("defaultFont","Arial",12,500), manaOffset = Vector2D(-1,-13), hpOffset = Vector2D(-1,-18), size = Vector2D(78,6)},
		scoreboard = {gap = 0.0784722, width = 0.038194, height = 0.0388}
		}
	},
	{1440,900,{
		rosh       = {x = 172, y = 9},
		rune       = {x = 262 , y = 9},
		minimap    = {px = 9, py = 9, h = 217, w = 227},
		ssMonitor  = {x = 318, y = 734, h = 28, w = 115, size = 14},
		bars       = {healthFont = drawMgr:CreateFont("defaultFont","Arial",12,500), manaOffset = Vector2D(-1,-15), hpOffset = Vector2D(-1,-21), size = Vector2D(86,6)},
		scoreboard = {gap = 0.0784722, width = 0.038194, height = 0.0388}
		}
	},
	{1680,1050,{
		rosh       = {x = 212, y = 3},
		rune       = {x = 212 , y = 21},
		minimap    = {px = 10, py = 11, h = 252, w = 267},
		ssMonitor  = {x = 277, y = 857, h = 32, w = 95, size = 14},
		bars       = {healthFont = drawMgr:CreateFont("defaultFont","Arial",12,500), manaOffset = Vector2D(-1,-18), hpOffset = Vector2D(-1,-25), size = Vector2D(102,6)},
		scoreboard = {gap = 0.0784722, width = 0.038194, height = 0.0388}
		}
	},
	{1920,1200,{
		rosh       = {x = 242, y = 6},
		rune       = {x = 242 , y = 24},
		minimap    = {px = 12, py = 14, h = 288, w = 304},
		ssMonitor  = {x = 320, y = 977, h = 32, w = 100, size = 14},
		bars       = {manaFont = drawMgr:CreateFont("manaFont","Arial",10,500), healthFont = drawMgr:CreateFont("healthFont","Arial",12,500), manaOffset = Vector2D(-1,-20), hpOffset = Vector2D(-1,-28), size = Vector2D(114,8)},
		scoreboard = {gap = 0.0784722, width = 0.038194, height = 0.0388}
		}
	},
}

slowDown = 0

function Tick()
	local playing = PlayingGame()
	ScriptConfig:SetVisible(playing)
	slowDown = 1 + slowDown%ScriptConfig.slowDown
	if slowDown == 1 then
		TickCounter.Start()
		CreepMasterTick(playing)

		EffectTick(playing)

		RuneTick(playing)

		RoshanTick(playing)

		MissingTick(playing)

		HpTick(playing)

		ManaBarTick(playing)

		CollectData(playing)

		AdvancedTick(playing)

		ScoreBoardTick(playing)

		GlyphTick(playing)

		ItemTick(playing)

		RoshanRespawnTick(playing)
		TickCounter.CalculateAvg()
		if IsKeyDown(32) then
			TickCounter.Print()
		end
	end
end

--== ROSHAN RESPAWN ==--

roshAlive = nil

function RoshanRespawnTick(playing)
	if playing and ScriptConfig.roshRe then
		local alive = #entityList:FindEntities({classId=CDOTA_Unit_Roshan}) == 1
		if roshAlive == false and alive == true then
			RoshRespawnMessage()
		end
		roshAlive = alive	
	else
		roshAlive = nil
	end
end

roshFont = drawMgr:CreateFont("roshFont","Arial",25,500)

function RoshRespawnMessage()
	local test = sideMessage:CreateMessage(228,62)
	test:AddElement(drawMgr:CreateRect(0,0,92,51,0xFFFFFFFF,drawMgr:GetTextureId("ESTL/heroes/npc_dota_roshan")),Vector2D(6,6))
	test:AddElement(drawMgr:CreateText(0,0,0xFFFFFFFF,"Roshan Is",roshFont),Vector2D(106,6))
	test:AddElement(drawMgr:CreateText(0,0,0xFFFFFFFF,"Respawned",roshFont),Vector2D(106,31))
end

--== ENEMY ITEM BOUGHT ==--

declarePurchase = {
	item_blink                = true,
	item_gem                  = true,
	item_cheese               = true,
	item_aegis                = true,
	item_travel_boots         = true,
	item_phase_boots          = true,
	item_power_treads         = true,
	item_hand_of_midas        = true,
	item_mekansm              = true,
	item_vladmir              = true,
	item_pipe                 = true,
	item_urn_of_shadows       = true,
	item_sheepstick           = true,
	item_orchid               = true,
	item_cyclone              = true,
	item_force_staff          = true,
	item_dagon                = true,
	item_dagon_2              = true,
	item_dagon_3              = true,
	item_dagon_4              = true,
	item_dagon_5              = true,
	item_necronomicon         = true,
	item_necronomicon_2       = true,
	item_necronomicon_3       = true,
	item_ultimate_scepter     = true,
	item_refresher            = true,
	item_assault              = true,
	item_heart                = true,
	item_black_king_bar       = true,
	item_shivas_guard         = true,
	item_bloodstone           = true,
	item_sphere               = true,
	item_vanguard             = true,
	item_blade_mail           = true,
	item_hood_of_defiance     = true,
	item_rapier               = true,
	item_monkey_king_bar      = true,
	item_radiance             = true,
	item_butterfly            = true,
	item_greater_crit         = true,
	item_basher               = true,
	item_bfury                = true,
	item_manta                = true,
	item_armlet               = true,
	item_invis_sword          = true,
	item_sange_and_yasha      = true,
	item_satanic              = true,
	item_mjollnir             = true,
	item_skadi                = true,
	item_maelstrom            = true,
	item_desolator            = true,
	item_mask_of_madness      = true,
	item_diffusal_blade       = true,
	item_ethereal_blade       = true,
	item_soul_ring            = true,
	item_arcane_boots         = true,
	item_ancient_janggo       = true,
	item_medallion_of_courage = true,
	item_smoke_of_deceit      = true,
	item_veil_of_discord      = true,
	item_rod_of_atos          = true,
	item_abyssal_blade        = true,
	item_heavens_halberd      = true,
	item_tranquil_boots       = true
}

items = {}

function ItemTick(playing)
	if playing and ScriptConfig.items then
		enemyItems = entityList:FindEntities(function (ent) return ent.item and declarePurchase[ent.name] == true and ent.purchaser ~= nil and not ent.owner.illusion and ent.owner.name ~= "npc_dota_roshan" and ent.purchaser.team ~= entityList:GetMyHero().team and not items[ent.handle] end)
		for i,v in ipairs(enemyItems) do
			items[v.handle] = true
			if items.init then
				GenerateSideMessage(v.purchaser.name,v.name)
			end
		end
		if not items.init then 
			items.init = true
		end
	elseif items.init then
		items = {}
	end
end

function GenerateSideMessage(heroName,itemName)
	local test = sideMessage:CreateMessage(222,60)
	test:AddElement(drawMgr:CreateRect(0,0,75,42,0xFFFFFFFF,drawMgr:GetTextureId("ESTL/heroes/"..heroName)),Vector2D(9,9))
	test:AddElement(drawMgr:CreateRect(0,0,64,32,0xFFFFFFFF,drawMgr:GetTextureId("ESTL/broadcast/item_bought")),Vector2D(89,14))
	test:AddElement(drawMgr:CreateRect(0,0,86,43,0xFFFFFFFF,drawMgr:GetTextureId("ESTL/items/"..(itemName:gsub("item_","")))),Vector2D(158,7))
end

--== ENEMY GLYPH MONITOR ==--

glyphFont = drawMgr:CreateFont("glyphFont","Arial",14,1600)

function GlyphTick(playing)
	if playing and ScriptConfig.glMon then
		local pos = Vector2D(screenSize.x - screenSize.y*0.02222	,screenSize.y*0.9759)
		local glyphText = GetGlyphTime()
		local glyphSize = glyphFont:GetTextSize(glyphText)
		if not enemyGlyph then
			enemyGlyph = drawMgr:CreateText(pos.x - glyphSize.x/2,pos.y - glyphSize.y/2,0xFFFFFF80,glyphText,glyphFont)
		else
			enemyGlyph.x = pos.x - glyphSize.x/2
			enemyGlyph.text = glyphText
		end		
	elseif enemyGlyph then
		enemyGlyph.visible = false
        enemyGlyph = nil
	end
end

function GetGlyphTime()
	local team = 5 - entityList:GetMyHero().team
	local cd = client:GetGlyphCooldown(team)
	if cd > 0 then
		return tostring(cd)
	else
		return "Ready"
	end
end

--== SCORE BOARD MONITOR ==--

scoreboard = {}
ultiCdFont = drawMgr:CreateFont("ultiCdFont","Arial",12,1500)

function ScoreBoardTick(playing)
	if playing and ScriptConfig.scMon then
		if not scoreboard.init then
			scoreboard.init = true
		end
		local enemyPlayers = entityList:FindEntities(function (ent) return ent.type == LuaEntity.TYPE_PLAYER end)
		for i,v in ipairs(enemyPlayers) do
			if not scoreboard[v.playerId] then
				CreateSB(v.playerId)
			else
				UpdateSB(v.playerId)
			end
		end
	elseif scoreboard.init then
		for k,v in pairs(scoreboard) do
            if type(k) == "table" then
            	for key,value in pairs(v) do
            		if type(value) == "userdata" and v.visible then
	            		value.visible = false
	            	end
            	end
            end
        end
        scoreboard = {}
	end
end

function IsHeroDead(hero)
	return hero.respawnTime > 0
end

function UpdateSB(playerId)

	if SleepCheck("scoreboard"..playerId) then
		scoreboard[playerId].pos = GetScoreBoardPos(playerId)
		Sleep(ScriptConfig.slowDown*1000,"scoreboard"..playerId)
	end
	local pos = scoreboard[playerId].pos
	pos = Vector2D(math.floor(pos.x),math.floor(pos.y))
	local hero = scoreboard[playerId].hero
	if hero then
		local dead = IsHeroDead(hero)
		local manaPerc = GetHeroMana(hero)/hero.maxMana
		local hpPerc = GetHeroHP(hero)/hero.maxHealth

		if scoreboard[playerId].hp then
			scoreboard[playerId].hp.w = (screenSize.x*location.scoreboard.width-1)*hpPerc
			scoreboard[playerId].mana.w = (screenSize.x*location.scoreboard.width-1)*manaPerc
			scoreboard[playerId].hpBack.visible = not dead
			scoreboard[playerId].hpBack.x = pos.x - screenSize.x*location.scoreboard.width/2 + 1
			scoreboard[playerId].hp.visible = not dead
			scoreboard[playerId].hp.x = pos.x - screenSize.x*location.scoreboard.width/2 + 1
			scoreboard[playerId].mana.visible = not dead
			scoreboard[playerId].mana.x = pos.x - screenSize.x*location.scoreboard.width/2 + 1
			scoreboard[playerId].hpBorder.visible = not dead
			scoreboard[playerId].hpBorder.x = pos.x - screenSize.x*location.scoreboard.width/2 + 1
		end

		if scoreboard[playerId].ulti then
			local icon = GetUltiIcon(hero)
			scoreboard[playerId].ulti.textureId = icon
			scoreboard[playerId].ulti.x = pos.x-8
			scoreboard[playerId].ulti.visible = icon ~= -1
		end

		local cdText = GetUltiCd(hero)
		local cdSize = ultiCdFont:GetTextSize(cdText)
		scoreboard[playerId].ultiCd.x = pos.x - cdSize.x/2
		scoreboard[playerId].ultiCd.text = cdText
	else
		scoreboard[playerId] = {}
	end
end

function GetHPColor(hero)
	if hero.team == entityList:GetMyHero().team then
		return 0x125011FF
	else
		return 0x702512FF
	end
end

function CreateSB(playerId)
	local pos = GetScoreBoardPos(playerId)
	if pos then
		pos = Vector2D(math.floor(pos.x),math.floor(pos.y))
		local hero = GetHero(playerId)
		if hero then
			scoreboard[playerId] = {}
			scoreboard[playerId].pos = pos
			Sleep(ScriptConfig.slowDown*1000,"scoreboard"..playerId)
			local dead = IsHeroDead(hero)
			local hpPerc = GetHeroHP(hero)/hero.maxHealth
			local manaPerc = GetHeroMana(hero)/hero.maxMana
			local color = GetHPColor(hero)

			scoreboard[playerId].hero = hero

			scoreboard[playerId].hpBack = drawMgr:CreateRect(pos.x - screenSize.x*location.scoreboard.width/2 + 1,pos.y,screenSize.x*location.scoreboard.width-1,11,0x000000FF)
			scoreboard[playerId].hp = drawMgr:CreateRect(pos.x - screenSize.x*location.scoreboard.width/2 + 1,pos.y,(screenSize.x*location.scoreboard.width-1)*hpPerc,5,color)
			scoreboard[playerId].mana = drawMgr:CreateRect(pos.x - screenSize.x*location.scoreboard.width/2 + 1,pos.y+6,(screenSize.x*location.scoreboard.width-1)*manaPerc,5,0x2570D6FF)
			scoreboard[playerId].hpBorder = drawMgr:CreateRect(pos.x - screenSize.x*location.scoreboard.width/2 + 1,pos.y,screenSize.x*location.scoreboard.width-1,11,0x000000FF,true)
			scoreboard[playerId].hpBack.visible = not dead
			scoreboard[playerId].hpBorder.visible = not dead
			scoreboard[playerId].hp.visible = not dead
			scoreboard[playerId].mana.visible = not dead

			scoreboard[playerId].hpBorder.visible = not dead
			if hero.team ~= entityList:GetMyHero().team or true then
				local icon = GetUltiIcon(hero)
				scoreboard[playerId].ulti = drawMgr:CreateRect(pos.x-8,pos.y-10,16,16,0x000000FF,icon)
				scoreboard[playerId].ulti.visible = icon ~= -1
			end

			local cdText = GetUltiCd(hero)
			local cdSize = ultiCdFont:GetTextSize(cdText)
			scoreboard[playerId].ultiCd = drawMgr:CreateText(pos.x - cdSize.x/2,pos.y - cdSize.y/2,0xFFFFFFFF,cdText,ultiCdFont)
		end
	end
end

function GetScoreBoardPos(playerId)
	local hero = GetHero(playerId)
	local player = GetHero(playerId)
	if hero then
		local delta = #entityList:FindEntities(function (ent) return ent.type == LuaEntity.TYPE_PLAYER and ent.team == player.team and ent.playerId < playerId end)
		if hero.team == 2 then
			delta = 5-delta
		end
		local x = screenSize.x/2
		if hero.team == 2 then
			x = x - screenSize.x*(location.scoreboard.gap + location.scoreboard.width*(delta-1))
		else
			x = x + screenSize.x*(location.scoreboard.gap + location.scoreboard.width*(delta))
		end
		local y = screenSize.y*location.scoreboard.height
		return Vector2D(x,y)
	end
end

function GetHero(playerId)
	local player = entityList:FindEntities(function (ent) return ent.type == LuaEntity.TYPE_PLAYER and ent.playerId == playerId end)
	if player[1] then
		return player[1].assignedHero
	end
end

function GetPlayer(playerId)
	local player = entityList:FindEntities(function (ent) return ent.type == LuaEntity.TYPE_PLAYER and ent.playerId == playerId end)
	if player[1] then
		return player[1]
	end
end

function GetUltiCd(hero)
	if hero then
		local spell = GetUlti(hero)
		if spell and spell.cd > 0 then
			return tostring(math.ceil(spell.cd))
		else
			return ""
		end
	end
end

function GetUlti(hero)
	local spellSteal = hero:FindSpell("rubick_spell_steal")
	if spellSteal then
		return spellSteal
	else
		for i,v in ipairs(hero.abilities) do
			if v:IsAbilityType(LuaEntityAbility.TYPE_ULTIMATE) then
				return v
			end
		end
	end
end

function GetUltiIcon(hero)
	if hero then
		local spell = GetUlti(hero)
		if spell then
			if spell.state == LuaEntityAbility.STATE_COOLDOWN then
				return drawMgr:GetTextureId("ESTL/pips/ulti_cooldown")
			elseif spell.state == LuaEntityAbility.STATE_NOMANA then
				return drawMgr:GetTextureId("ESTL/pips/ulti_nomana")
			elseif (spell.state == LuaEntityAbility.STATE_NOTLEARNED or spell.state == 84) and not (spell.name:find("empty1") or spell.name:find("empty2")) then
				return -1
			elseif spell.state == LuaEntityAbility.STATE_READY then
				return drawMgr:GetTextureId("ESTL/pips/ulti_ready")
			elseif spell.state == 17 then --Passive Spells
				return drawMgr:GetTextureId("ESTL/pips/ulti_ready")
			else
				return -1
			end
		else
			return -1
		end
	end
end
--== ADVANCED MONITOR ==--

function ColorTransfusionHealth(hpPerc)

    local brightness = 200 --Out of 255

    local _r = math.floor(brightness * (1 - 2*math.abs(0.5 - hpPerc)))
    local _g = math.floor(brightness * (1 - 2*math.abs(0.5 - hpPerc)))

    if hpPerc <= .5 then
        _r = brightness
    end

    if hpPerc >= .5 then
        _g = brightness
    end

    return _r*0x1000000 + _g*0x10000 + 0xFF

end

function GetColor(mod)
	if mod > 0 then
		return 0x00FF00FA
	elseif mod < 0 then
		return 0xFF0000FA
	else
		return 0xFFFFFFFA
	end
end

function GetHeroHP(hero)
	if hero.respawnTime == 0 and hero.health == 0 then
		return hero.maxHealth
	elseif hero.health == 0 then
		return 0
	elseif ScriptConfig.hmPredict and enemyData[hero.handle] and enemyData[hero.handle].lastData and not hero.visible then
		local temp = hero.health + hero.healthRegen*(client.gameTime - enemyData[hero.handle].lastData)
		if temp > hero.maxHealth then
			return hero.maxHealth
		else
			return math.floor(temp)
		end
	else
		return hero.health
	end
end

function GetHeroMana(hero)
	if hero.respawnTime == 0 and hero.health == 0 then
		return hero.maxMana
	elseif hero.health == 0 then
		return 0
	elseif ScriptConfig.hmPredict and enemyData[hero.handle] and enemyData[hero.handle].lastData and not hero.visible then
		local temp = hero.mana + hero.healthRegen*(client.gameTime - enemyData[hero.handle].lastData)
		if temp > hero.maxMana then
			return hero.maxMana
		else
			return math.floor(temp)
		end
	else
		return hero.mana
	end
end

advancedM = {}
advFont = drawMgr:CreateFont("advFont","Arial",12,500)
itemCdFont = drawMgr:CreateFont("itemCdFont","Arial",14,500)

function AdvancedTick(playing)
	if playing and ScriptConfig.advMon then
		if not advancedM.init then
			advancedM.init = true
			advancedM.count = 0
			advancedM.start = Vector2D(5,200 )
		end
		local enemies = entityList:FindEntities(function (ent) return ent.hero and ent.team ~= entityList:GetMyHero().team and not ent.illusion end)
		for i,v in ipairs(enemies) do
			if not advancedM[v.handle] then
				CreateAdv(v)
			else
				UpdateAdv(v)
			end
		end
	elseif advancedM.init then
		for k,v in pairs(advancedM) do
            if type(k) == "table" then
            	for key,value in pairs(v) do
            		if type(value) == "userdata" and v.visible then
	            		value.visible = false
	            	end
            	end
            end
        end
        advancedM = {}
	end
end

function UpdateSpells(hero)
	local spells = hero.abilities
	local realSpells = {}
	for i,v in ipairs(spells) do
		if not v.hidden and v.name ~= "attribute_bonus" then
			realSpells[#realSpells + 1] = v
		end
	end

	if advancedM[hero.handle].spellCount ~= #realSpells then
		StructureSpells(hero)
	else
		local spellSize = (150 - (#realSpells-1)*2)/#realSpells
		local topLeft = advancedM[hero.handle].topLeft + Vector2D(0,33 - spellSize / 2 - 1 - 11 - #realSpells)
		for i,v in ipairs(realSpells) do
        advancedM[hero.handle]["spell"..i.."cdFont"] =  drawMgr:CreateFont("cdFont"..v.handle,"Arial",math.floor(tostring(math.ceil(v.cd)):len() ~= 1 and advancedM[hero.handle]["spell"..i.."lvlFont"].tall*4/tostring(math.ceil(v.cd)):len() or advancedM[hero.handle]["spell"..i.."lvlFont"].tall*2),500)
			advancedM[hero.handle]["spell"..i].textureId = drawMgr:GetTextureId("ESTL/spellicons/"..GetSpellIcon(v))
			if v.manacost > 0 then
				local mcText = tostring(v.manacost)
				local mcSize = advFont:GetTextSize(mcText) + Vector2D(1,-3)
				if advancedM[hero.handle]["spell"..i.."mana"] ~= nil then
					advancedM[hero.handle]["spell"..i.."mana"].w = mcSize.x
					advancedM[hero.handle]["spell"..i.."mana"].x = topLeft.x + 204 + (spellSize+2)*(i-1) + spellSize - mcSize.x
					advancedM[hero.handle]["spell"..i.."manaCost"].x = topLeft.x + 204 + (spellSize+2)*(i-1) + spellSize - mcSize.x
					advancedM[hero.handle]["spell"..i.."manaCost"].text = mcText

				else
					advancedM[hero.handle]["spell"..i.."mana"] = drawMgr:CreateRect(topLeft.x + 204 + (spellSize+2)*(i-1) + spellSize - mcSize.x,topLeft.y + spellSize - mcSize.y,mcSize.x,mcSize.y,0x5050D0D0)
					advancedM[hero.handle]["spell"..i.."manaCost"] = drawMgr:CreateText(topLeft.x + 204 + (spellSize+2)*(i-1) + spellSize - mcSize.x,topLeft.y + spellSize - mcSize.y,0xFFFFFFFF,mcText,advFont)

				end
			else
				if advancedM[hero.handle]["spell"..i.."mana"] ~= nil then
					advancedM[hero.handle]["spell"..i.."mana"].visible = false
					advancedM[hero.handle]["spell"..i.."manaCost"].visible = false
					advancedM[hero.handle]["spell"..i.."mana"] = nil
					advancedM[hero.handle]["spell"..i.."manaCost"] = nil
				end
			end
			advancedM[hero.handle]["spell"..i.."Border"].color = GetSpellBorder(v)
			advancedM[hero.handle]["spell"..i.."Overlay"].color = GetSpellOver(v)

			local spellCd = GetAbilityCD(v)
			local cdSize = advancedM[hero.handle]["spell"..i.."cdFont"]:GetTextSize(spellCd)
			advancedM[hero.handle]["spell"..i.."CD"].position = Vector2D(topLeft.x + 205 + (spellSize+2)*(i-1) + spellSize/2 - cdSize.x/2,topLeft.y + 1 + spellSize/2 - cdSize.y/2)
			advancedM[hero.handle]["spell"..i.."CD"].text = spellCd
			advancedM[hero.handle]["spell"..i.."CD"].font = advancedM[hero.handle]["spell"..i.."cdFont"]

			local spellL = GetSpellLevel(v)
			local lSize = advancedM[hero.handle]["spell"..i.."lvlFont"]:GetTextSize(spellL)
			advancedM[hero.handle]["spell"..i.."lvl"].x = topLeft.x + 205 + (spellSize+2)*(i-1) + spellSize/2 - lSize.x/2
			advancedM[hero.handle]["spell"..i.."lvl"].text = spellL
		end

	end
end

function StructureSpells(hero)
	local topLeft = advancedM[hero.handle].topLeft

	local spells = hero.abilities
	local realSpells = {}
	for i,v in ipairs(spells) do
		if not v.hidden and v.name ~= "attribute_bonus" then
			realSpells[#realSpells + 1] = v
		end
	end

	advancedM[hero.handle].spellCount = #realSpells
	
	for i=1,6 do
		if advancedM[hero.handle]["spell"..i] then
			advancedM[hero.handle]["spell"..i].visible = false
			advancedM[hero.handle]["spell"..i.."Border"].visible = false
			advancedM[hero.handle]["spell"..i.."Overlay"].visible = false
			advancedM[hero.handle]["spell"..i.."CD"].visible = false
			advancedM[hero.handle]["spell"..i.."lvl"].visible = false
			advancedM[hero.handle]["spell"..i] = nil
			advancedM[hero.handle]["spell"..i.."Border"] = nil
			advancedM[hero.handle]["spell"..i.."Overlay"] = nil
			advancedM[hero.handle]["spell"..i.."CD"] = nil
			advancedM[hero.handle]["spell"..i.."lvl"] = nil
			advancedM[hero.handle]["spell"..i.."lvlFont"] = nil
			advancedM[hero.handle]["spell"..i.."cdFont"] = nil
			if advancedM[hero.handle]["spell"..i.."mana"] ~= nil then
				advancedM[hero.handle]["spell"..i.."mana"].visible = false
				advancedM[hero.handle]["spell"..i.."manaCost"].visible = false
				advancedM[hero.handle]["spell"..i.."mana"] = nil
				advancedM[hero.handle]["spell"..i.."manaCost"] = nil
			end
		end
	end

	local spellSize = math.floor((150 - (#realSpells-1)*2)/#realSpells)
	topLeft = topLeft + Vector2D(0,33 - spellSize / 2 - 1 - 11 - #realSpells)
	for i,v in ipairs(realSpells) do
        advancedM[hero.handle]["spell"..i.."lvlFont"] =  drawMgr:CreateFont("tFont"..v.handle,"Arial",#realSpells == 6 and 10 or #realSpells == 5 and 12 or 14,500)
        advancedM[hero.handle]["spell"..i.."cdFont"] =  drawMgr:CreateFont("cdFont"..v.handle,"Arial",math.floor(tostring(math.ceil(v.cd)):len() ~= 1 and advancedM[hero.handle]["spell"..i.."lvlFont"].tall*4/tostring(math.ceil(v.cd)):len() or advancedM[hero.handle]["spell"..i.."lvlFont"].tall*2),500)
		advancedM[hero.handle]["spell"..i] = drawMgr:CreateRect(topLeft.x + 205 + (spellSize+2)*(i-1),topLeft.y,spellSize,spellSize,0x000000FF,drawMgr:GetTextureId("ESTL/spellicons/"..GetSpellIcon(v)))
		if v.manacost > 0 then
			local mcText = tostring(v.manacost)
			local mcSize = advFont:GetTextSize(mcText) + Vector2D(1,-3)
			advancedM[hero.handle]["spell"..i.."mana"] = drawMgr:CreateRect(topLeft.x + 204 + (spellSize+2)*(i-1) + spellSize - mcSize.x,topLeft.y + spellSize - mcSize.y,mcSize.x,mcSize.y,0x5050D0D0)
			advancedM[hero.handle]["spell"..i.."manaCost"] = drawMgr:CreateText(topLeft.x + 204 + (spellSize+2)*(i-1) + spellSize - mcSize.x,topLeft.y + spellSize - mcSize.y,0xFFFFFFFF,mcText,advFont)
		end
		advancedM[hero.handle]["spell"..i.."Border"] = drawMgr:CreateRect(topLeft.x + 205 + (spellSize+2)*(i-1),topLeft.y,spellSize,spellSize,GetSpellBorder(v),true)
		advancedM[hero.handle]["spell"..i.."Overlay"] = drawMgr:CreateRect(topLeft.x + 205 + (spellSize+2)*(i-1),topLeft.y,spellSize,spellSize,GetSpellOver(v))
		local spellCd = GetAbilityCD(v)
		local cdSize = advancedM[hero.handle]["spell"..i.."cdFont"]:GetTextSize(spellCd)
		advancedM[hero.handle]["spell"..i.."CD"] = drawMgr:CreateText(topLeft.x + 205 + (spellSize+2)*(i-1) + spellSize/2 - cdSize.x/2,topLeft.y + 1 + spellSize/2 - cdSize.y/2,0xFFFFFFFF,spellCd,advancedM[hero.handle]["spell"..i.."cdFont"])
		local spellL = GetSpellLevel(v)
		local lSize = advancedM[hero.handle]["spell"..i.."lvlFont"]:GetTextSize(spellL)
		advancedM[hero.handle]["spell"..i.."lvl"] = drawMgr:CreateText(topLeft.x + 205 + (spellSize+2)*(i-1) + spellSize/2 - lSize.x/2,topLeft.y + spellSize + 2,0xFFFFFFFF,spellL,advancedM[hero.handle]["spell"..i.."lvlFont"])

	end
end

function GetSpellIcon(spell)
	if spell.name == "troll_warlord_berserkers_rage" and spell.toggled then
		return "troll_warlord_berserkers_rage_active"
	else
		return spell.name
	end
end

function GetSpellLevel(spell)
	return "L. "..spell.level
end

function GetSpellBorder(spell)
	if spell.state == LuaEntityAbility.STATE_COOLDOWN then
		return 0x000000FF
	elseif spell.state == LuaEntityAbility.STATE_NOMANA then
		return 0x0000A0FF
	elseif (spell.state == LuaEntityAbility.STATE_NOTLEARNED or spell.state == 84) and not (spell.name:find("empty1") or spell.name:find("empty2")) then
		return 0x404040FF
	elseif spell.state == LuaEntityAbility.STATE_READY then
		return 0x808080FF
	elseif spell.state == 16 or spell.state == 17 then --Passive Spells
		return 0x000000FF
	else
		return 0x00000000
	end
end

function GetSpellOver(spell)
	if spell.state == LuaEntityAbility.STATE_COOLDOWN then
		return 0x000000D0
	elseif spell.state == LuaEntityAbility.STATE_NOMANA then
		return 0x3030A0D0
	elseif (spell.state == LuaEntityAbility.STATE_NOTLEARNED or spell.state == 84) and not (spell.name:find("empty1") or spell.name:find("empty2")) then
		return 0x404040D0
	elseif spell.state == LuaEntityAbility.STATE_READY then
		return 0x00000001
	elseif spell.state == 16 or spell.state == 17 then --Passive Spells
		return 0x00000001
	else
		return 0x00000001
	end
end

function UpdateAdv(hero)
	local topLeft = advancedM[hero.handle].topLeft

	local hpColor = ColorTransfusionHealth(GetHeroHP(hero) / enemyData[hero.handle].maxHealth)
	local hpText = GetHeroHP(hero).." / "..enemyData[hero.handle].maxHealth
	local hpSize = advFont:GetTextSize(hpText)
	local hpReg = GetHPRegenText(hero)
	local hpRegSize = advFont:GetTextSize(hpReg)

	advancedM[hero.handle].hpFill.color = hpColor
	advancedM[hero.handle].hpBorder.color = hpColor
 	advancedM[hero.handle].hpFill.w = 150*(GetHeroHP(hero) / enemyData[hero.handle].maxHealth)
	advancedM[hero.handle].hpText.text = hpText
	advancedM[hero.handle].hpText.x = topLeft.x + 52 + 75 - hpSize.x/2
	advancedM[hero.handle].hpRegText.text = hpReg
	advancedM[hero.handle].hpRegText.x = topLeft.x + 52 + 149 - hpRegSize.x

	local manaText = math.floor(enemyData[hero.handle].mana).." / "..math.floor(enemyData[hero.handle].maxMana)
	local manaSize = advFont:GetTextSize(manaText)
	local manaReg = GetManaRegenText(hero)
	local manaRegSize = advFont:GetTextSize(manaReg)

	advancedM[hero.handle].manaFill.w = 150*(enemyData[hero.handle].mana / enemyData[hero.handle].maxMana)
	advancedM[hero.handle].manaText.x =  topLeft.x + 52 + 75 - manaSize.x/2
	advancedM[hero.handle].manaText.text = manaText
	advancedM[hero.handle].manaRegText.x = topLeft.x + 52 + 149 - manaRegSize.x
	advancedM[hero.handle].manaRegText.text = manaReg

	local dmgColor = GetColor(enemyData[hero.handle].dmgBonus)
	local dmgText = tostring(math.floor((enemyData[hero.handle].dmgMax + enemyData[hero.handle].dmgMin)/2 + enemyData[hero.handle].dmgBonus))
	local dmgSize = advFont:GetTextSize(dmgText)
	advancedM[hero.handle].dmgVal.color = dmgColor
	advancedM[hero.handle].dmgVal.text = dmgText
	advancedM[hero.handle].dmgVal.x = topLeft.x + 32 - dmgSize.x/2

	local moveText = tostring(math.floor(enemyData[hero.handle].movespeed))
	local moveValSize = advFont:GetTextSize(moveText)
	advancedM[hero.handle].moveVal.text = moveText
	advancedM[hero.handle].moveVal.x = topLeft.x + 56 + 8 - moveValSize.x/2

	local armorColor = GetColor(enemyData[hero.handle].bonusArmor)
	local armorText = tostring(math.floor(enemyData[hero.handle].totalArmor))
	local armorSize = advFont:GetTextSize(armorText)
	advancedM[hero.handle].armorVal.color = armorColor
	advancedM[hero.handle].armorVal.x = topLeft.x + 35 + 21*2 + 8 - armorSize.x/2
	advancedM[hero.handle].armorVal.text = armorText

	local baseMgcRs = nil
    if hero.name == "npc_dota_hero_meepo" then
        baseMgcRs = .35
    elseif hero.name == "npc_dota_hero_visage" then
        baseMgcRs = .10
    else
        baseMgcRs = .25
    end
	local mgcRsColor = GetColor(math.floor(enemyData[hero.handle].magicDmgResist*100)/100 - baseMgcRs)
	local mgcRsText = tostring(math.floor(enemyData[hero.handle].magicDmgResist*100)/100):gsub("0%.",".")
	local mgcRsSize = advFont:GetTextSize(mgcRsText)
	advancedM[hero.handle].mgcRsVal.color = mgcRsColor
	advancedM[hero.handle].mgcRsVal.x = topLeft.x + 35 + 21*3 + 8 - mgcRsSize.x/2
	advancedM[hero.handle].mgcRsVal.text = mgcRsText

	local attSpText = tostring(math.floor(enemyData[hero.handle].attackSpeed))
	local attSpSize = advFont:GetTextSize(attSpText)
	advancedM[hero.handle].attSpVal.text = attSpText
	advancedM[hero.handle].attSpVal.x = topLeft.x + 35 + 21*4 + 8 - attSpSize.x/2

	local strText = tostring(math.floor(enemyData[hero.handle].strengthTotal))
	local strColor = GetColor(enemyData[hero.handle].strengthTotal - enemyData[hero.handle].strength)
	local strSize = advFont:GetTextSize(strText)
	advancedM[hero.handle].strVal.color = strColor
	advancedM[hero.handle].strVal.x = topLeft.x + 35 + 21*5 + 8 - strSize.x/2
	advancedM[hero.handle].strVal.text = strText

	local agiText = tostring(math.floor(enemyData[hero.handle].agilityTotal))
	local agiColor = GetColor(enemyData[hero.handle].agilityTotal - enemyData[hero.handle].agility)
	local agiSize = advFont:GetTextSize(agiText)
	advancedM[hero.handle].agiVal.color = agiColor
	advancedM[hero.handle].agiVal.x = topLeft.x + 35 + 21*6 + 8 - agiSize.x/2
	advancedM[hero.handle].agiVal.text = agiText

	local intText = tostring(math.floor(enemyData[hero.handle].intellectTotal))
	local intColor = GetColor(enemyData[hero.handle].intellectTotal - enemyData[hero.handle].intellect)
	local intSize = advFont:GetTextSize(intText)
	advancedM[hero.handle].intVal.color = intColor
	advancedM[hero.handle].intVal.x = topLeft.x + 35 + 21*7 + 8 - intSize.x/2
	advancedM[hero.handle].intVal.text = intText

	local stashCheck = DoesHeroHasStashItems(hero)

	for i=1,12 do
		local item = hero:GetItem(i)
		local itemTopLeft = topLeft + Vector2D(27 + 25*(i),22)
		local itemSize = 24
		if i > 6 then
			itemSize = 18
			itemTopLeft = topLeft + Vector2D(360 + 19*((i-1)%3),13 + 19*(math.floor((i-7)/3)))
		end
		advancedM[hero.handle]["item"..i].textureId =drawMgr:GetTextureId("ESTL/modifier_textures/"..GetItemIcon(item))
		local chargeText = GetItemCharge(item)
		local chargeSize = advFont:GetTextSize(chargeText)
		advancedM[hero.handle]["item"..i.."Charge"].text = chargeText
		advancedM[hero.handle]["item"..i.."Charge"].x = itemTopLeft.x + itemSize - 1 - chargeSize.x
		advancedM[hero.handle]["item"..i.."Over"].color = GetItemOver(item)
		advancedM[hero.handle]["item"..i.."Border"].color = GetItemBorder(item)
		local itemcdText = GetAbilityCD(item)
		local itemcdSize = itemCdFont:GetTextSize(itemcdText)
		advancedM[hero.handle]["item"..i.."CD"].x = itemTopLeft.x + itemSize/2 - itemcdSize.x/2
		advancedM[hero.handle]["item"..i.."CD"].text = itemcdText
		if i > 6 then
			advancedM[hero.handle]["item"..i].visible = stashCheck
			advancedM[hero.handle]["item"..i.."Charge"].visible = stashCheck
			advancedM[hero.handle]["item"..i.."Over"].visible = stashCheck
			advancedM[hero.handle]["item"..i.."Border"].visible = stashCheck
			advancedM[hero.handle]["item"..i.."CD"].visible = stashCheck
		end
	end

	advancedM[hero.handle]["stash"].visible = stashCheck

	local bear = GetSpiritBear(hero)
	if bear then
		if advancedM[hero.handle]["bear"] then
			for i=1,6 do
				local item = bear:GetItem(i)
				local itemTopLeft = topLeft + Vector2D(215 + 19*(i),52)
				local itemSize = 18
				advancedM[hero.handle]["bear"..i].textureId =drawMgr:GetTextureId("ESTL/modifier_textures/"..GetItemIcon(item))
				local chargeText = GetItemCharge(item)
				local chargeSize = advFont:GetTextSize(chargeText)
				advancedM[hero.handle]["bear"..i.."Charge"].text = chargeText
				advancedM[hero.handle]["bear"..i.."Charge"].x = itemTopLeft.x + itemSize - 1 - chargeSize.x
				advancedM[hero.handle]["bear"..i.."Over"].color = GetItemOver(item)
				advancedM[hero.handle]["bear"..i.."Border"].color = GetItemBorder(item)
				local itemcdText = GetAbilityCD(item)
				local itemcdSize = advFont:GetTextSize(itemcdText)
				advancedM[hero.handle]["bear"..i.."CD"].x = itemTopLeft.x + itemSize/2 - itemcdSize.x/2
				advancedM[hero.handle]["bear"..i.."CD"].text = itemcdText
			end
		else
			advancedM[hero.handle]["bear"] = drawMgr:CreateText(topLeft.x + 205,topLeft.y+55,0xFFFFFFFF,"BEAR",advFont)
			for i=1,6 do
				local item = bear:GetItem(i)
				local itemTopLeft = topLeft + Vector2D(215 + 19*(i),52)
				local itemSize = 18
				advancedM[hero.handle]["bear"..i] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,0x000000FF,drawMgr:GetTextureId("ESTL/modifier_textures/"..GetItemIcon(item)))
				local chargeText = GetItemCharge(item)
				local chargeSize = advFont:GetTextSize(chargeText)
				advancedM[hero.handle]["bear"..i.."Charge"] = drawMgr:CreateText(itemTopLeft.x + itemSize - 1 - chargeSize.x,itemTopLeft.y+itemSize - chargeSize.y + 3,0xFFFFFFFF,chargeText,advFont)
				advancedM[hero.handle]["bear"..i.."Over"] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,GetItemOver(item))
				advancedM[hero.handle]["bear"..i.."Border"] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,GetItemBorder(item),true)
				local itemcdText = GetAbilityCD(item)
				local itemcdSize = itemCdFont:GetTextSize(itemcdText)
				advancedM[hero.handle]["bear"..i.."CD"] = drawMgr:CreateText(itemTopLeft.x + itemSize/2 - itemcdSize.x/2,itemTopLeft.y + itemSize/2 + 2 - itemcdSize.y/2,0xFFFFFFFF,itemcdText,advFont)
			end
		end
	else
		if advancedM[hero.handle]["bear"] then
			advancedM[hero.handle]["bear"].visible = false
			advancedM[hero.handle]["bear"] = nil
			for i=1,6 do
				advancedM[hero.handle]["bear"..i].visible = false
				advancedM[hero.handle]["bear"..i] = nil
				advancedM[hero.handle]["bear"..i.."Charge"].visible = false
				advancedM[hero.handle]["bear"..i.."Charge"] = nil
				advancedM[hero.handle]["bear"..i.."Over"].visible = false
				advancedM[hero.handle]["bear"..i.."Over"] = nil
				advancedM[hero.handle]["bear"..i.."Border"].visible = false
				advancedM[hero.handle]["bear"..i.."Border"] = nil
				advancedM[hero.handle]["bear"..i.."CD"].visible = false
				advancedM[hero.handle]["bear"..i.."CD"] = nil
			end

		end
	end

	UpdateSpells(hero)
end 

function CreateAdv(hero)
	advancedM[hero.handle] = {}
	local topLeft = advancedM.start + Vector2D(0,82)*advancedM.count
	advancedM[hero.handle].topLeft = topLeft

	advancedM[hero.handle].portrait = drawMgr:CreateRect(topLeft.x,topLeft.y,48,64,0x000000FF,drawMgr:GetTextureId("ESTL/heroes_selection/"..hero.name))
	advancedM[hero.handle].portraitBorder = drawMgr:CreateRect(topLeft.x-1,topLeft.y-1,50,66,0xFFFFFF10,true)

	local hpColor = ColorTransfusionHealth(enemyData[hero.handle].health / enemyData[hero.handle].maxHealth)
	local hpText = enemyData[hero.handle].health.." / "..enemyData[hero.handle].maxHealth
	local hpSize = advFont:GetTextSize(hpText)
	local hpReg = GetHPRegenText(hero)
	local hpRegSize = advFont:GetTextSize(hpReg)
	advancedM[hero.handle].hpBack = drawMgr:CreateRect(topLeft.x + 52,topLeft.y,150,9,0x000000AF)
	advancedM[hero.handle].hpFill = drawMgr:CreateRect(topLeft.x + 52,topLeft.y,150*(enemyData[hero.handle].health / enemyData[hero.handle].maxHealth),9,hpColor)
	advancedM[hero.handle].hpBorder = drawMgr:CreateRect(topLeft.x + 52,topLeft.y,150,9,hpColor,true)
	advancedM[hero.handle].hpText = drawMgr:CreateText(topLeft.x + 52 + 75 - hpSize.x/2,topLeft.y + 6 - hpSize.y/2,0xFFFFFFDF,hpText,advFont)
	advancedM[hero.handle].hpRegText =  drawMgr:CreateText(topLeft.x + 52 + 149 - hpRegSize.x,topLeft.y + 6 - hpRegSize.y/2,0xFFFFFFDF,hpReg,advFont)

	local manaText = math.floor(enemyData[hero.handle].mana).." / "..math.floor(enemyData[hero.handle].maxMana)
	local manaSize = advFont:GetTextSize(manaText)
	local manaReg = GetManaRegenText(hero)
	local manaRegSize = advFont:GetTextSize(manaReg)
	advancedM[hero.handle].manaBack = drawMgr:CreateRect(topLeft.x + 52,topLeft.y + 11,150,9,0x000000AF)
	advancedM[hero.handle].manaFill = drawMgr:CreateRect(topLeft.x + 52,topLeft.y + 11,150*(enemyData[hero.handle].mana / enemyData[hero.handle].maxMana),9,0x2570D6FF)
	advancedM[hero.handle].manaBorder = drawMgr:CreateRect(topLeft.x + 52,topLeft.y + 11,150,9,0x2570D6FF,true)
	advancedM[hero.handle].manaText = drawMgr:CreateText(topLeft.x + 52 + 75 - manaSize.x/2,topLeft.y + 17 - manaSize.y/2,0xFFFFFFDF,manaText,advFont)
	advancedM[hero.handle].manaRegText = drawMgr:CreateText(topLeft.x + 52 + 149 - manaRegSize.x,topLeft.y + 17 - manaRegSize.y/2,0xFFFFFFDF,manaReg,advFont)

	advancedM[hero.handle].levelBack = drawMgr:CreateRect(topLeft.x+1,topLeft.y + 52,47,12,0x000000AF)
	advancedM[hero.handle].levelVal = drawMgr:CreateText(topLeft.x + 3,topLeft.y + 51,0xFFFFFFFF,"Lv. "..enemyData[hero.handle].level,itemCdFont)

	advancedM[hero.handle].dmgIcon = drawMgr:CreateRect(topLeft.x,topLeft.y+65,64,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/DamageSword"))
	local dmgColor = GetColor(enemyData[hero.handle].dmgBonus)
	local dmgText = tostring(math.floor((enemyData[hero.handle].dmgMax + enemyData[hero.handle].dmgMin)/2 + enemyData[hero.handle].dmgBonus))
	local dmgSize = advFont:GetTextSize(dmgText)
	advancedM[hero.handle].dmgVal = drawMgr:CreateText(topLeft.x + 32 - dmgSize.x/2,topLeft.y + 66 + 9 - dmgSize.y/2,dmgColor,dmgText,advFont)

	advancedM[hero.handle].moveIcon = drawMgr:CreateRect(topLeft.x + 35 + 21*1,topLeft.y+48,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/roam_small"))
	local moveText = tostring(math.floor(enemyData[hero.handle].movespeed))
	local moveValSize = advFont:GetTextSize(moveText)
	advancedM[hero.handle].moveVal = drawMgr:CreateText(topLeft.x + 56 + 8 - moveValSize.x/2,topLeft.y+48 + 9 + 7  - moveValSize.y/2,0xFFFFFFDF,moveText,advFont)

	advancedM[hero.handle].armorIcon = drawMgr:CreateRect(topLeft.x + 35 + 21*2,topLeft.y+48,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/escape_small"))
	local armorColor = GetColor(enemyData[hero.handle].bonusArmor)
	local armorText = tostring(math.floor(enemyData[hero.handle].totalArmor))
	local armorSize = advFont:GetTextSize(armorText)
	advancedM[hero.handle].armorVal = drawMgr:CreateText(topLeft.x + 35 + 21*2 + 8 - armorSize.x/2,topLeft.y + 7 +48 + 9 - armorSize.y/2,armorColor,armorText,advFont)

	advancedM[hero.handle].mgcRsIcon = drawMgr:CreateRect(topLeft.x + 35 + 21*3,topLeft.y+48,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/cary_small"))
	local baseMgcRs = nil
    if hero.name == "npc_dota_hero_meepo" then
        baseMgcRs = .35
    elseif hero.name == "npc_dota_hero_visage" then
        baseMgcRs = .10
    else
        baseMgcRs = .25
    end
	local mgcRsColor = GetColor(math.floor(enemyData[hero.handle].magicDmgResist*100)/100 - baseMgcRs)
	local mgcRsText = tostring(math.floor(enemyData[hero.handle].magicDmgResist*100)/100):gsub("0%.",".")
	local mgcRsSize = advFont:GetTextSize(mgcRsText)
	advancedM[hero.handle].mgcRsVal = drawMgr:CreateText(topLeft.x + 35 + 21*3 + 8 - mgcRsSize.x/2,topLeft.y + 7 +48 + 9 - mgcRsSize.y/2,mgcRsColor,mgcRsText,advFont)

	advancedM[hero.handle].attSpIcon = drawMgr:CreateRect(topLeft.x + 35 + 21*4,topLeft.y+48,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/init_small"))
	local attSpText = tostring(math.floor(enemyData[hero.handle].attackSpeed))
	local attSpSize = advFont:GetTextSize(attSpText)
	advancedM[hero.handle].attSpVal = drawMgr:CreateText(topLeft.x + 35 + 21*4 + 8 - attSpSize.x/2,topLeft.y + 7 +48 + 9 - attSpSize.y/2,0xFFFFFFDF,attSpText,advFont)

	advancedM[hero.handle].strIcon = drawMgr:CreateRect(topLeft.x + 35 + 21*5,topLeft.y+48,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/str_small"))
	local strText = tostring(math.floor(enemyData[hero.handle].strengthTotal))
	local strColor = GetColor(enemyData[hero.handle].strengthTotal - enemyData[hero.handle].strength)
	local strSize = advFont:GetTextSize(strText)
	advancedM[hero.handle].strVal = drawMgr:CreateText(topLeft.x + 35 + 21*5 + 8 - strSize.x/2,topLeft.y + 7 +48 + 9 - strSize.y/2,strColor,strText,advFont)

	advancedM[hero.handle].agiIcon = drawMgr:CreateRect(topLeft.x + 35 + 21*6,topLeft.y+48,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/agi_small"))
	local agiText = tostring(math.floor(enemyData[hero.handle].agilityTotal))
	local agiColor = GetColor(enemyData[hero.handle].agilityTotal - enemyData[hero.handle].agility)
	local agiSize = advFont:GetTextSize(agiText)
	advancedM[hero.handle].agiVal = drawMgr:CreateText(topLeft.x + 35 + 21*6 + 8 - agiSize.x/2,topLeft.y + 7 +48 + 9 - agiSize.y/2,agiColor,agiText,advFont)

	advancedM[hero.handle].intIcon = drawMgr:CreateRect(topLeft.x + 35 + 21*7,topLeft.y+48,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/pips/int_small"))
	local intText = tostring(math.floor(enemyData[hero.handle].intellectTotal))
	local intColor = GetColor(enemyData[hero.handle].intellectTotal - enemyData[hero.handle].intellect)
	local intSize = advFont:GetTextSize(intText)
	advancedM[hero.handle].intVal = drawMgr:CreateText(topLeft.x + 35 + 21*7 + 8 - intSize.x/2,topLeft.y + 7 +48 + 9 - intSize.y/2,intColor,intText,advFont)

	local stashCheck = DoesHeroHasStashItems(hero)

	for i=1,12 do
		local item = hero:GetItem(i)
		local itemTopLeft = topLeft + Vector2D(27 + 25*(i),22)
		local itemSize = 24
		if i > 6 then
			itemSize = 18
			itemTopLeft = topLeft + Vector2D(360 + 19*((i-1)%3),13 + 19*(math.floor((i-7)/3)))
		end
		advancedM[hero.handle]["item"..i] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,0x000000FF,drawMgr:GetTextureId("ESTL/modifier_textures/"..GetItemIcon(item)))
		local chargeText = GetItemCharge(item)
		local chargeSize = advFont:GetTextSize(chargeText)
		advancedM[hero.handle]["item"..i.."Charge"] = drawMgr:CreateText(itemTopLeft.x + itemSize - 1 - chargeSize.x,itemTopLeft.y+itemSize - chargeSize.y + 3,0xFFFFFFFF,chargeText,advFont)
		advancedM[hero.handle]["item"..i.."Over"] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,GetItemOver(item))
		advancedM[hero.handle]["item"..i.."Border"] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,GetItemBorder(item),true)
		local itemcdText = GetAbilityCD(item)
		local itemcdSize = itemCdFont:GetTextSize(itemcdText)
		advancedM[hero.handle]["item"..i.."CD"] = drawMgr:CreateText(itemTopLeft.x + itemSize/2 - itemcdSize.x/2,itemTopLeft.y + itemSize/2 + 2 - itemcdSize.y/2,0xFFFFFFFF,itemcdText,itemCdFont)
		if i > 6 then
			advancedM[hero.handle]["item"..i].visible = stashCheck
			advancedM[hero.handle]["item"..i.."Charge"].visible = stashCheck
			advancedM[hero.handle]["item"..i.."Over"].visible = stashCheck
			advancedM[hero.handle]["item"..i.."Border"].visible = stashCheck
			advancedM[hero.handle]["item"..i.."CD"].visible = stashCheck
		end
	end

	advancedM[hero.handle]["stash"] = drawMgr:CreateText(topLeft.x + 370,topLeft.y,0xFFFFFFFF,"STASH",advFont)
	advancedM[hero.handle]["stash"].visible = stashCheck

	local bear = GetSpiritBear(hero)

	if bear then
		advancedM[hero.handle]["bear"] = drawMgr:CreateText(topLeft.x + 205,topLeft.y+55,0xFFFFFFFF,"BEAR",advFont)
		for i=1,6 do
			local item = bear:GetItem(i)
			local itemTopLeft = topLeft + Vector2D(215 + 19*(i),52)
			local itemSize = 18
			advancedM[hero.handle]["bear"..i] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,0x000000FF,drawMgr:GetTextureId("ESTL/modifier_textures/"..GetItemIcon(item)))
			local chargeText = GetItemCharge(item)
			local chargeSize = advFont:GetTextSize(chargeText)
			advancedM[hero.handle]["bear"..i.."Charge"] = drawMgr:CreateText(itemTopLeft.x + itemSize - 1 - chargeSize.x,itemTopLeft.y+itemSize - chargeSize.y + 3,0xFFFFFFFF,chargeText,advFont)
			advancedM[hero.handle]["bear"..i.."Over"] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,GetItemOver(item))
			advancedM[hero.handle]["bear"..i.."Border"] = drawMgr:CreateRect(itemTopLeft.x,itemTopLeft.y,itemSize,itemSize,GetItemBorder(item),true)
			local itemcdText = GetAbilityCD(item)
			local itemcdSize = itemCdFont:GetTextSize(itemcdText)
			advancedM[hero.handle]["bear"..i.."CD"] = drawMgr:CreateText(itemTopLeft.x + itemSize/2 - itemcdSize.x/2,itemTopLeft.y + itemSize/2 + 2 - itemcdSize.y/2,0xFFFFFFFF,itemcdText,itemCdFont)
		end
	end

	StructureSpells(hero)

	advancedM.count = advancedM.count + 1
end

function GetSpiritBear(hero)
	local summon = hero:FindAbility("lone_druid_spirit_bear")
	if summon then
		local handle = summon:GetProperty("CDOTA_Ability_LoneDruid_SpiritBear","m_hBear")
		if handle ~= -1 then
			return entityList:GetEntity(handle)
		else
			return nil
		end
	else
		return nil
	end
end

function DoesHeroHasStashItems(hero)
    for i=7,12 do
        if hero:GetItem(i) then
            return true
        end
    end
    return false
end

function GetHPRegenText(hero)
	if GetHeroHP(hero) < enemyData[hero.handle].maxHealth - .1 and hero.health > 0 then
		if enemyData[hero.handle].healthRegen > 0 then
			return "+"..math.floor(enemyData[hero.handle].healthRegen*10)/10
		else
			return tostring(math.floor(enemyData[hero.handle].healthRegen*10)/10)
		end
	else
		return ""
	end
end

function GetManaRegenText(hero)
	if GetHeroMana(hero) < enemyData[hero.handle].maxMana - .1 and hero.health > 0 then
		if enemyData[hero.handle].manaRegen > 0 then
			return "+"..math.floor(enemyData[hero.handle].manaRegen*10)/10
		else
			return tostring(math.floor(enemyData[hero.handle].manaRegen*10)/10)
		end
	else
		return ""
	end
end

function GetItemOver(item)
	if item ~= nil then
		if item.state == LuaEntityAbility.STATE_NOMANA then
	        return 0x3030A0D0
	    elseif item.state == LuaEntityAbility.STATE_ITEMCOOLDOWN or item.cd > 0 then
	        return 0x000000D0
	    else
	        return 0x00000000
	    end
    else
        return 0x00000000
    end
end

function GetItemBorder(item)
	if item ~= nil then
		if item.state == LuaEntityAbility.STATE_NOMANA then
		    return 0x3030A0D0
		elseif item.state == LuaEntityAbility.STATE_ITEMCOOLDOWN or item.cd > 0 then
		    return 0x000000D0
		else
		    return 0xFFFFFF10
		end
    else
        return 0xFFFFFF10
    end
end

function GetAbilityCD(item)
	if item ~= nil and item.cd > 0 then
		return tostring(math.ceil(item.cd))
	else
		return ""
	end
end

function GetItemCharge(item)
	if item ~= nil and (item.initialCharges > 0 or not item.permanent or item.requiresCharges or item.bottle) then
		return tostring((item.bottle and item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") > 0) and 3 or item.charges)
	else
		return ""
	end
end

function GetItemIcon(item)
	if item then
		if item.name == "item_bottle" then
            if item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 0 then
	        	return "item_bottle_doubledamage"
            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 2 then
                return "item_bottle_illusion"
            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 3 then
                return "item_bottle_invisibility"
            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 4 then
                return "item_bottle_regeneration"
            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 1 then
                return "item_bottle_haste"
            elseif item.charges == 3 then
                return "item_bottle"
            elseif item.charges == 2 then
                return "item_bottle_medium"
            elseif item.charges == 1 then
                return "item_bottle_small"
            elseif item.charges == 0 then
                return "item_bottle_empty"
            end
        elseif item.name == "item_power_treads" then
            if item.bootsState == PT_AGI then
                return "item_power_treads_agi"
            elseif item.bootsState == PT_INT then
                return "item_power_treads_int"
            elseif item.bootsState == PT_STR then
                return "item_power_treads_str"
            else
            	return "item_power_treads"
            end
        elseif item.name == "item_armlet" then
            if item.toggled then
                return "item_armlet_active"
            else
            	return "item_armlet"
            end
        elseif item.name == "item_radiance" then
            if item.toggled then
                return "item_radiance_inactive"
            else
            	return "item_radiance"
            end
        elseif item.name == "item_tranquil_boots" then
        	if item.charges == 0 then
                return "item_tranquil_boots"
            else
            	return "item_tranquil_boots_active"
            end
        elseif item.name == "item_ring_of_basilius" then
        	if item.toggled then
                return "item_ring_of_basilius"
            else
            	return "item_ring_of_basilius_active"
            end
        elseif item.name == "item_ring_of_aquila" then
        	if item.toggled then
                return "item_ring_of_aquila_active"
            else
            	return "item_ring_of_aquila"
            end
        elseif item.name:find("recipe") then
        	return "item_recipe"
        else
			return item.name
		end
	else
		return "item_emptyitembg"
	end
end

--== DATA COLLECT FOR ENEMY HEROES ==--

enemyData = {}

function CollectData(playing)
	if playing then
		if not enemyData.init then
			enemyData.init = true
		end
		local enemies = entityList:FindEntities(function (ent) return ent.hero and ent.team ~= entityList:GetMyHero().team and not ent:IsIllusion() end)
		for i,v in ipairs(enemies) do
			if not enemyData[v.handle] or v.visible then
				CollectEnemyData(v)
			end
		end
	elseif enemyData.init then
        enemyData = {}
	end
end

function CollectEnemyData(v)
	if not enemyData[v.handle] then
		enemyData[v.handle] = {}
	end
	enemyData[v.handle].health = GetHeroHP(v)
    enemyData[v.handle].maxHealth = v.maxHealth
    enemyData[v.handle].healthRegen = v.healthRegen
    enemyData[v.handle].mana = GetHeroMana(v)
    enemyData[v.handle].maxMana = v.maxMana
    enemyData[v.handle].manaRegen = v.manaRegen
    enemyData[v.handle].level = v:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel")
    enemyData[v.handle].dmgBonus = v.dmgBonus
    enemyData[v.handle].dmgMin = v.dmgMin
    enemyData[v.handle].dmgMax = v.dmgMax
    enemyData[v.handle].movespeed = v.movespeed
    enemyData[v.handle].bonusArmor = v.bonusArmor
    enemyData[v.handle].totalArmor = v.totalArmor
    enemyData[v.handle].magicDmgResist = v.magicDmgResist
    enemyData[v.handle].attackSpeed = v.attackSpeed
    enemyData[v.handle].strength = v.strength
    enemyData[v.handle].strengthTotal = v.strengthTotal
    enemyData[v.handle].agility = v.agility
    enemyData[v.handle].agilityTotal = v.agilityTotal
    enemyData[v.handle].intellect = v.intellect
    enemyData[v.handle].intellectTotal = v.intellectTotal
    enemyData[v.handle].lastData = client.gameTime
end

--== MANABARS ==--

manaBar = {}

function ManaBarTick(playing)
	if playing and ScriptConfig.manaBar then
		if not manaBar.init then
			manaBar.init = true
		end
		local enemies = entityList:FindEntities(function (ent) return ent.hero and ent.team ~= entityList:GetMyHero().team and not ent:IsIllusion() and ent.visible and ent.alive and not ent:IsUnitState(LuaEntityNPC.STATE_NO_HEALTHBAR) end)
		for i,v in ipairs(enemies) do
			if not manaBar[v.handle] then
				CreateManabar(v)
			end
		end
		for k,v in pairs(manaBar) do
			if type(k) == "number" then
				local entity = entityList:GetEntity(k)
				if entity then
					if entity.visible and entity.alive and not entity:IsUnitState(LuaEntityNPC.STATE_NO_HEALTHBAR) then
						UpdateManaBar(entity)
					else
						DestroyManaBar(k)
					end
				else
					DestroyManaBar(k)
				end
			end
		end
	elseif manaBar.init then
		for k,v in pairs(manaBar) do
            if k ~= "init" then
            	for key,value in pairs(v) do
	            	value:Destroy()
            	end
            end
        end
        manaBar = {}
	end
end

function CreateManabar(hero)
	local barPect = hero.mana / hero.maxMana
	manaBar[hero.handle] = {}
	manaBar[hero.handle].back = drawMgr3D:CreateRect(hero,Vector(0,0,hero.healthbarOffset),location.bars.manaOffset,location.bars.size,mb.emptyManaColor)
	manaBar[hero.handle].mana = drawMgr3D:CreateRect(hero,Vector(0,0,hero.healthbarOffset),Vector2D(location.bars.manaOffset.x-location.bars.size.x/2+location.bars.size.x*barPect/2,location.bars.manaOffset.y),Vector2D(location.bars.size.x*barPect,location.bars.size.y),mb.manaColor)
	manaBar[hero.handle].border = drawMgr3D:CreateRect(hero,Vector(0,0,hero.healthbarOffset),location.bars.manaOffset,location.bars.size,0x000000FF,true)
	if location.bars.manaFont then
		manaBar[hero.handle].text = drawMgr3D:CreateText(hero,Vector(0,0,hero.healthbarOffset),Vector2D(location.bars.manaOffset.x,location.bars.manaOffset.y + 1),0xFFFFFFFF,math.floor(hero.mana).." / "..math.floor(hero.maxMana),location.bars.manaFont)
	end
end

function UpdateManaBar(hero)
	local barPect = hero.mana / hero.maxMana
	manaBar[hero.handle].mana:Align2D(Vector2D(location.bars.manaOffset.x-location.bars.size.x/2+location.bars.size.x*barPect/2,location.bars.manaOffset.y))
	manaBar[hero.handle].mana:SetSize(Vector2D(location.bars.size.x*barPect,location.bars.size.y))
	if manaBar[hero.handle].text then
		manaBar[hero.handle].text:SetText(math.floor(hero.mana).." / "..math.floor(hero.maxMana))
	end
	
end

function DestroyManaBar(handle)
	manaBar[handle].back:Destroy()
	manaBar[handle].mana:Destroy()
	manaBar[handle].border:Destroy()
	if manaBar[handle].text then
		manaBar[handle].text:Destroy()
	end
	manaBar[handle] = nil
end

--== HP MONITOR ==--

hpMon = {}

function HpTick(playing)
	if playing and ScriptConfig.hpMon and location.bars.healthFont then
		if not hpMon.init then
			hpMon.init = true
		end
		local enemies = entityList:FindEntities(function (ent) return ent.hero and ent.team ~= entityList:GetMyHero().team and not ent:IsIllusion() and ent.visible and ent.alive and not ent:IsUnitState(LuaEntityNPC.STATE_NO_HEALTHBAR) end)
		for i,v in ipairs(enemies) do
			if not hpMon[v.handle] then
				CreateHpVisuals(v)
			end
		end
		for k,v in pairs(hpMon) do
			if type(k) == "number" then
				local entity = entityList:GetEntity(k)
				if entity then
					if entity.visible and entity.alive and not entity:IsUnitState(LuaEntityNPC.STATE_NO_HEALTHBAR) then
						UpdateHpVisuals(entity)
					else
						DesroyHpVisuals(k)
					end
				else
					DesroyHpVisuals(k)
				end
			end
		end
	elseif hpMon.init then
		for k,v in pairs(hpMon) do
            if k ~= "init" then
            	v:Destroy()
            end
        end
        hpMon = {}
	end
end

function CreateHpVisuals(hero)
	if location.bars.healthFont then
		hpMon[hero.handle] = drawMgr3D:CreateText(hero,Vector(0,0,hero.healthbarOffset),location.bars.hpOffset,0xFFFFFFFF,math.floor(hero.health).." / "..math.floor(hero.maxHealth),location.bars.healthFont)
	end
end

function UpdateHpVisuals(hero)
	hpMon[hero.handle]:SetText(math.floor(hero.health).." / "..math.floor(hero.maxHealth))
end

function DesroyHpVisuals(handle)
	hpMon[handle]:Destroy()
	hpMon[handle] = nil
end

--== MISSING MONITOR ==--

missingObjs = {}

function MissingTick(playing)
	if playing and ScriptConfig.missingMonitor then
		MissingFrame()
		if not missingObjs.init then
			missingObjs.init = true
			missingObjs.heroData = {}
			missingObjs.count = 0
            missingObjs.inside = drawMgr:CreateRect(location.ssMonitor.x,location.ssMonitor.y,location.ssMonitor.w,5*location.ssMonitor.h,0x000000FF)
            missingObjs.line = drawMgr:CreateLine(location.ssMonitor.x + 33,location.ssMonitor.y,location.ssMonitor.x + 33,location.ssMonitor.y + 5*location.ssMonitor.h,0x101010FF)
            missingObjs.inBorder = drawMgr:CreateRect(location.ssMonitor.x-1,location.ssMonitor.y-1,location.ssMonitor.w+2,5*location.ssMonitor.h+2,0x000000A0,true)
            missingObjs.outBorder = drawMgr:CreateRect(location.ssMonitor.x-2,location.ssMonitor.y-2,location.ssMonitor.w+4,5*location.ssMonitor.h+4,0x00000050,true)
		else
			for i,v in ipairs(entityList:FindEntities(function (ent) return ent.hero and ent.team ~= entityList:GetMyHero().team end)) do
				if not v.illusion then
					UpdateHeroData(v)
				end
			end
		end
	elseif missingObjs.init then
        for k,v in pairs(missingObjs) do
            if k ~= "init" and k ~= "heroData" and k ~= "count" then
            	if GetType(v) == "DrawObject3D" then
            		v:Destroy()
            	else
                	v.visible = false
                end
            end
        end
        missingObjs = {}
	end
end

function UpdateHeroData(hero,pos,override)
	if not pos then
		pos = hero.health > 0 and hero.position or entityList:FindEntities({classId = CDOTA_Unit_Fountain, team = hero.team})[1].position
	end
	local handle = nil
	if type(hero) == "number" then
		handle = hero
		hero = entityList:GetEntity(hero)
	else
		handle = hero.handle
	end
	if missingObjs.init then
		if not missingObjs.heroData[handle] then
			missingObjs.heroData[handle] = {init = true,missMsg = "Missing"}
		end
		if override then
			missingObjs.heroData[handle].pos = pos:Clone()
			missingObjs.heroData[handle].time = client.gameTime
			if missingObjs[hero.handle.."main1"] then
				UpdateMapVisuals(hero)
			end
		end
		if missingObjs.heroData[handle].vis == nil  then
			if not hero.visible and hero.respawnTime <= 0 then
				missingObjs.heroData[handle].vis = false
			end
		elseif  missingObjs.heroData[handle].vis == false then
			if hero.visible or hero.respawnTime > 0 then
				missingObjs.heroData[handle] = {init = true,missMsg = "Missing"}
			else
				missingObjs.heroData[handle].vis = true
				missingObjs.heroData[handle].pos = pos:Clone()
				missingObjs.heroData[handle].time = client.gameTime
			end
		elseif  missingObjs.heroData[handle].vis == true then
			if hero.visible or hero.respawnTime > 0 then
				missingObjs.heroData[handle] = {init = true,missMsg = "Missing"}
			end
		end
		if not missingObjs[handle.."sideIcon"] then
			missingObjs[handle.."sideIcon"] = drawMgr:CreateRect(location.ssMonitor.x,location.ssMonitor.y+location.ssMonitor.h*missingObjs.count,32,32,0x000000FF,drawMgr:GetTextureId("ESTL/miniheroes/"..hero.name))
            missingObjs[handle.."sideSs"] = drawMgr:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+location.ssMonitor.h*missingObjs.count,0xFFFFFFFF,"Missing: ",mmFont)
            missingObjs[handle.."sideEta"] = drawMgr:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+mmFont.tall+location.ssMonitor.h*missingObjs.count,0xFFFFFFFF,"ETA: ",mmFont)
            missingObjs[handle.."sideVis"] = drawMgr:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+mmFont.tall/2+2+location.ssMonitor.h*missingObjs.count,0xFFFFFFFF,"Visible",mmFont)
            missingObjs.count = missingObjs.count + 1 
		end
	end
end

function CreateMapVisuals(hero)
	missingObjs[hero.handle.."main1"] = drawMgr3D:CreateText(missingObjs.heroData[hero.handle].pos:Clone(),Vector(0,0,0),Vector2D(0,-30),0xFFFFFFFF,client:Localize("#"..hero.name),defaultFont)
	missingObjs[hero.handle.."main2"] = drawMgr3D:CreateText(missingObjs.heroData[hero.handle].pos:Clone(),Vector(0,0,0),Vector2D(0,-15),0xFFFFFFFF,math.floor(100*GetHeroHP(hero)/hero.maxHealth).."% HP",defaultFont)
end

function UpdateMapVisuals(hero)
	missingObjs[hero.handle.."main1"]:SetPosition(missingObjs.heroData[hero.handle].pos:Clone())
	missingObjs[hero.handle.."main2"]:SetPosition(missingObjs.heroData[hero.handle].pos:Clone())
end

function CreateMiniMapVisual(hero)
	local minimap = MapToMinimap(missingObjs.heroData[hero.handle].pos)
	missingObjs[hero.handle.."mini"] = drawMgr:CreateRect(minimap.x-8,minimap.y-8,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/miniheroes/"..hero.name))
end

function UpdateMiniMapVisual(hero)
	local minimap = MapToMinimap(missingObjs.heroData[hero.handle].pos)
	if missingObjs[hero.handle.."mini"].x ~= minimap.x - 8 then
		missingObjs[hero.handle.."mini"].x = minimap.x - 8
	end
	if missingObjs[hero.handle.."mini"].y ~= minimap.y - 8 then
		missingObjs[hero.handle.."mini"].y = minimap.y - 8
	end
end

function DestroyHeroVisuals(handle)
	if missingObjs.init then
		if missingObjs[handle.."main1"] then
			missingObjs[handle.."main1"]:Destroy()
			missingObjs[handle.."main1"] = nil
			missingObjs[handle.."main2"]:Destroy()
			missingObjs[handle.."main2"] = nil
		end
		if missingObjs[handle.."mini"] then
			missingObjs[handle.."mini"].visible = false
			missingObjs[handle.."mini"] = nil
		end
	end
end

function UpdateSideData(hero)
	if missingObjs.heroData[hero.handle] then
		if not hero.visible and missingObjs.heroData[hero.handle].pos then
			if missingObjs.heroData[hero.handle].missMsg then
				local delta = client.gameTime - missingObjs.heroData[hero.handle].time
				local ssText = nil
				if delta >= 60 then
					ssText = string.format(missingObjs.heroData[hero.handle].missMsg..": "..math.floor(delta/60)..":%02d",(delta%60))
				else
					ssText = string.format(missingObjs.heroData[hero.handle].missMsg..": %02d",(delta%60))
				end
				local ssWidth = mmFont:GetTextSize(ssText).x
				local ssX = location.ssMonitor.x + 17 + (location.ssMonitor.w - ssWidth)/2
				if missingObjs[hero.handle.."sideSs"].x ~= ssX then
					missingObjs[hero.handle.."sideSs"].x = ssX
				end
				if missingObjs[hero.handle.."sideSs"].text ~= ssText then
					missingObjs[hero.handle.."sideSs"].text = ssText
				end
				if missingObjs[hero.handle.."sideSs"].visible ~= true then
					missingObjs[hero.handle.."sideSs"].visible = true
				end
				local eta = (missingObjs.heroData[hero.handle].pos:GetDistance2D(entityList:GetMyHero())/500) - delta
				local etaText = nil
				if eta <= 0 then
					etaText = "ETA: Now"
				elseif eta >= 60 then
					etaText = string.format("ETA: "..math.floor(eta/60)..":%02d",(eta%60))
				else
					etaText = string.format("ETA: %02d",(eta%60))
				end
				local etaWidth = mmFont:GetTextSize(etaText).x
				local etaX = location.ssMonitor.x + 17 + (location.ssMonitor.w - etaWidth)/2
				if missingObjs[hero.handle.."sideEta"].x ~= etaX then
					missingObjs[hero.handle.."sideEta"].x = etaX
				end
				if missingObjs[hero.handle.."sideEta"].text ~= etaText then
					missingObjs[hero.handle.."sideEta"].text = etaText
				end
				if missingObjs[hero.handle.."sideEta"].visible ~= true then
					missingObjs[hero.handle.."sideEta"].visible = true
				end
				if missingObjs[hero.handle.."sideVis"].visible ~= false then
					missingObjs[hero.handle.."sideVis"].visible = false
				end
			end
		else
			if missingObjs.heroData[hero.handle].visMsg then
				local visText = missingObjs.heroData[hero.handle].visMsg
				local visWidth = mmFont:GetTextSize(visText).x
				local visX = location.ssMonitor.x + 17 + (location.ssMonitor.w - visWidth)/2
				if missingObjs[hero.handle.."sideVis"].x ~= visX then
					missingObjs[hero.handle.."sideVis"].x = visX
				end
				if missingObjs[hero.handle.."sideVis"].text ~= visText then
					missingObjs[hero.handle.."sideVis"].text = visText
				end
				if missingObjs[hero.handle.."sideVis"].visible ~= true then
					missingObjs[hero.handle.."sideVis"].visible = true
				end
				if missingObjs[hero.handle.."sideSs"].visible ~= false then
					missingObjs[hero.handle.."sideSs"].visible = false
				end
				if missingObjs[hero.handle.."sideEta"].visible ~= false then
					missingObjs[hero.handle.."sideEta"].visible = false
				end
			end
		end
	end
end

function SetMissingMessage(hero)
	if missingObjs.heroData[hero.handle] and hero.visible then
		if hero:FindModifier("modifier_treant_natures_guise") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_rune_invis") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_weaver_shukuchi") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_phantom_lancer_doppelwalk_invis") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_item_invisibility_edge_windwalk") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_clinkz_wind_walk") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_bounty_hunter_wind_walk") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_nyx_assassin_vendetta") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_broodmother_spin_web_invisible_applier") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_lycan_summon_wolves_invisibility") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_sandking_sand_storm_invis") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_riki_permanent_invisibility") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_invisible") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_persistent_invisibility") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_mirana_moonlight_shadow") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_templar_assassin_meld") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_slark_shadow_dance") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_invoker_ghost_walk_self") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_item_shadow_amulet_fade") then
			missingObjs.heroData[hero.handle].missMsg = "Invis"
		elseif hero:FindModifier("modifier_smoke_of_deceit") then
			missingObjs.heroData[hero.handle].missMsg = "Smoked"
		else
			missingObjs.heroData[hero.handle].missMsg = "Missing"	
		end
	end
end

function SetVisibleMessage(hero)
	if missingObjs.heroData[hero.handle] then
		if hero.respawnTime > 0 then
			missingObjs.heroData[hero.handle].visMsg = "Dead"
		else
			missingObjs.heroData[hero.handle].visMsg = "Visible"
		end
	end
end

function MissingFrame()
	if missingObjs.init then
		for k,v in pairs(missingObjs.heroData) do
			if type(k) == "number" then
				local hero = entityList:GetEntity(k)
				if hero then
					SetMissingMessage(hero)
					SetVisibleMessage(hero)
					if v and v.pos ~= nil then
						if not missingObjs[k.."main1"] then
							CreateMapVisuals(hero)
						else
							missingObjs[hero.handle.."main2"]:SetText(math.floor(100*GetHeroHP(hero)/hero.maxHealth).."% HP")
						end
						if not missingObjs[k.."mini"] then
							CreateMiniMapVisual(hero)
						else
							UpdateMiniMapVisual(hero)
						end
					else
						DestroyHeroVisuals(k)
					end
					if v.init then
						UpdateSideData(hero)
					end
				else
					DestroyHeroVisuals(k)
				end
			end
		end
	end
end

--== ROSHAN MONITOR ==--

roshObjs = {}

function RoshanTick(playing)
	if playing and ScriptConfig.roshBox then
		if not roshObjs.init then
			roshObjs.init = true
	        roshObjs.inside = drawMgr:CreateRect(location.rosh.x,location.rosh.y,95,18,0x000000FF)
	        roshObjs.inBorder = drawMgr:CreateRect(location.rosh.x-1,location.rosh.y-1,97,20,0x000000A0,true)
	        roshObjs.outBorder = drawMgr:CreateRect(location.rosh.x-2,location.rosh.y-2,99,22,0x00000050,true)
	        roshObjs.bmp = drawMgr:CreateRect(location.rosh.x,location.rosh.y,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/miniheroes/npc_dota_roshan"))
	        roshObjs.text = drawMgr:CreateText(location.rosh.x+20,location.rosh.y+3,0xFFFFFFFF,"Roshan: Alive",defaultFont)
		else
		    if roshObjs.deathTick and RoshAlive() then
		            roshObjs.deathTick = nil	
		    end
		    if roshObjs.deathTick then
		        local bigRes = 660 - tickDelta
		        local smlRes = 480 - tickDelta
		        local minutes = math.floor(tickDelta/60)
		        local seconds = tickDelta%60
		        if smlRes <= 0 then
		            roshObjs.text.text = (string.format("Roshan: %02d:%02d",10-minutes,59-seconds))
		        else
		            roshObjs.text.text = (string.format("%02d:%02d - %02d:%02d",math.floor(smlRes/60),smlRes%60,math.floor(bigRes/60),bigRes%60))
		        end
		    elseif roshObjs.text.text ~= "Roshan: Alive" then
		        roshObjs.text.text = ("Roshan: Alive")
		    end
		end
	elseif roshObjs.init then
        for k,v in pairs(roshObjs) do
            if k ~= "init" then
                v.visible = false
            end
        end
        roshObjs = {}
	end
end

function RoshAlive()
    local entities = entityList:FindEntities({classId=CDOTA_Unit_Roshan})
    tickDelta = client.gameTime-roshObjs.deathTick
    if #entities > 0 and tickDelta > 60 then
            local rosh = entities[1]
            if rosh and rosh.alive then
                    return true
            end
    end
    return false
end


function RoshEvent( event )
    if event.name == "dota_roshan_kill" then
        roshObjs.deathTick = client.gameTime
        if ScriptConfig.roshTime then
        	client:ExecuteCmd("chatwheel_say 53")
        	client:ExecuteCmd("chatwheel_say 57")
        end
    end
end

script:RegisterEvent(EVENT_DOTA,RoshEvent)

--== RUNE MONITOR ==--

runeObjs = {}

function RuneTick(playing)
	if playing and ScriptConfig.runeBox then
		if not runeObjs.init then
			runeObjs.init = true
	        runeObjs.inside = drawMgr:CreateRect(location.rune.x,location.rune.y,95,18,0x000000FF)
	        runeObjs.inBorder = drawMgr:CreateRect(location.rune.x-1,location.rune.y-1,97,20,0x000000A0,true)
	        runeObjs.outBorder = drawMgr:CreateRect(location.rune.x-2,location.rune.y-2,99,22,0x00000050,true)
	        runeObjs.bmp = drawMgr:CreateRect(location.rune.x+1,location.rune.y,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/modifier_textures/item_bottle_empty"))
	        runeObjs.text = drawMgr:CreateText(location.rune.x+20,location.rune.y+3,0xFFFFFFFF,"No Rune",defaultFont)
		else
		    local runes = entityList:FindEntities({classId=CDOTA_Item_Rune})
		    if #runes == 0 then
		            if runeObjs.minimap then
		                runeObjs.minimap.visible = false
		                runeObjs.minimap = nil
		            end
		            if runeObjs.text.text ~= ("No Rune") then
		                runeObjs.bmp = drawMgr:CreateRect(location.rune.x+1,location.rune.y,16,16,0x000000FF,drawMgr:GetTextureId("ESTL/modifier_textures/item_bottle_empty"))
		                runeObjs.text.text = ("No Rune")
		            end
		            return 
		    end
		    if  runeObjs.text.text ~= "No Rune" then
		            return
		    end
		    local rune = runes[1]
		    local runeType = rune.runeType
		    filename = ""
		    if runeType == 0 then
		            runeMsg = "DD"
		            filename = "doubledamage"
		    elseif runeType == 2 then
		            runeMsg = "Illu"
		            filename = "illusion"
		    elseif runeType == 3 then
		            runeMsg = "Invis"
		            filename = "invis"
		    elseif runeType == 4 then
		            runeMsg = "Reg"
		            filename = "regen"
		    elseif runeType == 1 then
		            runeMsg = "Haste"
		            filename = "haste"
		    else
		            runeMsg = "???"
		    end
		    if not runeObjs.minimap then
		        if runeObjs.text.text ~= runeMsg then
		            local runeMinimap = MapToMinimap(rune)
		            local size = 20
		            runeObjs.minimap = drawMgr:CreateRect(runeMinimap.x-size/2,runeMinimap.y-size/2,size,size,0x000000FF,drawMgr:GetTextureId("/ESTL/minimap/rune_"..filename))
		            if rune.position.x == -2272 then
		                    runeMsg = runeMsg .. " TOP"
		            else
		                    runeMsg = runeMsg .. " BOT"
		            end
		            runeObjs.text.text = (runeMsg)
		            runeObjs.bmp.visible = false
		            runeObjs.bmp = drawMgr:CreateRect(location.rune.x,location.rune.y+1,16,16,0x000000FF,drawMgr:GetTextureId("/ESTL/runes/"..filename))
		            runeObjs.bmp.visible = true
		        end
		    end
	    end
	elseif runeObjs.init then
        for k,v in pairs(runeObjs) do
            if k ~= "init" then
                v.visible = false
            end
        end
        runeObjs = {}
	end
end

--== ENEMY COURIER ON MINIMAP ==--

cours = {}

function CourierTick()
    if ScriptConfig.cours and PlayingGame() then
        cours.init = true
        local enemyCours = entityList:FindEntities({classId = CDOTA_Unit_Courier})
        for i,v in ipairs(enemyCours) do
            if v.team ~= entityList:GetMyHero().team and v.team ~= 0 and v.team ~= 1 and v.team ~= 5 then
                if v.visible and v.alive then
                    local courMinimap = MapToMinimap(v)
                    local flying = v:GetProperty("CDOTA_Unit_Courier","m_bFlyingCourier")
                    if flying then
                        if not cours[v.handle] or not cours[v.handle].flying then
                            cours[v.handle] = {}
                            cours[v.handle].icon = drawMgr:CreateRect(courMinimap.x-10,courMinimap.y-6,24,12,0x000000FF,drawMgr:GetTextureId("ESTL/minimap/dire_courier_flying"))
                            cours[v.handle].vec = courMinimap
                            cours[v.handle].flying = flying
                        elseif GetDistance2D(courMinimap,cours[v.handle].vec) > 0 then
                            cours[v.handle].icon.x,cours[v.handle].icon.y = courMinimap.x-10,courMinimap.y-6
                        end
                    else
                        if not cours[v.handle] or not cours[v.handle].flying then
                            cours[v.handle] = {}
                            cours[v.handle].icon = drawMgr:CreateRect(courMinimap.x-6,courMinimap.y-6,12,12,0x000000FF,drawMgr:GetTextureId("ESTL/minimap/dire_courier"))
                            cours[v.handle].vec = courMinimap
                            cours[v.handle].flying = flying
                        elseif GetDistance2D(courMinimap,cours[v.handle].vec) > 0 then
                            cours[v.handle].icon.x,cours[v.handle].icon.y = courMinimap.x-6,courMinimap.y-6
                        end
                    end
                elseif cours[v.handle] then
                    cours[v.handle].icon.visible = false
                    cours[v.handle] = nil
                end
            end
        end
    elseif cours.init then
        for k,v in pairs(cours) do
            if k ~= "init" then
                v.visible = false
            end
        end
        cours = {}
    end
end

script:RegisterEvent(EVENT_FRAME,CourierTick)

--== EFFECT PLACEMENT ==--

function AlliedInfest(unit)
	local ents = entityList:FindEntities(function (ent) return ent.hero and ent.team == unit.team and ent:GetDistance2D(unit) < 20 and ent.visible and ent:FindModifier("modifier_life_stealer_infest") ~= nil	end)
	return #ents > 0
end

effects = {}

function EffectFrame( ... )
	for k,v in pairs(effects) do
		if k:sub(-6) == "infest" or k:sub(-6) == "charge" then
			local handle = tonumber(k:sub(0,#k - 6))
	        v:SetVector(0,entityList:GetEntity(handle).position + Vector(0,0,255))
		end
	end
end

script:RegisterEvent(EVENT_FRAME,EffectFrame)

function EffectTick(playing)
	if playing then
		if not effects.init then
			effects.init = true
		end
	    local dirty = false
	    local npcs = entityList:FindEntities(function (ent) return ent.npc or ent.hero end)
	    for i,v in ipairs(npcs) do
            if effects[v.handle.."infest"] == nil and v:FindModifier("modifier_life_stealer_infest_effect") and v.alive and not AlliedInfest(v) then
                if ScriptConfig.shEffs then
	                effects[v.handle.."infest"] = Effect(Vector(),"life_stealer_infested_unit")
	                effects[v.handle.."infest"]:SetVector(0,v.position + Vector(0,0,255))
                end
            elseif effects[v.handle.."infest"] ~= nil  and (not v:FindModifier("modifier_life_stealer_infest_effect")  or not v.alive or not ScriptConfig.shEffs or AlliedInfest(v)) then
                effects[v.handle.."infest"] = nil
                dirty = true
            end
	    end
	    local towers = entityList:FindEntities({classId = CDOTA_BaseNPC_Tower})
	    for i,v in ipairs(towers) do 
	        if not effects[v.handle.."twRange"] and v.alive then
	            if (v.team == entityList:GetMyHero().team and ScriptConfig.allyTow) or (v.team ~= entityList:GetMyHero().team and ScriptConfig.enemyTow) then
	                effects[v.handle.."twRange"] = Effect(v,"range_display")
	                effects[v.handle.."twRange"]:SetVector(1,Vector(850,0,0))
	            end
	        elseif effects[v.handle.."twRange"] and (not v.alive or not (v.team == entityList:GetMyHero().team and ScriptConfig.allyTow) and not (v.team ~= entityList:GetMyHero().team and ScriptConfig.enemyTow)) then
	            effects[v.handle.."twRange"] = nil
	            dirty = true
	        end
	    end
	    local heroes = entityList:FindEntities(function (ent) return ent.hero end)
	    for i,v in ipairs(heroes) do 
	        if v.team == entityList:GetMyHero().team then
	            if effects[v.handle.."track"] == nil and v:FindModifier("modifier_bounty_hunter_track") and v.alive then
	                if ScriptConfig.shEffs then
	                	effects[v.handle.."track"] = Effect(v, "bounty_hunter_track_trail_circle")
	                end
	            elseif effects[v.handle.."track"] ~= nil  and (not v:FindModifier("modifier_bounty_hunter_track")  or not v.alive or not ScriptConfig.shEffs) then
	                effects[v.handle.."track"] = nil
	                dirty = true
	            end
	            if effects[v.handle.."charge"] == nil and v:FindModifier("modifier_spirit_breaker_charge_of_darkness_vision") and v.alive then
	                if ScriptConfig.shEffs then
	                	effects[v.handle.."charge"] = Effect(Vector(), "spirit_breaker_charge_target_mark")
	                	effects[v.handle.."charge"]:SetVector(0,v.position + Vector(0,0,255))
	                end
	            elseif effects[v.handle.."charge"] ~= nil  and (not v:FindModifier("modifier_spirit_breaker_charge_of_darkness_vision")  or not v.alive or not ScriptConfig.shEffs) then
	                effects[v.handle.."charge"] = nil
	                dirty = true
	            end
	            if effects[v.handle.."visible"] == nil and v.visibleToEnemy and v.alive then
	                if (v.playerId == entityList:GetMyHero().playerId and not v:IsIllusion() and ScriptConfig.selfVis) or ((v.playerId ~= entityList:GetMyHero().playerId or v:IsIllusion()) and ScriptConfig.allyVis) then
	                   	if v.playerId == entityList:GetMyHero().playerId and not v:IsIllusion() then
	                   		effects[v.handle.."visible"] = Effect(v,"aura_shivas")
	                   	else
							effects[v.handle.."visible"] = Effect(v,"ambient_gizmo_model")
	                   	end
	                   	effects[v.handle.."visible"]:SetVector(1,Vector(0,0,0))
	                end
	            elseif effects[v.handle.."visible"] ~= nil  and (not v.visibleToEnemy or not v.alive or not (v.handle == entityList:GetMyHero().handle and ScriptConfig.selfVis) and not (v.handle ~= entityList:GetMyHero().handle and ScriptConfig.allyVis)) then
	                effects[v.handle.."visible"] = nil
	                dirty = true
	            end
	        else
	            if effects[v.handle.."illu"] == nil and v:IsIllusion() and v.alive then
	                if ScriptConfig.shIllu then
	                    local color = Vector(0,0,255)
	                    effects[v.handle.."illu"] = {Effect(v,"rune_generic_rings"),Effect(v,"rune_generic_rings"),Effect(v,"rune_generic_rings"),Effect(v,"rune_generic_rings"),Effect(v,"smoke_of_deceit_buff")}
	                    effects[v.handle.."illu"][1]:SetVector(1,color)
	                    effects[v.handle.."illu"][2]:SetVector(1,color)
	                    effects[v.handle.."illu"][3]:SetVector(1,color)
	                    effects[v.handle.."illu"][4]:SetVector(1,color)
	                end
	            elseif effects[v.handle.."illu"] ~= nil  and (not v:IsIllusion() or not v.alive or not ScriptConfig.shIllu) then
	                effects[v.handle.."illu"] = nil
	                dirty = true
	            end
	        end
	    end
	    if dirty then
	    	collectgarbage("collect")
	    end
	elseif effects.init then
		effects = {}
	    collectgarbage("collect")
	end
end

--== LAST HIT MONITOR ==--

lhFont = drawMgr:CreateFont("defaultFont","Arial",14,1800)

oneHitColor	=	0xFF0000FF
unsureColor	=	0xD2691EFF
twoHitColor	= 	0xFFFF00FF
denyColor 	=	0xFFFFFFFF

function CreepMasterTick(playing)
	creepDirty = false
	if playing and ScriptConfig.creeps then
		if not creeps or not creeps.init then
			CreepInit()
		else
			CreepTick()
		end
	elseif creeps and creeps.init then
		CreepDeInit()
	end
end

function CreepInit()
	creeps = {}
	creeps.init = true
end

function CreepDeInit()
	for k,v in pairs(creeps) do
		if k ~= "init" then
			v.visible = false
		end
	end
	creeps = {}
end

function DoesCreepRequireVisuals(creep)
	if creep.visible and creep.alive and (not ScriptConfig.creepsNear or creep:GetDistance2D(entityList:GetMyHero()) <= 1000) then
		if creep.team == entityList:GetMyHero().team then
			return creep.health < creep.maxHealth / 2
		else
			local damageMin = GetDamageToCreep(creep)
			return creep.health < damageMin * 2
		end
	else
		return false
	end
end

function GetDamageToCreep(v)
    if ScriptConfig.creeps then
        creeps.init = true
        local me = entityList:GetMyHero()
        local damageMin = me.dmgMin + me.dmgBonus
        local damageMax = me.dmgMax + me.dmgBonus
        local qb = me:FindItem("item_quelling_blade")
        if v.team ~= me.team and v.classId ~= CDOTA_BaseNPC_Creep_Siege then
            if qb then
                if me.attackType == LuaEntityNPC.ATTACK_MELEE then
                	local bonus = qb:GetSpecialData("damage_bonus")/100
                    damageMin = damageMin + damageMin * bonus
                    damageMax = damageMax + damageMax * bonus
                elseif me.attackType == LuaEntityNPC.ATTACK_RANGED then
                	local bonus = qb:GetSpecialData("damage_bonus_ranged")/100
                    damageMin = damageMin + damageMin * bonus
                    damageMax = damageMax + damageMax * bonus
                end
            end
        end
        if v.classId == CDOTA_BaseNPC_Creep_Siege then
            damageMin = damageMin / 2
            damageMax = damageMax / 2
        end
        return v:DamageTaken(damageMin,DAMAGE_PHYS,me), v:DamageTaken(damageMax,DAMAGE_PHYS,me)
    end
end

function GetCreepColor(creep)
	local damageMin,damageMax = GetDamageToCreep(creep)
	if creep.health < damageMin then
		return oneHitColor
	elseif creep.health < damageMax then
		return unsureColor
	elseif creep.health < damageMin * 2 then
		return twoHitColor
	else
		return denyColor
	end
end

function CreepTick()
	for _,id in ipairs({CDOTA_BaseNPC_Creep,CDOTA_BaseNPC_Creep_Lane,CDOTA_BaseNPC_Creep_Neutral,CDOTA_BaseNPC_Creep_Siege}) do
		local t = entityList:FindEntities({visible = true, alive = true, classId = id})
		for i,v in ipairs(t) do
			if creeps[v.handle] == nil then
				if DoesCreepRequireVisuals(v) then
					CreateCreepVisuals(v)
				end
			end
		end
	end
	for k,v in pairs(creeps) do
		if k ~= "init" then
			local creep = entityList:GetEntity(k)
			if creep and DoesCreepRequireVisuals(creep) then
				UpdateCreepVisuals(creep)
			else
				DestroyCreepVisuals(k)
			end
		end
	end
end

function CreateCreepVisuals(creep)
	creeps[creep.handle] = drawMgr3D:CreateText(creep, Vector(0,0,creep.healthbarOffset),Vector2D(0,-9),GetCreepColor(creep),"[ "..tostring(creep.health).." ]",lhFont)
end

function UpdateCreepVisuals(creep)
	creeps[creep.handle]:SetColor(GetCreepColor(creep))
	creeps[creep.handle]:SetText("[ "..tostring(creep.health).." ]")
end

function DestroyCreepVisuals(handle)
	creeps[handle]:Destroy()
	creeps[handle] = nil
end

--Function returns x,y coordinates of a point's minimap equilavent
function MapToMinimap(x, y)
    if y == nil then
        if x.x then
            _x = x.x - MapLeft
            _y = x.y - MapBottom
        elseif x.position then
            _x = x.position.x - MapLeft
            _y = x.position.y - MapBottom
        else
            return {x = -640, y = -640}
        end
    else
            _x = x - MapLeft
            _y = y - MapBottom
    end
    
    local scaledX = math.min(math.max(_x * MinimapMapScaleX, 0), location.minimap.w)
    local scaledY = math.min(math.max(_y * MinimapMapScaleY, 0), location.minimap.h)
    
    local screenX = location.minimap.px + scaledX
    local screenY = screenSize.y - scaledY - location.minimap.py

    return Vector2D(math.floor(screenX),math.floor(screenY))
end

--== SETTING UP CONSTANTS ==--

do
    screenSize = client.screenSize
    if screenSize.x == 0 and screenSize.y == 0 then
            print("AiO GUI Helper cannot detect your screen resolutions.\nPlease switch to the Borderless Window mode.")
            script:Unload()
    end
    for i,v in ipairs(ResTable) do
            if v[1] == screenSize.x and v[2] == screenSize.y then
                    location = v[3]
                    break
            elseif i == #ResTable then
                    print(screenSize.x.."x"..screenSize.y.." resolution is unsupported by AiO GUI Helper.")
                    script:Unload()
            end
    end

    mmFont = drawMgr:CreateFont("mmFont","Arial",location.ssMonitor.size,500)
end

mb = {}
mb.manaColor = 0x5279FFFF
mb.emptyManaColor = 0x001863FF

MinimapMapScaleX = location.minimap.w / MapWidth
MinimapMapScaleY = location.minimap.h / MapHeight

script:RegisterEvent(EVENT_TICK,Tick)