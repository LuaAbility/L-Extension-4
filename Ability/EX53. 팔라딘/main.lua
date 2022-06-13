local particle = import("$.Particle")
local material = import("$.Material")


function Init(abilityData)
	plugin.registerEvent(abilityData, "생츄어리", "PlayerInteractEvent", 900)
	plugin.registerEvent(abilityData, "MS002-removeDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "생츄어리" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS002-removeDamage" then removeDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MS002-abilityTime") == nil then 
		player:setVariable("MS002-abilityTime", 0)
	end

	
	local timeCount = player:getVariable("MS002-abilityTime")
	if timeCount > 0 then
		timeCount = timeCount - 1
		if timeCount <= 0 then damage(player, ability) end
		player:setVariable("MS002-abilityTime", timeCount)
	end
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:getPlayer():setVelocity(newInstance("$.util.Vector", {0, 1.5, 0}))
					event:getPlayer():getWorld():spawnParticle(particle.SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 200, 0.2, 0.5, 0.2, 0.75)
					LAPlayer:setVariable("MS002-abilityTime", 40)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_HORSE_BREATHE, 1, 2)
					
					util.runLater(function()
						event:getPlayer():setVelocity(newInstance("$.util.Vector", {0, -5, 0}))
						event:getPlayer():getWorld():spawnParticle(particle.SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 200, 0.2, 0.5, 0.2, 0.75)
					end, 20)
				end
			end
		end
	end
end

function removeDamage(LAPlayer, event, ability, id)
	if event:getCause():toString() == "FALL" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) and LAPlayer:getVariable("MS002-abilityTime") > 0 then
			event:setCancelled(true)
			damage(LAPlayer, ability)
		end
	end
end

function damage(player, ability)
	local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(player, false))
	for i = 1, #players do
		if players[i] ~= player and game.targetPlayer(player, players[i], false) then
			if player:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
			player:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 7 then
				players[i]:getPlayer():damage(6, player:getPlayer())
				if player:getPlayer():getLevel() >= 30 then players[i]:getPlayer():setVelocity(newInstance("$.util.Vector", {0, 1.2, 0})) end
				
				players[i]:getPlayer():getWorld():spawnParticle(particle.EXPLOSION_LARGE, players[i]:getPlayer():getLocation(), 1, 0, 0, 0, 0.05)
			end
			
			player:getPlayer():getWorld():spawnParticle(particle.SMOKE_NORMAL, player:getPlayer():getLocation():add(0,1,0), 200, 0.2, 0.5, 0.2, 0.75)
			player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").BLOCK_ANVIL_PLACE, 0.5, 0.5)
			
			player:setVariable("MS002-abilityTime", 0)
		end
	end
end