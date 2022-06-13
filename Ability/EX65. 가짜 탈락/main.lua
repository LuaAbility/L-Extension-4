function Init(abilityData)
	plugin.registerEvent(abilityData, "EX065-collectQuestion-onDead", "AsyncPlayerChatEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX065-collectQuestion-onDead" then checkChat(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if not player:getVariable("EX065-deathTimer-noRemove") then
		player:setVariable("EX065-deathTimer-noRemove", 0)
	end
	
	if player:getVariable("EX065-canUse") == nil then
		local count = player:getVariable("EX065-deathTimer-noRemove")
		if count <= 1200 then
			game.sendActionBarMessage(player:getPlayer(), "EX065", "남은 시간 : " .. math.floor((1200 - player:getVariable("EX065-deathTimer-noRemove")) / 20) .. "초")
		else
			game.sendActionBarMessage(player:getPlayer(), "EX065", "부활 불가")
		end
		
		player:setVariable("EX065-deathTimer-noRemove", player:getVariable("EX065-deathTimer-noRemove") + 1)
	end
end

function onDeadTimer(player, ability)
	if player:getVariable("EX065-deathTimer-noRemove") <= 1200 and #util.getTableFromList(game.getPlayers()) > 2 then
		player:setVariable("EX065-canUse", true)
		game.sendActionBarMessage(player:getPlayer(), "EX065", "부활 가능!")
	else
		player:setVariable("EX065-canUse", false)
		game.sendActionBarMessage(player:getPlayer(), "EX065", "부활 불가")
	end
end

function checkChat(LAPlayer, event, ability, id)
	if event:getPlayer() == LAPlayer:getPlayer() and LAPlayer:getVariable("EX065-canUse") then
		if event:getMessage() ~= nil and string.find(event:getMessage(), "개같이 부활") then
			LAPlayer.isSurvive = true
			LAPlayer.lifeCount = plugin.getPlugin().gameManager.defaultLife
			LAPlayer:setVariable("EX065-canUse", false)
			
			game.sendActionBarMessage(LAPlayer:getPlayer(), "EX065", "")
			
			util.runLater(function()
				LAPlayer:getPlayer():setGravity(true)
				LAPlayer:getPlayer():getInventory():clear()
				
				LAPlayer:getPlayer():teleport(plugin.getPlugin().gameManager:getVariable("-spawn"))
				LAPlayer:getPlayer():setBedSpawnLocation(plugin.getPlugin().gameManager:getVariable("-spawn"), true)
				
				LAPlayer:getPlayer():getInventory():addItem(plugin.getPlugin().gameManager:getVariable("-item"))
				LAPlayer:getPlayer():getInventory():setArmorContents(plugin.getPlugin().gameManager:getVariable("-equip"))
				
				LAPlayer:getPlayer():setGameMode(import("$.GameMode").SURVIVAL)
			end, 2)
		end
	end
end