--[[
		Save as self.lua into Ensage\Scripts\libs.

		Functions:
			targetFind:GetLastMouseOver(range): Returns the latest mouse-overed hero if it is in range, if not it will return closest hero to the mouse position.
			targetFind:GetClosestToMouse(range): Returns closest hero to the mouse position that is in range.
			targetFind:GetLowestEHP(range,type): Returns the hero by looking at their hp and resistances.
				Type: Damage type. Possible inputs : "magic", "phys" and nothing
					NoType: Compares purely by current HP
					"phys": Comparation includes armor calculation and ignores ethereal heroes.
					"magic": Comparation includes magic resistance calculation and ignores magic immune heroes.
				Tresh: EHP Threshold. If entered function will only return a hero if it's EHP is lower than given amount
				
		Examples:
			targetFind:GetLastMouseOver(1000) REMOVED FOR NOW
			targetFind:GetClosestToMouse(500)
			targetFind:GetLowestEHP(600,"phys")
			targetFind:GetLowestEHP(850,"magic")
			targetFind:GetLowestEHP(99999,"magic",300)
			targetFind:GetLowestEHP(1300)
--]]
require("libs.Utils")
targetFind = {}
function targetFind:GetClosestToMouse(range)
	local player = entityList:GetMyHero()
	if not player then
		return
	end
	local enemyTeam = player:GetEnemyTeam()

	local result = nil
	local bestDistance = nil
	local mousePos = client.mousePosition

	local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO, team=enemyTeam, alive=true, visible=true, illusion=false})
	for _,v in ipairs(enemies) do
		local distance = v:GetDistance2D( mousePos )
		if distance < range then
			if not bestDistance or distance < bestDistance then
				bestDistance = distance
				result = v
			end
		end
	end
	return result
end

function targetFind:GetLowestEHP(range,dmg_type,tresh)
	local player = entityList:GetMyHero()
	if not player then
		return
	end
	local enemyTeam = player:GetEnemyTeam()

	local result = nil
	local enemies = entityList:FindEntities({type=TYPE_HERO, team = enemyTeam})
	for _,v in ipairs(enemies) do
		if me:GetDistance2D(v) < range then
			local immunity
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
			if distance <= range and v.alive and not v.illusion and v.visible and not immunity and (not tresh or (v.health*v_multipler) < tresh) then 
				if not result or (result.health*l_multipler) > (v.health*v_multipler) then
					result = v
				end
			end
		end
	end
	return result
end
