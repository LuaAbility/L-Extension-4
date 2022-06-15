local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX006-curse", "PlayerDeathEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX006-curse" then curse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function curse(LAPlayer, event, ability, id)
	local damageEvent = event:getEntity():getLastDamageCause()
	
	if (damageEvent ~= nil and damageEvent:isCancelled() == false and damageEvent:getEventName() == "EntityDamageByEntityEvent") then
		local damagee = damageEvent:getEntity()
		local damager = util.getRealDamager(damageEvent:getDamager())
		
		if damager ~= nil and damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
			if game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
				if game.targetPlayer(LAPlayer, game.getPlayer(damagee)) then
					local id = {}
					local abilities = util.getTableFromList(game.getPlayer(damagee):getAbility())
					for i = 1, #abilities do
						if 	abilities[i].abilityID == "LA-EX-006" or 
							abilities[i].abilityID == "LA-EX-007" or 
							abilities[i].abilityID == "LA-MW-015" then
							return 0 
						end
						
						if not LAPlayer:hasAbility(abilities[i].abilityID) then 
							table.insert(id, abilities[i].abilityID) 
						end
					end
					
					if #id < 1 then return 0 end
					
					local randomIndex = util.random(1, #id)
					if not LAPlayer:hasAbility(id[randomIndex]) then
						game.addAbility(LAPlayer, id[randomIndex], false)
						game.sendMessage(event:getDamager(), "§2[§a흡수§2] ".. id[randomIndex] .. "§a 능력을 얻었습니다.")
						util.executeCommand("la ability " .. id[randomIndex], 1, damagee)
					end
				end
			end
		end
	end
end