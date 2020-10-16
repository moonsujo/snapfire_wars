-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end


-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')


-- Rune system override
require('components/runes') 
require('filters')
require('libraries/keyvalues')



-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')
require('internal/util')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
-- core_mechanics.lua is where you can specify how the game works
require('core_mechanics')
-- modifier_ai.lua is where you can specify how the non-player controlled units will behave
require('libraries/modifiers/modifier_ai')
-- modifier_ai_ult_creep specifies how the creeps in the last zone will behave
require('libraries/modifiers/modifier_ai_ult_creep')
-- modifier_ai_ult_creep specifies how drow will behave
require('libraries/modifiers/modifier_ai_drow')
-- modifier_stunned.lua stuns the entity on creation
require('libraries/modifiers/modifier_stunned')
-- modifier_invulnerable.lua adds the invulnerability modifier
require('libraries/modifiers/modifier_invulnerable')
-- modifier_invulnerable.lua adds the magic immunity modifier
require('libraries/modifiers/modifier_magic_immune')
-- modifier_silenced.lua adds the silenced modifier
require('libraries/modifiers/modifier_silenced')
-- modifier_attack_immune.lua adds the attack immunity modifier
require('libraries/modifiers/modifier_attack_immune')
-- modifier_attack_immune.lua adds the attack immunity modifier
require('libraries/modifiers/modifier_specially_deniable')
-- modifier_attack_immune.lua adds the bloodlust modifier that speeds up the hero when it kills another hero
require('modifier_fiery_soul_on_kill_lua')

-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "playground" then
  require("examples/playground")
end

--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]


function GameMode:OnAllPlayersLoaded()
  GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode, "ModifierFilter"), self)

  --for the countdown function
  function round (num)
    return math.floor(num + 0.5)
  end

  local COUNT_DOWN_FROM = 40
  local endTime = round(GameRules:GetGameTime() + COUNT_DOWN_FROM)

  GameRules:GetGameModeEntity():SetThink(function ()
    
    local delta = round(endTime - GameRules:GetGameTime())

    --starting message
    if delta == 39 then
      EmitGlobalSound('gbuTheme')
      -- GameMode:SpawnNeutral()
      -- Timers:CreateTimer({
      --   endTime = 20, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
      --   callback = function()
      --     Notifications:BottomToAll({text="FINISH!" , duration= 35, style={["font-size"] = "30px", color = "white"}})
      --   end
      -- })
      --Notifications:BottomToAll({text="Battle Royale" , duration= 39, style={["font-size"] = "30px", color = "white"}})
      --Notifications:BottomToAll({text="Categories: Last Team Standing, Most Damage, Most Kills" , duration= 39, style={["font-size"] = "30px", color = "white"}})
      Notifications:BottomToAll({text="Warm Up Phase" , duration= 30, style={["font-size"] = "45px", color = "red"}})
      --[[local top_leftVectorEnt = Entities:FindByName(nil, "top_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local top_leftVector = top_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of top_left corner: " .. tostring(top_leftVector))
      local top_rightVectorEnt = Entities:FindByName(nil, "top_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local top_rightVector = top_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of top_right corner: " .. tostring(top_rightVector))
      local bottom_leftVectorEnt = Entities:FindByName(nil, "bottom_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local bottom_leftVector = bottom_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of bottom_left corner: " .. tostring(bottom_leftVector))
      local bottom_rightVectorEnt = Entities:FindByName(nil, "bottom_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local bottom_rightVector = bottom_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of bottom_right corner: " .. tostring(bottom_rightVector))
      local island_centerVectorEnt = Entities:FindByName(nil, "island_center")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local island_centerVector = island_centerVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of island center: " .. tostring(island_centerVector))
      local center_ring_top_leftVectorEnt = Entities:FindByName(nil, "center_ring_top_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local center_ring_top_leftVector = center_ring_top_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of center_ring_top_left corner: " .. tostring(center_ring_top_leftVector))
      local center_ring_top_rightVectorEnt = Entities:FindByName(nil, "center_ring_top_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local center_ring_top_rightVector = center_ring_top_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of center_ring_top_right corner: " .. tostring(center_ring_top_rightVector))
      local center_ring_bottom_leftVectorEnt = Entities:FindByName(nil, "center_ring_bottom_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local center_ring_bottom_leftVector = center_ring_bottom_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of center_ring_bottom_left corner: " .. tostring(center_ring_bottom_leftVector))
      local center_ring_bottom_rightVectorEnt = Entities:FindByName(nil, "center_ring_bottom_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local center_ring_bottom_rightVector = center_ring_bottom_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of center_ring_bottom_right corner: " .. tostring(center_ring_bottom_rightVector))
      
      --hills
      --top left
      local hill_top_left_top_leftVectorEnt = Entities:FindByName(nil, "hill_top_left_top_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_left_top_leftVector = hill_top_left_top_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_left_top_left corner: " .. tostring(hill_top_left_top_leftVector))
      local hill_top_left_top_rightVectorEnt = Entities:FindByName(nil, "hill_top_left_top_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_left_top_rightVector = hill_top_left_top_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_left_top_right corner: " .. tostring(hill_top_left_top_rightVector))
      local hill_top_left_bottom_leftVectorEnt = Entities:FindByName(nil, "hill_top_left_bottom_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_left_bottom_leftVector = hill_top_left_bottom_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_left_bottom_left corner: " .. tostring(hill_top_left_bottom_leftVector))
      local hill_top_left_bottom_rightVectorEnt = Entities:FindByName(nil, "hill_top_left_bottom_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_left_bottom_rightVector = hill_top_left_bottom_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_left_bottom_right corner: " .. tostring(hill_top_left_bottom_rightVector))
            
      --top right
      local hill_top_right_top_leftVectorEnt = Entities:FindByName(nil, "hill_top_right_top_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_right_top_leftVector = hill_top_right_top_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_right_top_left corner: " .. tostring(hill_top_right_top_leftVector))
      local hill_top_right_top_rightVectorEnt = Entities:FindByName(nil, "hill_top_right_top_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_right_top_rightVector = hill_top_right_top_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_right_top_right corner: " .. tostring(hill_top_right_top_rightVector))
      local hill_top_right_bottom_leftVectorEnt = Entities:FindByName(nil, "hill_top_right_bottom_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_right_bottom_leftVector = hill_top_right_bottom_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_right_bottom_left corner: " .. tostring(hill_top_right_bottom_leftVector))
      local hill_top_right_bottom_rightVectorEnt = Entities:FindByName(nil, "hill_top_right_bottom_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_top_right_bottom_rightVector = hill_top_right_bottom_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_top_right_bottom_right corner: " .. tostring(hill_top_right_bottom_rightVector))

      --bottom left
      local hill_bottom_left_top_leftVectorEnt = Entities:FindByName(nil, "hill_bottom_left_top_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_left_top_leftVector = hill_bottom_left_top_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_left_top_left corner: " .. tostring(hill_bottom_left_top_leftVector))
      local hill_bottom_left_top_rightVectorEnt = Entities:FindByName(nil, "hill_bottom_left_top_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_left_top_rightVector = hill_bottom_left_top_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_left_top_right corner: " .. tostring(hill_bottom_left_top_rightVector))
      local hill_bottom_left_bottom_leftVectorEnt = Entities:FindByName(nil, "hill_bottom_left_bottom_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_left_bottom_leftVector = hill_bottom_left_bottom_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_left_bottom_left corner: " .. tostring(hill_bottom_left_bottom_leftVector))
      local hill_bottom_left_bottom_rightVectorEnt = Entities:FindByName(nil, "hill_bottom_left_bottom_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_left_bottom_rightVector = hill_bottom_left_bottom_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_left_bottom_right corner: " .. tostring(hill_bottom_left_bottom_rightVector))
            
      --bottom right
      local hill_bottom_right_top_leftVectorEnt = Entities:FindByName(nil, "hill_bottom_right_top_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_right_top_leftVector = hill_bottom_right_top_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_right_top_left corner: " .. tostring(hill_bottom_right_top_leftVector))
      local hill_bottom_right_top_rightVectorEnt = Entities:FindByName(nil, "hill_bottom_right_top_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_right_top_rightVector = hill_bottom_right_top_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_right_top_right corner: " .. tostring(hill_bottom_right_top_rightVector))
      local hill_bottom_right_bottom_leftVectorEnt = Entities:FindByName(nil, "hill_bottom_right_bottom_left")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_right_bottom_leftVector = hill_bottom_right_bottom_leftVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_right_bottom_left corner: " .. tostring(hill_bottom_right_bottom_leftVector))
      local hill_bottom_right_bottom_rightVectorEnt = Entities:FindByName(nil, "hill_bottom_right_bottom_right")
      -- GetAbsOrigin() is a function that can be called on any entity to get its location
      local hill_bottom_right_bottom_rightVector = hill_bottom_right_bottom_rightVectorEnt:GetAbsOrigin()
      print("[GameMode:OnAllPlayersLoaded] coordinates of hill_bottom_right_bottom_right corner: " .. tostring(hill_bottom_right_bottom_rightVector))]]
      

      --[[[GameMode:OnAllPlayersLoaded] coordinates of top_left corner: Vector 0000000000638340 [-2506.230957 1974.780273 128.000977]
      [GameMode:OnAllPlayersLoaded] coordinates of top_right corner: Vector 0000000000684D78 [1677.998047 1978.366211 128.000000]
      [GameMode:OnAllPlayersLoaded] coordinates of bottom_left corner: Vector 00000000008DB948 [-2528.156250 -2254.627930 128.000000]
      [GameMode:OnAllPlayersLoaded] coordinates of bottom_right corner: Vector 00000000008AC3C0 [1774.116211 -2296.162109 166.007355]
      [GameMode:OnAllPlayersLoaded] coordinates of island center: Vector 00000000006772D0 [-234.199707 -45.612793 128.000000]
      [GameMode:OnAllPlayersLoaded] coordinates of center_ring_top_left corner: Vector 0000000000677358 [-635.768311 296.765533 128.000000]
      [GameMode:OnAllPlayersLoaded] coordinates of center_ring_top_right corner: Vector 0000000000318138 [142.913330 256.254791 128.000244]
      [GameMode:OnAllPlayersLoaded] coordinates of center_ring_bottom_left corner: Vector 000000000031F270 [-664.320068 -458.133301 128.000000]
      [GameMode:OnAllPlayersLoaded] coordinates of center_ring_bottom_right corner: Vector 0000000000324A30 [133.909668 -445.487305 128.000244]]
      
      GameMode:SetUpRunes()
      


      --[[  
        --for i = 0, 3 do
        GameMode.items[i] = GameMode:SpawnItem("item_faerie_fire", -2506, 1677, -2254, 1974)
      --end
      for i = 0, 3 do
        GameMode.ddRunes[i] = GameMode:SpawnRune(DOTA_RUNE_DOUBLEDAMAGE, -2506, 1677, -2254, 1974)
      end
      for i = 0, 3 do
        GameMode.arcaneRunes[i] = GameMode:SpawnRune(DOTA_RUNE_ARCANE, -2506, 1677, -2254, 1974)
      end
      return 1]]
      return 1

    elseif delta > 9 then
      --sets the amount of seconds until SetThink is called again
      return 1

    elseif delta == 9 then
      GameMode.pregameBuffer = true
      Notifications:ClearTopFromAll()
      Notifications:ClearBottomFromAll()
      Notifications:BottomToAll({text="GET READY!" , duration= 5.0, style={["font-size"] = "45px", color = "red"}})
      for playerID = 0, GameMode.maxNumPlayers do
        if PlayerResource:IsValidPlayerID(playerID) then
          heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
          heroEntity:SetBaseMagicalResistanceValue(10)
          heroEntity:SetPhysicalArmorBaseValue(0)
          heroEntity:SetBaseHealthRegen(0)
          heroEntity:ForceKill(true)
        end
      end
      --record damage done to compare it to the total damage done after the first round
      
      for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
          GameMode.numTeams = GameMode.numTeams + 1
          local teamDamageDoneTotal = 0
          for playerID = 0, GameMode.maxNumPlayers do
            if GameMode.teams[teamNumber][playerID] ~= nil then
              print("[GameMode:OnAllPlayersLoaded] playerID: " .. playerID)
              local playerDamageDoneTotal = 0
              for victimTeamNumber = 6, 13 do
                if GameMode.teams[victimTeamNumber] ~= nil then
                  print("[GameMode:OnAllPlayersLoaded] victimTeamNumber: " .. victimTeamNumber)
                  if victimTeamNumber == teamNumber then goto continue
                  else
                    for victimID = 0, 7 do
                      if GameMode.teams[victimTeamNumber][victimID] ~= nil then
                        print("[GameMode:OnAllPlayersLoaded] victimID: " .. victimID)
                        playerDamageDoneTotal = playerDamageDoneTotal + PlayerResource:GetDamageDoneToHero(playerID, victimID)
                      end
                    end
                  end
                  ::continue::
                end
              end
              GameMode.teams[teamNumber][playerID].totalDamageDealt = playerDamageDoneTotal
              teamDamageDoneTotal = teamDamageDoneTotal + playerDamageDoneTotal
            end
          end
          GameMode.teams[teamNumber].totalDamageDealt = teamDamageDoneTotal
        end
      end

      --same for kills
      for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            local teamKillsTotal = 0
            for playerID  = 0, GameMode.maxNumPlayers do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                    GameMode.teams[teamNumber][playerID].totalKills = PlayerResource:GetKills(playerID)
                    teamKillsTotal = teamKillsTotal + PlayerResource:GetKills(playerID)
                end
            end
            --assign teamKillsTotal to GameMode.teams[teamNumber].totalKills
            GameMode.teams[teamNumber].totalKills = teamKillsTotal
        end
      end
      return 5


    --play the starting sound
    --calculate the damage dealt for every hero against each other
    --rank them in descending order 
    --highest rank gets placed first; lowest rank gets placed last at the starting line
    elseif delta == 4 then
      GameMode.pregameActive = false
      GameMode.pregameBuffer = false
      --set up death match mode
      if GameMode.type == "deathMatch" then
        GameMode:DeathMatchStart()

      else
        GameRules:SetHeroRespawnEnabled( false )
        GameMode:RoundStart(GameMode.teams)
      end
      return 4
    
    elseif delta == 0 then
    end
  end)
end

function GameMode:SetUpRunes()
        --top left 
        --potion
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(-2506, -635)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(296, 1974)
          if (item_x > -1989 and item_x < -1293) and (item_y < 1522 and item_y > 803) then
            onHill = true
          else
            GameMode.items[0] = GameMode:SpawnItem("item_faerie_fire", item_x, item_y)
            onHill = false
          end
        end
        --double damage rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(-2506, -635)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(296, 1974)
          if (item_x > -1989 and item_x < -1293) and (item_y < 1522 and item_y > 803) then
            onHill = true
          else
            GameMode.ddRunes[0] = GameMode:SpawnRune(DOTA_RUNE_DOUBLEDAMAGE, item_x, item_y)
            onHill = false
          end
        end
        --arcane rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(-2506, -635)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(296, 1974)
          if (item_x > -1989 and item_x < -1293) and (item_y < 1522 and item_y > 803) then
            onHill = true
          else
            GameMode.arcaneRunes[0] = GameMode:SpawnRune(DOTA_RUNE_ARCANE, item_x, item_y)
            onHill = false
          end
        end

        --top right
        --potion
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(142, 1677)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(256, 1978)
          if (item_x > 566 and item_x < 1261) and (item_y > 798 and item_y < 1518) then
            onHill = true
          else
            GameMode.items[1] = GameMode:SpawnItem("item_faerie_fire", item_x, item_y)
            onHill = false
          end
        end
        --double damage rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(142, 1677)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(256, 1978)
          if (item_x > 566 and item_x < 1261) and (item_y > 798 and item_y < 1518) then
            onHill = true
          else
            GameMode.ddRunes[1] = GameMode:SpawnRune(DOTA_RUNE_DOUBLEDAMAGE, item_x, item_y)
            onHill = false
          end
        end
        --arcane rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(142, 1677)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(256, 1978)
          if (item_x > 566 and item_x < 1261) and (item_y > 798 and item_y < 1518) then
            onHill = true
          else
            GameMode.arcaneRunes[1] = GameMode:SpawnRune(DOTA_RUNE_ARCANE, item_x, item_y)
            onHill = false
          end
        end

        --bottom left
        --potion
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(-2528, -664)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(-2254, -458)
          if (item_x > -1990 and item_x < -1295) and (item_y > -1757 and item_y < -1037) then
            onHill = true
          else
            GameMode.items[2] = GameMode:SpawnItem("item_faerie_fire", item_x, item_y)
            onHill = false
          end
        end
        --double damage rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(-2528, -664)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(-2254, -458)
          if (item_x > -1990 and item_x < -1295) and (item_y > -1757 and item_y < -1037) then
            onHill = true
          else
            GameMode.ddRunes[2] = GameMode:SpawnRune(DOTA_RUNE_DOUBLEDAMAGE, item_x, item_y)
            onHill = false
          end
        end
        --arcane rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(-2528, -664)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(-2254, -458)
          if (item_x > -1990 and item_x < -1295) and (item_y > -1757 and item_y < -1037) then
            onHill = true
          else
            GameMode.arcaneRunes[2] = GameMode:SpawnRune(DOTA_RUNE_ARCANE, item_x, item_y)
            onHill = false
          end
        end

        --bottom right
        --potion
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(133, 1774)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(-2296, -445)
          if (item_x > 561 and item_x < 1256) and (item_y > -1749 and item_y < -1029) then
            onHill = true
          else
            GameMode.items[3] = GameMode:SpawnItem("item_faerie_fire", item_x, item_y)
            onHill = false
          end
        end
        --double damage rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(133, 1774)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(-2296, -445)
          if (item_x > 561 and item_x < 1256) and (item_y > -1749 and item_y < -1029) then
            onHill = true
          else
            GameMode.ddRunes[3] = GameMode:SpawnRune(DOTA_RUNE_DOUBLEDAMAGE, item_x, item_y)
            onHill = false
          end
        end
        --arcane rune
        local onHill = true
        while onHill do
          local item_x = math.random() + math.random(133, 1774)
          --print("[GameMode:SpawnItem] item_x: " .. item_x)
          local item_y = math.random() + math.random(-2296, -445)
          if (item_x > 561 and item_x < 1256) and (item_y > -1749 and item_y < -1029) then
            onHill = true
          else
            GameMode.arcaneRunes[3] = GameMode:SpawnRune(DOTA_RUNE_ARCANE, item_x, item_y)
            onHill = false
          end
        end

        --center
        --potion
        local item_x = math.random() + math.random(-635, 133)
        --print("[GameMode:SpawnItem] item_x: " .. item_x)
        local item_y = math.random() + math.random(-445, 296)
        GameMode.items[4] = GameMode:SpawnItem("item_faerie_fire", item_x, item_y)
        --double damage rune
        local item_x = math.random() + math.random(-635, 133)
        --print("[GameMode:SpawnItem] item_x: " .. item_x)
        local item_y = math.random() + math.random(-445, 296)
        GameMode.ddRunes[4] = GameMode:SpawnRune(DOTA_RUNE_DOUBLEDAMAGE, item_x, item_y)
        --arcane rune
        local item_x = math.random() + math.random(-635, 133)
        --print("[GameMode:SpawnItem] item_x: " .. item_x)
        local item_y = math.random() + math.random(-445, 296)
        GameMode.arcaneRunes[4] = GameMode:SpawnRune(DOTA_RUNE_ARCANE, item_x, item_y)
end

function GameMode:RemoveRunes()
  for i = 0, 4 do
    UTIL_Remove(GameMode.items[i])
  end
  for i = 0, 4 do
    UTIL_Remove(GameMode.ddRunes[i])
  end
  for i = 0, 4 do
    UTIL_Remove(GameMode.arcaneRunes[i])
  end
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  --hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_ultimate_scepter", hero, hero)
  print("[GameMode:OnHeroInGame] item: " .. tostring(item))
  hero:AddItem(item)
  local item = CreateItem("item_force_staff", hero, hero)
  print("[GameMode:OnHeroInGame] item: " .. tostring(item))
  hero:AddItem(item)
  --local item = CreateItem("item_black_king_bar", hero, hero)
  --hero:AddItem(item)
  local item = CreateItem("item_cyclone", hero, hero)
  print("[GameMode:OnHeroInGame] item: " .. tostring(item))
  hero:AddItem(item)
  local item = CreateItem("item_glimmer_cape", hero, hero)
  print("[GameMode:OnHeroInGame] item: " .. tostring(item))
  hero:AddItem(item)
  local item = CreateItem("item_black_king_bar", hero, hero)
  print("[GameMode:OnHeroInGame] item: " .. tostring(item))
  hero:AddItem(item)

  --for future version
  --hero:GetPlayerOwner():SetMusicStatus(0, 0)
  


  --get ability
  --set its level to max
  --index starts from 0
  --[[		"Ability1"				"snapfire_scatterblast"
		"Ability2"				"snapfire_firesnap_cookie"
		"Ability3"				"snapfire_lil_shredder"
		"Ability4"				"snapfire_gobble_up"
		"Ability5"				"snapfire_spit_creep"
		"Ability6"				"snapfire_mortimer_kisses"
		"Ability7"				"fiery_soul_on_kill_lua"
    "Ability8"				"true_sight"]]
  --hero:AddAbility("snapfire_gobble_up")
  --hero:AddAbility("snapfire_scatterblast")
  if GameMode.pregameActive then
    hero:SetBaseMagicalResistanceValue(100)
    hero:SetPhysicalArmorBaseValue(500)
    hero:SetBaseHealthRegen(500)
  end
  local abil = hero:GetAbilityByIndex(0)
  abil:SetLevel(4)
  abil = hero:GetAbilityByIndex(1)
  abil:SetLevel(4)
  abil = hero:GetAbilityByIndex(2)
  abil:SetLevel(4)
  abil = hero:GetAbilityByIndex(3)
  abil:SetLevel(1)
  --"gobble up" is hidden by default
  abil:SetHidden(false)
  abil = hero:GetAbilityByIndex(4)
  abil:SetLevel(1)
  --offset because of scepter
  abil = hero:GetAbilityByIndex(5)
  abil:SetLevel(3)
  abil = hero:GetAbilityByIndex(6)
  abil:SetLevel(1)
  --[[abil = hero:GetAbilityByIndex(7)
  abil:SetLevel(1)]]



  --abil = hero:GetAbilityByIndex(6)
  --abil:SetLevel(1)
  --abil = hero:GetAbilityByIndex(7)
  --abil:SetLevel(4)
  print("[GameMode:OnHeroInGame] team number: " .. hero:GetTeamNumber())
  print("[GameMode:OnHeroInGame] player ID: " .. hero:GetPlayerID())
  
  if GameMode.teams[hero:GetTeamNumber()] == nil then
    print("[GameMode:OnHeroInGame] making a new entry in the 'teams' table")
    GameMode.teams[hero:GetTeamNumber()] = {}
    GameMode.teams[hero:GetTeamNumber()].score = 0
    GameMode.teams[hero:GetTeamNumber()].remaining = true
    GameMode.teams[hero:GetTeamNumber()].totalDamageDealt = true
    --deprecate
    GameMode.teams[hero:GetTeamNumber()].totalKills = true
    GameMode.teams[hero:GetTeamNumber()].wanted = false
  end
  GameMode.teams[hero:GetTeamNumber()][hero:GetPlayerID()] = {}
  GameMode.teams[hero:GetTeamNumber()][hero:GetPlayerID()].hero = hero
  GameMode.teams[hero:GetTeamNumber()][hero:GetPlayerID()].totalDamageDealt = 0
  GameMode.teams[hero:GetTeamNumber()][hero:GetPlayerID()].totalKills = 0
  GameMode.numPlayers = GameMode.numPlayers + 1
  
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  --use "print" and "PrintTable" to print messages in the debugger
  DebugPrint("[BAREBONES] The game has officially begun")
end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  --make file in modifiers folder
  --link it to the class (this is the modifier for neutral creeps' AI)
  LinkLuaModifier("modifier_ai", "libraries/modifiers/modifier_ai.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_ai_ult_creep", "libraries/modifiers/modifier_ai_ult_creep.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_ai_drow", "libraries/modifiers/modifier_ai_drow.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_invulnerable", "libraries/modifiers/modifier_invulnerable.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_silenced", "libraries/modifiers/modifier_silenced.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_attack_immune", "libraries/modifiers/modifier_attack_immune.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_magic_immune", "libraries/modifiers/modifier_magic_immune.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_specially_deniable", "libraries/modifiers/modifier_specially_deniable.lua", LUA_MODIFIER_MOTION_NONE)
  --change game title in addon_english.txt
  --remove items in shops.txt to remove them from the shop
  --remove items completely by disabling them in npc_abilities_custom.txt
  
  --disable the in game announcer
  --GameMode:SetAnnouncerDisabled(true)
  --GameMode:SetBuybackEnabled(false)

  
  CustomGameEventManager:RegisterListener("js_player_select_type", OnJSPlayerSelectType)
  CustomGameEventManager:RegisterListener("js_player_select_points", OnJSPlayerSelectPoints)
  CustomGameEventManager:RegisterListener("js_player_select_hero", OnJSPlayerSelectHero)
  
  

  --call this which is located in the internal/gamemode file to initialize the basic settings provided by barebones 
  GameMode:_InitGameMode()


  -- SEEDING RNG IS VERY IMPORTANT
  math.randomseed(Time())
  
  GameMode.teams = {}
  GameMode.numTeams = 0
  GameMode.currentRound = 0
  GameMode.pregameActive = true
  GameMode.pregameBuffer = false
  GameMode.tieBreakerActive = false
  GameMode.roundActive = false
  GameMode.teamNames = {}
  GameMode.teamNames[6] = "Blue Team"
  GameMode.teamNames[7] = "Red Team"
  GameMode.teamNames[8] = "Pink Team"
  GameMode.teamNames[9] = "Green Team"
  GameMode.teamNames[10] = "Brown Team"
  GameMode.teamNames[11] = "Cyan Team"
  GameMode.teamNames[12] = "Olive Team"
  GameMode.teamNames[13] = "Purple Team"
  GameMode.items = {}
  GameMode.ddRunes = {}
  GameMode.arcaneRunes = {}
  GameMode.maxNumPlayers = 16
  --default = 7
  GameMode.pointsToWin = 10
  GameMode.pointsVote = {}
  --for testing
  --GameMode.pointsVote[7] = 0
  --GameMode.pointsVote[14] = 3
  --GameMode.pointsNumVoted = 3
  GameMode.pointsNumVoted = 0
  GameMode.numPlayers = 0
  GameMode.roundEnd = false
  --default = battle royale
  GameMode.type = "battleRoyale"
  GameMode.typeVote = {}
  --for testing
  --GameMode.typeVote["battleRoyale"] = 0
  --GameMode.typeVote["deathMatch"] = 3
  --GameMode.typeNumVoted = 3
  GameMode.typeNumVoted = 0
  GameMode.wantedEnabled = true
  GameMode.firstBlood = true
  


  --[[DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  
  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')]]
end

function OnJSPlayerSelectType(event, keys)
  print("[OnJSPlayerSelectType] someone voted")
  
	local player_id = keys["PlayerID"]
  local type = keys["type"]
  print("[OnJSPlayerSelectType] type: " .. type)

  local player = PlayerResource:GetPlayer(player_id)
  if player ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "type_selection_end", {})
  end

  --decide type of gamemode after everyone votes
  
  if GameMode.typeVote[type] == nil then
    GameMode.typeVote[type] = 1
  else
    GameMode.typeVote[type] = GameMode.typeVote[type] + 1
  end
  print("[OnJSPlayerSelectType] GameMode.typeVote[type]: " .. GameMode.typeVote[type])

  --check if everyone has voted
  GameMode.typeNumVoted = GameMode.typeNumVoted + 1
  print("[OnJSPlayerSelectType] GameMode.typeNumVoted: " .. GameMode.typeNumVoted)
  if GameMode.typeNumVoted == PlayerResource:NumPlayers() then
    print("[OnJSPlayerSelectType] everyone voted for the game mode")
    local typeVoteRanking = {}
    function spairs(t, order)
      -- collect the keys
      local keys = {}
      for k in pairs(t) do keys[#keys+1] = k end

      -- if order function given, sort by it by passing the table and keys a and b
      -- otherwise just sort the keys 
      if order then
          table.sort(keys, function(a,b) return order(t, a, b) end)
      else
          table.sort(keys)
      end

      -- return the iterator function
      local i = 0
      return function()
          i = i + 1
          if keys[i] then
              return keys[i], t[keys[i]]
          end
      end
    end
  
  
    local rank = 1
    for k,v in spairs(GameMode.typeVote, function(t,a,b) return t[b] < t[a] end) do
        typeVoteRanking[rank] = k 
        rank = rank + 1
    end
    local topTypeVote = GameMode.typeVote[typeVoteRanking[1]]

    --ipairs?
    for type, votes in pairs(GameMode.typeVote) do
      if GameMode.typeVote[type] == topTypeVote then
          --GameMode.type = "battleRoyale"
          GameMode.type = type
          if type == "battleRoyale" then
            Notifications:TopToAll({text="Mode: Battle Royale", duration= 35.0, style={["font-size"] = "35px", color = "white"}})
          else
            Notifications:TopToAll({text="Mode: Death Match", duration= 35.0, style={["font-size"] = "35px", color = "white"}})
          end
          --subsequent lines get displayed below
          --Notifications:TopToAll({text=string.format("Game Mode: %s", "Battle Royale"), duration= 35.0, style={["font-size"] = "35px", color = "white"}})
          
        --[[else
        print("[OnJSPlayerSelectType] everyone voted for the game mode deathMatch block")
        GameMode.type = "deathMatch"
        Notifications:TopToAll({text=string.format("Game Mode: %s", "Death Match"), duration= 35.0, style={["font-size"] = "35px", color = "white"}})]]
      end
    end
  end
end

function OnJSPlayerSelectPoints(event, keys)
	local player_id = keys["PlayerID"]
  local points = keys["points"]

  local player = PlayerResource:GetPlayer(player_id)
  if player ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "points_selection_end", {})
  end

  --decide points to win after everyone votes
  
  if GameMode.pointsVote[points] == nil then
    GameMode.pointsVote[points] = 1
  else
    GameMode.pointsVote[points] = GameMode.pointsVote[points] + 1
  end

  --check if everyone has voted
  GameMode.pointsNumVoted = GameMode.pointsNumVoted + 1
  if GameMode.pointsNumVoted == PlayerResource:NumPlayers() then
    local pointsVoteRanking = {}
    function spairs(t, order)
      -- collect the keys
      local keys = {}
      for k in pairs(t) do keys[#keys+1] = k end

      -- if order function given, sort by it by passing the table and keys a and b
      -- otherwise just sort the keys 
      if order then
          table.sort(keys, function(a,b) return order(t, a, b) end)
      else
          table.sort(keys)
      end

      -- return the iterator function
      local i = 0
      return function()
          i = i + 1
          if keys[i] then
              return keys[i], t[keys[i]]
          end
      end
    end
  
  
    --save the top damage
    --if there's other entries with the same value, give them scores too
    -- this uses a custom sorting function ordering by damageDone, descending
    local rank = 1
    for k,v in spairs(GameMode.pointsVote, function(t,a,b) return t[b] < t[a] end) do
        pointsVoteRanking[rank] = k 
        rank = rank + 1
    end
    local topPointsVote = GameMode.pointsVote[pointsVoteRanking[1]]
    for points = 10, 30, 10 do
        if GameMode.pointsVote[points] == topPointsVote then
            GameMode.pointsToWin = points
            Notifications:TopToAll({text=string.format("Number of Points to Win: %s", points), duration= 35.0, style={["font-size"] = "35px", color = "white"}})
            break
        end
    end


  end
end

function OnJSPlayerSelectHero(event, keys)
	local player_id = keys["PlayerID"]
	local hero_name = keys["hero_name"]
	
	local current_hero_name = PlayerResource:GetSelectedHeroName(player_id)
	if current_hero_name == nil then
		return
	end

	if current_hero_name == "npc_dota_hero_snapfire" then
		local selectedHero = PlayerResource:ReplaceHeroWith(player_id, hero_name, PlayerResource:GetGold(player_id), 0)
		if selectedHero == nil then
			return
		end
	end

	local player = PlayerResource:GetPlayer(player_id)
	if player ~= nil then
		CustomGameEventManager:Send_ServerToPlayer(player, "hero_selection_end", {})
	end
end





-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end


function GameMode:SpawnNeutral()
  --Start an iteration finding each entity with this name
  --If you've named everything with a unique name, this will return your entity on the first go
  --dynamically assign spawn to entity location via argument passed into the function



  -- Spawn the unit at the location on the dire team
  -- if set to neutral team, when hero dies, their death timer gets added 26 seconds to the fixed resurrection time
  local spawnedUnit = CreateUnitByName(string.format("npc_dota_warlock_golem_scepter_1", spawn_name), Vector(0,0,0), true, nil, nil, DOTA_TEAM_BADGUYS)


  -- set the angle it's facing
  -- (0, 0, 0) = faces to the endzone
  --(pitch (100 = facing down), yaw (100 = facing left), roll (0 = normal))
  spawnedUnit:SetAngles(0, 0, 0)


end



function GameMode:Restore(hero)
  --Purge stuns and debuffs from pregame
  --set "bFrameOnly" to maintain the purged state
  hero:Purge(true, true, false, true, true)
  --heal health and mana to full
  hero:Heal(8000, nil)
  hero:GiveMana(8000)
  -- A timer running every second that starts immediately on the next frame, respects pauses

    if hero:HasAbility("true_sight") then
      print("[GameMode:Restore] hero has true_sight")
      --when the ability is removed, so is the modifier it applies
      --changed "OnOwnerDied" to "OnCreated" in "true_sight" ability
      hero:RemoveAbility("true_sight")
      --adding print statements here makes sure true_sight ability is removed
      print("[GameMode:Restore] removed true_sight")
    else
      print("[GameMode:Restore] hero does not have true_sight")
    end
  if not hero:IsAlive() then
    hero:RespawnHero(false, false)
  end
end


--play the starting sound
--calculate the damage dealt for every hero against each other
--rank them in descending order
--highest rank gets placed first; lowest rank gets placed last at the starting line
function GameMode:RoundStart(teams)
  EmitGlobalSound('snapfireOlympics.introAndBackground3')      
  GameMode.currentRound = GameMode.currentRound + 1
  GameMode:RemoveRunes()
  
  Notifications:BottomToAll({text=string.format("ROUND %s", GameMode.currentRound), duration= 5.0, style={["font-size"] = "45px", color = "white"}})  
  for teamNumber = 6, 13 do
    if teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers do
        if teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            print("[GameMode:RoundStart] playerID: " .. playerID)
            for itemIndex = 0, 5 do
              if heroEntity:GetItemInSlot(itemIndex) ~= nil then
                heroEntity:GetItemInSlot(itemIndex):EndCooldown()
              end
            end
            for abilityIndex = 0, 5 do
              abil = heroEntity:GetAbilityByIndex(abilityIndex)
              abil:EndCooldown()
            end

            --[[Timers:CreateTimer(function()
              for i = 0, 10 do
                print("[GameMode:RoundStart] hero of playerID " .. playerID .. "has a modifier: " .. heroEntity:GetModifierNameByIndex(i))
              end
              return 1.0
            end)]]
            heroEntity:Stop()
            heroEntity:ForceKill(false)
            GameMode:Restore(heroEntity)
            heroEntity:AddNewModifier(nil, nil, "modifier_specially_deniable", {})
            --set camera to hero because when the hero is relocated, the camera stays still
            --use global variable 'PlayerResource' to call the function
            PlayerResource:SetCameraTarget(playerID, heroEntity)
            --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
            --set entity to 'nil' to undo setting the camera
            heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
          end
        end
      end
    end
  end

  GameMode:SetUpRunes()
  
  GameMode.roundActive = true
  -- 1 second delayed, run once using gametime (respect pauses)
  Timers:CreateTimer({
    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()            
      for playerID = 0, GameMode.maxNumPlayers do
        if PlayerResource:IsValidPlayerID(playerID) then
          PlayerResource:SetCameraTarget(playerID, nil)
        end
      end
    end
  })
  
end

function GameMode:DeathMatchStart()
  --intro sound
  EmitGlobalSound('snapfireOlympics.introAndBackground3')
  GameRules:SetHeroRespawnEnabled( true )
  --do the announcement
  Timers:CreateTimer({
    callback = function()
      Notifications:BottomToAll({text="3..." , duration= 1.0, style={["font-size"] = "45px"}})
    end
  })
  Timers:CreateTimer({
    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      Notifications:BottomToAll({text="2..." , duration= 1.0, style={["font-size"] = "45px"}})
    end
  })
  Timers:CreateTimer({
    endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      Notifications:BottomToAll({text="1..." , duration= 1.0, style={["font-size"] = "45px"}})
    end
  })
  Timers:CreateTimer({
    endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      Notifications:BottomToAll({text="GO!" , duration= 5.0, style={["font-size"] = "45px"}})
    end
  })
  --set up runes
  --runes every 1 minute
  Timers:CreateTimer(0, function()
      GameMode:RemoveRunes()
      return 60.0
    end
  )
  Timers:CreateTimer(0, function()
      GameMode:SetUpRunes()
      return 60.0
    end
  )
  --after a certain time, remove them

  --reset cooldowns
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            print("[GameMode:RoundStart] playerID: " .. playerID)
            for itemIndex = 0, 5 do
              if heroEntity:GetItemInSlot(itemIndex) ~= nil then
                heroEntity:GetItemInSlot(itemIndex):EndCooldown()
              end
            end
            for abilityIndex = 0, 5 do
              abil = heroEntity:GetAbilityByIndex(abilityIndex)
              abil:EndCooldown()
            end

            --[[Timers:CreateTimer(function()
              for i = 0, 10 do
                print("[GameMode:RoundStart] hero of playerID " .. playerID .. "has a modifier: " .. heroEntity:GetModifierNameByIndex(i))
              end
              return 1.0
            end)]]
            heroEntity:Stop()
            heroEntity:ForceKill(false)
            GameMode:Restore(heroEntity)
            heroEntity:AddNewModifier(nil, nil, "modifier_specially_deniable", {})
            --set camera to hero because when the hero is relocated, the camera stays still
            --use global variable 'PlayerResource' to call the function
            PlayerResource:SetCameraTarget(playerID, heroEntity)
            --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
            --set entity to 'nil' to undo setting the camera
            heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
          end
        end
      end
    end
  end
  Timers:CreateTimer({
    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()            
      for playerID = 0, GameMode.maxNumPlayers do
        if PlayerResource:IsValidPlayerID(playerID) then
          PlayerResource:SetCameraTarget(playerID, nil)
        end
      end
    end
  })
end


function GameMode:CheckWinningTeam()
  print("[GameMode:CheckWinningTeam] inside the function")
  local teamsRemaining = 0
  local winningTeamNumber = 0
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          heroEntity = GameMode.teams[teamNumber][playerID].hero
          if heroEntity:IsAlive() then
            teamsRemaining = teamsRemaining + 1
            winningTeamNumber = teamNumber
            break
          end
        end
      end
    end
  end
  if teamsRemaining == 1 then
    return winningTeamNumber
  else
    return 0
  end
end

function GameMode:SpawnItem(item_name, item_x, item_y)
  --for i = 0, 3 do
    --randomly generate a number between x1 and x2
    --randomly generate a number between y1 and y2
    --place a potion there
  --create the item
  --it returns a handle; store it in a variable
  --pass this variable to the function
  local item_a = CreateItem(item_name, nil, nil)
  item_a:SetCastOnPickup(true)

  
  --print("[GameMode:SpawnItem] item_y: " .. item_y)
  --what happens when an item is spawned on the hill?
  --island bottom layer's z = 128
  local item_z = 128
  --print("[GameMode:SpawnItem] item_vector: " .. tostring(Vector(item_x, item_y, item_z)))
  item_handle = CreateItemOnPositionSync(Vector(item_x, item_y, item_z), item_a)
  --print("[GameMode:SpawnItem] item_handle: ")
  --PrintTable(item_a)
  return item_handle
  --spawn 4 items
  --put them in a table
  --add a field "item_used"
  --when item is used,
    --set "item_used" to true
  --at the start of rounds
  --if item_used == true then
    --spawn new item
  --else
    --do nothing
  --
end

function GameMode:SpawnRune(rune_number, item_x, item_y)
  --local item_a = CreateItem("item_imba_rune_doubledamage", nil, nil)

  local item_z = 128
  --print("[GameMode:SpawnItem] rune_vector: " .. tostring(Vector(item_x, item_y, item_z)))

  local rune_handle = CreateRune(Vector(item_x, item_y, item_z), rune_number)
  --rune_handle = CreateItemOnPositionSync(Vector(item_x, item_y, item_z), item_a)
  --print("[GameMode:SpawnItem] rune_handle: ")
  --PrintTable(item_a)
  return rune_handle
  --spawn 4 items
  --put them in a table
  --add a field "item_used"
  --when item is used,
    --set "item_used" to true
  --at the start of rounds
  --if item_used == true then
    --spawn new item
  --else
    --do nothing
  --
end

--CustomGameEventManager:Send_ServertoAllPlayers("scores_create_scoreboard", {name = "This is lua!", desc="This is also LUA!", max= 5, id= 5})

--[[function GameMode:NeutralThinker(unit)
    -- A timer running every second that starts 5 seconds in the future, respects pauses
    Timers:CreateTimer(5, function()
      unit:StartGesture(ACT_DOTA_TAUNT)
      return 1.0
    end
  )
end]]