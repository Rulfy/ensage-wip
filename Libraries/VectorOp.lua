--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0    


		Save as VectorOp.lua into Ensage\Scripts\libs.

		Functions:
			Vector:Clone(): Retruns a clone of the given Vector for copying purposes.

			Vector2D:Clone(): Retruns a clone of the given Vector2D for copying purposes.

			Vector:Unit(): Returns the unit Vector that is on  the same xy direction as the given Vector.

			Vector2D:Unit(): Returns the unit Vector2D that is on  the same xy direction as the given Vector2D.

			Vector:GetXYAngle(): Returns the XY angle of the given Vector.

			Vector2D:GetXYAngle(): Returns the XY angle of the given Vector2D.

			VectorOp.UnitVectorFromXYAngle(alpha): Creates and returns a unit Vector with given angle as its XY angle.

			VectorOp.UnitVector2DFromXYAngle(alpha): Creates and returns a unit Vector2D with given angle as its XY angle.

			Vector:GetDistance2D(a): Calculates the distance between the given Vector and parameter.

			Vector2D:GetDistance2D(a): Calculates the distance between the given Vector2D and parameter.

--]]

VectorOp = {}

function Vector:Clone()
	return Vector(self.x,self.y,self.z)
end

function Vector2D:Clone()
	return Vector2D(self.x,self.y)
end

function Vector:Unit()
	local self = self/#self
	return Vector(self.x,self.y,0)
end

function Vector2D:Unit()
	local self = self/#self
	return Vector2D(self.x,self.y)
end

function Vector:GetXYAngle()
	return math.atan2(self.y,self.x)
end

function Vector2D:GetXYAngle()
	return math.atan2(self.y,self.x)
end

function VectorOp.UnitVectorFromXYAngle(alpha)
	return Vector(math.cos(alpha),math.sin(alpha),0)
end

function VectorOp.UnitVector2DFromXYAngle(alpha)
	return Vector2D(math.cos(alpha),math.sin(alpha))
end

function Vector:GetDistance2D(a)
	assert(GetType(a) == "Vector" or GetType(a) == "LuaEntity" or GetType(a) == "Vector2D" or GetType(a) == "Projectile", "GetDistance2D: Invalid Parameter (Got "..GetType(a)..")")
	if a.x == nil or a.y == nil then
		return self:GetDistance2D(a.position)
	else
		return math.sqrt(math.pow(a.x-self.x,2)+math.pow(a.y-self.y,2))
	end
end

function Vector2D:GetDistance2D(a)
	assert(GetType(a) == "Vector" or GetType(a) == "LuaEntity" or GetType(a) == "Vector2D" or GetType(a) == "Projectile", "GetDistance2D: Invalid Parameter (Got "..GetType(a)..")")
	if a.x == nil or a.y == nil then
		return self:GetDistance2D(a.position)
	else
		return math.sqrt(math.pow(a.x-self.x,2)+math.pow(a.y-self.y,2))
	end
end