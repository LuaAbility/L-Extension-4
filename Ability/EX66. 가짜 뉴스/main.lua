function Init(abilityData) 
	plugin.registerEvent(abilityData, "가짜 뉴스", "PlayerInteractEvent", 1000)
end

function onEvent(funcTable)
	if funcTable[1] == "가짜 뉴스" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local playersE = util.getTableFromList(game.getTeamManager():getOpponentTeam(LAPlayer, false))
					local playersT = util.getTableFromList(game.getTeamManager():getMyTeam(LAPlayer, false))
					if #playersE > 0 and #playersT > 0 then
						local randomIndexE = util.random(1, #playersE)
						local randomIndexT = util.random(1, #playersT)
						
						game.broadcastMessage("§f" .. playersE[randomIndex]:getPlayer():getName() .. "이(가) " .. playersE[randomIndex]:getPlayer():getName() .. "에게 살해당했습니다")
						event:getEntity():getWorld():strikeLightningEffect(playersE[randomIndex]:getPlayer():getLocation())
						game.broadcastMessage("§4[§cLAbility§4] §c" .. playersE[randomIndex]:getPlayer():getName() .. "님이 탈락하셨습니다.")
						plugin.getPlugin().gameManager:playerAbilityList(playersE[randomIndex])
					end
				end
			end
		end
	end
end