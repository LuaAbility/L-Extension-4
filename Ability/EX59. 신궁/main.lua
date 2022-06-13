local particle = import("$.Particle")
local material = import("$.Material")
local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "소울 애로우", "PlayerInteractEvent", 800)
	plugin.registerEvent(abilityData, "MS008-removeGravity", "EntityShootBowEvent", 0)
	plugin.registerEvent(abilityData, "MS008-hitArrow", "ProjectileHitEvent", 0)
	plugin.registerEvent(abilityData, "MS008-cancelDrop", "PlayerDropItemEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MS008-abilityUse" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS008-removeGravity" then removeGravity(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS008-hitArrow" then hitArrow(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS008-cancelDrop" then cancelDrop(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local count = player:getVariable("MS008-shootCount")
	if not count then
		count = 0
		player:setVariable("MS008-shootCount", count)
	end
	
	if player:getPlayer():getLevel() >= 30 then player:setVariable("MS008-expCount", 3) 
	else player:setVariable("MS008-expCount", 5) end
	
	if count == player:getVariable("MS008-expCount") then
		player:getPlayer():getWorld():spawnParticle(particle.SMOKE_NORMAL, player:getPlayer():getLocation():add(0, 0.5, 0), 2, 0.2, 0.5, 0.2, 0.05)
	end
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS008", "")
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local bows = util.getTableFromMap(event:getPlayer():getInventory():all(material.BOW))
					for i = 1, #bows do
						local itemMeta = bows[i]:getItemMeta()
						if itemMeta:hasEnchant(import("$.enchantments.Enchantment").ARROW_INFINITE) ~= true then 
							itemMeta:addEnchant(import("$.enchantments.Enchantment").ARROW_INFINITE, 1, true) 
							local lore = newInstance("java.util.ArrayList", {})
							lore:add("§7능력의 힘으로 강화되었습니다.")
							itemMeta:setLore( lore )
							bows[i]:setItemMeta(itemMeta)
						end
					end
					
					util.runLater(function()
						bows = util.getTableFromMap(event:getPlayer():getInventory():all(material.BOW))
						for i = 1, #bows do
							local itemMeta = bows[i]:getItemMeta()
							if itemMeta:hasEnchant(import("$.enchantments.Enchantment").ARROW_INFINITE) == true then 
								local lore = itemMeta:getLore()
								if lore and lore:contains("§7능력의 힘으로 강화되었습니다.") then
									itemMeta:setLore(newInstance("java.util.ArrayList", {}))
									itemMeta:removeEnchant(import("$.enchantments.Enchantment").ARROW_INFINITE)
									bows[i]:setItemMeta(itemMeta)
								end 
							end
						end
					end, 200)
				end
			end
		end
	end
end

function cancelDrop(LAPlayer, event, ability, id)
	local itemMeta = event:getItemDrop():getItemStack():getItemMeta()
	if itemMeta:hasEnchant(import("$.enchantments.Enchantment").ARROW_INFINITE) == true then 
		local lore = itemMeta:getLore()
		if lore:contains("§7능력의 힘으로 강화되었습니다.") then
			event:setCancelled(true)
		end 
	end
end

function removeGravity(LAPlayer, event, ability, id)
	if event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) and event:getProjectile():getVelocity():length() > 2.9f then
			if LAPlayer:getVariable("MS008-shootCount") == LAPlayer:getVariable("MS008-expCount") then
				LAPlayer:setVariable("MS008-shootCount", 0)
				LAPlayer:setVariable("MS008-expArrow", event:getProjectile())
			else 
				LAPlayer:setVariable("MS008-shootCount", LAPlayer:getVariable("MS008-shootCount") + 1)
			end
			
			event:getProjectile():setGravity(false)
			event:getProjectile():setVelocity(event:getProjectile():getVelocity():multiply(2))
			event:getProjectile():setDamage(event:getProjectile():getDamage() * 0.5f)
		end
	end
end


function hitArrow(LAPlayer, event, ability, id)
	if LAPlayer:getVariable("MS008-expArrow") and event:getEntity() == LAPlayer:getVariable("MS008-expArrow") then
		if event:getHitBlock() then 
			event:getEntity():getWorld():createExplosion(event:getHitBlock():getLocation():add(0, 1.5, 0), 1.5)
			event:getEntity():getWorld():spawnParticle(particle.EXPLOSION_HUGE, event:getHitBlock():getLocation(), 1, 1, 1, 1, 0.05)
		elseif event:getHitEntity() then 
			event:getEntity():getWorld():createExplosion(event:getHitEntity():getLocation(), 1.5) 
			event:getEntity():getWorld():spawnParticle(particle.EXPLOSION_HUGE, event:getHitEntity():getLocation(), 1, 1, 1, 1, 0.05)
		end
		event:getEntity():remove()
	end
end