local particle = import("$.Particle")
local material = import("$.Material")
local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "리인카네이션", "EntityDamageEvent", 3600)
end

function onEvent(funcTable)
	if funcTable[1] == "리인카네이션" then reincarnation(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "리인카네이션" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then reincarnation_addDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local reincarnation = player:getVariable("MS003-reincarnation")
	if not reincarnation then
		player:setVariable("MS003-reincarnation", 0)
		player:setVariable("MS003-damageStatus", 0)
	end
	
	local abilityTime = player:getVariable("MS003-reincarnation")
	local remainDamage = 40 - player:getVariable("MS003-damageStatus")
	if player:getPlayer():getLevel() > 30 then remainDamage = 20 - player:getVariable("MS003-damageStatus") end
	
	if abilityTime > 0 then 
		local explainText = "§5리인카네이션 §f: §a" .. math.ceil(abilityTime / 20) .. "초"
		if remainDamage > 0 then explainText = explainText .. " §f/ §c남은 필요 데미지 §f: §6" .. remainDamage
		else explainText = explainText .. " §f/ §a필요 데미지 달성 완료!" end
		game.sendActionBarMessage(player:getPlayer(), "MS003", explainText)
		
		player:getPlayer():getWorld():spawnParticle(particle.REDSTONE, player:getPlayer():getLocation():add(0, 0.5, 0), 20, 0.3, 0.5, 0.3, 0, newInstance("$.Particle$DustOptions", {import("$.Color").PURPLE, 1}))
		player:getPlayer():getWorld():spawnParticle(particle.SMOKE_NORMAL, player:getPlayer():getLocation():add(0,0.5,0), 10, 0.2, 0.5, 0.2, 0.01)
		abilityTime = abilityTime - 1
		if abilityTime == 0 then checkDamage(player:getPlayer(), remainDamage) end
	else game.sendActionBarMessage(player:getPlayer(), "MS003", "") end
	
	player:setVariable("MS003-reincarnation", abilityTime)
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS003", "")
end

function checkDamage(player, remainDamage)
	if remainDamage > 0 then
		game.sendMessage(player, "§4[§c다크나이트§4] §c필요 데미지량을 충족하지 못하여 사망합니다.")
		player:setHealth(0)
		
		player:getWorld():spawnParticle(particle.REDSTONE, player:getLocation():add(0,1,0), 1, 0, 0, 0, 0, newInstance("$.Particle$DustOptions", {import("$.Color").RED, 1}))
		player:getWorld():playSound(player:getLocation(), import("$.Sound").BLOCK_BEACON_DEACTIVATE, 0.5, 2)
	else
		game.sendMessage(player, "§2[§a다크나이트§2] §a필요 데미지량을 충족하여 사망하지 않습니다.")
		
		player:getWorld():spawnParticle(particle.REDSTONE, player:getLocation():add(0,1,0), 1, 0, 0, 0, 0, newInstance("$.Particle$DustOptions", {import("$.Color").LIME, 1}))
		player:getWorld():playSound(player:getLocation(), import("$.Sound").BLOCK_BEACON_ACTIVATE, 0.5, 2)
	end
end

function reincarnation(LAPlayer, event, ability, id)
	local damagee = event:getEntity()
	
	if damagee:getType():toString() == "PLAYER" and LAPlayer:getPlayer():equals(damagee) then
		if LAPlayer:getVariable("MS003-reincarnation") > 0 then event:setCancelled(true)
		elseif damagee:getHealth() - event:getFinalDamage() <= 0 and game.checkCooldown(LAPlayer, game.getPlayer(damagee), ability, id) then
			event:setCancelled(true)
			damagee:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.HEAL, 10, 9}))
			LAPlayer:setVariable("MS003-damageStatus", 0)
			LAPlayer:setVariable("MS003-reincarnation", 200)
			
			damagee:getWorld():spawnParticle(particle.SMOKE_NORMAL, damagee:getLocation():add(0,1,0), 400, 0.2, 0.5, 0.2, 0.75)
			damagee:getWorld():playSound(damagee:getLocation(), import("$.Sound").ENTITY_WITHER_SPAWN, 0.5, 1)
		end
	end
end

function reincarnation_addDamage(LAPlayer, event, ability, id)
	local damager = util.getRealDamager(event:getDamager())
	local damagee = event:getEntity()
	
	if damager ~= nil and damager:equals(LAPlayer:getPlayer()) and damagee:getType():toString() == "PLAYER" then
		if damagee:getHealth() - event:getFinalDamage() <= 0 then LAPlayer:setVariable("MS003-damageStatus", LAPlayer:getVariable("MS003-damageStatus") + 15)
		else LAPlayer:setVariable("MS003-damageStatus", LAPlayer:getVariable("MS003-damageStatus") + math.ceil(event:getFinalDamage() + 0.5)) end
	end
end