local particle = import("$.Particle")
local material = import("$.Material")
local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "포이즌 체인", "EntityDamageEvent", 1000)
end

function onTimer(player, ability)
	local abilityTime = player:getVariable("MS004-abilityTime")
	if not abilityTime then
		abilityTime = 0
		player:setVariable("MS004-abilityTime", 0)
	end	
	abilityTime = abilityTime - 1
	player:getPlayer():getWorld():spawnParticle(particle.REDSTONE, player:getPlayer():getLocation():add(0, 0.5, 0), 10, 0.3, 0.5, 0.3, 0, newInstance("$.Particle$DustOptions", {import("$.Color").GREEN, 0.5}))
	game.sendActionBarMessage(player:getPlayer(), "MS004", "§2포이즌 체인 §f: §c" .. math.ceil(abilityTime / 20) .. "초")
	
	if abilityTime % 40 == 0 then player:getPlayer():damage(2) end
	if abilityTime == 0 then 
		infect(player) 
		game.removeAbilityAsID(player, "LA-MS-004-HIDDEN", false)  
	end
	
	player:setVariable("MS004-abilityTime", abilityTime)
end

function Reset(player, ability)
	game.sendMessage(player:getPlayer(), "§8[§7포이즌 체인§8] §7포이즌 체인이 사라집니다.")
	game.sendActionBarMessageToAll("MS004", "")
end

function infect(player)
	player:getPlayer():getWorld():spawnParticle(particle.REDSTONE, player:getPlayer():getLocation():add(0, 0.5, 0), 2000, 5, 1, 5, 0.75, newInstance("$.Particle$DustOptions", {import("$.Color").GREEN, 1.5}))
	player:getPlayer():getWorld():spawnParticle(particle.EXPLOSION_NORMAL, player:getPlayer():getLocation():add(0, 0.5, 0), 300, 5, 1, 5, 0.05)
	player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").ENTITY_GENERIC_EXPLODE, 2, 1)
	
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if player:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
			player:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 5 then
			if players[i] ~= player and game.targetPlayer(player, players[i], true) and 
			not game.hasAbility(players[i], "LA-MS-004") and not game.hasAbility(players[i], "LA-MS-004-HIDDEN") then
				game.addAbility(players[i], "LA-MS-004-HIDDEN", false)
				game.sendMessage(players[i]:getPlayer(), "§2[§a포이즌 체인§2] §a2초마다 데미지를 입으며, 지속시간이 끝나면 주변 플레이어들에게 이 능력을 감염시킵니다.")
				players[i]:setVariable("MS004-abilityTime", 100)
			end
		end
	end
end