require('libs.Utils')
require('libs.HotkeyConfig')
require('libs.TargetFind')

ScriptConfig = ConfigGUI:New()
scriptEngine:RegisterLibEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
scriptEngine:RegisterLibEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("Function Wheel")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("funWheel","Function Wheel",SGC_TYPE_ONKEYDOWN,false,false,0xE2)


FunctionWheel = {}

FunctionWheel.TYPE_NONE = 0
FunctionWheel.TYPE_POINT = 1
FunctionWheel.TYPE_UNIT = 2

FunctionWheel.smallFont = drawMgr:CreateFont("defaultFont","Arial",25,1000)
FunctionWheel.bigFont = drawMgr:CreateFont("defaultFont","Arial",40,1000)

functionIds = {}

functions = {}

function FunctionWheel.AddFunction(id,name,check,fun,type)
	local callerScript = GetCallerScript()
	smartAssert(functionIds[id..callerScript] == nil, "Cannot add function to Function Wheel: Existing Id ")
	smartAssert(type == 0 or type == 1 or type == 2, "Cannot add function to Function Wheel: Invalid Type")
	table.insert(functions,{script = callerScript, name = name, check = check, fun = fun, type = type, id = id..callerScript})
	functionIds[id..callerScript] = #functions
end

function FunctionWheel.RemoveFunction(id)
	if GetCallerScript() ~= "FunctionWheel.lua" then
		id = id..GetCallerScript()
	end
	smartAssert(functionIds[id] ~= nil, "Cannot remove function from Function Wheel: Not existing Id")
	table.remove(functions,functionIds[id])
	for k,v in pairs(functionIds) do
		if v > functionIds[id] then
			functionIds[k] = v - 1
		end
	end
	functionIds[id] = nil
end

function FunctionWheel.ClearUnloadedFunctions()
	for i,v in pairs(functions) do
		if not scriptEngine:IsLoaded(v.script) then
			FunctionWheel.RemoveFunction(v.id)
			return
		end
	end
end


FunctionWheel.mPos = nil
FunctionWheel.wheel = nil
FunctionWheel.cursor = nil
FunctionWheel.curFuns = nil
FunctionWheel.names = nil
FunctionWheel.recs = nil
FunctionWheel.unit = nil
FunctionWheel.point = nil
FunctionWheel.range = nil

function FunctionWheel.SetRange(range)
	FunctionWheel.range = range
end

function FunctionWheel.Tick()
	if not PlayingGame() then
		ScriptConfig:SetVisible(false)
		return
	end

	FunctionWheel.ClearUnloadedFunctions()

	ScriptConfig:SetVisible(#functions > 0)

	if ScriptConfig.funWheel then
		if not FunctionWheel.mPos then
			if not FunctionWheel.range then
				FunctionWheel.unit = entityList:GetMouseover()
			else
				FunctionWheel.unit = targetFind:GetLastMouseOver(FunctionWheel.range)
			end
			FunctionWheel.point = client.mousePosition
			FunctionWheel.curFuns = {}
			local ind = 1
			for i,v in ipairs(functions) do
				if v.type == FunctionWheel.TYPE_NONE then
					if v.check() then
						FunctionWheel.curFuns[ind] = v
						ind = ind + 1
					end
				elseif v.type == FunctionWheel.TYPE_POINT then
					if v.check(FunctionWheel.point) then
						FunctionWheel.curFuns[ind] = v
						ind = ind + 1
					end
				elseif v.type == FunctionWheel.TYPE_UNIT and FunctionWheel.unit then
					if v.check(FunctionWheel.unit) then
						FunctionWheel.curFuns[ind] = v
						ind = ind + 1
					end
				end
			end
			if #FunctionWheel.curFuns > 0 then
				FunctionWheel.mPos = client.mouseScreenPosition 
				FunctionWheel.wheel = drawMgr:CreateRect(FunctionWheel.mPos.x - 128,FunctionWheel.mPos.y - 128,256,256,0x000000FF,drawMgr:GetTextureId("FWT/wheel"))
				FunctionWheel.cursor = drawMgr:CreateRect(FunctionWheel.mPos.x - 64,FunctionWheel.mPos.y - 64,128,128,0x000000FF,drawMgr:GetTextureId("FWT/cursor"))
				FunctionWheel.names = {}
				FunctionWheel.recs = {}

				for i,v in ipairs(FunctionWheel.curFuns) do
					local alpha = (2*math.pi*(i - 1)/#FunctionWheel.curFuns - math.pi/2)%(2*math.pi)
					local center = FunctionWheel.mPos + Vector2D(85*math.cos(alpha),85*math.sin(alpha))
					local font = FunctionWheel.smallFont
					center = center - GetRelativePlacement(alpha,font,v.name)
					FunctionWheel.names[i] = drawMgr:CreateText(center.x,center.y,0xD9D9D9FF,v.name,font)
				end
			end
		else
			local newMPos = client.mouseScreenPosition
			if newMPos:GetDistance2D(FunctionWheel.mPos) > 38 then
				newMPos = (newMPos - FunctionWheel.mPos) * 38 / newMPos:GetDistance2D(FunctionWheel.mPos) + FunctionWheel.mPos
			end
			FunctionWheel.cursor.position = newMPos - Vector2D(64,64)
			currentIndex = nil
			if newMPos:GetDistance2D(FunctionWheel.mPos) >= 30 then
				currentIndex = math.floor(((math.atan2(FunctionWheel.mPos.y - newMPos.y,FunctionWheel.mPos.x - newMPos.x) - math.pi/2 + math.pi/#FunctionWheel.curFuns)%(2*math.pi))/(2*math.pi/#FunctionWheel.curFuns)) + 1
			end
			for i,v in ipairs(FunctionWheel.names) do
				if i ~= currentIndex then
					if v.font.tall == FunctionWheel.bigFont.tall then
						local alpha = (2*math.pi*(i - 1)/#FunctionWheel.curFuns - math.pi/2)%(2*math.pi)
						local center = FunctionWheel.mPos + Vector2D(85*math.cos(alpha),85*math.sin(alpha))
						center = center - GetRelativePlacement(alpha,FunctionWheel.smallFont,v.text)
						v.font = FunctionWheel.smallFont
						v.position = center
					end
				else
					if v.font.tall == FunctionWheel.smallFont.tall then
						local alpha = (2*math.pi*(i - 1)/#FunctionWheel.curFuns - math.pi/2)%(2*math.pi)
						local center = FunctionWheel.mPos + Vector2D(85*math.cos(alpha),85*math.sin(alpha))
						center = center - GetRelativePlacement(alpha,FunctionWheel.bigFont,v.text)
						v.font = FunctionWheel.bigFont
						v.position = center
					end
				end
			end
		end
	elseif FunctionWheel.mPos then
		if currentIndex then
			local fun = FunctionWheel.curFuns[currentIndex]
			if fun.type == FunctionWheel.TYPE_NONE then
				fun.fun()
			elseif fun.type == FunctionWheel.TYPE_POINT then
				fun.fun(FunctionWheel.point)
			elseif fun.type == FunctionWheel.TYPE_UNIT then
				fun.fun(FunctionWheel.unit)
			end
		end
		FunctionWheel.mPos = nil
		FunctionWheel.wheel = nil
		FunctionWheel.cursor = nil
		FunctionWheel.names = nil
		FunctionWheel.recs = nil
		FunctionWheel.curFuns = nil
	end
end

function GetRelativePlacement(alpha,font,text)
	local alphaR = alpha/math.pi
	if alphaR < .25 then
		return Vector2D(0,2*(.25 - alphaR)*font:GetTextSize(text).y)
	elseif alphaR < .5 then
		return Vector2D(4*(alphaR - .25)*font:GetTextSize(text).x/2,0)
	elseif alphaR < .75 then
		return Vector2D(2*(alphaR - .25)*font:GetTextSize(text).x,0)
	elseif alphaR < 1.25 then
		return Vector2D(font:GetTextSize(text).x,2*(alphaR - .75)*font:GetTextSize(text).y)
	elseif alphaR < 1.75 then
		return Vector2D(2*(1.75 - alphaR)*font:GetTextSize(text).x,font:GetTextSize(text).y)
	else
		return Vector2D(0,2*(2.25 - alphaR)*font:GetTextSize(text).y)
	end
end

scriptEngine:RegisterLibEvent(EVENT_TICK,FunctionWheel.Tick)