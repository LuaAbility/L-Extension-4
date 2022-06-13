local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX060-damage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX060-damage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local count = player:getVariable("EX060-abilityTime")
	if count == nil then 
		player:setVariable("EX060-abilityTime", 0) 
		player:setVariable("EX060-damageReduct", false)
		player:setVariable("EX060-seeCount", 0)
 
		count = 0
	end
	
	if count % 30 == 0 then 
		seeCheck(player) 
		
		local str = "§a관심 §f: "
		local color = "§7"
		local seeCount = player:getVariable("EX060-seeCount")
		
		if seeCount then
			if seeCount >= 4 then color = "§6"
			elseif seeCount >= 2 then color = "§b"
			elseif seeCount < 1 then color = "§c" end
			
			str = str .. color .. seeCount .. "명"
			
			game.sendActionBarMessage(player:getPlayer(), "EX060", str)
		end
	end
	
	player:setVariable("EX060-abilityTime", count + 1) 
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("EX060", "")
end

function seeCheck(player)
	local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(player, false))
	local seeCount = 0
	
	for i = 1, #players do
		if getLookingAt(players[i]:getPlayer(), player:getPlayer()) and game.targetPlayer(player, players[i], false) then seeCount = seeCount + 1 end
	end
	
	seeBuff(player, seeCount)
end

function seeBuff(player, count)
	player:setVariable("EX060-damageReduct", count >= 4)
	player:setVariable("EX060-seeCount", count)

	if count >= 2 then
		local maxHealth = player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getValue()
		if (player:getPlayer():getHealth() + 2 >= maxHealth) then player:getPlayer():setHealth(maxHealth)
		else player:getPlayer():setHealth(player:getPlayer():getHealth() + 2) end
	elseif count < 1 then
		player:getPlayer():damage(2)
	end
end

function getLookingAt(player, player1)
	local eye = player:getEyeLocation()
	local toEntity = player1:getEyeLocation():toVector():subtract(eye:toVector())
	local dot = toEntity:normalize():dot(eye:getDirection())
	
	if player:getWorld():getEnvironment() ~= player1:getWorld():getEnvironment() then dot = 0
	elseif player:getPlayer():getLocation():distance(player1:getLocation()) > 40 then dot = 0 end

	if not player:hasLineOfSight(player1) then dot = 0 end
	
	return dot > 0.6
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) and LAPlayer:getVariable("EX060-damageReduct") then
			event:setDamage(event:getDamage() * 0.75)
		end
	end
end