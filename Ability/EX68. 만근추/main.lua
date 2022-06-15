local particle = import("$.Particle")
local material = import("$.Material")

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX068-kill", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX068-kill" then kill(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function kill(LAPlayer, event, ability, id)
	if event:getCause():toString() == "ENTITY_ATTACK" or event:getCause():toString() == "PROJECTILE" then
		if event:getEntity():getType():toString() == "PLAYER" and game.getPlayer(event:getEntity()) == LAPlayer then
			event:getEntity():damage(event:getDamage())
			event:setCancelled(true)
		end
	end
end