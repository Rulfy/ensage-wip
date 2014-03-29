--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0  
 ]]


sideMessage = {}

sideMessage.id = 0
sideMessage.lastTick = nil
sideMessage.objs = {}

sideMessage.ENTER_TIME = 650
sideMessage.STAY_TIME = 2500
sideMessage.EXIT_TIME = 650

function sideMessage:CreateMessage(w,h,bgColor,bdColor)
	if not bgColor then bgColor = 0x111111C0 end
	if not bdColor then bdColor = 0x444444FF end
	obj = {}
	obj.w = w
	obj.h = h
	obj.bgColor = bgColor
	obj.bdColor = bdColor
 	obj.id = sideMessage.id
 	sideMessage.id = sideMessage.id + 1
 	obj.bg = drawMgr:CreateRect(client.screenSize.x,client.screenSize.y*0.64,w,h,bgColor)
 	obj.bd = drawMgr:CreateRect(client.screenSize.x,client.screenSize.y*0.64,w,h,bdColor,true)
 	obj.createTick = GetTick()
 	obj.elements = {}

 	function obj:Destroy()
 		self.bg.visible = false
 		self.bg = nil
 		self.bd.visible = false
 		self.bd = nil
 		for i,v in ipairs(self.elements) do
 			v.obj.visible = false
 			v.obj = nil
 		end
 		sideMessage.objs[self.id] = nil
 		self = nil
 	end

 	function obj:AddElement(drawObj,relPos)
 		self.elements[#self.elements + 1] = {obj = drawObj,relPos = relPos}
 		drawObj.position = self.bg.position + relPos
 	end

 	function obj:ShiftVec(vec)
 		self.bg.position = self.bg.position + vec
 		self.bd.position = self.bd.position + vec
 		for i,v in ipairs(self.elements) do
 			v.obj.position = v.obj.position + vec
 		end
 	end

 	function obj:SetX(x)
 		self.bg.x = x
 		self.bd.x = x
 		for i,v in ipairs(self.elements) do
 			v.obj.x = v.relPos.x + x
 		end
 	end

 	for i,v in pairs(sideMessage.objs) do
	 	if v then
	 		v:ShiftVec(Vector2D(0,-h - 3))
	 	end
	 end

 	sideMessage.objs[obj.id] = obj
 	return obj
end

 function sideMessage_Frame()
 	if sideMessage.lastTick then
	 	for i,v in pairs(sideMessage.objs) do
	 		if v then
	 			local span = GetTick() - v.createTick
	 			if span < sideMessage.ENTER_TIME then
	 				v:SetX(client.screenSize.x - (v.w-1)*span/sideMessage.ENTER_TIME)
	 			elseif span < sideMessage.ENTER_TIME + sideMessage.STAY_TIME then
	 				v:SetX(client.screenSize.x - v.w + 1)
	 			elseif span < sideMessage.ENTER_TIME + sideMessage.STAY_TIME + sideMessage.EXIT_TIME then
	 				v:SetX(client.screenSize.x - (v.w-1)*(sideMessage.ENTER_TIME + sideMessage.STAY_TIME + sideMessage.EXIT_TIME - span)/sideMessage.EXIT_TIME)
	 			else
	 				v:Destroy()
	 			end
	 		end
	 	end
	end
	sideMessage.lastTick = GetTick()
 end

 scriptEngine:RegisterLibEvent(EVENT_FRAME,sideMessage_Frame)