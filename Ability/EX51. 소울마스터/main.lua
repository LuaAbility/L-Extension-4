local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "이클립스", "PlayerInteractEvent", 1000)
end

function onEvent(funcTable)
	if funcTable[1] == "이클립스" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MS016-passiveCount") == nil then player:setVariable("MS016-passiveCount", 0) end
	local count = player:getVariable("MS016-passiveCount")
	if count > 0 then 
		count = count - 1
		player:getPlayer():getWorld():setTime(player:getPlayer():getWorld():getTime() + 14)
		game.sendActionBarMessage(player:getPlayer(), "MS016", "§6이클립스 §f: §a" .. math.ceil(count / 20) .. "초")
	else
		game.sendActionBarMessage(player:getPlayer(), "MS016", "")
	end
	
	passiveAbility(player:getPlayer())
	player:setVariable("MS016-passiveCount", count)
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS016", "")
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					LAPlayer:setVariable("MS016-passiveCount", 400)
					if event:getPlayer():getLevel() >= 30 then ability:setTime(id, 600) end
				end
			end
		end
	end
end

function passiveAbility(p)
	local currentTime = p:getWorld():getTime() % 24000

	if currentTime < 13500 or currentTime > 23500 then 
		p:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.INCREASE_DAMAGE, 3, 0}))
		p:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SLOW, 3, 0}))
	else 
		p:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SPEED, 3, 0}))
		p:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.WEAKNESS, 3, 0}))
	end
end