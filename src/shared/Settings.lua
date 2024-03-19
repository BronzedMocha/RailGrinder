-- Read-only!!!

local game_settings = {}

game_settings.PhysicsControllersEnabled = false

game_settings.starter_data = {
    last_join = 0;
    login_count = 0;
    owned_gamepasses = {};
    player_options = {}
}

game_settings.controls = {
    jump = {
        keys = {Enum.KeyCode.Space};
    },
    accelerate = {
        keys = {Enum.KeyCode.LeftShift};
    },
    crouch = {
        keys = {Enum.KeyCode.C};
    },
    lean = {
        keys = {
            Enum.KeyCode.W,
            Enum.KeyCode.A,
            Enum.KeyCode.S,
            Enum.KeyCode.D,
            Enum.KeyCode.Up,
            Enum.KeyCode.Left,
            Enum.KeyCode.Down,
            Enum.KeyCode.Right
        };
    },
    catch = {
        keys = {Enum.KeyCode.E};
    },
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
            name = "GamepassName";
            image = "rbxassetid://0123456789";
            info = "Lorem ispum";
            price = 100;
            id = 0123456789;
        };
    ]]
}

return game_settings