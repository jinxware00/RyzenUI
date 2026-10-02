local Ryzen = loadstring(game:HttpGet("https://raw.githubusercontent.com/jinxware00/RyzenUI/refs/heads/main/RyzenLib.lua"))()

local Window = Ryzen:Window({
    Name = "Ryzen Example",
    Subtitle = "v1.0",
    Size = Vector2.new(620, 480),
    Keybind = "rshift",
})

local Main = Window:Page({ Name = "Main", Icon = "home" })
local Visuals = Window:Page({ Name = "Visuals", Icon = "eye" })

local General = Main:Section({ Name = "General", Side = 1 })
local Tuning = Main:Section({ Name = "Tuning", Side = 2 })

General:Label("Welcome to Ryzen")

General:Toggle({
    Name = "Enabled",
    Default = false,
    Flag = "Enabled",
    Tooltip = "Master switch",
    Callback = function(Value)
        Ryzen:Notify(Value and "Enabled" or "Disabled", 2)
    end,
})

General:Button({
    Name = "Say hello",
    Callback = function()
        Ryzen:Notify("Hello from Ryzen", 3)
    end,
})

General:Textbox({
    Name = "Nickname",
    Default = "",
    Flag = "Nickname",
})

Tuning:Slider({
    Name = "Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Suffix = " studs",
    Flag = "Speed",
})

Tuning:Dropdown({
    Name = "Mode",
    Items = { "Legit", "Rage", "Silent" },
    Default = "Legit",
    Flag = "Mode",
    Callback = function(Selection)
        print("Mode:", Selection[1])
    end,
})

Tuning:Dropdown({
    Name = "Targets",
    Items = { "Head", "Torso", "Arms", "Legs" },
    Default = { "Head" },
    Multi = true,
    Searchable = true,
    Flag = "Targets",
})

local Look = Visuals:Section({ Name = "Look", Side = 1 })

Look:Colorpicker({
    Name = "Accent",
    Default = Color3.fromRGB(122, 134, 255),
    Flag = "Accent",
    Callback = function(Color, Alpha)
        print("Accent:", Color, Alpha)
    end,
})

Look:Keybind({
    Name = "Toggle ESP",
    Default = "e",
    Flag = "EspKey",
    Callback = function(Key)
        print("Bound to", Key)
    end,
})

task.spawn(function()
    while true do
        if Ryzen.Flags.Enabled then
            print("Speed:", Ryzen.Flags.Speed)
        end
        task.wait(1)
    end
end)

Ryzen:Notify("Loaded", 4)
