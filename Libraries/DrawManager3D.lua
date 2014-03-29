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

 drawMgr3D = {}

 drawMgr3D.objs = {}
 drawMgr3D.id = 0

 function drawMgr3D:CreateText(pos, align3D, align2D, color, text, Font)
 	obj = {}
 	obj.pos = pos
 	obj.align3D = align3D
 	obj.align2D = align2D
 	obj.color = color
 	obj.text = text
 	obj.font = Font
 	obj.id = drawMgr3D.id
 	drawMgr3D.id = drawMgr3D.id + 1
 	obj.drawObj = drawMgr:CreateText(0,0,color,text,Font)
 	obj.visible = obj.drawObj.visible

 	function obj:Destroy()
 		self.drawObj.visible = false
 		self.drawObj = nil
 		drawMgr3D.objs[self.id] = nil
 		self = nil
 	end

 	function obj:Sync()
 		local initPos = (self.pos.position or self.pos)
 		local inScreen, screenPos = client:ScreenPosition(initPos + self.align3D)
 		if inScreen then
 			self.drawObj.visible = self.visible
 			local textSize = self.font:GetTextSize(self.text) / 2
 			local relPos = screenPos + self.align2D - textSize
 			if self.drawObj.x ~= relPos.x then
 				self.drawObj.x = relPos.x
 			end
 			if self.drawObj.y ~= relPos.y then
 				self.drawObj.y = relPos.y
 			end
 		else
 			self.drawObj.visible = false
 		end
 	end

 	function obj:SetColor(color)
 		self.color = color
 		self.drawObj.color = color
 	end

 	function obj:GetType()
 		return "DrawObject3D"
 	end

 	function obj:SetVisible(visible)
 		self.visible = visible
 		self.drawObj.visible = visible
 	end

 	function obj:SetPosition(pos)
 		self.pos = pos
 	end

 	function obj:Align3D(pos)
 		self.align3D = pos
 	end

 	function obj:Align2D(pos)
 		self.align2D = pos
 	end

 	function obj:SetText(text)
 		self.text = text
 		self.drawObj.text = text
 	end

 	obj:Sync()
 	drawMgr3D.objs[obj.id] = obj
 	return obj
 end

 function drawMgr3D:CreateRect(pos, align3D, align2D, size, color, ouTexture)
 	obj = {}
 	obj.pos = pos
 	obj.align3D = align3D
 	obj.align2D = align2D
 	obj.color = color
 	obj.size = size
 	obj.ouTexture = ouTexture
 	obj.id = drawMgr3D.id
 	drawMgr3D.id = drawMgr3D.id + 1
 	if ouTexture ~= nil then
 		obj.drawObj = drawMgr:CreateRect(0,0,size.x,size.y,color,ouTexture)
 	else
 		obj.drawObj = drawMgr:CreateRect(0,0,size.x,size.y,color)
 	end
 	obj.visible = obj.drawObj.visible

 	function obj:Destroy()
 		self.drawObj.visible = false
 		self.drawObj = nil
 		drawMgr3D.objs[self.id] = nil
 		self = nil
 	end

 	function obj:Sync()
 		local initPos = (self.pos.position or self.pos)
 		local inScreen, screenPos = client:ScreenPosition(initPos + self.align3D)
 		if inScreen then
 			self.drawObj.visible = self.visible
 			local relPos = screenPos + self.align2D - (self.size/2)
 			if self.drawObj.x ~= relPos.x then
 				self.drawObj.x = relPos.x
 			end
 			if self.drawObj.y ~= relPos.y then
 				self.drawObj.y = relPos.y
 			end
 		else
 			self.drawObj.visible = false
 		end
 	end

 	function obj:SetColor(color)
 		self.color = color
 		self.drawObj.color = color
 	end

 	function obj:GetType()
 		return "DrawObject3D"
 	end

 	function obj:SetVisible(visible)
 		self.visible = visible
 		self.drawObj.visible = visible
 	end

 	function obj:SetPosition(pos)
 		self.pos = pos
 	end

 	function obj:Align3D(pos)
 		self.align3D = pos
 	end

 	function obj:Align2D(pos)
 		self.align2D = pos
 	end

 	function obj:SetSize(size)
 		self.size = size
 		self.drawObj.size = size
 	end

 	obj:Sync()
 	drawMgr3D.objs[obj.id] = obj
 	return obj
 end

 function drawMgr3D_GlobalSync()
 	for i,v in pairs(drawMgr3D.objs) do
 		if v then
 			v:Sync()
 		end
 	end
 end

 scriptEngine:RegisterLibEvent(EVENT_FRAME,drawMgr3D_GlobalSync)