local attribute = import("$.attribute.Attribute")
local effect = import("$.potion.PotionEffectType")
local material = import("$.Material")

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX064-onEliminate-ignoreDead", "PlayerEliminateEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX064-onEliminate-ignoreDead" then onEliminate(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("EX064-correct-noRemove") and player:getVariable("EX064-isAlive") then
		player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.INCREASE_DAMAGE, 40, 0}))
		player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.REGENERATION, 40, 0}))
		game.sendActionBarMessage(player:getPlayer(), "EX064", "§e예언 성공!")
	end
	
	if player:getVariable("EX064-correct-noRemove") == nil then
		if not player:getVariable("EX064-openUI-noRemove") then 
			player:setVariable("EX064-openUI-noRemove", true)
			useFunc(player)
		elseif player:getVariable("EX064-target-noRemove") then
			local str = "§e예언 §f: §6" .. player:getVariable("EX064-target-noRemove"):getName()
			game.sendActionBarMessage(player:getPlayer(), "EX064", str)
		end
	end
end

function onDeadTimer(player, ability)
	if player:getVariable("EX064-correct-noRemove") then
		player.isSurvive = true
		player.lifeCount = plugin.getPlugin().gameManager.defaultLife
		player:setVariable("EX064-correct-noRemove", false)
		
		game.sendActionBarMessage(player:getPlayer(), "EX064", "§e예언 성공!")
		
		util.runLater(function()
			player:getPlayer():setGravity(true)
			player:getPlayer():getInventory():clear()
			
			player:getPlayer():teleport(plugin.getPlugin().gameManager:getVariable("-spawn"))
			player:getPlayer():setBedSpawnLocation(plugin.getPlugin().gameManager:getVariable("-spawn"), true)
			
			player:getPlayer():getInventory():addItem(plugin.getPlugin().gameManager:getVariable("-item"))
			player:getPlayer():getInventory():setArmorContents(plugin.getPlugin().gameManager:getVariable("-equip"))
			
			player:getPlayer():setGameMode(import("$.GameMode").SURVIVAL)
		end, 2)
	end
	
	if player:getVariable("EX064-correct-noRemove") == nil then
		if player:getVariable("EX064-target-noRemove") then
			local str = "§e예언 §f: §6" .. player:getVariable("EX064-target-noRemove"):getName()
			game.sendActionBarMessage(player:getPlayer(), "EX064", str)
		end
	end
end

function onEliminate(LAPlayer, event, ability, id)
	if LAPlayer:getVariable("EX064-target-noRemove") then
		if LAPlayer:getVariable("EX064-target-noRemove") == event:getPlayer():getPlayer() then
			game.sendMessage(LAPlayer:getPlayer(), "§4[§c예언가§4] §c예언에 실패했습니다.")
			LAPlayer:setVariable("EX064-correct-noRemove", false)
			LAPlayer:setVariable("EX064-target-noRemove", nil)
			game.sendActionBarMessage(LAPlayer:getPlayer(), "EX064", "")
		elseif LAPlayer:getVariable("EX064-correct-noRemove") == nil then
			local players = util.getTableFromList(game.getPlayers())
			if #players == 3 then
				for i = 1, #players do
					if event:getPlayer() ~= players[i] and players[i]:getPlayer() == LAPlayer:getVariable("EX064-target-noRemove") then
						LAPlayer:setVariable("EX064-isAlive", LAPlayer.isSurvive)
						LAPlayer:setVariable("EX064-correct-noRemove", true)
						LAPlayer:setVariable("EX064-target-noRemove", nil)
						return 0
					end
				end
			end
		end
	end
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("EX064", "")
end

function useFunc(LAPlayer)
	LAPlayer:setVariable("EX064-cancelClose", true)
	
	local guiMethod = util.createGUIMethod(
	function(event) -- onClick
		event:setCancelled(true)
		
		local players = util.getTableFromList(game.getPlayers())
		for i = 1, #players do
			if string.find(event:getCurrentItem():getItemMeta():getDisplayName(), players[i]:getPlayer():getName()) then
				LAPlayer:setVariable("EX064-target-noRemove", players[i]:getPlayer())
				LAPlayer:setVariable("EX064-cancelClose", false)
				game.sendMessage(LAPlayer:getPlayer(), "§6[§e예언가§6] §6" .. players[i]:getPlayer():getName() .. "§e님을 최후의 2인으로 예언했습니다.")
				event:getView():close()
				return 0
			end
		end
	end,
	function(event) -- onClose
		import("com.LAbility.Manager.GUIManager"):setOpenTrigger("§a예언 §2(" .. LAPlayer:getPlayer():getName() .. ")", LAPlayer:getVariable("EX064-cancelClose"))
		if LAPlayer:getVariable("EX064-cancelClose") then
			util.runLater(function()
				import("com.LAbility.Manager.GUIManager"):reopenGUI(LAPlayer:getPlayer(), "§a예언 §2(" .. LAPlayer:getPlayer():getName() .. ")")
			end, 1)
		end
	end)
	
	local targets = {}
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i] ~= LAPlayer then
			local item = newInstance("$.inventory.ItemStack", { material.PLAYER_HEAD})
            local meta = item:getItemMeta()
            meta:setDisplayName("§a" .. players[i]:getPlayer():getName())
            meta:setOwnerProfile(plugin.getServer():createPlayerProfile(players[i]:getPlayer():getName()))
            item:setItemMeta(meta)
			table.insert(targets, item)
		end
	end
	
	import("com.LAbility.Manager.GUIManager"):registerGUI(LAPlayer:getPlayer(), 54, targets, "§a예언 §2(" .. LAPlayer:getPlayer():getName() .. ")", guiMethod)
end