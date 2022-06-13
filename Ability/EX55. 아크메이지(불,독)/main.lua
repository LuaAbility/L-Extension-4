local particle = import("$.Particle")
local material = import("$.Material")
local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "포이즌 체인", "EntityDamageEvent", 1200)
end

function onEvent(funcTable)
	if funcTable[1] == "포이즌 체인" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS004", "")
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		local item = event:getDamager():getInventory():getItemInMainHand()
		if game.isAbilityItem(item, "IRON_INGOT") then
			if not game.hasAbility(game.getPlayer(event:getEntity()), "LA-MS-004-HIDDEN") and game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				event:getEntity():getWorld():spawnParticle(particle.REDSTONE, event:getEntity():getLocation():add(0, 0.5, 0), 100, 0.3, 0.5, 0.3, 0.75, newInstance("$.Particle$DustOptions", {import("$.Color").GREEN, 1.5}))
				event:getEntity():getWorld():spawnParticle(particle.EXPLOSION_NORMAL, event:getEntity():getLocation():add(0, 0.5, 0), 20, 0.3, 0.5, 0.3, 0.05)
				event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_GENERIC_EXPLODE, 0.5, 1)
				
				game.addAbility(game.getPlayer(event:getEntity()), "LA-MS-004-HIDDEN")
				game.sendMessage(event:getEntity(), "§2[§a포이즌 체인§2] §a2초마다 데미지를 입으며, 지속시간이 끝나면 주변 플레이어들에게 이 능력을 감염시킵니다.")
				if event:getDamager():getLevel() < 30 then game.getPlayer(event:getEntity()):setVariable("MS004-abilityTime", 100)
				else game.getPlayer(event:getEntity()):setVariable("MS004-abilityTime", 200) end
			end
		end
	end
end