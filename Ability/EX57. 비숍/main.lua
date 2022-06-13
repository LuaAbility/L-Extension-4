local particle = import("$.Particle")
local material = import("$.Material")

function Init(abilityData)
	plugin.registerEvent(abilityData, "프레이", "PlayerInteractEvent", 1000)
	plugin.registerEvent(abilityData, "MS006-editAttack", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "프레이" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS006-editAttack" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then editAttack(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MS006-abilityTime") == nil then player:setVariable("MS006-abilityTime", 0) end
	local count = player:getVariable("MS006-abilityTime")
	if count > 0 then 
		count = count - 1 
		if count <= 0 then endOfAbility(player)
		else cancelData(player, count) end
	end
	player:setVariable("MS006-abilityTime", count)
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS006", "")
end

function useAbility(LAPlayer, event, ability, id)
	if game.getPlayer(event:getPlayer()) ~= nil and game.getPlayer(event:getPlayer()):getVariable("MS006-gameMode") ~= nil then
		event:setCancelled(true)
	elseif event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					LAPlayer:setVariable("MS006-abilityTime", 100)
				end
			end
		end
	end
end

function endOfAbility(player)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:setVariable("MS006-Pray", false)
	end
	
	game.sendActionBarMessageToAll("MS006", "")
	game.sendMessage(player:getPlayer(), "§2[§a비숍§2] §a능력 시전 시간이 종료되었습니다. (프레이)") 
end

function cancelData(player, count)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if player:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and players[i]:getPlayer():getLocation():distance(player:getPlayer():getLocation()) <= 10 and game.targetPlayer(player, players[i], false, true) then 
			players[i]:setVariable("MS006-Pray", true)
			game.sendActionBarMessage(players[i]:getPlayer(), "MS006", "§6프레이 §f: §a" .. math.ceil(count / 20) .. "초")
		else 
			players[i]:setVariable("MS006-Pray", false) 
			game.sendActionBarMessage(players[i]:getPlayer(), "MS006", "")
		end
	end 
	
	player:setVariable("MS006-Pray", true)
	game.sendActionBarMessage(player:getPlayer(), "MS006", "§6프레이 §f: §a" .. math.ceil(count / 20) .. "초")
	
	circleEffect(player:getPlayer():getLocation(), 10)
end

function editAttack(LAPlayer, event, ability, id)
	local damager = util.getRealDamager(event:getDamager())
	if damager and game.getPlayer(damager) and event:getEntity():getType():toString() == "PLAYER" then
		local LADamager = game.getPlayer(damager)
		if LADamager:getVariable("MS006-Pray") then
			local edit = 0.25
			if LAPlayer:getPlayer():getLevel() >= 30 then edit = 0.5 end
			
			if LAPlayer == LADamager or (LAPlayer:getTeam() and LAPlayer:getTeam() == LADamager:getTeam()) then event:setDamage(event:getDamage() * (1 + edit)) 
			else event:setDamage(event:getDamage() * (1 - edit))  end
		end
	end
end

function circleEffect(loc, radius)
    local location = loc:clone()
    for i = 0, 60 do
        local angle = 2 * math.pi * i / 60
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        location:add(x, 0, z)
		location:getWorld():spawnParticle(particle.ITEM_CRACK, location, 5, 0, 0, 0, 0.1, newInstance("$.inventory.ItemStack", {import("$.Material").GOLD_BLOCK}))
        location:subtract(x, 0, z)
    end
end

