local attribute = import("$.attribute.Attribute")
local effect = import("$.potion.PotionEffectType")
local material = import("$.Material")

local quiz = {
	{ 
		{"§f해당 아이템의 이름은?", material.WAXED_EXPOSED_CUT_COPPER_SLAB},
		{"§f약간 녹슨 깎인 구리 반 블록", material.WAXED_EXPOSED_CUT_COPPER_SLAB},
		{"§f밀랍칠한 약간 녹슨 깎인 구리 반 블록", material.WAXED_EXPOSED_CUT_COPPER_SLAB},
		{"§f밀랍칠한 약간 녹슨 구리 반 블록", material.WAXED_EXPOSED_CUT_COPPER_SLAB},
		2
	},
	{ 
		{"§f해당 아이템의 이름은?", material.STRIPPED_SPRUCE_LOG},
		{"§f껍질 벗긴 가문비나무", material.STRIPPED_SPRUCE_LOG},
		{"§f껍질 벗긴 가문비나무 원목", material.STRIPPED_SPRUCE_LOG},
		{"§f가문비나무 원목", material.STRIPPED_SPRUCE_LOG},
		1
	},
	{ 
		{"§f자바 에디션 상에서 생성 불가능한 아이템은?", material.BARRIER},
		{"§f연쇄형 명령 블록", material.CHAIN_COMMAND_BLOCK},
		{"§f직소 블록", material.JIGSAW},
		{"§f가루눈", material.POWDER_SNOW_BUCKET},
		3
	},
	{ 
		{"§f존재하지 않는 자바 에디션 버전은?", material.BARRIER},
		{"§f1.9.5", material.ELYTRA},
		{"§f1.4.7", material.WITHER_SKELETON_SKULL},
		{"§f1.5", material.REDSTONE_BLOCK},
		1
	},
	{ 
		{"§f썩은 살점 섭취 시 허기 확률은?", material.ROTTEN_FLESH},
		{"§f85%", material.ROTTEN_FLESH},
		{"§f80%", material.ROTTEN_FLESH},
		{"§f90%", material.ROTTEN_FLESH},
		2
	},
	{ 
		{"늑대를 처음 길들일 때의 목줄 색깔은?", material.BONE},
		{"§f초록", material.GREEN_WOOL},
		{"§f파랑", material.BLUE_WOOL},
		{"§f빨강", material.RED_WOOL},
		3
	}
}

function Init(abilityData)
	plugin.registerEvent(abilityData, "문제 출제", "PlayerInteractEvent", 2400)
end

function onEvent(funcTable)
	if funcTable[1] == "문제 출제" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function Reset(player, ability)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		import("com.LAbility.Manager.GUIManager"):setOpenTrigger("§a문제! (" .. players[i]:getPlayer():getName() .. ")", false)
		players[i]:getPlayer():closeInventory()
	end
	
	game.sendActionBarMessageToAll("EX063", "")
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					Reset(LAPlayer, ability)
					useFunc()
				end
			end
		end
	end
end

function useFunc()
	local players = util.getTableFromList(game.getPlayers())
	local quizIndex = util.random(1, #quiz)
	
	for i = 1, #players do
		local targetPlayer = players[i]:getPlayer()
		local targets = {}
		local randomIndex = {2, 3, 4}
		local cancelClose = true
		local invTemp = nil
		
		local guiMethod = util.createGUIMethod(
		function(event) -- onClick
			event:setCancelled(true)
			
			local isAwnser = false
			for j = 2, 4 do
				if event:getCurrentItem():getItemMeta():getDisplayName() == quiz[quizIndex][j][1] then
					isAwnser = true
				end
			end
			
			if isAwnser then
				if event:getCurrentItem():getItemMeta():getDisplayName() == quiz[quizIndex][quiz[quizIndex][5] + 1][1] then
					game.sendMessage(targetPlayer, "§6[§e퀴즈§6] §e정답입니다!")
					targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.INCREASE_DAMAGE, 200, 0}))
					targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.REGENERATION, 200, 0}))
					targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SPEED, 200, 1}))
				else
					game.sendMessage(targetPlayer, "§4[§c퀴즈§4] §c오답입니다.")
					targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 200, 0}))
					targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.WEAKNESS, 200, 0}))
					targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SLOW, 200, 1}))
				end
				
				cancelClose = false
				event:getView():close()
			end
		end,
		function(event) -- onClose
			if cancelClose then
				game.sendMessage(targetPlayer, "§4[§c퀴즈§4] §c문제를 풀지 않아 오답처리됩니다.")
				targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 200, 0}))
				targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.WEAKNESS, 200, 0}))
				targetPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SLOW, 200, 1}))
			end
		end)
		
		for j = 1, 100 do
			local index = util.random(1, #randomIndex)
			local temp = randomIndex[index]
			randomIndex[index] = randomIndex[1]
			randomIndex[1] = temp
		end
		
		for j = 1, 54 do
			if j == 14 then
				local item = newInstance("$.inventory.ItemStack", { quiz[quizIndex][1][2] })
				local meta = item:getItemMeta()
				meta:setDisplayName("§f" .. quiz[quizIndex][1][1])
				item:setItemMeta(meta)
				table.insert(targets, item)
			elseif j == 39 then
				local item = newInstance("$.inventory.ItemStack", { quiz[quizIndex][randomIndex[1]][2] })
				local meta = item:getItemMeta()
				meta:setDisplayName("§f" .. quiz[quizIndex][randomIndex[1]][1])
				item:setItemMeta(meta)
				table.insert(targets, item)
			elseif j == 41 then
				local item = newInstance("$.inventory.ItemStack", { quiz[quizIndex][randomIndex[2]][2] })
				local meta = item:getItemMeta()
				meta:setDisplayName("§f" .. quiz[quizIndex][randomIndex[2]][1])
				item:setItemMeta(meta)
				table.insert(targets, item)
			elseif j == 43 then
				local item = newInstance("$.inventory.ItemStack", { quiz[quizIndex][randomIndex[3]][2] })
				local meta = item:getItemMeta()
				meta:setDisplayName("§f" .. quiz[quizIndex][randomIndex[3]][1])
				item:setItemMeta(meta)
				table.insert(targets, item)
			else table.insert(targets, newInstance("$.inventory.ItemStack", { material.AIR })) end
		end
		
		invTemp = import("com.LAbility.Manager.GUIManager"):registerGUI(targetPlayer, 54, targets, "§a문제! (" .. targetPlayer:getName() .. ")", guiMethod)
	end
end