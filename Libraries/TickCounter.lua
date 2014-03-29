TickCounter = {}
TickCounter.avg = {}
TickCounter.i = 1

function TickCounter.Start()
	if not TickCounter.count then
		TickCounter.count = 0
	else
		TickCounter.count = TickCounter.count + 1
	end
	TickCounter.tick = GetTick()
	TickCounter.i = 1
end

function TickCounter.CalculateAvg()
	local i = TickCounter.i
	if TickCounter.avg[i] then
		TickCounter.avg[i] = ((TickCounter.avg[i]*TickCounter.count) + (GetTick() - TickCounter.tick))/(TickCounter.count + 1)
	else
		TickCounter.avg[i] = GetTick() - TickCounter.tick
	end
	TickCounter.i = TickCounter.i + 1
end

function TickCounter.Update()
	TickCounter.tick = GetTick()
end

function TickCounter.Print()
	for i,v in ipairs(TickCounter.avg) do
		print(i,v)
	end
end