local powerTick = 10

function Init(abilityData) 
	plugin.registerEvent(abilityData, "차징", "PlayerInteractEvent", 600)
end

function onEvent(funcTable)
	if funcTable[1] == "차징" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("EX070-timer") == nil then 
		player:setVariable("EX070-tick", 0)
		player:setVariable("EX070-timer", 0) 
		player:setVariable("EX070-beamTime", 0)
		player:setVariable("EX070-prevCharge", false) 
		player:setVariable("EX070-isCharging", false) 
		player:setVariable("EX070-power", 0) 
	end
	
	local tick = player:getVariable("EX070-tick")
	local prevCharge = player:getVariable("EX070-prevCharge")
	local isCharging = player:getVariable("EX070-isCharging")
	
	if tick > 3 then
		tick = 0
		
		if prevCharge and not isCharging then 
			game.sendActionBarMessage(player:getPlayer(), "EX070", "")
			fire(player, ability)
		end
		
		player:setVariable("EX070-prevCharge", isCharging) 
		player:setVariable("EX070-isCharging", false)
	end
	
	if isCharging or prevCharge then 
		player:setVariable("EX070-timer", player:getVariable("EX070-timer") + 1) 
		
		local str = "차징 : "
		local power = math.floor(player:getVariable("EX070-timer") / powerTick)
		if power > 10 then power = 10 end
		
		for i = 1, power do 
			str = str .. "■" 
		end
		
		if power < 10 then
			for i = power + 1, 10 do 
				str = str .. "□" 
			end
		end
		
		game.sendActionBarMessage(player:getPlayer(), "EX070", str)
	else
		game.sendActionBarMessage(player:getPlayer(), "EX070", "")
	end
	
	local beamTime = player:getVariable("EX070-beamTime")
	if beamTime > 0 then push(player) end
	
	player:setVariable("EX070-tick", tick + 1)
	player:setVariable("EX070-beamTime", beamTime - 1)
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if not ability:isCooldown(id) then 
					LAPlayer:setVariable("EX070-isCharging", true) 
				end
			end
		end
	end
end

function fire(player, ability) 
	local power = math.floor(player:getVariable("EX070-timer") / powerTick)
	if power > 10 then power = 10
	elseif power < 1 then return 0 end
	
	local radius = power / 2.0

	local baseDir = player:getPlayer():getEyeLocation():getDirection():clone()
	local baseLoc = player:getPlayer():getEyeLocation():clone()
	
	player:setVariable("EX070-beamLoc", baseLoc)
	
	for i = 0, 20 do
		util.runLater(function()
			player:setVariable("EX070-beamLoc", baseLoc:add(baseDir:clone():multiply(radius)))
		end, i)
	end
	
	game.checkCooldown(player, player, ability, "차징")
	player:setVariable("EX070-prevCharge", false) 
	player:setVariable("EX070-isCharging", false)
	player:setVariable("EX070-timer", 0)
	player:setVariable("EX070-power", power) 
	player:setVariable("EX070-beamTime", 20)
end

function push(LAPlayer) 
	local beamLoc = LAPlayer:getVariable("EX070-beamLoc")
	local power = LAPlayer:getVariable("EX070-power")
	local radius = LAPlayer:getVariable("EX070-power") / 4.0
	local effRadius = radius / 2.0

	if beamLoc and power then
		beamLoc:getWorld():spawnParticle(import("$.Particle").REDSTONE, beamLoc, power * 100, effRadius, effRadius, effRadius, 0.05, newInstance("$.Particle$DustOptions", {import("$.Color").BLUE, 2}))
		local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(LAPlayer, false))
		for j = 1, #players do
			if players[j] ~= LAPlayer and game.targetPlayer(LAPlayer, players[j], false) then
				if beamLoc:getWorld():getEnvironment() == players[j]:getPlayer():getWorld():getEnvironment() and 
					checkhit(beamLoc, players[j]:getPlayer():getLocation():clone(), radius) then
					players[j]:getPlayer():damage(power, LAPlayer:getPlayer())
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

function checkhit(basePos, targetPos, radius)
	for i = 0, 2.0, 0.1 do
		if basePos:distance(targetPos:add(0, i, 0)) <= radius then
			return true
		end
	end
	
	return false
end