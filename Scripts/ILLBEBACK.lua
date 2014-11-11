require("libs.Utils")

function Tick( tick )
    if PlayingGame() then
		if SleepCheck() then
	       if entityList:GetMyHero().reincarnating then
    			client:ExecuteCmd("say I'LL BE BACK")
	            Sleep(10000)
	        end
	    end
   	end
end

script:RegisterEvent(EVENT_TICK,Tick)