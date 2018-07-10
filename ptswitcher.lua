local ptswitch = {}
ptswitch.optionEnable = Menu.AddOptionBool({"Utility"}, "PT Switcher", false)
local needInit = true
local myHero
local lastStat
local nextTick = 0
function ptswitch.Init()
	myHero = Heroes.GetLocal()
	needInit = false
	nextTick = 0
end 
function ptswitch.OnGameStart()
	needInit = true
end
function ptswitch.OnUpdate()
	if not Menu.IsEnabled(ptswitch.optionEnable) or not Heroes.GetLocal() or not Engine.IsInGame() then return end
	if needInit then
		ptswitch.Init()
	end
	if not myHero then return end
	if lastStat and GameRules.GetGameTime() >= nextTick then
		local pt = NPC.GetItem(myHero, "item_power_treads", true)
		if pt then
			if PowerTreads.GetStats(pt) ~= lastStat then
				Ability.CastNoTarget(pt)
				nextTick = nextTick + 0.1
			end
			if PowerTreads.GetStats(pt) == lastStat then
				lastStat = nil
			end
		end
	end
end
function ptswitch.OnPrepareUnitOrders(orders)
	if not Menu.IsEnabled(ptswitch.optionEnable) or not myHero then return end
	if NPC.HasState(Heroes.GetLocal(), Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return end
	if orders.order ~= 5 and orders.order ~= 6 and orders.order ~= 7 and orders.order ~= 8 and orders.order ~= 9 then return end
	if not orders.ability or not Entity.IsAbility(orders.ability) then return end
	if Ability.GetManaCost(orders.ability) < 1 then return end
	local pt = NPC.GetItem(myHero, "item_power_treads", true)
	if pt then
		if NPC.IsStunned(myHero) then return end
		lastStat = PowerTreads.GetStats(pt)
		if PowerTreads.GetStats(pt) == 0 then
			Ability.CastNoTarget(pt)
		elseif PowerTreads.GetStats(pt) == 2 then
			Ability.CastNoTarget(pt)
			Ability.CastNoTarget(pt)
		end
		nextTick = GameRules.GetGameTime() + Ability.GetCastPoint(orders.ability) + 0.25
	end
end
return ptswitch