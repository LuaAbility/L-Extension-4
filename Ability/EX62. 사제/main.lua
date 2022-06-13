local particle = import("$.Particle")
local material = import("$.Material")
local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "신성한 폭발", "PlayerInteractEvent", 1000)
end

function onEvent(funcTable)
	if funcTable[1] == "신성한 폭발" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("EX062", "")
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					useFunc(LAPlayer)
				end
			end
		end
	end
end

function useFunc(player)
	local players = util.getTableFromList(game.getPlayers())
	local enemy = {}
	local team = {}
	
	for i = 1, #players do
		if player == players[i] then table.insert(team, players[i])
		elseif player:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and players[i]:getPlayer():getLocation():distance(player:getPlayer():getLocation()) <= 5 and game.targetPlayer(player, players[i], false, true) then 
			if player:getTeam() and player:getTeam() == players[i]:getTeam() then table.insert(team, players[i])
			else table.insert(enemy, players[i]) end
		end
	end 
	
	for i = 1, #enemy do
		enemy[i]:getPlayer():damage(10 / (#enemy))
	end 
	
	for i = 1, #team do
		local healAmount = 10 / (#team)
		
		local maxHealth = team[i]:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getValue()
		if (team[i]:getPlayer():getHealth() + healAmount >= maxHealth) then team[i]:getPlayer():setHealth(maxHealth)
		else team[i]:getPlayer():setHealth(team[i]:getPlayer():getHealth() + healAmount) end
	end 
end

