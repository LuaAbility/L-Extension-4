local particle = import("$.Particle")
local material = import("$.Material")
local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "애로우 플래터", "PlayerInteractEvent", 100)
end

function onEvent(funcTable)
	if funcTable[1] == "애로우 플래터" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local blocks = player:getVariable("MS007-blocks")
	if not blocks then
		player:setVariable("MS007-blocks", {})
		player:setVariable("MS007-maxBow", 1)
		player:setVariable("MS007-currentCount", 2)
		player:setVariable("MS007-count", 0)
	end
	
	if player:getVariable("MS007-count") % 2 == 0 then shootTurret(player) end
	player:setVariable("MS007-count", player:getVariable("MS007-count") + 1)
	
	if player:getPlayer():getLevel() >= 30 then player:setVariable("MS007-maxBow", 2)
	else player:setVariable("MS007-maxBow", 1) end
	
	if blocks then
		for i = 1, #blocks do
		end
	end
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS007", "")
	local block = player:getVariable("MS007-blocks")
	if block then
		for i = 1, #block do
			resetTurret(block[i])
		end
	end
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getItem() ~= nil then
		if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
				if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
					local blocks = LAPlayer:getVariable("MS007-blocks")
					if #blocks < LAPlayer:getVariable("MS007-maxBow") then
						table.insert(blocks, event:getPlayer():getLocation():getBlock():getLocation():add(0.5, 1, 0.5))
						blocks[#blocks]:setDirection(event:getPlayer():getLocation():getDirection())
					else
						local targetBlock = blocks[1 + (LAPlayer:getVariable("MS007-currentCount") % LAPlayer:getVariable("MS007-maxBow"))]
						resetTurret(targetBlock)
						
						targetBlock = event:getPlayer():getLocation():getBlock():getLocation():add(0.5, 1, 0.5)
						targetBlock:setDirection(event:getPlayer():getLocation():getDirection())
						blocks[1 + (LAPlayer:getVariable("MS007-currentCount") % LAPlayer:getVariable("MS007-maxBow"))] = targetBlock
						
						LAPlayer:setVariable("MS007-currentCount", LAPlayer:getVariable("MS007-currentCount") + 1)
					end
					
					LAPlayer:setVariable("MS007-blocks", blocks)
				end
			end
			
			if LAPlayer == game.getPlayer(event:getPlayer()) and event:getAction():toString() == "LEFT_CLICK_AIR" or event:getAction():toString() == "LEFT_CLICK_BLOCK" then
				LAPlayer:setVariable("MS007-blocks", {})
				LAPlayer:setVariable("MS007-currentCount", LAPlayer:getVariable("MS007-maxBow"))
				game.sendMessage(event:getPlayer(), "§2[§a보우마스터§2] §a설치한 터렛을 모두 제거했습니다.")
			end
		end
	end
end

function resetTurret(loc)
	if loc then
		loc:getWorld():spawnParticle(particle.SMOKE_LARGE, loc, 500, 0, 0, 0, 0.05)
	end
end

function shootTurret(player)
	local block = player:getVariable("MS007-blocks")
	if block then
		for i = 1, #block do
			local dir = newInstance("$.util.Vector", {block[i]:getDirection():getX(), 0.2, block[i]:getDirection():getZ()})
			local arrow = block[i]:getWorld():spawnEntity(block[i]:clone():add(dir), import("$.entity.EntityType").ARROW)
			arrow:setVelocity(dir)
			arrow:setShooter(player:getPlayer())
			arrow:setDamage(3)
			arrow:setPickupStatus(import("$.entity.AbstractArrow$PickupStatus").DISALLOWED)
			
			block[i]:getWorld():playSound(block[i], import("$.Sound").ENTITY_ARROW_SHOOT, 0.1, 1)
			block[i]:getWorld():spawnParticle(import("$.Particle").REDSTONE, block[i], 100, 0.15, 0.15, 0.15, 0.05, newInstance("$.Particle$DustOptions", {import("$.Color").AQUA, 1}))
			block[i]:getWorld():spawnParticle(import("$.Particle").REDSTONE, block[i], 100, 0.15, 0.15, 0.15, 0.05, newInstance("$.Particle$DustOptions", {import("$.Color").BLACK, 1}))
		end
	end
end