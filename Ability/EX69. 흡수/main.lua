local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX061-damage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "EX061-getHealth", "PlayerDeathEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX061-damage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX061-getHealth" then getHealth(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local count = player:getVariable("EX061-abilityTime")
	if count == nil then 
		player:setVariable("EX061-abilityTime", 100) 
		count = 100
	end
	
	if count == 0 then 
		local currenthealth = player:getPlayer():getHealth()
		local reductHealth = (player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getBaseValue() * 0.1f)
		
		currenthealth = currenthealth - reductHealth
		if currenthealth < 0 then currenthealth = 0 end
		
		player:getPlayer():setHealth(currenthealth)
	end
	
	player:setVariable("EX061-abilityTime", count - 1) 
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("EX061", "")
end

function getHealth(LAPlayer, event, ability, id)
	local damageEvent = event:getEntity():getLastDamageCause()
	
	if (damageEvent ~= nil and damageEvent:isCancelled() == false and damageEvent:getEventName() == "EntityDamageByEntityEvent") then
		local damagee = damageEvent:getEntity()
		local damager = damageEvent:getDamager()
		
		if damager ~= nil and damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
			if game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
				local maxHealth = damager:getAttribute(attribute.GENERIC_MAX_HEALTH):getBaseValue()
				damager:setHealth(maxHealth)
			end
		end
	end
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) and LAPlayer:getVariable("EX061-damageReduct") then
			event:setDamage(event:getDamage() * 0.75)
		end
	end
end