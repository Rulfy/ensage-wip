--[[
		Save as TickCounter.lua into Ensage\Scripts\libs.

		Functions:
			TickCounter.new(): 				Creates a new TickCounter instance for your script

			TickCounter:Start():			Resets everything (is called automatically after creating a new instance)
			TickCounter:SetMaxCount(count):	Sets a new max count for saved tick values to calculate the average. Default value is 100
			TickCounter:Update():			Updates the internal tick values. Should be always called when you want to see the tick change (at least once per tick)
			TickCounter:Print():			Prints the current avg-tick and the last tick difference (between two update calls)
			TickCounter:CalculateAvg():		Returns the avg tick value
			TickCounter:CalculateDiff(): 	Returns the tick difference between two last update calls

		Example:
			perf = TickCounter.new()
			perf:Start()

			function Tick(tick)
				perf:Update()
				-- do some calculations and script stuff here
				perf:Update()
				perf:Print() -- will give you the tick difference = time [ms] and the avg tick diff (if called multiple times)
			end

		script:RegisterEvent(EVENT_TICK,Tick)
--]]

TickCounter = {}

function TickCounter.new()
	local result = 
		{	
			Start=TickCounter.Start, 
			CalculateDiff = TickCounter.CalculateDiff,
			CalculateAvg = TickCounter.CalculateAvg, 
			Update = TickCounter.Update, 
			Print = TickCounter.Print,
			SetMaxCount = TickCounter.SetMaxCount
		}
	result:Start()
	return result
end

function TickCounter:Start()
	self.tick = GetTick()
	self.maxCount = 100
	self.avg = {}
	self.avg[1] = self.tick
	if not self.maxCount or self.maxCount < 2 then
		self.maxCount = 2
	end
end

function TickCounter:SetMaxCount(count)
	self.maxCount = count
	if not self.maxCount or self.maxCount < 2 then
		self.maxCount = 2
	end
end

function TickCounter:CalculateAvg()
	-- need at least 2 values for an avg diff...
	if #self.avg < 2 then 
		return 0
	end
	
	local len = #self.avg - 1
	local sum = 0
	for i=1,len,1 do
		sum = sum + math.abs(self.avg[i+1] - self.avg[i])
	end
	return sum / len
end

function TickCounter:CalculateDiff()
	-- need at least 2 values for an diff...
	if #self.avg < 2 then 
		return 0
	end
	return self.tick - (self.avg[#self.avg-1] or self.avg[self.maxCount])
end

function TickCounter:Update()
	local tick = GetTick()
	-- only update if something has changed..
	if tick == self.tick then
		return
	end
	self.tick = tick
	
	if #self.avg == self.maxCount then
		table.remove(self.avg, 1)
	end
	-- safe new values for avg
	table.insert(self.avg, self.tick)
end

function TickCounter:Print()
	print("Last tick diff: ", self:CalculateDiff())
	print("Avg tick diff:  ", self:CalculateAvg())
end