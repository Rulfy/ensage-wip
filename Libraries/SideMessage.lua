--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0  


	Functions:
		msg = sideMessage:CreateMessage(w,h[,bgColor,bdColor,
											enterTime,stayTime,exitTime]): 	
													Creates a new sideMessage object with the given width and height.
													You may also give an optional frame and background color.
													The last 3 parameters are used for the timings of the side message.
													After the exit time, the message is automaticalle destroyed.

	msg:AddElement(drawObject):						Add any draw object to the newly created side message. 
													The position of the draw object will be used as an relative position!
													Please only add elements after freshly creating a message, since it may become invalid after the exitTime passed.

	Attributes (please don't change them):
		sideMessage.ENTER_TIME: default enter time is 650 ms.
		sideMessage.STAY_TIME:	default stay time is 2500 ms.
		sideMessage.EXIT_TIME: 	default exit time is 650 ms.

		sideMessage.bgColor: 	default color of the background.
		sideMessage.bdColor:	default color of the frame.
															
	Example:
		do
			local myFont = drawMgr:CreateFont("sideMsg","Arial",14,10) 
			local msg = sideMessage:CreateMessage(300,40)
			msg:AddElement( drawMgr:CreateText(5,5,-1,"Hello world",myFont) )
			msg:AddElement( drawMgr:CreateText(5,20,-1,"The game is already running "..math.floor(client.gameTime) .." seconds",myFont) )
		end
 ]]


sideMessage = {}

sideMessage.lastTick = nil
sideMessage.objs = {}

sideMessage.ENTER_TIME = 650
sideMessage.STAY_TIME = 2500
sideMessage.EXIT_TIME = 650
sideMessage.bgColor = 0x111111C0
sideMessage.bdColor = 0x444444FF

function sideMessage:CreateMessage(pw,ph,pbgColor,pbdColor,penterTime,pstayTime,pexitTime)
	if not pbgColor then pbgColor = self.bgColor end
	if not pbdColor then pbdColor = self.bdColor end
	if not penterTime then penterTime = self.ENTER_TIME end
	if not pstayTime then pstayTime = self.STAY_TIME end
	if not pexitTime then pexitTime = self.EXIT_TIME end

	local screenSize = client.screenSize
	local selfMsg = self
	local obj = {
		w = pw, h = ph,
		bgColor = pbgColor, bdColor = pbdColor,
		bg = drawMgr:CreateRect(screenSize.x,screenSize.y*0.64,pw,ph,pbgColor),
 		bd = drawMgr:CreateRect(screenSize.x,screenSize.y*0.64,pw,ph,pbdColor,true),
 		enterTime = penterTime, stayTime = pstayTime, exitTime = pexitTime,
 		createTick = GetTick(),
 		elements = {},
	 		Destroy = 	function(self)
	 						self.bg.visible = false
					 		self.bg = nil
					 		self.bd.visible = false
					 		self.bd = nil
					 		for _,v in ipairs(self.elements) do
					 			v.obj.visible = false
					 			v.obj = nil
					 		end
	 					end,
 		AddElement = 	function(self,drawObj)
 							table.insert(self.elements, {obj=drawObj,pos=drawObj.position})
				 			drawObj.position = drawObj.position + self.bg.position
				 		end,
		ShiftVec =	 	function(self,vec)
					 		self.bg.position = self.bg.position + vec
					 		self.bd.position = self.bd.position + vec
					 		for _,v in ipairs(self.elements) do
					 			v.obj.position = v.obj.position + vec
					 		end
 						end,
 		SetX =			function(self,x)
					 		self.bg.x = x
					 		self.bd.x = x
					 		for _,v in ipairs(self.elements) do
					 			v.obj.x = v.pos.x + x
					 		end
					 	end

	}

 	for _,v in ipairs(self.objs) do
	 	if v then
	 		v:ShiftVec(Vector2D(0,-ph - 3))
	 	end
	 end
	table.insert(self.objs,obj)
 	return obj
end

 function sideMessage:Frame(tick)
 	if self.lastTick then
 		local saved = {}
	 	for i,v in ipairs(self.objs) do
	 		if v then
	 			local span = GetTick() - v.createTick
	 			if span < v.enterTime then
	 				v:SetX(client.screenSize.x - (v.w-1)*span/v.enterTime)
	 				table.insert(saved,v)
	 			elseif span < v.enterTime + v.stayTime then
	 				v:SetX(client.screenSize.x - v.w + 1)
	 				table.insert(saved,v)
	 			elseif span < v.enterTime + v.stayTime + v.exitTime then
	 				v:SetX(client.screenSize.x - (v.w-1)*(v.enterTime + v.stayTime + v.exitTime - span)/v.exitTime)
	 				table.insert(saved,v)
	 			else
	 				v:Destroy()
	 			end
	 		end
	 	end
	 	self.objs = saved
	end
	self.lastTick = GetTick()
 end

 scriptEngine:RegisterLibEvent(EVENT_FRAME,sideMessage.Frame,sideMessage)