--[[
		Save as TargetFind.lua into Ensage\Scripts\libs.

		Functions:
			targetFind:GetLastMouseOver([source,]range): 					Returns the latest mouse-overed hero in the range of your given source (default = me). 
																				Without parameters is will just return the last mouse-overed hero.
			targetFind:GetClosestToMouse([source,]range[,includeFriendly):	Returns closest hero to the mouse position that is in range of your mouse position [and source.
			targetFind:GetLowestEHP(range,type): 							Returns the hero by looking at their hp and resistances.
																				Type: Damage type. Possible inputs : "magic", "phys" and nothing
																				NoType: Compares purely by current HP
																				"phys": Comparation includes armor calculation and ignores ethereal heroes.
																				"magic": Comparation includes magic resistance calculation and ignores magic immune heroes.
																				Tresh: EHP Threshold. If entered function will only return a hero if it's EHP is lower than given amount
		Examples:
			targetFind:GetLastMouseOver(1000)
			targetFind:GetClosestToMouse(500)
			targetFind:GetLowestEHP(600,"phys")
			targetFind:GetLowestEHP(850,"magic")
			targetFind:GetLowestEHP(99999,"magic",300)
			targetFind:GetLowestEHP(1300)
--]]

require("libs.Utils")

targetFind = {}
targetFind.mOverTable = {}
targetFind.lastMOver = nil
targetFind.i = 0

function targetFind:TargetTick(tick)
	if PlayingGame() then
		local mOver = entityList:GetMouseover()
		if mOver and mOver.hero and mOver.visible and mOver.alive and mOver.team ~= entityList:GetMyHero().team and not mOver:IsIllusion() and (not self.lastMOver or self.lastMOver.handle ~= mOver.handle) then
			self.lastMOver = mOver
			self.mOverTable[mOver.handle] = self.i
			self.i = self.i + 1
		end
	end
end

function targetFind:TargetClose()
	-- reset all saved entities to prevent crashes!
	self.lastMOver = nil
	self.mOverTable = {}
	self.i = 0
end

function targetFind:GetLastMouseOver(source,range)
	local me = entityList:GetMyHero()
	local enemyTeam = me:GetEnemyTeam()
	-- check if at least one parameter ist set
	if not range and source then 
		range = source
		source = me
	end
	local enemies = entityList:FindEntities(function (v) return v.hero and v.alive and v.visible and not v:IsIllusion() and v.team == enemyTeam and (not source or v:GetDistance2D(source) < range) end)
	table.sort( enemies, function (a,b) return self:GetMouseOverRank(a) > self:GetMouseOverRank(b) end )
	if enemies[1] then
		if self:GetMouseOverRank(enemies[1]) >= 0 then
			return enemies[1]
		else
			return self.GetClosestToMouse(range)
		end
	end
end

function targetFind:GetMouseOverRank(ent)
	local rank = self.mOverTable[ent.handle]
	if rank then
		return rank
	else
		return -1
	end
end

function targetFind:GetClosestToMouse(source,range,includeFriendly)
	local me = entityList:GetMyHero()
	
	local mousePos = client.mousePosition
	-- check if source is provided
	if not includeFriendly and type(range) == "boolean" then
		includeFriendly = range
	end
	if not range or type(range) == "boolean" then 
		range = source
		source = nil
	end
	-- check mouse [and source range
	local enemies 
	if includeFriendly then
		enemies = entityList:FindEntities(function (v) return v.hero and v.alive and v.visible and not v:IsIllusion() and (not source or v:GetDistance2D(source) < range) end)
	else
		local enemyTeam = me:GetEnemyTeam()
		enemies = entityList:FindEntities(function (v) return v.hero and v.alive and v.visible and not v:IsIllusion() and v.team == enemyTeam and (not source or v:GetDistance2D(source) < range) end)
	end
	table.sort( enemies, function (a,b) return a:GetDistance2D(mousePos) < b:GetDistance2D(mousePos) end )
	return enemies[1]
end


function targetFind:GetLowestEHP(range,dmg_type,tresh)
	local me = entityList:GetMyHero()
	local enemyTeam = me:GetEnemyTeam()

	local result = nil
	local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO, team = enemyTeam})
	for _,v in ipairs(enemies) do
		if me:GetDistance2D(v) < range then
			local immunity,v_multipler,l_multipler = false,1,1
			if dmg_type == "magic" then
				if lowenemy then l_multipler = 1/(1-lowenemy.magicDmgResist) end
				v_multipler = 1/(1-v.magicDmgResist)
				immunity = v.magicImmune
			elseif dmg_type == "phys" then
				if lowenemy then l_multipler = 1/(1-lowenemy.dmgResist)  end
				v_multipler = 1/(1-v.dmgResist) 
				immunity = v.ghost
			else
				l_multipler = 1
				v_multipler = 1
				immunity = false
			end
			local distance = GetDistance2D(me,v)
			if distance <= range and v.alive and not v:IsIllusion() and v.visible and not immunity and (not tresh or (v.health*v_multipler) < tresh) then 
				if not result or (result.health*l_multipler) > (v.health*v_multipler) then
					result = v
				end
			end
		end
	end
	return result
end

scriptEngine:RegisterLibEvent(EVENT_TICK,targetFind.TargetTick,targetFind)
scriptEngine:RegisterLibEvent(EVENT_CLOSE,targetFind.TargetClose,targetFind)
