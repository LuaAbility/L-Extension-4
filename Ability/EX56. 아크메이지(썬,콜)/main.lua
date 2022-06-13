local particle = import("$.Particle")
local material = import("$.Material")
local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "썬더 브레이크", "PlayerInteractEvent", 1200)
	plugin.registerEvent(abilityData, "MS005-checkLightning", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MS005-removeFreeze", "PlayerDeathEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "썬더 브레이크" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS005-checkLightning" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then checkLightning(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS005-removeFreeze" then removeFreeze(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local abilityTime = player:getVariable("MS005-abilityTime")
	if not abilityTime then
		abilityTime = 0
		player:setVariable("MS005-abilityTime", 0)
	end	
	
	if abilityTime > 0 then player:setVariable("MS005-abilityTime", abilityTime - 1) end
end

function removeFreeze(LAPlayer, event, ability, id)
	local damageEvent = event:getEntity():getLastDamageCause()
	
	if damageEvent ~= nil and damageEvent:isCancelled() == false then
		damageEvent:getEntity():setFreezeTicks(0)
	end
end

function checkLightning(LAPlayer, event, ability, id)
	local damager = util.getRealDamager(event:getDamager())
	if damager ~= nil and damager:getType():toString() == "LIGHTNING" and event:getEntity():getType():toString() == "PLAYER" then
		local tables = LAPlayer:getVariable("MS005-lightning")
		if tables then
			for i = 1, #tables do
				if tables[i] == damager then
					if event:getEntity():equals(LAPlayer:getPlayer()) then event:setCancelled(true)
					else event:getEntity():setFreezeTicks(400) end
				end
			end
		end
	end
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS005", "")
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():setFreezeTicks(0)
	end
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local maxLightning = 2
					if event:getPlayer():getLevel() >= 30 then maxLightning = 4 end
					
					local baseLoc = event:getPlayer():getLocation():clone()
					local radian = math.rad(baseLoc:getYaw())
					local yAxisCos = math.cos(-radian)
					local yAxisSin = math.sin(-radian)
					local append = newInstance("$.util.Vector", {0, 0, 5})
					local addLoc = rotateAroundAxisY(append, yAxisCos, yAxisSin)
					
					
					LAPlayer:setVariable("MS005-lightning", { })
		
					for i = 0, maxLightning do
						util.runLater(function()
							baseLoc = baseLoc:add(addLoc:getX(), 0, addLoc:getZ())
							table.insert(LAPlayer:getVariable("MS005-lightning"), baseLoc:getWorld():spawnEntity(baseLoc:add(1, 0, 1), import("$.entity.EntityType").LIGHTNING))
							table.insert(LAPlayer:getVariable("MS005-lightning"), baseLoc:getWorld():spawnEntity(baseLoc:add(1, 0, -1), import("$.entity.EntityType").LIGHTNING))
							table.insert(LAPlayer:getVariable("MS005-lightning"), baseLoc:getWorld():spawnEntity(baseLoc:add(-1, 0, 1), import("$.entity.EntityType").LIGHTNING))
							table.insert(LAPlayer:getVariable("MS005-lightning"), baseLoc:getWorld():spawnEntity(baseLoc:add(-1, 0, -1), import("$.entity.EntityType").LIGHTNING))
							baseLoc:getWorld():spawnParticle(particle.EXPLOSION_HUGE, baseLoc, 2, 0, 0, 0, 0.05)
							baseLoc:getWorld():spawnParticle(import("$.Particle").SNOWFLAKE, baseLoc:clone():add(0, 0.5, 0), 500, 3, 1, 3, 0.05)
						end, i * 15)
					end
				end
			end
		end
	end
end

function rotateAroundAxisY(v, _cos, _sin)
    local x = v:getX() * _cos + v:getZ() * _sin
    local z = v:getX() * -_sin + v:getZ() * _cos
    return v:setX(x):setZ(z)
end