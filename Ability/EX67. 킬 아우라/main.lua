function Init(abilityData) 
	plugin.registerEvent(abilityData, "킬 아우라", "PlayerInteractEvent", 600)
end

function onEvent(funcTable)
	if funcTable[1] == "킬 아우라" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					hacked(LAPlayer)
				end
			end
		end
	end
end

function hacked(lap) 
	local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(lap, false))
	for i = 1, #players do
		if players[i] ~= lap and game.targetPlayer(lap, players[i], false) then
			if lap:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
			lap:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 4 then
				local damageAmount = 1
				local targetItem = event:getPlayer():getInventory():getItemInOffHand()
				if targetItem and targetItem:getType():toString() ~= "AIR" then 
					local itemMeta = targetItem:getItemMeta()
					
					if itemMeta:hasAttributeModifiers() then 
						local damagies = util.getTableFromList(itemMeta:getAttributeModifiers(attribute.GENERIC_ATTACK_DAMAGE))
						for j = 1, #damagies do
							damageAmount = damageAmount + damagies[j]:getAmount()
						end
						
						if damageAmount > 1 then damageAmount = damageAmount - 1 end
					else damageAmount = weaponDamage(targetItem:getType()) end
				end
				
				players[i]:getPlayer():damage(damageAmount, lap:getPlayer())
			end
		end
	end
end

function weaponDamage(itemType)
	local material = import("$.Material")
	if 		itemType == material.TRIDENT 			then	return  9.0 
	elseif 	itemType == material.WOODEN_SWORD 		then	return  4.0 
	elseif 	itemType == material.STONE_SWORD 		then	return  5.0 
	elseif 	itemType == material.IRON_SWORD 		then	return  6.0 
	elseif 	itemType == material.GOLDEN_SWORD 		then	return  4.0 
	elseif 	itemType == material.DIAMOND_SWORD 		then	return  7.0  
	elseif 	itemType == material.NETHERITE_SWORD 	then	return  8.0  
	elseif 	itemType == material.WOODEN_AXE 		then	return  7.0 
	elseif 	itemType == material.STONE_AXE 			then	return  9.0  
	elseif 	itemType == material.IRON_AXE 			then	return  9.0 
	elseif 	itemType == material.GOLDEN_AXE 		then	return  7.0 
	elseif 	itemType == material.DIAMOND_AXE 		then	return  9.0 
	elseif 	itemType == material.NETHERITE_AXE 		then	return 10.0 
	elseif 	itemType == material.WOODEN_SHOVEL 		then	return  2.5 
	elseif 	itemType == material.WOODEN_PICKAXE 	then	return  2.0  
	elseif 	itemType == material.STONE_SHOVEL 		then	return  3.5 
	elseif 	itemType == material.STONE_PICKAXE 		then	return  3.0  
	elseif 	itemType == material.IRON_SHOVEL 		then	return  4.5 
	elseif 	itemType == material.IRON_PICKAXE 		then	return  4.0  
	elseif 	itemType == material.GOLDEN_SHOVEL 		then	return  2.5 
	elseif 	itemType == material.GOLDEN_PICKAXE 	then	return  2.0  
	elseif 	itemType == material.DIAMOND_SHOVEL 	then	return  5.5 
	elseif 	itemType == material.DIAMOND_PICKAXE 	then	return  5.0  
	elseif 	itemType == material.NETHERITE_SHOVEL 	then	return  6.5 
	elseif 	itemType == material.NETHERITE_PICKAXE 	then	return  6.0 
	else 													return  1.0 end
end