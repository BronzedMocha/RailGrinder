-- Read-only!!!

local game_settings = {}

game_settings.starter_data = {
    last_join = 0;
    login_count = 0;
    owned_gamepasses = {};
    player_options = {}
}

game_settings.player_options = {
    --[[[1] = {
        name = "AFK";
        info = "Toggle AFK";
        default = false;
        storable = false;
    };]]
}

game_settings.gamepasses = {
    --[[
        gamepass = {
            name = "Gamepass Name";
            image = "rbxassetid://0123456789";
            info = "Lorem ispum";
            price = 100;
            id = 0123456789;
        };
    ]]
}

return game_settings