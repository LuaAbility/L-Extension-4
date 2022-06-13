local particle = import("$.Particle")
local material = import("$.Material")
local effect = import("$.potion.PotionEffectType")
local circleDelay = 60

--player:getPlayer():getLevel() >= 30

function Init(abilityData)
	plugin.registerEvent(abilityData, "콤보 인스팅트", "PlayerInteractEvent", 0)
	plugin.registerEvent(abilityData, "MS001-checkDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "콤보 인스팅트" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MS001-checkDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then checkDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local combo = player:getVariable("MS001-combo")
	if not combo then
		combo = 0
		player:setVariable("MS001-abilityTime", 0)
	end	
	
	if combo > 10 then combo = 10 end
	
	local abilityTime = player:getVariable("MS001-abilityTime")
	if abilityTime > 0 then 
		local right = newInstance("$.util.Vector", {-0.375, 0.7, 0})

		local radian = math.rad(player:getPlayer():getLocation():getYaw())
		local yAxisCos = math.cos(-radian)
		local yAxisSin = math.sin(-radian)
		
		right = player:getPlayer():getLocation():add(rotateAroundAxisY(right, yAxisCos, yAxisSin))
					
		game.sendActionBarMessage(player:getPlayer(), "MS001", "§c콤보 인스팅트 §f: §a" .. math.ceil(abilityTime / 20) .. "초")
		player:getPlayer():getWorld():spawnParticle(particle.REDSTONE, right, 3, 0.05, 0.05, 0.05, 0, newInstance("$.Particle$DustOptions", {import("$.Color").RED, 1}))
	else 
		game.sendActionBarMessage(player:getPlayer(), "MS001", "§6콤보 §f: §a" .. combo) 
		circleEffect(player:getPlayer():getLocation(), abilityTime % circleDelay, combo)
	end
	
	player:setVariable("MS001-abilityTime", abilityTime - 1)
	player:setVariable("MS001-combo", combo)
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("MS001", "")
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					if LAPlayer:getVariable("MS001-combo") >= 5 then
						LAPlayer:setVariable("MS001-abilityTime", (5 + (LAPlayer:getVariable("MS001-combo") * 2)) * 20)
						LAPlayer:setVariable("MS001-combo", 0)
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_ENDER_DRAGON_GROWL, 0.5, 1)
						event:getPlayer():getWorld():spawnParticle(particle.SMOKE_NORMAL, event:getPlayer():getLocation():add(0, 1, 0), 200, 0.1, 0.1, 0.1, 0.5)
					else
						game.sendMessage(LAPlayer:getPlayer(), "§4[§c히어로§4] §c콤보가 부족합니다.")
					end
				end
			end
		end
	end
end

function checkDamage(LAPlayer, event, ability, id)
	local damager = util.getRealDamager(event:getDamager())
	if damager ~= nil and damager:getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
			if game.targetPlayer(LAPlayer, game.getPlayer(event:getEntity()), false) then
				if LAPlayer:getVariable("MS001-abilityTime") > 0  then
					event:setDamage(event:getDamage() + event:getDamage() * 0.33)
					
					local startPos = newInstance("$.util.Vector", {util.random(6, 10) / 10f, util.random(2, 8) / 10f, -0.3})
					local endPos = newInstance("$.util.Vector", {util.random(6, 10) / 10f, util.random(10, 18) / 10f, -0.3})
					
					if util.random() >= 0.5 then startPos = startPos:setX(startPos:getX() * -1)
					else endPos = endPos:setX(endPos:getX() * -1) end
					
					local radian = math.rad(damager:getLocation():getYaw())
					local yAxisCos = math.cos(-radian)
					local yAxisSin = math.sin(-radian)
					
					startPos = event:getEntity():getLocation():add(rotateAroundAxisY(startPos, yAxisCos, yAxisSin))
					endPos = event:getEntity():getLocation():add(rotateAroundAxisY(endPos, yAxisCos, yAxisSin))
					
					drawLine(startPos, endPos, 0.05)
				elseif util.random() < 0.75 then
					LAPlayer:setVariable("MS001-combo", LAPlayer:getVariable("MS001-combo") + 1)
				end
			end
		elseif game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			if game.targetPlayer(LAPlayer, game.getPlayer(damager), false) and LAPlayer:getVariable("MS001-abilityTime") <= 0 and util.random() < 0.6 then
				LAPlayer:setVariable("MS001-combo", LAPlayer:getVariable("MS001-combo") + 1)
			end
		end
	end
end

function drawLine(point1, point2, delay)
    local world = point1:getWorld()
    local distance = point1:distance(point2)
    local p1 = point1:toVector()
    local p2 = point2:toVector()
    local vector = p2:clone():subtract(p1):normalize():multiply(0.1)
	
    for i = 0, distance, 0.1 do
		util.runLater(function()
			local loc = newInstance("$.Location", { world, p1:getX(), p1:getY(), p1:getZ() })
			world:spawnParticle(particle.REDSTONE, loc, 16, 0.025, 0.025, 0.025, 0, newInstance("$.Particle$DustOptions", {import("$.Color").RED, 1}))
			world:spawnParticle(particle.REDSTONE, loc, 8, 0.025, 0.025, 0.025, 0, newInstance("$.Particle$DustOptions", {import("$.Color").BLACK, 1}))
			p1:add(vector)
		end, math.floor(i * 10 * delay + 0.5))
    end
	
	
	util.runLater(function()
		world:playSound(point1, import("$.Sound").ENTITY_ZOMBIE_BREAK_WOODEN_DOOR, 0.3, 1)
	end, math.floor((distance / 2) * 10 * delay + 0.5))
end

function rotateAroundAxisY(v, _cos, _sin)
    local x = v:getX() * _cos + v:getZ() * _sin
    local z = v:getX() * -_sin + v:getZ() * _cos
    return v:setX(x):setZ(z)
end

function circleEffect(loc, count, combo)
    local location = loc:clone()
	
	for i = 1, 5 do
		if combo >= i then
			local angle = 2 * math.pi * count / circleDelay
			local x = math.cos(angle + (i * 30))
			local z = math.sin(angle + (i * 30))
			
			local effectOption = import("$.Color").BLUE
			if combo >= (i + 5) then effectOption = import("$.Color").RED end
			
			location:add(x, 0.2, z)
			location:getWorld():spawnParticle(particle.REDSTONE, location, 1, 0, 0, 0, 0, newInstance("$.Particle$DustOptions", {effectOption, 1.5}))
			location:subtract(x, 0.2, z)
		end
	end
end