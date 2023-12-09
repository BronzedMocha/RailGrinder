local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local libraries = packages:WaitForChild("external")
local wally = packages:WaitForChild("wally")

local Knit = require(wally:WaitForChild("Knit"))
local ProfileService = require(libraries:WaitForChild("ProfileService"))
local game_settings = require(ReplicatedStorage:WaitForChild("Settings"))

local GameProfileStore
local PlayerOptions
local PlayerLog

local PLAYER_LOGIN_TIMES = {}
local DATASTORE_KEY = "GAME_DATA;"

local Datastore = Knit.CreateService {
    Name = "Datastore";
    Client = {
		PlayerData = Knit.CreateProperty(nil);
	};
}

Datastore.Profiles = {}

function Datastore:_onProfileLoaded(player, profile)
    profile.Data.last_join = tick()
    profile.Data.login_count += 1

    PlayerOptions:LoadPlayerOptions(player, profile.Data.player_options)

	Datastore.Client.PlayerData:SetFor(player, profile.Data)
end

function Datastore:onPlayerAdded(player)
    local profile = GameProfileStore:LoadProfileAsync(
		DATASTORE_KEY..player.UserId,
		"ForceLoad"
	)
	if profile ~= nil then
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate
		profile:ListenToRelease(function()
			self.Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			--print("profile exists!")

			--utilityFunctions.readTable(profile.Data.max_asset_type_slots)
			
			PlayerLog.player_list[player].datastore = profile
			-- A profile has been successfully loaded:
			self:_onProfileLoaded(player, profile)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--  Roblox servers trying to load this profile at the same time:
		player:Kick()
	end
	
    PLAYER_LOGIN_TIMES[player] = tick()
end

function Datastore:onPlayerRemoving(player)
	local profile = PlayerLog.player_list[player].datastore
	if profile ~= nil then

        if PLAYER_LOGIN_TIMES[player] then
            profile.Data.seconds_played += (tick() - PLAYER_LOGIN_TIMES[player])
            PLAYER_LOGIN_TIMES[player] = nil
        end
 
        profile.Data.player_options = PlayerOptions:SaveOptions(player)

        local minute_store = DataStoreService:GetOrderedDataStore(game_settings.leaderboard_data.minutes.datastore)
        pcall(function()
            minute_store:UpdateAsync(player.UserId, function()
                return math.floor(profile.Data.seconds_played/60)
            end)
        end)

		profile:Release()
	end
end

-- GAMEPASSES

function Datastore:CheckForGamepasses(player)
    local profile = PlayerLog.player_list[player].datastore
    for i,v in pairs(game_settings.gamepasses) do
        local owns = MarketplaceService:UserOwnsGamePassAsync(player.UserId, v.id)

        if owns and not profile.Data.owned_gamepasses[i] then
            profile.Data.owned_gamepasses[i] = true
            --print("PLAYER '"..player.DisplayName.."' now owns gamepass: "..i)
            
            -- add custom gamepass events here
        end
    end
end


-- INITIALIZATION

function Datastore:KnitInit()
    PlayerLog = Knit.GetService("PlayerLog")
    PlayerOptions = Knit.GetService("PlayerOptions")

	GameProfileStore = ProfileService.GetProfileStore(
		"PlayerData",
		game_settings.starter_data
	)
end


return Datastore