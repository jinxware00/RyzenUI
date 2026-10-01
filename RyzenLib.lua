local function CreateRyzenBackend()
    local RegistryName = "RyzenUI"
    local Environment = nil
    pcall(function()
        Environment = getfenv and getfenv() or _G
    end)
    if type(Environment) ~= "table" then
        Environment = {}
    end
    local SharedTable = type(shared) == "table" and shared or {}
    local function SetGlobal(Key, Value)
        pcall(function()
            Environment[Key] = Value
        end)
        pcall(function()
            getgenv()[Key] = Value
        end)
        pcall(function()
            _G[Key] = Value
        end)
        pcall(function()
            SharedTable[Key] = Value
        end)
    end
    local function GetGlobal(Key)
        local Found
        pcall(function()
            Found = getgenv()[Key]
        end)
        if Found ~= nil then
            return Found
        end
        pcall(function()
            Found = _G[Key]
        end)
        if Found ~= nil then
            return Found
        end
        pcall(function()
            Found = SharedTable[Key]
        end)
        if Found ~= nil then
            return Found
        end
        pcall(function()
            Found = Environment[Key]
        end)
        return Found
    end
    local function ResolveFunction(Name, Default)
        local Candidate = Environment[Name]
        if type(Candidate) ~= "function" then
            pcall(function()
                Candidate = _G[Name]
            end)
        end
        if type(Candidate) ~= "function" then
            return Default
        end
        return Candidate
    end
    local IsKeyPressed =
        ResolveFunction(
        "iskeypressed",
        function()
            return false
        end
    )
    local IsMouse1Pressed =
        ResolveFunction(
        "ismouse1pressed",
        function()
            return false
        end
    )
    local IsMouse2Pressed =
        ResolveFunction(
        "ismouse2pressed",
        function()
            return false
        end
    )
    local IsRobloxActive =
        ResolveFunction(
        "isrbxactive",
        function()
            return true
        end
    )
    local SetRobloxInput =
        ResolveFunction(
        "setrobloxinput",
        function()
        end
    )
    local SetClipboard =
        ResolveFunction(
        "setclipboard",
        function()
        end
    )
    local Base64Decode = ResolveFunction("base64decode")
    local Base64Encode = ResolveFunction("base64encode")
    local HttpPost = ResolveFunction("httppost")
    local HttpRequest = ResolveFunction("request") or ResolveFunction("http_request")
    local GetClipboard = ResolveFunction("getclipboard")
    local Clock = os and os.clock
    if type(Clock) ~= "function" then
        Clock =
            ResolveFunction(
            "tick",
            function()
                return 0
            end
        )
    end
    local Color32 = Color3
    local Vector22 = Vector2
    local NewVector2 = Vector22.new
    local NewColor = Color32.fromRGB
    local ColorFromHsv
    pcall(function()
        ColorFromHsv = Color32.fromHSV
    end)
    if type(ColorFromHsv) ~= "function" then
        ColorFromHsv = function()
            return NewColor(255, 255, 255)
        end
    end
    local MathFloor, MathAbs, MathMin, MathMax, MathSin, MathSqrt =
        math.floor,
        math.abs,
        math.min,
        math.max,
        math.sin,
        math.sqrt
    local MathCos, MathPi = math.cos, math.pi
    local TableRemove, TableConcat = table.remove, table.concat
    local WriteFile = ResolveFunction("writefile")
    local ReadFile = ResolveFunction("readfile")
    local IsFile =
        ResolveFunction(
        "isfile",
        function()
            return false
        end
    )
    local IsFolder =
        ResolveFunction(
        "isfolder",
        function()
            return false
        end
    )
    local MakeFolder = ResolveFunction("makefolder")
    local ListFiles =
        ResolveFunction(
        "listfiles",
        function()
            return {}
        end
    )
    local DeleteFile = ResolveFunction("delfile")
    local HttpService
    pcall(function()
        HttpService = game:GetService("HttpService")
    end)
    local function Sanitize(Value, Seen)
        local Kind = type(Value)
        if Kind == "number" then
            if Value ~= Value or Value == math.huge or Value == -math.huge then
                return 0
            end
            return Value
        elseif Kind == "string" or Kind == "boolean" then
            return Value
        elseif Kind == "table" then
            Seen = Seen or {}
            if Seen[Value] then
                return nil
            end
            Seen[Value] = true
            local Object = {}
            pcall(function()
                for Key, Value2 in pairs(Value) do
                    local KeyType = type(Key)
                    if KeyType == "string" or KeyType == "number" then
                        Object[Key] = Sanitize(Value2, Seen)
                    end
                end
            end)
            Seen[Value] = nil
            return Object
        end
        return nil
    end
    local function JsonEncode(Data)
        local Value = Sanitize(Data)
        local Success, Result =
            pcall(
            function()
                return HttpService:JSONEncode(Value)
            end
        )
        if Success then
            return Result
        end
        if type(Value) == "table" then
            local Filtered = {}
            for Key, Value2 in pairs(Value) do
                if
                    pcall(function()
                        return HttpService:JSONEncode(Value2)
                    end)
                 then
                    Filtered[Key] = Value2
                end
            end
            local Success2, EncodedRetry =
                pcall(
                function()
                    return HttpService:JSONEncode(Filtered)
                end
            )
            if Success2 then
                return EncodedRetry
            end
        end
        return nil
    end
    local function JsonDecode(Text)
        local Success, Result =
            pcall(
            function()
                return HttpService:JSONDecode(Text)
            end
        )
        return Success and Result or nil
    end
    local InstanceToken = {}
    SetGlobal(RegistryName .. "InstanceId", InstanceToken)
    pcall(SetRobloxInput, true)
    local function Clamp(Value, Min, Max)
        if Value < Min then
            return Min
        elseif Value > Max then
            return Max
        else
            return Value
        end
    end
    local function IsTrue(Value)
        return Value == true
    end
    local function ToList(Value)
        local Result = {}
        if type(Value) == "table" then
            for Index = 1, #Value do
                Result[Index] = Value[Index]
            end
        elseif Value ~= nil then
            Result[1] = Value
        end
        return Result
    end
    local function ColorsDiffer(ValueA, ValueB)
        if not ValueA or not ValueB then
            return ValueA ~= ValueB
        end
        return MathAbs(ValueA.R - ValueB.R) > 0.001 or MathAbs(ValueA.G - ValueB.G) > 0.001 or
            MathAbs(ValueA.B - ValueB.B) > 0.001
    end
    local function SplitCombo(Text)
        if type(Text) == "string" then
            local Position = string.find(Text, "+", 1, true)
            if Position then
                return string.sub(Text, 1, Position - 1), string.sub(Text, Position + 1)
            end
            return nil, Text
        end
        return nil, nil
    end
    local KeyAliases = {
        rightshift = "rshift",
        leftshift = "lshift",
        rightcontrol = "rctrl",
        leftcontrol = "lctrl",
        rightctrl = "rctrl",
        leftctrl = "lctrl",
        rightalt = "ralt",
        leftalt = "lalt",
        control = "ctrl",
        ["return"] = "enter",
        escape = "esc",
        del = "delete",
        backquote = "tilde",
        grave = "tilde",
        equals = "plus",
        equal = "plus",
        leftbracket = "lbracket",
        rightbracket = "rbracket",
        backslashkey = "backslash",
        mousebutton3 = "mb3",
        middlemouse = "mb3",
        mmb = "mb3",
        m3 = "mb3",
        scrollclick = "mb3",
        mousebutton4 = "mb4",
        mouse4 = "mb4",
        xbutton1 = "mb4",
        m4 = "mb4",
        mousebutton5 = "mb5",
        mouse5 = "mb5",
        xbutton2 = "mb5",
        m5 = "mb5",
        mouse1 = "m1",
        leftmouse = "m1",
        lmb = "m1",
        leftclick = "m1",
        mousebutton1 = "m1",
        mb1 = "m1",
        mouse2 = "m2",
        rightmouse = "m2",
        rmb = "m2",
        rightclick = "m2",
        mousebutton2 = "m2",
        mb2 = "m2"
    }
    local function NormalizeKey(Value)
        if Value == nil then
            return nil
        end
        Value = string.lower(tostring(Value)):gsub("%s+", "")
        if Value == "" or Value == "-" or Value == "none" or Value == "nil" or Value == "unbound" then
            return nil
        end
        return KeyAliases[Value] or Value
    end
    local function NormalizeKeyMode(Value)
        if Value == "Toggle" or Value == "Always" then
            return Value
        end
        return "Hold"
    end
    local KeyDisplayNames = {m1 = "MB1", m2 = "MB2", mb3 = "MB3", mb4 = "MB4", mb5 = "MB5"}
    local function KeyDisplay(Key)
        return KeyDisplayNames[Key] or string.upper(tostring(Key))
    end
    local function ComboDisplay(Value)
        if Value == nil or Value == "" then
            return "none"
        end
        local Modifier, Key = SplitCombo(Value)
        if Modifier then
            return KeyDisplay(Modifier) .. "+" .. KeyDisplay(Key or "")
        end
        return KeyDisplay(Value)
    end
    local White = NewColor(255, 255, 255)
    local Theme = {
        bg = NewColor(16, 18, 18),
        sidebar = NewColor(16, 18, 18),
        white = White,
        text = White,
        sub = White,
        accent = White,
        accentA = NewColor(64, 47, 181),
        accentB = NewColor(207, 48, 170),
        tlRed = NewColor(250, 93, 86),
        tlYellow = NewColor(252, 190, 57),
        tlGreen = NewColor(119, 174, 94),
        trackOff = NewColor(30, 34, 34),
        trackOn = NewColor(56, 62, 62),
        knobOff = NewColor(56, 62, 62),
        sliderTrack = NewColor(56, 62, 62),
        good = NewColor(119, 174, 94),
        bad = NewColor(250, 93, 86),
        unsafe = NewColor(252, 190, 57),
        surface = NewColor(21, 24, 24),
        surface2 = NewColor(30, 34, 34),
        surface3 = NewColor(56, 62, 62),
        border = NewColor(70, 74, 82)
    }
    local ThemePresets = {
        Indigo = {NewColor(122, 134, 255), NewColor(189, 130, 255)},
        NeverBlox = {NewColor(82, 122, 246), NewColor(120, 150, 255)},
        Lemon = {NewColor(252, 211, 49), NewColor(240, 165, 25)},
        Mono = {White, White},
        Sunset = {NewColor(255, 150, 90), NewColor(255, 90, 140)},
        Mint = {NewColor(110, 230, 180), NewColor(90, 200, 255)},
        Rose = {NewColor(255, 120, 160), NewColor(200, 120, 255)},
        Gold = {NewColor(255, 210, 120), NewColor(255, 150, 80)},
        Crimson = {NewColor(255, 100, 100), NewColor(255, 60, 140)},
        Ocean = {NewColor(90, 200, 255), NewColor(120, 140, 255)},
        Toxic = {NewColor(150, 255, 120), NewColor(60, 220, 160)},
        Lavender = {NewColor(180, 160, 255), NewColor(220, 160, 255)},
        Aqua = {NewColor(80, 230, 230), NewColor(80, 180, 255)},
        Ember = {NewColor(255, 120, 60), NewColor(255, 70, 70)},
        Cyber = {NewColor(0, 255, 200), NewColor(120, 100, 255)},
        Bubblegum = {NewColor(255, 140, 220), NewColor(150, 180, 255)},
        Forest = {NewColor(120, 220, 120), NewColor(180, 230, 90)},
        Slate = {NewColor(150, 170, 200), NewColor(110, 130, 170)},
        Cherry = {NewColor(255, 90, 120), NewColor(255, 150, 110)},
        Aurora = {NewColor(120, 255, 200), NewColor(160, 140, 255)},
        Sky = {NewColor(120, 200, 255), NewColor(180, 210, 255)},
        Magma = {NewColor(255, 80, 40), NewColor(255, 180, 40)},
        Grape = {NewColor(170, 110, 255), NewColor(255, 110, 200)},
        Steel = {NewColor(120, 200, 220), NewColor(150, 160, 200)},
        Peach = {NewColor(255, 180, 150), NewColor(255, 130, 160)},
        Neon = {NewColor(0, 240, 255), NewColor(180, 0, 255)},
        Waifu = {NewColor(150, 205, 120), NewColor(195, 230, 130)}
    }
    local Opacity = {
        hairline = 0.10,
        card = 0.03,
        cardStrk = 0.12,
        tabFill = 0.04,
        text = 0.80,
        label = 0.50,
        dim = 0.40,
        hover = 0.70,
        field = 0.05
    }
    Opacity.winShadow = {0.10, 0.07, 0.05, 0.03, 0.015}
    local DrawingFonts = Drawing and Drawing.Fonts or {}
    local FontSystem = DrawingFonts.System or 0
    local FontBold = DrawingFonts.SystemBold or DrawingFonts.System or 0
    local FontUi = DrawingFonts.UI or DrawingFonts.System or 0
    local FontMonospace = DrawingFonts.Monospace or 0
    local FontWidthRatios = {
        [FontSystem] = 0.48,
        [FontBold] = 0.52,
        [FontUi] = 0.50,
        [FontMonospace] = 0.60,
        [DrawingFonts.Minecraft or -1] = 0.55,
        [DrawingFonts.Pixel or -2] = 0.50,
        [DrawingFonts.Fortnite or -3] = 0.55,
        [DrawingFonts.ProximaSoftBold or -4] = 0.53
    }
    local FontChoices = {}
    do
        local Candidate = {
            {"Default", FontSystem},
            {"Bold", FontBold},
            {"Proxima", DrawingFonts.ProximaSoftBold},
            {"Proggy", FontUi},
            {"Minecraft", DrawingFonts.Minecraft},
            {"JetBrains", FontMonospace},
            {"Pixel", DrawingFonts.Pixel},
            {"Fortnite", DrawingFonts.Fortnite}
        }
        for _, Entry in ipairs(Candidate) do
            if Entry[2] ~= nil then
                FontChoices[#FontChoices + 1] = Entry
            end
        end
    end
    local function ResolveFont(Name)
        for _, Entry in ipairs(FontChoices) do
            if Entry[1] == Name then
                return Entry[2]
            end
        end
        return FontSystem
    end
    local State = {
        alive = true,
        destroyed = false,
        open = false,
        rendering = false,
        x = 0,
        y = 0,
        w = 560,
        h = 460,
        minimized = false,
        title = "uilib",
        subtitle = "",
        configName = "default",
        mouseX = 0,
        mouseY = 0,
        hasMouse = false,
        mouseScroll = 0,
        lastFrame = Clock() or 0,
        dt = 1 / 60,
        inputState = nil,
        drawVisible = 0,
        contentFade = 1,
        tabs = {},
        activeTab = nil,
        activeIndex = 1,
        notifications = {},
        drag = nil,
        resizeEdge = nil,
        sliderDrag = nil,
        scrollDrag = nil,
        dropdown = nil,
        colorpicker = nil,
        cpDrag = nil,
        focus = nil,
        repeatKey = nil,
        repeatAt = 0,
        tooltipText = nil,
        tooltipX = 0,
        tooltipY = 0,
        tooltipAt = 0,
        lastTooltipText = nil,
        hoverEffects = true,
        tooltipsEnabled = true,
        smartFps = false,
        checkboxStyle = false,
        hotkeyEnabled = false,
        searchStyle = "off",
        errorCount = 0
    }
    local MenuKey = "p"
    local KeybindItems = {}
    local Keys, KeyNames = {}, {}
    local function RegisterKey(Name, KeyCode, Char, ShiftedChar)
        Name = string.lower(tostring(Name))
        if not Keys[Name] then
            KeyNames[#KeyNames + 1] = Name
        end
        Keys[Name] = {id = KeyCode, held = false, click = false, released = false, char = Char, shifted = ShiftedChar}
    end
    RegisterKey("m1", 0x01)
    RegisterKey("m2", 0x02)
    RegisterKey("mb3", 0x04)
    RegisterKey("mb4", 0x05)
    RegisterKey("mb5", 0x06)
    RegisterKey("backspace", 0x08)
    RegisterKey("tab", 0x09)
    RegisterKey("enter", 0x0D)
    RegisterKey("shift", 0x10)
    RegisterKey("ctrl", 0x11)
    RegisterKey("alt", 0x12)
    RegisterKey("esc", 0x1B)
    RegisterKey("space", 0x20, " ", " ")
    RegisterKey("pageup", 0x21)
    RegisterKey("pagedown", 0x22)
    RegisterKey("end", 0x23)
    RegisterKey("home", 0x24)
    RegisterKey("left", 0x25)
    RegisterKey("up", 0x26)
    RegisterKey("right", 0x27)
    RegisterKey("down", 0x28)
    RegisterKey("insert", 0x2D)
    RegisterKey("delete", 0x2E)
    local ShiftedDigits = {")", "!", "@", "#", "$", "%", "^", "&", "*", "("}
    for Index = 0, 9 do
        RegisterKey(tostring(Index), 0x30 + Index, tostring(Index), ShiftedDigits[Index + 1])
    end
    for Index = 0, 25 do
        local Char = string.char(97 + Index)
        RegisterKey(Char, 0x41 + Index, Char, string.upper(Char))
    end
    for Index = 1, 12 do
        RegisterKey("f" .. Index, 0x6F + Index)
    end
    RegisterKey("lshift", 0xA0)
    RegisterKey("rshift", 0xA1)
    RegisterKey("lctrl", 0xA2)
    RegisterKey("rctrl", 0xA3)
    RegisterKey("lalt", 0xA4)
    RegisterKey("ralt", 0xA5)
    RegisterKey("semicolon", 0xBA, ";", ":")
    RegisterKey("plus", 0xBB, "=", "+")
    RegisterKey("comma", 0xBC, ",", "<")
    RegisterKey("minus", 0xBD, "-", "_")
    RegisterKey("period", 0xBE, ".", ">")
    RegisterKey("slash", 0xBF, "/", "?")
    RegisterKey("tilde", 0xC0, "`", "~")
    RegisterKey("lbracket", 0xDB, "[", "{")
    RegisterKey("backslash", 0xDC, "\\", "|")
    RegisterKey("rbracket", 0xDD, "]", "}")
    RegisterKey("quote", 0xDE, "'", '"')
    local DrawObjects = {sq = {}, tx = {}, ln = {}, ci = {}, tr = {}, im = {}}
    local DrawCache = {sq = {}, tx = {}, ln = {}, ci = {}, tr = {}, im = {}}
    local DrawUsed = {sq = 0, tx = 0, ln = 0, ci = 0, tr = 0, im = 0}
    local DrawHighWater = {sq = 0, tx = 0, ln = 0, ci = 0, tr = 0, im = 0}
    local DrawClassNames = {sq = "Square", tx = "Text", ln = "Line", ci = "Circle", tr = "Triangle", im = "Image"}
    local ZCounter = 0
    local function NextZIndex(Layer)
        ZCounter = ZCounter + 1
        return (Layer or 1) * 10000 + (ZCounter < 10000 and ZCounter or 9999)
    end
    local function ResetDrawPools()
        DrawUsed.sq, DrawUsed.tx, DrawUsed.ln = 0, 0, 0
        DrawUsed.ci, DrawUsed.tr, DrawUsed.im = 0, 0, 0
        ZCounter = 0
    end
    local function AcquireDrawing(Kind)
        if not State.alive or State.destroyed then
            return nil
        end
        local Index = DrawUsed[Kind] + 1
        DrawUsed[Kind] = Index
        local Objects, Caches = DrawObjects[Kind], DrawCache[Kind]
        local Object = Objects[Index]
        local Cache = Caches[Index]
        if not Object then
            local Success, Created =
                pcall(
                function()
                    return Drawing.new(DrawClassNames[Kind])
                end
            )
            if not Success or not Created then
                return nil
            end
            Object = Created
            Objects[Index] = Object
            Cache = {}
            Caches[Index] = Cache
        end
        if Index > DrawHighWater[Kind] then
            DrawHighWater[Kind] = Index
        end
        if Cache.v ~= true then
            Cache.v = true
            Object.Visible = true
        end
        return Object, Cache
    end
    local function HideUnusedDrawings()
        for Kind, Objects in pairs(DrawObjects) do
            local Caches = DrawCache[Kind]
            local Used, HighWater = DrawUsed[Kind], DrawHighWater[Kind]
            if Used < HighWater then
                for Index = Used + 1, HighWater do
                    local Object, Info = Objects[Index], Caches[Index]
                    if Object and Info and Info.v ~= false then
                        Info.v = false
                        Object.Visible = false
                    end
                end
            end
            if Used > HighWater then
                DrawHighWater[Kind] = Used
            end
        end
    end
    local function HideAllDrawings()
        for Kind, Objects in pairs(DrawObjects) do
            local Caches = DrawCache[Kind]
            for Index = 1, #Objects do
                local Object, Cache = Objects[Index], Caches[Index]
                if Object and Cache and Cache.v ~= false then
                    Cache.v = false
                    Object.Visible = false
                end
            end
        end
    end
    local function HideImages()
        pcall(function()
            for _, Kind in ipairs(State.tabs) do
                if Kind._img then
                    Kind._img.Visible = false
                    if Kind._ic then
                        Kind._ic[7] = false
                    end
                end
                if Kind._imgA then
                    Kind._imgA.Visible = false
                    if Kind._icA then
                        Kind._icA[7] = false
                    end
                end
                if Kind.subs then
                    for _, Entry in ipairs(Kind.subs) do
                        if Entry._img then
                            Entry._img.Visible = false
                            if Entry._ic then
                                Entry._ic[7] = false
                            end
                        end
                        if Entry._imgA then
                            Entry._imgA.Visible = false
                            if Entry._icA then
                                Entry._icA[7] = false
                            end
                        end
                    end
                end
                for _, Entry in ipairs(Kind.sections) do
                    for _, Target in ipairs(Entry.items) do
                        if Target._img then
                            Target._img.Visible = false
                        end
                        if Target._ddImg then
                            Target._ddImg.Visible = false
                            if Target._ddIc then
                                Target._ddIc[7] = false
                            end
                        end
                    end
                end
            end
            if State._gearImg then
                State._gearImg.Visible = false
            end
            if State.bgImg then
                State.bgImg.Visible = false
            end
            if State.avatarImg then
                State.avatarImg.Visible = false
            end
            if State.logoImg then
                State.logoImg.Visible = false
            end
            if State.iconImg then
                State.iconImg.Visible = false
            end
        end)
    end
    local function RemoveAllDrawings()
        for Kind, Objects in pairs(DrawObjects) do
            local Caches = DrawCache[Kind]
            for Index = 1, #Objects do
                local Object = Objects[Index]
                if Object then
                    pcall(function()
                        Object.Visible = false
                        Object:Remove()
                    end)
                    Objects[Index] = nil
                end
                Caches[Index] = nil
            end
        end
    end
    local SupportsCorner, SupportsOutline = false, false
    pcall(function()
        local Value = Drawing.new("Square")
        Value.Corner = 4
        SupportsCorner = true
        Value:Remove()
    end)
    pcall(function()
        local Kind = Drawing.new("Text")
        Kind.Outline = true
        SupportsOutline = true
        Kind:Remove()
    end)
    local function FillRect(X, Y, Width, Height, Color, ZIndex, Rounding, Alpha)
        if Width <= 0 or Height <= 0 then
            ZCounter = ZCounter + 1
            return
        end
        local Object, Cache = AcquireDrawing("sq")
        if not Object then
            return
        end
        if Cache[1] ~= X or Cache[2] ~= Y then
            Cache[1], Cache[2] = X, Y
            Object.Position = NewVector2(X, Y)
        end
        if Cache[3] ~= Width or Cache[4] ~= Height then
            Cache[3], Cache[4] = Width, Height
            Object.Size = NewVector2(Width, Height)
        end
        local Red, Green, Blue = Color.R, Color.G, Color.B
        if Cache[5] ~= Red or Cache[6] ~= Green or Cache[7] ~= Blue then
            Cache[5], Cache[6], Cache[7] = Red, Green, Blue
            Object.Color = Color
        end
        if Cache[8] ~= true then
            Cache[8] = true
            Object.Filled = true
        end
        if SupportsCorner then
            local CornerRadius = (Rounding or 0) * (State.roundScale or 1)
            if Cache[9] ~= CornerRadius then
                Cache[9] = CornerRadius
                Object.Corner = CornerRadius
            end
        end
        local ZIndexValue = NextZIndex(ZIndex)
        if Cache[10] ~= ZIndexValue then
            Cache[10] = ZIndexValue
            Object.ZIndex = ZIndexValue
        end
        local Alpha2 = Alpha or 1
        if Cache[11] ~= Alpha2 then
            Cache[11] = Alpha2
            Object.Transparency = Alpha2
        end
    end
    local function StrokeRect(X, Y, Width, Height, Color, ZIndex, Rounding, Alpha)
        if Width <= 0 or Height <= 0 then
            ZCounter = ZCounter + 1
            return
        end
        local Object, Cache = AcquireDrawing("sq")
        if not Object then
            return
        end
        if Cache[1] ~= X or Cache[2] ~= Y then
            Cache[1], Cache[2] = X, Y
            Object.Position = NewVector2(X, Y)
        end
        if Cache[3] ~= Width or Cache[4] ~= Height then
            Cache[3], Cache[4] = Width, Height
            Object.Size = NewVector2(Width, Height)
        end
        local Red, Green, Blue = Color.R, Color.G, Color.B
        if Cache[5] ~= Red or Cache[6] ~= Green or Cache[7] ~= Blue then
            Cache[5], Cache[6], Cache[7] = Red, Green, Blue
            Object.Color = Color
        end
        if Cache[8] ~= false then
            Cache[8] = false
            Object.Filled = false
        end
        if SupportsCorner then
            local CornerRadius = (Rounding or 0) * (State.roundScale or 1)
            if Cache[9] ~= CornerRadius then
                Cache[9] = CornerRadius
                Object.Corner = CornerRadius
            end
        end
        local ZIndexValue = NextZIndex(ZIndex)
        if Cache[10] ~= ZIndexValue then
            Cache[10] = ZIndexValue
            Object.ZIndex = ZIndexValue
        end
        local Alpha2 = Alpha or 1
        if Cache[11] ~= Alpha2 then
            Cache[11] = Alpha2
            Object.Transparency = Alpha2
        end
    end
    local function DrawLine(X1, Y1, X2, Y2, Color, ZIndex, Thickness, Alpha)
        local Object, Cache = AcquireDrawing("ln")
        if not Object then
            return
        end
        if Cache[1] ~= X1 or Cache[2] ~= Y1 then
            Cache[1], Cache[2] = X1, Y1
            Object.From = NewVector2(X1, Y1)
        end
        if Cache[3] ~= X2 or Cache[4] ~= Y2 then
            Cache[3], Cache[4] = X2, Y2
            Object.To = NewVector2(X2, Y2)
        end
        local Red, Green, Blue = Color.R, Color.G, Color.B
        if Cache[5] ~= Red or Cache[6] ~= Green or Cache[7] ~= Blue then
            Cache[5], Cache[6], Cache[7] = Red, Green, Blue
            Object.Color = Color
        end
        local LineThickness = Thickness or 1
        if Cache[8] ~= LineThickness then
            Cache[8] = LineThickness
            Object.Thickness = LineThickness
        end
        local ZIndexValue = NextZIndex(ZIndex)
        if Cache[9] ~= ZIndexValue then
            Cache[9] = ZIndexValue
            Object.ZIndex = ZIndexValue
        end
        local Alpha2 = Alpha or 1
        if Cache[10] ~= Alpha2 then
            Cache[10] = Alpha2
            Object.Transparency = Alpha2
        end
    end
    local function DrawCircle(X, Y, Radius, Color, ZIndex, Filled, Thickness, Sides, Alpha)
        local Object, Cache = AcquireDrawing("ci")
        if not Object then
            return
        end
        if Cache[1] ~= X or Cache[2] ~= Y then
            Cache[1], Cache[2] = X, Y
            Object.Position = NewVector2(X, Y)
        end
        if Cache[3] ~= Radius then
            Cache[3] = Radius
            Object.Radius = Radius
        end
        local Red, Green, Blue = Color.R, Color.G, Color.B
        if Cache[4] ~= Red or Cache[5] ~= Green or Cache[6] ~= Blue then
            Cache[4], Cache[5], Cache[6] = Red, Green, Blue
            Object.Color = Color
        end
        local IsFilled = Filled ~= false
        if Cache[7] ~= IsFilled then
            Cache[7] = IsFilled
            Object.Filled = IsFilled
        end
        local LineThickness = Thickness or 1
        if Cache[8] ~= LineThickness then
            Cache[8] = LineThickness
            Object.Thickness = LineThickness
        end
        local SideCount = Sides or 32
        if Cache[9] ~= SideCount then
            Cache[9] = SideCount
            Object.NumSides = SideCount
        end
        local ZIndexValue = NextZIndex(ZIndex)
        if Cache[10] ~= ZIndexValue then
            Cache[10] = ZIndexValue
            Object.ZIndex = ZIndexValue
        end
        local Alpha2 = Alpha or 1
        if Cache[11] ~= Alpha2 then
            Cache[11] = Alpha2
            Object.Transparency = Alpha2
        end
    end
    local function DrawTriangle(PointA, PointB, PointC, Color, ZIndex, Filled, Alpha)
        local Object, Key = AcquireDrawing("tr")
        if not Object then
            return
        end
        if Key[1] ~= PointA.X or Key[2] ~= PointA.Y then
            Key[1], Key[2] = PointA.X, PointA.Y
            Object.PointA = PointA
        end
        if Key[3] ~= PointB.X or Key[4] ~= PointB.Y then
            Key[3], Key[4] = PointB.X, PointB.Y
            Object.PointB = PointB
        end
        if Key[5] ~= PointC.X or Key[6] ~= PointC.Y then
            Key[5], Key[6] = PointC.X, PointC.Y
            Object.PointC = PointC
        end
        local Red, Green, Blue = Color.R, Color.G, Color.B
        if Key[7] ~= Red or Key[8] ~= Green or Key[9] ~= Blue then
            Key[7], Key[8], Key[9] = Red, Green, Blue
            Object.Color = Color
        end
        local IsFilled = Filled ~= false
        if Key[10] ~= IsFilled then
            Key[10] = IsFilled
            Object.Filled = IsFilled
        end
        if Key[13] ~= 1 then
            Key[13] = 1
            Object.Thickness = 1
        end
        local ZIndexValue = NextZIndex(ZIndex)
        if Key[11] ~= ZIndexValue then
            Key[11] = ZIndexValue
            Object.ZIndex = ZIndexValue
        end
        local Transparency = Alpha or 1
        if Key[12] ~= Transparency then
            Key[12] = Transparency
            Object.Transparency = Transparency
        end
    end
    local function ResolveUiFont(Font)
        local UiFont = State.uiFont
        if UiFont and (Font == FontSystem or Font == FontBold) then
            return UiFont
        end
        return Font
    end
    local function MeasureText(Text, Size, Font)
        Font = ResolveUiFont(Font)
        return #tostring(Text or "") * (Size or 13) * (FontWidthRatios[Font] or 0.48)
    end
    local function TruncateText(Text, MaxWidth, Size, Font)
        Text = tostring(Text or "")
        Font = ResolveUiFont(Font)
        local CharWidth = FontWidthRatios[Font] or 0.48
        local MaxChars = MathFloor(MaxWidth / ((Size or 13) * CharWidth))
        if #Text <= MaxChars then
            return Text
        end
        if MaxChars <= 2 then
            return ""
        end
        return string.sub(Text, 1, MaxChars - 2) .. ".."
    end
    local function WrapText(Text, MaxWidth, Size, Font)
        Text = tostring(Text or "")
        local CharWidth = FontWidthRatios[Font] or 0.48
        local MaxChars = MathMax(1, MathFloor(MaxWidth / ((Size or 13) * CharWidth)))
        local Lines, Line = {}, ""
        for Word in string.gmatch(Text, "%S+") do
            local Candidate = Line == "" and Word or Line .. " " .. Word
            if #Candidate <= MaxChars then
                Line = Candidate
            else
                if Line ~= "" then
                    Lines[#Lines + 1] = Line
                end
                if #Word > MaxChars then
                    while #Word > MaxChars do
                        Lines[#Lines + 1] = string.sub(Word, 1, MaxChars)
                        Word = string.sub(Word, MaxChars + 1)
                    end
                    Line = Word
                else
                    Line = Word
                end
            end
        end
        if Line ~= "" then
            Lines[#Lines + 1] = Line
        end
        if #Lines == 0 then
            Lines[1] = ""
        end
        return Lines
    end
    local function CenterTextY(Y, Height, Size)
        return MathFloor(Y + (Height - (Size or 13)) / 2 + 0.5)
    end
    local function DrawText(Text, X, Y, Color, Size, Font, ZIndex, Centered, Outlined, MaxWidth, Alpha)
        Text = tostring(Text or "")
        if Text == "" then
            ZCounter = ZCounter + 1
            return
        end
        if MaxWidth then
            Text = TruncateText(Text, MaxWidth, Size, Font)
            if Text == "" then
                ZCounter = ZCounter + 1
                return
            end
        end
        local Object, Cache = AcquireDrawing("tx")
        if not Object then
            return
        end
        local ResolvedFont = ResolveUiFont(Font or FontSystem)
        local FontSize = Size or 13
        local DrawX = Centered == true and X - MeasureText(Text, FontSize, ResolvedFont) / 2 or X
        local DrawColor = Color == White and Theme.text or Color
        if Cache[9] ~= Text then
            Cache[9] = Text
            Object.Text = Text
        end
        local Red, Green, Blue = DrawColor.R, DrawColor.G, DrawColor.B
        if Cache[3] ~= Red or Cache[4] ~= Green or Cache[5] ~= Blue then
            Cache[3], Cache[4], Cache[5] = Red, Green, Blue
            Object.Color = DrawColor
        end
        if Cache[10] ~= ResolvedFont then
            Cache[10] = ResolvedFont
            Object.Font = ResolvedFont
        end
        if Cache[6] ~= FontSize then
            Cache[6] = FontSize
            Object.Size = FontSize
        end
        if SupportsOutline then
            local IsOutlined = Outlined == true
            if Cache[12] ~= IsOutlined then
                Cache[12] = IsOutlined
                Object.Outline = IsOutlined
            end
        end
        if Cache[11] ~= false then
            Cache[11] = false
            Object.Center = false
        end
        if Cache[1] ~= DrawX or Cache[2] ~= Y then
            Cache[1], Cache[2] = DrawX, Y
            Object.Position = NewVector2(DrawX, Y)
        end
        local ZIndexValue = NextZIndex((ZIndex or 1) + 10)
        if Cache[7] ~= ZIndexValue then
            Cache[7] = ZIndexValue
            Object.ZIndex = ZIndexValue
        end
        local Alpha2 = Alpha or 1
        if Cache[8] ~= Alpha2 then
            Cache[8] = Alpha2
            Object.Transparency = Alpha2
        end
    end
    local function DrawCenteredText(Text, CenterX, Y, Color, Size, Font, ZIndex, Alpha)
        Text = tostring(Text or "")
        if Text == "" then
            ZCounter = ZCounter + 1
            return
        end
        local Object, Cache = AcquireDrawing("tx")
        if not Object then
            return
        end
        local ResolvedFont = ResolveUiFont(Font or FontSystem)
        local FontSize = Size or 13
        local DrawColor = Color == White and Theme.text or Color
        if Cache[9] ~= Text then
            Cache[9] = Text
            Object.Text = Text
        end
        local Red, Green, Blue = DrawColor.R, DrawColor.G, DrawColor.B
        if Cache[3] ~= Red or Cache[4] ~= Green or Cache[5] ~= Blue then
            Cache[3], Cache[4], Cache[5] = Red, Green, Blue
            Object.Color = DrawColor
        end
        if Cache[10] ~= ResolvedFont then
            Cache[10] = ResolvedFont
            Object.Font = ResolvedFont
        end
        if Cache[6] ~= FontSize then
            Cache[6] = FontSize
            Object.Size = FontSize
        end
        if SupportsOutline then
            if Cache[12] ~= false then
                Cache[12] = false
                Object.Outline = false
            end
        end
        if Cache[11] ~= true then
            Cache[11] = true
            Object.Center = true
        end
        if Cache[1] ~= CenterX or Cache[2] ~= Y then
            Cache[1], Cache[2] = CenterX, Y
            Object.Position = NewVector2(CenterX, Y)
        end
        local ZIndexValue = NextZIndex((ZIndex or 1) + 10)
        if Cache[7] ~= ZIndexValue then
            Cache[7] = ZIndexValue
            Object.ZIndex = ZIndexValue
        end
        local Alpha2 = Alpha or 1
        if Cache[8] ~= Alpha2 then
            Cache[8] = Alpha2
            Object.Transparency = Alpha2
        end
    end
    local function Approach(Current, Target, Speed)
        if State.noAnim or State.lite or not Current then
            return Target
        end
        local DeltaTime = State.dt or 1 / 60
        if DeltaTime <= 0 then
            DeltaTime = 1 / 60
        end
        return Current + (Target - Current) * (1 - math.exp(-(Speed or 15) * DeltaTime))
    end
    local GradientCache = {c1 = nil, c2 = nil, steps = nil, cols = nil}
    local function DrawGradient(X, Y, Width, Height, ColorA, ColorB, ZIndex, Alpha)
        if Width <= 0 then
            return
        end
        local Steps = State.lite and 6 or 24
        local Cache = GradientCache
        if Cache.steps ~= Steps or Cache.c1 ~= ColorA or Cache.c2 ~= ColorB then
            local Colors = {}
            for Index = 1, Steps do
                local Kind = (Index - 0.5) / Steps
                Colors[Index] =
                    Color32.new(
                    ColorA.R + (ColorB.R - ColorA.R) * Kind,
                    ColorA.G + (ColorB.G - ColorA.G) * Kind,
                    ColorA.B + (ColorB.B - ColorA.B) * Kind
                )
            end
            Cache.steps, Cache.c1, Cache.c2, Cache.cols = Steps, ColorA, ColorB, Colors
        end
        local Cols = Cache.cols
        local Left = MathFloor(X + 0.5)
        for Index = 1, Steps do
            local Right = MathFloor(X + Width * Index / Steps + 0.5)
            local SliceWidth = Right - Left
            if SliceWidth < 1 then
                SliceWidth = 1
            end
            FillRect(Left, Y, SliceWidth, Height, Cols[Index], ZIndex, 0, Alpha)
            Left = Right
        end
    end
    function State.fadeLine(X, Y, Width, Color, ZIndex, Alpha, Reversed)
        if Width <= 6 or Alpha <= 0.003 then
            return
        end
        local Slices = State.lite and 8 or MathMin(26, MathMax(10, MathFloor(Width / 6)))
        local Left = MathFloor(X + 0.5)
        for Index = 1, Slices do
            local Right = MathFloor(X + Width * Index / Slices + 0.5)
            local SliceWidth = Right - Left
            if SliceWidth >= 1 then
                local Kind = (Index - 0.5) / Slices
                if not Reversed then
                    Kind = 1 - Kind
                end
                FillRect(Left, Y, SliceWidth, 1, Color, ZIndex, 0, Alpha * Kind * Kind)
            end
            Left = Right
        end
    end
    local function LerpColor(ColorA, ColorB, Amount)
        return Color32.new(
            ColorA.R + (ColorB.R - ColorA.R) * Amount,
            ColorA.G + (ColorB.G - ColorA.G) * Amount,
            ColorA.B + (ColorB.B - ColorA.B) * Amount
        )
    end
    local function MidColor(ColorA, ColorB, Amount)
        return LerpColor(ColorA, ColorB, 0.5)
    end
    local function ColorToHsv(Color)
        local Red, Green, Blue = Color.R, Color.G, Color.B
        local Max, Min = MathMax(Red, Green, Blue), MathMin(Red, Green, Blue)
        local Delta = Max - Min
        local Hue, Saturation = 0, Max > 0 and Delta / Max or 0
        if Delta > 0 then
            if Max == Red then
                Hue = (Green - Blue) / Delta % 6
            elseif Max == Green then
                Hue = (Blue - Red) / Delta + 2
            else
                Hue = (Red - Green) / Delta + 4
            end
            Hue = Hue / 6
        end
        return Hue, Saturation, Max
    end
    local function ColorToHex(Color)
        local function Blue(Value)
            local Entry = MathFloor(Clamp(Value, 0, 1) * 255 + 0.5)
            return string.format("%02X", Entry)
        end
        return "#" .. Blue(Color.R) .. Blue(Color.G) .. Blue(Color.B)
    end
    local function HexToColor(Text)
        Text = string.gsub(tostring(Text or ""), "[^0-9a-fA-F]", "")
        if #Text == 3 then
            Text = Text:gsub("(.)", "%1%1")
        end
        if #Text < 6 then
            return nil
        end
        local Red = tonumber(string.sub(Text, 1, 2), 16)
        local Green = tonumber(string.sub(Text, 3, 4), 16)
        local Blue = tonumber(string.sub(Text, 5, 6), 16)
        if not (Red and Green and Blue) then
            return nil
        end
        return NewColor(Red, Green, Blue)
    end
    local IconStroke = 1.4
    local IconDrawers = {}
    IconDrawers["target"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX, CenterY = X + Size / 2, Y + Size / 2
        DrawCircle(CenterX, CenterY, Size * 0.44, Color, ZIndex, false, IconStroke, 26, Alpha)
        DrawCircle(CenterX, CenterY, Size * 0.24, Color, ZIndex, false, IconStroke, 22, Alpha)
        DrawCircle(CenterX, CenterY, Size * 0.06, Color, ZIndex, true, 1, 12, Alpha)
    end
    IconDrawers["crosshair"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX, CenterY = X + Size / 2, Y + Size / 2
        DrawCircle(CenterX, CenterY, Size * 0.4, Color, ZIndex, false, IconStroke, 26, Alpha)
        DrawLine(CenterX, Y, CenterX, Y + Size * 0.16, Color, ZIndex, IconStroke, Alpha)
        DrawLine(CenterX, Y + Size * 0.84, CenterX, Y + Size, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X, CenterY, X + Size * 0.16, CenterY, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.84, CenterY, X + Size, CenterY, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["user"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawCircle(X + Size / 2, Y + Size * 0.33, Size * 0.17, Color, ZIndex, false, IconStroke, 18, Alpha)
        DrawLine(X + Size * 0.22, Y + Size * 0.88, X + Size * 0.32, Y + Size * 0.64, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.78, Y + Size * 0.88, X + Size * 0.68, Y + Size * 0.64, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.32, Y + Size * 0.64, X + Size * 0.68, Y + Size * 0.64, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.22, Y + Size * 0.88, X + Size * 0.78, Y + Size * 0.88, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["eye"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX, CenterY = X + Size / 2, Y + Size / 2
        DrawCircle(CenterX, CenterY, Size * 0.15, Color, ZIndex, false, IconStroke, 16, Alpha)
        DrawCircle(CenterX, CenterY, Size * 0.05, Color, ZIndex, true, 1, 10, Alpha)
        DrawLine(X + Size * 0.12, CenterY, X + Size * 0.32, Y + Size * 0.3, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.32, Y + Size * 0.3, X + Size * 0.68, Y + Size * 0.3, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.68, Y + Size * 0.3, X + Size * 0.88, CenterY, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.12, CenterY, X + Size * 0.32, Y + Size * 0.7, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.32, Y + Size * 0.7, X + Size * 0.68, Y + Size * 0.7, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.68, Y + Size * 0.7, X + Size * 0.88, CenterY, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["settings"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX, CenterY = X + Size / 2, Y + Size / 2
        DrawCircle(CenterX, CenterY, Size * 0.17, Color, ZIndex, false, IconStroke, 18, Alpha)
        for Index = 0, 5 do
            local Angle = Index * MathPi / 3
            DrawLine(
                CenterX + MathCos(Angle) * Size * 0.25,
                CenterY + MathSin(Angle) * Size * 0.25,
                CenterX + MathCos(Angle) * Size * 0.42,
                CenterY + MathSin(Angle) * Size * 0.42,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
    end
    IconDrawers["folder"] = function(X, Y, Size, Color, ZIndex, Alpha)
        StrokeRect(X + Size * 0.1, Y + Size * 0.34, Size * 0.8, Size * 0.46, Color, ZIndex, 2, Alpha)
        DrawLine(X + Size * 0.1, Y + Size * 0.34, X + Size * 0.1, Y + Size * 0.24, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.1, Y + Size * 0.24, X + Size * 0.42, Y + Size * 0.24, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.42, Y + Size * 0.24, X + Size * 0.5, Y + Size * 0.34, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["code"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterY = Y + Size / 2
        DrawLine(X + Size * 0.38, Y + Size * 0.26, X + Size * 0.18, CenterY, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.18, CenterY, X + Size * 0.38, Y + Size * 0.74, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.62, Y + Size * 0.26, X + Size * 0.82, CenterY, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.82, CenterY, X + Size * 0.62, Y + Size * 0.74, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["sliders"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.14, Y + Size * 0.33, X + Size * 0.86, Y + Size * 0.33, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.14, Y + Size * 0.67, X + Size * 0.86, Y + Size * 0.67, Color, ZIndex, IconStroke, Alpha)
        DrawCircle(X + Size * 0.66, Y + Size * 0.33, Size * 0.1, Color, ZIndex, true, 1, 12, Alpha)
        DrawCircle(X + Size * 0.34, Y + Size * 0.67, Size * 0.1, Color, ZIndex, true, 1, 12, Alpha)
    end
    IconDrawers["shield"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local Points = {{0.5, 0.12}, {0.83, 0.27}, {0.71, 0.78}, {0.5, 0.9}, {0.29, 0.78}, {0.17, 0.27}, {0.5, 0.12}}
        for Index = 1, #Points - 1 do
            DrawLine(
                X + Points[Index][1] * Size,
                Y + Points[Index][2] * Size,
                X + Points[Index + 1][1] * Size,
                Y + Points[Index + 1][2] * Size,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
    end
    IconDrawers["zap"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local Points = {{0.55, 0.1}, {0.3, 0.55}, {0.5, 0.55}, {0.45, 0.9}, {0.7, 0.45}, {0.5, 0.45}, {0.55, 0.1}}
        for Index = 1, #Points - 1 do
            DrawLine(
                X + Points[Index][1] * Size,
                Y + Points[Index][2] * Size,
                X + Points[Index + 1][1] * Size,
                Y + Points[Index + 1][2] * Size,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
    end
    IconDrawers["box"] = function(X, Y, Size, Color, ZIndex, Alpha)
        StrokeRect(X + Size * 0.18, Y + Size * 0.18, Size * 0.64, Size * 0.64, Color, ZIndex, 2, Alpha)
        DrawLine(X + Size * 0.18, Y + Size * 0.4, X + Size * 0.82, Y + Size * 0.4, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["home"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.14, X + Size * 0.15, Y + Size * 0.46, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.14, X + Size * 0.85, Y + Size * 0.46, Color, ZIndex, IconStroke, Alpha)
        StrokeRect(X + Size * 0.27, Y + Size * 0.46, Size * 0.46, Size * 0.4, Color, ZIndex, 1, Alpha)
    end
    IconDrawers["star"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX, CenterY = X + Size / 2, Y + Size / 2
        local Points = {}
        for Index = 0, 10 do
            local Result = Index % 2 == 0 and Size * 0.44 or Size * 0.18
            local Angle = -MathPi / 2 + Index * MathPi / 5
            Points[#Points + 1] = {CenterX + MathCos(Angle) * Result, CenterY + MathSin(Angle) * Result}
        end
        for Index = 1, #Points - 1 do
            DrawLine(
                Points[Index][1],
                Points[Index][2],
                Points[Index + 1][1],
                Points[Index + 1][2],
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
    end
    IconDrawers["swords"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.16, Y + Size * 0.72, X + Size * 0.72, Y + Size * 0.16, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.66, Y + Size * 0.12, X + Size * 0.86, Y + Size * 0.32, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.84, Y + Size * 0.72, X + Size * 0.28, Y + Size * 0.16, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.34, Y + Size * 0.12, X + Size * 0.14, Y + Size * 0.32, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["sword"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.82, Y + Size * 0.16, X + Size * 0.38, Y + Size * 0.6, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.22, Y + Size * 0.56, X + Size * 0.44, Y + Size * 0.78, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.14, Y + Size * 0.86, X + Size * 0.3, Y + Size * 0.7, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["globe"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX, CenterY = X + Size / 2, Y + Size / 2
        DrawCircle(CenterX, CenterY, Size * 0.4, Color, ZIndex, false, IconStroke, 22, Alpha)
        DrawLine(X + Size * 0.11, CenterY, X + Size * 0.89, CenterY, Color, ZIndex, IconStroke, Alpha)
        DrawLine(CenterX, Y + Size * 0.1, CenterX, Y + Size * 0.9, Color, ZIndex, IconStroke, Alpha)
        for Index = 0, 15 do
            local AngleA, AngleB = Index / 16 * 2 * MathPi, (Index + 1) / 16 * 2 * MathPi
            DrawLine(
                CenterX + MathCos(AngleA) * Size * 0.17,
                CenterY + MathSin(AngleA) * Size * 0.4,
                CenterX + MathCos(AngleB) * Size * 0.17,
                CenterY + MathSin(AngleB) * Size * 0.4,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
    end
    IconDrawers["users"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawCircle(X + Size * 0.38, Y + Size * 0.34, Size * 0.15, Color, ZIndex, false, IconStroke, 16, Alpha)
        DrawLine(X + Size * 0.16, Y + Size * 0.86, X + Size * 0.24, Y + Size * 0.64, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.6, Y + Size * 0.64, X + Size * 0.52, Y + Size * 0.86, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.24, Y + Size * 0.64, X + Size * 0.52, Y + Size * 0.64, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.16, Y + Size * 0.86, X + Size * 0.52, Y + Size * 0.86, Color, ZIndex, IconStroke, Alpha)
        DrawCircle(X + Size * 0.7, Y + Size * 0.32, Size * 0.11, Color, ZIndex, false, IconStroke, 14, Alpha)
        DrawLine(X + Size * 0.66, Y + Size * 0.56, X + Size * 0.86, Y + Size * 0.56, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.86, Y + Size * 0.56, X + Size * 0.82, Y + Size * 0.74, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["monitor"] = function(X, Y, Size, Color, ZIndex, Alpha)
        StrokeRect(X + Size * 0.14, Y + Size * 0.2, Size * 0.72, Size * 0.46, Color, ZIndex, 2, Alpha)
        DrawLine(X + Size * 0.38, Y + Size * 0.84, X + Size * 0.62, Y + Size * 0.84, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.66, X + Size * 0.5, Y + Size * 0.84, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["grid"] = function(X, Y, Size, Color, ZIndex, Alpha)
        StrokeRect(X + Size * 0.16, Y + Size * 0.16, Size * 0.3, Size * 0.3, Color, ZIndex, 1.5, Alpha)
        StrokeRect(X + Size * 0.54, Y + Size * 0.16, Size * 0.3, Size * 0.3, Color, ZIndex, 1.5, Alpha)
        StrokeRect(X + Size * 0.16, Y + Size * 0.54, Size * 0.3, Size * 0.3, Color, ZIndex, 1.5, Alpha)
        StrokeRect(X + Size * 0.54, Y + Size * 0.54, Size * 0.3, Size * 0.3, Color, ZIndex, 1.5, Alpha)
    end
    IconDrawers["layers"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX = X + Size / 2
        DrawLine(CenterX, Y + Size * 0.12, X + Size * 0.86, Y + Size * 0.34, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.86, Y + Size * 0.34, CenterX, Y + Size * 0.56, Color, ZIndex, IconStroke, Alpha)
        DrawLine(CenterX, Y + Size * 0.56, X + Size * 0.14, Y + Size * 0.34, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.14, Y + Size * 0.34, CenterX, Y + Size * 0.12, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.14, Y + Size * 0.56, CenterX, Y + Size * 0.78, Color, ZIndex, IconStroke, Alpha)
        DrawLine(CenterX, Y + Size * 0.78, X + Size * 0.86, Y + Size * 0.56, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["gauge"] = function(X, Y, Size, Color, ZIndex, Alpha)
        local CenterX, CenterY = X + Size / 2, Y + Size * 0.62
        for Index = 0, 10 do
            local AngleA, AngleB = MathPi + Index / 11 * MathPi, MathPi + (Index + 1) / 11 * MathPi
            DrawLine(
                CenterX + MathCos(AngleA) * Size * 0.36,
                CenterY + MathSin(AngleA) * Size * 0.36,
                CenterX + MathCos(AngleB) * Size * 0.36,
                CenterY + MathSin(AngleB) * Size * 0.36,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
        DrawLine(CenterX, CenterY, CenterX + Size * 0.2, CenterY - Size * 0.22, Color, ZIndex, IconStroke, Alpha)
        DrawCircle(CenterX, CenterY, Size * 0.05, Color, ZIndex, true, 1, 10, Alpha)
    end
    IconDrawers["map"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.16, Y + Size * 0.22, X + Size * 0.38, Y + Size * 0.14, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.38, Y + Size * 0.14, X + Size * 0.62, Y + Size * 0.22, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.62, Y + Size * 0.22, X + Size * 0.84, Y + Size * 0.14, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.84, Y + Size * 0.14, X + Size * 0.84, Y + Size * 0.78, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.84, Y + Size * 0.78, X + Size * 0.62, Y + Size * 0.86, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.62, Y + Size * 0.86, X + Size * 0.38, Y + Size * 0.78, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.38, Y + Size * 0.78, X + Size * 0.16, Y + Size * 0.86, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.16, Y + Size * 0.86, X + Size * 0.16, Y + Size * 0.22, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.38, Y + Size * 0.14, X + Size * 0.38, Y + Size * 0.78, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.62, Y + Size * 0.22, X + Size * 0.62, Y + Size * 0.86, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["crown"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.14, Y + Size * 0.72, X + Size * 0.2, Y + Size * 0.3, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.2, Y + Size * 0.3, X + Size * 0.35, Y + Size * 0.5, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.35, Y + Size * 0.5, X + Size * 0.5, Y + Size * 0.24, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.24, X + Size * 0.65, Y + Size * 0.5, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.65, Y + Size * 0.5, X + Size * 0.8, Y + Size * 0.3, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.8, Y + Size * 0.3, X + Size * 0.86, Y + Size * 0.72, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.14, Y + Size * 0.72, X + Size * 0.86, Y + Size * 0.72, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["flame"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.1, X + Size * 0.72, Y + Size * 0.4, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.72, Y + Size * 0.4, X + Size * 0.78, Y + Size * 0.66, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.78, Y + Size * 0.66, X + Size * 0.5, Y + Size * 0.9, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.9, X + Size * 0.22, Y + Size * 0.66, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.22, Y + Size * 0.66, X + Size * 0.34, Y + Size * 0.44, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.34, Y + Size * 0.44, X + Size * 0.44, Y + Size * 0.56, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.44, Y + Size * 0.56, X + Size * 0.5, Y + Size * 0.1, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["skull"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawCircle(X + Size / 2, Y + Size * 0.42, Size * 0.3, Color, ZIndex, false, IconStroke, 20, Alpha)
        DrawCircle(X + Size * 0.4, Y + Size * 0.42, Size * 0.06, Color, ZIndex, true, 1, 10, Alpha)
        DrawCircle(X + Size * 0.6, Y + Size * 0.42, Size * 0.06, Color, ZIndex, true, 1, 10, Alpha)
        DrawLine(X + Size * 0.36, Y + Size * 0.72, X + Size * 0.64, Y + Size * 0.72, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.44, Y + Size * 0.7, X + Size * 0.44, Y + Size * 0.84, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.56, Y + Size * 0.7, X + Size * 0.56, Y + Size * 0.84, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["lock"] = function(X, Y, Size, Color, ZIndex, Alpha)
        StrokeRect(X + Size * 0.24, Y + Size * 0.46, Size * 0.52, Size * 0.4, Color, ZIndex, 2, Alpha)
        for Index = 0, 8 do
            local AngleA, AngleB = MathPi + Index / 9 * MathPi, MathPi + (Index + 1) / 9 * MathPi
            DrawLine(
                X + Size / 2 + MathCos(AngleA) * Size * 0.16,
                Y + Size * 0.46 + MathSin(AngleA) * Size * 0.16,
                X + Size / 2 + MathCos(AngleB) * Size * 0.16,
                Y + Size * 0.46 + MathSin(AngleB) * Size * 0.16,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
    end
    IconDrawers["bell"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.28, Y + Size * 0.7, X + Size * 0.3, Y + Size * 0.42, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.72, Y + Size * 0.7, X + Size * 0.7, Y + Size * 0.42, Color, ZIndex, IconStroke, Alpha)
        for Index = 0, 7 do
            local AngleA, AngleB = MathPi + Index / 8 * MathPi, MathPi + (Index + 1) / 8 * MathPi
            DrawLine(
                X + Size / 2 + MathCos(AngleA) * Size * 0.2,
                Y + Size * 0.42 + MathSin(AngleA) * Size * 0.2,
                X + Size / 2 + MathCos(AngleB) * Size * 0.2,
                Y + Size * 0.42 + MathSin(AngleB) * Size * 0.2,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
        DrawLine(X + Size * 0.28, Y + Size * 0.7, X + Size * 0.72, Y + Size * 0.7, Color, ZIndex, IconStroke, Alpha)
        DrawCircle(X + Size / 2, Y + Size * 0.8, Size * 0.05, Color, ZIndex, true, 1, 8, Alpha)
    end
    IconDrawers["compass"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawCircle(X + Size / 2, Y + Size / 2, Size * 0.4, Color, ZIndex, false, IconStroke, 22, Alpha)
        DrawLine(X + Size * 0.62, Y + Size * 0.38, X + Size * 0.5, Y + Size * 0.62, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.62, X + Size * 0.38, Y + Size * 0.5, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.38, Y + Size * 0.5, X + Size * 0.62, Y + Size * 0.38, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["rocket"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.5, Y + Size * 0.1, X + Size * 0.68, Y + Size * 0.5, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.68, Y + Size * 0.5, X + Size * 0.6, Y + Size * 0.72, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.6, Y + Size * 0.72, X + Size * 0.4, Y + Size * 0.72, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.4, Y + Size * 0.72, X + Size * 0.32, Y + Size * 0.5, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.32, Y + Size * 0.5, X + Size * 0.5, Y + Size * 0.1, Color, ZIndex, IconStroke, Alpha)
        DrawCircle(X + Size * 0.5, Y + Size * 0.42, Size * 0.08, Color, ZIndex, false, IconStroke, 12, Alpha)
        DrawLine(X + Size * 0.32, Y + Size * 0.58, X + Size * 0.2, Y + Size * 0.78, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.68, Y + Size * 0.58, X + Size * 0.8, Y + Size * 0.78, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["leaf"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawLine(X + Size * 0.2, Y + Size * 0.8, X + Size * 0.8, Y + Size * 0.2, Color, ZIndex, IconStroke, Alpha)
        for Index = 0, 9 do
            local AngleA, AngleB = -MathPi / 4 + Index / 10 * MathPi, -MathPi / 4 + (Index + 1) / 10 * MathPi
            DrawLine(
                X + Size * 0.5 + MathCos(AngleA) * Size * 0.34,
                Y + Size * 0.5 + MathSin(AngleA) * Size * 0.34,
                X + Size * 0.5 + MathCos(AngleB) * Size * 0.34,
                Y + Size * 0.5 + MathSin(AngleB) * Size * 0.34,
                Color,
                ZIndex,
                IconStroke,
                Alpha
            )
        end
        DrawLine(X + Size * 0.34, Y + Size * 0.66, X + Size * 0.66, Y + Size * 0.34, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["gamepad"] = function(X, Y, Size, Color, ZIndex, Alpha)
        StrokeRect(X + Size * 0.14, Y + Size * 0.34, Size * 0.72, Size * 0.34, Color, ZIndex, 5, Alpha)
        DrawLine(X + Size * 0.26, Y + Size * 0.44, X + Size * 0.26, Y + Size * 0.58, Color, ZIndex, IconStroke, Alpha)
        DrawLine(X + Size * 0.19, Y + Size * 0.51, X + Size * 0.33, Y + Size * 0.51, Color, ZIndex, IconStroke, Alpha)
        DrawCircle(X + Size * 0.68, Y + Size * 0.47, Size * 0.045, Color, ZIndex, true, 1, 8, Alpha)
        DrawCircle(X + Size * 0.76, Y + Size * 0.55, Size * 0.045, Color, ZIndex, true, 1, 8, Alpha)
    end
    IconDrawers["search"] = function(X, Y, Size, Color, ZIndex, Alpha)
        DrawCircle(X + Size * 0.42, Y + Size * 0.42, Size * 0.26, Color, ZIndex, false, IconStroke, 20, Alpha)
        DrawLine(X + Size * 0.62, Y + Size * 0.62, X + Size * 0.84, Y + Size * 0.84, Color, ZIndex, IconStroke, Alpha)
    end
    IconDrawers["cog"] = IconDrawers["settings"]
    local function DrawIcon(Name, X, Y, Size, Color, ZIndex, Alpha)
        local Drawer = IconDrawers[Name]
        if Drawer then
            Drawer(X, Y, Size, Color, ZIndex, Alpha)
        end
    end
    local IconPngData = {
        ["target"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB0klEQVR4nO2Y8VHCUAzGv3r8ryPgBLIBZQPdACZQJ8ANdANlAtmAMgF0A0bQCWoezWGtpMlL4ax3/d29612bl/eRvqR5DNBxBug4vcC2dF7ghfSgKIopjU0hM4UR9iWxafKVSA7p8gqFhICBoMJgdkfulvWbUgTvobOGHYvt/NhNKYLVX/xJ44nG9sfEJMkQAblMa7dG7Pey4jPxCHykeS84A7TMA12eD2KOCLRk8RbnQ/Xd18G2nEQg7aWw4ccoN34gvLo1banW20MSOENZB9dN2UrCrlBu8qnw/A1lkn0cex58k00oQWNe87cNnLC4Fb6jJhGiOJFEalzATyg9mjiwjbtMuSLIe26DOK4pijtE4o1ginhu4cCbxZZXW2cIB/+3H1Tw1LcdHHgjmCGeJRy4IshfiEXElIUng/drwQkX6ozGjWKa00hPWqgrZ4iVNJEXTNEcyYUmLqzRdMaxNKwTrXsm8yHKOldtFpbaa+Uu+xAEb8OqwkLO0nX3DWtbLGXG81mzkmoGlgjOOWnqx86Yc3FIiHHtVgrD+VvK4iBGq28ZiZzAJm4FPVo5+RtZBYaS8Q6FP/vrgw3DGSGHzAx2mmxzSdxeCzpOXwfb0gtsyxfbX+Kilrt4bgAAAABJRU5ErkJggg==",
        ["crosshair"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAADMklEQVR4nM1Y/3XaMBA+8vi/bBB3gqQT1J0AMkHoBJAJSicITFAzAXSCOBM0TFBnA5iA3odPRIiTLBvxXr/39Kwn63Sfdbofcp/+c/QpIfb7/T2evV7vjRLhhhKByY358QdN+kmQjCBjbPVHlAhJTWxhQInQowvAphzyA+cul6chtuWGc1jiyWfyN3VEa4JMCiQmVJs0ixSruBXcFkx2Sy3QiiCTw9l6pnhiLipuT0xyHSsQTZDJgdhUebXjthbllYxl0vBBnxSZOZN8olQEmdwvOvVS4JXbjBWVDbI55nH76rwqWPY7XUqQFcypPnMG2LFxGzPJOtjNgk53FGdySl0JyqIrOiWXd80UkmlKh+RD6GN7gcXgrcgMWQpyAZIVty8+7w5lkimdeuvYRw5KuU1wVqVNTF52IWuMraGMdOer5/tesIK/9EHwlRfOlTnY5Wc6dyCDguqwslVkS/pwnIrnfNYWuPGQG9Hp7s1IJ/cSIEfy7kXmuphb/Ux0xhGkOm0Z7DyhZO7Mo8Bac3dQHGPnzIsmmFv9Mw+T8/VI8XhkmUwZX3t0HnFjKcUiMAfMdmfNqRS5nNpDM2Fl9e+MfnAxg30hhx0pSEeljMWY1kWmjNnOg3OaSz9nTht4/LXqwWQ4mFhiE/Ii6jbkWPvwZopcl2BdKWO2d+9ENzg8mJh73EEeKEjM7MSoTFm4pPbQ0llm9d+0WOvz4tLqD92X8nVLiseSZSplfOjReYSPoG3CgZRMLpCeNtSMDSmpTNYceHSGCUoQfbeGfihz4IE5hXcS73JPIWCv+e6raEK5eOYs4i2LJAgjzpnwg91Ye8yqlXE/ee6MWhIciKJbGcIufEtUbiEZGPPCUvetyy0RsM/OoTjwlVEdyQHT0E0v+GdBTLqgc5Ijak9upJBbNF0dGn99yJ1h6ZBcSc7Mm+QxR/L7ik7JLZvuIwf9FAnl8mQA84SunQNFZhFDrhVBIQmFIHpL3QCHmF7l4m4g3o2vH1M8URArqL6wb6kFLv15ZGJfLk9zU0PiRzgqqc6x0TuWlKANp8BQL1ldcK16sJUZQ0j5h7Xw9C9CMhMD1/iJnpTgNfAPyQ1XINTuz3oAAAAASUVORK5CYII=",
        ["swords"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAADGUlEQVR4nM1YsW4TQRAdO1FEFQIlTSwRatJScWlRivwBxx84X5D4C7C/ALuFJgWijVMhKpI+COcHgNAQIUXOG9/a3tubm9293EV+0mh1d7Mzb3d2ZndvnVYc67TiKBCcTqdbaF4KuletVmtCNQA+Omi2hU8X8PHHftFyOh6jOaJy9GHgkO5H7j2arqLSg49jcgmamftNfgxh4B1VAHx8QJMGqD6Zz2TberlLYUiNoyhEkMtxaVM1RJGMJJeDjyCvtz3ISPgWRFIhNzK21TXtKzPnWAtjtGM44ue3VCRJZWtSI4c+qdEhDb4ZXBAyBoNn0lSElBRyrg8JdhZ30PwUdHJZC71hiVFXjyvClkZOmeFiFpsiPBCUczMUMZPXVI3cwC7WuRDjQzfEeSDJA8iVIdoLJDcyHJacBKWYMAbpOba9iWNDTJLQMDaYOEsupKDumQxJHBdqmWlgJtXEiSbYAMnSxCn1T4FoMnE0BB8W6g43bwyQI0hCml+KRB0zSdmGcErLhDlE3z7FEDQHWD79diAnMDCokeR/yIb1fIZ+iaCnnmb6lvEEznbnzjmMIacbRW/DeZ5QCbQ12BGcR681RW+OC1LuKBrBE6ru3K1/HyG3gt4lJHFvcjYa30kgnyCfBV//IM80cl6CNZHkmVtz3v2FbPvIMUJ3kkvhU2i414R3m5RVCC+8BA2JnZLPTHJRvwISwu3rvXS5fxa49s3DxI54lCn5sTiiczlC842KpYTDuin0HVJ2s1v4tUPvEuTqnpjHX5CngkEO945E0NxrvlPxSDVLCMrXVhu2rzFs7c0/tC1yHYsckUyOR/eC8neXnjXiVCDHA5plq7IEbF+JieQM7gyyo8ckw730zIzY4TAb/6nVh4twoc4pGc+4hn4pQV4/XyGPnE4cguchZQE2eFfgc98E0pX6mMH9oGKUbiCv0OdcJGg6vyG5sJaeOGJhBuGWGd609+Hji/2yUGaMwj5lo7Hhnb174EYiN+NT1sOEe0zZmjyDHISEOAQmxLzXv6bs+J/YYQ0iaBuri1gV29En6ofGyv/lvwPj/9coBGLaTwAAAABJRU5ErkJggg==",
        ["user"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABjUlEQVR4nO2W7U3DQAyG36AOUCYgTABskA2ACegIYZNugJgA2KAbQCboMQHpBMFuXLWq2vuw0yg/7pGstLmL7tF92TNMnBkmTha0kgWtDCbYdV1Jjxv5+1sUhcMAXMEIiT1RrOknx0pize+4DUYKGCCBN3osAt2WNJuvUKKeQZKrEZZjaumrQjWDNOAc/ZLOIz9pKW5pJlskop1B3luxcpC+qv2oPcUl0imhQCt4j3Q036iX+AfpaL5Rz+Bogup7kE6ywz5zhGjoBI+6xAyfyk1EP+6zgBK1IM0IL1kFvyS3VdJXhSkXy8AlBaey5qCpkXelRW47BiZOLlitmASlSL3DPkvsnrt9t4KxeE3egyT1iP6KqRCfXx162U+S/UICUYJSXr1Q1FAm/QMcxZLiPab8CgqSHC/bxwBixziK59A15BUUuW9clgefZEjwD2mFqYaWBK/PNZ7NJDJ7l5Zj5jLWSXzXzBhywbEmf1H7igWHuHLKykbGOknokJQY/no5xvkyTa5mrGRBK1nQyj9JfnKIuCLRswAAAABJRU5ErkJggg==",
        ["eye"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACl0lEQVR4nO1Y4XXaQAyW8/K/bFB3gpIJYiYoTFAyQdMJ4k7QMEHMBIEJ4k6QMAF0A5iA6sOye3F8J9nOy+OHv/cUBSzpPutsScclnTku6cwxEOyLgWBfvAvB4/E4ZvWp9vUhiqIX6omIOkAIfWNJRELIRdZdCLciyMS+s7plGVM3gOA9E11aHUwEmVjC6jd1J1YHiP5korlmqBJkcg+s5mTDX9GfjfYZk7wJGVz4LjCxEcsz6eSwXZOoQCyCG5/ItRDmWANr+QwiHzlWTxTeUmRrqj348kKtKJxVxMBN7kkjaCS3YUmaAnpIImbO8pVakmwi+MhqSmFcuZljn5jVHUvsLLZgm51jgxt+VuKu2GfmJchBQOxRCfKLg6SOz5zVg8f2hm0zxxZ+dxTGjH1WbwjKNmxZRkqAL2VmpPw8KfaTspxIpreK/V7WOG21+xbfGsht3G0THw2VjfhuFPvRKx/8aZG9P7xIUn5gvyMZIGWn9MlZXSsuVRYvHNYauY9ExedEUFK/pvbQtstqU8eyfJTcZ/De4Hhdq/oWn8pGfLXtBbLyn4qgvGkLg/PU8cko3M6Wbpkhvb4CC3eIqNdB3CGKbKgt7ago1HvHL6WiZ5d+aINZrV4iNgp1HIgNv7Ebu6mToOLn9HZCdtE4hUido1opKq9pU9GBivb5qrf7hgVLW1JHpRbkgKumwaNx3BJD9MQD+YFRaSvdxEcsgQ3pmZv5pqLgwCqZzCg8hQB4ZnIqnl8AfgkZOhPLPDSyWSZqLJKy/KD3BSpGqo1s5kOTZDOl4jTXB2sh9mIxbn3slDcVzRw1zXr2OJUdKl6sHbVAp3NxCdn+hP5P37HonWhkKbdO3k3oRfAjMPx41BcDwb4YCPbF2RP8B6CM/vT50VvlAAAAAElFTkSuQmCC",
        ["monitor"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABL0lEQVR4nO2YgQ2CMBBFr8YBdANGcAN1Ah3BDcQJ1AnUDVzBCcQN3EDZgA3wH7aJIhDhYsHkXnIpVggv9Lhw7VPH6VPH+S/BNE0nGGaIEbXDFXEyxkRuwrgDyIUYdtQNVpDc80EmCLkAw426xRCSiVvioOCEC/llnPvNaRaVvSTT1zzwgc3/c36+V3Syb7mqe2odlKKCUlRQigpKUUEpKihFBaWooJTCD1Z83Q7IM7Yv+qDsCZ5xAXdVd/JDgAiL/nCCSW6eG5YjtUvmlC0x+gFumH13cVWcrNNbDs4RB0RM7RFbh4WbMCSkrF20iNtXrYNSGi2xrZNrer7tAyrfDeNET+y45b0W8iTINXJJ9ThAMKx5jdclrv30mKaCGzt+u9EZIfbUAHGZ+TVaZqQ8AFdjQ0+y/ANkAAAAAElFTkSuQmCC",
        ["palette"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACqUlEQVR4nO2Y/3XaMBDHv/D4v2UC3AmSDeJOEDoBZoKECUInCJkgsAGZIGaCwgRVJyhMQO/C+SGrkixLcZrXl89794z1i69POunsAd45A7xz/n+Bx+Pxii653GZyVXLdkm16vd4ekfQQAYmaiKgx2eeALiXZmmzVVmwrgSQsp8sdzh5rC4tbkD2ECg0SSMLYS/dkBV4HRfaNRG6bGjYKFHHPZJd4feYk8ruvgVegiPuJsHUWy4xELlyVfVeF5rkuxTH39F+Fq7Lv6wj/tM7IhmRfyJ4s9U9SN5S2Ph5JZGarsE6xROsz3PB2UWjt2cu84EdS9IvsUo9UarOky8QzZkntv5qFLg/ewU+p34gQpRUpyzZSwk9ODzFGk0BZDzkaBjP6sAdHWtFIypx9HBRoEhg40IQE3LAIWTuPOB9zkN8v60ra3MA/vRXX5oP9tQapwW90H7k+eANfVzc1D0pw2MQdyDZkO6Szk7EOjvrazmFOcW7pwANxROZk3HmKeKY8Bo8lQg5NHfpoZkEDquqGfi8R58md9K3GUTglDiY1D5r5YGbpoCxlMfndPrCslkCEeLAWfRK1F2jPheW0uLa0U/rNwFcp8AbKpwpHFgfQLeKinPv8oLF4WtlzvCnnlnYlPAJd5IhPUnVY5NxTv9HXO2NOcYl/y61ZUBNI6ksEhH5HzGwZti1I1nh7Vq6k1SawxNvBszXVUzcTVz5Y0uUK3cH54hKnQ8C7p8YmrKHwsaiMsn3I21yF86UpIAMOYZjyVYHxnSQc8qnZyxyJhLx2KrJPiP0DAgn0Gwbn6cmQ4EnX21oojcmCiMzJVojAPLraEpLNvIiUvYpfCzcI5wGJxH5+K3D+/OZan/wg49QoTlrAjOyZnAVzQGU4pVJbPXtOIVlg13x8RE/lD10o3SFAI/ONAAAAAElFTkSuQmCC",
        ["settings"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACVElEQVR4nO2Y7VHDMAyG33D8ByYg3aBMQJgANiBMQJmAMAF0gnYD2gloJ2g7QdMNYIIiEfWucWXHTvp1PZ47Xe4ix1ZkW5J9jiPnHEfOaRu4XC4v6fFK0rY0mZK8RVH0jZpEaAAZOKDHfUWzIRn4gJo0neLrLbWx0tSDS5925MHa45yhJrL+tt7W5Kyi45Tki6RHYm6EkHX1YPTblj6579T1YeQwjg2aGK9HJH0ZMHThD0RSksTQ3dAqmCLQwC+lo10xIgPvNIU6xWQceyfB/khkzA02PCgLmqc2xn7JyYst86XmwQ72bxwTk3My82XJg+K9OUloWBij2Dz5ajAUm+EWYXBKbK2nRtNAbedW8UQd9jWFrCvWXcCf0o4uTbEouvDnxWac9LcKK750zXCjhhnPP19QZzE88CgqfkhS+aESapiRhjzdM9j5gD99h47HaGvGMdZURx/kKCK/jSn8yR26gYylcvQVtdWDtG5iuNdNG/7EDt29jKXiSnWTCiOe4c+jQ/cX2mypbsNAavhOj09UB2uO/J2KNqufrap8eKxPGbvENgJ1hxZ512FcD2GZqbW+abRUx8qQyM+MoKe6BGFwPIytqQ6FkRmKo+Qh4CNqtv7CVm5xjGt0GquBmpk2Nom4t3Lx7wB1TFfJP0J4uVSXMTkm0RSuU532R1z3PZEMEc5Qvh0rutT2kfNALUdClpzkY70UEl0PfpRqRglnq8q97yzZUBNJT3PP5ld1L5BO9+pDWHi0maEBTQ2cbqmNlaZTzEE9g/sCMzvYBeY++L9Eb8ov04vnmGZXJSUAAAAASUVORK5CYII=",
        ["sliders"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABa0lEQVR4nO2YgU3DMBBFf1AG6AhhgnYDnA0YgU5AR4ENGIENaDdIN/AGwAThrBgpRL7Qsy8mVH6S5TiJ7eudfT9ujZVTY+UUA1NZvYE3yEDf9w/9wBuEVMiAs2zUbKuqOl7Ydf0hDnqQfvCOqkcqDeI4k5cOo/HGHuyofEzet1SeqU83HYjzoFsrG8Qzt3R2zH1D5XZ6s46YYCmCc3IGGiouRA3i6GaenREO8VPo5bKLU8mSqIm9r08S7znEIfZqYNykNNkLFkZkIBlnMKSgoTOBhfmfXzMzSsImb+rj0sQWcVgwSsJJ3TsuUJJxiKnPkao7xGNpuOtXEudVLoxz6vEbFhpKUnZxAJGSeBU4+eYeGVALkU9N3+FvQykjBk0tdptq48sBSmiuwYa5TkKqJD+gMLbMo63wiGlRlCSdrGeST8iUxWLpM8kkxO7L2UABzTRjmesktBP1q2/eayXqv9gMIsofmKkUA1P5Am/6eNUAfuXtAAAAAElFTkSuQmCC",
        ["shield"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABkUlEQVR4nO2Y7VHDMAyG3/T6n45gJqAjtBPABrgTMAKwQdggbEA3CBvABJQJIBME6aL8AeIvJbnc1c+dLpdasd9KbiN5jYWzxsI5H4Ft2xq6XMvtsSiKE0aggAIStUEnypLtfg2/sJHQZyhIEkjCdnS5Jbsh23jcv9GJfSKxb4gkWKCkkEVZMoM0TmQlIraAV6BE6x5/U6ilj2rtcnIKJHH8be8wLY8k8mFocFCgpPQD83A5lPKV4yGD+TBDA/lNoiUL1JIFaskCtWSBWlzvYq7zvjCHCGJobOV4iAvNT0yPcw1XscDUmJ7aNbh4gSEVNaf6AtPQ0FZy9jS+CDIVpqPyOYRE0NCFu7Gxo9iQbX3NkzeCMkGJ8SlDOruYtpOjeIVxeCdx2xDHkD3YY9GlRUsjcwURLFBOBSz02JgThpgIskhutg9I5yBzhK+JBGg/8v6pEf7L5rTuUs5moiLYIwsZsmOAO/uYFHFMkkCGiwkyPt3ak73+48Kf7dlHCo+0dTAS8odu5bZaxAHmHOSSX8sPoqdhh7W2pFsAAAAASUVORK5CYII=",
        ["folder"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAA5UlEQVR4nO3Y0Q2CMBSF4VPDAG6gIzCCIziCbgAbuIFxAt1AN8ARcBM3wNuEGNqQiD2Q3of7JaSh4eEnTYBSQLkCylkgywJZo4Fd121l2GCal3PujYW4eELiKhnOmM7HnSTyggUEgRK3k6FBmptEHjGzVXS+R7qD3OAVM4sDS3B8ZKq7HOWvwJz86jUSuR5Oagr0fFw1nND4HAyWWWNgsMT2qmNZIMsCWRbIskCWBbIskKU+MP6ibpFf0BAHPpBf0BAEyr72KUONfOq+4cuNXdXvrNgt6L/asV8oDsrZY4ZlgSz1gR+92GNIRtdWlgAAAABJRU5ErkJggg==",
        ["code"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABW0lEQVR4nO2X0XHCMAyGZR/vpRukG3QD0g06QtigI3QTugnpBG0nKCOQCVyJ6sGAQyQL5/Lg787nxOff+jBHHFawcFawcKqglSpopQpaqYJWPCgJITTYNqCEMpQFJSpBLPCM3Re2Hq/3ihzN7SnLa4hx0om8MBVa89DgnFsLsyG6PWJ7wey3JCvawYQc8QZyttE1rbGX7uSk4IjcFnfgA4Tw3CxJX1rOKunnkLNI+rnkciX9nHI5ki4h+ItdA4XkLmp12O2ioQPWeornpL7iS2n1qaFgM1E7KfiKbYjuO/ykO7gzvGYXDQ1c+4wrQX7Ct1BQckSuTZ0uyV9xSUmN3KhgKUmt3E3Be0vmyE0KTki+gxCe24FS7lQfhPBDtMf2wENHLPAozIYcOUL8wprYyR+Q8wkZcqe6oIRf2xss0itilGvh/6Q4KGJ6wbmpfzutVEErVdBKFbSyeME/RofOMy1Qvr4AAAAASUVORK5CYII=",
        ["zap"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABnUlEQVR4nO2Y4U3DMBSEL6j/YQQzAdmAsAEjsAHdgG7QjACTECaATgCdAJggPLcOMiZW+/yuUn7kkyyndpOcznkXKwtMnAUmzizQyuQFnuEE9H3fSvuUdgEjFciIqFq61/DzsqqqDxg4hcBn6ZrdxQUYoT6DIu4WQZywAQF2kayj4y8QoAkU91bSuWioAwGKwFCt98nwpBxspaWR8gYC5ipLYiXGHDEehsDfWPlzYULEeExLnMRKDCViPNZncJ0ZF+39dWZuI+YeXUDFyxBi5QF6bkRgd+yfiwSGWHnH/8o9xIuIazQnlC7xCnpxw3kq1A6Kew5797Q8iXt3UFIicDRWDvAtrS7JRdUSh1BuoKctDW2Vg6E46sy0f91djYxvsXev6N2scjDcpBub88GXOW1ZKm53T5DICFTHSgpru+UyU0sYYW233MiYjxXzloslMC0cHytm9zwsgelbpbUURgylSOQZ7KQbdi9bEedAguXgeXRMWdoBloNDxJhjJcXsYBIxVPc8jCX2xeCr9pERKyn0bzNs5g+YVmaBVn4A2WB+p41hgdoAAAAASUVORK5CYII=",
        ["box"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABOElEQVR4nO2X7Q2CMBRFb43/cQMZgQ3sCDqBjuBIOoGO0BEcQTfQCfA2oNZa1ORhK0lP0vRTe/KARxnjzxnjzxmmYF3XS1aapUQcjixGKbX1J5Q/QLkdqznSsKfkwh0YuR3KrZFOzjJvHe74l7hy2heWA+Jg9y2c9h1fsHTaB4ZbIwKMmmE1CzjkNCNm0IIF740Z4lB0TfiCBo+btWr7sTFu5ylRM2IlmtRSIA02tVXMHsfbwFOibic00qFdOYsKrWIkaySAci8+Oc1IyYJSRpCxVR+wayBA9BSHnrq+/08UQe6r+1jzjj7yoPkwr/EloQjmRC0lC0rJglKyoJTBHhYuiE9wzy5Bg/iY0GDXq65sfzBFHE4IfDBZOo9LlJywWqF52U/wG85oArGh3Dm04KvzXEpympFyBbWzVjAPa8AQAAAAAElFTkSuQmCC",
        ["home"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABV0lEQVR4nO2XjW3CMBCFnysGYIRuUEagE1TdIN2go3QD2KDtBAkb0E2yQfosXVRo/s65AyLhTzoZcTb5dHEOZ4WFs8LCyYJW7kuwaZqXOIYQvuHEA5yg3I7DVwz57EKAEcqsOXwytv9SFeOV1axhwCQociVjMzDlyHi2SM6+xZSLUmNykFwpc2cxq4IncmvlkljBWMkjEkmuIOW2SJODzC1lbRJJgrxAgXS5llaySFmkFpQf9mgfuxRJ1R6UvlbAlz335NvUpMkKXkguUmga+mAFRxqwNxVGGnqvoKIBezPY0Du3+AZywF9D73SHvj34iOvKtWzk2md0BGO3DyfwqwMuxyGc0/mnySdqKx6CP4z3gdwH4wkGPARr7p2qL8Gn0nRYjeQ9aCULWsmCVlzaDOYzuVZz5N8b8mM5TV595I8njb4XpXrqVdKyVi14S/JTbCULWlm84C907Xp979DbtQAAAABJRU5ErkJggg==",
        ["star"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB2UlEQVR4nO2Y0XHCMAyGlR7vpRMQJmg6Qc0E7QiMACMwQVeADcoE0AlaJiCdoHQC+usqrhRsx7INl4d8dz4H25F/ZEV20qOW06OW0wlMpROYyg1lYr/fVyhbKRVloqBMQNQKlZGf66IoRpSBLALFY+8nzQ8Q+UGJ5FriSWCbmmQPwnt9VF+Wrh3KEF7cUQI5PDh2tPc9fcHk8OAWVenoruHBISWQ5EGIeya3OKaUMdEEeRCTlKgGh0npTxRP3pTz+El+Pbo+xOQmJD4Lj6gXyvQkNsAi5xA7tXVaBUKcQbWi62LNm64Y5IHfdD14rtrWYRUosWHoOiJ5DuOKR+dTLO4uUTZ0Odh25dsSvWnmyJNvlB+2yZ6rfYMa8yCLRDG4XFA+FmwzJM0EJ2oYG6OaUjozsRU2LylBCuKk+0RxLCFOtbPEHPnvKZ6BcrzOg56jlYY7zRFMe1gwlI7RDG69QG0MNp1cDjvPbYKNf2g9+OjpW8rklVzH2DgjWKCccGx8oow4ffCuIIVTyUj6NLbiBdJ57PByctItUdang6WNvTkLsOUkOM3IqZo3dY4vXsJJ0z56cu+cfpeX/1gVem/MTlLFvpDLC36tyYPZPn1ciu7zWyqdwFRaL/AH0duIDzY4li8AAAAASUVORK5CYII=",
        ["skull"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAADMElEQVR4nM1Y63HbMAyGe/kfdYIyE8SeoMoEcSaoO0HdCeoNKk9geYI6E0SeoPYEVSeoM4EL2NAdDYIvWZfLd4ejCILgxzeoG3jnuIF3jkEJHo/HgtLRaHSAgTCCnmAyX1BKlIJTGw3KgdN1X9LZBJGYweQHypSJpYDI1ShLJNpCBrIIIrmfmMzhOlRI8nuqcRJBns4XlDEMgwblKWXaowQTyK1RWpQdnKeSULC9gfM61UD2DzGSo57kXlEqOE/XIcHHnOUWMknGCNbgjsBflCk63UEG0Bd1slFI0g6fQS5BdvhbqPcoZd8jg0ezQbkXRRNfh0MEaWpLob7LPSYUvwaTP0LdoN8Hzf6Dx8kMXHLLa8kR2MdSqEtu04FKEFxytCkWMBwW7DPU5gk+gp9Fvh70fj37qiNtnuAQ5DVihLqB4dGIvOmCDRvaCJZSgT3edN/UAZQVbSKWFXfqAordtwhBtW0t3DIiv7UbBXcHEqZYNuk2kcfutBHQZkIZmmbMk297aulo29iVtBEMHcALj74QZT67MZIKBRtO2xrB0GYw1vcWrNEVZdJub+Wn4IfTdkpE/cmjv4U0kN3RU3YPEaSMoOFrj9Ba+jFcBhGt51u1Y59FpG39qsPKtBbs3p0udF78VCZHjw7dsdgkQTslENmj3gnpfAd1LfKPdEYxAXJCMWC3Btc2OULMjs+7x0ibZ1+akh38E2rvhW7V6UYk+EjyBCIftTrqCLLhs1DTOVaBH9RoxfICfnKVQu7Z16FQuGVAX0dP9s3CtjNMVsLuK9rVwo6OmF/C7mL9JhMMONx1t4FlR4GtXOAt2t0l2DkdtuHbJCdwRTn0r4rpWNEZRSfrHkLkCEGC2OMS3LNKW4fLRF0t8gW34UWffzNOSISjMOez07CqleuvL1LexTTF2nORgtglJIBDrRkoz1f0UYTqBqeYUSs6aqiKTQ+TI5sK9HVaxeqnEFzAZTRio4Q4fDbkM0ow598M7Tb5bmgg/hwowSVJV990kH8zNpBoA57HTQa2SKxMNU6ZYhstXI9NjnHuCBrQr79UqCFVCH3/sC5AvylC2CC56KaQ6P2P+q3wH/rMb9XrhmAmAAAAAElFTkSuQmCC",
        ["gauge"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACWElEQVR4nO2Y7VECMRCG9xj/qx1cB9KBZwVgBaYDsQK1AulArECsQKxAqYCjA6gA3+VyM3u5JCQXYPjBO7OTIyG5J7ubD7igE9cFnbjOgKk6A6ZqL4CbzeYKxY1RvcyyrKREZdRBGmgAG8IK2JXjqyvYDDaFfQF4RYcE1GCPsJEHyiWGuwPkX0yn4BADjr31Bsupm3hCPMb+AQH3jkJZmpawsX7pqvaO9nSfqvAzVJ2fU4rUzhA74L5gL6Hhwhj59mXGouGJ7MrLHsXBrWH3GHQYk0sMJuEYDBaULj0P3MiA43DmeFF0mIxxCxS/sHXIJDPHIDmKhahizxWxK9AYk/PymaodYI6x+iH9XIvkzficCleg4HTJdZUK7duzDMYzG4qq165wIte+BVxjPLSrTaVFvZi8gFSFoBaHdkzd4Aqqck2Ox6F9Mb6qdJkb33UCDsTzJPZ4cnjNhJEqxfMt+QD1rOURNqE4uILaXqvlShW5K/TNMJselI3riI3Y5zWWLbRbWbatggIBYxYGr9CRp12RXz9kZ0i/D1pWvanXlC3KBCwoXr5rlzO0oTJDXFK8Sk+bong1JpwMqC8BT5amp4jQXpKDwQyxHLC1J7kEkDFykfvWuThF3Sykr7g72hialwXLJeE+9fayS/qm/imqruXh0AixDtdcVCk6vJR4npsnl+2om4jngT4dDiK9RcmjtXXuZ5ZOnBMlNRP3GOKTq7VltTyoXdzpBpMo6zudP5rgyQmKBzqOPuAYZWvw/qrTqzqnw2rl2y87/fVxTJ3/fkvVGTBVJw/4D7296lpNRhmNAAAAAElFTkSuQmCC",
        ["wrench"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACDklEQVR4nM2Yj3WCMBCHD58DdIPGCaoT1BF0guIG7QS1G9QJpBvYDewGdgJwg3YC+zsJNCAlCVyw33t5eUIgH5c/HozpnzN2bXg6nW5Q3RmHjlEUZRSYqO2klnpAeURRDU0ylARlA9kvCsCo7aTudEbNcqSPr1FSPMwzBSByaYTOE8ojaYPbPUlG00mQ8ZDcQXBJQoxcG6LTGNWbQ9MFHmZNQjhHsMAxkue5K7HKR0bHryix7QLHSPLqj0mAMoKQSylflStIJLYL0f5A1X2xTob7TKgnI92Zot+tZOsSSb7Mcl7p+/aiGGJVO94qiXNbVFOyo6gnbau4UVLLxTQQtm2mIjm0HBPpjhWqtKXdQdcuw2oy6bvVmKs4Q3VLcnC2o6gn5hDvSJaUBDAjqKRuapAgiivqQRlBPVdeSJZYL6zOXPwX44Z7VPckS+dINm0zC5R3kqVzJC8EOdlEYUke7m+So5OkyzvJmvKoNm1BR137bE9ew+2TUSuq/rdytpLph9hTe2ZTx1nSO2FtIqSkc8rfhn5JmqN8elzmNCdFBJlQkmKCTAhJUUFGWlJckJGUFFnFf9FxdS/xgGVmFVSQ6SB5gOCs+BFckPGVhGDpFWQONnTYZU6eGUSQ8ZCsZFKDDLGJZbg5e5qaL1qDRbDAiOSmduqDj9ffAgePYB1EdE75ym386Hl1QRvOX/mvxQ+3BNohn7iytgAAAABJRU5ErkJggg==",
        ["bell"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABY0lEQVR4nO2YgY3CMAxFf08McGzQm+B6G+Q2uNugK3QCYAIYgQ1ggzICG9ANYINiwEgIUWrXrlRQnmRVtCE8OQl1MsLAGWHgREErH3CirutAUXIEOJHAARJK6bK7u/2VJEkFI14ZzIX31HjNwU/hPTWmIaahneCSqbShSUWxpKGeoSOdBEkso8sKzWL3VBT/JLqFErUgy5XQD+GB4lcrqRIkuZPUabV2nV8VxQ9JHqRf0K7iKWyTP+U+xIgzyNnbw4exNIuaDObwI5c21AgG+BGkDTV/1N/wQ9yXZg7WcITmoOi3Yz1oJQpaiYJWoqAV0auOCwVXpH22CnJHJfwpJZJPBW/kMvhzrszbJNsymKMfuSsZWkqvl1/FS1xK/IB+2FBRs3jWwOXoo0/MQ8zb0HnD46LLXvgWcwYbDo6ujDVbzEeYD4/4BKt48Kiwyp37hxN8JvjHH9ckt4ED779I+mbwgkd0cGLR5PM1UwAAAABJRU5ErkJggg==",
        ["lock"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABq0lEQVR4nO2Y0VHDMAyGFa7vlA3SDWCChAnoCkwA2YANChuwQckEaSYAJmg2ACYIEiiHG+IktpRcHvzd6eyodu8/WZYTr2DhrECJuq4vsTnnx68oit5AgQgEoKg1Nndo92jr1s8V2jPaE4r9BE+8BXLEig5hbUjctW9EvQSyuFdw48pH5Bk4wstatNw5/EbpB+qzz6TgudMKhP/5douatmiHxkF98mE3M8atea4TzkuMUfiAP4E5C+kbf8Am4ccKx2/AAacIcu6Z0XscMe3B6Mf8H6NxXeKTHDKX1UbHGKc8VCvUUxEEShkUiEmdYnOD1t4g9FsB7uxwHp0uVLTzoTyOBsRR3drBtGQo0loNrAJRXIzNEebhwvZC0VdmYpgPa20Mu1hKEChFW2DJbQJK+LwPdvGOtsFSkZJRn31itATSC2vVPHB/CwpoCCxNcQ3sK0HI4jeJRgQTPhZPYJ94s2jl4N4Uyf09KKC1xHSWHvkDiUhBCe0cTEGZcNRJCQKl9AmsYD6st17WOshHVQbTk/VdcA5eHvFnJx38TncqI6CovYg+O5dA2MVSvgHw8nfpPNSjVwAAAABJRU5ErkJggg==",
        ["search"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACM0lEQVR4nO2Y7VHCQBCGN47/pQOvA+nAUIF0YKwArEA6ECogVKBUYKxArIDYAVYQd8lmWDK55G5DMD94Z3Zycx+5h9u9uw3X0HNdQ891AWyr3gNe+XTOssygTdDe0LbZQVReoj3CiRW4dMKJB/iYoM0cuu/QpkEQrOAEagREuCE+lmhD8FOM9oygO2ihWkCG+0AblJrWaBu0lNsM2hjtttQvQcARdAHIbiW4YQmM3JdaxhBkjHYjqhfYfwodAM4hj7tCK5woggbxD0vQ7kT1CMcmoFBQM8kWDq5d4wRjcBTtdshDoFhJtattx0wEx3Hn5SIOgbmoChnaWzbAUJTXtphr0Lzmnc6yAcr42YBCfLx8iyoDCtmuOiPKKkCWPAMHoJDLXWzgNFIB2lz8I8oG9JIHdwoK2QClWx9AIb6FjKhKQCEb4LsoG74hfCWPpl/tQV0JiC+L6aWiasmHt5Owb4QPmXrFoFRdPihXYH8vuxy2DPcqquiHzkApKyCvoszpKKa+EOClajUp5ihphTw1k+1Rm5SrKd2iiSge7yuaaSMVExuw7/YiLXvSgLpm1OXMpknk1ghy1xa3EoGOfCGdvkk4n6Ns5BOawRZoBsfQyqeibZ/8+my2/dzgKd4oIU9IVrh6w1Cyb1Vu6LWS3oC+agvp9dmpEUOEcJzZOLu7c0BSG8izAJK0kGcDJNVAhrYxZwUkWSCtSXHnu9gmdusY8i++1Nbv3wBddfl/sK0ugG3Ve8A/XTrc2FB3eyMAAAAASUVORK5CYII=",
        ["flame"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACOklEQVR4nO1Y7XHCMAxVewxAN8gGZYOGCWCDhgkoE8AIMEFhgtIJgA1ggsIEhQnSZ6pwic8fcuLc8YN3pwuxZPkhWY6SDt05OnTneBBsimeKgDzPE8gA0qXIaEwQpKa4/EDWkC+KjCeqCY7WJ2RYcQhQRNTagyql9B+tHrWMYIIgp0htINH3mwlBe5Aj5yTHNtEgJsh7TqXVF7nMMn8MeadAhKRYFYRkz01B5Be1smBilWLCfYrLBPqzwJesiuE040VCcYQkhvElCI5IAC9BjoA652IXxQIkP3xGkj2onLRRsWNOtxPOCLYYvQJbRLHvMvBFUG3sNs+71BdFCcEQrFhCkLmUvhTnJMcI6VryvIzkVX/GvBeb0hrBwCfCjZwC/xYdI0DXtZYrxQnJUCFXIJBkYlM07Qcr5FQjwc3EFYEkjWjS8vdBYFvclLoc9Vvp9sQkeSvXeRLVjuDIQq7LsjFEcuLwZ30u16niHRZMLeT0RW+RZNstLm+a3QU21rPWF8GDYWxWWrDoVEwLXHXai9TMYLclB3wE59r9pZxaXtDVgvWoRIrnXjSbNTUguNYc7jX9gPzQbco+TtSEIDeVM4dJQn64bGa+xtVbxXCg0ryzqE/kx8Ey/m064HVIj5khk3nVxpeCuXoKlQ9FOiMBRAQ5DSnkhKosdzhzskeIWHcrNJ6r/mgqfScRH9RweGSSPQNxU4u1MhDp4r4nJXddgyKBz7uC/D6EhAtRv6O0gccHzKZ4EGyKuyf4B8e71RBt5IsJAAAAAElFTkSuQmCC",
        ["snowflake"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACRElEQVR4nO2Y7XHCMAyGlRz/YQQ2gA0aRugETScoG+BOUDpBwwTtBoQNGIERYAIqFftwjL/kuG1+8N754jS29FROZJkRDFwjGLgGD1hCJp3P5wm2N9kmkEk5Iyiwvch+gW0JGcSOIEbnCVtleTR39NW8iuYCUyxAdCDw0mDbYv+DMY/GbmmutBEtbgT1yNQxkHJM7bARFBdQYDtp915IC9xJ2ogW6yMpimIv378W2xiukBAJV5EN4PiEBKHzuQEZUhIcqfRArLB9SpiOpKMKusvNhiPb0sfKNblwwNV4Ue/WEdvC5QD8kfTCweXLVkn9Ecd9meNcETxofTKwTYgkB450tNiwA6LRFi+bHpBcuI30GQcoHddMSB1mz4SrwSFvHuRAhpQCFwTMBZkK9+PfMEQG6JO3Oa+Me3qp9WWcawC+Z0ot3IrmvCL40QW4hmvJ9F96R8CluhliRd1JNyagkFfbEj8Y95RKzGUcRzxT2sGtWmxr/Q9Re3HMxo9jWrj+Ezt8VmnPbDtOg2OeIaDgV5yjKnEk86h6svxtuL6QZQ44uYQz7U8zxrbohXRVMxVcEmssnJmESdwqaGHbj10RnPaEA+AXGDYb7q9Ynr7IuEiA0xWKpIBLcSGAA+gTAy4IGVLKwd268UM38e4gUxXEPbhHVyW5SrWUc3EQTskBKYAhLqD+DsXVc7eQrPeQe3AXuEQH7B5cZwjHPErGDXan2G+AIXa55XFAkVHFQmuZ10KCcv8+SKKUsoZMSsqDf6n7j+h99Q0A3W3gZBxT3QAAAABJRU5ErkJggg==",
        ["bot"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB3UlEQVR4nO2Yj1HCMBTGv3oOABt0A+sEhgkYAUbQCcQJxA1wBCYoTiBMIEwAG+B7NZUUSJrk0cqd/d29Sy/Nn++SvLzX3uLKucWV8z8E7vf7HhUjskxXLcnekyTZQUgCISSOReVkvaNXLG5AIpcQIBJI4lIqPnEqroRF3pPINSK5gYwJ7OKg300gQLqCW7gFMjtawT4iqXUSEqGoGOLgACZ14oo2NEZ+pp7P5pzEL1ydkxpxj1S8olmeSOTU9tIqUDvAF9qhb7uSXE6Soj0y24su1Em5eoGVM8gxleyZjJ0jR3vkPKeeu3J1JaY4LSrzHPRDlw8XalfC9+Og9GpzBacB4ngAxcbPF2hnkmktBcUKBt55nEaNzQrqP8NPuhXTzkZxN5YrmMKf3YXrbBS7GZPNDM2DrJ+HgnZOEqPzNqDfGodzwvE6FbY7R7HFphfP4H8+mub3/B5fMwuyO/wtKzJ1cs3oCkX2QrZB+2z03MrMbFzploI9mqyOB3LhsTsDW+Ia+00yDfmk1G1niCBWoEI4vqGuQmw2M6Jt4+3yXUXeYt8wWkGSbkVNGEqXsEpxCQwJ7FKsc1m9WP/0maN55q4fTHXXzJjsDc1Elo0ee+xqJP791jSdF0vpBEr5BitApEHVmA2+AAAAAElFTkSuQmCC",
        ["ghost"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACkElEQVR4nO2Y0XHbMAyGoV7eqw2iTlB3gjITxBtEmaDqBKknqDdwNEHSCeJuIE9QZ4NqAheowDsaBiWQ8uXy4P8ORwsEyU80RYG6gneuK5ihw+FQYXGLRuVCVHdoe7RfRVHsIVMFZAjB7rD4AQOYRQS7RtAWEpUEiGBLLH6CHUxqj/YdQZ+tDT5YAxHuAYsnyIcDbvvEfZlkmkHscINFPRKyg2F2ugCE1uTnkTaPOJP3MBdwBK6HYR3SQH8jbUtuS3EfIQOymIBrYFhzUrTYmxgY6KBrtDulmtbkGlIBeQv5o1TdY4ePkKGRG/4U24rGHpKN4lvlwpF4plbGsYY2mhPv1GHxIty04S7hDML+aZu5Fe4b7H8rY2MzWCu+Bs6nxjhmFPCruG7nvK6kuK92Ysz/OgHE6af9qxJu886fINlnxWMfSUsWSumQrybeNvyW0U7sg7G4rWVsDXAB06JXnuPfNdqX1DiCxRvQxt6GDm0NyrvYhRe8P7qwU/ZBRtxuYmxTsnD09/EC7wNXrz1AxrjJN5E5mxFyaL/Z3BniosrKqHEmOsuA1rgxzUr530IXwLm6AM7VBXCuLoBzlXJwp3ztgY8DWn2J9o2tjMQ47qMCo0wzyIkknVFKvj46zzIQ1ftUrUbfTZj/ifN1Q/VgkGUGr0O4AGATgQP+/eJnUjn8+zbXMCHLDFYRf80J5wL0JNdDdqAfiEpQ8r8cwDHVE/UxeLNS88HeUG+JMSsFkNLzCk6Pi+HAji0G0XIfOzDKCkgdOnoq0Wo4hey5vguSVAlJp7qan2wHRkgNcBuD8w6GXDHEq4cL6j3kK8esuI2vj0F24jr6babBYgnDR0nzZ7ZUBZ/lKrRn7TNc1kf0t9Q/g8sRu4EGCmsAAAAASUVORK5CYII=",
        ["gamepad"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB9ElEQVR4nO2Y0U3DMBCGL1XfKRtkg4YJCBPACGEC6ATtBnQD2glaJiBs0E4AnYAyQfhPMVJwzva1idI85JcsV/b5/OXqs52MqecaU881ADbVANhUA2BTqQCLopigukeJUVJqphzlC+UtiqJjyDgKGQDuAdUryoTaFcM9AnLrMxr5OgGXodpQ+3BkfG7MHE45I4iBKap36kY3iORO6vBFcE7daeHq8EWwILdmKPzEoQj/VCbn+spliAiKLGMHXEp+7eAv9z9DCQW7pfHJ1YvLkOdkn6QBpHI7aVuTc/pPAfyo/D4KbQnV/8K5WSo8+RP5xeO3WsDEbkD4U18bOHJUt5YJgy1Jp1hqdAHWwg2AakLMeFuw2qYU1prKk+RZsI+lAWLmFOHVf2eSJJglFe0xJjH+Y1SfVv8R/df2oC4vC6GH0SWJYothTU+MHivBED7Tef/MJANpq5EiqDl3tQvfVhbor80tHXUJXU61uaUIxnQ5xXZD7wFr2wwW6jfp1iFfBHakk3TKSKptNRKgJjsZLnXd4QSfDJiTAtK+1UhJsqcW4cykbJuasT4d7AYJcNkm3J+UkAu7YSQ4WlF5Zto6nAtX8e2DXJu5/48hh8yJwiWmMhlWmtdEjcxrbGb8s+9cuqx6Afui4dNHUw2ATTUANlXvAX8Bo1qeTaQi0oIAAAAASUVORK5CYII=",
        ["brain"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACNUlEQVR4nO2Y7XWCMBSGLz0dwE5Q3IANxAlqJyhOYDcoG2gn0E6gTlDdQDegE1QnoO+tUXNiQhJCrT94zrkHIZfwcj8CeE83zj3dOK3AUG5e4B01QFmWCWwM+4R9l2d4fwp7oppEFAAunGLzBksd3AtYHkXRB3lQWyDEsbCc/FnAhhC6c3GuJZDThk1G9dnA+i4ivWsQ4nIKE8cksLmLo5dAbgY61JyRSAK7VfWWipttTiAYW8a3yn5h8R9BZKfKwVmgiF6qGRrC+rB32EAZm4jj7NOF7ZVxFvdKFTg3CQTyxUbK4TUymZIjIqVqiRSYo2s6xyfFiebYhC5FDGBzXobU9EFIrpkjrkqzj8BHzbGxSP1JHB26k7c5bCqNdVi4Ye6EQgSKC8eaIT4mRzFTxuWaTOmyRq1YBUJcTFIkNMyk3xtl7EsZ25MnLhHktJhqhB9ZM2mfo7mks7hTxOBX0CHiuqfHrpZA0blJhUsq7/CjCzYQ63QMUyPKc6k3u9f42QWK4h9RNS/HJsG2Z5pH6lJdqSyoAuM6KCad0fmOewbXQmxj2JIjKM2RSaI4Srps8EvDinwFqvDbp4Mbp/hBOke3uMtYF/qmBTIr6beu5o5wRyeieYz8hUBXniFuYXNq5JvEE46ckzjm2l91a1hmS6uMTwS3FMZvQ/iIY3wETugfcBYoHmn84hkaSS9Cv4t9Otvr5fZI+99MKNcUWFANQhfqoaMfvxvWWgWCmuQatDUYSiswlB+dk9tKqmoWqQAAAABJRU5ErkJggg==",
        ["map"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABdElEQVR4nO2YgW2DMBBFz1UGyAZlg3aDuhOUDcoI3aTtBnQDmKB0g3SCphuQCci3OBTLCdjhsIQiP+kLCV2OFycSPm9o5Wxo5SRBKbcn2HVdhssLkvOtCqmVUnuKgAopsqQK5HGkbIeUyBdkW08/jcsrkiGm9hOfaegaQTTZcpNiQmqMik4r23K/jPov+cZiLs+XJNWInBH6RrY0Tc0P9cmaPtpT9wNBHSpYBTyY0FDxSpv/Y4E8kQDT7+zepUI8tKMZDflnHGQf6EqiCzo9MupFTe5pZr9ogkv1S28SKUlQShKUkgSlJEEpSVBKEpSyesE7EoBt3h/yzpvTKIg2rA7D2Hk2I0s2rEsK2jR0km0D+5na3L05JmhWwzf01HwNGTtzT80B0RDcUaCgpn4udvlHPpDSGsiHsTMPkHX5pX6ly7HTiKmpTFN/CmAE9tykoQlYtqDpsXOQqkLOc4KmsjlYM7J9yBQkZRNNcCnSm0RKEpRyBNDskPpwhwuvAAAAAElFTkSuQmCC",
        ["cog"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACVElEQVR4nO2Y7VHDMAyG33D8ByYg3aBMQJgANiBMQJmAMAF0gnYD2gloJ2g7QdMNYIIiEfWucWXHTvp1PZ47Xe4ix1ZkW5J9jiPnHEfOaRu4XC4v6fFK0rY0mZK8RVH0jZpEaAAZOKDHfUWzIRn4gJo0neLrLbWx0tSDS5925MHa45yhJrL+tt7W5Kyi45Tki6RHYm6EkHX1YPTblj6579T1YeQwjg2aGK9HJH0ZMHThD0RSksTQ3dAqmCLQwC+lo10xIgPvNIU6xWQceyfB/khkzA02PCgLmqc2xn7JyYst86XmwQ72bxwTk3My82XJg+K9OUloWBij2Dz5ajAUm+EWYXBKbK2nRtNAbedW8UQd9jWFrCvWXcCf0o4uTbEouvDnxWac9LcKK750zXCjhhnPP19QZzE88CgqfkhS+aESapiRhjzdM9j5gD99h47HaGvGMdZURx/kKCK/jSn8yR26gYylcvQVtdWDtG5iuNdNG/7EDt29jKXiSnWTCiOe4c+jQ/cX2mypbsNAavhOj09UB2uO/J2KNqufrap8eKxPGbvENgJ1hxZ512FcD2GZqbW+abRUx8qQyM+MoKe6BGFwPIytqQ6FkRmKo+Qh4CNqtv7CVm5xjGt0GquBmpk2Nom4t3Lx7wB1TFfJP0J4uVSXMTkm0RSuU532R1z3PZEMEc5Qvh0rutT2kfNALUdClpzkY70UEl0PfpRqRglnq8q97yzZUBNJT3PP5ld1L5BO9+pDWHi0maEBTQ2cbqmNlaZTzEE9g/sCMzvYBeY++L9Eb8ov04vnmGZXJSUAAAAASUVORK5CYII=",
        ["rocket"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAC00lEQVR4nO2Y0XHbMAyGoZzfmw2qTlBngrATVN1AnqDdoMoEcSeoO4GcCSxP0GSCKhMkmcDFb4EuS5MURcm+POS/wykmIfIzSIJwZvTKNaNXrjfAsTo74G63u+aHEjP1zLbIsuzZbDwLIEPl/PjKVrJdBlxfxOegkwIyGGBu7UkDyu2GkwEyXMGPnxSOWK8uaGIhamwAq2kkHDRpBGVJN2xzmkjREeTJFduG7UmetwKk+wH1ZyRcYzdERZAnL6nbT1qK7UGnBIFD5FxLupXnNSUAZn1vOOBI4ObSD6jfdHwCH9gK9mvFD/1rto+eqR7Z1x4jvMQeOOSqwoDbOODIhIPk74L8WrkaLwbCQZUxcUXuPbc14SzIrcP/xQc4GwiHpV2Kj6LudphCS9cXgjIHXE7daXTpEw/UiB98cvLrgz2pZ2xEL7fvYC3XEufk1taAKykMB9UCZMLVDr/CBwe5IoiNv2L7bHXtoyf9iELsLdHIUzn6fvCY3yggb5qRb1xRd/LueSAl7Wj7TuN1SFVJgFoSsUsjn/XtvSg4NhVaWooFtMWALT/eU7qCh8JWSjVTyCQpio6c1uAIQnL3NmzvBrw2GA5Kqgd5knvqTmVsJG9wIIziIrpO7LuLdYmlVUulHAuJqF2xb2WMiRuqorGAkk429H/+AlwtfSHIR+p+oc3FZ5+22FD1lDSgZsw8cErgQvrCk6/FX+9JLCGKiZU1HvImEvJhadknav/7CtZgdheV1NV3OpJH+0q+KJY0t7ruKFK+q+6JIuSLgoAhasrz6qHo6JMrggUlSpYav4NVwG0RCwe5ABXFybVMLdtV4J2FvT/75DrFMT9uoKXdIHlu7fEfDLcf0/wwYP/dmLnNGiOn46I0CQ6yI9iXn36RlXhtSdVzNwXcfjzzg0SwpX93LBJuI7aOvUdlHEVdHdnSCPnSzFwGH3Sxn0JJ1cw59fYv4LH6C0Y4RyJu4KXxAAAAAElFTkSuQmCC",
        ["swirl"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAADKElEQVR4nO1Y63EaMRDe8/h/7AoiKjCpwOrA1wGkgpAO0gF2B1ABuAKOCsJVwFFBcAVkN1o5e4sex2MIk/E3s3PiJO190j604hauHLdw5bh6gjddBu12u28oY5Q7uDCyO4ikhvh45p89lBIuiC4mloSubwcRD6K9Cg1g0z8kdNRFUWzhCCQJ4ocNPox4Vam+Abgd7kMGOJ4ejZIKZYPkm9i8AtJKLT4W4tU9P8coQzgfGnBkKyQ7lR05E1vRfgO3m0T43L5owC14iJtyjyR9UGbTjBFtstFP2CdHK/6K8qVgUJvfvUb0vrHkvpk1cYWPx0g3fXyU8h/WYcClqSfVRYtowFmJhPx4q3XmCK5BrYjxXZqhC1DXCJzvehCZXi66cwR30IEcDqPV0077aKZ0tMRxqwzJFxwzgmMIcm77pV6/osJSjUlF9ATcgrZizhza5u6l3CQVJKHcNlLkFpBON9S3UGf4KDAGjiGoMVUrJTPrRSxZJPrw9ywH1iGjWwfP0QQr32CfG4i+GpypLAm4oqIW/QOOZo+5aPfPRVA6vFV9ZSs1uLauesqILn9iwUkEVUTKVS9DTs7vpLlNRFcS/0dFTWC/85A78Kj8y4+nd/IUaiK6jiaozSCVVqpvJklye6bGdA4MiShBTq4yEkvRR+Sn6oNrJEY5j3LjGtokdIoq4VSCDLnqJ2VKSri1Gm9hP8JraCd4A5ncdwjBifr9fo7yDlto76QG9VlVEIz1IOyvYgqSxQIBVzyBdlIOFQsG2qU/ucBcp59AseAJFqcQpHO0QfkkXlPN9gIHgO7WII48gQ3qMrF5N0qJQZmxs9NFnXyFCFo175nHGcgT+6MzQo7QpOYXStkE2ub08D50F+ibs9T+hOA8R9fQEsIRS+W+twhF+BAi0CfJKkIwRMzjnUS4vt0jZqF9U2xSE1omZuenyw5F3wbOC/JZA84acsFValKu5Des1PLTy2foBsqBZP6Jj2jUSbstT5lkRZ0sFngiSRXqT5VJidxmRXuTuxWeVM2kEmwCqTN9D/+i3JKnSpUbnE3U5wYn/h8oTZe79cUJHoqPP9FPxW+r/Eb9R3QXOAAAAABJRU5ErkJggg==",
        ["globe"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAC1ElEQVR4nO1Y0XHbMAx99uU/3qDqBPEGoSdoOoHlCepOUHeCeoM4EzidIMoEdieou4E9gQtE0BWiSYqk7Fyul3eHI0WBxBMFQISu8MZxhTeO/5/g8Xi8pcbIZSHtTtpqMBg8owcGyACRmlJzh5rYqEN9T1KRPBLZByQiiSARM9T8IBkjDxXJdyJaxU6IIkjEeJeYWInzYEXylYjuuxQ7CRK5gpo18neN8YfkgzW2JZl0kRwiTI53btOTHIhEQc2M5KCGec3fYiOdoEx8QncQdOEnapIr1FH+S917sREiGdrBPsHQgHds0Vzw6yThNXU0j8WWE04flGh9Qhp4Zxp/4pZ9bOnzMbLB92/U0MQV3T6COX43SUkf8lp3JNcyxEl9YusNHRNL9H+1nZCdXaghI7ZbcPngHV4JRHKJOgU1MLaOi+At8tCZdD1Yqf4n+2bLBxOCww6IFe3GIzJANtmdNmqo5cv2acaoPqeIOck9TjFPCYgQaJ0tkWRbTbAw4aq5H8qDW0muM1weW9VvJW2bYGFd4xVJOjkMY2Y4SPLnKRYl0rAPEdwhnmQs7hP1gwQ1buyBC75ubStIsFL9kaSAFs5NUmzowNh6CUrq0Gc2AwfOTFJ/uQ52+nK9Yq3wBR4IyXNgqvonyd5FUCsVGVF4Ai5NRcbWeIl2Wqnsub7jlj6rsdN+dJ3rHGe6GFQkn1H73Qb//O+ZbBhb2RfFc9XnBdYevSXSYWTeGu3gWLiUvVUd7c4Kbf/gA8HMoVeifqDUndR4oLVLJBLkp6ssw95SkfRZN+eoxicj4ysNvIlaJhi4S0VvdCfiECIXJMiQiQVOS8UlkWSi31zJPBK8ZtFVuKf8+mDHngbU2NAIceCycx7z6yP2NLMXJ+aqy/c7LYYcz2UfLmPIvdhGBiRyDerP1HWHOvsZJ/8q5+uTRVBD6pjmg1/I8A5SvPctDXoTvDTef6L3xV9GTCZ/TsXbRAAAAABJRU5ErkJggg==",
        ["leaf"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB+ElEQVR4nO2Y7VHCQBCG3zj+xw6MHUgFxgrECgwVSAfSAVAB0gEdCBUYKiB2oBXgrrnMRGXva8OEH3lmdi6wB/Nkj/sglzhzLnHm9IJaekEtJxM8HA53ji4fSZKUjj5IoMSIZBS3FKlpfSko7kn0U+oQJUhSGTVPFCOKK+goSHAoJYMESYyrM0NVsTa5kYb7Ap6QHIu9o305JpUSXpOE5JbU5OgApyDJzdGRHGMVJLmcmmd0iChIcjw7Z+gYWwWn0C8hao7OYlM9zdB+oSWkZWaEeLYUe4Qh7iSSYIZwuGqPFAOEbXegRbqQcpJgijB25jMPCJRzIQm6TiJNVqgqPkHcermzJb23OoEVDU+OqmoviKOwJSVBn1n4I2dm/BLxlLakJGi9K1TDMjHX3KaIZ21LSoIlZLi6Iz5ktrFe2mYwIwna7mraOLtx9TS7zdrVQTywUnV48Rz8eXtLcpnJs9heKTiMrSAzP/Je3rjWHve3LjnGeuSnKpXUXJuX9ZJS596gO10PfQRd62DeuJ7WFySXQie38JFjrIL0JRtqxqiGo2ykNNsZj8TEt7NzJ6Eve8X/002s4K+fiQ9eW92RP9YZwuC1cxwqx8TuxWlA3wX3NyMRTPSjD5ooPOwcqYl6tvOBtaTYUKxtjzV8UD+bOTX980EtvaCWb5ZAfzhWHlKuAAAAAElFTkSuQmCC",
        ["sprout"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACU0lEQVR4nO1Y7VEjMQxVbvhPOrilg6MClgouHcRXwUEFhApIBwkdQAUsFYRUQKgAqCA8sQoojkxW68Dkx74Zjb9k7YtkyZ4c0J7jgPYcHcFcdARz0RHMxS9yYrlc9iF3kEA/ADdBQQmZgOQFfTPcBHu93guaaxmOvJ6UCAwhRRP9th4cqz57sty2QYhN0H2GTCGBGqBHLYGPLdD8liH3j8W7lm5AcwXpy9QcUqb0Ndp6kHGj+gUlPCJem7QhR5kEH6Lxf7LJBTX1yuOm5Bg5dXARje/1AOTOaNOrY5B7IAdan0EhsVTDI3x8IfMFmhl9hpXxhPWCnNjVTXK/IicY0To5xphaYFcEPxKGywmaYbR+S3VpcSMnSRinVGdlpeaC6j+xDrw78CSGhnkGxQuPVIepgrBx9tJt/CHW1XMYs95fqr0WLH2qPVxC/lBdoljnyPoRySSBoQrNibE0hVxGZ07v4+SYYz1E8wUavruDsY3PcGnZS4ZYNpxTXbs0AmT2xR38apDjGjmjTXJs+zxF7p0HbQGMcxgqyKGxPIXxf5F+HPK4WGty5ba62KgOeknuihyjURaLoUFiOVjhTtwkKwya3iium0RlaAwO6bFOHOjys6pv6HIlSP3YDXjrYEjMM5FRNDd32jDhIhi9pmMMpcatMDV0rr0Fu81NcvPFmg5d5dxrYu0MSrbekX12mmDtfMEee+vQsZ/1T3UCxR48yyBHxl7X20/2Bz0RE6woDyeUj0oPNsqMhLm1FxGeKsPWS1wfs17UP4Huz6NcdARzsfcE3wBmmutmpDlXvgAAAABJRU5ErkJggg==",
        ["layers"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACeElEQVR4nO1Y7VHjQAx9Yfh/dHDu4Hwd+DoIFeB0kKvgQgUHFcSpAKggoYJABYQOoIKghxXwbLzfDsOPvBmNnaxWel7tSrJP8c1xim+OI8FcnGAgbLfbC5GlygUGwgiZEDJncrkRqYyhlcj5aDR6QQayCAq5Ui5LkTOLygYtyQckIjnEQq6Wyxp2ckRBHdVNQjRBhlRkLrfziGlzztHtEIWoEIuDAu1+K5EGhpoh34ROCF5BITdGG9JUctC5a7UVhCCCYvAf2pWLDlEP3k+92vTCGWJHChkKK3hSkXUFNYUwpBUOhwptyK3bxrqCMukJbZr4CjzIKv7uG3DV4uwqEwGrL9ch4Ul7xuFBH7Vt0EpQyxP3xj0Ohzv6cJVCZ5rh6RKp5PYSw+NSbI99zUTwPtPk2oj8QB5eRUhsFaKcUupuRX4hDY9oyW1CJ5x4CJXdAq+GK5EF4rGQ+WWXnDYeZRJBmXiFNlE/yX3VIcl9WcvtBGFgSCc6p2ufW4a5dq2+euFK1Fvjr6k4uTZ0+PQM+U+LGaaQsXlKtQ7PunqiU/QZcIX42vh9JYZvjJC7UtFeCtGQLg1yRAMLfM1Cjf3GlA4nPatC3XrnUMYbY5wPwsaj6PzN8E9N3WCCHcNmGJm7/roMGzZq7D9ob/hNePtBSxgZZrbw/+EmZns98FaQD/+IgDibycVsNOnkj1kRHK8HrCAzBCK6Y7FUFJI731UH1eGqdTvwqAqSTFAJFOivKI1ea+P/6AqyQ3LPp+mGCdb3mWNhJukYDPHpo0b/O7I3hYRgkK5ZU1GDz5DzxE9zPnnsMGhbr3sTKXvNhq9870jC8QtrLo4Ec/EGlwgYKQZtG6AAAAAASUVORK5CYII=",
        ["grid"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABhUlEQVR4nO2Y4U3DMBCFX1D/0xHCBu0EdAPaDdIJYAQ2gE4AG9BOAEyQMEHaDdIJwhkuUhTunLMsVUHyJ1l27frdUxzbp8wwcWaYOMlgLJM3eKUNtG1bUClbPzWVJypzYf6cx+oRDRej0HxkmjmqXmBnn2XZZqDxTtUKdjaksYfRYEnVAmEsKUDF893cMmw6Kpq/HHZq72CoOcdcaVsRY6ZdHEsyGEsyGIt2k5xxeU5Sp2bwFYHidMh+dD+4fUIYe6lTM/hI5QAbzsha6F/DbvLAMf+Q+WbxleW9FfpPTtFYwU/TXZGiPibO/z5meImvff+h5fkc0biFn3PwEnMC+gZbPnfEby5XDTQWrJEbNNwO3pJGA6PBZ6ruYedI4jcDjdpormNHGg/DTu2YuUMYeX+3cjtHGGJM7R3McXlyqTMlC7Ekg7Ekg7Fo5+AXwmmUthUxpi8fDOHQv+q4bc0nvTFFg/yNZIvxJ+kS0h2VQhgreGwsaXUxxO8yP14wcdIujiUZjOUbzPq5rgR8AucAAAAASUVORK5CYII=",
        ["crown"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACnElEQVR4nO2Y7VHcMBCG1wz/CRVEVBBTAb4KoANIBeEq4FJBnAruOuCoIE4FuXRgKgAqcN6NFpB10kq2GeaGuXdmR9bX6rG+7UPacR3SjuvjA3ZdZxCcwz7BjCS3sEfYXVEULU1QQSMFsBsEVw5UTBvYGqDfaYQGAwLsAsEPSoP5amFzgK6HVBoECDgGu45k//biZ5FyNSDnlKlsQMAtyQ6pD1XDGjT66JXnOVmRfSEfdoXyX+mtANHYAsGNk/TEsLnDJdNiBTtyknm461TdJCCcVwh+UR+ugvMNDRD8lAga6kPO4KehiYAMV9EEOA/yj5PEU2Om1TlIOKwcOFY9Fo4ldd3tppI2aBQg9RfFPdkFERXPVZmvmmrxFWpjS0WiwQeyJwTrJ3rgWinL5R4keuyvaq8sQ36TaIuyJ7GyB4oT48CxUiv2IvIckuvLyMsFpQ2x8eKtX4B7ohMhunSylt2rQtPC91XSCMCeIod+o9f6v+qbTF9BZQOGJBv1qYD44oVQhTZzbUh9ZQPGtgPZOlaBrLWyJUWH1FcUMLDDa07PA2lnSvky0daLUj145zxfKuUM2WGeiT2R/kKXkTZoKKA7f0pl1+ebieGekN4wkrYl8VFG2thSzlncIvgsUX4+1TbhhC9eHHwWG0m6hy+j1clZJAvn2cBuabxuqb+/LlIVcu+DPAzuQuDVOcvtSek5vhW5Q8sfVKkTJxvQPWefxXB16mNIPq74DPf3vuOcFxxy5e+UbO5h7tVW4oZsb0V7CHBZbb8V4GDlAu5/fUzVHnCq9oBTtfOAk27Ujv7C+IfQidhc0iZryEbNx9KRB7Uie3NuI3UM2dPkCvbFyUreYsYA8tHFZ+pGg1LqG7KwFWyR+4di9B/W99LOL5J/34H4Fqzbn6kAAAAASUVORK5CYII=",
        ["users"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAB+ElEQVR4nO2X8VHCMBTGXz3+FzeoE8gGlAnUCcQJhAmkEygb4AQeE1g2qBNYJ6BMgN9rE6/WtHltwOO8/O5yKU2+vI80SV8HdOIM6MTxBl3xBl3xBl3pZHC/31+jGqmSorwEQZBZNCGqu4omhWZNQgJJJwQZonpFiQzNCwSMG3SP3G5oSlBuocvpQAbfGsxp5gj2XNPMUD21aBJoJuRqEIFuqJy9NnIEu6jptqiGFt0EuqStwxnZiQR9hjD03U9d28yJxpZskpCOR2jrIJnBlGTkDddtZLYOkjUYovqwdNtgLUU1Hf+xK4vu0nZMWWdQDRC3dNmhzAz3p6qtidhmjpE8Yja5QDU3BHxHidCeGjR8L1J9qvAYczWmPTZ1pLJbc5OxBg2/RYpdbTtW6nQ2+Nf8u2RhXLu1kzxm9YjP9W9oNiRk0DIorxnOXiJVwoZ+XLHJhMr3a1OmstYmlSbTGm5rShwCQ8AQFWchU+oHB+LEYVkNqmYxocpM1liR4egJauYe1OCHIKMypUor4y+o/PNtzKBZUt2gUNwVnsGJNqmWzVagi/U5GXQU9uHHaxCxElRjge6Cl4h+k4zoeEjMmCg8+a86V7RBaf7Wh0/qR+GpMMi7DIv3Hpf8/SFJ1aVk9PvY4sAbi7GV3vk+WXDFG3TFG3TFG3TlCxeAq5+TynB6AAAAAElFTkSuQmCC",
        ["compass"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACwElEQVR4nO2Y7VHjMBCG33j4f5QgKiAdoFRwuQrwVXBcBWcqOHdwSQWBCmIquFABpgNSQdjFm8GWZWtlOzMMwzOz41jRx2t5tVr5DB+cM3xwPr/Aw+FwRRcrt0aupVyL2Wz2gBHMMAASdU2XJSph54HqL2QF2R2JXSOSKIEkzNLlL9kcwyjIbklooW2gEkjCeJZYWIppWJH9JqEvoYpBgSTO0GWD4bPWxY5sERLZK1Bm7glhPxsKi7voE5l0/SHitjidOEjfWxnLS9LTeMxi6OOe7LZ2P5exvHgFympNMS0cYvh1LtF+8FTGbOH1Qar8H9PM3h7Vis1JWCl9G1R+7cJBfeEWJh5x6QTiWBi/RkOD3hzFCVlHGytj9wtEtUMM5ZnspwjL3NUps3fd0966Bb69+ArxPKJ6jatAvZvA/9/dgoYPiqNuEccPEnYXqhQRUxf1rdB9xRZxPGrECTx7mpja8P8E48iPP2iG5mQbscYgMnu/oKPxEK4PGuh5dnwuw7sPsevUF9sS+h3J1G/GJKxZRN0/EXUbK98VWELH3rNiM99viW0GenoFasndAhLM6ZMvhsbMHtMQ6C6SAmF4l8gV9Xj2WLBBHLv6TUOgxJ99f3usQkkmn1nIOOZtEMfePQ74wkyBfvIOUec1YSvEzxzTiqmJplKNtbPxH4Wxn40RdqRwC7rSLfaDS89fF07axME3xTRZ9wP1bd3Crp3Et6nfszgWRvYP1Yxpty8Nma/QK1Ac1T1k73gbE2EppmXddVbuPNXJ/smNLnFaOFWzXZFBc+wsyb7hNHBIM4OOnYw0NKiecmq4TxOKqcF0SzqwaPvkGLgvq/n0ocoHuSOylH7yqWvM5zRuyxlzqhH3NjYGIBmKRZUchPyT/YyDf6E4s7QYJLCOnGM4g+YFZaS4RJWV7GI+tfkYLfDUfH1EH8sr/Sj18Q217OUAAAAASUVORK5CYII=",
        ["magnet"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAADMUlEQVR4nM2YTbLSQBDH/6HYS3kBcwPBvRoPoOLWjXgC8Aa8Ezw9gXmLV2+LegDAAyjvAJbhAoonwO6kg5PJfGWCpf+qLmA+f/R0TweG+M81xBl1PB7H9PKcLBVTtSHbkW2TJDkgUAl6iqBG9DInmxmgbFqRXRDozjewFyDBMdiSbIQ45WRvXB6NAhSvXaLyWl8VZC9s3uwMKHBrsrFj2BZVvNWeyVAd/z3L+INAbtAH0AO3J1vSJrljPs9bkL2CGfKJ7slgQA8cx9FbBIrWylAlyh2tqyCbqDE5QIAccL9QHU0wHEuOMiW71bq4rbGW14MeuCzkqvCsXaDtyUm97uBfwbHkKKeGruVpDOxwnHFfyO6iA5xSTTJpqqvHCva9cmiJQ+MTK6B47lsEnOvi5ti6MF3K8qW+as0c26uBBW5tgGNtHXDvBcJWVRZQjk6VrLnXmsuwGljgbJfwMwExwc3g15zGTi19BVyAgRWCNVMhHXAfyN4Z2jOYtdE+lyehPm7ZsvUz2VO0IU/v0dYVHVvZLuPmSp/PAQ0NZZEFHFeJKctgP9ITnMhWf3Wlpsb6iKc2OP4gG17BrwacHL++9gZhgIUKqOs7tKANgDTBzbQx/MVzfaLE/2M4APWrg497LRMba8GsmwA4Fj/tFIZ2U2aXF3siC9pqIoPzI9DBsemO+icBcHpsQpnDJ5YqTXsaW34uPSi3e4bqCFTVnrRteqPBXUfALdGOv7x+k2iDGWiDtifh25Tmcqka+8Zp+3G7fvGzk9K6JDaSRLI2Q9uTPrjrCDgef2noWjgfWAMgTdn60jL26IDjwjAyrJ03eGBbuVqEi3+d/gw8Ux+bAmtwTnNeB8Dd0rjWKQT9JqFFU/166PCAcIJ0waEqDIcoQF2W4GbVF7npV9tHskdd4PoA/oQ5fmbSn1sg0QWOFfSrToNLXXCswNrthYsCtJSq+3pZFMhP6AGHGEBlA1Wt2i0J8dAw90coHCs2Bm0Vp6zdqEqXKVsZ7gHB7RGo6L/fPJApOmYrzg3I6lC7o+BYsTFYKrB2R8OxegGyPJC94Mr1cSZJBi/x56lm1fVfL5POBvi39Bveg5lLAuPIgwAAAABJRU5ErkJggg==",
        ["footprints"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAADOklEQVR4nM1YwW4TMRB9qXqslHDjgNTtEQmJ/AHLFzR/0PAFpF/QzRfQfgHpFyQfgMT2yAE1EYgrmwM3pCYSBziFGTKLNuOx10m6VZ802p2x134ee8ZeH+KR4zCm0mq1SulxStIV04JkSnLdarUKNIgWwsSY0JgkCVR7QyRHaAgHvgIi16fHR4TJMd5L3UZgelA8d4t4FOTFEzQAnwfHHvsNyZBkruxJU150gkQ6SpR5RpKSlxZS55IeBUm7UidBA7A8eKH0JSrkGPI+UfW6qIEsnd0JUgM9uJ4YVMlVUCi9A5vUGcl3khWpt6s17kg4uBJsQ5DQV/pynxTCJOgxgjvojvTFxC+wBUHthRH8SJW+UOQGcAdsIZOBmNAEXyq9gB9tpU+V/hbx6MuAHNR5cGp9RI1xPb3gF5Vyay1fk7wmOcc6XWm8s9bkQaXRbSKsZ9iqUZ2qsjmt5T5JTnJJkgphjYGXIH1keiuS4EwdGvRgdUri/vpwPXkms+MS9CDx2F8pPUcYC489U3oZ3f+hCc6Uniq9XF/bRDvgyZE85UafvRDBXOnaU4xU6UtjeRRKD63vSaCslmBiRNZpRAeF0o/hh6674RR9WLAChcO/tD+Fuy4tgrqdfwP1nL4dGwdKub22jMJv9HiOeDzRe7VE4p2qd84pBm5/KdYH4ypOysFYUfwH8Sisg4TYnBSCSFQ9bRGcIR4/AmXOcUznuNKOACyChdJLb9zAzWcfgGiCDGsHSpW+4fm6RM3gXSKV7SnauzJN8wiCwaQfQ3AfaC9ukJH9X097XlViftzbnvcYjLB57OoQqS/0/Cn6M/2B7C4IEdQ5jBd3GYHdmrq6syl9+4tejyrmF4FPnPYsgoVhGyGyQQPsrSPE4bc2OGtQ9tUr1OMq8l7mM+LxSRt8QZIhHLEzuEclH74qvcD6538IO6VtwCTIOwFJF+4tAr8PuczzKxoDPl1nLHDTkINgFEsjWbkD7EFqZ0TdD94zsWPPu4mmEzUjVzofvcYscI9uum74AvM+IMujQH2S5zugRM9W4x6UDrOIquYd0ENMMeSgOgxUGfrugBqf4irkcMAnmlRMOckk9E/+oAR3wV9uaCeGF/zxowAAAABJRU5ErkJggg==",
        ["sword"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACD0lEQVR4nM2YvU4CQRSF76Ix2hC1tJHEB1ALY6zE1thayxsoT6A+AfgExtaKwtiKla30FthYGrQyJgbPkVlchmF2F2YGTnIy7M4d+LjztzvzMuOalxnXVAC73W4JxbqhqhVFUSd5I5LAAlwNxZkl5BKQF/FFUEDAXaOoZAhdiTNZkEDKAUdtxR+CjMGccAPynkEL3A18AFdt7b1m0AaHMVZRMdbv8AaYBU7pRCzyMouzwlni+rPYeQYdwF0lF2unGXQAp3e/uwz6gKOcAPqCoyYG9AlHTQToG44aGzAEHDUWYCg4qpACUobP1QNmcDgqssDxobKmLrlwcmM/DQmXBthEsZ+49Q0vSEA4ytbFbe06OBxly+Ayiia8OSLEOxw1MoNqwy7DL4bqH/hWPMP9caQFqEy+wUt6FXwEH/uCE8n4NKMgX+GiVsVMzhmaOIGjsi7UXG6Khvte4ahUwJxvZE7hqEiDYVfG7wh862LmKoZ2nzKcUa6TuwB8Fo+AD9KbudQ7vGpoQ3DuMqaJw5m/Dci2OFIhAVdKwMkoOHahWoLWZHgJYg9UxKH6gOpff1hiB8aXgtyBW1pcUxxK72KeiTzBi1ocu3sj0o7GVBtmrQ6X4AZi6uILUP3gIYo7Q13V9Y9n0dBWB4h76e0QX1pVR6Yg416sIPfkf0w+wg2ZgjLtxaaxF0rBj4DzauZP+X8B4icUfKgAlRsAAAAASUVORK5CYII=",
        ["sparkles"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACRUlEQVR4nN1Y0XHCMAxVev0vTFDYACYoTFA2IJ2gdAJgAugGZgLYoDABdALoBMAE9AmUKwTbiY2P5PrudDrbwnnIlmT7kUqORyo5HqhAHA6HSpZNYQRBrga1hR7Y7CIqCCCmoLqQXRRFVZNdIR6Upe1Ks4J2bLK9O0GQaUFNU90j9Hd19ndbYhDoQPUhDYvZDjLGkg+TjnsSnEG95jSvgiST9VtifKwBWYo0cv4shrBnfiw2E0g9Icfw8iBIfUG1pDnHhG1ygKSW/lnXAhJjnk3a1pmgeGyZ6m5i8hU5APNsoJ6l2cbv5zo7nyXu5ezLghL9bSLHcPKgZP+1YbiuWyLLXJwLFQt+NzPZuXqw5zl2BQ4ESMdG7mhHOSH/mL1nKvAceRcRGAKZHuRlhYzITo5kbM22shWCILIQ42h9p1P+8oGCfLpGdxpXBIUYe6xFYTCHfPgS1RHkHJe3OuTFCgSb5AHdkb9K4eFd83VBwqeOBYXDsYyRJ7KChHNbl/zAhX8cPEjSkJTBRGPIU4b5nk7RO3apKja4JuoNmUkyudrdE3UC+bCymKjQ5BiutXjsOXYFXhHIVK4CRjgRlH010QxNPPYc7+vknmL+Jjki4IF1S3+1PdyBVYic58mFB7k+XR48+qZnEN87CXtRSTPOQ1AIJIePmsFMQYbn2+V/Xjs9oSi7hHIuHd587bwF8vQxgLycdTOxHoiptH0hr1uay9ebjhyjDM9ve5AzXiWKfGEdiLZWoMI8yODUk1W/CyWYB6V/5f8F0Ifq/euDgPsAAAAASUVORK5CYII=",
        ["waypoints"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABm0lEQVR4nO2Xj02DQBTGPwwD1AnEDdhAuoEj4ASmE+gIOkHpBnWC4gStE5RuYCfA76U0UXIHx/0hJPJLXmjgAb/ewXtHjIkTY+L8D8G6rhfcPDMyxeGKsYmiqIQFERxp5PaMpCd1aSN5A3dS9MsJj7BgzGcwhQXzW+zKLOiKD0HTh7+EBU51kDVQ5PYGqSdGyjr4jYFYj2Ajt2vtXjEOivSDjZxgNYKa7rGixBs8M3gEGzkZueTX7k0IOSHuEEm4uVMcyvH3xfigXI5AKKeYctI314xF9+n4YmS2z5cJOsEjzBYAtyHlBJ1gDZOTCQIztzpXJi/otKJuamJQdIJnmHGk5EtIUZ1gATNE7BUBRbVlgjfLcfnQ0d30QbFPaqK0vPd2fezoTMKJ+RWGCPbBG2a4jF6vaPNn1x2Xk/wn5m7hS3CgaI7+zlRR8L6901sn6BE1QtWZfHy4Xy9eMjL+XDI+4Qlvgld8iwZv9s3U70xyVVMcXFBwWR15n2INZ9ucsQQL25xRpljo6ExSK7ec3UJ13miCtswLVld+AHRchUekLW3kAAAAAElFTkSuQmCC",
        ["bug"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAACCklEQVR4nO2Y7W3CMBCG31T8Lxs0GzRMQNiADcgIHaFMUDYo3YANAhPQbhA2gAnSO3EWSRQ7/ogrVPFIVlL7XL/4fOeDCe6cCe6ch8BQ/qfAuq4zfiZJ8h3DvskTHKHFlvQ4cqP3Dwv7z4b9Eo44CyTyxvubCOhFxgrNXCsSOCLu2lN7bnTvqLH7MvlbvTd37MICXd3sLNAg0oSXOCYkiutIti18g6SkNnWYxralT5A4uZgWSHGNSBdxTc7UZuTqynZCMiBohXYUptJCqKQptiT4S2esFSiBcMTfMNMF0N1fdUMuLnDNZXzm5gbTE9puY1JqLxp7Tju8Y3wm2cU7+AhsQmJrg7iMFjl37Kciolck2Vut7XPVdam64kQA91UIZAyBc9qtvNspfXMEMnQGOSHniMuednuhG9TuoOxAjvjkfR5QmFxc4RptsbnAcFaHXJzidnOUBlO+CbadvoLayjBHubUyXX1jpJkfWiDTzOE089o3ZptmxrhJas8xK4wCxcUq0XJe66tiMintd2IDsStwq7C7nGmOSkEnLxePUFrZYizBTFGcIr44yBqpblArkD7Rnh4HxOcga/XrgAOSUEuEsTAJ6uJ0F8s/XsOftYs4xrlYoAXe4SdyLXPd1oMn8g1tA31RquB6sXDdOYW3QIUILdCuujm4OH1sfIUpggXG5vEDZigPgaH8Av23voLBXVgfAAAAAElFTkSuQmCC",
        ["activity"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAABc0lEQVR4nO2X7U3DMBCGL1EH6AgdoSOEDboBzgawASN0g5YN2KAwQWECwgZ0gvCecKWrib8jnB9+pFNk5y59ZDvXdkULZ0ULpwrmUgVzqYK5VMFcWirMOI5rxHn85cm831BhWA6X7XXcAHm/6BZD7kBCDryZOcUEtZwSUx+InZlXZIshp3A5iKkLYoPd/TZz/30FLXLdlByTvIL89uFyj/jCw18Ca/i8nY3pO9S/2mqSVlDLnUgfcIyP+JCe/HInY7p3yTHRK2jKCaySuuYTsRbTj8jfk4eoRu2QY5R+M201Uu45RC5K0CJ3Ib+kWcNyigIJEnTIdYjeJjnRiLnXPVAE3jPoksNKvOscRbetgxkQG7qVs7aTJMEQOZGrJiRlzRY1A0XSziHHYO5If7db1gyUQDuHnEdy56rx0cwlZzyDv/QVYu9rxCmCLNdRotzcTAmOYlhUjpk6g9czVFyOKf6T30f925lLFcylCuZSBXNZvOAPi9mzvQ09WC4AAAAASUVORK5CYII="
    }
    State.placeImg = function(Image, Cache, X, Y, Width, Height, ZIndex, Alpha, Visible)
        if not Image or not Cache then
            return
        end
        pcall(function()
            if Cache[1] ~= X or Cache[2] ~= Y then
                Cache[1], Cache[2] = X, Y
                Image.Position = NewVector2(X, Y)
            end
            if Cache[3] ~= Width or Cache[4] ~= Height then
                Cache[3], Cache[4] = Width, Height
                Image.Size = NewVector2(Width, Height)
            end
            if Cache[5] ~= ZIndex then
                Cache[5] = ZIndex
                Image.ZIndex = ZIndex
            end
            if Cache[6] ~= Alpha then
                Cache[6] = Alpha
                Image.Transparency = Alpha
            end
            if Cache[7] ~= Visible then
                Cache[7] = Visible
                Image.Visible = Visible
            end
        end)
    end
    State.iconMasks = State.iconMasks or {}
    State.iconAlias = {
        ["home"] = "house",
        ["settings"] = "gear",
        ["cog"] = "gear",
        ["user"] = "person",
        ["users"] = "two-people",
        ["people"] = "two-people",
        ["sliders"] = "three-sliders-horizontal",
        ["shield"] = "shield-check",
        ["zap"] = "lightning-bolt",
        ["lightning"] = "lightning-bolt",
        ["box"] = "gift-box",
        ["globe"] = "globe-simplified",
        ["world"] = "globe-simplified",
        ["layers"] = "two-stacked-squares",
        ["gauge"] = "speedometer",
        ["speed"] = "speedometer",
        ["map"] = "location-pin-map",
        ["fire"] = "flame",
        ["lock"] = "lock-closed",
        ["notification"] = "bell",
        ["gamepad"] = "controller",
        ["search"] = "magnifying-glass",
        ["target"] = "crosshairs",
        ["crosshair"] = "crosshairs",
        ["swords"] = "sword",
        ["edit"] = "pencil",
        ["trash"] = "trash-can",
        ["delete"] = "trash-can",
        ["book"] = "book-closed",
        ["menu"] = "three-bars-horizontal",
        ["cart"] = "shopping-cart",
        ["mail"] = "envelope",
        ["email"] = "envelope",
        ["mic"] = "microphone",
        ["volume"] = "speaker",
        ["sound"] = "speaker",
        ["close"] = "x",
        ["info"] = "circle-i",
        ["question"] = "circle-question",
        ["warning"] = "triangle-exclamation",
        ["alert"] = "triangle-exclamation",
        ["time"] = "clock",
        ["camera"] = "photo-camera",
        ["hash"] = "hashtag",
        ["monitor"] = "code",
        ["plus"] = "plus-small",
        ["minus"] = "minus-small",
        ["play"] = "play-small",
        ["pause"] = "pause-small",
        ["stop"] = "stop-small"
    }
    State.iconMasks["house"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAACAAAAAAAAAAAAAAAAAAAAAAAEAAZ7fggABAAAAAAAAAAAAAAAAAAAAQMAL8v//88zAAICAAAAAAAAAAAAAAADAABq9f/6+v/3bwAAAwAAAAAAAAAAAQQAF6v///z///z//68ZAAQBAAAAAAACAQBJ4f/7/v/////++//kTQAAAwAAAAAABIn///v///////////z//40GAAAAAAAwxf/9/f/////////////9/f/INAAAAADn//v///////////////////v/7QAAAAAmpv/8/////////////////P+rJwAAAAAAmP/7/////fv7+/v9////+/+eAAAAAAACnP/7////////////////+/+iAgAAAAAAm//7//3/zI2Pj43J//3/+/+hAAAAAAAAm//7//v/WAAAAABQ//z/+/+hAAAAAAAAm//7//v/YAUJCQVZ//z/+/+hAAAAAAAAmv36//v/XgAEBABX//z/+v2gAAAAAAAAoP/8/fj7WQAAAABS+/n9/P+nAAAAAAAASuP7////9+fo6Of2/////ORPAAAAAAAAAAklP1RmeYWJiYV5ZlU/JgoAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["gear"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAgECCMPv7roEAgECAwAAAAAAAAAAAAEAAAUAR/////86AAUAAAEAAAAAAAABAQBKHwAOu/37+/6xCgAjSQABAAAAAAACAI3/9L7e//7///7/2sD2/4EAAwAAAAAAW//6/////v37+/3+////+/9QAAAAAAAAtv77/vz9/P/////9/fz++/+pAAAAAAAAN/z9///9/9iWmNv//f/+/vgtAAAAAAADAKv//P3/kQcAAAma//37/54ABAAAAAADALb/+f/IAAAFBQAA0v/5/6kABAAAAAAAb/n9+v9wAQUAAAUAff/6/fZoAAAAAAC5////+/9lAgQAAAQCcv/7////rwAAAAD//P7//P+qAAYDBAUAt//8//78/AAAAADc/vr8//39VgAAAABg//3//Pr+0AAAAACQ/////v7+/5xRU6D//v7+////ggAAAAAJNlay//3///////////3/qVM0BwAAAAAAAAAG1v79/vv7+/v//f/NAQAAAAAAAAABAgYAu/78//3///3//P6uAAYCAQAAAAAAAAAB4v/6/f/3+P/9+v/XAQEAAAAAAAAAAAIBg/f//6gbHrH///V7AAIAAAAAAAAAAAABADGjnAAAAAOjoC0AAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["person"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAfO/EfzwKAAAAAAAAAAAAAAAAAAAAAQAL6/////3dcgECAAAAAAAAAAAAAAAAAwA8//39/P7/8woAAQAAAAAAAAAAAAAABAB9//v///z9wwEBAAAAAAAAAAAAAAAAAgC+/vz///v/ggAEAAAAAAAAAAAAAAABAAry//v7/fz+QQADAAAAAAAAAAAAAAAAAgKF7v/////zDgABAAAAAAAAAAAAAAAAAAMAGU+QzfGGAwUAAAAAAAAAAAAAAAAAAgAAAAAAAAMAAAACAAAAAAAAAAAAAAACADmTp6qsqKOokzkAAgAAAAAAAAAAAAMAWf7///////////5ZAAMAAAAAAAAAAQEL6f/5+/v7+/v7+f/pCwEBAAAAAAAAAwA4//3///////////3/OAADAAAAAAAABABr/vv///////////v+bAAEAAAAAAAAAwCi//v///////////v/owADAAAAAAAAAQHU//3///////////3/1AEBAAAAAAACAB/1/v7///////////7+9R8AAgAAAAADAEL//vz9/v/////+/fz+/0IAAwAAAAABAQ2i/f/////////////9og0BAQAAAAAAAAAAOo3F5fb+/vblxY06AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["two-people"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAABAAAAAAAAAAEAAAAAAAAAAwBQ1bd3OQcAAgBrv8aDDQABAAAAAAAAAgDQ/////9kpAJr/////xgkCAQAAAAACABz2/fv7+v9cIf/7/P34/2MABAAAAAAEAFf//P///v0dWfz7///7/JoABAAAAAAEAJ/99/z8/t8AR//6/v/5/34ABAAAAAAEAHT////+/6QACc///v7/8R8BAgAAAAAAAQBBhsX1+EQAAB+7/f/SPQACAAAAAAAAAAMAAAAJDwADAQAAEBYAAAQAAAAAAAAAAQApaHVrTxEAAhNUaWpkKwABAAAAAAACAIH5/////+FEAMH/////+oUAAgAAAAAAZf/++/v7+v/2GF39+Pv7/v9pAAAAAAAF2P38//////n/hAP2//7//P3bBgAAAAAs+v////////z+ygDI//z////7LwAAAABk//3///////7/9gaJ//v///z/aQAAAACh//z////////9/zRG//z///z/pwAAAADj/Pr9/f7+/fz3/X0P/P79/fr86AAAAADG/////////////2IZ////////zAAAAAANYKXM3+jn3MOURwBz5+XgzKZjDgAAAAAAAAAAChEQBwAAAAEOEBEKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["eye"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgMAAAAAAAAAAAMCAAAAAAAAAAAAAAADAAAVTXeNjXdNFQAAAwAAAAAAAAAAAAMAHZft////////7ZcdAAMAAAAAAAAAAwBK6f///Pr4+Pr8///pSgADAAAAAAADAEr9//v+/P/////8/vv//UoAAwAAAAABHvH+/P/9/+y/vev//v/8//EeAQAAAAAAqf/7//3/fw8AABSJ//3/+/+pAAAAAAA1/f3//P+BPMRxAwAAjP/8//39NQAAAACe//z+/+wI2v/6DAIDDez//vz/ngAAAADr//78/74AeOiSAgICALz//P7/6wAAAADt//78/7oAAA8AAAACALr//P7/7QAAAACj//z+/+kKBAABAAIDCun//vz/owAAAAA6/v3//P+EAAEDAwAAhP/8//3+OgAAAAAAsP/7//3/fg0AAA1+//3/+/+wAAAAAAABI/X+/f/+/+OysuP//v/9/vUjAQAAAAADAFP///v+/P/////8/vv//1MAAwAAAAAAAwBT7////Pn4+Pn8///vUwADAAAAAAAAAAMAJKP0////////9KMkAAMAAAAAAAAAAAADAAAdWIOamoNYHQAAAwAAAAAAAAAAAAAAAgMAAAAAAAAAAAMCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["folder"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAA+jI+Pj4+Pij8AAwAAAAAAAAAAAAAAAAD4//////////9PAAYDAwMDAwMDAwAAAAD/+/v7+/v7+v3zMAAAAAAAAAAAAAAAAAD+//////////3/6K6wrq6urq2rVwAAAAD////////////+/////////////wAAAAD//////////////vz8/Pz8/Pz7/wAAAAD//////////////////////////gAAAAD//////////////////////////wAAAAD//////////////////////////wAAAAD//////////////////////////wAAAAD//////////////////////////wAAAAD//////////////////////////wAAAAD//////////////////////////wAAAAD//////////////////////////wAAAAD+/////////////////////////gAAAAD/+/v7+/v7+/v7+/v7+/v7+/v7/wAAAAD9/////////////////////////QAAAABJmpydnZ2dnZ2dnZ2dnZ2dnZyaSQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["code"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAgMAAQQBAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAIAEVoKAAIANkwAEVsJAAIAAAAAAAAAAwARxv86AAQA2fsATf+3CQACAAAAAAADABHF/44FBAAZ/LsACJ7/twkAAgAAAAAAEMb/kAABBABO/3cAAwCg/7cIAAAAAAARxP+RAAMBBACO/zoABAIAof+1CQAAAADS/4gABAEAAQDS9QwAAQEDAJr/vgAAAADT/4oABAEBABj9vAACAAEDAZv/vwAAAAARxP+TAAMFAE3/eAAEAQIAo/+1CQAAAAAAEMX/kgAEAI3/OwAEAACh/7cIAAAAAAADABDE/5AFAM/0DAADCZ//tgkAAgAAAAAAAwAQxf82A//CAAYAT/+2CQACAAAAAAAAAAIAEFgKAFIsAAIAEFkJAAIAAAAAAAAAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQQAAAMCAAAAAQQBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["three-sliders-horizontal"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQEBAgABKx8AAAEBAAAAAAAAAAAAAAAAAAAAADPL+PGaCAAAAAAAAAAABAMEBAQEBAUFEuP//v//iQMHAAAAAADb9PP09PT09PT0+P/9//78//P0zgAAAACKoqChoaKioaKgrv/8/fz96J+jgQAAAAAAAAAAAAAAAAAAAL//////XQAAAAAAAAAEBAQEAA4UAAAGAxWk5NhtAAYEBAAAAAADAwQDhOLqqRcCBAAADQUAAwICAwAAAAAAAAB8/////78AAAAAAAAAAAAAAAAAAACux8X3/P3+/P/MxcbGx8fGxsXHowAAAAC91tX7/P7+/P/b1tbW1tbW1tXWsgAAAAAAAACH///+/8oAAAAAAAAAAAAAAAAAAAACAgMHmfH3viEBAwAAAAAAAwEBAgAAAAAEBAQDABwkAAAGAw6Q08VcAAYEBAAAAAAAAAAAAAAAAAAAALj/////VwAAAAAAAACKoqChoaKjoaKgrf/7/fv96J+jgQAAAADb9PP09PT09PT0+f/9//78//P0zgAAAAAABAMEBAQEBAUEE+j//Pz/jgMHAAAAAAAAAAAAAAAAAAAAAD/c//ytDAAAAAAAAAABAQEBAQEBAQEBAgAORDUAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["shield-check"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAADPpLk45E9AwAAAAQBAAAAAAAAAAACOIXQ/v/////+z4Q3AgAAAAAAAAABEITU//////z+/vz/////04MQAQAAAAAAhf///vv9/////////fv+//+FAAAAAAAAnvv5///////////++/7/+fueAAAAAAAAmf/7//////////7/////+/+YAAAAAAAAlf/7/////////v//iNj/+f+VAAAAAAAAjv/7//77/v/9/f9WAML/+P+OAAAAAAAAgv/7//////z+/1cAqv/9+/+CAAAAAAAAbv/5/99i5v/9VwCo//z/+/9uAAAAAAAAUv/6/t4FJNtZAKf/+v///P9SAAAAAAAALv///f/UDwEAo//6/////v8sAAAAAAAACOP//vz/0y6i//r////9/+EHAAAAAAAEAJj/+//9/////f/////7/5YABAAAAAADACv9/P7//f/9//////78/CoAAgAAAAAAAwCH//n///////////n/hQADAAAAAAAAAQMCrf/7/f/////9+/+sAgMBAAAAAAAAAAEBA5j///z+/vz//5gDAQEAAAAAAAAAAAABAQBV2P/////YVQABAQAAAAAAAAAAAAAAAQMADnvp6XsOAAMBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["lightning-bolt"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABABa7KcFAgAAAAAAAAAAAAAAAAAAAAADADL0//8kAAIAAAAAAAAAAAAAAAAAAAIBE+D//f0oAAIAAAAAAAAAAAAAAAAAAQQAuf/7//4nAAIAAAAAAAAAAAAAAAAABACM//v+//4nAAIAAAAAAAAAAAAAAAAEAFv/+//+//4qAgIAAAAAAAAAAAAAAAMAMff8/v/+//4aAAMEAwAAAAAAAAAAAgAS3f/9/////v5wIAAAAAEAAAAAAAAAAgS3//z/////////98aGPAABAAAAAAAEAGn/9v3+///////8/////1IAAwAAAAAEAF3//////P///////v32/2oABAAAAAAAAQBKldP+//////////z/vQYCAQAAAAAAAAAAAAMsfv7+/////f/hFQACAAAAAAAAAAADBAEAHP/////+/Pk3AAMAAAAAAAAAAAAAAAMCLf/////7/2IABAAAAAAAAAAAAAAAAAIAKv////v/kgAEAAAAAAAAAAAAAAAAAAIAKv//+//AAgMBAAAAAAAAAAAAAAAAAAIAKv79/+QXAQIAAAAAAAAAAAAAAAAAAAIAKP//9zgAAwAAAAAAAAAAAAAAAAAAAAEBCLj3YwAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["gift-box"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAbKtZaqxaAAEAAAAAAAAAAAACBAQEBgB2//f///f/WAAHBAQEAQAAAAAAAAAAAAHa0gDmuwDvuAEAAAAAAAAAAAAga29xUgCd/63v4LH/ewBgcW9pGQAAAADg////+RkRoP////+QBy3/////0QAAAAD/+/v4/7cAaP+Vq/9LANH9+Pv79wAAAAD//v/9/uYAWIUAAJBDBPj+/v/+9QAAAADz//////9uAABbSgAAiP//////5QAAAAAeIyAhICElAAA2LQAAJyEhISAkHAAAAAAAPklISEhIUlMAC1NRR0hIR0k3AAAAAABG//////////8mSP//////////KQAAAABL/fv8/Pz8+/wiQfz5/Pz8/Pz7LgAAAABK//7//////v8iQv/8///////8LQAAAABK//7//////v8iQv/8///////8LQAAAABK//7//////v8iQv/8///////8LQAAAABK//7//////v8iQv/8///////8LQAAAABJ/v7//////v8iQv/8///////6LQAAAABN//39/Pz8+/wiQfz5/Pz8/f7/LgAAAAAc3P////////8kRf/////////IDQAAAAAAFkpieYyapKsXLayimIp2X0YOAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["star"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQmRkQgBAQAAAAAAAAAAAAAAAAAAAAAEAGT//2IABAAAAAAAAAAAAAAAAAAAAAACAMD9/b4AAgAAAAAAAAAAAAAAAAAAAAIAIfj+/vggAAIAAAAAAAAAAAACBAQEBAgDcP/7+/9uAwgEBAQEAgAAAAAAAAAAAAAAxP/8/P/EAAAAAAAAAAAAAAAncXR1dnSC+v/////6gnR2dXRxJwAAAADo////////////////////////6AAAAADk//f7+/v7////////+/v7+/f/5AAAAAAmxf/8/v/////////////+/P/FJgAAAAAABpf//////////////////5cGAAAAAAACAABi8v3+/////////v3yYgAAAgAAAAAAAQQAR//9/////////f9IAAQBAAAAAAAAAAQDXP/8/////////P9cAwQAAAAAAAAAAAMAsf/7//78/P7/+/+yAAMAAAAAAAAAAQAQ7f/+/f/////9/v/tEAABAAAAAAAAAwBL//z7//16ev3/+/z/SwADAAAAAAAABACc/Pr/1DwAADzU//r8nAAEAAAAAAAAAwCf//2QCwAEBAALkP3/nwADAAAAAAAAAQAWhEwAAAMAAAMAAEyEFgABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["globe-simplified"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACABFqxo8AAI/FaA4AAwAAAAAAAAAAAQIAYN3/+RRYSRb4/9paAAIBAAAAAAABAwCY////awL04wBu////kQADAQAAAAADAJb/+f3rA3r//2IF6/35/40AAwAAAAAAVv/6+v+PAur+/toAkf/6+v9NAAAAAAAM3v79/f8yP//8/f8qNf/9/P7WBwAAAABg//z+//QDi/76+v50BPT//v3/UwAAAAC1/vz9/9cAuv/8+/+kANf//fz+qQAAAADp/////8gA0/////+/AMr/////4QAAAAAaGhoaGxMAFRoaGhsTABMbGhoaGgAAAABbZGRjZEwAU2RjY2RLAFBkY2RkXQAAAADx/////9YA3f/////EAOH/////7AAAAACx+vj5+9cAsfv49/qSAOT7+fj6qQAAAABh//3+//YFhf77/P9YFf7//v3/VQAAAAAK2/78/f8zOv/8/voRXf/7/P/RBgAAAAAATP/6+v+MAen+/7AAwf/7+/9BAAAAAAADAIP/+vznAX7//i0p/vr8/3cAAwAAAAAAAwB/////XQb+qwC0////dAADAAAAAAAAAAIARMT/8RJYGVH//789AAMAAAAAAAAAAAADAABHoWEACLCWQwAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["grid"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACZ////////////////////////igAAAAD/y4mNi4r03IqMjIrk7YqLjYnT/AAAAAD+gQAAAADkrQAAAADA1AAAAACU/wAAAAD/jAQJBATmtAQHBwTF2AQFCASe/wAAAAD/igEGAQHmswEEBAHE1wECBQGc/wAAAAD/hgAAAADlsAAAAADC1gAAAACZ/wAAAAD/7dfZ2Nj789fY2Nf2+dfY2Nfw9QAAAAD/5MTFxMT57cTFxcTx9sTExcTo9gAAAAD/gwAAAADlrwAAAADB1QAAAACW/wAAAAD/iwMIAwPmtAMGBgPF1wMEBwOd/wAAAAD/jAMIAwPmtAMGBgPF2AMEBwOd/wAAAAD/ggAAAADkrgAAAADA1AAAAACW/wAAAAD/3bO2tLT46bO1tbPu87S0tbPi9wAAAAD/8+bm5ub99+bm5ub5++bm5ub19AAAAAD/iAABAADmsgAAAADD1gAAAACa/wAAAAD/igAFAADmswADAwDE1wABBACc/wAAAAD/jAUJBQXmtAUICAXF2AUGCQWe/wAAAAD+gQAAAADkrQAAAADA1AAAAACU/wAAAAD/y4qNi4v03YqNjIrk7YuMjYrT/AAAAACZ////////////////////////igAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["two-stacked-squares"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACK////////////////7kEAAgAAAAAAAAD72ZmbmpqampqampqX+6MABAAAAAAAAAD/lAAAAAAAAAAAAAAA66oABAAAAAAAAAD/ngQIBAQEBAQEBQQE7KgABAAAAAAAAAD/nAAEAAACAQAAAQEA9q0ABQABAwAAAAD/nAAEAAAAAAAAAAAAQykAAAAAAAAAAAD/nAAEAgBCxM/Pz8/PwsfPz8/KawAAAAD/nAAEAgDH/////////////////wAAAAD/nAAEAQDJ/Pr9/f39/f39/f38/gAAAAD/nAAEAQDJ//z//////////////wAAAAD/nAAFAQDJ//z//////////////wAAAAD+nAADAQHJ//z//////////////wAAAAD/mQABAADK//z//////////////wAAAADr/+bn5kS7//z//////////////wAAAAA7oa6trC+///z//////////////wAAAAAAAAAAAADK//z//////////////wAAAAACBAMDBQHI//z//////////////wAAAAAAAAAAAQDJ//z//////////////gAAAAAAAAAAAgDK//z//////////////wAAAAAAAAAAAwBl9fz///////////37mQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["speedometer"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAABAgAAAAAAAAAAAAACAAAFOGWAgGJADQIBAF5SAAAAAAAAAAMACXXY///////QHgACjP9xAAAAAAAAAwAx0f///vn6/5oLABu6/6kAAgAAAAADADrx//v9+//7bgAAQOH/2hEEAgAAAAACGur/+//7/+JBAABt+//4OAAAAQAAAAAAqP/7//z/vR0ACpz/+v9xABd5AAAAAAA1/f3//P+tAwAmx//4/6wAAKH/LwAAAACX//z+/uoRAEnp//n/3RIAZf/9lQAAAADY//37/6QAKPj/+vz7OQAw9/z/1wAAAAD2///7/4wCWP/2+f9wAA7W//z/9QAAAAD////8/64AHef//6kAAKP/+////gAAAAD1///+/vMiACuLdAoAZ//7////9QAAAADW//3//f/LHAAAAABP+fz+//3/1gAAAACT//z///3/6IhaY6n///7///z/lAAAAAAx/P3////9/////////v////38MQAAAAAAov/4+/v7+vf4+Pj7+/v7+P+iAAAAAAACFub//////////////////+YXAgAAAAACADGcnJ2dnZ2dnZ2dnZ2cnDEAAgAAAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["location-pin"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAymNn09NeULgABAQAAAAAAAAAAAAECAYb3////////9H8AAgEAAAAAAAAAAQMBqf///P37+/38//+gAAMAAAAAAAAAAwB+//n//f/////9/vn/cwADAAAAAAACAB/4/P7+//CztPL//v788xkAAgAAAAAEAHr/+/3/xR8AACPM//37/28ABAAAAAADALj++/72IQAFBQAq+f37/q0AAwAAAAAAAND/+v/IAAMAAAIA0v/6/8YAAQAAAAABAM3/+v/RAAQBAQMB2v/6/8MAAgAAAAADAKz++/39PwAAAABJ/v37/qIABAAAAAAEAGT//P7/5k0LDFLq/v78/1kABAAAAAABAQ/o/v3////j5f////3+4QsBAQAAAAAAAwBW//v9/v3///3+/Pz/TAADAAAAAAAAAAMAdv///f/9/f/9//9tAAMAAAAAAAAAAAADAFDX//7///7/00oAAwAAAAAAAAAAAAAAAwAIsf78/P6oBgADAAAAAAAAAAAAAAAAAAYARP/8/f85AAYAAAAAAAAAAAAAAAAAAAEBE+///+gNAQEAAAAAAAAAAAAAAAAAAAACALv//7AAAwAAAAAAAAAAAAAAAAAAAAADAVb49UwBAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["location-pin-map"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAADAAAAAAAAAAAAAAAAAAAAAAACAAUrKwUAAgAAAAAAAAAAAAAAAAAAAAIAXtr9/dpeAAIAAAAAAAAAAAAAAAAAAwBi////////YQADAAAAAAAAAAACBAECAQ/s/f/Gxv/97A8BAgEEAgAAAAAAAAAAAED//7gAALj//0AAAAAAAAAAAAAefNpxAEv//6QAAKT//0oAcdp8HgAAAADf/7k8ABz4/PuVlfv89xwAPbn/3wAAAAD/cgAABgCF//3///3/hQAGAABy/wAAAAD+bgMGAAACjv75+f6OAgAABgNu/gAAAAD/cAACXV0BAGb//2UAAV1dAgBw/wAAAAD/cAAAz9AAAgr19AoCANDPAABw/wAAAAD/cAAAwMEAAwLa2gIDAMHAAABw/wAAAAD/cAACxMUDBQAaGgAFA8XEAgBw/wAAAAD/cgEAvr8AAgQhJQQCAL++AAFy/wAAAAD9ZAAq2981CAC5ygAGNN/bKgBk/QAAAAD/ws7/8u//76TZ4aLu/+/y/87C/wAAAACY8L5hGBJMmuX//+WaTRIYYb7wlwAAAAAACAAAAAAAAAArKwAAAAAAAAAIAAAAAAACAAMEAQEDBAAAAAAEAwEBBAMAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["crown"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgAAAAAAAgA4OQABAAAAAAACAQAAAAAAAAECAAADAEX8/UcAAwAAAgEAAAAAAAABJgAABAICCd3//90JAgIEAAAnAgAAAACt/bkwAAMAg//7+/+AAAMAMrr9sQAAAAD4///5hgYl+Pz+/vz2IAiJ+v//+gAAAADX/vv//83L//3///3/yND///v+2QAAAAC9//3+/P///v/////+///8/v3/vwAAAACf//z///39/////////f3///z/oQAAAACA//z///////////////////z/gQAAAABh//3///////////////////3/YgAAAABE//7///////////////////7/RQAAAAAq+v/+/////////////////v/6KwAAAAAV6//9/Pv7/P3+/v38+/v8/f/rFQAAAAAE1vz///////////////////zWBAAAAAAAyv/ptH9YPi8oKC8+WH+06f/KAAAAAAAAfFkAAAQfNkZOTkY2HwQAAFl8AAAAAAABABl7yfH///////////HJexkAAQAAAAABG+b///////z7+/z//////+YbAQAAAAABAR9trNTr+P7///7469SsbR8BAQAAAAAAAAAAAAMWJzQ7OzQnFgMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["flame"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEP3vXRhhwAAwAAAAAAAAAAAAAAAAAABAFQ//7//+dWAAMAAAAAAAAAAAAAAAAAAwC+//v+/P//UQADAAAAAAAAAAAAAAAEAE3//P////z+6xMBAQAAAAAAAAAAAAIBFeX+/f/////7/3EABAAAAAAAAAAAAQMBuf/8///////8/rkBBQEAAAAAAAAAAwCH//v////////9/9gAAAAAAAAAAAADAD//+/7////+///9/9cOOxwAAQAAAAACAcX//P////////////Ti/7cAAgAAAAAAKf7+//////39/f7//////vQVAAAAAAAAVv/8///9/85c//39//79/f89AAAAAAAAZf/7///7/4oAev///v///P5TAAAAAAAAWf/7///9/0ACAD7f/v3//P9OAAAAAAAAMf/+//7/9BcCCQBw//v//v8sAAAAAAABBdv+/f7+9x0ABACJ//v9/dgEAQAAAAAEAGr/+v/9/7MbBkvx/v76/2kABAAAAAABAgTD//n//v/w3f///vr/xAQCAQAAAAAAAgEX0//+/fz///38/v/UGAECAAAAAAAAAAIAEqP9/////v///qMSAAIAAAAAAAAAAAACAABCpOD6++KlQgAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["lock-closed"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAUtT//8I4AAIAAAAAAAAAAAAAAAAAAwBu/+KVnfP7RgADAAAAAAAAAAAAAAACACj/tAgAABna7A4BAQAAAAAAAAAAAAAEAIj+GQAHBwBE/1UABAAAAAAAAAAAAAMFAbHqAAIBAwIX/nwBBgMAAAAAAAAAAQAAAK/mAAAAAAAT/3oAAAABAAAAAAACAGTCye/6y8vLy8rQ/+TJukcAAgAAAAAAR/////////////////////okAQAAAAAAhv34/f7//Pz7+/z9//79+f9XAAAAAAAAg//7/////////////////P5XAAAAAAAAhP/7/////v/h6v/+/////P9XAAAAAAAAhP/7/////v8kVf/8/////P9XAAAAAAAAhP/7//////8ZSP/8/////P9XAAAAAAAAhP/7//////8dS//8/////P9XAAAAAAAAhP/7/////v8UR//8/////P9XAAAAAAAAhP/7/////v+/0P/+/////P9XAAAAAAAAhP37////////////////+/xXAAAAAAAAhv/8/Pz9/v/8/f/+/fz9/v9WAAAAAAABLs/8////////////////+L0WAQAAAAABAAM3c6nQ6ff+/fXlyaFqLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["bell"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAABawO349+q2SwABAAAAAAAAAAAAAAECCaj//////////5MBAwEAAAAAAAAAAAIArf/7/f7///79/P+QAAMAAAAAAAAAAwBQ//r//////////vv/NQADAAAAAAAAAwCy/fv///////////v+kwAEAAAAAAABAArl//7///////////3/zQABAAAAAAADADP//v////////////7/9hoAAgAAAAAEAGv/+//////////////8/00AAwAAAAADAKb/+//////////////7/4gABAAAAAAABNz//f/////////////8/8EAAgAAAAAAJvz////////////////+/+8RAAAAAAAAW//8/////////////////f8/AAAAAAAAlf/7////////////////+/93AAAAAAAAy//9/////////////////P+wAAAAAAAi8/v6/Pz+//39/f3//vz8+vvjDgAAAAA7///////////////////////3IQAAAAACNXCatsP4+Nzn5df88sK0lWosAAAAAAAAAAAAAACl+ioAAED/gQAAAAAAAAAAAAAAAgQEBQIi6fOWnv/WEgMEBAQCAAAAAAAAAAAAAAIALcD//7AdAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["compass"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAECABBpue07ZemxXwkAAwAAAAAAAAAAAQEAYN3///8nU////9NQAAMAAAAAAAABAwGa///8/P4bTP74/f//hQADAAAAAAADAJv/+v3//f+nvP77/f37/4EAAwAAAAAAXP/6/////fv////////++/9DAAAAAAAP4/39///+/////+/M0P/+/P7OBAAAAABo//z///7/xoZUNBgAB+T//f3/SgAAAAC6/Pv9/P/GAAAcAAABFO7//Pr9nAAAAAD6////+/+HALH/24kBN//+////4AAAAABBLS6q/v9YBu39//gBW///iCwuQAAAAABeTE24//8nLP///7oBjv/+nEtMWgAAAAD8//////ERCoTL82MAuP/7////4gAAAAC2+/n7/8kAAAAAAwAf6f7+/fj7mAAAAABi//39/8oHDzJWfa3p//7///3/RQAAAAAL3v79///c5////////v///P/HAgAAAAAAU//6/v////////z+///++/87AAAAAAADAJD/+/39/P+Qq//9//z8/3YAAwAAAAABAwCO///9+/4aSv74/f//eAADAAAAAAAAAQIAVNP///8nVf///8hEAAMAAAAAAAAAAAADAAlcq+E7Y92jUQIAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["controller"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAECAAAAAAAAAAAAAAAAAwAAAAAAAAAAAQAALmVyc3Nzc3NzcVgXAAIAAAAAAAABAQyj///////////////ubQACAAAAAAACArb//fv7+/v7+/v7+Pj//2oAAwAAAAAAU//5/vz+/////////////fMVAAAAAAAApf35/////f////r7kWPw+f9SAAAAAAAAyP//2UfX//3/////HwDb//+AAAAAAAAO5f/hlgCT4f39/p6Nxqu/fviwAAAAAAAr+v8fAAkAHf/+9QAA8f9BAMniAQAAAABQ//ywbABqr/39/6qavp7Hjvj1HQAAAAB5//n/zxTN//z/////HADa//7/RgAAAACj//z8+vD6/P////r7onfz+vv/dQAAAADL//3///////39/f7///////z/pwAAAADu//7///7//v///////Pv///3/1gAAAAD+///////8/8o/ReD//f////7/7gAAAADj/f3///77/DAAAEP/+v7///z90wAAAABq//77+/3/hAAGBgCP//v7+/3/XwAAAAAAhv////yTAgMBAQMFqP////+CAAAAAAABAC1kYCkAAAAAAAEAAD93cTAAAQAAAAAAAgAAAAACAAAAAAABAQAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["magnifying-glass"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAEmj2/T026NJAAADAAAAAAAAAAAAAwAotf//////////tSgAAwAAAAAAAAADAD/u//+0akREarT//+4/AAMAAAAAAAABJfH/2EEAAAAAAABB2P/wJgECAAAAAAABuv/aGgADBAMDBAMAGtr/vgECAAAAAABI//s7AAUAAAAAAAAFADv6/0MAAwAAAACo/7MABAAAAAAAAAAABACz/p4ABAAAAADh/2EBBAAAAAAAAAAABAFh/9ICAAAAAAD5/z0AAwAAAAAAAAAAAwA8/+kOAAAAAAD7/zoAAwAAAAAAAAAAAwA6/+sPAAAAAADm/1kBBAAAAAAAAAAABAFZ/9cDAAAAAACz/qYABAAAAAAAAAAABACl/qgAAwAAAABX//YpAAQAAAAAAAAEACn1/1IABAAAAAAFzP/HCgAFAwICAwUACsj/0AYBAQAAAAAAOPz/wSYAAAAAAAAmwf/4MgAFAAAAAAADAFr7/++SRyYmR5Lv////nQkABAAAAAAAAwBD1P////7+////1VDG/8YeAAAAAAAAAAMACma56P396LpmCwAf5f/hQAAAAAAAAAACAAAADyIiDwAAAAUAOPH/6QAAAAAAAAAAAQQCAAAAAAIEAQAEAF3ndgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["sword"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABACY8vL08/PscwAAAAAAAAAAAAAAAAAEAHH/////////6QAAAAAAAAAAAAAAAAMARf/8/v////7+6AAAAAAAAAAAAAAAAgAf6/79//////7/6AAAAAAAAAAAAAABAwbK//z///////7/6AAAAAAAAAAAAAAEAJ7/+/z+//////7/5gAAAAAAAAAAAAQAbf/6/v////////3+7wAAAAAAAQMAAwBA/fr9/6no//7//f//gwAAAAAAAAABARvo/fr/awC4//z8//lhAAAAAAAAKbEPAMf/+f9sAID+/fv/4DoAAwAAAAAASv9ci//4/24Aff/8+/+9GQAEAAAAAAACC77///z/cAB7//n+/5IDAAMAAAAAAAACAg7C//lmAHj/+P/6ZgABAgAAAAAAAAAAAAAFv/9Zav/3/+I9AAQBAAAAAAAAAAAAOKsqBMT///3/wRsABAAAAAAAAAAAAACf///lJgTA//iJAAADAAAAAAAAAAAAAAD9/vn/5C0MwP9bGAQBAAAAAAAAAAAAAABx//35/7EADLz/uQADAAAAAAAAAAAAAAAAbv///zgBAARGKAABAAAAAAAAAAAAAAAEAHLtoQECAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["crosshairs"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAADbyAAAAAMAAAAAAAAAAAAAAAAAAgAHQYT/+3o7AgADAAAAAAAAAAAAAAEBAF3U///9////zFAAAgAAAAAAAAAAAQMCnP//3Kf/+qXk//+JAAMBAAAAAAAAAwCc//h2CwDo1gARhP//hAADAAAAAAADAFb/9ksAAAIZFQMAAGD8/z8AAwAAAAACBtf/eAAGAQIAAAEBBgCS/78BAwAAAAAAO//gBQQBAAAAAAAAAgMT8P0kAAAAAAAAff6gCQABAReZkRABAQALuv9lAAAAAADJ+P7z6lEBAKf//5EAAWns9P32swAAAADc//76+lsAAK///5oAAHX8+v3/xQAAAAAFiP6kFwABAR+rpBYBAQAYvP9wAgAAAAAAPv/aAAQBAAAAAAAAAgMM7P4mAAAAAAACCNz/cQAGAQEAAAEBBgCL/8UCAwAAAAAEAF3/80UAAQRdUwQAAFn6/0UAAwAAAAAAAwCi//ZxCQj/9QAPf/3/igADAAAAAAAAAQIEof//26X69KPi//+OAAMBAAAAAAAAAAEBAGDU///+////zFMAAgAAAAAAAAAAAAABAgAHQYT/+3o7AgACAAAAAAAAAAAAAAAAAAMAAADbyAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["pencil"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAQ962DgADAAAAAAAAAAAAAAAAAAAABQRO7///whIAAwAAAAAAAAAAAAAAAAADAACv//j7/88XAAAAAAAAAAAAAAAAAAQAUUYAtf/7+//TIAAAAAAAAAAAAAAABQBO//c8ALf/+/v/zwAAAAAAAAAAAAAFAFH8/f/0PQC4//j/1AAAAAAAAAAAAAUAVPz+/v3/9D0At//dJwAAAAAAAAAABQBX/f79///9//Q6AJ8sAAAAAAAAAAAFAFn+/f3//////f72QAAAAgAAAAAAAAUAXP/9/v///////f/uOgMEAAAAAAAABABf//3+///////9/+4zAAIAAAAAAAAEAGL//f7///////3/8TgABAAAAAAAAAAAY//9/v///////f/0PQAEAAAAAAAAAABl//3+///////9/vdCAAQAAAAAAAAAAAD2//7///////3++UcABAAAAAAAAAAAAAD//////////f77TAAEAAAAAAAAAAAAAAD+///////+/f1RAAUAAAAAAAAAAAAAAAD+//////3+/1cABQAAAAAAAAAAAAAAAAD//////v/9WwAEAAAAAAAAAAAAAAAAAACh/P3+/exhAAUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["pencil-square"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADMDIyMjIyMjItAwABBAWP6HkAAwAAAAC3////////////OQAFAG3//P99AAAAAAD/o0xPTExMTE1HCwAFJQ26//j/hgAAAAD9cgAAAAAAAAAAAACg8jIAvv/88AAAAAD/fAMHAwMDAwUFAJ7///A1Ab7/ZwAAAAD/egAEAAAAAQIAof/7/P/vMA1VAAAAAAD/egAEAAACAgCk//r///z/9RcAAwAAAAD/egAEAAEBAaf/+v///vv/gQcIAQAAAAD/egAEAQIEqv/6////+/+DAAAAAAAAAAD/egAEAgGg//r////7/4kAAw8/AgAAAAD/egAGAB3//f7///r/jwAHAFj/IQAAAAD/egAGACj7/v3++v+VAAMFAF3+JgAAAAD/egAGACX//////5oAAwEEAFz/JQAAAAD/egAFAQi3+vnzlAACAQAEAFz/JQAAAAD/egAEAQABISQaAAEBAAAEAFz/JQAAAAD/egAEAAAAAAAAAgAAAAAEAFz/JQAAAAD/fAQIBAQFBgYGBAQEBAQIBF//JQAAAAD+cAAAAAAAAAAAAAAAAAAAAE//JQAAAAD/u3p9e3t7e3t7e3t7e3t9eqv/JAAAAACh//////////////////////+rBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["trash-can"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwFP8f/////xTwEDAAAAAAAAAAAAAQMEBQDJ2XZ6enbYygAFBAMBAAAAAAAAAAAAAAv9gQMHBwOB/QsAAAAAAAAAAAAAFlCErdT/9ff39/f1/9SthFAXAAAAAAAt/f/////////////////////9LQAAAAARWMj7+f3//f7+/v79//35+8hYEQAAAAABAKL/+//////////////7/6IAAQAAAAAFBJT/+///6//////r///7/5QEBQAAAAAEAID/+f/XEs///88S1//5/4AABAAAAAAEAG3/+f/UALP//7MA1P/5/20ABAAAAAAEAFr/+v/kAaX//6UB5P/6/1oABAAAAAADAEn/+//uAJT//5MA7v/7/0kAAwAAAAADADj//f/4CIP//4MI+P/9/zgAAwAAAAACACj+////C2n//2kL/////igAAgAAAAACABr1//3/Pn3//30+//3/9RoAAgAAAAABAA7q//3/+v3///35//3/6g4AAQAAAAABAATc//3///////////3/3AQAAQAAAAAAAADT/Pr9/f7///79/fr80wAAAAAAAAAAAwCl////////////////pQADAAAAAAAAAQEVdqrQ6ff+/vfp0Kp2FQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["book-closed"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgB83gR48e3w8PDw8O/vxSMBAgAAAAAEAGb/+QKB//7////+/////68AAwAAAAACAMz98gOA/vr///////79/dYAAAAAAAAAANH/9AOA//7RL1Cb2P/9/9EAAAAAAAAAANH/9AOA//93ACYABHX//9IAAAAAAAAAANH/9AOA//8sQv/ZB2H//9IAAAAAAAAAANH/9AN+/+IAgv/gALX//9IAAAAAAAAAANH/9AN+/8wCADU+B+v//9IAAAAAAAAAANH/9AOA//zSjEMKU//7/9IAAAAAAAAAANH/9AOA//v////z+P/8/9IAAAAAAAAAANH/9AOA//v9+/z////9/9IAAAAAAAAAANH/9AOA//v////+/v/9/9IAAAAAAAAAANH/9AOA//v////////9/9IAAAAAAAAAANH/9AOA//v////////9/9IAAAAAAAAAANH/9AOA//v////////9/9EAAAAAAAAAANH+8wOA//v////////8/tUAAAAAAAAAAM///AeG/////////////8gAAQAAAAAAAOLAHAAEGxobGxseG8XYHwsAAQAAAAADAL/fZG9pZGRkZGRmY9bnaUMAAQAAAAACASze/////////////////8YAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["check"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQEAgAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIABYOaJAAAAAAAAAAAAAAAAAAAAAAAAgEFsv//0gAAAAAAAAAAAAAAAAAAAAACAQWy//f95gAAAAAAAAAAAAAAAAAAAAIBBbL/+P/2SQAAAAAAAAAAAAAAAAAAAgEFsv/4/vlIAAAAAAACBAQAAAAAAAACAQWy//j/+UoABQAAAAAAAAAAAAAAAAIBBbL/+P74SQAEAAAAAAAum3QAAgEAAgEFsv/4/vlKAAQAAAAAAADn//+cAAIDAQWy//n/+UoABAAAAAAAAAD8+/n/mwAABrP/+f75SgAFAAAAAAAAAABg//35/5oRtP/4/vlKAAQAAAAAAAAAAAAAXv/8/P/j//v++UoABQAAAAAAAAAAAAAFAGH//fz/+/75SgAFAAAAAAAAAAAAAAAABQBh//z4//lLAAQAAAAAAAAAAAAAAAAAAAQAYv//+EsABQAAAAAAAAAAAAAAAAAAAAAEAEeLNwAEAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAMEAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["three-dots-horizontal"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAwQDAQAAAAMDBAIAAAACAwQDAQAAAAAAAAAAAAEAAAAAAAABAAAAAAAAAAAAAAAMlJxWGAACAGynaCsAAgA8qn07AwAAAABg////6iwAHP////1lAQDG////sgAAAACo+vj6/0gAV/z49/+QABvv+/n+5AAAAADu//r76hEAmP/6+f9KAE7//vj8mgAAAACK7f//swABSd////MTAR3G/P//TQAAAAAAFEt2IAACAAk3c0IAAgAAKGhjAwAAAAACAAAAAAAAAgAAAAABAAEAAAAAAAAAAAAAAQMEAgAAAAEDBAMAAAAAAgQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["three-bars-horizontal"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADBAQEBAQEBAQEBAQEBAQEBAQEAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABnk5KTk5OTk5OTk5OTk5OTk5KTWwAAAAD/////////////////////////+gAAAABJdHN0dHR0dHR0dHR0dHR0dHN0QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAIISAhISEhISEhISEhISEhISEhBQAAAADg////////////////////////zgAAAADE6unp6enp6enp6enp6enp6ejptAAAAAAADAwMDAwMDAwMDAwMDAwMDAwMAAAAAAAEAQEBAQEBAQEBAQEBAQEBAQEBBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABkkY+QkJCQkJCQkJCQkJCQkI+QWAAAAAD/////////////////////////+gAAAABNd3Z3d3d3d3d3d3d3d3d3d3Z3QwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADBAQEBAQEBAQEBAQEBAQEBAQEAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["chevron-small-down"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAEBAAAAAAADAAADAAAAAAAAAAAAAAAAAwAAAgAAAAAAEBAAAgAAAAAAAAAAAAACAA8SAAAAAABj6OljAAQAAAAAAAAAAAQAYObqZwAAAAD7////ZwAEAAAAAAAABABm////9QAAAADw//v8/2YABQAAAAAEAGj//Pr/2wAAAABQ+f/8/P9lAAQAAAQAaP/8/P/wOwAAAAAATvz+/P3/ZAAFBABq//z8//Q9AAAAAAAFAFH7/vz9/2MAAGv//fz/9UEABAAAAAAABABR+/78/f9ZYv/8/P/2QwAEAAAAAAAAAAUAUvz+/f////78//hGAAUAAAAAAAAAAAAFAFL9/v3//v3/+EgABQAAAAAAAAAAAAAABQBT/P78/P75SwAEAAAAAAAAAAAAAAAAAAQAVP3///tOAAUAAAAAAAAAAAAAAAAAAAAEAE7U2EwABAAAAAAAAAAAAAAAAAAAAAAAAwABAwACAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["chevron-small-up"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAgAQEQACAAAAAAAAAAAAAAAAAAAAAAAEAGXo6mIABAAAAAAAAAAAAAAAAAAAAAQAaf////9jAAUAAAAAAAAAAAAAAAAABABp//z8/Pz/YQAFAAAAAAAAAAAAAAAEAGj//P3///39/14ABQAAAAAAAAAAAAQAZ//8/P/6/P/8/f9bAAQAAAAAAAAABABn//38//pETf7+/P3+WAAFAAAAAAAEAGf//Pz++k4AAFX9/vz+/lUABQAAAAAAZP/9/P77TwAEBQBU/P78/v1RAAAAAABk//38/vtPAAQAAAUAU/z+/P76TQAAAAD4/fv++1AABQAAAAAFAFL7/vr+5QAAAADz///8UQAEAAAAAAAABABR/P//7gAAAABP1tdNAAQAAAAAAAAAAAQAStPZUwAAAAAAAgIAAgAAAAAAAAAAAAADAAEDAAAAAAADAAADAAAAAAAAAAAAAAAAAwAAAgAAAAAAAQEAAAAAAAAAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["chevron-large-left"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQIAmtg3AAIAAAAAAAAAAAAAAAAAAAABAgCd//9+AAQAAAAAAAAAAAAAAAAAAAECAKL//9IYAQEAAAAAAAAAAAAAAAAAAQIAo///1RkAAgAAAAAAAAAAAAAAAAABAgCk///WGgADAAAAAAAAAAAAAAAAAAICAab//9caAAMAAAAAAAAAAAAAAAAAAQIBp///1xsAAwAAAAAAAAAAAAAAAAABAAGp///YHAADAAAAAAAAAAAAAAAAAAECBar//9ocAAMAAAAAAAAAAAAAAAAAAAMAkf/7zxsAAwAAAAAAAAAAAAAAAAAAAAQAnv/7wgkBAgAAAAAAAAAAAAAAAAAAAAECDsD//8YOAAIAAAAAAAAAAAAAAAAAAAABAAvA///FDgACAAAAAAAAAAAAAAAAAAAAAgALwP//xQ4AAwAAAAAAAAAAAAAAAAAAAAIAC8D//8UOAAIAAAAAAAAAAAAAAAAAAAACAAvA///FDgACAAAAAAAAAAAAAAAAAAAAAgALwP//xg8AAQAAAAAAAAAAAAAAAAAAAAIAC8H//8USAgEAAAAAAAAAAAAAAAAAAAACAAu8//97AAQAAAAAAAAAAAAAAAAAAAAAAgAMwfFCAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["chevron-large-right"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAXdtxAAQAAAAAAAAAAAAAAAAAAAAAAAQAt///cgAEAAAAAAAAAAAAAAAAAAAAAAIBNu7//3YABAAAAAAAAAAAAAAAAAAAAAACADnw/v93AAQAAAAAAAAAAAAAAAAAAAAABAA68f7/eAAEAQAAAAAAAAAAAAAAAAAAAAQAO/H+/3oABAAAAAAAAAAAAAAAAAAAAAAEADzy/v97AAQBAAAAAAAAAAAAAAAAAAAABAA88v7/fQADAAAAAAAAAAAAAAAAAAAAAAQAPvT//34AAgAAAAAAAAAAAAAAAAAAAAAEADjo+/9eAAMAAAAAAAAAAAAAAAAAAAADACHi+/9oAAQAAAAAAAAAAAAAAAAAAAQAKef//5YBAgAAAAAAAAAAAAAAAAAABAAq5f//lgACAQAAAAAAAAAAAAAAAAAEACnl//+WAAMBAAAAAAAAAAAAAAAAAAQAKuX//5cAAwEAAAAAAAAAAAAAAAAABAAq5f//lwADAQAAAAAAAAAAAAAAAAACACrl//+XAAMBAAAAAAAAAAAAAAAAAAIBKeX//5gAAwEAAAAAAAAAAAAAAAAAAAQAs///lAADAQAAAAAAAAAAAAAAAAAAAAMAbPWZAAMBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["heart"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQIAAAAAAAADAwAAAAAAAAIBAAAAAAABAAAycot9TQoAAApNfYtyMgAAAQAAAAAADKP//////91RUd3//////6MMAAAAAAAFuf/9+/v7/P/////8+/v7/f+5BQAAAABz//r///////3+/v3///////r/cwAAAADb/f3///////////////////392wAAAAD7////////////////////////+wAAAAD6////////////////////////+QAAAADY/v3///////////////////3+2AAAAACI//z///////////////////z/iAAAAAAc8P3+/////////////////v3wHAAAAAAAcf/6////////////////+v9xAAAAAAADAbb/+v/////////////6/7YBAwAAAAABAQ7L//r///////////r/yw4BAQAAAAAAAgATxv/6/v/////++v/GEwACAAAAAAAAAAIAC6r//vz///z+/6oLAAIAAAAAAAAAAAACAAB4+//7+//7eAAAAgAAAAAAAAAAAAAAAQIAOcr//8o5AAIBAAAAAAAAAAAAAAAAAAADAANkZAMAAwAAAAAAAAAAAAAAAAAAAAAAAwAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["clock"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAApdr9/z8tunUwMAAwAAAAAAAAAAAQIAVtX//////////8pGAAMAAAAAAAABAwCQ///9/f78/P78/f//egADAAAAAAADAJH/+/3///////////z8/3cAAwAAAAAAVP/6/v///f+Lnv/8///++/88AAAAAAAM3v79/////f8hQf/8/////P/IAwAAAABj//3//////f8xTv/8//////3/RQAAAAC6/vz//////f8uS//8//////z+mwAAAADp//7//////f8wT/38//////3/0AAAAAD8/////////f8nQ//7//////7/5gAAAAD9/////////P98AJb//f////7/5wAAAADr//7///////3/bgCR//z///3/0QAAAAC9/vz///////79/2hc//z///z+nwAAAABo//3////////+/v////////3/SgAAAAAP4/39//////////3+/////P7OBAAAAAAAXP/6///////////////++/9DAAAAAAADAJv/+v3///////////37/4EAAwAAAAABAwGb///9/f7///79/f//hQADAAAAAAAAAQEAYN3//////////9NQAAMAAAAAAAAAAAECABBpu+n8++WzXwkAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["key"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAMeLhZgAAAwAAAAAAAAAAAAAAAAAABAAu5f///7YfAAMAAAAAAAAAAAAAAAADAC7q//z+/P/nOAADAAAAAAAAAAAAAAIALun//P/9//n/8TQAAgAAAAAAAAAAAgEg6P/8///////8/+UXAgAAAAAAAAAABABg//r//vlmKrH/+f+uAAAAAAAAAAAABABg/vv8/88AAC///Pz/UAAAAAAAAAAABAJY//v+/vJGEJb//P380QAAAAAAAAAABgCB//v//v/+6v////v/sgAAAAAAAAAEAGT9/f////7///3/+/+8DgAAAAAAAAUAYv/9/v/////+/v/7/8ALAAAAAAAABABh//z+/////vz9/fv/wQwAAgAAAAAFAGD//f7////7//////+9DAACAAAAAAAAXP/9/v//////71hDQz4EAAIAAAAAAABg/v3+///+++2rNgAAAAAAAQAAAAAAAAD7//7////8/7kAAAMDAwMBAAAAAAAAAAD//v////73gjsEBAAAAAAAAAAAAAAAAAD+/v//+//fAAABAAAAAAAAAAAAAAAAAAD//////+49BAQAAAAAAAAAAAAAAAAAAACT8PLz4EEAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["flag"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACZsAAka7fZy4QWAAAAAAY5gVcAAQAAAACM+rvy///////gdUJTldb+//8rAAAAAAA3/////f3+/fz/////////+/gjAAAAAAAJ3vz8///////9+/38+/37/7AAAwAAAAAApf/7///////////////9/0oABAAAAAAAY//7//////////////3/2wADAQAAAAAAJvz+/v////////////799VwABAAAAAABAtX//f/////////////+//5MAAAAAAAEAJb/+/78/P3//////////f7zPQAAAAAEAFL//P/////8/v////78/Pz/lgAAAAACABn0/+/FueT///z8/f////vCKAAAAAAAAgDPzxUAAA105////+2yaigAAAAAAAAABACJ8gIBAwAAEUheRhUAAAABAQAAAAAAAwA+/zsAAwEDAAAAAAACBAIAAAAAAAAAAQAK+IMABAAAAQMEAwEAAAAAAAAAAAAAAAMAwNAAAgAAAAAAAAAAAAAAAAAAAAAAAAQAc/0SAAEAAAAAAAAAAAAAAAAAAAAAAAIALf9LAAQAAAAAAAAAAAAAAAAAAAAAAAEAA/GiAAQAAAAAAAAAAAAAAAAAAAAAAAADAJigAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["tag"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABQBZ3+jq6urq6ejjbwAAAAAAAAAAAAAEAFX6////////////6gAAAAAAAAAAAAUAV//+/f7+/v/+//7+6QAAAAAAAAAABQBW/v3+///+/+guVvz/6AAAAAAAAAAFAFb+/f7////9/9oAIfr/6AAAAAAAAAUAVv79/f///////v/R4v//6QAAAAAABABW/v3+//////////////7/6QAAAAAFAFb+/f3////////////9/f7/6AAAAAAAVP79/f////////////////7+6QAAAABW/P79//////////////////3/6AAAAAD1/v3//////////////////v79WgAAAACw//v////////////////+/f9YAAAAAAAJs//7//////////////79/1oABQAAAAAABrf/+v///////////v3/WgAFAAAAAAACAQe3//v////////+/f9bAAUAAAAAAAAAAgAHt//6//////79/1sABQAAAAAAAAAAAAIAB7j/+////v3/XAAEAAAAAAAAAAAAAAACAAe5//v+/v9cAAUAAAAAAAAAAAAAAAAAAgAHtf///FsABQAAAAAAAAAAAAAAAAAAAAIACbXtXwAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["photo-camera"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQMCBAIKbH99fX9oBgIDAgIBAAAAAAACAAAAAACv////////oQAAAAAAAgAAAAAAEzU4Nn3/+fv7+/v6/3E2ODQPAAAAAABV6P/////+/////////v/////jSQAAAADx//3+/v3//v/7/P7///3+/vz/4wAAAAD//v/////////////+/f/////99AAAAAD+//////z/kS1sreT/////////8gAAAAD///////7/MAAAAA4+w/79////8wAAAAD//////f/iCQIFAwEAkf/7////8wAAAAD/////+/+pAAMAAQEG2f/9////8wAAAAD/////+/9gBAgCAwAq/f7/////8wAAAAD//////f8/AAAABANo//v/////8wAAAAD//////v7moV8lAACu//v/////8wAAAAD+///////////6zKX3//7/////8gAAAAD//P3+/v/++/z////////+/v389wAAAADX//////38/Pv6+fj7/P3/////xAAAAAAmrdzx////////////////79qkHAAAAAAAAAQVKT1NWWFlZWFYTDsoFAMAAAAAAAACAwAAAAAAAAAAAAAAAAAAAAADAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["image"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+kpmZmpqampqampqampqamZmSPgAAAAD4+ubo5+jo5+fn5+fn5+fn6Ob6+AAAAAD/awAAAAAAAAAAAAAAAAAAAABr/wAAAAD+cAAEAAcAAAAAAAAAAAAABABw/gAAAAD/cAACR96vDAIBAQQFAQAABABw/wAAAAD/cAAArP//MQADAgAAAAEABABw/wAAAAD/cAABOc2cBwIEAFZ4BwACBABw/wAAAAD/cAAFAAAAAAUAdP//ugkABgBw/wAAAAD/cAEGAAMCBQBz//v4/7oIAwFw/wAAAAD/cgAABQAEAHH//P7/+/+5CQBz/wAAAAD/agCm3mIAcf/8/v////v/uwBq/wAAAAD/dKH///+q//7+///////6/6R0/wAAAAD/8v/8/f///v///////////f/z/wAAAAD///3////8//////////////3//wAAAAD+/v/////////////////////+/gAAAAD/+/v7+/v7+/v7+/v7+/v7+/v7/wAAAAD9/////////////////////////AAAAABJmpydnZ2dnZ2dnZ2dnZ2dnZyaSQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["cloud"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEEBAQEBAEAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAADAAAAAAAAAAAAAAAAAAADAAVQjqSTWgwAAwAAAAAAAAAAAAAAAAMAPND//////95RAAMAAAAAAAAAAAAAAwBA+P/7+/v7+///XQADAAAAAAAAAAABARDl//v///////z9+CUEBgIAAAAAAAAEAG//+//////////7/5IAAAADAAAAAAADAbv+/P/////////+/uyfficAAgAAAAABANH//f////////////////dkAAAAAAAAA9b+/f////////////77+v//RwAAAAAVwv79//////////////////z+ywAAAACo//3/////////////////////+gAAAAD4/f/////////////////////++wAAAAD7/P7///////////////////v/wwAAAACT//37/f////////////79+v/0MwAAAAAEkv/////8+/v7+/v7/P///9o8AAAAAAAAADma3v////////////fHbw0AAgAAAAAAAgAACC9Wd4yYmItyTSEAAAACAAAAAAAAAAIDAAAAAAAAAAAAAAABBAEAAAAAAAAAAAAAAQIEBAQEBAQEBAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["sun"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAwComgADAAAAAgAAAAAAAAAAAAAAAgAAAgDYyAADAAABAAAAAAAAAAAAAAopAAAAAgCZjQADAQAAKwMAAAAAAAADAD7/bAIDAwIAAAMDAgWS/x0AAgAAAAAAAgWW/xUCAAAKCAAAAjX/cAICAAAAAAAAAAAAJgMAVbvi369AAAklAAAAAAAAAAAAAAABAACO////////agAAAgAAAAAAAAADAwMEAlv/+vz+/fv9/zYCAwMDAwAAAAAAAAABAs/9/P/////7/6YAAwAAAAAAAACju4MAF/L//v/////9/tUBA5S7kQAAAACyzI8AGPP//v/////9/9YAA6HMnwAAAAAAAAABAtH9/P/////7/qkAAwAAAAAAAAADAgIEAWD/+vz+/vv8/zoCAwMCAwAAAAAAAAABAACW////////cgAAAgAAAAAAAAAAAAAAHgIAXcPp5rhHAAgdAAAAAAAAAAAAAgOM/BUBAAAQDgAAAjX/ZwECAAAAAAADAD3/dgIDBAEAAAIDAgec/x0AAgAAAAABAA0zAAAAAgCPgwADAQAANQUAAAAAAAAAAAAAAgAAAgDYyAADAAAAAAAAAAAAAAAAAAEDAAAAAwCyowADAAABAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["moon"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAK77sOQADAAAAAAAAAAAAAAAAAAAAAwBS7f//owAEAAAAAAAAAAAAAAAAAAADAFT///j+mwAEAAAAAAAAAAAAAAAAAAABJvb+/fv/fQAEAAAAAAAAAAAAAAAAAAAAtf/7//v/gQAEAAAAAAAAAAAAAAAAAAA6/v3///v/oQADAAAAAAAAAAAAAAAAAACa//z///3/3AQBAAAAAAAAAAAAAAAAAADY//3////9/0cABAAAAAAAAAAAAAAAAAD2///////8/swBAwIAAAAAAAAAAAAAAAD//////////P+QAAIDAQAAAAAAAAAAAAD2//////////z/jwMAAAMEBAQEAgAAAADZ//7////////8/8hLBgAAAAAAAAAAAACc//z//////////P//2aOCfpyeNgAAAAA9//3///////////39////////8AAAAAAAuP/7/////////////fv7+/j+uwAAAAABKfj9/f///////////////f7vIgAAAAADAFj///v////////////7//9LAAAAAAAAAwBZ9v/+/P7////+/P//8lIAAwAAAAAAAAMALbT+//////////yvKAADAAAAAAAAAAADAABAmdf0/vTVljwAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["trophy"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAis7Mzs7Ozs7Ozc+wEAAAAAAAAAANUVZy////////////////oVVVFQAAAADA/////v39/f39/f39/f39////2QAAAADyuCA/+v/+//////////z/eCCf/wAAAACo6AAM8f/+//////////z/TQDQywAAAABd/yYE5//+//////////3/Owr+fQAAAAAe/2MC3P/9////////////Izz/NwAAAAAA4bMAyv/8/////////v/+BIn2BwAAAAAAf/8pe/77/////////f/EF/WjAAAAAAACDMz/w//9/////////f7Z7uYcAQAAAAABAA+T6vz//v/////+/f/trCAAAQAAAAAAAQAABjn0//3///77/20LAAABAAAAAAAAAAEDAABG9v/+//7/ggAAAwIAAAAAAAAAAAAAAQQAQOj+/Pt3AAQBAAAAAAAAAAAAAAAAAAAGAE/6/5EAAgEAAAAAAAAAAAAAAAAAAAIAdef8/fGlCwEBAAAAAAAAAAAAAAAAAwBi////////qgACAAAAAAAAAAAAAAABAAvn+/n8/Pv3/zwAAwAAAAAAAAAAAAABARHg////////+0MAAwAAAAAAAAAAAAAAAQAeYo+rsJpyNwABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["bug"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAQAAAAIAHK/08qkWAAEAAAABAgAAAAAAAAAAAQEL0P/////GBgIBAAAAAAAAAAAbBwAABAB1/+fV1+n/ZQAEAAAKGAAAAADzYgAEAgNDLQAAAAAzQAMCBACB6wAAAAD/bgQIAwAARpEaN4s6AAADCASO/wAAAAD/dgAAAFXc//8qWv//z0QAAACX/QAAAADA/qWXqP//+/snU/v4//+hman/oAAAAAATnd3+//39/v8nVP/7/f7/99yNCQAAAAAAAA3g+/3//v8nVP/7//z7yAAAAAAAAAAFA3H/+////v8nVP/7///9/0kDBAAAAAADALn+/P///v8nVP/7///7/pAABAAAAAAAAdf//f///v8nVP/7///8/7MAAwAAAAAABdz//f///v8nVP/7///8/7kDAwAAAAADALj+/P///v8nVP/7///7/osABgAAAAAAZOv//v///v8nVP/7///9/9lQAAAAAACE/8P4/f7//v8nVP/7//7+7cr/YgAAAAD8mwCI//n+/v8nVP/7/vr/YAC66QAAAAD/bgIFr///+/4nVP34//+OAAGR/wAAAABuJwABA4n3//8nVf//7XAAAwA1ZQAAAAAAAAABAAAzldokTtSGIwACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["wallet"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGjw5OTk5OTk5OTk5OTcGAAEAAAAAAABZ6v/////////////////WDwMCAAAAAAD0//14TE5MTExMTExMS0xUBgAAAQAAAAD//fxHEhYUFBQUFBQUFBQSISQHAAAAAAD+////////////////////+/zSGgAAAAD////+//////////////////7/ZAAAAAD//////v7+/v7+/v7+/v7+/vv9kgAAAAD////////////////+/Pz7/v3/uAAAAAD///////////////////////3/0wAAAAD//////////////v7xX0yQ7P7/5QAAAAD/////////////+/+aAAAATf//7wAAAAD//////////////P9QBw0HO///8wAAAAD//////////////P9bAAAAgv/+8AAAAAD//////////////v7ui0ZN5v7/6AAAAAD///////////////////////3/1wAAAAD////////////////++/39/v3/vQAAAAD9//////////////////////z+mQAAAAD//v7+/v7+/v7+/v7+/v7+/vv/bQAAAADA///////////////////////nJAAAAAAKRUpKSkpKSkpKSkpKSkpKSUofAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["shopping-cart"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADz//ZgBAcEBQUFBQUFBQUFBQUEAQAAAACNpu/eAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJr/iICBgICAgICAgICAgIByFQAAAAAIA2P+////////////////////wgAAAAADADH++vr7+/v7+/v7+/v7+/r74wAAAAABAArm//3///////////////z/nAAAAAAAAgC4//z///////////////3/UwAAAAAABACD//v//////////////v/tFgAAAAAAAwBN//z//////////////P64AAAAAAAAAgAe+P/7+/v7+/v7+/v79/53AAAAAAAAAAEC1P////////////////8tAAAAAAAAAAQAo/6ZkZKSkpKSkpKQkU0AAgAAAAAAAAQAa/82AAAAAAAAAAAAAAABAAAAAAAAAAIAI/r70NLR0dHR0dDRySsAAgAAAAAAAAACAEnK5OLj4+Pj5Ofl3C4AAgAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAC6FQAABAAEAFYBeAAIAAAAAAAAAAAEBDeH/+SQBAgMAtP//UgADAAAAAAAAAAEAE/P//y8AAwIAxf//YQAEAAAAAAAAAAACAF3MegACAAIAMr2XCAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["phone"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5buzSsBAgAAAAAAAAAAAAAAAAAAAAAWtv/+/8oCAgEAAAAAAAAAAAAAAAAAAADE//v/+/9eAAQAAAAAAAAAAAAAAAAAAAD//f///f7gDQEBAAAAAAAAAAAAAAAAAAD6//////z/UgAEAAAAAAAAAAAAAAAAAADs//7///v/PQADAAAAAAAAAAAAAAAAAADN//3/+v+RAAIAAAAAAAAAAAAAAAAAAACX//z7/5UAAgEAAAAAAAAAAAAAAAAAAABN//z/lgADAQAAAAAAAAAAAAAAAAAAAAAL3v6SAAMBAAAAAAAAAAAAAAAAAAAAAAAAf/8fAgMAAAAAAAAAAAMDAQAAAAAAAAABEvW2AAQAAAAAAAAAAQAAAAMAAAAAAAADAGn/XwAFAAAAAAEBAENSCgABAgAAAAAAAwCz/zkABQAAAQIAmf//2l8AAAAAAAAAAQIO0/c6AAMDAgCc//v7///DKQAAAAAAAAIAGNP/XwAAAJz/+v///fr/ygAAAAAAAAACABCy/7MumP/6//////778QAAAAAAAAAAAgAAbPj///z8/f7///v/jAAAAAAAAAAAAAEBABaB2v///////f+vAgAAAAAAAAAAAAAABAAADE+WzOv6+7sPAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["envelope"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA9jI+Pj4+Pj4+Pj4+Pj4+Pj4+MPQAAAAD6////////////////////////+gAAAAD4//n5+/v7+/v7+/v7+/v7+fn/+AAAAAAZqf//+/7///////////77//+pGQAAAAA8AEna///8/////////P//2kkAPAAAAAD/phEAg/r//P3///38//qDABGm/wAAAAD9/+9sACO5///7+///uSMAbO///QAAAAD//P//yTMAWOT//+RYADPJ///8/wAAAAD///78//+WBwSZmQQHlv///P7//wAAAAD//////f7/5lwAAFzm//79/////wAAAAD////////7//+9vf//+////////wAAAAD//////////v3///3+/////////wAAAAD////////////8/P///////////wAAAAD//////////////////////////wAAAAD9/////////////////////////QAAAAD///37+/v7+/v7+/v7+/v7+/3//wAAAADC////////////////////////wgAAAAADK0ZcbX2Hj5SWlpSPh31tXEYrAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["microphone"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgBn3/3+/vrTTQACAAAAAAAAAAAAAAADAGP/////////+j8AAwAAAAAAAAAAAAEBCOT+/P/////6/78AAgAAAAAAAAAAAAIAH/r//v/////9/t8EAAEAAAAAAAAAAAIAIPr//v/////9/98GAAEAAAAAAAAAAAIAIPr//v/////9/98GAAEAAAAAAAAAAAIAIPr//v/////9/98GAAEAAAAAAAAAAAIAIPr//v/////9/98GAAEAAAAAAAAAAAIAIPr//v/////9/98GAAEAAAAAAAAAAAIBHvn+/v/////9/t4EAQEAAAAAAAAAAAAAB9v/+f39/f34/7QAAAAAAAAAAAAAAAIdAFX/////////9TMAHAAAAAAAAAACACv9UwBGudnb29etLgB/9w0AAQAAAAABAge2/2MAAAAAAAAAA4D/jwIDAAAAAAAAAQAJpv/xysO2ucTO+v+HAAEBAAAAAAAAAAEAAD6Xv8T/9sO9ii4AAQAAAAAAAAAAAAABAgAAAADUpgAAAAADAAAAAAAAAAAAAAAAAAMAAADXpwAAAAIAAAAAAAAAAAAAAAAAAgA1cW/q0W9xJAABAAAAAAAAAAAAAAAABACV////////aAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["headphones"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAADWY4P////3WhiUAAAEAAAAAAAAAAgAXpP//yqOamqjT//+IBwABAAAAAAACACrj/4YcAAAAAAAAKqH/xBEBAQAAAAACFeLwOAAAAgQEBAMBAABW/8AEAwAAAAAArP80AAYCAAAAAAAAAgUAWv97AAAAAAA4/4IABgAAAAAAAAAAAAAFALP2FQAAAACl9xACAgAAAAAAAAAAAAADAjP/bQAAAADvvgACAAAAAAAAAAAAAAABAALpuwAAAAD/kQEEAAAAAAAAAAAAAAAAAgDE4gAAAAD+igQIAQAAAAAAAAAAAAACBwS86gAAAAD/gAAAAAEAAAAAAAAAAAIAAAC26wAAAAD/wHhrEwACAAAAAAAAAgAkcnjc4gAAAAD/////1xMBAgAAAAADAC/v////2QAAAAD//fv5/7kAAwEAAAEBEdv/+fr+2gAAAAD0////+v+LAAMAAAIDtf/7//3/zQAAAADJ/v3//vz/NwADBABh//r///z/mAAAAABi//v///v/YAAEBACQ/Pv//vz+NQAAAAAEwf/6/vz4IAACAwBF//v++v+WAAAAAAABGdH//v+YAAMAAAIBxf///7MHAgAAAAACABKg6a4QAgEAAAIBJMXmhQMAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["speaker"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAQCAAAAAAAAAAAAAAMAWop9GAABAAAAAAAAAAAAAAAAAAAABQB4////ogAEAAAEAWUoAQAAAAABAwMGAGb/+vf7uAADAAAAAfS1AAAAAAAAAAAAVv/8/vz/tAADAQNFBHT8GQAAAAARSEpm+v7+//z/tQAEABf/WRD/aQAAAADS//////7///z/tQAEDwHXvADitwAAAAD//Pz8/v////z/uABW5gCN9gCp7QAAAAD9//////////z/uABN/x1X/wR//wAAAAD///////////z/twAt/jg//xNq/wAAAAD///////////z/twAt/Tc//xJq/wAAAAD9//////////z/uABP/xxY/wSA/wAAAAD//Pz8/v////z/uABV4QCP9QCr6wAAAADV//////////z/tQADCwHZugDktQAAAAATTE1r/P7+//z/tQAEABf/VhL/ZwAAAAAAAAAAXP/7/vz/tAADAQM+A3n7FwAAAAABAwMGAHD/+vj7twADAAAAAfWxAAAAAAAAAAAABACE////qQAEAAADAV4lAQAAAAAAAAAAAQMAa52QIQABAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAQCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["x"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACE98AQAAIAAAAAAAAAAAMAG832cAAAAAD//v/BDgACAAAAAAAAAwAY0P//8gAAAADE//j/xQ4AAgAAAAADABjU//j/rgAAAAATxv/3/8MNAAIAAAMAF9L/9/+2CgAAAAAAEMn/9//CDQACAwAX0v/2/7oIAAAAAAADABLK//f/wQwBABbR//f/uggAAgAAAAAAAwASy//3/8EFEND/9/+7CQACAAAAAAAAAAMAEsv/+P+9yP/3/7wJAAIAAAAAAAAAAAADABPO//v///v/vQoAAgAAAAAAAAAAAAAAAgAQxf76+v+1CAECAAAAAAAAAAAAAAAAAgAQxf76+v+1CAECAAAAAAAAAAAAAAADABPO//v///v/vQoAAgAAAAAAAAAAAAMAEsv/+P+9yP/3/7wJAAIAAAAAAAAAAwASy//3/8EFEND/9/+7CQACAAAAAAADABLK//f/wQwBABbR//f/uggAAgAAAAAAEMr/9//CDQACAwAX0v/2/7oIAAAAAAATxv/3/8MNAAIAAAMAF9L/9/+2CgAAAADE//j/xQ4AAgAAAAADABjU//j/rgAAAAD//v/BDgACAAAAAAAAAwAY0P//8gAAAACE98AQAAIAAAAAAAAAAAMAG832cQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["pin"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwBZ20AAAwEAAAAAAAAAAAAAAAAAAAAAAwIg5fdqAAIBAAAAAAAAAAAAAAAAAAADAABs7P3/kgACAQAAAAAAAAAAAAAAAAQAE6z///77/6YCAQEAAAAAAAACAQABAwA93P/7/v//+v+sAgIBAAAAAAAAAAMAAHL7//v///////r/pAADAQAAAAAzCwAUq//+/f/////////6/48ABAAAAAD/u0fd//v+////////////+v9kAAAAAABX/////P///////////////v/9OQAAAAAATvv8/v/////////////+/u7p4wAAAAAFAFP9/v3////////////7/14kUgAAAAAABABT/f/+//////////v/pAAAAAAAAAAAAAQAVu76/f///////f/YDAIDAwAAAAAAAAEGAK///f7////+/PkyAAMAAAAAAAAAAQQAjP+s+P/9///7/2kABAAAAAAAAAABBACH/4cAVv39/vz/pwAEAAAAAAAAAAAEAIb/ggAGAFb9/f7ZDgIBAAAAAAAAAAAAg/+DAAQBBQBV/v83AAQAAAAAAAAAAACS/4EABAEAAAQAUvm0DwIBAAAAAAAAAAD4kQAEAQAAAAAFAFz7LAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["circle-i"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAApdr9/z8tunUwMAAwAAAAAAAAAAAQIAVtX//////////8pGAAMAAAAAAAABAwCQ///9/f78/P78/f//egADAAAAAAADAJH/+/3///////////z8/3cAAwAAAAAAVP/6/v///f9nff/9///++/88AAAAAAAM3v79/////f1NZ//8/////P/IAwAAAABj//3///////////////////3/RQAAAAC6/vz///3/1Co2f//9//////z+mwAAAADp//7///3/21EETP/8//////3/0AAAAAD8//////////80Tf/8//////7/5gAAAAD9/////////PstTP/8//////7/5wAAAADr//7/////+/stS/v6//////3/0QAAAAC9/vz///////8yUv////////z+nwAAAABo//3///3/x5saLZvS//3///3/SgAAAAAP4/39//v/dAAQDgCR//v//P7OBAAAAAAAXP/6////9u7s7O74///++/9DAAAAAAADAJv/+v3///////////37/4EAAwAAAAABAwGb///9/P3+/v38/f//hQADAAAAAAAAAQEAYN3//////////9NQAAMAAAAAAAAAAAECABBpu+n8++WzXwkAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["circle-question"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAARSotTq6c+aRwAAAwAAAAAAAAAAAAIATMz//////////8E9AAMAAAAAAAABAwCG///9/Pv6+vr8/v//cQAEAAAAAAADAIn/+/3//f///////vz9/28AAwAAAAAAT//6/v///8SAdKX4//7+/P83AAAAAAAK2/79//32aAAAAAA88v7+/P/EAgAAAABf//3//v7sHS/E0EgAqf/7//3/QgAAAAC4/vz///7/7+///50Anf/7//z/mQAAAADo//7////+////1h0O4v79//3/zwAAAAD8////////+/3QFA7C//3///7/5gAAAAD9/////////f8jANb//P////7/5wAAAADr//7////+//5iiv/7//////3/0gAAAAC+/v3///////////3///////z+oAAAAABp//3////+/+8tU//+//////3/SwAAAAAP5P39///+/+sFMv/+/////P7PBQAAAAAAXv/6//////7t8P/////++/9EAAAAAAADAJz/+v3///////////37/4MAAwAAAAABAgGc///8/f7+/v79/f//hgADAAAAAAAAAQEAYd3//////////9NRAAMAAAAAAAAAAAECABFqu+n8++WzYAkAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["triangle-exclamation"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgNycgMCAQAAAAAAAAAAAAAAAAAAAAADAH///38AAwAAAAAAAAAAAAAAAAAAAAIBI/f6+vcjAQIAAAAAAAAAAAAAAAAAAAMAsv/8/P+yAAMAAAAAAAAAAAAAAAAAAwBL//z9/fz/TAADAAAAAAAAAAAAAAABAwja/v3///3+2gkDAQAAAAAAAAAAAAADAH3/+f9+cf/5/30AAwAAAAAAAAAAAAIBIfX9+/86Kv/8/fUhAQIAAAAAAAAAAAMAr//8/P9HOf/9/P+vAAMAAAAAAAAAAwBI//z//P9AMf/9//z/SAADAAAAAAABAgfY/v3//P9VRv/8//3+2AcCAQAAAAAEAHr/+//////////+///7/3oABAAAAAABHvT9/v///v+4rP7+///+/fQeAQAAAAAAqP/8///+//IAAOH//f///P+oAAAAAABL//3//////v2IePn+//////3/SgAAAADf+/n7+/v7+/v///z7+/v7+/n73wAAAADi////////////////////////4gAAAAAlfIKDg4ODg4ODg4ODg4ODg4J8JQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["calendar"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgYCKe83AgQBAQQCOe0eAgUCAAAAAAABAAAAMv9DAAAAAAAARP8lAAAAAQAAAAAAMafE0v7WxsfHx8fG1v7Pw6MpAAAAAAAr7/////3///////////3////nIQAAAACg////////////////////////jgAAAACf4+Hk5OTk5OTk5OTk5OTk5OHjkQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABgi4mLi4uLi4uLi4uLi4uLi4mLVwAAAAC9////////////////////////rAAAAACt+/j7////+/v///v7///++/j7nQAAAACw//v/63Dj//+Vlf//4XLx//v/oAAAAACw//v/4C/T//9jY///0TLo//v/oAAAAACw//z///////////////////z/oAAAAACw//z///////////////////z/oAAAAACw//z//Nn6///l5f//+tr9//z/oAAAAACv//r/1gDH//88PP//xQDh//r/nwAAAACx/vz/+cP2///V1f//9cX7//z+oQAAAACj//n9///////////////+/fn/kgAAAAA28//////////9/f/////////tLAAAAAAAOqHC1+jx+P3///z48efWwJ4yAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["hashtag"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEL3cQEAQIAHu2dAAIAAAAAAAAAAAAAAgAu/+YHAAQAUv/DAAIAAAAAAAAAAAAABABQ/r0AAgQAdv6WAAQAAAAAAAAABAQECAR1/5sECAgEnf9zBAgEAwAAAAAAAAAAAACX/2IAAAAAwP86AAAAAAAAAAAHZIB+gH/d/6d+gX+C7v6Wf39/RwAAAAA4////////////////////////9QAAAAAJbIaGhpf+9YyGiIam/uWHhoWGTwAAAAAAAAAAAC3/zgAAAABU/6cAAAAAAAAAAAAABAQIBGX/qwQHCASM/4QECAQEAwAAAAADBAQIBIf/iAQIBgOv/2EECAQEAQAAAAAAAAAAAKv/UgAAAADS/ysAAAAAAAAAAABgm5qcnOr+tZudm6H3/qmbm52BDQAAAADy////////////////////////NwAAAAA1aWlphf7qa2lraZn/1WlqaGlRBAAAAAAAAAAAPf+8AAAAAGb/kwAAAAAAAAAAAAACBAgEdf+YBAgIBJ3/cQQIBAQDAAAAAAAAAAQAl/5yAAQCAL7+TAADAAAAAAAAAAAAAAIAxf9NAAQAB+n/KgACAAAAAAAAAAAAAAIAj9oXAAIBA7TICAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["robux"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAHKP/94sNAAADAAAAAAAAAAAAAAMBAAl5+feUof/pYQAAAgIAAAAAAAAAAgAAXOj/mxYAACmz/9RFAAACAAAAAAACAD/M/7ovAAJpVQAARdD/tCsAAgAAAAAAdf/VSgAAUdL//7g1AABg6f9RAAAAAAAn/44AAC+y///+///7lBcACbbvDAAAAABZ/xwAavj/+/L19fL//+dAAEb/LAAAAABZ/yQB0P/1QhkbHBlw+/+YAU3+LQAAAABZ/yIAxv7xEQAAAAA///6TAEz/LQAAAABZ/yIAyP/yGwECBAFJ//+UAEz/LQAAAABZ/yIAyP/yHAIDBQJJ//+UAEz/LQAAAABZ/yIAx/7xDQAAAAA9//2UAEz/LQAAAABZ/yQBzf/2Vy4wMS6B+/+UAU3+LQAAAABZ/xwAVun//////////9MyAEX/LAAAAAAn/44AAByY+//8/v/seQkACbbvDAAAAAAAdf/VSgAAOrz//58hAABg6f9RAAAAAAACAD/M/7kxAABOPAAARdD/tCsAAgAAAAAAAgAAXOj/mxkAACqz/9RFAAACAAAAAAAAAAMBAAl5+feToP/pYQAAAgIAAAAAAAAAAAAABAAAHKP/94sNAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["discord"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQMEAgAAAAACBAMBAAAAAAAAAAAAAAADAAAAAAQDAwQAAAAAAwAAAAAAAAAAAAAABTh4LwAAAAA1dzcEAAEAAAAAAAAAAgJ62P//05atrJbY///WdwECAAAAAAAEAGj///77////////+/7//2YAAwAAAAABEOr8+////fv8+/v9///7/OoQAQAAAAAAc//7///9/v/////+/f//+/9yAAAAAAAF1f79//////7///7///7//f7UBQAAAAA9/v7+///N7f/+/v/rzf///v7+PAAAAACF//z9/2gAIuH+/twdAGr//fz/ggAAAAC8//v/5gIFAIz//4EABQLm//v/uAAAAADd//3+8RcAAKn//6AAABfx/v3/2gAAAADu//79/7g/dvz+/vpzP7j//f7/6gAAAADv/v7///////39/f3///////797AAAAAD1//r+6dD//////////87q/vn/8QAAAABd5f//4X5gl8DU1MGWYYDj///iWQAAAAAAF43s/+wBAAAAAAAABfL/6ooVAAAAAAADAAAYcEABBgIAAAIGAENuFgAAAwAAAAAAAQMAAAABAAAAAAAAAQAAAAMBAAAAAAAAAAACBAIAAAAAAAAAAAIEAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["plus-small"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACADjZ1DEBAgAAAAAAAAAAAAAAAAAAAAADALf//6oAAwAAAAAAAAAAAAAAAAAAAAACAMX+/roAAgAAAAAAAAAAAAAAAAAAAAACAML//7cAAgAAAAAAAAAAAAAAAAAAAAACAMP//7gAAgAAAAAAAAAAAAAAAAAAAAACAMP//7gAAgAAAAAAAAAAAAACAwICAgIEAsT//7kCBAICAgIDAgAAAAAAAAAAAAAAAMD//7UAAAAAAAAAAAAAAAA+rbu6urq7uu///+y6u7q6ubynKgAAAADw////////////////////////zwAAAAD1////////////////////////1AAAAABFt8LDw8PEw/H//+7DxMPDwsKwMAAAAAAAAAAAAAAAAMH//7UAAAAAAAAAAAAAAAADAgICAgIEAsP//7kCBAICAgIDAgAAAAAAAAAAAAACAMP//7gAAgAAAAAAAAAAAAAAAAAAAAACAMP//7gAAgAAAAAAAAAAAAAAAAAAAAACAML//7cAAgAAAAAAAAAAAAAAAAAAAAACAMT+/rkAAgAAAAAAAAAAAAAAAAAAAAADALz//7AAAwAAAAAAAAAAAAAAAAAAAAADAEbt6j4AAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["minus-small"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAABA0MDAwMDAwMDAwMDAwMDA0EAAAAAABc2Ofm5+fn5+fn5+fn5+fn5ufYXAAAAAD7////////////////////////+wAAAADt////////////////////////7QAAAAA+uMfIycnJycnJycnJycnJyMe4PgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAgEBAQEBAQEBAQEBAQEBAQECAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["play-small"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAT/GpHwAAAwAAAAAAAAAAAAAAAAAAAAAAjf//6G4EAAMCAAAAAAAAAAAAAAAAAAAAiP74///MRgAABAEAAAAAAAAAAAAAAAAAif/7/vz//6MgAAADAAAAAAAAAAAAAAAAif/7///9/f/udQcAAwIAAAAAAAAAAAAAif/7//////z//89JAAAEAQAAAAAAAAAAif/7///////++///pyQAAAMAAAAAAAAAif/7//////////39//F7CAABAAAAAAAAif/7/////////////P//004AAgAAAAAAif/7//////////////77//9mAAAAAAAAif/7//////////////78//9iAAAAAAAAif/7/////////////P//zEYAAQAAAAAAif/7//////////3+/+xxBQABAAAAAAAAif/7///////+/P//nh4AAAMAAAAAAAAAif/7//////v//8dAAAAEAQAAAAAAAAAAif/7///8/v/oawIAAwEAAAAAAAAAAAAAif/7/vz//pcaAAEDAAAAAAAAAAAAAAAAiP74///COwAABAAAAAAAAAAAAAAAAAAAjf//4GMAAAMBAAAAAAAAAAAAAAAAAAAASOmcFgABAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["pause-small"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3397f397YOQADAwBg3t3f393fjQAAAAD/////////cQAEBACk////////3gAAAAD9/v7+/vr+bAAEBACd/vr+/v3+1QAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD///////v/bQAEBACe//v///7/1wAAAAD+//////v/bAAEBACd//v///7/1gAAAAD///////v/cQAEBACj//v///7/3AAAAADb//7///35SgADBAB3/vz///3/rQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State.iconMasks["stop-small"] = {
        w = 24,
        h = 24,
        a = [[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWpN3f4ODg4ODg4ODg4ODg39uKBQAAAAC5////////////////////////hQAAAAD//f7+/v7+/v7+/v7+/v7+/vz92QAAAAD+//////////////////////7/1gAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD///////////////////////7/1wAAAAD+//////////////////////7/1gAAAAD//f////////////////////392gAAAADP//3///////////////////3/nAAAAAAtzP3+/////////////////vqzEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA]]
    }
    State._pngFromMask = function(Mask, Width, Height, Red, Green, Blue)
        local Floor, Char, Byte, Concat, Sub = math.floor, string.char, string.byte, table.concat, string.sub
        local Xor, BitAnd, ShiftRight
        if bit32 then
            Xor, BitAnd, ShiftRight = bit32.bxor, bit32.band, bit32.rshift
        else
            Xor = function(A, B)
                local Result, Position = 0, 1
                for _ = 1, 32 do
                    local BitA, BitB = A % 2, B % 2
                    if BitA ~= BitB then
                        Result = Result + Position
                    end
                    A = (A - BitA) / 2
                    B = (B - BitB) / 2
                    Position = Position * 2
                end
                return Result
            end
            BitAnd = function(A, B)
                local Result, Position = 0, 1
                for _ = 1, 32 do
                    local BitA, BitB = A % 2, B % 2
                    if BitA == 1 and BitB == 1 then
                        Result = Result + Position
                    end
                    A = (A - BitA) / 2
                    B = (B - BitB) / 2
                    Position = Position * 2
                end
                return Result
            end
            ShiftRight = function(Value, Shift)
                return Floor(Value / 2 ^ Shift)
            end
        end
        local CrcT = State._crcT
        if not CrcT then
            CrcT = {}
            for Index = 0, 255 do
                local Crc = Index
                for _ = 1, 8 do
                    if BitAnd(Crc, 1) == 1 then
                        Crc = Xor(3988292384, ShiftRight(Crc, 1))
                    else
                        Crc = ShiftRight(Crc, 1)
                    end
                end
                CrcT[Index] = Crc
            end
            State._crcT = CrcT
        end
        local function Crc32(Text)
            local Crc = 4294967295
            for Index = 1, #Text do
                Crc = Xor(ShiftRight(Crc, 8), CrcT[BitAnd(Xor(Crc, Byte(Text, Index)), 255)])
            end
            return Xor(Crc, 4294967295)
        end
        local function Be32(Value)
            return Char(
                Floor(Value / 16777216) % 256,
                Floor(Value / 65536) % 256,
                Floor(Value / 256) % 256,
                Value % 256
            )
        end
        local function Le16(Value)
            return Char(Value % 256, Floor(Value / 256) % 256)
        end
        local Pixel = Char(Red, Green, Blue)
        local Value = {}
        local Offset = 0
        for _ = 1, Height do
            Value[#Value + 1] = Char(0)
            local Row = {}
            for _ = 1, Width do
                Offset = Offset + 1
                Row[#Row + 1] = Pixel .. Char(Byte(Mask, Offset) or 0)
            end
            Value[#Value + 1] = Concat(Row)
        end
        local Raw = Concat(Value)
        local SumA, SumB = 1, 0
        for Index = 1, #Raw do
            SumA = (SumA + Byte(Raw, Index)) % 65521
            SumB = (SumB + SumA) % 65521
        end
        local Adler = SumB * 65536 + SumA
        local ZIndex = {Char(120, 1)}
        local Position, Entry = 1, #Raw
        while Position <= Entry do
            local Char2 = Entry - Position + 1
            if Char2 > 65535 then
                Char2 = 65535
            end
            local IsFinal = Position + Char2 - 1 >= Entry and 1 or 0
            ZIndex[#ZIndex + 1] =
                Char(IsFinal) .. Le16(Char2) .. Le16(65535 - Char2) .. Sub(Raw, Position, Position + Char2 - 1)
            Position = Position + Char2
        end
        ZIndex[#ZIndex + 1] = Be32(Adler)
        local Compressed = Concat(ZIndex)
        local function MakeChunk(ChunkType, Payload)
            local Chunk = ChunkType .. Payload
            return Be32(#Payload) .. Chunk .. Be32(Crc32(Chunk))
        end
        return Char(137, 80, 78, 71, 13, 10, 26, 10) ..
            MakeChunk("IHDR", Be32(Width) .. Be32(Height) .. Char(8, 6, 0, 0, 0)) ..
                MakeChunk("IDAT", Compressed) .. MakeChunk("IEND", "")
    end
    local IconImages = {}
    if Base64Decode then
        for Key, Value in pairs(IconPngData) do
            local Success, Blue = pcall(Base64Decode, Value)
            if Success and Blue and Blue ~= "" then
                IconImages[Key] = Blue
            end
        end
    end
    State._rebuildIcons = function()
        local IconMasks = State.iconMasks
        if not IconMasks or not State._pngFromMask then
            return
        end
        local UsedIcons = {}
        for _, Kind in ipairs(State.tabs or {}) do
            if Kind.icon then
                UsedIcons[Kind.icon] = true
            end
            if Kind.subs then
                for _, Value in ipairs(Kind.subs) do
                    if Value.icon then
                        UsedIcons[Value.icon] = true
                    end
                end
            end
        end
        if State.settingsIcon then
            UsedIcons[State.settingsIcon] = true
        end
        local Accent = State._accentMid or NewColor(155, 132, 255)
        local AccentR, AccentG, AccentB = Accent.R * 255, Accent.G * 255, Accent.B * 255
        local Luma = 0.3 * AccentR + 0.59 * AccentG + 0.11 * AccentB
        local BrightR = MathFloor(Clamp(Luma + (AccentR - Luma) * 1.8, 0, 255) + 0.5)
        local BrightG = MathFloor(Clamp(Luma + (AccentG - Luma) * 1.8, 0, 255) + 0.5)
        local BrightB = MathFloor(Clamp(Luma + (AccentB - Luma) * 1.8, 0, 255) + 0.5)
        local IconGreyDone = State._iconGreyDone
        if not IconGreyDone then
            IconGreyDone = {}
            State._iconGreyDone = IconGreyDone
        end
        for Name in pairs(UsedIcons) do
            local Mask = IconMasks[Name]
            if not Mask and State.iconAlias then
                Mask = IconMasks[State.iconAlias[Name]]
            end
            if Mask then
                local Raw = Mask._raw
                if not Raw and Base64Decode then
                    local Success, Object = pcall(Base64Decode, Mask.a)
                    if Success and Object and Object ~= "" then
                        Raw = Object
                        Mask._raw = Object
                    end
                end
                if Raw then
                    if not IconGreyDone[Name] then
                        local Success, GreyPng = pcall(State._pngFromMask, Raw, Mask.w, Mask.h, 188, 191, 199)
                        if Success and GreyPng then
                            IconImages[Name] = GreyPng
                            IconGreyDone[Name] = true
                        end
                    end
                    local Success, CornerB = pcall(State._pngFromMask, Raw, Mask.w, Mask.h, BrightR, BrightG, BrightB)
                    if Success and CornerB then
                        IconImages[Name .. "#a"] = CornerB
                    end
                end
            end
        end
    end
    State._rebuildIcons()
    local Mouse, LocalPlayer, Players
    pcall(function()
        Players = game:GetService("Players")
    end)
    local function GetViewportSize()
        if State._vpW then
            return State._vpW, State._vpH
        end
        local X, Y = 1920, 1080
        pcall(function()
            local CurrentCamera = workspace.CurrentCamera
            if CurrentCamera then
                X = CurrentCamera.ViewportSize.X
                Y = CurrentCamera.ViewportSize.Y
            end
        end)
        State._vpW, State._vpH = X, Y
        return X, Y
    end
    local function UpdateMouse()
        if not Mouse then
            pcall(function()
                LocalPlayer = Players and Players.LocalPlayer
            end)
            pcall(function()
                Mouse = LocalPlayer and LocalPlayer:GetMouse()
            end)
        end
        if Mouse then
            State.mouseX = Mouse.X
            State.mouseY = Mouse.Y
            State.hasMouse = true
            return Mouse.X, Mouse.Y
        end
        State.hasMouse = false
        return nil, nil
    end
    local function IsMouseInside(X, Y, Width, Height)
        local MouseX, MouseY = State.mouseX, State.mouseY
        return State.hasMouse and MouseX >= X and MouseX <= X + Width and MouseY >= Y and MouseY <= Y + Height
    end
    local function UpdateInputBlock(Force)
        local MenuActive = State.open and State.minimized ~= true
        if State.dialog then
            MenuActive = true
        elseif MenuActive and State.gameInput == "always" then
            MenuActive = false
        elseif MenuActive and State.gameInput == true then
            local PopupOpen = State.dropdown or State.colorpicker or State.keyMenu or State.spotlightOpen
            if not PopupOpen and not IsMouseInside(State.x, State.y, State.w, State.h) then
                MenuActive = false
            end
        end
        local BlockInput = not MenuActive
        if Force or State.inputState ~= BlockInput then
            State.inputState = BlockInput
            pcall(SetRobloxInput, BlockInput)
        end
    end
    local function ClampWindowToScreen()
        local ViewportWidth, ViewportHeight = GetViewportSize()
        State.x = Clamp(State.x, 0, MathMax(0, ViewportWidth - MathMin(80, State.w)))
        State.y = Clamp(State.y, 0, MathMax(0, ViewportHeight - MathMin(40, State.h)))
    end
    local function SetOpen(IsOpen)
        IsOpen = IsTrue(IsOpen)
        if State.open == IsOpen then
            return
        end
        State.open = IsOpen
        State.drag = nil
        State.resizeEdge = nil
        State.sliderDrag = nil
        State.scrollDrag = nil
        State.dropdown = nil
        State.colorpicker = nil
        State.cpDrag = nil
        State.focus = nil
        State.keyMenu = nil
        UpdateInputBlock(false)
    end
    local function SafeCall(Callback, ...)
        if type(Callback) ~= "function" then
            return
        end
        local Success, Result = pcall(Callback, ...)
        if not Success then
            State.notifications[#State.notifications + 1] = {
                title = "error",
                description = string.lower(tostring(Result)),
                duration = 5,
                elapsed = 0
            }
            return
        end
        return Result
    end
    local function SnapToStep(Value, Item)
        local Min, Max, Step = Item.min or 0, Item.max or 100, Item.step or 1
        if Step <= 0 then
            Step = 1
        end
        local Steps = MathFloor((Value - Min) / Step + 0.5)
        local Snapped = Clamp(Min + Steps * Step, Min, Max)
        if Item.float == true then
            return Snapped
        end
        local Scale, ScaledStep, Decimals = 1, Step, 0
        while Decimals < 8 and MathFloor(ScaledStep) ~= ScaledStep do
            ScaledStep = ScaledStep * 10
            Scale = Scale * 10
            Decimals = Decimals + 1
        end
        return MathFloor(Snapped * Scale + 0.5) / Scale
    end
    local function SetDropdownValue(Item, Value, Notify)
        local List = ToList(Value)
        local Changed = #List ~= #Item.value
        for Index = 1, MathMax(#Item.value, #List) do
            if Item.value[Index] ~= List[Index] then
                Changed = true
                break
            end
        end
        for Index = #Item.value, 1, -1 do
            Item.value[Index] = nil
        end
        for Index = 1, #List do
            Item.value[Index] = List[Index]
        end
        if Changed then
            Item._ddVer = (Item._ddVer or 0) + 1
        end
        if Changed and Notify ~= false then
            SafeCall(Item.callback, Item.value)
        end
    end
    local function SetItemValue(Item, Value, Notify)
        if Item.type == "dropdown" then
            SetDropdownValue(Item, Value, Notify)
            return
        end
        if Item.type == "rangeslider" then
            local Low, High
            if type(Value) == "table" then
                Low = tonumber(Value[1] or Value.lo)
                High = tonumber(Value[2] or Value.hi)
            end
            if Low and High then
                Low = SnapToStep(Low, Item)
                High = SnapToStep(High, Item)
                if Low > High then
                    Low, High = High, Low
                end
                local Changed = Low ~= Item.valueLo or High ~= Item.valueHi
                Item.valueLo, Item.valueHi = Low, High
                if Changed and Notify ~= false then
                    SafeCall(Item.callback, Item.valueLo, Item.valueHi)
                end
            end
            return
        end
        if Item.type == "colorpicker" then
            local Color, Transparency = Value, nil
            if type(Value) == "table" then
                Color = Value[1]
                Transparency = tonumber(Value[2])
            end
            local Success, Result =
                pcall(
                function()
                    return Color and Color.R
                end
            )
            if Success and Result ~= nil then
                local Changed =
                    ColorsDiffer(Item.value, Color) or
                    Transparency ~= nil and MathAbs((Item.alpha or 1) - Transparency) > 0.001
                Item.value = Color
                if Transparency ~= nil then
                    Item.alpha = Transparency
                end
                if Changed and Notify ~= false then
                    SafeCall(Item.callback, Item.value, Item.alpha or 1)
                end
            end
            return
        end
        if Item.type == "slider" then
            Value = tonumber(Value) or Item.value or Item.min or 0
            Value = SnapToStep(Value, Item)
        elseif Item.type == "textbox" then
            Value = tostring(Value or "")
        elseif Item.type == "keybind" then
            Value = NormalizeKey(Value)
        elseif Item.type == "checkbox" then
            Value = Value == true
        end
        local Changed = Item.value ~= Value
        Item.value = Value
        if Changed and Notify ~= false then
            SafeCall(Item.callback, Value)
        end
    end
    local function IsDisabled(Item, Visited)
        local DependsOn = Item.dependsOn
        if DependsOn and DependsOn.item then
            Visited = Visited or {}
            if Visited[Item] then
                return false
            end
            Visited[Item] = true
            if not DependsOn.item.value or IsDisabled(DependsOn.item, Visited) then
                return true
            end
        end
        return false
    end
    local OpenColorpicker, OpenDropdown
    State._refreshChoices = function(Item, Force)
        local ChoicesFn = Item.choicesFn
        if type(ChoicesFn) ~= "function" then
            return false
        end
        local Now = Clock() or 0
        if not Force and Item._refreshAt and Now < Item._refreshAt then
            return false
        end
        Item._refreshAt = Now + 0.4
        local Success, Objects = pcall(ChoicesFn)
        if not Success or type(Objects) ~= "table" then
            return false
        end
        local Unchanged = #Objects == #Item.choices
        if Unchanged then
            for Index = 1, #Objects do
                if Objects[Index] ~= Item.choices[Index] then
                    Unchanged = false
                    break
                end
            end
        end
        if Unchanged then
            return false
        end
        Item.choices = ToList(Objects)
        if Item.value and #Item.value > 0 then
            local ChoiceSet = {}
            for _, Entry in ipairs(Item.choices) do
                ChoiceSet[Entry] = true
            end
            local Kept, Removed = {}, false
            for _, Value in ipairs(Item.value) do
                if ChoiceSet[Value] then
                    Kept[#Kept + 1] = Value
                else
                    Removed = true
                end
            end
            if Removed then
                SetDropdownValue(Item, Kept, true)
            end
        end
        local Dropdown = State.dropdown
        if Dropdown and Dropdown.item == Item then
            Dropdown.choices = ToList(Item.choices)
            Dropdown._filterQ = nil
            Dropdown._filtered = nil
            Dropdown.scrollOffset = Clamp(Dropdown.scrollOffset or 0, 0, MathMax(0, #Item.choices - 1))
        end
        return true
    end
    local function AddItem(Section, Item)
        Section.items[#Section.items + 1] = Item
        Item._secName = Section.name
        if Item.default == nil then
            if Item.type == "slider" or Item.type == "checkbox" or Item.type == "textbox" then
                Item.default = Item.value
            elseif Item.type == "dropdown" then
                Item.default = ToList(Item.value)
            elseif Item.type == "colorpicker" then
                Item._defColor = Item.value
                Item._defAlpha = Item.alpha
            elseif Item.type == "keybind" then
                Item._defKey = Item.value
            end
        end
        local Handle = {item = Item}
        function Handle:Set(Value)
            SetItemValue(Item, Value, true)
            return self
        end
        function Handle:Get()
            if Item.type == "rangeslider" then
                return Item.valueLo, Item.valueHi
            end
            if Item.type == "colorpicker" then
                return Item.value, Item.alpha or 1
            end
            return Item.value
        end
        function Handle:IsActivated()
            if Item.type == "keybind" then
                local Value = Item.value
                if not Value or Value == "" or Item.listening then
                    return false
                end
                local Modifier, Key = SplitCombo(Value)
                local KeyState = Keys[Key]
                if not KeyState then
                    return false
                end
                if Modifier then
                    local ModifierState = Keys[Modifier]
                    return (ModifierState ~= nil and ModifierState.held and KeyState.held) == true
                end
                return KeyState.held == true
            end
            local Keybind = Item.keybind
            if Keybind and Keybind.callback then
                return Keybind.active == true
            end
            return Item.value == true
        end
        function Handle:DependsOn(Dependency)
            Item.dependsOn = Dependency
            return self
        end
        function Handle:Tooltip(Text)
            Item.tooltip = tostring(Text or "")
            return self
        end
        function Handle:SetText(Data)
            Item.label = tostring(Data)
            if Item.buttons and Item.buttons[1] then
                Item.buttons[1].label = Item.label
            end
            return self
        end
        function Handle:SetColor(Value)
            Item.color = Value
            return self
        end
        function Handle:SetRisk(ValueB)
            Item.risk = ValueB ~= false
            return self
        end
        function Handle:Reset()
            if Item.type == "rangeslider" then
                Item.valueLo = Item.defLo or Item.min
                Item.valueHi = Item.defHi or Item.max
                SafeCall(Item.callback, Item.valueLo, Item.valueHi)
            elseif Item.type == "colorpicker" then
                if Item._defColor ~= nil then
                    Item.value = Item._defColor
                    Item.alpha = Item._defAlpha or 1
                    SafeCall(Item.callback, Item.value, Item.alpha)
                end
            elseif Item.type == "dropdown" then
                SetDropdownValue(Item, Item.default or {}, true)
            elseif Item.default ~= nil then
                SetItemValue(Item, Item.default, true)
            end
            return self
        end
        if Item.type == "checkbox" then
            function Handle:AddKeybind(Key, Mode, Callback)
                local Keybind = {
                    value = NormalizeKey(Key),
                    mode = NormalizeKeyMode(Mode),
                    callback = Callback,
                    listening = false,
                    active = false
                }
                Item.keybind = Keybind
                KeybindItems[#KeybindItems + 1] = Item
                local KeybindHandle = {item = Item, keybind = Keybind}
                function KeybindHandle:Set(Key2, CharWidth)
                    Keybind.value = NormalizeKey(Key2)
                    if CharWidth then
                        Keybind.mode = NormalizeKeyMode(CharWidth)
                    end
                    return self
                end
                function KeybindHandle:IsActivated()
                    if Keybind.callback then
                        return Keybind.active == true
                    end
                    return Item.value == true
                end
                function KeybindHandle:Parent()
                    return Handle
                end
                Handle.keyHandle = KeybindHandle
                return Handle
            end
            function Handle:AddColorpicker(Label, Color, Callback, Alpha)
                Item.colorpicker = {
                    label = Label or "color",
                    value = Color or Theme.accent,
                    alpha = Alpha or 1,
                    callback = Callback
                }
                return Handle
            end
        end
        if Item.type == "dropdown" then
            function Handle:UpdateChoices(Choices)
                Item.choices = ToList(Choices)
                if State.dropdown and State.dropdown.item == Item then
                    State.dropdown.choices = ToList(Choices)
                    State.dropdown._filterQ = nil
                    State.dropdown.scrollOffset = 0
                end
                return self
            end
            function Handle:AddChoice(Value)
                for Index = 1, #Item.choices do
                    if Item.choices[Index] == Value then
                        return self
                    end
                end
                Item.choices[#Item.choices + 1] = Value
                return self:UpdateChoices(Item.choices)
            end
            function Handle:RemoveChoice(Value)
                for Index = #Item.choices, 1, -1 do
                    if Item.choices[Index] == Value then
                        TableRemove(Item.choices, Index)
                    end
                end
                local Removed = false
                for Index = #Item.value, 1, -1 do
                    if Item.value[Index] == Value then
                        TableRemove(Item.value, Index)
                        Removed = true
                    end
                end
                self:UpdateChoices(Item.choices)
                if Removed then
                    Item._ddVer = (Item._ddVer or 0) + 1
                    SafeCall(Item.callback, Item.value)
                end
                return self
            end
            function Handle:SetSearchable(ValueB)
                Item.searchable = ValueB == true
                return self
            end
            function Handle:SetMaxSelections(Value)
                Item.maxSelections = tonumber(Value)
                if Item.maxSelections and #Item.value > Item.maxSelections then
                    local List = {}
                    for Index = 1, Item.maxSelections do
                        List[Index] = Item.value[Index]
                    end
                    SetDropdownValue(Item, List, true)
                end
                return self
            end
            function Handle:ClearChoices()
                Item.choices = {}
                if #Item.value > 0 then
                    SetDropdownValue(Item, {}, true)
                end
                return self:UpdateChoices(Item.choices)
            end
            function Handle:SetRefresh(ChoicesFn)
                Item.choicesFn = type(ChoicesFn) == "function" and ChoicesFn or nil
                if Item.choicesFn then
                    State._refreshChoices(Item, true)
                end
                return self
            end
            function Handle:Refresh()
                State._refreshChoices(Item, true)
                return self
            end
        end
        if Item.type == "button" then
            function Handle:AddButton(Label, Callback)
                Item.buttons[#Item.buttons + 1] = {label = tostring(Label or "Button"), callback = Callback}
                return self
            end
        end
        if Item.type == "keybind" then
            KeybindItems[#KeybindItems + 1] = Item
        end
        return Handle
    end
    local function CreateSection(Tab, Name, Side, Description)
        local Section = {
            name = tostring(Name or "Section"),
            side = tostring(Side or "Left"),
            items = {},
            desc = Description ~= nil and Description ~= "" and tostring(Description) or nil
        }
        Tab.sections[#Tab.sections + 1] = Section
        local SectionApi = {_section = Section}
        function SectionApi:SetName(Data)
            Section.name = tostring(Data)
            return self
        end
        function SectionApi:Label(Label, Color, Tooltip)
            if type(Color) == "string" and Tooltip == nil then
                Tooltip = Color
                Color = nil
            end
            local ChoicesFn = type(Label) == "function" and Label or nil
            return AddItem(
                Section,
                {
                    type = "label",
                    labelFn = ChoicesFn,
                    label = ChoicesFn and "" or tostring(Label or ""),
                    color = Color or Theme.sub,
                    tooltip = Tooltip
                }
            )
        end
        function SectionApi:Info(Text, Color)
            return AddItem(Section, {type = "info", label = tostring(Text or ""), color = Color or Theme.sub})
        end
        function SectionApi:Divider(Label)
            return AddItem(Section, {type = "divider", label = Label and tostring(Label) or nil})
        end
        function SectionApi:Button(Label, Callback, Tooltip)
            return AddItem(
                Section,
                {
                    type = "button",
                    label = tostring(Label or "Button"),
                    callback = Callback,
                    tooltip = Tooltip,
                    buttons = {{label = tostring(Label or "Button"), callback = Callback}}
                }
            )
        end
        function SectionApi:Toggle(Label, Default, Callback, Tooltip)
            return AddItem(
                Section,
                {
                    type = "checkbox",
                    label = tostring(Label or "Toggle"),
                    value = Default == true,
                    callback = Callback,
                    tooltip = Tooltip
                }
            )
        end
        SectionApi.Checkbox = SectionApi.Toggle
        function SectionApi:Slider(Label, Default, Step, Min, Max, Suffix, Callback, Tooltip)
            local Item = {
                type = "slider",
                label = tostring(Label or "Slider"),
                min = tonumber(Min) or 0,
                max = tonumber(Max) or 100,
                step = tonumber(Step) or 1,
                value = tonumber(Default) or tonumber(Min) or 0,
                suffix = Suffix or "",
                callback = Callback,
                tooltip = Tooltip
            }
            Item.value = SnapToStep(Item.value, Item)
            return AddItem(Section, Item)
        end
        function SectionApi:RangeSlider(Label, DefaultLow, DefaultHigh, Step, Min, Max, Suffix, Callback, Tooltip)
            local Item = {
                type = "rangeslider",
                label = tostring(Label or "Range"),
                min = tonumber(Min) or 0,
                max = tonumber(Max) or 100,
                step = tonumber(Step) or 1,
                valueLo = tonumber(DefaultLow) or tonumber(Min) or 0,
                valueHi = tonumber(DefaultHigh) or tonumber(Max) or 100,
                suffix = Suffix or "",
                callback = Callback,
                tooltip = Tooltip
            }
            Item.valueLo = SnapToStep(Item.valueLo, Item)
            Item.valueHi = SnapToStep(Item.valueHi, Item)
            if Item.valueLo > Item.valueHi then
                Item.valueLo, Item.valueHi = Item.valueHi, Item.valueLo
            end
            Item.defLo, Item.defHi = Item.valueLo, Item.valueHi
            return AddItem(Section, Item)
        end
        function SectionApi:Dropdown(Label, Default, Choices, Multi, Callback, Tooltip, Searchable, MaxSelections)
            local ChoicesFn = type(Choices) == "function" and Choices or nil
            local InitialChoices = Choices
            if ChoicesFn then
                local Success, Result = pcall(ChoicesFn)
                InitialChoices = Success and type(Result) == "table" and Result or {}
            end
            return AddItem(
                Section,
                {
                    type = "dropdown",
                    label = tostring(Label or "Dropdown"),
                    value = ToList(Default),
                    choices = ToList(InitialChoices),
                    choicesFn = ChoicesFn,
                    multi = Multi == true,
                    searchable = Searchable == true,
                    maxSelections = tonumber(MaxSelections),
                    callback = Callback,
                    tooltip = Tooltip
                }
            )
        end
        function SectionApi:Colorpicker(Label, Default, Callback, Alpha)
            return AddItem(
                Section,
                {
                    type = "colorpicker",
                    label = tostring(Label or "Color"),
                    value = Default or Theme.accent,
                    alpha = Alpha or 1,
                    callback = Callback
                }
            )
        end
        function SectionApi:Textbox(Label, Default, Callback, Tooltip)
            return AddItem(
                Section,
                {
                    type = "textbox",
                    label = tostring(Label or "Textbox"),
                    value = tostring(Default or ""),
                    callback = Callback,
                    tooltip = Tooltip
                }
            )
        end
        function SectionApi:Keybind(Label, Default, Callback, Tooltip)
            return AddItem(
                Section,
                {
                    type = "keybind",
                    label = tostring(Label or "Keybind"),
                    value = NormalizeKey(Default),
                    listening = false,
                    callback = Callback,
                    tooltip = Tooltip
                }
            )
        end
        function SectionApi:Image(Data, Height, Width)
            return AddItem(
                Section,
                {type = "image", imageData = Data, imgHeight = tonumber(Height) or 80, imgWidth = tonumber(Width)}
            )
        end
        return SectionApi
    end
    local UiLib = {}
    UiLib.__index = UiLib
    function UiLib.Notify(First, Second, Third, Fourth, Fifth)
        local Title, Description, Duration, Type
        if type(First) == "table" then
            Title, Description, Duration, Type = Second, Third, Fourth, Fifth
        else
            Title, Description, Duration, Type = First, Second, Third, Fourth
        end
        State.notifications[#State.notifications + 1] = {
            title = string.lower(tostring(Title or "notification")),
            description = string.lower(tostring(Description or "")),
            duration = tonumber(Duration) or State.notifyDur or 5,
            elapsed = 0,
            ntype = Type and string.lower(tostring(Type)) or nil
        }
    end
    function UiLib:Dialog(Options)
        Options = Options or {}
        State.dialog = {
            title = tostring(Options.title or "Confirm"),
            text = tostring(Options.text or ""),
            confirm = tostring(Options.confirm or "Confirm"),
            cancel = tostring(Options.cancel or "Cancel"),
            onConfirm = Options.onConfirm,
            onCancel = Options.onCancel
        }
        return self
    end
    function UiLib:SetAccent(ValueA, ValueB)
        ValueB = ValueB or ValueA
        if ValueA ~= nil then
            Theme.accentA = ValueA
            State.baseAccentA = ValueA
        end
        if ValueB ~= nil then
            Theme.accentB = ValueB
            State.baseAccentB = ValueB
        end
        pcall(function()
            if State._c1pick and State._c1pick.item then
                State._c1pick.item.value = Theme.accentA
            end
        end)
        pcall(function()
            if State._c2pick and State._c2pick.item then
                State._c2pick.item.value = Theme.accentB
            end
        end)
        return self
    end
    function UiLib:SetTheme(Preset)
        if type(Preset) == "table" then
            local Accent, Accent2 = Preset.accent, Preset.accent
            if Preset.accentA ~= nil then
                Accent = Preset.accentA
            end
            if Preset.accentB ~= nil then
                Accent2 = Preset.accentB
            end
            for Key, Value in pairs(Preset) do
                if Theme[Key] ~= nil and Key ~= "accent" and Key ~= "accentA" and Key ~= "accentB" then
                    Theme[Key] = Value
                end
            end
            if Accent or Accent2 then
                UiLib:SetAccent(Accent or Theme.accentA, Accent2 or Theme.accentB)
            end
        end
        return self
    end
    function UiLib:SetOpacity(Value)
        Value = tonumber(Value)
        if Value then
            if Value > 1 then
                Value = Value / 100
            end
            State.menuOpacity = Clamp(Value, 0.4, 1)
        end
        return self
    end
    function UiLib:SetPerformance(Enabled)
        State.lite = Enabled == true
        return self
    end
    function UiLib:IsPerformance()
        return State.lite == true
    end
    function UiLib:SetRounding(Value)
        Value = tonumber(Value)
        if Value then
            if Value > 2.5 then
                Value = Value / 100
            end
            State.roundScale = Clamp(Value, 0, 2.5)
        end
        return self
    end
    function UiLib:GetRounding()
        return State.roundScale or 1
    end
    function UiLib:SetRowLines(Enabled)
        State.rowLines = Enabled == true
        return self
    end
    function UiLib:SetCheckboxStyle(Enabled)
        State.checkboxStyle = Enabled == true
        return self
    end
    function UiLib:IsCheckboxStyle()
        return State.checkboxStyle == true
    end
    function UiLib:SetKeybindOverlay(Enabled)
        State.hotkeyEnabled = Enabled ~= false
        return self
    end
    function UiLib:SetAutoSave(Enabled)
        State.autoSave = Enabled == true
        return self
    end
    function UiLib:SetMenuKey(Key)
        if type(Key) == "number" or type(Key) == "string" and tonumber(Key) then
            local KeyCode = tonumber(Key)
            for Name, Key2 in pairs(Keys) do
                if Key2.id == KeyCode then
                    Key = Name
                    break
                end
            end
        end
        local Normalized = NormalizeKey(Key)
        if Normalized and Keys[Normalized] then
            MenuKey = Normalized
        end
        return self
    end
    function UiLib:IsOpen()
        return State.open == true
    end
    function UiLib:SetOpen(ValueB)
        SetOpen(ValueB == true)
        return self
    end
    function UiLib:_dbgFocus(Height)
        local Target = type(Height) == "table" and Height.item or Height
        if Target then
            State.focus = Target
            Target.caret = 0
            Target.selA = nil
        end
        return self
    end
    function UiLib:_dbgOpenDropdown(Height)
        local Target = type(Height) == "table" and Height.item or Height
        if Target then
            OpenDropdown(120, 120, 180, Target)
        end
        return self
    end
    function UiLib:OpenColorpicker(Height)
        local Item = type(Height) == "table" and Height.item or Height
        if Item and Item.type == "colorpicker" then
            OpenColorpicker(State.x + 80, State.y + 80, Item)
        end
        return self
    end
    function UiLib:OpenSpotlight(IsOpen)
        State.spotlightOpen = IsOpen ~= false
        if State.spotlightOpen then
            State.spotlight = {query = "", sel = 1}
            State.focus = nil
        end
        return self
    end
    function UiLib:AvatarLog()
        return table.concat(State._avLog or {"avatar task has not run yet"}, "\n")
    end
    function UiLib:SetGameInput(Enabled)
        State.gameInput = Enabled == "always" and "always" or Enabled ~= false
        return self
    end
    function UiLib:OpenSettings()
        if State.settingsTab and State.activeTab ~= State.settingsTab then
            State._prevTab = State.activeTab
            State._prevIndex = State.activeIndex
            State.activeTab = State.settingsTab
            State.activeIndex = State.settingsIndex or #State.tabs
            State.contentFade = 0
        end
        return self
    end
    function UiLib:SetTitle(Data)
        State.title = tostring(Data or "uilib")
        return self
    end
    function UiLib:SetSize(Width, Height)
        if tonumber(Width) then
            State.w = MathMax(80, tonumber(Width))
            State.wTarget = State.w
        end
        if tonumber(Height) then
            State.h = MathMax(80, tonumber(Height))
            State.hTarget = State.h
        end
        return self
    end
    function UiLib:SetPos(A, B)
        if tonumber(A) then
            State.x = tonumber(A)
        end
        if tonumber(B) then
            State.y = tonumber(B)
        end
        return self
    end
    UiLib.SetPosition = UiLib.SetPos
    function UiLib:Center()
        local ViewportWidth, ViewportHeight = GetViewportSize()
        State.x = MathFloor(ViewportWidth / 2 - State.w / 2)
        State.y = MathFloor(ViewportHeight / 2 - State.h / 2)
        return self
    end
    function UiLib:Category(Name)
        State._curCategory = Name ~= nil and tostring(Name) ~= "" and tostring(Name) or nil
        return self
    end
    function UiLib:Tab(Name, Icon)
        local Tab = {
            name = tostring(Name or "Tab " .. #State.tabs + 1),
            icon = Icon,
            category = State._curCategory,
            subs = {},
            sections = {},
            scrollY = 0,
            targetScrollY = 0,
            maxScroll = 0
        }
        State.tabs[#State.tabs + 1] = Tab
        if not State.activeTab then
            State.activeTab = Tab
            State.activeIndex = #State.tabs
        end
        local TabApi = {_tab = Tab}
        function TabApi:Section(Name2, Side, Description)
            return CreateSection(Tab, Name2, Side, Description)
        end
        function TabApi:Sub(Name2, Icon2)
            local Sub = {
                name = tostring(Name2 or "Sub " .. #Tab.subs + 1),
                icon = Icon2,
                parent = Tab,
                sections = {},
                scrollY = 0,
                targetScrollY = 0,
                maxScroll = 0
            }
            Tab.subs[#Tab.subs + 1] = Sub
            local SubApi = {_tab = Sub}
            function SubApi:Section(Name3, Side, Description)
                return CreateSection(Sub, Name3, Side, Description)
            end
            return SubApi
        end
        return TabApi
    end
    function UiLib:CreateBox(Options)
        Options = type(Options) == "table" and Options or {}
        State.boxes = State.boxes or {}
        local Box = {
            title = tostring(Options.title or "Box"),
            lines = {},
            visible = Options.visible ~= false,
            alive = true,
            x = Options.position and Options.position.X or Options.x or 20,
            y = Options.position and Options.position.Y or Options.y or 140,
            width = Options.width or Options.w
        }
        State.boxes[#State.boxes + 1] = Box
        local SectionApi = {_box = Box}
        function SectionApi:Text(Value, Color)
            local Line = {value = Value, color = Color}
            Box.lines[#Box.lines + 1] = Line
            return {Set = function(_, Data)
                    Line.value = Data
                end, SetColor = function(_, Value2)
                    Line.color = Value2
                end}
        end
        SectionApi.Label = SectionApi.Text
        function SectionApi:Stat(Value, Color)
            local Line = {kind = "stat", value = Value, color = Color}
            Box.lines[#Box.lines + 1] = Line
            return {Set = function(_, Data)
                    Line.value = Data
                end, SetColor = function(_, Value2)
                    Line.color = Value2
                end}
        end
        function SectionApi:Bar(Value, Color)
            local Line = {kind = "bar", value = Value, color = Color}
            Box.lines[#Box.lines + 1] = Line
            return {Set = function(_, Value2)
                    Line.value = Value2
                end, SetColor = function(_, Value2)
                    Line.color = Value2
                end}
        end
        function SectionApi:SetVisible(ValueB)
            Box.visible = ValueB ~= false
            return self
        end
        function SectionApi:Toggle()
            Box.visible = not Box.visible
            return self
        end
        function SectionApi:SetTitle(Data)
            Box.title = tostring(Data)
            return self
        end
        function SectionApi:Clear()
            Box.lines = {}
            return self
        end
        function SectionApi:Remove()
            Box.alive = false
            for Index, Value in ipairs(State.boxes) do
                if Value == Box then
                    TableRemove(State.boxes, Index)
                    break
                end
            end
        end
        return SectionApi
    end
    local function SplitPath(Text)
        local Position = {}
        for Key in string.gmatch(Text, "[^%.]+") do
            Position[#Position + 1] = Key
        end
        return Position
    end
    function UiLib:GetValue(Path)
        local Position = SplitPath(tostring(Path))
        if #Position < 3 then
            return nil
        end
        for _, Kind in ipairs(State.tabs) do
            if Kind.name == Position[1] then
                for _, Value in ipairs(Kind.sections) do
                    if Value.name == Position[2] then
                        for _, Target in ipairs(Value.items) do
                            if Target.label == Position[3] then
                                if Target.type == "rangeslider" then
                                    return Target.valueLo, Target.valueHi
                                end
                                if Target.type == "colorpicker" then
                                    return Target.value, Target.alpha or 1
                                end
                                return Target.value
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    function UiLib:SetValue(Path, Value)
        local Position = SplitPath(tostring(Path))
        if #Position < 3 then
            return self
        end
        for _, Kind in ipairs(State.tabs) do
            if Kind.name == Position[1] then
                for _, Value2 in ipairs(Kind.sections) do
                    if Value2.name == Position[2] then
                        for _, Target in ipairs(Value2.items) do
                            if Target.label == Position[3] then
                                SetItemValue(Target, Value, true)
                                return self
                            end
                        end
                    end
                end
            end
        end
        return self
    end
    local function PollInput()
        State.mouseScroll = 0
        local Active = true
        pcall(function()
            Active = IsRobloxActive()
        end)
        for _, Name in ipairs(KeyNames) do
            local Key = Keys[Name]
            Key.click = false
            Key.released = false
        end
        local Mouse1Down = Active and IsMouse1Pressed() or false
        local Mouse2Down = Active and IsMouse2Pressed() or false
        Keys.m1.click = Mouse1Down and not Keys.m1.held
        Keys.m1.released = not Mouse1Down and Keys.m1.held
        Keys.m1.held = Mouse1Down
        Keys.m2.click = Mouse2Down and not Keys.m2.held
        Keys.m2.released = not Mouse2Down and Keys.m2.held
        Keys.m2.held = Mouse2Down
        local TextFocused =
            State.focus ~= nil or State.spotlightOpen or State.dialog ~= nil or State.kbCapture ~= nil or
            State.colorpicker ~= nil and State.colorpicker.hexInput ~= nil
        if not TextFocused then
            for _, Item in ipairs(KeybindItems) do
                if Item.keybind and Item.keybind.listening or Item.type == "keybind" and Item.listening then
                    TextFocused = true
                    break
                end
            end
        end
        if TextFocused then
            for _, Name in ipairs(KeyNames) do
                if Name ~= "m1" and Name ~= "m2" then
                    local Key = Keys[Name]
                    local IsDown = Active and IsKeyPressed(Key.id) or false
                    Key.click = IsDown and not Key.held
                    Key.released = not IsDown and Key.held
                    Key.held = IsDown
                end
            end
        else
            local PolledKeys = {}
            PolledKeys[MenuKey] = true
            PolledKeys.ctrl = true
            PolledKeys.lctrl = true
            PolledKeys.rctrl = true
            PolledKeys.space = true
            PolledKeys.esc = true
            if State.open then
                PolledKeys.left = true
                PolledKeys.right = true
                PolledKeys.up = true
                PolledKeys.down = true
                PolledKeys.pageup = true
                PolledKeys.pagedown = true
            end
            for _, Item in ipairs(KeybindItems) do
                local Keybind = Item.keybind
                if Keybind and Keybind.value then
                    if Keybind._pcSrc ~= Keybind.value then
                        Keybind._pcSrc = Keybind.value
                        Keybind._pcMod, Keybind._pcKey = SplitCombo(Keybind.value)
                    end
                    if Keybind._pcMod then
                        PolledKeys[Keybind._pcMod] = true
                    end
                    if Keybind._pcKey then
                        PolledKeys[Keybind._pcKey] = true
                    end
                elseif Item.type == "keybind" and Item.value and Item.value ~= "" then
                    if Item._pcSrc ~= Item.value then
                        Item._pcSrc = Item.value
                        Item._pcMod, Item._pcKey = SplitCombo(Item.value)
                    end
                    if Item._pcMod then
                        PolledKeys[Item._pcMod] = true
                    end
                    if Item._pcKey then
                        PolledKeys[Item._pcKey] = true
                    end
                end
            end
            for Name in pairs(PolledKeys) do
                local Key = Keys[Name]
                if Key and Name ~= "m1" and Name ~= "m2" then
                    local IsDown = Active and IsKeyPressed(Key.id) or false
                    Key.click = IsDown and not Key.held
                    Key.released = not IsDown and Key.held
                    Key.held = IsDown
                end
            end
        end
    end
    local function IsShiftHeld()
        return Keys.shift.held or Keys.lshift.held or Keys.rshift.held
    end
    local function IsCtrlHeld()
        return Keys.ctrl.held or Keys.lctrl.held or Keys.rctrl.held
    end
    local function KeyRepeat(Name)
        local Key = Keys[Name]
        if not Key then
            return false
        end
        if Key.click then
            State.repeatKey = Name
            State.repeatAt = (Clock() or 0) + 0.4
            return true
        end
        if Key.held and State.repeatKey == Name and (Clock() or 0) >= State.repeatAt then
            State.repeatAt = (Clock() or 0) + 0.035
            return true
        end
        return false
    end
    local function HandleTextInput(Target, Field, NumericOnly, HexOnly)
        local Text = Target[Field] or ""
        Target.caret = Clamp(Target.caret or #Text, 0, #Text)
        local Caret = Target.caret
        local SelA = Target.selA
        local HasSelection = SelA ~= nil and SelA ~= Caret
        local SelectionStart = HasSelection and MathMin(SelA, Caret) or Caret
        local SelectionEnd = HasSelection and MathMax(SelA, Caret) or Caret
        local Changed = false
        local ShiftHeld = IsShiftHeld()
        local function DeleteSelection()
            Text = string.sub(Text, 1, SelectionStart) .. string.sub(Text, SelectionEnd + 1)
            Caret = SelectionStart
            SelA = nil
            HasSelection = false
            Changed = true
        end
        local function Commit()
            Target.caret = Clamp(Caret, 0, #Text)
            Target.selA = SelA
            Target[Field] = Text
            return Changed
        end
        if IsCtrlHeld() then
            if Keys.a.click then
                SelA = 0
                Caret = #Text
                Keys.a.click = false
            elseif Keys.c.click then
                if HasSelection then
                    pcall(SetClipboard, string.sub(Text, SelectionStart + 1, SelectionEnd))
                end
                Keys.c.click = false
            elseif Keys.x.click then
                if HasSelection then
                    pcall(SetClipboard, string.sub(Text, SelectionStart + 1, SelectionEnd))
                    DeleteSelection()
                end
                Keys.x.click = false
            elseif Keys.v.click then
                Keys.v.click = false
                local Clipboard
                if GetClipboard then
                    local Success, Cache = pcall(GetClipboard)
                    if Success then
                        Clipboard = Cache
                    end
                end
                if type(Clipboard) == "string" and Clipboard ~= "" then
                    if NumericOnly then
                        Clipboard = Clipboard:gsub("[^0-9%.%-]", "")
                    elseif HexOnly then
                        Clipboard = Clipboard:gsub("[^0-9a-fA-F]", "")
                    end
                    if HasSelection then
                        DeleteSelection()
                    end
                    Text = string.sub(Text, 1, Caret) .. Clipboard .. string.sub(Text, Caret + 1)
                    Caret = Caret + #Clipboard
                    Changed = true
                end
            end
            return Commit()
        end
        if Keys.left.click or Keys.right.click or Keys.home.click or Keys["end"].click then
            local NewCaret = Caret
            if Keys.left.click then
                NewCaret = HasSelection and not ShiftHeld and SelectionStart or MathMax(0, Caret - 1)
            end
            if Keys.right.click then
                NewCaret = HasSelection and not ShiftHeld and SelectionEnd or MathMin(#Text, Caret + 1)
            end
            if Keys.home.click then
                NewCaret = 0
            end
            if Keys["end"].click then
                NewCaret = #Text
            end
            if ShiftHeld then
                SelA = SelA or Caret
            else
                SelA = nil
            end
            Caret = NewCaret
            Keys.left.click = false
            Keys.right.click = false
            Keys.home.click = false
            Keys["end"].click = false
            return Commit()
        end
        if Keys.delete.click then
            if HasSelection then
                DeleteSelection()
            elseif Caret < #Text then
                Text = string.sub(Text, 1, Caret) .. string.sub(Text, Caret + 2)
                SelA = nil
                Changed = true
            end
            Keys.delete.click = false
        end
        if KeyRepeat("backspace") then
            if HasSelection then
                DeleteSelection()
            elseif Caret > 0 then
                Text = string.sub(Text, 1, Caret - 1) .. string.sub(Text, Caret + 1)
                Caret = Caret - 1
                SelA = nil
                Changed = true
            end
        end
        if not Changed then
            for _, Name in ipairs(KeyNames) do
                local Key = Keys[Name]
                if Key.char then
                    local ShouldType =
                        Key.click or Key.held and State.repeatKey == Name and (Clock() or 0) >= State.repeatAt
                    if ShouldType then
                        local Char = ShiftHeld and Key.shifted or Key.char
                        if NumericOnly and not Char:match("[0-9%.%-]") then
                            Char = ""
                        elseif HexOnly and not Char:match("[0-9a-fA-F]") then
                            Char = ""
                        end
                        if Char ~= "" then
                            if HasSelection then
                                DeleteSelection()
                            end
                            Text = string.sub(Text, 1, Caret) .. Char .. string.sub(Text, Caret + 1)
                            Caret = Caret + 1
                            SelA = nil
                            Changed = true
                        end
                        if Key.click then
                            State.repeatKey = Name
                            State.repeatAt = (Clock() or 0) + 0.4
                            Key.click = false
                        else
                            State.repeatAt = (Clock() or 0) + 0.035
                        end
                        break
                    end
                end
            end
        end
        return Commit()
    end
    local TextFont = FontUi
    local TextWidthRatio = FontWidthRatios[FontUi] or 0.50
    local function GetCharWidth(Size)
        return (Size or 13) * TextWidthRatio
    end
    local function CaretFromX(Target, Text, MouseX)
        local CharWidth = Target._ecw or GetCharWidth(13)
        return Clamp(
            (Target._es or 0) + MathFloor((MouseX - (Target._ex or 0)) / CharWidth + 0.5),
            0,
            #tostring(Text or "")
        )
    end
    local function DrawEditableText(
        Target,
        Text,
        X,
        Y,
        Size,
        Color,
        Alpha,
        ZIndex,
        MaxWidth,
        Focused,
        Caret,
        SelectionStart)
        Text = tostring(Text or "")
        local CharWidth = GetCharWidth(Size)
        local Entry = #Text
        Caret = Clamp(Caret or Entry, 0, Entry)
        local MaxVisibleChars = MathMax(1, MathFloor(MaxWidth / CharWidth))
        local ScrollStart = 0
        if Focused and Caret > MaxVisibleChars then
            ScrollStart = Caret - MaxVisibleChars
        end
        Target._ecw = CharWidth
        Target._ex = X
        Target._es = ScrollStart
        local ScrollEnd = MathMin(Entry, ScrollStart + MaxVisibleChars)
        local HasSelection = Focused and SelectionStart and SelectionStart ~= Caret
        local VisibleText = string.sub(Text, ScrollStart + 1, ScrollEnd)
        for Index = 1, #VisibleText do
            DrawText(
                string.sub(VisibleText, Index, Index),
                X + (Index - 1) * CharWidth,
                Y,
                Color,
                Size,
                TextFont,
                ZIndex,
                false,
                false,
                nil,
                Alpha
            )
        end
        if Focused and not HasSelection and (Clock() or 0) % 1 < 0.55 then
            FillRect(X + Clamp(Caret - ScrollStart, 0, #VisibleText) * CharWidth, Y, 1, Size, Color, ZIndex, 0, Alpha)
        end
        if HasSelection then
            local SelectionLow, SelectionHigh = MathMin(SelectionStart, Caret), MathMax(SelectionStart, Caret)
            local SelectionStartIndex = Clamp(SelectionLow - ScrollStart, 0, #VisibleText)
            local SelectionEndIndex = Clamp(SelectionHigh - ScrollStart, 0, #VisibleText)
            FillRect(
                X + SelectionStartIndex * CharWidth,
                Y - 1,
                MathMax(1, (SelectionEndIndex - SelectionStartIndex) * CharWidth),
                Size + 4,
                State._accentMid,
                ZIndex,
                3,
                SelectionEndIndex > SelectionStartIndex and 0.45 * Alpha or 0
            )
        end
    end
    local function ProcessFocusedInput()
        local Focus = State.focus
        if not Focus then
            return
        end
        if Focus == State.dropdown and Focus.searchable then
            if Keys.enter.click or Keys.esc.click then
                State.focus = nil
                Keys.enter.click = false
                Keys.esc.click = false
                return
            end
            if HandleTextInput(Focus, "searchQuery", false) then
                Focus.scrollOffset = 0
            end
            return
        end
        if type(Focus) ~= "table" or Focus.type ~= "textbox" and Focus.type ~= "slider" then
            return
        end
        if Keys.enter.click or Keys.esc.click then
            if Focus.type == "slider" and Focus.directValue then
                if Keys.enter.click then
                    SetItemValue(Focus, tonumber(Focus.directValue) or Focus.value, true)
                end
                Focus.directValue = nil
            end
            State.focus = nil
            Focus.selA = nil
            Keys.enter.click = false
            Keys.esc.click = false
            return
        end
        if Focus.type == "textbox" then
            if HandleTextInput(Focus, "value", false) then
                SafeCall(Focus.callback, Focus.value)
            end
        else
            HandleTextInput(Focus, "directValue", true)
        end
    end
    local function ProcessKeybinds()
        if State.focus then
            return
        end
        for _, Item in ipairs(KeybindItems) do
            local Keybind = Item.keybind
            if Keybind and Keybind.value and not Keybind.listening and not IsDisabled(Item) then
                if Keybind._pcSrc ~= Keybind.value then
                    Keybind._pcSrc = Keybind.value
                    Keybind._pcMod, Keybind._pcKey = SplitCombo(Keybind.value)
                end
                local PcMod, PcKey = Keybind._pcMod, Keybind._pcKey
                local KeyState = Keys[PcKey]
                local ModifierState = PcMod and Keys[PcMod] or nil
                if KeyState then
                    if Keybind.callback then
                        local Pressed = Keybind.active or false
                        if PcMod and not ModifierState then
                        elseif Keybind.mode == "Always" then
                            Pressed = true
                        elseif Keybind.mode == "Toggle" then
                            local Notify =
                                PcMod and (ModifierState.held and KeyState.click) or not PcMod and KeyState.click
                            if Notify then
                                Pressed = not Keybind.active
                            end
                        else
                            Pressed =
                                PcMod and (ModifierState.held and KeyState.held) or not PcMod and KeyState.held or false
                        end
                        if Pressed ~= Keybind.active then
                            Keybind.active = Pressed
                            SafeCall(Keybind.callback, Pressed)
                        end
                    else
                        if PcMod and not ModifierState then
                        elseif Keybind.mode == "Always" then
                            SetItemValue(Item, true, true)
                        elseif Keybind.mode == "Toggle" then
                            local Notify =
                                PcMod and (ModifierState.held and KeyState.click) or not PcMod and KeyState.click
                            if Notify then
                                SetItemValue(Item, not Item.value, true)
                            end
                        else
                            SetItemValue(
                                Item,
                                PcMod and (ModifierState.held and KeyState.held) or not PcMod and KeyState.held or false,
                                true
                            )
                        end
                    end
                end
            end
        end
    end
    State._captureKeybind = function()
        local Url, Keybind
        for _, Item in ipairs(KeybindItems) do
            if Item.type == "keybind" and Item.listening then
                Url = Item
                break
            end
            if Item.keybind and Item.keybind.listening then
                Url = Item
                Keybind = Item.keybind
                break
            end
        end
        if not Url then
            return false
        end
        for _, Name in ipairs(KeyNames) do
            local Key = Keys[Name]
            if Key.click then
                if Keybind then
                    if Name == "esc" then
                        Keybind.value = nil
                    else
                        Keybind.value = Name
                    end
                    Keybind.listening = false
                else
                    if Name ~= "esc" then
                        Url.value = Name
                        SafeCall(Url.callback, Url.value)
                    end
                    Url.listening = false
                    State.kbCapture = nil
                end
                Key.click = false
                Keys.m1.click = false
                Keys.m2.click = false
                break
            end
        end
        return true
    end
    function OpenDropdown(X, Y, Width, Item)
        State._refreshChoices(Item, true)
        local RowHeight = 26
        local Searchable = Item.searchable == true
        local HeaderHeight = Searchable and 30 or 0
        local RowCount = MathMin(#Item.choices, 8)
        local Height = MathMax(RowHeight, RowCount * RowHeight) + 8 + HeaderHeight
        local ViewportWidth, ViewportHeight = GetViewportSize()
        X = Clamp(X, 8, MathMax(8, ViewportWidth - Width - 8))
        Y = Clamp(Y, 8, MathMax(8, ViewportHeight - Height - 8))
        State.dropdown = {
            item = Item,
            choices = ToList(Item.choices),
            value = Item.value,
            x = X,
            y = Y,
            w = Width,
            h = Height,
            rowH = RowHeight,
            multi = Item.multi,
            scrollOffset = 0,
            anim = 0,
            searchable = Searchable,
            headerH = HeaderHeight,
            searchQuery = ""
        }
        State.colorpicker = nil
        if Searchable then
            State.focus = State.dropdown
        end
    end
    function OpenColorpicker(X, Y, Item)
        local Width, Height = 250, 240
        local ViewportWidth, ViewportHeight = GetViewportSize()
        X = Clamp(X, 8, MathMax(8, ViewportWidth - Width - 8))
        Y = Clamp(Y, 8, MathMax(8, ViewportHeight - Height - 8))
        local Hover, Cleaned, Value = ColorToHsv(Item.value)
        State.colorpicker = {
            picker = Item,
            x = X,
            y = Y,
            w = Width,
            h = Height,
            hue = Hover,
            sat = Cleaned,
            val = Value,
            alpha = Item.alpha or 1,
            anim = 0,
            fmt = "HEX"
        }
        State.dropdown = nil
    end
    local function DrawDropdown(Clicked, RightClicked)
        local Dropdown = State.dropdown
        if not Dropdown then
            return Clicked, RightClicked
        end
        Dropdown.anim = Approach(Dropdown.anim or 0, Dropdown.closing and 0 or 1, 9)
        if Dropdown.closing and Dropdown.anim < 0.02 then
            if State.focus == Dropdown then
                State.focus = nil
            end
            State.dropdown = nil
            return Clicked, RightClicked
        end
        local Anim = Dropdown.anim
        local X, Y, Width, Height = Dropdown.x, Dropdown.y + (1 - Anim) * -6, Dropdown.w, Dropdown.h
        local RowH, HeaderHeight = Dropdown.rowH, Dropdown.headerH or 0
        if not Dropdown.closing then
            State._refreshChoices(Dropdown.item, false)
        end
        local Choices = Dropdown.choices
        if Dropdown.searchable and Dropdown.searchQuery ~= "" then
            if Dropdown.searchQuery ~= Dropdown._filterQ then
                Dropdown._filterQ = Dropdown.searchQuery
                local Query = string.lower(Dropdown.searchQuery)
                local Candidate = {}
                for _, Entry in ipairs(Dropdown.choices) do
                    if string.find(string.lower(tostring(Entry)), Query, 1, true) then
                        Candidate[#Candidate + 1] = Entry
                    end
                end
                Dropdown._filtered = Candidate
            end
            Choices = Dropdown._filtered
        end
        local VisibleRows = MathMax(1, MathFloor((Height - 8 - HeaderHeight) / RowH))
        local Hovered = IsMouseInside(X - 4, Y - 4, Width + 8, Height + 8)
        if Hovered and State.mouseScroll ~= 0 then
            Dropdown.scrollOffset = Dropdown.scrollOffset - (State.mouseScroll > 0 and 1 or -1)
        end
        Dropdown.scrollOffset = Clamp(Dropdown.scrollOffset, 0, MathMax(0, #Choices - VisibleRows))
        FillRect(X - 3, Y - 3, Width + 6, Height + 6, NewColor(0, 0, 0), 199, 11, 0.28 * Anim)
        FillRect(X, Y, Width, Height, LerpColor(Theme.bg, White, 0.03), 200, 8, 0.98 * Anim)
        if Dropdown.searchable then
            local Focused = State.focus == Dropdown
            FillRect(X + 6, Y + 5, Width - 12, 22, White, 202, 6, Opacity.field * Anim)
            StrokeRect(X + 6, Y + 5, Width - 12, 22, White, 203, 6, (Focused and 0.4 or Opacity.hairline) * Anim)
            local SearchQuery = Dropdown.searchQuery
            if SearchQuery == "" and not Focused then
                DrawText(
                    "search...",
                    X + 14,
                    CenterTextY(Y + 5, 22, 13),
                    White,
                    13,
                    FontSystem,
                    204,
                    false,
                    false,
                    Width - 28,
                    0.3 * Anim
                )
            else
                DrawEditableText(
                    Dropdown,
                    SearchQuery,
                    X + 14,
                    CenterTextY(Y + 5, 22, 13),
                    13,
                    White,
                    Opacity.dim * Anim,
                    204,
                    Width - 30,
                    Focused,
                    Dropdown.caret,
                    Dropdown.selA
                )
            end
            if Clicked and IsMouseInside(X + 6, Y + 5, Width - 12, 22) then
                State.focus = Dropdown
                Dropdown.caret = CaretFromX(Dropdown, SearchQuery, State.mouseX)
                Dropdown.selA = Dropdown.caret
                State.textDrag = Dropdown
                Clicked = false
            end
            if Keys.m1.held and State.textDrag == Dropdown then
                Dropdown.caret = CaretFromX(Dropdown, SearchQuery, State.mouseX)
            end
        end
        local ListTop = Y + 4 + HeaderHeight
        local Now = Clock() or 0
        local AccentMid = State._accentMid
        local RowWidth = #Choices > VisibleRows and Width - 18 or Width - 8
        Dropdown._sy = Approach(Dropdown._sy or Dropdown.scrollOffset, Dropdown.scrollOffset, 16)
        local ScrollPos = Dropdown._sy
        local ListHeight = VisibleRows * RowH
        for Row = 0, VisibleRows do
            local RowIndex = MathFloor(ScrollPos) + Row
            local Choice = RowIndex >= 0 and Choices[RowIndex + 1] or nil
            if Choice then
                local RowY = ListTop + (RowIndex - ScrollPos) * RowH
                if RowY + RowH > ListTop and RowY < ListTop + ListHeight then
                    local ClipFade =
                        Clamp((RowY + RowH - ListTop) / RowH, 0, 1) * Clamp((ListTop + ListHeight - RowY) / RowH, 0, 1)
                    local EntryFade = Clamp((Anim - Row * 0.07) / 0.4, 0, 1)
                    local RowAlpha = EntryFade * ClipFade
                    local RowTop = RowY + (1 - EntryFade) * 12
                    local Selected = false
                    for _, Entry in ipairs(Dropdown.value) do
                        if Entry == Choice then
                            Selected = true
                            break
                        end
                    end
                    local RowHovered =
                        RowY >= ListTop - 2 and RowY + RowH <= ListTop + ListHeight + 2 and
                        IsMouseInside(X + 4, RowTop, RowWidth, RowH - 2)
                    FillRect(
                        X + 4,
                        RowTop,
                        RowWidth,
                        RowH - 2,
                        AccentMid,
                        202,
                        6,
                        (Dropdown._pressRow == RowIndex and Dropdown._pressT and Dropdown._pressT > Now and
                            0.45 * (Dropdown._pressT - Now) / 0.3 or
                            0) * RowAlpha
                    )
                    FillRect(X + 4, RowTop, RowWidth, RowH - 2, White, 202, 6, (Selected and 0.05 or 0) * RowAlpha)
                    FillRect(
                        X + 4,
                        RowTop,
                        RowWidth,
                        RowH - 2,
                        AccentMid,
                        202,
                        6,
                        (RowHovered and 0.16 or 0) * RowAlpha
                    )
                    DrawText(
                        Choice,
                        X + 12,
                        CenterTextY(RowTop, RowH - 2, 13),
                        White,
                        13,
                        FontSystem,
                        203,
                        false,
                        false,
                        Width - 42,
                        ((RowHovered or Selected) and Opacity.text or Opacity.label) * RowAlpha
                    )
                    if Selected then
                        local CheckX, CheckY = X + 4 + RowWidth - 14, RowTop + (RowH - 2) / 2 + 1
                        DrawLine(CheckX, CheckY, CheckX + 3, CheckY + 3, White, 204, 1.5, Opacity.text * RowAlpha)
                        DrawLine(
                            CheckX + 3,
                            CheckY + 3,
                            CheckX + 8,
                            CheckY - 4,
                            White,
                            204,
                            1.5,
                            Opacity.text * RowAlpha
                        )
                    end
                    if Clicked and RowHovered and not Dropdown.closing then
                        Dropdown._pressRow = RowIndex
                        Dropdown._pressT = Now + 0.3
                        if Dropdown.multi then
                            local List = ToList(Dropdown.value)
                            local RemoveIndex
                            for Index = #List, 1, -1 do
                                if List[Index] == Choice then
                                    RemoveIndex = Index
                                end
                            end
                            if RemoveIndex then
                                TableRemove(List, RemoveIndex)
                            elseif not Dropdown.item.maxSelections or #List < Dropdown.item.maxSelections then
                                List[#List + 1] = Choice
                            end
                            SetDropdownValue(Dropdown.item, List, true)
                            Dropdown.value = Dropdown.item.value
                        else
                            SetDropdownValue(Dropdown.item, {Choice}, true)
                            Dropdown.closing = true
                            State.focus = nil
                        end
                        Clicked = false
                    end
                end
            end
        end
        local MaxOffset = MathMax(0, #Choices - VisibleRows)
        if Dropdown._sbDrag and not Keys.m1.held then
            Dropdown._sbDrag = nil
        end
        if MaxOffset > 0 then
            local TrackTop, TrackHeight, TrackX = ListTop + 1, VisibleRows * RowH - 4, X + Width - 6
            FillRect(TrackX, TrackTop, 3, TrackHeight, White, 204, 2, 0.05 * Anim)
            local ThumbHeight = MathMax(22, TrackHeight * VisibleRows / #Choices)
            local ScrollFraction = Dropdown.scrollOffset / MaxOffset
            local ThumbTop = TrackTop + (TrackHeight - ThumbHeight) * ScrollFraction
            Dropdown._sbY = Approach(Dropdown._sbY or ThumbTop, ThumbTop, 18)
            if MathAbs(Dropdown._sbY - ThumbTop) < 0.1 then
                Dropdown._sbY = ThumbTop
            end
            local TrackHovered = IsMouseInside(TrackX - 6, TrackTop, 12, TrackHeight) or Dropdown._sbDrag
            Dropdown._sbHf = Approach(Dropdown._sbHf or 0, TrackHovered and 1 or 0, 14)
            if MathAbs(Dropdown._sbHf - (TrackHovered and 1 or 0)) < 0.004 then
                Dropdown._sbHf = TrackHovered and 1 or 0
            end
            local ThumbColor = LerpColor(Theme.accentA, Theme.accentB, ScrollFraction)
            FillRect(
                TrackX - 1.5,
                Dropdown._sbY - 2,
                7,
                ThumbHeight + 4,
                ThumbColor,
                205,
                3.5,
                0.18 * Dropdown._sbHf * Anim
            )
            FillRect(
                TrackX,
                Dropdown._sbY,
                4,
                ThumbHeight,
                LerpColor(White, ThumbColor, 0.75),
                205,
                2,
                (0.25 + 0.45 * Dropdown._sbHf) * Anim
            )
            if Clicked and IsMouseInside(TrackX - 6, TrackTop, 12, TrackHeight) then
                Dropdown._sbDrag = true
                Clicked = false
            end
            if Dropdown._sbDrag and Keys.m1.held then
                local Fraction =
                    Clamp((State.mouseY - TrackTop - ThumbHeight / 2) / MathMax(1, TrackHeight - ThumbHeight), 0, 1)
                Dropdown.scrollOffset = MathFloor(Fraction * MaxOffset + 0.5)
            end
        end
        if Dropdown.multi and RightClicked and Hovered then
            Dropdown.ctx = {x = State.mouseX, y = State.mouseY}
            RightClicked = false
        end
        if Dropdown.ctx then
            local CenterX, CenterY, CharWidth = Dropdown.ctx.x, Dropdown.ctx.y, 110
            FillRect(CenterX, CenterY, CharWidth, 52, Theme.bg, 206, 6, 0.98 * Anim)
            StrokeRect(CenterX, CenterY, CharWidth, 52, White, 207, 6, Opacity.cardStrk * Anim)
            for Index, Object in ipairs({"Select All", "Clear All"}) do
                local ButtonY = CenterY + 4 + (Index - 1) * 24
                local ButtonHovered = IsMouseInside(CenterX + 3, ButtonY, CharWidth - 6, 22)
                FillRect(CenterX + 3, ButtonY, CharWidth - 6, 22, White, 207, 5, (ButtonHovered and 0.05 or 0) * Anim)
                DrawText(
                    Object,
                    CenterX + 10,
                    CenterTextY(ButtonY, 22, 12),
                    White,
                    12,
                    FontSystem,
                    208,
                    false,
                    false,
                    CharWidth - 16,
                    Opacity.label * Anim
                )
                if Clicked and ButtonHovered then
                    if Index == 1 then
                        local List = {}
                        for _, Entry in ipairs(Dropdown.choices) do
                            if not Dropdown.item.maxSelections or #List < Dropdown.item.maxSelections then
                                List[#List + 1] = Entry
                            end
                        end
                        SetDropdownValue(Dropdown.item, List, true)
                    else
                        SetDropdownValue(Dropdown.item, {}, true)
                    end
                    Dropdown.value = Dropdown.item.value
                    Dropdown.ctx = nil
                    Clicked = false
                end
            end
            if Clicked and not IsMouseInside(CenterX - 4, CenterY - 4, CharWidth + 8, 60) then
                Dropdown.ctx = nil
                Clicked = false
            end
        end
        if Clicked and not Hovered and not Dropdown.ctx and not Dropdown.closing then
            Dropdown.closing = true
            State.focus = nil
            Clicked = false
        end
        return Clicked, RightClicked
    end
    local function DrawColorpicker(Clicked, Held)
        local Colorpicker = State.colorpicker
        if not Colorpicker then
            return Clicked
        end
        local CpCache = State._cpCache
        if not CpCache then
            CpCache = {}
            State._cpCache = CpCache
        end
        Colorpicker.anim = Approach(Colorpicker.anim or 0, 1, 22)
        local Anim = Colorpicker.anim
        local Padding = 12
        local ContentWidth = Colorpicker.w - Padding * 2
        local AreaHeight = 128
        local BarHeight, RowHeightSmall = 10, 22
        local PickerHeight = Padding + AreaHeight + 14 + BarHeight + 14 + BarHeight + 14 + RowHeightSmall + Padding
        local ViewportWidth, ViewportHeight = GetViewportSize()
        Colorpicker.y = Clamp(Colorpicker.y, 8, MathMax(8, ViewportHeight - PickerHeight - 8))
        local X = Colorpicker.x
        local Y = Colorpicker.y + (1 - Anim) * -6
        local AccentMid = State._accentMid
        FillRect(X - 3, Y - 3, Colorpicker.w + 6, PickerHeight + 6, NewColor(0, 0, 0), 209, 12, 0.30 * Anim)
        FillRect(X, Y, Colorpicker.w, PickerHeight, Theme.bg, 210, 9, 0.98 * Anim)
        StrokeRect(X, Y, Colorpicker.w, PickerHeight, White, 211, 9, Opacity.cardStrk * Anim)
        local function ApplyColor()
            local CurrentColor = ColorFromHsv(Colorpicker.hue, Colorpicker.sat, Colorpicker.val)
            Colorpicker.picker.value = CurrentColor
            Colorpicker.picker.alpha = Colorpicker.alpha
            SafeCall(Colorpicker.picker.callback, CurrentColor, Colorpicker.alpha)
        end
        local CenterY = Y + Padding
        local AreaX, AreaY = X + Padding, CenterY
        local HueY = AreaY + AreaHeight + 14
        local AlphaY = HueY + BarHeight + 14
        local BarSlices = Clamp(MathFloor(ContentWidth), 40, 170)
        local EditingHex = Colorpicker.hexInput ~= nil
        if Held and not EditingHex then
            local Changed = false
            if State.cpDrag == "sv" or IsMouseInside(AreaX, AreaY, ContentWidth, AreaHeight) then
                State.cpDrag = "sv"
                Colorpicker.sat = Clamp((State.mouseX - AreaX) / ContentWidth, 0, 1)
                Colorpicker.val = Clamp(1 - (State.mouseY - AreaY) / AreaHeight, 0, 1)
                Changed = true
            elseif State.cpDrag == "hue" or IsMouseInside(AreaX - 4, HueY - 4, ContentWidth + 8, BarHeight + 8) then
                State.cpDrag = "hue"
                Colorpicker.hue = Clamp((State.mouseX - AreaX) / ContentWidth, 0, 1)
                Changed = true
            elseif State.cpDrag == "alpha" or IsMouseInside(AreaX - 4, AlphaY - 4, ContentWidth + 8, BarHeight + 8) then
                State.cpDrag = "alpha"
                Colorpicker.alpha = Clamp((State.mouseX - AreaX) / ContentWidth, 0, 1)
                Changed = true
            end
            if Changed then
                local NewCaret = ColorFromHsv(Colorpicker.hue, Colorpicker.sat, Colorpicker.val)
                if
                    ColorsDiffer(Colorpicker.picker.value, NewCaret) or
                        MathAbs((Colorpicker.picker.alpha or 1) - Colorpicker.alpha) > 0.001
                 then
                    ApplyColor()
                end
            end
        end
        if not Held then
            State.cpDrag = nil
        end
        local CurrentColor = ColorFromHsv(Colorpicker.hue, Colorpicker.sat, Colorpicker.val)
        local HueColor = ColorFromHsv(Colorpicker.hue, 1, 1)
        local Steps = Clamp(MathFloor(ContentWidth), 40, 170)
        if not CpCache.sv or CpCache.svHue ~= Colorpicker.hue or CpCache.svN ~= Steps then
            CpCache.svHue = Colorpicker.hue
            CpCache.svN = Steps
            local Kind = {}
            for Index = 0, Steps - 1 do
                Kind[Index] = LerpColor(White, HueColor, Index / (Steps - 1))
            end
            CpCache.sv = Kind
        end
        local HueColumns = CpCache.sv
        for Index = 0, Steps - 1 do
            local SliceX = MathFloor(AreaX + ContentWidth * Index / Steps + 0.5)
            local X1 = MathFloor(AreaX + ContentWidth * (Index + 1) / Steps + 0.5)
            if X1 > SliceX then
                FillRect(SliceX, AreaY, X1 - SliceX, AreaHeight, HueColumns[Index], 212, 0, Anim)
            end
        end
        local Rows = Clamp(MathFloor(AreaHeight), 40, 150)
        for Index = 1, Rows - 1 do
            local RowY1 = MathFloor(AreaY + AreaHeight * Index / Rows + 0.5)
            local Y1 = MathFloor(AreaY + AreaHeight * (Index + 1) / Rows + 0.5)
            if Y1 > RowY1 then
                FillRect(
                    AreaX,
                    RowY1,
                    ContentWidth,
                    Y1 - RowY1,
                    NewColor(0, 0, 0),
                    213,
                    0,
                    Index / (Rows - 1) * 0.92 * Anim
                )
            end
        end
        StrokeRect(AreaX, AreaY, ContentWidth, AreaHeight, NewColor(0, 0, 0), 214, 4, 0.25 * Anim)
        local CursorX, CursorY = AreaX + Colorpicker.sat * ContentWidth, AreaY + (1 - Colorpicker.val) * AreaHeight
        DrawCircle(CursorX, CursorY, 7.5, NewColor(0, 0, 0), 214, false, 2, 26, 0.45 * Anim)
        DrawCircle(CursorX, CursorY, 7, White, 215, false, 2.4, 26, Anim)
        DrawCircle(CursorX, CursorY, 4.5, CurrentColor, 216, true, 1, 26, Anim)
        if not CpCache.hueBar or CpCache.hueBarN ~= BarSlices then
            CpCache.hueBarN = BarSlices
            local Kind = {}
            for Index = 0, BarSlices - 1 do
                Kind[Index] = ColorFromHsv(Index / (BarSlices - 1), 1, 1)
            end
            CpCache.hueBar = Kind
        end
        local HueBar = CpCache.hueBar
        local HalfBar = BarHeight / 2
        FillRect(AreaX, HueY, ContentWidth, BarHeight, HueBar[0], 213, BarHeight / 2, Anim)
        for Index = 0, BarSlices - 1 do
            local SliceX = MathFloor(AreaX + HalfBar + (ContentWidth - 2 * HalfBar) * Index / BarSlices + 0.5)
            local X1 = MathFloor(AreaX + HalfBar + (ContentWidth - 2 * HalfBar) * (Index + 1) / BarSlices + 0.5)
            if X1 > SliceX then
                FillRect(SliceX, HueY, X1 - SliceX, BarHeight, HueBar[Index], 214, 0, Anim)
            end
        end
        local HueX = AreaX + Colorpicker.hue * ContentWidth
        DrawCircle(HueX, HueY + BarHeight / 2, 7, NewColor(0, 0, 0), 214, false, 2, 24, 0.3 * Anim)
        DrawCircle(HueX, HueY + BarHeight / 2, 6.5, White, 215, true, 1, 24, Anim)
        DrawCircle(HueX, HueY + BarHeight / 2, 4.5, HueColor, 216, true, 1, 24, Anim)
        FillRect(AreaX, AlphaY, ContentWidth, BarHeight, NewColor(70, 70, 70), 213, BarHeight / 2, Anim)
        for Index = 0, BarSlices - 1 do
            local SliceX = MathFloor(AreaX + ContentWidth * Index / BarSlices + 0.5)
            local X1 = MathFloor(AreaX + ContentWidth * (Index + 1) / BarSlices + 0.5)
            local Red = (Index == 0 or Index == BarSlices - 1) and BarHeight / 2 or 0
            if X1 > SliceX then
                FillRect(SliceX, AlphaY, X1 - SliceX, BarHeight, CurrentColor, 214, Red, Index / (BarSlices - 1) * Anim)
            end
        end
        local AlphaX = AreaX + Colorpicker.alpha * ContentWidth
        DrawCircle(AlphaX, AlphaY + BarHeight / 2, 7, NewColor(0, 0, 0), 214, false, 2, 24, 0.3 * Anim)
        DrawCircle(AlphaX, AlphaY + BarHeight / 2, 6.5, White, 215, true, 1, 24, Anim)
        DrawCircle(
            AlphaX,
            AlphaY + BarHeight / 2,
            4.5,
            CurrentColor,
            216,
            true,
            1,
            24,
            Anim * (0.4 + 0.6 * Colorpicker.alpha)
        )
        CenterY = AlphaY + BarHeight + 14
        local Y2 = CenterY
        FillRect(AreaX, Y2, 22, RowHeightSmall, NewColor(50, 50, 50), 213, 7, Anim)
        FillRect(AreaX, Y2, 22, RowHeightSmall, CurrentColor, 214, 7, Anim * Colorpicker.alpha)
        StrokeRect(AreaX, Y2, 22, RowHeightSmall, White, 214, 7, Opacity.hairline * Anim)
        local FormatX, FormatWidth = AreaX + 28, 40
        local FormatHovered = IsMouseInside(FormatX, Y2, FormatWidth, RowHeightSmall)
        FillRect(
            FormatX,
            Y2,
            FormatWidth,
            RowHeightSmall,
            White,
            213,
            5,
            (FormatHovered and 0.09 or Opacity.field) * Anim
        )
        DrawText(
            Colorpicker.fmt,
            FormatX + 7,
            CenterTextY(Y2, RowHeightSmall, 11),
            White,
            11,
            FontBold,
            214,
            false,
            false,
            nil,
            Opacity.text * Anim
        )
        do
            local ArrowX = FormatX + FormatWidth - 11
            local ArrowY = Y2 + RowHeightSmall / 2 - 1
            DrawLine(ArrowX, ArrowY, ArrowX + 3, ArrowY + 3, White, 214, 1.2, Opacity.dim * Anim)
            DrawLine(ArrowX + 3, ArrowY + 3, ArrowX + 6, ArrowY, White, 214, 1.2, Opacity.dim * Anim)
        end
        if Clicked and FormatHovered then
            Colorpicker.fmt = Colorpicker.fmt == "HEX" and "RGB" or "HEX"
            Colorpicker.hexInput = nil
            if State.focus == Colorpicker then
                State.focus = nil
            end
            Clicked = false
        end
        local AlphaLabelWidth = 42
        local HexX = FormatX + FormatWidth + 8
        local HexWidth = AreaX + ContentWidth - AlphaLabelWidth - 4 - HexX
        local HexText =
            ColorToHex(CurrentColor) ..
            ((Colorpicker.alpha or 1) < 0.999 and
                string.format("%02X", MathFloor(Clamp(Colorpicker.alpha, 0, 1) * 255 + 0.5)) or
                "")
        local DisplayText
        if EditingHex then
            DisplayText = Colorpicker.fmt == "RGB" and Colorpicker.hexInput or "#" .. Colorpicker.hexInput
        elseif Colorpicker.fmt == "RGB" then
            DisplayText =
                string.format(
                "%d, %d, %d",
                MathFloor(CurrentColor.R * 255 + 0.5),
                MathFloor(CurrentColor.G * 255 + 0.5),
                MathFloor(CurrentColor.B * 255 + 0.5)
            )
        else
            DisplayText = HexText
        end
        local HexHovered = IsMouseInside(HexX, Y2, HexWidth, RowHeightSmall)
        FillRect(
            HexX,
            Y2,
            HexWidth,
            RowHeightSmall,
            White,
            213,
            5,
            (EditingHex and 0.10 or (HexHovered and 0.06 or Opacity.field)) * Anim
        )
        if EditingHex then
            DrawEditableText(
                Colorpicker,
                Colorpicker.hexInput,
                HexX + 8,
                CenterTextY(Y2, RowHeightSmall, 12),
                12,
                White,
                Opacity.text * Anim,
                214,
                HexWidth - 16,
                true,
                Colorpicker.caret,
                Colorpicker.selA
            )
        else
            DrawText(
                DisplayText,
                HexX + 8,
                CenterTextY(Y2, RowHeightSmall, 12),
                White,
                12,
                FontMonospace,
                214,
                false,
                false,
                HexWidth - 14,
                Opacity.text * Anim
            )
        end
        DrawText(
            MathFloor(Colorpicker.alpha * 100 + 0.5) .. "%",
            AreaX + ContentWidth - AlphaLabelWidth + 4,
            CenterTextY(Y2, RowHeightSmall, 12),
            White,
            12,
            FontSystem,
            214,
            false,
            false,
            AlphaLabelWidth - 6,
            Opacity.label * Anim
        )
        local function CommitHex()
            if Colorpicker.fmt == "RGB" then
                local Result, Value, Value2 = string.match(Colorpicker.hexInput or "", "(%d+)%D+(%d+)%D+(%d+)")
                if Result then
                    local Color =
                        NewColor(
                        Clamp(tonumber(Result), 0, 255),
                        Clamp(tonumber(Value), 0, 255),
                        Clamp(tonumber(Value2), 0, 255)
                    )
                    local Hue, Saturation, Brightness = ColorToHsv(Color)
                    Colorpicker.hue = Hue
                    Colorpicker.sat = Saturation
                    Colorpicker.val = Brightness
                    ApplyColor()
                end
            else
                local Value = string.gsub(tostring(Colorpicker.hexInput or ""), "[^0-9a-fA-F]", "")
                local Cache = HexToColor(Colorpicker.hexInput)
                if Cache then
                    local Hue, Saturation, Brightness = ColorToHsv(Cache)
                    Colorpicker.hue = Hue
                    Colorpicker.sat = Saturation
                    Colorpicker.val = Brightness
                    if #Value >= 8 then
                        local AlphaByte = tonumber(string.sub(Value, 7, 8), 16)
                        if AlphaByte then
                            Colorpicker.alpha = AlphaByte / 255
                        end
                    end
                    ApplyColor()
                end
            end
            Colorpicker.hexInput = nil
        end
        if Clicked and HexHovered and not EditingHex then
            if Colorpicker.fmt == "RGB" then
                Colorpicker.hexInput =
                    string.format(
                    "%d, %d, %d",
                    MathFloor(CurrentColor.R * 255 + 0.5),
                    MathFloor(CurrentColor.G * 255 + 0.5),
                    MathFloor(CurrentColor.B * 255 + 0.5)
                )
            else
                Colorpicker.hexInput = string.sub(string.gsub(HexText, "#", ""), 1, 8)
            end
            Colorpicker.caret = #Colorpicker.hexInput
            Colorpicker.selA = 0
            Colorpicker._ex = HexX + 8
            Colorpicker._ecw = GetCharWidth(12)
            Colorpicker._es = 0
            State.cpHexDrag = true
            State.focus = Colorpicker
            Clicked = false
        elseif EditingHex then
            if Keys.enter.click then
                CommitHex()
                State.focus = nil
                Keys.enter.click = false
            elseif Keys.esc.click then
                Colorpicker.hexInput = nil
                State.focus = nil
                Keys.esc.click = false
            elseif Clicked and not IsMouseInside(X - 4, Y - 4, Colorpicker.w + 8, PickerHeight + 8) then
                CommitHex()
                State.focus = nil
            else
                HandleTextInput(Colorpicker, "hexInput", false, Colorpicker.fmt ~= "RGB")
            end
        end
        if EditingHex and Keys.m1.held and State.cpHexDrag then
            Colorpicker.caret = CaretFromX(Colorpicker, Colorpicker.hexInput, State.mouseX)
        end
        if not Held then
            State.cpHexDrag = nil
        end
        if Clicked and not IsMouseInside(X - 4, Y - 4, Colorpicker.w + 8, PickerHeight + 8) then
            State.colorpicker = nil
            if State.focus == Colorpicker then
                State.focus = nil
            end
            Clicked = false
        end
        return Clicked
    end
    local KeybindModes = {"Hold", "Toggle", "Always"}
    local function DrawKeybindMenu(Clicked)
        local KeyMenu = State.keyMenu
        if not KeyMenu then
            return Clicked
        end
        KeyMenu.anim = Approach(KeyMenu.anim or 0, 1, 22)
        local Anim = KeyMenu.anim
        local Width, RowHeight = 96, 24
        local Height = #KeybindModes * RowHeight + 8
        local ViewportWidth, ViewportHeight = GetViewportSize()
        local X = Clamp(KeyMenu.x, 8, MathMax(8, ViewportWidth - Width - 8))
        local Y = Clamp(KeyMenu.y, 8, MathMax(8, ViewportHeight - Height - 8)) + (1 - Anim) * -6
        FillRect(X, Y, Width, Height, Theme.bg, 250, 8, 0.97 * Anim)
        StrokeRect(X, Y, Width, Height, White, 251, 8, Opacity.cardStrk * Anim)
        for Index, Mode in ipairs(KeybindModes) do
            local RowTop = Y + 4 + (Index - 1) * RowHeight
            local Selected = KeyMenu.kb.mode == Mode
            local Hovered = IsMouseInside(X + 4, RowTop, Width - 8, RowHeight - 2)
            FillRect(
                X + 4,
                RowTop,
                Width - 8,
                RowHeight - 2,
                White,
                252,
                6,
                ((Hovered or Selected) and (Selected and 0.06 or 0.04) or 0) * Anim
            )
            DrawText(
                Mode,
                X + 12,
                CenterTextY(RowTop, RowHeight - 2, 13),
                White,
                13,
                FontSystem,
                253,
                false,
                false,
                Width - 20,
                (Selected and Opacity.text or Opacity.label) * Anim
            )
            if Clicked and Hovered then
                KeyMenu.kb.mode = Mode
                State.keyMenu = nil
                Clicked = false
            end
        end
        if Clicked and not IsMouseInside(X - 4, Y - 4, Width + 8, Height + 8) then
            State.keyMenu = nil
            Clicked = false
        end
        return Clicked
    end
    local function DrawKeybindOverlay(Clicked, Held)
        if true then
            return Clicked
        end
        if not State._winReady then
            return Clicked
        end
        local Rows = {}
        for _, Item in ipairs(KeybindItems) do
            local Keybind = Item.keybind
            local Enabled = Keybind and Keybind.value and Keybind.value ~= "" and Item.value == true
            Item._hkA = Approach(Item._hkA or 0, Enabled and 1 or 0, 16)
            if Item._hkA > 0.02 then
                local Label = Item.label or ""
                local LowerLabel = string.lower(Label)
                if
                    (LowerLabel == "enabled" or LowerLabel == "enable" or LowerLabel == "active" or LowerLabel == "on") and
                        Item._secName and
                        Item._secName ~= ""
                 then
                    Label = Item._secName
                end
                Rows[#Rows + 1] = {
                    label = Label,
                    key = Keybind and Keybind.value and ComboDisplay(Keybind.value) or "",
                    ra = Item._hkA
                }
            end
        end
        local VisibleCount = 0
        for _, Result in ipairs(Rows) do
            VisibleCount = VisibleCount + Result.ra
        end
        State.hkFade = Approach(State.hkFade or 0, 1, 14)
        local HkFade = State.hkFade
        if HkFade < 0.02 then
            return Clicked
        end
        local Width, RowHeight = 180, 20
        local Height = 30 + (#Rows == 0 and 0 or VisibleCount * RowHeight) + 6
        State.hkPos = State.hkPos or {x = 18, y = 90}
        if Held and State.hkDrag then
            State.hkDrag.tx = State.mouseX - State.hkDrag.ox
            State.hkDrag.ty = State.mouseY - State.hkDrag.oy
        end
        if State.hkDrag and State.hkDrag.tx then
            State.hkPos.x = Approach(State.hkPos.x, State.hkDrag.tx, 28)
            State.hkPos.y = Approach(State.hkPos.y, State.hkDrag.ty, 28)
        end
        local ScreenWidth, ScreenHeight = GetViewportSize()
        State.hkPos.x = Clamp(State.hkPos.x, 0, MathMax(0, ScreenWidth - Width))
        State.hkPos.y = Clamp(State.hkPos.y, 0, MathMax(0, ScreenHeight - Height))
        local X, Y = State.hkPos.x, State.hkPos.y
        FillRect(X, Y, Width, Height, Theme.bg, 150, 8, 0.92 * HkFade)
        StrokeRect(X, Y, Width, Height, White, 151, 8, Opacity.cardStrk * HkFade)
        DrawText("keybinds", X + 12, Y + 9, White, 12, FontBold, 152, false, false, Width - 24, Opacity.text * HkFade)
        DrawGradient(X + 10, Y + 26, Width - 20, 2, Theme.accentA, Theme.accentB, 152, 0.9 * HkFade)
        local RowTop = Y + 30
        for _, Result in ipairs(Rows) do
            local RowAlpha = Result.ra * HkFade
            local Slide = (1 - Result.ra) * 12
            local RowTop2 = RowTop
            DrawCircle(X + 14 + Slide, RowTop2 + RowHeight / 2, 2.5, Theme.accentA, 152, true, 1, 10, RowAlpha)
            DrawText(
                Result.label,
                X + 22 + Slide,
                CenterTextY(RowTop2, RowHeight, 12),
                White,
                12,
                FontSystem,
                152,
                false,
                false,
                Width - 92,
                Opacity.text * RowAlpha
            )
            local Key = Result.key
            local KeyWidth = MathMax(18, MeasureText(Key, 11, FontMonospace) + 12)
            local KeyX = X + Width - 10 - KeyWidth + Slide
            FillRect(KeyX, RowTop2 + 2, KeyWidth, RowHeight - 4, White, 152, 4, Opacity.field * RowAlpha)
            DrawCenteredText(
                Key,
                KeyX + KeyWidth / 2,
                RowTop2 + RowHeight / 2,
                White,
                11,
                FontMonospace,
                153,
                Opacity.text * RowAlpha
            )
            RowTop = RowTop + RowHeight * Result.ra
        end
        if Clicked and not State.hkDrag and IsMouseInside(X, Y, Width, 28) then
            State.hkDrag = {ox = State.mouseX - X, oy = State.mouseY - Y}
            Clicked = false
        end
        return Clicked
    end
    local function FuzzyScore(Query, Target)
        local QueryLength, TargetLength = #Query, #Target
        if QueryLength == 0 then
            return 0
        end
        local QueryIndex, TargetIndex, FirstMatch, Left, Gaps = 1, 1, nil, 0, 0
        while QueryIndex <= QueryLength and TargetIndex <= TargetLength do
            if string.sub(Query, QueryIndex, QueryIndex) == string.sub(Target, TargetIndex, TargetIndex) then
                if not FirstMatch then
                    FirstMatch = TargetIndex
                elseif TargetIndex - Left > 1 then
                    Gaps = Gaps + 1
                end
                Left = TargetIndex
                QueryIndex = QueryIndex + 1
            end
            TargetIndex = TargetIndex + 1
        end
        if QueryIndex <= QueryLength then
            return nil
        end
        local WordBonus = (FirstMatch == 1 or string.sub(Target, FirstMatch - 1, FirstMatch - 1) == " ") and -1 or 0
        return FirstMatch - 1 + Gaps * 4 + WordBonus
    end
    local function SearchItems(Query)
        Query = string.lower(Query or "")
        local Result = {}
        for Key, Tab in ipairs(State.tabs) do
            for _, Entry in ipairs(Tab.sections) do
                for _, Item in ipairs(Entry.items) do
                    if Item.label and Item.type ~= "divider" and Item.type ~= "label" then
                        local Score = Query == "" and 0 or FuzzyScore(Query, string.lower(Item.label))
                        if Score then
                            Result[#Result + 1] = {
                                tab = Tab,
                                ti = Key,
                                item = Item,
                                label = Item.label,
                                sub = Tab.name .. "  >  " .. Entry.name,
                                type = Item.type,
                                score = Score
                            }
                        end
                    end
                end
            end
        end
        table.sort(
            Result,
            function(ValueA, ValueB)
                if ValueA.score ~= ValueB.score then
                    return ValueA.score < ValueB.score
                end
                return ValueA.label < ValueB.label
            end
        )
        return Result
    end
    local function JumpToSearchResult(Result)
        if not Result then
            return
        end
        if State.activeTab ~= Result.tab then
            State.activeTab = Result.tab
            State.activeIndex = Result.ti
            State.contentFade = 0
        end
        State.minimized = false
        SetOpen(true)
        Result.item._flash = (Clock() or 0) + 1.3
        State._spotScrollTo = Result.item
        State.spotlightOpen = false
    end
    local function DrawSpotlight(Clicked)
        local Spotlight = State.spotlight
        if not Spotlight then
            Spotlight = {query = "", sel = 1}
            State.spotlight = Spotlight
        end
        State.spotlightFade = Approach(State.spotlightFade or 0, State.spotlightOpen and 1 or 0, 16)
        local SpotlightFade = State.spotlightFade
        if SpotlightFade < 0.02 then
            return Clicked
        end
        if State.spotlightOpen then
            if Keys.esc.click then
                State.spotlightOpen = false
                Keys.esc.click = false
            end
            if HandleTextInput(Spotlight, "query", false) then
                Spotlight.sel = 1
            end
        end
        if Spotlight.query ~= Spotlight._resQ then
            Spotlight._resQ = Spotlight.query
            Spotlight._results = SearchItems(Spotlight.query)
        end
        local Results = Spotlight._results
        Spotlight.sel = Clamp(Spotlight.sel or 1, 1, MathMax(1, #Results))
        if State.spotlightOpen then
            if Keys.down.click then
                Spotlight.sel = MathMin(#Results, Spotlight.sel + 1)
                Keys.down.click = false
            end
            if Keys.up.click then
                Spotlight.sel = MathMax(1, Spotlight.sel - 1)
                Keys.up.click = false
            end
            if Keys.enter.click then
                JumpToSearchResult(Results[Spotlight.sel])
                Keys.enter.click = false
                return Clicked
            end
        end
        local ViewportWidth, ViewportHeight = GetViewportSize()
        local BoxWidth, RowHeight, VisibleRows = 470, 34, 7
        local ShownRows = MathMin(#Results, VisibleRows)
        local BoxHeight = 50 + (ShownRows > 0 and ShownRows * RowHeight + 8 or 30)
        local BoxX, BoxY = MathFloor((ViewportWidth - BoxWidth) / 2), MathFloor(ViewportHeight * 0.16)
        FillRect(0, 0, ViewportWidth, ViewportHeight, NewColor(0, 0, 0), 398, 0, 0.4 * SpotlightFade)
        FillRect(BoxX, BoxY, BoxWidth, BoxHeight, Theme.bg, 400, 12, 0.97 * SpotlightFade)
        StrokeRect(BoxX, BoxY, BoxWidth, BoxHeight, White, 401, 12, Opacity.cardStrk * SpotlightFade)
        DrawCircle(BoxX + 24, BoxY + 21, 6, White, 402, false, 1.5, 16, Opacity.label * SpotlightFade)
        DrawLine(BoxX + 28, BoxY + 25, BoxX + 33, BoxY + 30, White, 402, 1.5, Opacity.label * SpotlightFade)
        DrawGradient(BoxX + 14, BoxY + 46, BoxWidth - 28, 2, Theme.accentA, Theme.accentB, 402, 0.7 * SpotlightFade)
        local TextX = BoxX + 44
        if Spotlight.query == "" and not State.spotlightOpen then
            DrawText(
                "Search widgets...",
                TextX,
                CenterTextY(BoxY, 46, 15),
                White,
                15,
                FontSystem,
                402,
                false,
                false,
                BoxWidth - 60,
                0.3 * SpotlightFade
            )
        else
            DrawEditableText(
                Spotlight,
                Spotlight.query,
                TextX,
                CenterTextY(BoxY, 46, 15),
                15,
                White,
                Opacity.text * SpotlightFade,
                402,
                BoxWidth - 60,
                State.spotlightOpen,
                Spotlight.caret,
                Spotlight.selA
            )
        end
        if State.spotlightOpen then
            if Clicked and IsMouseInside(BoxX + 36, BoxY, BoxWidth - 50, 46) then
                Spotlight.caret = CaretFromX(Spotlight, Spotlight.query, State.mouseX)
                Spotlight.selA = Spotlight.caret
                State.spTextDrag = true
                Clicked = false
            end
            if Keys.m1.held and State.spTextDrag then
                Spotlight.caret = CaretFromX(Spotlight, Spotlight.query, State.mouseX)
            end
        end
        if #Results == 0 then
            DrawText(
                "no matches",
                BoxX + 18,
                BoxY + 62,
                White,
                13,
                FontSystem,
                402,
                false,
                false,
                BoxWidth - 36,
                Opacity.dim * SpotlightFade
            )
        end
        local AccentMid = State._accentMid
        local MaxOffset = MathMax(0, #Results - VisibleRows)
        Spotlight._off = Clamp(Spotlight._off or 0, 0, MaxOffset)
        if Spotlight.sel - 1 < Spotlight._off then
            Spotlight._off = Spotlight.sel - 1
        end
        if Spotlight.sel - 1 > Spotlight._off + VisibleRows - 1 then
            Spotlight._off = Spotlight.sel - VisibleRows
        end
        Spotlight._off = Clamp(Spotlight._off, 0, MaxOffset)
        Spotlight._sy = Approach(Spotlight._sy or Spotlight._off, Spotlight._off, 16)
        local ScrollPos = Spotlight._sy
        local ListTop, ListHeight = BoxY + 50, VisibleRows * RowHeight
        local HasScrollbar = #Results > VisibleRows
        local Width = HasScrollbar and BoxWidth - 24 or BoxWidth - 16
        local MouseMoved = State.mouseX ~= Spotlight._mx or State.mouseY ~= Spotlight._my
        Spotlight._mx, Spotlight._my = State.mouseX, State.mouseY
        for Row = 0, VisibleRows do
            local RowIndex = MathFloor(ScrollPos) + Row
            local Result = RowIndex >= 0 and Results[RowIndex + 1] or nil
            if Result then
                local RowTop = ListTop + (RowIndex - ScrollPos) * RowHeight
                if RowTop + RowHeight > ListTop and RowTop < ListTop + ListHeight then
                    local ClipFade =
                        Clamp((RowTop + RowHeight - ListTop) / RowHeight, 0, 1) *
                        Clamp((ListTop + ListHeight - RowTop) / RowHeight, 0, 1)
                    local RowAlpha = SpotlightFade * ClipFade
                    local InView = RowTop >= ListTop - 2 and RowTop + RowHeight <= ListTop + ListHeight + 2
                    local Hovered = InView and IsMouseInside(BoxX + 8, RowTop, Width, RowHeight)
                    if Hovered and MouseMoved and not Spotlight._sbDrag then
                        Spotlight.sel = RowIndex + 1
                    end
                    local IsSelected = RowIndex + 1 == Spotlight.sel
                    FillRect(
                        BoxX + 8,
                        RowTop + 1,
                        Width,
                        RowHeight - 2,
                        AccentMid,
                        401,
                        8,
                        (IsSelected and 0.1 or 0) * RowAlpha
                    )
                    FillRect(
                        BoxX + 8,
                        RowTop + 1,
                        3,
                        RowHeight - 2,
                        AccentMid,
                        402,
                        1.5,
                        (IsSelected and 0.9 or 0) * RowAlpha
                    )
                    DrawText(
                        Result.label,
                        BoxX + 18,
                        RowTop + 6,
                        White,
                        14,
                        FontBold,
                        402,
                        false,
                        false,
                        BoxWidth - 150,
                        Opacity.text * RowAlpha
                    )
                    DrawText(
                        Result.sub,
                        BoxX + 18,
                        RowTop + 19,
                        White,
                        11,
                        FontSystem,
                        402,
                        false,
                        false,
                        BoxWidth - 150,
                        Opacity.dim * RowAlpha
                    )
                    DrawText(
                        Result.type,
                        BoxX + Width - 4 - MeasureText(Result.type, 11, FontSystem),
                        CenterTextY(RowTop, RowHeight, 11),
                        White,
                        11,
                        FontSystem,
                        402,
                        false,
                        false,
                        nil,
                        Opacity.dim * RowAlpha
                    )
                    if InView and Clicked and Hovered then
                        JumpToSearchResult(Result)
                        Clicked = false
                    end
                end
            end
        end
        if Spotlight._sbDrag and not Keys.m1.held then
            Spotlight._sbDrag = nil
        end
        if MaxOffset > 0 then
            local TrackX = BoxX + BoxWidth - 7
            local ThumbHeight = MathMax(22, ListHeight * VisibleRows / #Results)
            local ScrollFraction = Spotlight._off / MaxOffset
            local ThumbY = ListTop + (ListHeight - ThumbHeight) * ScrollFraction
            FillRect(TrackX, ListTop, 3, ListHeight, White, 403, 2, 0.05 * SpotlightFade)
            local TrackHovered = IsMouseInside(TrackX - 6, ListTop, 12, ListHeight) or Spotlight._sbDrag
            Spotlight._sbHf = Approach(Spotlight._sbHf or 0, TrackHovered and 1 or 0, 14)
            if MathAbs(Spotlight._sbHf - (TrackHovered and 1 or 0)) < 0.004 then
                Spotlight._sbHf = TrackHovered and 1 or 0
            end
            local ThumbColor = LerpColor(Theme.accentA, Theme.accentB, ScrollFraction)
            FillRect(
                TrackX - 1.5,
                ThumbY - 2,
                7,
                ThumbHeight + 4,
                ThumbColor,
                404,
                3.5,
                0.18 * Spotlight._sbHf * SpotlightFade
            )
            FillRect(
                TrackX,
                ThumbY,
                4,
                ThumbHeight,
                LerpColor(White, ThumbColor, 0.75),
                404,
                2,
                (0.25 + 0.45 * Spotlight._sbHf) * SpotlightFade
            )
            if Clicked and IsMouseInside(TrackX - 6, ListTop, 12, ListHeight) then
                Spotlight._sbDrag = true
                Clicked = false
            end
            if Spotlight._sbDrag and Keys.m1.held then
                local Fraction =
                    Clamp((State.mouseY - ListTop - ThumbHeight / 2) / MathMax(1, ListHeight - ThumbHeight), 0, 1)
                Spotlight._off = Clamp(MathFloor(Fraction * MaxOffset + 0.5), 0, MaxOffset)
                Spotlight.sel = Clamp(Spotlight.sel, Spotlight._off + 1, Spotlight._off + VisibleRows)
            end
        end
        if Clicked and not IsMouseInside(BoxX, BoxY, BoxWidth, BoxHeight) then
            State.spotlightOpen = false
            Clicked = false
        end
        return Clicked
    end
    local function DrawBoxes(Clicked, Held)
        local Boxes = State.boxes
        if not Boxes or #Boxes == 0 then
            return Clicked
        end
        local Open = State.open
        for _, Box in ipairs(Boxes) do
            if Box.visible ~= false and Box.alive ~= false then
                local AccentMid = State._accentMid
                local Lines = {}
                local MaxWidth = MeasureText(Box.title or "Box", 12, FontBold) + 30
                for _, Line in ipairs(Box.lines) do
                    local Kind = Line.kind or "text"
                    if Kind == "stat" then
                        local Value = Line.value
                        if type(Value) == "function" then
                            local Success, Result = pcall(Value)
                            Value = Success and Result or ""
                        end
                        Value = tostring(Value == nil and "" or Value)
                        if Value ~= "" then
                            local Label, Value2 = Value:match("^(.-)%s+|%s+(.+)$")
                            if not Label then
                                Label, Value2 = Value:match("^(.-):%s+(.+)$")
                            end
                            if not Label then
                                Label, Value2 = "", Value
                            end
                            Lines[#Lines + 1] = {kind = "stat", label = Label, text = Value2, color = Line.color}
                            MaxWidth =
                                MathMax(
                                MaxWidth,
                                MeasureText(Label, 12, FontSystem) + MeasureText(Value2, 12, FontMonospace) + 70
                            )
                        end
                    elseif Kind == "bar" then
                        local Value = Line.value
                        if type(Value) == "function" then
                            local Success, Result = pcall(Value)
                            Value = Success and Result or nil
                        end
                        if Value ~= nil then
                            local List = tonumber(Value) or 0
                            local Percent = List > 0 and List <= 1 and List * 100 or List
                            Lines[#Lines + 1] = {kind = "bar", pct = Clamp(Percent, 0, 100), color = Line.color}
                            MaxWidth = MathMax(MaxWidth, 170)
                        end
                    else
                        local Value = Line.value
                        if type(Value) == "function" then
                            local Success, Result = pcall(Value)
                            Value = Success and Result or ""
                        end
                        Value = tostring(Value == nil and "" or Value)
                        Lines[#Lines + 1] = {kind = "text", text = Value, color = Line.color}
                        MaxWidth = MathMax(MaxWidth, MeasureText(Value, 12, FontSystem) + 24)
                    end
                end
                local HeaderHeight, LineHeight = 26, 18
                local Width = Box.width or MathMax(140, MaxWidth)
                local Height = HeaderHeight + #Lines * LineHeight + (#Lines > 0 and 8 or 4)
                Box.x = Box.x or 20
                Box.y = Box.y or 140
                if Box._drag and not Held then
                    Box._drag = nil
                end
                if Open and Held and Box._drag then
                    Box._drag.tx = State.mouseX - Box._drag.ox
                    Box._drag.ty = State.mouseY - Box._drag.oy
                end
                if Box._drag and Box._drag.tx then
                    Box.x = Approach(Box.x, Box._drag.tx, 28)
                    Box.y = Approach(Box.y, Box._drag.ty, 28)
                end
                local X, Y = Box.x, Box.y
                FillRect(X, Y, Width, Height, Theme.bg, 160, 8, 0.92)
                StrokeRect(X, Y, Width, Height, White, 161, 8, Opacity.cardStrk)
                DrawCircle(X + 15, Y + HeaderHeight / 2, 2.5, Theme.accentA, 162, true, 1, 10, 1)
                DrawText(
                    Box.title or "Box",
                    X + 24,
                    CenterTextY(Y, HeaderHeight, 12),
                    White,
                    12,
                    FontBold,
                    162,
                    false,
                    false,
                    Width - 34,
                    Opacity.text
                )
                DrawGradient(X + 10, Y + HeaderHeight - 1, Width - 20, 1.5, Theme.accentA, Theme.accentB, 162, 0.7)
                for Index, Line in ipairs(Lines) do
                    local RowTop = Y + HeaderHeight + 5 + (Index - 1) * LineHeight
                    if Line.kind == "stat" then
                        local Upper = string.upper(Line.text)
                        local IsReady = Upper:find("READY") or Upper:find("FARMING") or Upper:find("GO", 1, true)
                        local IsIdle =
                            Upper:find("PAUSED") or Upper:find("WAIT") or Upper:find("IDLE") or
                            Upper:find("OFF", 1, true) or
                            Upper:find("SOON") or
                            Upper == "--" or
                            Upper:match("^%d+:%d")
                        local DotColor =
                            IsReady and AccentMid or (IsIdle and NewColor(120, 122, 130) or NewColor(195, 197, 205))
                        local DotAlpha =
                            IsReady and 0.5 + 0.42 * MathSin((Clock() or 0) * 5) or (IsIdle and 0.7 or 0.85)
                        DrawCircle(X + 16, RowTop + 7, 3, DotColor, 163, true, 1, 12, DotAlpha)
                        DrawText(
                            Line.label,
                            X + 28,
                            RowTop,
                            White,
                            12,
                            FontSystem,
                            162,
                            false,
                            false,
                            Width - 110,
                            Opacity.label
                        )
                        DrawText(
                            Line.text,
                            X + Width - 12 - MeasureText(Line.text, 12, FontMonospace),
                            RowTop,
                            Line.color or White,
                            12,
                            FontMonospace,
                            162,
                            false,
                            false,
                            nil,
                            IsReady and Opacity.text or Opacity.label
                        )
                    elseif Line.kind == "bar" then
                        FillRect(X + 14, RowTop + 5, Width - 28, 6, White, 162, 3, Opacity.field)
                        if Line.pct > 0 then
                            FillRect(
                                X + 14,
                                RowTop + 5,
                                MathMax(6, (Width - 28) * Line.pct / 100),
                                6,
                                Theme.accentA,
                                163,
                                3,
                                0.95
                            )
                        end
                    else
                        DrawText(
                            Line.text,
                            X + 14,
                            RowTop,
                            Line.color or White,
                            12,
                            FontSystem,
                            162,
                            false,
                            false,
                            Width - 24,
                            Opacity.label
                        )
                    end
                end
                if Open and Clicked and not Box._drag and IsMouseInside(X, Y, Width, HeaderHeight) then
                    Box._drag = {ox = State.mouseX - X, oy = State.mouseY - Y}
                    Clicked = false
                end
            end
        end
        return Clicked
    end
    local function DrawMenuLogo(CenterX, CenterY, Size, Color, Alpha, ZIndex)
        local BarWidth, BarHeight, BarGap = Size * 0.62, Size * 0.1375, Size * 0.275
        local BarX = CenterX - BarWidth / 2
        FillRect(BarX, CenterY - BarGap - BarHeight / 2, BarWidth, BarHeight, Color, ZIndex, BarHeight / 2, Alpha)
        FillRect(BarX, CenterY - BarHeight / 2, BarWidth, BarHeight, Color, ZIndex, BarHeight / 2, Alpha)
        FillRect(BarX, CenterY + BarGap - BarHeight / 2, BarWidth, BarHeight, Color, ZIndex, BarHeight / 2, Alpha)
    end
    local function DrawMinimized(Clicked, Held)
        State.minA = Approach(State.minA or 0, State.minimized and 1 or 0, 11)
        local Alpha = State.minA * State.drawVisible
        if Alpha < 0.02 then
            return Clicked
        end
        State.minPos = State.minPos or {x = 24, y = 24}
        local MinBubbleDrag = State.minBubbleDrag
        if MinBubbleDrag then
            if Held then
                MinBubbleDrag.tx = State.mouseX - MinBubbleDrag.ox
                MinBubbleDrag.ty = State.mouseY - MinBubbleDrag.oy
                if math.abs(State.mouseX - MinBubbleDrag.downX) + math.abs(State.mouseY - MinBubbleDrag.downY) > 4 then
                    MinBubbleDrag.moved = true
                end
                State.minPos.x = Approach(State.minPos.x, MinBubbleDrag.tx, 28)
                State.minPos.y = Approach(State.minPos.y, MinBubbleDrag.ty, 28)
                local ScreenW, ScreenH = GetViewportSize()
                State.minPos.x = Clamp(State.minPos.x, 0, MathMax(0, ScreenW - 42))
                State.minPos.y = Clamp(State.minPos.y, 0, MathMax(0, ScreenH - 42))
            else
                if not MinBubbleDrag.moved then
                    State.x = State.minPos.x
                    State.y = State.minPos.y
                    ClampWindowToScreen()
                    State.minimized = false
                end
                State.minBubbleDrag = nil
            end
        end
        local DrawVisible = State.drawVisible
        local MinA = State.minA
        local Ease = MinA * MinA * (3 - 2 * MinA)
        local Size = 42
        local WindowX, WindowY, WindowWidth, WindowHeight = State.x, State.y, State.w, State.h
        local RestX, RestY = State.minPos.x, State.minPos.y
        local BubbleX = WindowX + (RestX - WindowX) * Ease
        local RowTop = WindowY + (RestY - WindowY) * Ease
        local BubbleWidth = WindowWidth + (Size - WindowWidth) * Ease
        local BubbleHeight = WindowHeight + (Size - WindowHeight) * Ease
        local BubbleRounding = 10 + 11 * Ease
        local CenterX, CenterY = BubbleX + BubbleWidth / 2, RowTop + BubbleHeight / 2
        local AccentMid = State._accentMid
        local BubbleReady = State.minA > 0.9
        local Hovered = BubbleReady and IsMouseInside(BubbleX, RowTop, BubbleWidth, BubbleHeight)
        State._minHov = Approach(State._minHov or 0, Hovered and 1 or 0, 12)
        local MinHov = State._minHov
        for Index = 1, 3 do
            local Object = Index * 3
            FillRect(
                BubbleX - Object,
                RowTop - Object + 2,
                BubbleWidth + Object * 2,
                BubbleHeight + Object * 2,
                NewColor(0, 0, 0),
                199,
                BubbleRounding + Object,
                (0.10 - Index * 0.025) * Ease * DrawVisible
            )
        end
        FillRect(
            BubbleX - 3,
            RowTop - 3,
            BubbleWidth + 6,
            BubbleHeight + 6,
            AccentMid,
            200,
            BubbleRounding + 2,
            0.25 * MinHov * DrawVisible
        )
        FillRect(
            BubbleX,
            RowTop,
            BubbleWidth,
            BubbleHeight,
            LerpColor(Theme.bg, AccentMid, Ease),
            201,
            BubbleRounding,
            (0.96 - 0.04 * Ease) * DrawVisible
        )
        FillRect(
            BubbleX,
            RowTop,
            BubbleWidth,
            BubbleHeight * 0.5,
            LerpColor(AccentMid, White, 0.14),
            202,
            BubbleRounding,
            0.22 * Ease * DrawVisible
        )
        StrokeRect(
            BubbleX,
            RowTop,
            BubbleWidth,
            BubbleHeight,
            White,
            203,
            BubbleRounding,
            (0.16 + 0.14 * Ease + 0.35 * MinHov) * DrawVisible
        )
        if Ease > 0.4 then
            local IconAlpha = Clamp((Ease - 0.4) / 0.6, 0, 1) * DrawVisible
            if State.iconImg then
                pcall(function()
                    local IconSize = BubbleWidth - 8
                    State.iconImg.Position = NewVector2(CenterX - IconSize / 2, CenterY - IconSize / 2)
                    State.iconImg.Size = NewVector2(IconSize, IconSize)
                    pcall(function()
                        State.iconImg.Rounding = BubbleRounding
                    end)
                    State.iconImg.ZIndex = 2049999
                    State.iconImg.Transparency = IconAlpha
                    State.iconImg.Visible = IconAlpha > 0.01
                end)
            else
                DrawMenuLogo(CenterX, CenterY, BubbleHeight, NewColor(36, 38, 50), IconAlpha, 204)
            end
        end
        if BubbleReady and Clicked and Hovered and not State.minBubbleDrag then
            State.minBubbleDrag = {
                ox = State.mouseX - BubbleX,
                oy = State.mouseY - RowTop,
                downX = State.mouseX,
                downY = State.mouseY,
                moved = false
            }
            Clicked = false
        end
        return Clicked
    end
    local function DrawThickLine(X1, Y1, X2, Y2, Thickness, Color, ZIndex, Alpha)
        local DeltaX, DeltaY = X2 - X1, Y2 - Y1
        local Length = MathSqrt(DeltaX * DeltaX + DeltaY * DeltaY)
        if Length < 0.001 then
            return
        end
        local NormalX, NormalY = -DeltaY / Length * Thickness / 2, DeltaX / Length * Thickness / 2
        local CornerA, CornerB = NewVector2(X1 + NormalX, Y1 + NormalY), NewVector2(X1 - NormalX, Y1 - NormalY)
        local CornerC, CornerD = NewVector2(X2 - NormalX, Y2 - NormalY), NewVector2(X2 + NormalX, Y2 + NormalY)
        DrawTriangle(CornerA, CornerB, CornerC, Color, ZIndex, true, Alpha)
        DrawTriangle(CornerA, CornerC, CornerD, Color, ZIndex, true, Alpha)
    end
    local function ItemHeight(Item)
        local Type = Item.type
        if Type == "slider" or Type == "rangeslider" then
            return 38
        elseif Type == "dropdown" then
            return State.dropdownInline and 26 or 44
        elseif Type == "textbox" then
            return 44
        elseif Type == "checkbox" then
            return 30
        elseif Type == "colorpicker" then
            return 26
        elseif Type == "label" then
            return MathMax(18, (Item.cachedLineCount or 1) * 16 + 2)
        elseif Type == "info" then
            return MathMax(16, (Item.cachedLineCount or 1) * 15 + 2)
        elseif Type == "button" then
            return 26
        elseif Type == "keybind" then
            return 30
        elseif Type == "image" then
            return (Item.imgHeight or 80) + 6
        elseif Type == "divider" then
            return 18
        end
        return 28
    end
    local function ShowTooltip(Text, X, Y)
        if not Text or Text == "" then
            return
        end
        State.tooltipText = Text
        State.tooltipX = X
        State.tooltipY = Y
        if State.lastTooltipText ~= Text then
            State.tooltipAt = Clock() or 0
        end
    end
    local function DrawItem(Item, X, Y, Width, Alpha, Clicked, RightClicked, Blocked)
        local Type = Item.type
        local Interactive = Alpha > 0.5 and not Blocked
        if Type == "label" then
            if Item.labelFn then
                local Success, Value = pcall(Item.labelFn)
                if Success and Value ~= nil then
                    Item.label = tostring(Value)
                end
            end
            local Font = ResolveUiFont(FontSystem)
            if Item._wrapW ~= Width or Item._wrapTxt ~= Item.label or Item._wrapF ~= Font then
                Item._wrapW = Width
                Item._wrapTxt = Item.label
                Item._wrapF = Font
                local WrappedLines = {}
                for RawLine in (Item.label .. "\n"):gmatch("(.-)\n") do
                    if RawLine == "" then
                        WrappedLines[#WrappedLines + 1] = ""
                    else
                        for _, Line in ipairs(WrapText(RawLine, Width, 13, Font)) do
                            WrappedLines[#WrappedLines + 1] = Line
                        end
                    end
                end
                Item._wrapLines = WrappedLines
                Item.cachedLineCount = MathMax(1, #WrappedLines)
            end
            local WrapLines = Item._wrapLines
            for Index = 1, #WrapLines do
                DrawText(
                    WrapLines[Index],
                    X,
                    Y + (Index - 1) * 16,
                    Item.color or White,
                    13,
                    FontSystem,
                    31,
                    false,
                    false,
                    nil,
                    0.7 * Alpha
                )
            end
        elseif Type == "info" then
            local Font = ResolveUiFont(FontSystem)
            if Item._wrapW ~= Width or Item._wrapTxt ~= Item.label or Item._wrapF ~= Font then
                Item._wrapW = Width
                Item._wrapTxt = Item.label
                Item._wrapF = Font
                local WrappedLines = {}
                for RawLine in (Item.label .. "\n"):gmatch("(.-)\n") do
                    if RawLine == "" then
                        WrappedLines[#WrappedLines + 1] = ""
                    else
                        for _, Line in ipairs(WrapText(RawLine, Width, 12, Font)) do
                            WrappedLines[#WrappedLines + 1] = Line
                        end
                    end
                end
                Item._wrapLines = WrappedLines
                Item.cachedLineCount = MathMax(1, #WrappedLines)
            end
            local WrapLines = Item._wrapLines
            for Index = 1, #WrapLines do
                DrawText(
                    WrapLines[Index],
                    X,
                    Y + (Index - 1) * 15,
                    Item.color or White,
                    12,
                    FontSystem,
                    31,
                    false,
                    false,
                    nil,
                    Opacity.dim * Alpha
                )
            end
        elseif Type == "divider" then
            local LineColor = MidColor(Theme.accentA, Theme.accentB, Y * 0.004)
            if Item.label then
                local CenterX = X + Width / 2
                local HalfWidth = MeasureText(Item.label, 12, FontSystem) / 2 + 8
                State.fadeLine(X, Y + 8, CenterX - HalfWidth - X, LineColor, 30, 0.45 * Alpha, true)
                DrawCenteredText(Item.label, CenterX, Y + 8, White, 12, FontSystem, 31, Opacity.dim * Alpha)
                State.fadeLine(
                    CenterX + HalfWidth,
                    Y + 8,
                    X + Width - (CenterX + HalfWidth),
                    LineColor,
                    30,
                    0.45 * Alpha
                )
            else
                local HalfWidth = Width / 2
                State.fadeLine(X, Y + 8, HalfWidth, LineColor, 30, 0.40 * Alpha, true)
                State.fadeLine(X + HalfWidth, Y + 8, HalfWidth, LineColor, 30, 0.40 * Alpha)
            end
        elseif Type == "button" then
            local ButtonHeight = 22
            local ButtonList = Item.buttons or {{label = Item.label, callback = Item.callback}}
            local ButtonCount = #ButtonList
            local Gap = 8
            local ButtonWidth = (Width - Gap * (ButtonCount - 1)) / ButtonCount
            for ButtonIndex, Value in ipairs(ButtonList) do
                local RestX = X + (ButtonIndex - 1) * (ButtonWidth + Gap)
                local Hovered = Interactive and IsMouseInside(RestX, Y, ButtonWidth, ButtonHeight)
                Value._hf = Approach(Value._hf or 0, Hovered and 1 or 0, 16)
                local HoverFade = Value._hf
                FillRect(RestX, Y, ButtonWidth, ButtonHeight, White, 30, 5, (Opacity.field + 0.06 * HoverFade) * Alpha)
                StrokeRect(
                    RestX,
                    Y,
                    ButtonWidth,
                    ButtonHeight,
                    White,
                    31,
                    5,
                    (Opacity.hairline + 0.22 * HoverFade) * Alpha
                )
                local TextAlpha = (Opacity.label + (Opacity.hover - Opacity.label) * HoverFade) * Alpha
                DrawCenteredText(
                    Value.label,
                    RestX + ButtonWidth / 2,
                    Y + ButtonHeight / 2,
                    Item.color or White,
                    13,
                    FontSystem,
                    32,
                    TextAlpha
                )
                if Item.tooltip and ButtonIndex == 1 and Hovered then
                    ShowTooltip(Item.tooltip, State.mouseX, State.mouseY)
                end
                if Clicked and Hovered then
                    SafeCall(Value.callback)
                    Clicked = false
                end
            end
        elseif Type == "checkbox" then
            local RightEdge = X + Width
            local PickerHovered, KeybindHovered = false, false
            local AccentColor = Item.risk and (Theme.unsafe or NewColor(255, 190, 70)) or State._accentMid
            local Enabled = Item.value and 1 or 0
            local BoxX
            if State.checkboxStyle then
                local Size = 18
                BoxX = X + Width - Size
                local BoxY = Y + 4
                local CenterX, CenterY = BoxX + Size / 2, BoxY + Size / 2
                local BoxHovered = Interactive and IsMouseInside(BoxX, BoxY, Size, Size) or false
                local BoxHover = BoxHovered and 1 or 0
                local BoxPressed = BoxHovered and Keys.m1.held and 1 or 0
                Item.animState = Approach(Item.animState or Enabled, Enabled, Item.value and 13 or 15)
                Item.cbG = Approach(Item.cbG or Enabled, Enabled, 34)
                Item.cbHv = Approach(Item.cbHv or 0, BoxHover, 12)
                Item.cbPr = Approach(Item.cbPr or 0, BoxPressed, 22)
                if Item.cbLast == nil then
                    Item.cbLast = Item.value
                end
                if Item.value ~= Item.cbLast then
                    Item.cbFl = 1
                    Item.cbLast = Item.value
                end
                Item.cbFl = Approach(Item.cbFl or 0, 0, 22)
                if MathAbs(Item.animState - Enabled) < 0.0005 then
                    Item.animState = Enabled
                end
                if MathAbs(Item.cbG - Enabled) < 0.0005 then
                    Item.cbG = Enabled
                end
                if MathAbs(Item.cbHv - BoxHover) < 0.002 then
                    Item.cbHv = BoxHover
                end
                if MathAbs(Item.cbPr - BoxPressed) < 0.002 then
                    Item.cbPr = BoxPressed
                end
                if Item.cbFl < 0.002 then
                    Item.cbFl = 0
                end
                local AnimState = Item.animState
                local EaseValue =
                    AnimState * AnimState * (3 - 2 * AnimState) +
                    1.70658 * AnimState * AnimState * AnimState * (1 - AnimState) * Item.cbG * Enabled
                local EaseClamped = MathMin(1, EaseValue)
                local Overshoot = Clamp((EaseValue - 1) / 0.1, 0, 1)
                local Bounce = 4 * AnimState * (1 - AnimState)
                local Text = 0.24 * Bounce * Bounce * (2 * Item.cbG - 1)
                local Value = (2 + 10 * EaseValue) * (1 - 0.06 * Item.cbPr)
                local SquashWidth = MathMin(Value * (1 + Text), 15.2)
                local SquashHeight = MathMin(Value * (1 - 0.85 * Text), 15.2)
                local Result = MathMin(MathMin(SquashWidth, SquashHeight) / 2, 3 + 2 * (1 - EaseClamped))
                local Pulse = MathMax(Bounce, Overshoot)
                local GlowWidth = MathMin(SquashWidth * (1 + 0.1 * Pulse), 15.4)
                local Hover = MathMin(SquashHeight * (1 + 0.1 * Pulse), 15.4)
                local DimAccent = LerpColor(AccentColor, Theme.bg, 0.5)
                local LightAccent = LerpColor(AccentColor, White, 0.55)
                local GlowAlpha = MathMin(1, EaseValue * 3)
                FillRect(
                    BoxX,
                    BoxY,
                    Size,
                    Size,
                    LerpColor(Theme.trackOff, DimAccent, 0.55 * EaseClamped),
                    30,
                    5,
                    (0.5 + 0.12 * Item.cbHv) * Alpha
                )
                FillRect(
                    CenterX - GlowWidth / 2,
                    CenterY - Hover / 2,
                    GlowWidth,
                    Hover,
                    LerpColor(AccentColor, White, 0.35),
                    31,
                    MathMin(MathMin(GlowWidth, Hover) / 2, Result + 1.2),
                    0.3 * Pulse * GlowAlpha * Alpha
                )
                FillRect(
                    CenterX - SquashWidth / 2,
                    CenterY - SquashHeight / 2,
                    SquashWidth,
                    SquashHeight,
                    LerpColor(
                        LerpColor(DimAccent, AccentColor, MathMin(1, EaseValue * 1.25)),
                        LightAccent,
                        MathMin(1, 0.55 * Item.cbFl + 0.35 * Bounce)
                    ),
                    32,
                    Result,
                    GlowAlpha * Alpha
                )
                local InnerWidth, InnerHeight =
                    SquashWidth * (0.36 + 0.6 * Item.cbFl),
                    SquashHeight * (0.36 + 0.6 * Item.cbFl)
                FillRect(
                    CenterX - InnerWidth / 2,
                    CenterY - InnerHeight / 2,
                    InnerWidth,
                    InnerHeight,
                    White,
                    33,
                    MathMin(InnerWidth, InnerHeight) / 2 * (1 - 0.45 * Item.cbFl),
                    0.78 * Item.cbFl * Item.cbFl * Alpha
                )
                local MouseX = MathMax(SquashWidth, SquashHeight)
                local RingSize = MathMin(17, MouseX + 3.6 * (1 - Overshoot))
                StrokeRect(
                    BoxX + (Size - RingSize) / 2,
                    BoxY + (Size - RingSize) / 2,
                    RingSize,
                    RingSize,
                    LightAccent,
                    34,
                    MathMin(RingSize / 2, Result + (RingSize - MouseX) / 2),
                    0.5 * Overshoot * Alpha
                )
                StrokeRect(
                    BoxX,
                    BoxY,
                    Size,
                    Size,
                    LerpColor(White, AccentColor, MathMin(1, 0.9 * EaseClamped + 0.35 * Item.cbFl)),
                    35,
                    5,
                    (Opacity.hairline + 0.5 * MathMax(EaseClamped, Item.cbHv)) * Alpha
                )
            else
                local SwitchWidth, SwitchHeight = 38, 20
                BoxX = X + Width - SwitchWidth
                local BoxY = Y + 3
                Item.animState = Approach(Item.animState or Enabled, Enabled, 16)
                FillRect(
                    BoxX,
                    BoxY,
                    SwitchWidth,
                    SwitchHeight,
                    LerpColor(Theme.trackOff, AccentColor, Item.animState),
                    30,
                    6,
                    Alpha
                )
                FillRect(BoxX + 3 + (SwitchWidth - 20) * Item.animState, BoxY + 3, 14, 14, White, 32, 4, Alpha)
            end
            RightEdge = BoxX - 8
            if Item.colorpicker then
                RightEdge = RightEdge - 14
                local SwatchHovered = Interactive and IsMouseInside(RightEdge, Y + 6, 14, 14)
                FillRect(RightEdge, Y + 6, 14, 14, NewColor(40, 40, 40), 30, 5, Alpha)
                FillRect(RightEdge, Y + 6, 14, 14, Item.colorpicker.value, 31, 5, Alpha * (Item.colorpicker.alpha or 1))
                StrokeRect(RightEdge, Y + 6, 14, 14, White, 32, 5, (SwatchHovered and 0.4 or Opacity.hairline) * Alpha)
                PickerHovered = SwatchHovered
                RightEdge = RightEdge - 8
                if Clicked and SwatchHovered then
                    OpenColorpicker(State.mouseX + 12, State.mouseY - 80, Item.colorpicker)
                    Clicked = false
                end
            end
            if Item.keybind then
                local Keybind = Item.keybind
                local Label = Keybind.listening and "..." or ComboDisplay(Keybind.value)
                local KeyWidth = MathMax(28, MeasureText(Label, 13, FontMonospace) + 14)
                RightEdge = RightEdge - KeyWidth
                local KeyHovered = Interactive and IsMouseInside(RightEdge, Y + 3, KeyWidth, 20)
                Keybind._hov = Approach(Keybind._hov or 0, (KeyHovered or Keybind.listening) and 1 or 0, 14)
                if Keybind.listening then
                    local AccentMid = State._accentMid
                    FillRect(RightEdge - 1, Y + 2, KeyWidth + 2, 22, Theme.accentB, 30, 6, 0.18 * Alpha)
                    FillRect(RightEdge, Y + 3, KeyWidth, 20, AccentMid, 31, 5, 0.6 * Alpha)
                    StrokeRect(RightEdge, Y + 3, KeyWidth, 20, Theme.accentB, 32, 5, 0.85 * Alpha)
                else
                    FillRect(
                        RightEdge,
                        Y + 3,
                        KeyWidth,
                        20,
                        White,
                        31,
                        5,
                        (Opacity.field + 0.05 * Keybind._hov) * Alpha
                    )
                    StrokeRect(RightEdge, Y + 3, KeyWidth, 20, Theme.accentA, 32, 5, 0.45 * Keybind._hov * Alpha)
                    local ModeName = NormalizeKeyMode(Keybind.mode)
                    local ModeColor =
                        ModeName == "Always" and Theme.accentB or ModeName == "Toggle" and Theme.accentA or White
                    StrokeRect(
                        RightEdge,
                        Y + 3,
                        KeyWidth,
                        20,
                        ModeColor,
                        32,
                        5,
                        (ModeName == "Hold" and Opacity.hairline or 0.55) * Alpha
                    )
                end
                DrawCenteredText(
                    Label,
                    RightEdge + KeyWidth / 2 + 0.37,
                    Y + 13,
                    White,
                    13,
                    FontMonospace,
                    33,
                    (Keybind.listening and Opacity.text or (KeyHovered and Opacity.hover or Opacity.dim)) * Alpha
                )
                KeybindHovered = KeyHovered
                RightEdge = RightEdge - 8
                if KeyHovered and not Keybind.listening then
                    ShowTooltip(
                        "click rebind (any key / mouse)  \194\183  right-click mode",
                        State.mouseX,
                        State.mouseY
                    )
                end
                if Clicked and KeyHovered then
                    Keybind.listening = true
                    Clicked = false
                    Keys.m1.click = false
                end
                if RightClicked and KeyHovered and not Keybind.listening then
                    State.keyMenu = {kb = Keybind, x = State.mouseX, y = State.mouseY, anim = 0}
                    State.dropdown = nil
                    State.colorpicker = nil
                    RightClicked = false
                end
            end
            DrawText(
                Item.label,
                X,
                CenterTextY(Y, 26, 13),
                White,
                13,
                FontSystem,
                31,
                false,
                false,
                RightEdge - X - 4,
                Opacity.label * Alpha
            )
            if Item.tooltip and Interactive and IsMouseInside(X, Y, Width, 26) then
                ShowTooltip(Item.tooltip, State.mouseX, State.mouseY)
            end
            if Clicked and Interactive and IsMouseInside(X, Y, Width, 26) and not PickerHovered and not KeybindHovered then
                SetItemValue(Item, not Item.value, true)
                Clicked = false
            end
        elseif Type == "keybind" then
            local Label = Item.listening and "..." or ComboDisplay(Item.value)
            local KeyWidth = MathMax(40, MeasureText(Label, 13, FontMonospace) + 16)
            local KeyX = X + Width - KeyWidth
            local KeyHovered = Interactive and IsMouseInside(KeyX, Y + 3, KeyWidth, 20)
            Item._hov = Approach(Item._hov or 0, (KeyHovered or Item.listening) and 1 or 0, 14)
            DrawText(
                Item.label,
                X,
                CenterTextY(Y, 26, 13),
                White,
                13,
                FontSystem,
                31,
                false,
                false,
                KeyX - X - 6,
                Opacity.label * Alpha
            )
            if Item.listening then
                local AccentMid = State._accentMid
                FillRect(KeyX - 1, Y + 2, KeyWidth + 2, 22, Theme.accentB, 30, 5, 0.18 * Alpha)
                FillRect(KeyX, Y + 3, KeyWidth, 20, AccentMid, 31, 4, 0.6 * Alpha)
                StrokeRect(KeyX, Y + 3, KeyWidth, 20, Theme.accentB, 32, 4, 0.85 * Alpha)
            else
                FillRect(KeyX, Y + 3, KeyWidth, 20, White, 31, 4, (Opacity.field + 0.05 * Item._hov) * Alpha)
                StrokeRect(KeyX, Y + 3, KeyWidth, 20, Theme.accentA, 32, 4, 0.45 * Item._hov * Alpha)
                StrokeRect(KeyX, Y + 3, KeyWidth, 20, White, 32, 4, Opacity.hairline * Alpha)
            end
            DrawCenteredText(
                Label,
                KeyX + KeyWidth / 2 + 0.37,
                Y + 13,
                White,
                13,
                FontMonospace,
                33,
                (Item.listening and Opacity.text or (KeyHovered and Opacity.hover or Opacity.dim)) * Alpha
            )
            if Item.tooltip and Interactive and IsMouseInside(X, Y, Width, 26) then
                ShowTooltip(Item.tooltip, State.mouseX, State.mouseY)
            end
            if Clicked and KeyHovered then
                Item.listening = true
                State.kbCapture = Item
                Clicked = false
                Keys.m1.click = false
            end
        elseif Type == "image" then
            local ImageHeight = Item.imgHeight or 80
            local ImageWidth = Item.imgWidth or Width
            if ImageWidth > Width then
                ImageWidth = Width
            end
            local X2 = X + (Width - ImageWidth) / 2
            if Item.imageData then
                if not Item._img then
                    pcall(function()
                        Item._img = Drawing.new("Image")
                        Item._img.Data = Item.imageData
                    end)
                end
                if Item._img then
                    pcall(function()
                        Item._img.Position = NewVector2(X2, Y)
                        Item._img.Size = NewVector2(ImageWidth, ImageHeight)
                        Item._img.ZIndex = 329999
                        Item._img.Transparency = Alpha
                        Item._img.Visible = Alpha > 0.01
                        pcall(function()
                            Item._img.Rounding = Item.rounding or 6
                        end)
                    end)
                end
            else
                FillRect(X2, Y, ImageWidth, ImageHeight, White, 30, 6, Opacity.field * Alpha)
                StrokeRect(X2, Y, ImageWidth, ImageHeight, White, 31, 6, Opacity.hairline * Alpha)
            end
        elseif Type == "colorpicker" then
            DrawText(
                Item.label,
                X,
                CenterTextY(Y, 24, 13),
                White,
                13,
                FontSystem,
                31,
                false,
                false,
                Width - 24,
                Opacity.label * Alpha
            )
            local SwatchX, SwatchY = X + Width - 16, Y + 5
            local Hovered = Interactive and IsMouseInside(SwatchX, SwatchY, 16, 16)
            FillRect(SwatchX, SwatchY, 16, 16, NewColor(40, 40, 40), 30, 6, Alpha)
            FillRect(SwatchX, SwatchY, 16, 16, Item.value, 31, 6, Alpha * (Item.alpha or 1))
            StrokeRect(SwatchX, SwatchY, 16, 16, White, 32, 6, (Hovered and 0.4 or Opacity.hairline) * Alpha)
            if Clicked and Hovered then
                OpenColorpicker(State.mouseX + 12, State.mouseY - 80, Item)
                Clicked = false
            end
        elseif Type == "slider" then
            DrawText(
                Item.label,
                X,
                CenterTextY(Y, 16, 13),
                White,
                13,
                FontSystem,
                31,
                false,
                false,
                Width - 60,
                Opacity.label * Alpha
            )
            local Focused = State.focus == Item
            if Item._dispVal ~= Item.value then
                Item._dispVal = Item.value
                local Value = Item.value
                local NumberText =
                    Value == MathFloor(Value) and tostring(MathFloor(Value)) or
                    string.format("%.8f", Value):gsub("0+$", ""):gsub("%.$", "")
                Item._dispStr = NumberText .. (Item.suffix ~= "" and " " .. Item.suffix or "")
            end
            local DisplayText = Focused and (Item.directValue or "") or Item._dispStr
            local ValueWidth =
                MathMax(
                40,
                (Focused and #DisplayText * GetCharWidth(12) or MeasureText(DisplayText, 12, FontSystem)) + 16
            )
            local ValueX = X + Width - ValueWidth
            FillRect(ValueX, Y, ValueWidth, 18, White, 30, 3, Opacity.field * Alpha)
            StrokeRect(ValueX, Y, ValueWidth, 18, White, 31, 3, (Focused and 0.4 or Opacity.hairline) * Alpha)
            if Focused then
                DrawEditableText(
                    Item,
                    Item.directValue or "",
                    ValueX + 7,
                    CenterTextY(Y, 18, 12),
                    12,
                    White,
                    Opacity.text * Alpha,
                    32,
                    ValueWidth - 12,
                    true,
                    Item.caret,
                    Item.selA
                )
            else
                DrawText(
                    DisplayText,
                    ValueX + ValueWidth / 2,
                    CenterTextY(Y, 18, 12),
                    White,
                    12,
                    FontSystem,
                    32,
                    true,
                    false,
                    ValueWidth - 8,
                    Opacity.dim * Alpha
                )
            end
            if Clicked and Interactive and IsMouseInside(ValueX, Y, ValueWidth, 18) then
                if State.focus ~= Item then
                    Item.directValue = tostring(Item.value)
                end
                State.focus = Item
                Item._ex = ValueX + 7
                Item._ecw = GetCharWidth(12)
                Item._es = 0
                Item.caret = CaretFromX(Item, Item.directValue or "", State.mouseX)
                Item.selA = Item.caret
                State.textDrag = Item
                Item._dragDownX = State.mouseX
                Clicked = false
            end
            if Keys.m1.held and State.textDrag == Item then
                if MathAbs(State.mouseX - (Item._dragDownX or State.mouseX)) > 3 then
                    Item.caret = CaretFromX(Item, Item.directValue or "", State.mouseX)
                end
            end
            local TrackY = Y + 26
            local SliceWidth = Width
            local Fraction = Item.max ~= Item.min and Clamp((Item.value - Item.min) / (Item.max - Item.min), 0, 1) or 0
            Item._fillFrac = Approach(Item._fillFrac or Fraction, Fraction, 20)
            local FillFrac = Item._fillFrac
            FillRect(X, TrackY, SliceWidth, 8, Theme.sliderTrack, 30, 4, Alpha)
            if FillFrac > 0.001 then
                FillRect(
                    X,
                    TrackY,
                    MathMax(8, SliceWidth * FillFrac),
                    8,
                    LerpColor(Theme.accentA, Theme.accentB, FillFrac),
                    31,
                    4,
                    Alpha
                )
            end
            local KnobX = X + SliceWidth * FillFrac
            local KnobHovered = Interactive and IsMouseInside(KnobX - 9, TrackY - 5, 18, 18)
            Item.animatedRadius =
                Approach(Item.animatedRadius or 6, (KnobHovered or State.sliderDrag == Item) and 9 or 6, 16)
            DrawCircle(KnobX, TrackY + 4, Item.animatedRadius, White, 32, true, 1, 24, Alpha)
            if
                Clicked and Interactive and IsMouseInside(X - 4, TrackY - 8, SliceWidth + 8, 16) and
                    not IsMouseInside(ValueX, Y, ValueWidth, 18)
             then
                State.sliderDrag = Item
                Clicked = false
            end
            if
                RightClicked and Interactive and IsMouseInside(X - 4, TrackY - 8, SliceWidth + 8, 16) and
                    Item.default ~= nil
             then
                SetItemValue(Item, Item.default, true)
                RightClicked = false
            end
            if Keys.m1.held and State.sliderDrag == Item then
                local Name =
                    SnapToStep(Item.min + (Item.max - Item.min) * Clamp((State.mouseX - X) / SliceWidth, 0, 1), Item)
                if Name ~= Item.value then
                    Item.value = Name
                    SafeCall(Item.callback, Name)
                end
            end
        elseif Type == "rangeslider" then
            DrawText(
                Item.label,
                X,
                CenterTextY(Y, 16, 13),
                White,
                13,
                FontSystem,
                31,
                false,
                false,
                Width - 90,
                Opacity.label * Alpha
            )
            if Item._rsLo ~= Item.valueLo or Item._rsHi ~= Item.valueHi or Item._rsSuf ~= Item.suffix then
                Item._rsLo, Item._rsHi, Item._rsSuf = Item.valueLo, Item.valueHi, Item.suffix
                Item._rsDisp =
                    tostring(Item.valueLo) ..
                    " - " .. tostring(Item.valueHi) .. (Item.suffix ~= "" and " " .. Item.suffix or "")
            end
            local RsDisp = Item._rsDisp
            local ValueWidth = MathMax(54, MeasureText(RsDisp, 12, FontSystem) + 16)
            local ValueX = X + Width - ValueWidth
            FillRect(ValueX, Y, ValueWidth, 18, White, 30, 3, Opacity.field * Alpha)
            StrokeRect(ValueX, Y, ValueWidth, 18, White, 31, 3, Opacity.hairline * Alpha)
            DrawText(
                RsDisp,
                ValueX + ValueWidth / 2,
                CenterTextY(Y, 18, 12),
                White,
                12,
                FontSystem,
                32,
                true,
                false,
                ValueWidth - 8,
                Opacity.dim * Alpha
            )
            local TrackY = Y + 26
            local SliceWidth = Width
            local Range = Item.max ~= Item.min and Item.max - Item.min or 1
            Item._fLo = Approach(Item._fLo or 0, Clamp((Item.valueLo - Item.min) / Range, 0, 1), 20)
            Item._fHi = Approach(Item._fHi or 1, Clamp((Item.valueHi - Item.min) / Range, 0, 1), 20)
            local LowX, HighX = X + SliceWidth * Item._fLo, X + SliceWidth * Item._fHi
            FillRect(X, TrackY, SliceWidth, 8, Theme.sliderTrack, 30, 4, Alpha)
            local FillWidth = HighX - LowX
            if FillWidth > 0.5 then
                FillRect(
                    LowX,
                    TrackY,
                    MathMax(8, FillWidth),
                    8,
                    LerpColor(Theme.accentA, Theme.accentB, (Item._fLo + Item._fHi) / 2),
                    31,
                    4,
                    Alpha
                )
            end
            local Dragging = State.sliderDrag == Item
            local LowHovered = Interactive and IsMouseInside(LowX - 9, TrackY - 5, 18, 18)
            local HighHovered = Interactive and IsMouseInside(HighX - 9, TrackY - 5, 18, 18)
            Item._rLo = Approach(Item._rLo or 6, (LowHovered or Dragging and Item._drag == "lo") and 9 or 6, 16)
            Item._rHi = Approach(Item._rHi or 6, (HighHovered or Dragging and Item._drag == "hi") and 9 or 6, 16)
            DrawCircle(LowX, TrackY + 4, Item._rLo, White, 32, true, 1, 24, Alpha)
            DrawCircle(HighX, TrackY + 4, Item._rHi, White, 32, true, 1, 24, Alpha)
            if
                Clicked and Interactive and IsMouseInside(X - 4, TrackY - 8, SliceWidth + 8, 16) and
                    not IsMouseInside(ValueX, Y, ValueWidth, 18)
             then
                Item._drag = State.mouseX < (LowX + HighX) / 2 and "lo" or "hi"
                State.sliderDrag = Item
                Clicked = false
            end
            if RightClicked and Interactive and IsMouseInside(X - 4, TrackY - 8, SliceWidth + 8, 16) then
                Item.valueLo = Item.defLo or Item.min
                Item.valueHi = Item.defHi or Item.max
                SafeCall(Item.callback, Item.valueLo, Item.valueHi)
                RightClicked = false
            end
            if Keys.m1.held and State.sliderDrag == Item then
                local Name = SnapToStep(Item.min + Range * Clamp((State.mouseX - X) / SliceWidth, 0, 1), Item)
                if Item._drag == "lo" then
                    if Name > Item.valueHi then
                        Name = Item.valueHi
                    end
                    if Name ~= Item.valueLo then
                        Item.valueLo = Name
                        SafeCall(Item.callback, Item.valueLo, Item.valueHi)
                    end
                else
                    if Name < Item.valueLo then
                        Name = Item.valueLo
                    end
                    if Name ~= Item.valueHi then
                        Item.valueHi = Name
                        SafeCall(Item.callback, Item.valueLo, Item.valueHi)
                    end
                end
            end
        elseif Type == "dropdown" then
            local Inline = State.dropdownInline == true
            local ContentWidth = Inline and MathMax(110, MathFloor(Width * 0.5)) or Width
            local AreaX = Inline and X + Width - ContentWidth or X
            local AreaY = Inline and Y or Y + 20
            if Inline then
                DrawText(
                    Item.label,
                    X,
                    CenterTextY(Y, 24, 13),
                    White,
                    13,
                    FontSystem,
                    31,
                    false,
                    false,
                    AreaX - X - 8,
                    Opacity.label * Alpha
                )
            else
                DrawText(
                    Item.label,
                    X,
                    CenterTextY(Y, 16, 13),
                    White,
                    13,
                    FontSystem,
                    31,
                    false,
                    false,
                    Width,
                    Opacity.label * Alpha
                )
            end
            if Item._ddDisp == nil or Item._ddDispVer ~= Item._ddVer then
                Item._ddDispVer = Item._ddVer
                Item._ddDisp =
                    Item.multi and (#Item.value > 0 and TableConcat(Item.value, ", ") or "none") or
                    (Item.value[1] or "none")
            end
            local DdDisp = Item._ddDisp
            local Hovered = Interactive and IsMouseInside(AreaX, AreaY, ContentWidth, 24)
            FillRect(
                AreaX,
                AreaY,
                ContentWidth,
                24,
                White,
                30,
                5,
                (Opacity.field + 0.02 + (Hovered and 0.03 or 0)) * Alpha
            )
            DrawText(
                DdDisp,
                AreaX + 10,
                CenterTextY(AreaY, 24, 13),
                White,
                13,
                FontSystem,
                32,
                false,
                false,
                ContentWidth - 18,
                Opacity.dim * Alpha
            )
            local IsOpen = State.dropdown and State.dropdown.item == Item and not State.dropdown.closing
            if Item._ddImg then
                State.placeImg(Item._ddImg, Item._ddIc, AreaX + ContentWidth - 20, AreaY + 5, 14, 14, 32, 0, false)
            end
            if Item.tooltip and Hovered then
                ShowTooltip(Item.tooltip, State.mouseX, State.mouseY)
            end
            if Clicked and Hovered then
                if IsOpen then
                    State.dropdown.closing = true
                else
                    OpenDropdown(AreaX, AreaY + 26, ContentWidth, Item)
                end
                Clicked = false
            end
        elseif Type == "textbox" then
            DrawText(
                Item.label,
                X,
                CenterTextY(Y, 16, 13),
                White,
                13,
                FontSystem,
                31,
                false,
                false,
                Width,
                Opacity.label * Alpha
            )
            local AreaY = Y + 20
            local Focused = State.focus == Item
            local Hovered = Interactive and IsMouseInside(X, AreaY, Width, 24)
            FillRect(X, AreaY, Width, 24, White, 30, 4, Opacity.field * Alpha)
            StrokeRect(
                X,
                AreaY,
                Width,
                24,
                White,
                31,
                4,
                (Focused and 0.45 or (Hovered and 0.2 or Opacity.hairline)) * Alpha
            )
            local TextX = X + 10
            local Value = Item.value or ""
            local ShowPlaceholder = Value == "" and not Focused
            if ShowPlaceholder then
                DrawText(
                    Item.label,
                    TextX,
                    CenterTextY(AreaY, 24, 13),
                    White,
                    13,
                    FontSystem,
                    32,
                    false,
                    false,
                    Width - 20,
                    0.3 * Alpha
                )
            elseif Focused then
                DrawEditableText(
                    Item,
                    Value,
                    TextX,
                    CenterTextY(AreaY, 24, 13),
                    13,
                    White,
                    Opacity.text * Alpha,
                    32,
                    Width - 18,
                    Focused,
                    Item.caret,
                    Item.selA
                )
            else
                DrawText(
                    Value,
                    TextX,
                    CenterTextY(AreaY, 24, 13),
                    White,
                    13,
                    FontSystem,
                    32,
                    false,
                    false,
                    Width - 18,
                    Opacity.text * Alpha
                )
            end
            if Clicked and Hovered then
                State.focus = Item
                Item.caret = CaretFromX(Item, Value, State.mouseX)
                Item.selA = Item.caret
                State.textDrag = Item
                Item._dragDownX = State.mouseX
                Clicked = false
            end
            if Keys.m1.held and State.textDrag == Item then
                if MathAbs(State.mouseX - (Item._dragDownX or State.mouseX)) > 3 then
                    Item.caret = CaretFromX(Item, Value, State.mouseX)
                end
            end
        end
        return Clicked, RightClicked
    end
    local SectionHeaderBase = 17
    local function SectionHeaderHeight(Text)
        if not (Text.name and Text.name ~= "") then
            return 0
        end
        return SectionHeaderBase + (Text.desc and Text.desc ~= "" and 13 or 0)
    end
    local function DrawSection(Section, X, Y, Width, Height, ClipTop, ClipBottom, Clicked, Held, RightClicked, Blocked)
        local StaggerDelay = MathMin((Section._si or 1) - 1, 6) * 0.06
        local SectionFade = Clamp((State.contentFade - StaggerDelay) / (1 - StaggerDelay), 0, 1) * State.drawVisible
        local X2 = State.hoverEffects ~= false
        local HeaderHeight = SectionHeaderHeight(Section)
        if HeaderHeight > 0 then
            local HeaderAlpha =
                SectionFade * Clamp((Y + HeaderHeight - ClipTop) / HeaderHeight, 0, 1) *
                Clamp((ClipBottom - Y) / HeaderHeight, 0, 1)
            if HeaderAlpha > 0.01 then
                local Accent = State._accentMid
                if Section._nameU ~= Section.name then
                    Section._nameU = Section.name
                    Section._nameUpper = string.upper(Section.name)
                end
                local TextAlpha = (Section.collapsed and 0.55 or 0.85) * HeaderAlpha
                DrawText(
                    Section._nameUpper,
                    X + 4,
                    Y + 2,
                    Accent,
                    11,
                    FontBold,
                    31,
                    false,
                    false,
                    Width - 22,
                    TextAlpha
                )
                if Section.desc then
                    DrawText(
                        Section.desc,
                        X + 4,
                        Y + 15,
                        White,
                        10,
                        FontSystem,
                        31,
                        false,
                        false,
                        Width - 22,
                        Opacity.dim * 0.72 * HeaderAlpha
                    )
                end
                local LabelWidth = MathMin(MeasureText(Section._nameUpper, 11, FontBold), Width - 40)
                local LineStart = X + 4 + LabelWidth + 10
                State.fadeLine(
                    LineStart,
                    Y + 8,
                    X + Width - 6 - LineStart,
                    Accent,
                    31,
                    (Section.collapsed and 0.18 or 0.30) * HeaderAlpha
                )
                if Clicked and not Blocked and IsMouseInside(X, Y, Width, HeaderHeight) then
                    Section.collapsed = not Section.collapsed
                    Clicked = false
                end
            end
        end
        if (Section._cA or 0) > 0.98 then
            for _, Target in ipairs(Section.items) do
                if Target._img then
                    pcall(function()
                        Target._img.Visible = false
                    end)
                end
                if Target._ddImg then
                    pcall(function()
                        Target._ddImg.Visible = false
                    end)
                    if Target._ddIc then
                        Target._ddIc[7] = false
                    end
                end
            end
            return Clicked, RightClicked
        end
        local ContentTop = Y + HeaderHeight
        local CardTop = MathMax(ContentTop, ClipTop)
        local CardHeight = MathMin(Y + Height, ClipBottom) - CardTop
        local CardHovered = not Blocked and IsMouseInside(X, CardTop, Width, CardHeight)
        Section._hovA = Approach(Section._hovA or 0, CardHovered and X2 and 1 or 0, 6)
        local CardBase = NewColor(150, 153, 161)
        FillRect(
            X,
            CardTop,
            Width,
            CardHeight,
            LerpColor(White, CardBase, 0.40),
            28,
            5,
            Opacity.card * 2.1 * SectionFade
        )
        local HovA = Section._hovA
        local AccentMid = State._accentMid
        local HeaderAlpha = HovA * SectionFade * (State.glowMul or 1)
        if not State.lite then
            StrokeRect(X - 2, CardTop - 2, Width + 4, CardHeight + 4, AccentMid, 32, 7, 0.05 * HeaderAlpha)
            StrokeRect(X - 1, CardTop - 1, Width + 2, CardHeight + 2, AccentMid, 32, 6, 0.11 * HeaderAlpha)
        end
        StrokeRect(X, CardTop, Width, CardHeight, AccentMid, 33, 5, 0.34 * HeaderAlpha)
        local Width2 = Width - 38
        local X3 = X + 20
        local Y2 = ContentTop + 11
        local Entry = #Section.items
        local Gap = State.rowLines and 4 or 6
        local ClipEnd = MathMin(ClipBottom, Y + Height)
        for Index, Item in ipairs(Section.items) do
            local ImageHeight = ItemHeight(Item)
            if Y2 + ImageHeight < ClipTop - 2 or Y2 > ClipEnd + 2 then
                if Item._img then
                    pcall(function()
                        Item._img.Visible = false
                    end)
                end
                if Item._ddImg then
                    pcall(function()
                        Item._ddImg.Visible = false
                    end)
                    if Item._ddIc then
                        Item._ddIc[7] = false
                    end
                end
            else
                local Disabled = IsDisabled(Item)
                local EdgeFade = 1
                if Y2 < ClipTop then
                    EdgeFade = Clamp(1 - (ClipTop - Y2) / (ImageHeight * 0.5), 0, 1)
                end
                if Y2 + ImageHeight > ClipEnd then
                    EdgeFade = MathMin(EdgeFade, Clamp(1 - (Y2 + ImageHeight - ClipEnd) / (ImageHeight * 0.5), 0, 1))
                end
                local Alpha = (Disabled and 0.4 or 1) * SectionFade * EdgeFade
                Clicked, RightClicked = DrawItem(Item, X3, Y2, Width2, Alpha, Clicked, RightClicked, Blocked)
                local GlowAlpha =
                    Item._flash and Item._flash > (Clock() or 0) and
                    0.35 + 0.5 * Clamp(0.5 + 0.5 * MathSin((Clock() or 0) * 9), 0, 1) or
                    0
                StrokeRect(X3 - 4, Y2 - 4, Width2 + 8, ImageHeight + 8, State._accentMid, 33, 7, GlowAlpha * Alpha)
                if State.rowLines and Index < Entry then
                    local LineY = Y2 + ImageHeight + Gap / 2
                    if LineY > ClipTop and LineY < ClipEnd then
                        DrawLine(X + 14, LineY, X + Width - 14, LineY, White, 31, 1, 0.12 * SectionFade * EdgeFade)
                    end
                end
            end
            Y2 = Y2 + ImageHeight + (Index < Entry and Gap or 0)
        end
        return Clicked, RightClicked
    end
    local function SectionHeight(Section)
        Section._cA = Approach(Section._cA or (Section.collapsed and 1 or 0), Section.collapsed and 1 or 0, 10)
        local HeaderHeight = SectionHeaderHeight(Section)
        local Total = HeaderHeight + 11 + 8
        local Entry = #Section.items
        for Index, Item in ipairs(Section.items) do
            Total = Total + ItemHeight(Item) + (Index < Entry and (State.rowLines and 4 or 6) or 0)
        end
        return Total + (HeaderHeight + 6 - Total) * Section._cA
    end
    local function DrawTabContent(Tab, Clicked, Held, RightClicked, X, Y, Width, Height)
        local Blocked = State.dropdown ~= nil or State.colorpicker ~= nil or State.keyMenu ~= nil or State.dialog ~= nil
        local ColumnWidth = MathFloor((Width - 10) / 2)
        local SpotScrollTo = State._spotScrollTo
        State._spotScrollTo = nil
        local LeftHeight, RightHeight = 0, 0
        for _, Value in ipairs(Tab.sections) do
            Value._h = SectionHeight(Value)
            if Value.side == "Full" then
                local FullTop = MathMax(LeftHeight, RightHeight)
                LeftHeight = FullTop + Value._h + 10
                RightHeight = LeftHeight
            elseif Value.side == "Right" then
                RightHeight = RightHeight + Value._h + 10
            else
                LeftHeight = LeftHeight + Value._h + 10
            end
        end
        local TotalHeight = MathMax(LeftHeight, RightHeight)
        Tab.maxScroll = MathMax(0, TotalHeight - Height)
        if State.mouseScroll ~= 0 and not Blocked and IsMouseInside(State.x, State.y, State.w, State.h) then
            Tab.targetScrollY = Clamp(Tab.targetScrollY - (State.mouseScroll > 0 and 1 or -1) * 42, 0, Tab.maxScroll)
        end
        if
            Tab.maxScroll > 0 and not Blocked and not State.focus and not State.spotlightOpen and
                IsMouseInside(X, Y, Width, Height)
         then
            if Keys.up.click then
                Tab.targetScrollY = MathMax(0, Tab.targetScrollY - 60)
            end
            if Keys.down.click then
                Tab.targetScrollY = MathMin(Tab.maxScroll, Tab.targetScrollY + 60)
            end
            if Keys.pageup.click then
                Tab.targetScrollY = MathMax(0, Tab.targetScrollY - Height * 0.8)
            end
            if Keys.pagedown.click then
                Tab.targetScrollY = MathMin(Tab.maxScroll, Tab.targetScrollY + Height * 0.8)
            end
        end
        Tab.targetScrollY = Clamp(Tab.targetScrollY, 0, Tab.maxScroll)
        Tab.scrollY = Approach(Tab.scrollY, Tab.targetScrollY, 15)
        if MathAbs(Tab.scrollY - Tab.targetScrollY) < 0.1 then
            Tab.scrollY = Tab.targetScrollY
        end
        local BaseY = Y - Tab.scrollY + (1 - State.contentFade) * 12
        local ClipTop, ClipBottom = Y, Y + Height
        local LeftY, RightY = BaseY, BaseY
        for SectionIndex, Value in ipairs(Tab.sections) do
            Value._si = SectionIndex
            local TextX, RowY, SectionWidth
            if Value.side == "Full" then
                RowY = MathMax(LeftY, RightY)
                TextX = X
                SectionWidth = Width
                LeftY = RowY + Value._h + 10
                RightY = LeftY
            elseif Value.side == "Right" then
                TextX = X + ColumnWidth + 10
                RowY = RightY
                SectionWidth = ColumnWidth
                RightY = RightY + Value._h + 10
            else
                TextX = X
                RowY = LeftY
                SectionWidth = ColumnWidth
                LeftY = LeftY + Value._h + 10
            end
            if SpotScrollTo then
                local ItemOffset, ItemCount = SectionHeaderHeight(Value) + 14, #Value.items
                for ItemIndex, Target in ipairs(Value.items) do
                    if Target == SpotScrollTo then
                        Tab.targetScrollY = Clamp(RowY - BaseY + ItemOffset - 40, 0, Tab.maxScroll)
                        SpotScrollTo = nil
                        break
                    end
                    ItemOffset =
                        ItemOffset + ItemHeight(Target) + (ItemIndex < ItemCount and (State.rowLines and 4 or 6) or 0)
                end
            end
            Clicked, RightClicked =
                DrawSection(
                Value,
                TextX,
                RowY,
                SectionWidth,
                Value._h,
                ClipTop,
                ClipBottom,
                Clicked,
                Held,
                RightClicked,
                Blocked
            )
        end
        if Tab.maxScroll > 0 then
            local ScrollbarAlpha = State.contentFade * State.drawVisible
            local TrackX = X + Width + 4
            local ThumbHeight = MathMax(34, Height / TotalHeight * Height)
            local Fraction = Tab.scrollY / Tab.maxScroll
            local ThumbY = Y + Fraction * (Height - ThumbHeight)
            local Dragging = State.scrollDrag and State.scrollDrag.tab == Tab
            local Hovered = IsMouseInside(TrackX - 7, ThumbY, 18, ThumbHeight) or Dragging
            local Active = Clamp(MathAbs(Tab.targetScrollY - Tab.scrollY) / 30, 0, 1)
            local GlowTarget = Hovered and 1 or Active
            Tab._sbGlow = Approach(Tab._sbGlow or 0, GlowTarget, 12)
            if MathAbs(Tab._sbGlow - GlowTarget) < 0.004 then
                Tab._sbGlow = GlowTarget
            end
            local ThumbColor = LerpColor(Theme.accentA, Theme.accentB, Fraction)
            FillRect(TrackX + 0.5, Y, 3, Height, White, 34, 1.5, (0.05 + 0.05 * Tab._sbGlow) * ScrollbarAlpha)
            local ButtonWidth = 4.5 + Tab._sbGlow * 1
            local RestX = TrackX + 2 - ButtonWidth / 2
            FillRect(
                RestX - 2,
                ThumbY - 3,
                ButtonWidth + 4,
                ThumbHeight + 6,
                ThumbColor,
                35,
                (ButtonWidth + 4) / 2,
                0.16 * Tab._sbGlow * ScrollbarAlpha
            )
            FillRect(
                RestX,
                ThumbY,
                ButtonWidth,
                ThumbHeight,
                ThumbColor,
                36,
                ButtonWidth / 2,
                (0.55 + 0.45 * Tab._sbGlow) * ScrollbarAlpha
            )
            if Clicked and not Blocked and IsMouseInside(TrackX - 7, Y, 18, Height) then
                local GrabOffset =
                    IsMouseInside(TrackX - 7, ThumbY, 18, ThumbHeight) and State.mouseY - ThumbY or ThumbHeight / 2
                State.scrollDrag = {tab = Tab, grab = GrabOffset}
                Clicked = false
            end
            if Keys.m1.held and State.scrollDrag and State.scrollDrag.tab == Tab then
                local TrackSpace = MathMax(1, Height - ThumbHeight)
                Tab.targetScrollY = Clamp((State.mouseY - Y - State.scrollDrag.grab) / TrackSpace, 0, 1) * Tab.maxScroll
            end
        elseif State.scrollDrag and State.scrollDrag.tab == Tab then
            State.scrollDrag = nil
        end
        if Tab.maxScroll > 0 and Clicked and not Blocked and IsMouseInside(X, Y, Width, Height) and not State.scrollDrag then
            State.contentDrag = {tab = Tab, my = State.mouseY, start = Tab.targetScrollY}
            Tab._kv = 0
            Clicked = false
        end
        if Keys.m1.held and State.contentDrag and State.contentDrag.tab == Tab then
            local DeltaTime = State.dt or 1 / 60
            if DeltaTime <= 0 then
                DeltaTime = 1 / 60
            end
            local NewScroll = Clamp(State.contentDrag.start - (State.mouseY - State.contentDrag.my), 0, Tab.maxScroll)
            Tab._kv = (Tab._kv or 0) * 0.72 + (NewScroll - Tab.targetScrollY) / DeltaTime * 0.28
            Tab.targetScrollY = NewScroll
        elseif (Tab._kv or 0) ~= 0 and not State.scrollDrag then
            local DeltaTime = State.dt or 1 / 60
            if DeltaTime <= 0 then
                DeltaTime = 1 / 60
            end
            Tab.targetScrollY = Clamp(Tab.targetScrollY + Tab._kv * DeltaTime, 0, Tab.maxScroll)
            Tab._kv = Tab._kv * math.exp(-5 * DeltaTime)
            if MathAbs(Tab._kv) < 4 or Tab.targetScrollY <= 0 or Tab.targetScrollY >= Tab.maxScroll then
                Tab._kv = 0
            end
        end
        return Clicked, RightClicked
    end
    local BackgroundEffects = {"Off", "Snow", "Matrix", "Rain"}
    local EffectParticleCounts = {Snow = 48, Rain = 80}
    local MatrixGlyphs = "01ABCDEFGHJKLMNPRSTUVXYZ#$%&@"
    local function RandomGlyph()
        local Index = 1 + MathFloor(math.random() * #MatrixGlyphs)
        return string.sub(MatrixGlyphs, Index, Index)
    end
    local function CreateEffectParticles(EffectName, Width)
        local Particles = {}
        local Density = State.lite and 0.55 or 1
        if EffectName == "Matrix" then
            local Columns = MathMax(6, MathFloor(Width / 18 * Density))
            for Index = 1, Columns do
                local TrailLength = 6 + MathFloor(math.random() * 6)
                local Green = {}
                for Key = 1, TrailLength do
                    Green[Key] = RandomGlyph()
                end
                Particles[Index] = {
                    col = (Index - 0.5) / Columns,
                    y = math.random() * 1.4 - 0.4,
                    v = 0.25 + math.random() * 0.55,
                    trail = TrailLength,
                    g = Green
                }
            end
            return Particles
        end
        local Entry = MathMax(6, MathFloor((EffectParticleCounts[EffectName] or 80) * Density))
        for Index = 1, Entry do
            Particles[Index] = {
                x = math.random(),
                y = math.random(),
                ph = math.random() * 6.2832,
                sp = 0.3 + math.random() * 0.9,
                sz = 1 + math.random() * 2.2,
                a = 0.35 + math.random() * 0.6,
                depth = math.random(),
                swayAmp = 0.005 + math.random() * 0.018,
                fl = 1.6 + math.random() * 1.8
            }
        end
        return Particles
    end
    local function DrawBackgroundEffect(X, Y, Width, Height, TitleHeight, Alpha)
        local BgEffect = State.bgEffect
        if not BgEffect or BgEffect == "Off" then
            State._fx = nil
            State._fxName = nil
            return
        end
        if Alpha <= 0.02 then
            return
        end
        local BubbleX, RowTop = X + 2, Y + TitleHeight + 2
        local BubbleWidth, BubbleHeight = Width - 4, Height - TitleHeight - 4
        if BubbleWidth <= 12 or BubbleHeight <= 12 then
            return
        end
        if State._fxName ~= BgEffect or not State._fx then
            State._fx = CreateEffectParticles(BgEffect, BubbleWidth)
            State._fxName = BgEffect
        end
        local Position = State._fx
        local Kind = Clock() or 0
        local DeltaTime = State.dt or 1 / 60
        if DeltaTime > 0.1 then
            DeltaTime = 0.1
        end
        local Fade = Alpha
        local BgEffectColor = State.bgEffectColor
        pcall(function()
            if BgEffect == "Snow" then
                local Wind =
                    MathSin(Kind * 0.13) * 0.5 + MathSin(Kind * 0.31 + 1.3) * 0.22 + MathSin(Kind * 0.07) * 0.3
                for Index = 1, #Position do
                    local Particle = Position[Index]
                    local Depth = Particle.depth
                    Particle.y = Particle.y + (0.035 + Depth * 0.11) * DeltaTime
                    if Particle.y > 1.04 then
                        Particle.y = -0.04
                        Particle.x = math.random()
                    end
                    local Sway =
                        MathSin(Kind * Particle.sp + Particle.ph) * Particle.swayAmp +
                        MathSin(Kind * Particle.sp * Particle.fl + Particle.ph) * Particle.swayAmp * 0.45
                    local DrawX = BubbleX + (Particle.x + Sway + Wind * (0.012 + Depth * 0.03)) * BubbleWidth
                    local DrawY = RowTop + Particle.y * BubbleHeight
                    local Result = 2 + Depth * 4.5
                    local Color =
                        BgEffectColor or LerpColor(NewColor(215, 228, 255), NewColor(255, 255, 255), Depth)
                    local Fade2 =
                        Clamp((DrawY - RowTop - Result) / 6, 0, 1) *
                        Clamp((RowTop + BubbleHeight - DrawY - Result * 1.4) / 8, 0, 1)
                    local Transparency =
                        (0.3 + Depth * 0.5) * (0.85 + 0.15 * MathSin(Kind * 2 + Particle.ph)) * Fade * Fade2
                    local Spin = Kind * Particle.sp * 0.3 + Particle.ph
                    if Depth > 0.55 then
                        DrawCircle(DrawX, DrawY, Result * 1.4, Color, 12, true, 1, 12, Transparency * 0.08)
                    end
                    for Value = 0, 2 do
                        local SpokeAngle = Spin + Value * 1.0472
                        local SpokeDx, SpokeY = MathCos(SpokeAngle) * Result, MathSin(SpokeAngle) * Result
                        DrawLine(
                            DrawX - SpokeDx,
                            DrawY - SpokeY,
                            DrawX + SpokeDx,
                            DrawY + SpokeY,
                            Color,
                            13,
                            1,
                            Transparency
                        )
                    end
                    DrawCircle(DrawX, DrawY, MathMax(1, Result * 0.28), Color, 13, true, 1, 8, Transparency)
                end
            elseif BgEffect == "Rain" then
                local RestY = RowTop + BubbleHeight
                for Index = 1, #Position do
                    local Particle = Position[Index]
                    Particle.y = Particle.y + (0.85 + Particle.sz * 0.25) * DeltaTime
                    if Particle.y > 1.06 then
                        Particle.y = -0.05
                        Particle.x = math.random()
                    end
                    local DrawX = BubbleX + Particle.x * BubbleWidth
                    local DropY = RowTop + Particle.y * BubbleHeight
                    local Length = 6 + Particle.sz * 5
                    local DropTop = MathMax(DropY, RowTop)
                    local DropBottom = MathMin(DropY + Length, RestY)
                    local Opacity2 = Particle.a * Fade * 0.5
                    if DropBottom <= DropTop then
                        DropBottom = DropTop
                        Opacity2 = 0
                    end
                    DrawLine(
                        DrawX + (DropTop - DropY) / Length * 2.5,
                        DropTop,
                        DrawX + (DropBottom - DropY) / Length * 2.5,
                        DropBottom,
                        BgEffectColor or NewColor(170, 200, 255),
                        12,
                        1,
                        Opacity2
                    )
                end
            elseif BgEffect == "Matrix" then
                local GlyphSpacing = 14
                for Index = 1, #Position do
                    local Particle = Position[Index]
                    Particle.y = Particle.y + Particle.v * DeltaTime
                    if Particle.y * BubbleHeight - Particle.trail * GlyphSpacing > BubbleHeight then
                        Particle.y = -math.random() * 0.3
                        for Key = 1, Particle.trail do
                            Particle.g[Key] = RandomGlyph()
                        end
                    end
                    local CenterX = BubbleX + Particle.col * BubbleWidth
                    for Key = 1, Particle.trail do
                        local DrawY = RowTop + Particle.y * BubbleHeight - (Key - 1) * GlyphSpacing
                        local Fade2 = 1 - (Key - 1) / Particle.trail
                        local EdgeClip =
                            Clamp((DrawY - RowTop + 2) / 4, 0, 1) *
                            Clamp((RowTop + BubbleHeight - DrawY - GlyphSpacing + 2) / 4, 0, 1)
                        local Color =
                            Key == 1 and
                            (BgEffectColor and LerpColor(BgEffectColor, White, 0.35) or NewColor(205, 255, 215)) or
                            (BgEffectColor and LerpColor(NewColor(0, 0, 0), BgEffectColor, 0.3 + 0.5 * Fade2) or
                                NewColor(40 + 60 * Fade2, 200, 80 + 40 * Fade2))
                        DrawText(
                            Particle.g[Key] or "0",
                            CenterX,
                            DrawY,
                            Color,
                            13,
                            FontSystem,
                            12,
                            false,
                            false,
                            nil,
                            Fade2 * Fade * 0.9 * EdgeClip
                        )
                    end
                    if MathSin(Kind * 3 + Particle.col * 30) > 0.985 then
                        Particle.g[1] = RandomGlyph()
                    end
                end
            end
        end)
    end
    local function DrawWindow(Clicked, Held, RightClicked)
        local PlaceImg = State.placeImg
        local DrawVisible = State.drawVisible
        local TitleHeight = 31
        local CharWidth = 6
        if State.activeSub and State.activeSub.parent ~= State.activeTab then
            State.activeSub = nil
        end
        local CurrentPage = State.activeSub or State.activeTab
        if CurrentPage ~= State._tabSeen then
            State.dropdown = nil
            State.colorpicker = nil
            State.keyMenu = nil
            State.focus = nil
            pcall(function()
                for _, Kind in ipairs(State.tabs) do
                    for _, Entry in ipairs(Kind.sections) do
                        for _, Target in ipairs(Entry.items) do
                            if Target._img then
                                Target._img.Visible = false
                            end
                            if Target._ddImg then
                                Target._ddImg.Visible = false
                                if Target._ddIc then
                                    Target._ddIc[7] = false
                                end
                            end
                        end
                    end
                    if Kind.subs then
                        for _, Entry in ipairs(Kind.subs) do
                            for _, Entry2 in ipairs(Entry.sections) do
                                for _, Target in ipairs(Entry2.items) do
                                    if Target._img then
                                        Target._img.Visible = false
                                    end
                                    if Target._ddImg then
                                        Target._ddImg.Visible = false
                                        if Target._ddIc then
                                            Target._ddIc[7] = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            State._tabSeen = CurrentPage
        end
        if Held and State.drag then
            State.drag.tx = State.mouseX - State.drag.ox
            State.drag.ty = State.mouseY - State.drag.oy
        end
        if State.drag and State.drag.tx then
            local OldX, OldY = State.x, State.y
            State.x = Approach(State.x, State.drag.tx, 28)
            State.y = Approach(State.y, State.drag.ty, 28)
            ClampWindowToScreen()
            local MoveX, MoveY = State.x - OldX, State.y - OldY
            if MoveX ~= 0 or MoveY ~= 0 then
                local Dropdown = State.dropdown
                if Dropdown and Dropdown.x then
                    Dropdown.x = Dropdown.x + MoveX
                    Dropdown.y = Dropdown.y + MoveY
                end
                local Colorpicker = State.colorpicker
                if Colorpicker and Colorpicker.x then
                    Colorpicker.x = Colorpicker.x + MoveX
                    Colorpicker.y = Colorpicker.y + MoveY
                end
                local KeyMenu = State.keyMenu
                if KeyMenu and KeyMenu.x then
                    KeyMenu.x = KeyMenu.x + MoveX
                    KeyMenu.y = KeyMenu.y + MoveY
                end
            end
        end
        if Held and State.resizeEdge then
            local ResizeStart = State.resizeStart
            local ResizeEdge = State.resizeEdge
            if ResizeEdge == "r" or ResizeEdge == "br" then
                State.wTarget = MathMax(420, ResizeStart.w + State.mouseX - ResizeStart.mx)
            end
            if ResizeEdge == "b" or ResizeEdge == "br" then
                State.hTarget = MathMax(300, ResizeStart.h + State.mouseY - ResizeStart.my)
            end
        end
        State.wTarget = State.wTarget or State.w
        State.hTarget = State.hTarget or State.h
        State.w = Approach(State.w, State.wTarget, 16)
        State.h = Approach(State.h, State.hTarget, 16)
        local X, Y, Width, Height = State.x, State.y + (1 - DrawVisible) * 14, State.w, State.h
        local SideLayout = State.tabLayout ~= "top"
        local TabBarHeight = 42
        local HeaderHeight = SideLayout and 42 or TitleHeight
        local RailMin, RailMax = 54, MathMax(126, MathFloor(Width * 0.23))
        local RailWidth = RailMin + (RailMax - RailMin) * (State._sbX or 0)
        local NoPopup = not State.dropdown and not State.colorpicker and not State.keyMenu and not State.spotlightOpen
        local SidebarHovered = SideLayout and NoPopup and IsMouseInside(X, Y, RailWidth, Height)
        State._sbX = Approach(State._sbX or 0, SidebarHovered and 1 or 0, 10)
        if MathAbs(State._sbX - (SidebarHovered and 1 or 0)) < 0.003 then
            State._sbX = SidebarHovered and 1 or 0
        end
        local ExpandFade = 1
        local SliceWidth = SideLayout and RailMin + (RailMax - RailMin) * ExpandFade or 0
        if not State.lite then
            local WinShadow = Opacity.winShadow
            for Index = 1, #WinShadow do
                local Object = Index * 4
                FillRect(
                    X - Object,
                    Y - Object + 6,
                    Width + Object * 2,
                    Height + Object * 2,
                    NewColor(0, 0, 0),
                    9,
                    16,
                    WinShadow[Index] * DrawVisible
                )
            end
        end
        local WindowOpacity = State.menuOpacity or 0.90
        FillRect(X, Y, Width, Height, Theme.bg, 10, 8, WindowOpacity * DrawVisible)
        local GradientCells = 12
        local CellWidth = (Width - 2) / GradientCells
        local CellHeight = (Height - 2) / GradientCells
        for Row = 0, GradientCells - 1 do
            for Column = 0, GradientCells - 1 do
                local Blend = (Column + Row) / (2 * (GradientCells - 1))
                FillRect(
                    X + 1 + Column * CellWidth,
                    Y + 1 + Row * CellHeight,
                    CellWidth + 1,
                    CellHeight + 1,
                    LerpColor(Theme.accentA, Theme.accentB, Blend),
                    10,
                    0,
                    0.11 * DrawVisible
                )
            end
        end
        if State.bgImg then
            pcall(function()
                local ButtonWidth, ButtonHeight
                if State.bgImgWFrac then
                    ButtonWidth = State.bgImgWFrac * Width
                    ButtonHeight = (State.bgImgHFrac or 1) * (Height - HeaderHeight)
                else
                    ButtonWidth = (Height - HeaderHeight) * 0.6
                    ButtonHeight = Height - HeaderHeight
                end
                State.bgImg.Position =
                    NewVector2(
                    X + (Width - ButtonWidth) / 2,
                    Y + HeaderHeight + (Height - HeaderHeight - ButtonHeight) / 2
                )
                State.bgImg.Size = NewVector2(ButtonWidth, ButtonHeight)
                State.bgImg.ZIndex = 119999
                State.bgImg.Transparency = (State.bgImgAlpha or 0.12) * DrawVisible
                State.bgImg.Visible = DrawVisible > 0.01
            end)
        end
        State._winRect = {x = X, y = Y, w = Width, h = Height, th = HeaderHeight, v = DrawVisible}
        StrokeRect(X, Y, Width, Height, White, 12, 8, Opacity.hairline * DrawVisible)
        if SideLayout then
            FillRect(
                X + SliceWidth,
                Y + HeaderHeight,
                Width - SliceWidth,
                Height - HeaderHeight,
                White,
                11,
                7,
                0.045 * DrawVisible
            )
            if State.activeTab then
                DrawText(
                    (State.activeSub or State.activeTab).name,
                    X + SliceWidth + 16,
                    CenterTextY(Y, HeaderHeight, 15),
                    White,
                    15,
                    FontBold,
                    13,
                    false,
                    false,
                    MathMax(2, Width - SliceWidth - 272),
                    Opacity.text * DrawVisible
                )
            end
        else
            FillRect(X + 1, Y + TitleHeight, Width - 2, 4, State._accentMid, 11, 0, 0.035 * DrawVisible)
            DrawGradient(
                X + 1,
                Y + TitleHeight - 1.4,
                Width - 2,
                1.4,
                Theme.accentA,
                Theme.accentB,
                12,
                0.55 * DrawVisible
            )
        end
        do
            local ShineX = X - 46 + (Width + 92) * DrawVisible
            local ShinePulse = 4 * DrawVisible * (1 - DrawVisible)
            local ShineLeft, ShineRight = MathMax(X + 2, ShineX), MathMin(X + Width - 2, ShineX + 30)
            FillRect(ShineLeft, Y + 2, ShineRight - ShineLeft, HeaderHeight - 3, White, 12, 6, 0.09 * ShinePulse)
            local GlowLeft, GlowRight = MathMax(X + 2, ShineX - 18), MathMin(X + Width - 2, ShineX)
            FillRect(
                GlowLeft,
                Y + 2,
                GlowRight - GlowLeft,
                HeaderHeight - 3,
                State._accentMid,
                12,
                6,
                0.06 * ShinePulse
            )
        end
        local TitleCenterY = Y + HeaderHeight / 2
        local LogoCenterX = SideLayout and X + 29 or X + 20
        local LogoCenterY = SideLayout and Y + 22 or TitleCenterY
        local AccentMid = State._accentMid
        local LogoSize = 16
        if State.iconImg and (not SideLayout or not State.logoImg) then
            local ImageSize = LogoSize + 6
            pcall(function()
                State.iconImg.Position = NewVector2(LogoCenterX - ImageSize / 2, LogoCenterY - ImageSize / 2)
                State.iconImg.Size = NewVector2(ImageSize, ImageSize)
                pcall(function()
                    State.iconImg.Rounding = 5
                end)
                State.iconImg.ZIndex = 169999
                State.iconImg.Transparency = DrawVisible
                State.iconImg.Visible = DrawVisible > 0.01
            end)
        elseif State.logoImg and not SideLayout then
            local ImageSize = LogoSize + 6
            pcall(function()
                State.logoImg.Position = NewVector2(LogoCenterX - ImageSize / 2, LogoCenterY - ImageSize / 2)
                State.logoImg.Size = NewVector2(ImageSize, ImageSize)
                pcall(function()
                    State.logoImg.Rounding = 5
                end)
                State.logoImg.ZIndex = 169999
                State.logoImg.Transparency = DrawVisible
                State.logoImg.Visible = DrawVisible > 0.01
            end)
        elseif not SideLayout then
            FillRect(
                LogoCenterX - LogoSize / 2,
                LogoCenterY - LogoSize / 2,
                LogoSize,
                LogoSize,
                AccentMid,
                14,
                2.5,
                0.95 * DrawVisible
            )
            DrawMenuLogo(LogoCenterX, LogoCenterY, LogoSize, NewColor(36, 38, 50), DrawVisible, 15)
        end
        local function DrawControl(CenterX, Kind)
            local PixelX, PixelY = MathFloor(CenterX + 0.5), MathFloor(TitleCenterY + 0.5)
            local Size = 20
            local RestX, RestY = PixelX - Size / 2, PixelY - Size / 2
            local Hovered = IsMouseInside(RestX, RestY, Size, Size)
            local Key = "_ctl_" .. Kind
            State[Key] = Approach(State[Key] or 0, Hovered and 1 or 0, 14)
            if MathAbs(State[Key] - (Hovered and 1 or 0)) < 0.004 then
                State[Key] = Hovered and 1 or 0
            end
            local HoverFade = State[Key]
            FillRect(RestX, RestY, Size, Size, AccentMid, 13, 6, 0.14 * HoverFade * DrawVisible)
            StrokeRect(RestX, RestY, Size, Size, AccentMid, 14, 6, 0.55 * HoverFade * DrawVisible)
            local Color = LerpColor(White, AccentMid, HoverFade)
            local Opacity2 = (0.5 + 0.45 * HoverFade) * DrawVisible
            if Kind == "close" then
                local Result = 4
                DrawThickLine(
                    PixelX - Result,
                    PixelY - Result,
                    PixelX + Result,
                    PixelY + Result,
                    1.8,
                    Color,
                    16,
                    Opacity2
                )
                DrawThickLine(
                    PixelX + Result,
                    PixelY - Result,
                    PixelX - Result,
                    PixelY + Result,
                    1.8,
                    Color,
                    16,
                    Opacity2
                )
            elseif Kind == "search" then
                DrawCircle(PixelX - 1, PixelY - 1, 3.2, Color, 16, false, 1.5, 18, Opacity2)
                DrawThickLine(PixelX + 1.3, PixelY + 1.3, PixelX + 4.2, PixelY + 4.2, 1.7, Color, 16, Opacity2)
            else
                DrawThickLine(PixelX - 4, PixelY, PixelX + 4, PixelY, 1.8, Color, 15, Opacity2)
            end
            return Hovered
        end
        local function OpenSpotlight()
            State.spotlightOpen = true
            State.spotlight = {query = "", sel = 1}
            State.focus = nil
        end
        local SearchStyle = "off"
        if SearchStyle == "icon" then
            local ControlHovered = DrawControl(X + Width - 71, "search")
            if ControlHovered then
                ShowTooltip("Search  \194\183  Ctrl+Space", State.mouseX, State.mouseY)
            end
            if ControlHovered and Clicked and NoPopup then
                OpenSpotlight()
                Clicked = false
            end
        elseif SearchStyle == "bar" then
            local SearchWidth =
                MathFloor(MathMin(190, MathMax(100, (SideLayout and Width - SliceWidth or Width) * 0.28)))
            local RestX, RestY = X + Width - 66 - SearchWidth, TitleCenterY - 9
            local SearchHovered = IsMouseInside(RestX, RestY, SearchWidth, 18)
            State._sbHov = Approach(State._sbHov or 0, SearchHovered and 1 or 0, 12)
            if MathAbs(State._sbHov - (SearchHovered and 1 or 0)) < 0.004 then
                State._sbHov = SearchHovered and 1 or 0
            end
            local SbHov = State._sbHov
            FillRect(RestX, RestY, SearchWidth, 18, White, 13, 9, (Opacity.field + 0.04 * SbHov) * DrawVisible)
            StrokeRect(RestX, RestY, SearchWidth, 18, AccentMid, 14, 9, (0.12 + 0.4 * SbHov) * DrawVisible)
            DrawCircle(
                RestX + 10,
                TitleCenterY - 1,
                3,
                AccentMid,
                15,
                false,
                1.3,
                18,
                (0.7 + 0.3 * SbHov) * DrawVisible
            )
            DrawThickLine(
                RestX + 11.8,
                TitleCenterY + 1.2,
                RestX + 14.4,
                TitleCenterY + 3.8,
                1.4,
                AccentMid,
                15,
                (0.7 + 0.3 * SbHov) * DrawVisible
            )
            DrawText(
                "Search",
                RestX + 20,
                CenterTextY(RestY, 18, 12),
                White,
                12,
                FontSystem,
                15,
                false,
                false,
                SearchWidth - 26,
                (Opacity.dim + 0.12 * SbHov) * DrawVisible
            )
            if SearchHovered then
                ShowTooltip("Ctrl+Space", State.mouseX, State.mouseY)
            end
            if Clicked and SearchHovered and NoPopup then
                OpenSpotlight()
                Clicked = false
            end
        end
        if DrawControl(X + Width - 21, "close") and Clicked and NoPopup then
            SetOpen(false)
            Clicked = false
        end
        local TitleHovered =
            SideLayout and
            (IsMouseInside(X + SliceWidth, Y, Width - SliceWidth, HeaderHeight) or IsMouseInside(X, Y, SliceWidth, 42)) or
            IsMouseInside(X, Y, Width, TitleHeight)
        if Clicked and NoPopup and not State.drag and not State.resizeEdge and TitleHovered then
            State.drag = {ox = State.mouseX - X, oy = State.mouseY - Y}
            Clicked = false
        end
        if SideLayout then
            local TitleX = X + 16
            if State.logoImg then
                local ImageSize = State.logoSize or 30
                local LogoY = Y + 22 + ((State.subtitle ~= "" and 30 or 18) - 22) * ExpandFade
                local LogoX = TitleX - 4 * (1 - ExpandFade)
                pcall(function()
                    State.logoImg.Position = NewVector2(LogoX, LogoY - ImageSize / 2)
                    State.logoImg.Size = NewVector2(ImageSize, ImageSize)
                    pcall(function()
                        State.logoImg.Rounding = ImageSize * 0.22
                    end)
                    State.logoImg.ZIndex = 629999
                    State.logoImg.Transparency = DrawVisible
                    State.logoImg.Visible = DrawVisible > 0.01
                end)
                if State.iconImg then
                    pcall(function()
                        State.iconImg.Visible = false
                    end)
                end
                TitleX = TitleX + ImageSize + 9
            elseif State.iconImg then
                TitleX = X + 44
            else
                local Initial = string.upper(string.sub(State.title or "", 1, 1))
                if Initial ~= "" then
                    local BadgeSize = 26
                    local BadgeX = X + 16 + BadgeSize / 2 - 4 * (1 - ExpandFade)
                    local BadgeY = Y + 22 + ((State.subtitle ~= "" and 30 or 18) - 22) * ExpandFade
                    FillRect(
                        BadgeX - BadgeSize / 2,
                        BadgeY - BadgeSize / 2,
                        BadgeSize,
                        BadgeSize,
                        State._accentMid,
                        61,
                        7,
                        0.16 * DrawVisible
                    )
                    StrokeRect(
                        BadgeX - BadgeSize / 2,
                        BadgeY - BadgeSize / 2,
                        BadgeSize,
                        BadgeSize,
                        White,
                        61,
                        7,
                        Opacity.cardStrk * DrawVisible
                    )
                    DrawCenteredText(
                        Initial,
                        BadgeX,
                        BadgeY,
                        State._accentMid,
                        15,
                        FontBold,
                        62,
                        Opacity.text * DrawVisible
                    )
                    TitleX = X + 16 + BadgeSize + 9
                end
            end
            do
                local TitleWidth = MathMax(2, X + SliceWidth - 14 - TitleX)
                local TitleSize = 16
                local TitleTextWidth = MeasureText(State.title, TitleSize, FontBold)
                if TitleTextWidth > TitleWidth then
                    TitleSize = MathMax(11, MathFloor(TitleSize * TitleWidth / TitleTextWidth))
                end
                local TitleY, TitleAlpha = Y + 20 - MathFloor(TitleSize / 2), Opacity.text * DrawVisible * ExpandFade
                DrawText(
                    State.title,
                    TitleX,
                    TitleY + 1,
                    NewColor(0, 0, 0),
                    TitleSize,
                    FontBold,
                    60,
                    false,
                    false,
                    TitleWidth,
                    0.28 * TitleAlpha
                )
                DrawText(
                    State.title,
                    TitleX,
                    TitleY,
                    State._accentMid,
                    TitleSize,
                    FontBold,
                    61,
                    false,
                    false,
                    TitleWidth,
                    TitleAlpha
                )
            end
            local DividerY = Y + 34
            if State.subtitle ~= "" then
                DrawText(
                    State.subtitle,
                    TitleX,
                    Y + 34,
                    White,
                    11,
                    FontSystem,
                    61,
                    false,
                    false,
                    MathMax(2, X + SliceWidth - 14 - TitleX),
                    Opacity.dim * DrawVisible * ExpandFade
                )
                DividerY = Y + 50
            end
            DrawGradient(
                X + 12,
                DividerY,
                SliceWidth - 24,
                1,
                Theme.accentA,
                Theme.accentB,
                61,
                0.3 * DrawVisible * ExpandFade
            )
            local RailX, RailWidth2 = X + 12, SliceWidth - 24
            local TabHeight, SubTabHeight, TabRounding, SubTabRounding = 30, 24, 7, 6
            local IconGrey = NewColor(150, 153, 161)
            local IconIdle = NewColor(188, 191, 199)
            local CategoryColor = NewColor(120, 122, 132)
            local AccentMid2 = State._accentMid
            local RowY = MathFloor(Y + 50 + (DividerY + 12 - (Y + 50)) * ExpandFade)
            local LastCategory = nil
            for Index, Tab in ipairs(State.tabs) do
                if not Tab.hidden then
                    if Tab.category and Tab.category ~= LastCategory then
                        RowY = RowY + (LastCategory == nil and 6 or 12) * ExpandFade
                        DrawText(
                            string.upper(Tab.category),
                            RailX + 2,
                            RowY,
                            CategoryColor,
                            11,
                            FontBold,
                            61,
                            false,
                            false,
                            RailWidth2 - 4,
                            0.42 * DrawVisible * ExpandFade
                        )
                        RowY = RowY + 4 + 16 * ExpandFade
                        LastCategory = Tab.category
                    end
                    local SubCount = #Tab.subs
                    local IsActive = State.activeTab == Tab
                    local IsSelected = IsActive and SubCount == 0
                    local Hovered = IsMouseInside(RailX, RowY, RailWidth2, TabHeight) and NoPopup
                    local Hovered2 = Hovered and State.hoverEffects ~= false
                    local ActiveFade = Approach(Tab._af or 0, IsSelected and 1 or 0, 12)
                    if MathAbs(ActiveFade - (IsSelected and 1 or 0)) < 0.004 then
                        ActiveFade = IsSelected and 1 or 0
                    end
                    Tab._af = ActiveFade
                    local BounceFade = Approach(Tab._bf or 0, IsActive and 1 or 0, 16)
                    if MathAbs(BounceFade - (IsActive and 1 or 0)) < 0.004 then
                        BounceFade = IsActive and 1 or 0
                    end
                    Tab._bf = BounceFade
                    local HoverFade = Approach(Tab._hf or 0, Hovered2 and 1 or 0, 18)
                    if MathAbs(HoverFade - (Hovered2 and 1 or 0)) < 0.004 then
                        HoverFade = Hovered2 and 1 or 0
                    end
                    Tab._hf = HoverFade
                    local Expand = Approach(Tab._exp or 0, IsActive and 1 or 0, IsActive and 14 or 17)
                    if MathAbs(Expand - (IsActive and 1 or 0)) < 0.004 then
                        Expand = IsActive and 1 or 0
                    end
                    Tab._exp = Expand
                    Tab._flash = Approach(Tab._flash or 0, 0, 5)
                    if Tab._flash < 0.004 then
                        Tab._flash = 0
                    end
                    local LabelMix = ActiveFade + (1 - ActiveFade) * 0.5 * HoverFade
                    local IconMix = SubCount > 0 and MathMax(0.5 * HoverFade, Tab._flash) or LabelMix
                    local Slide = 1.5 * HoverFade * (1 - ActiveFade)
                    FillRect(
                        RailX,
                        RowY,
                        RailWidth2,
                        TabHeight,
                        LerpColor(White, AccentMid2, 0.35),
                        61,
                        TabRounding,
                        (0.055 * ActiveFade + 0.05 * HoverFade * (1 - ActiveFade)) * DrawVisible
                    )
                    local IconColor = LerpColor(IconIdle, AccentMid2, IconMix)
                    local LabelX = RailX + 13
                    if Tab.icon then
                        local IconY = RowY + (TabHeight - 16) / 2
                        local IconX = RailX + 10 - 3 * (1 - ExpandFade) + Slide
                        local IconAlpha = (0.7 + 0.3 * IconMix) * DrawVisible
                        local AccentIconData = IconImages[Tab.icon .. "#a"]
                        if IconImages[Tab.icon] and AccentIconData then
                            if not Tab._img then
                                Tab._ic = {}
                                pcall(function()
                                    Tab._img = Drawing.new("Image")
                                    Tab._img.Data = IconImages[Tab.icon]
                                end)
                            end
                            if not Tab._imgA then
                                Tab._icA = {}
                                pcall(function()
                                    Tab._imgA = Drawing.new("Image")
                                    Tab._imgA.Data = AccentIconData
                                end)
                                Tab._icaKey = State._iconAccentKey
                            end
                            if Tab._imgA and Tab._icaKey ~= State._iconAccentKey then
                                Tab._icaKey = State._iconAccentKey
                                pcall(function()
                                    Tab._imgA.Data = AccentIconData
                                end)
                            end
                            PlaceImg(Tab._img, Tab._ic, IconX, IconY, 16, 16, 629998, IconAlpha, IconAlpha > 0.01)
                            PlaceImg(
                                Tab._imgA,
                                Tab._icA,
                                IconX,
                                IconY,
                                16,
                                16,
                                629999,
                                IconAlpha * IconMix,
                                IconAlpha * IconMix > 0.01
                            )
                        elseif IconDrawers[Tab.icon] then
                            if Tab._img then
                                PlaceImg(Tab._img, Tab._ic, IconX, IconY, 16, 16, 629998, 0, false)
                            end
                            if Tab._imgA then
                                PlaceImg(Tab._imgA, Tab._icA, IconX, IconY, 16, 16, 629999, 0, false)
                            end
                            DrawIcon(Tab.icon, IconX, IconY, 16, IconColor, 62, IconAlpha)
                        elseif IconImages[Tab.icon] then
                            if not Tab._img then
                                Tab._ic = {}
                                pcall(function()
                                    Tab._img = Drawing.new("Image")
                                    Tab._img.Data = IconImages[Tab.icon]
                                end)
                            end
                            PlaceImg(Tab._img, Tab._ic, IconX, IconY, 16, 16, 629999, IconAlpha, IconAlpha > 0.01)
                        end
                        LabelX = RailX + 34
                    end
                    local MaxWidth = MathMax(2, X + SliceWidth - 18 - LabelX)
                    DrawText(
                        Tab.name,
                        LabelX + 1,
                        CenterTextY(RowY, TabHeight, 13) + 1,
                        NewColor(0, 0, 0),
                        13,
                        FontBold,
                        62,
                        false,
                        false,
                        MaxWidth,
                        0.22 * ActiveFade * DrawVisible
                    )
                    DrawText(
                        Tab.name,
                        LabelX + Slide,
                        CenterTextY(RowY, TabHeight, 13),
                        LerpColor(IconGrey, White, LabelMix),
                        13,
                        FontBold,
                        63,
                        false,
                        false,
                        MaxWidth,
                        (0.90 + 0.10 * ActiveFade) * DrawVisible * ExpandFade
                    )
                    if Clicked and Hovered then
                        State.activeTab = Tab
                        State.activeIndex = Index
                        State.contentFade = 0
                        Tab._flash = 1
                        if SubCount > 0 then
                            local LastSub = Tab._lastSub
                            local Success = false
                            if LastSub then
                                for _, Value in ipairs(Tab.subs) do
                                    if Value == LastSub then
                                        Success = true
                                        break
                                    end
                                end
                            end
                            if not Success then
                                LastSub = Tab.subs[1]
                            end
                            State.activeSub = LastSub
                            Tab._lastSub = LastSub
                        else
                            State.activeSub = nil
                        end
                        Clicked = false
                    end
                    local TabExtent = TabHeight
                    if SubCount > 0 then
                        local SubTop = RowY + TabHeight + 4
                        local SubStagger = MathMin(0.10, 0.7 / MathMax(1, SubCount - 1))
                        local TrackSpace = MathMax(0.001, 1 - (SubCount - 1) * SubStagger)
                        for Key, Sub in ipairs(Tab.subs) do
                            local SubFade = Clamp((Expand - (Key - 1) * SubStagger) / TrackSpace, 0, 1)
                            SubFade = SubFade * SubFade * (3 - 2 * SubFade)
                            local ScrollPos = Y + HeaderHeight + 6
                            local SubActive = State.activeSub == Sub
                            local SearchHovered =
                                IsMouseInside(X + SliceWidth + 16 + (Key - 1) * 92, ScrollPos, 86, SubTabHeight) and
                                SubFade > 0.5 and
                                Expand > 0.5 and
                                NoPopup and
                                State.hoverEffects ~= false
                            local SubActiveFade = Approach(Sub._af or 0, SubActive and 1 or 0, 12)
                            if MathAbs(SubActiveFade - (SubActive and 1 or 0)) < 0.004 then
                                SubActiveFade = SubActive and 1 or 0
                            end
                            Sub._af = SubActiveFade
                            local SubHoverFade = Approach(Sub._hf or 0, SearchHovered and 1 or 0, 18)
                            if MathAbs(SubHoverFade - (SearchHovered and 1 or 0)) < 0.004 then
                                SubHoverFade = SearchHovered and 1 or 0
                            end
                            Sub._hf = SubHoverFade
                            local SubX, SubWidth = X + SliceWidth + 16 + (Key - 1) * 92, 86
                            local SubMix = SubActiveFade + (1 - SubActiveFade) * 0.35 * SubHoverFade
                            local SubColor = LerpColor(IconIdle, AccentMid2, SubMix)
                            FillRect(
                                SubX,
                                ScrollPos,
                                SubWidth,
                                SubTabHeight,
                                LerpColor(White, AccentMid2, 0.35),
                                62,
                                SubTabRounding,
                                (0.05 * SubActiveFade + 0.04 * SubHoverFade * (1 - SubActiveFade)) * SubFade *
                                    DrawVisible
                            )
                            local SubLabelX = SubX + 20
                            if Sub.icon then
                                local SubIconY = ScrollPos + (SubTabHeight - 14) / 2
                                local SubIconAlpha = SubFade * (0.7 + 0.3 * SubMix) * DrawVisible
                                local SubAccentIconData = IconImages[Sub.icon .. "#a"]
                                if IconImages[Sub.icon] and SubAccentIconData then
                                    if not Sub._img then
                                        Sub._ic = {}
                                        pcall(function()
                                            Sub._img = Drawing.new("Image")
                                            Sub._img.Data = IconImages[Sub.icon]
                                        end)
                                    end
                                    if not Sub._imgA then
                                        Sub._icA = {}
                                        pcall(function()
                                            Sub._imgA = Drawing.new("Image")
                                            Sub._imgA.Data = SubAccentIconData
                                        end)
                                        Sub._icaKey = State._iconAccentKey
                                    end
                                    if Sub._imgA and Sub._icaKey ~= State._iconAccentKey then
                                        Sub._icaKey = State._iconAccentKey
                                        pcall(function()
                                            Sub._imgA.Data = SubAccentIconData
                                        end)
                                    end
                                    PlaceImg(
                                        Sub._img,
                                        Sub._ic,
                                        SubX + 9,
                                        SubIconY,
                                        14,
                                        14,
                                        629998,
                                        SubIconAlpha,
                                        SubIconAlpha > 0.01
                                    )
                                    PlaceImg(
                                        Sub._imgA,
                                        Sub._icA,
                                        SubX + 9,
                                        SubIconY,
                                        14,
                                        14,
                                        629999,
                                        SubIconAlpha * SubMix,
                                        SubIconAlpha * SubMix > 0.01
                                    )
                                elseif IconDrawers[Sub.icon] then
                                    if Sub._img then
                                        PlaceImg(Sub._img, Sub._ic, SubX + 9, SubIconY, 14, 14, 629998, 0, false)
                                    end
                                    if Sub._imgA then
                                        PlaceImg(Sub._imgA, Sub._icA, SubX + 9, SubIconY, 14, 14, 629999, 0, false)
                                    end
                                    DrawIcon(Sub.icon, SubX + 9, SubIconY, 14, SubColor, 63, SubIconAlpha)
                                elseif IconImages[Sub.icon] then
                                    if not Sub._img then
                                        Sub._ic = {}
                                        pcall(function()
                                            Sub._img = Drawing.new("Image")
                                            Sub._img.Data = IconImages[Sub.icon]
                                        end)
                                    end
                                    PlaceImg(
                                        Sub._img,
                                        Sub._ic,
                                        SubX + 9,
                                        SubIconY,
                                        14,
                                        14,
                                        629999,
                                        SubIconAlpha,
                                        SubIconAlpha > 0.01
                                    )
                                end
                                SubLabelX = SubX + 28
                            else
                                DrawCircle(
                                    SubX + 11,
                                    ScrollPos + SubTabHeight / 2,
                                    2,
                                    SubColor,
                                    63,
                                    true,
                                    1,
                                    12,
                                    SubFade * (0.5 + 0.5 * SubActiveFade) * DrawVisible
                                )
                            end
                            DrawText(
                                Sub.name,
                                SubLabelX,
                                CenterTextY(ScrollPos, SubTabHeight, 12),
                                LerpColor(IconGrey, White, SubMix),
                                12,
                                FontSystem,
                                63,
                                false,
                                false,
                                SubWidth - (SubLabelX - SubX) - 6,
                                (0.86 + 0.14 * SubActiveFade) * SubFade * DrawVisible
                            )
                            if
                                Clicked and IsMouseInside(SubX, ScrollPos, SubWidth, SubTabHeight) and SubFade > 0.5 and
                                    Expand > 0.5 and
                                    NoPopup
                             then
                                State.activeTab = Tab
                                State.activeSub = Sub
                                Tab._lastSub = Sub
                                State.activeIndex = Index
                                State.contentFade = 0
                                Clicked = false
                            end
                        end
                        TabExtent = TabExtent
                    end
                    RowY = RowY + TabExtent + 2 + 4 * ExpandFade
                end
            end
            do
                if not State._plResolved and LocalPlayer then
                    local Name, DisplayText = "player", "player"
                    pcall(function()
                        if LocalPlayer then
                            Name = tostring(LocalPlayer.Name or "player")
                        end
                    end)
                    pcall(function()
                        if LocalPlayer and LocalPlayer.DisplayName and LocalPlayer.DisplayName ~= "" then
                            DisplayText = tostring(LocalPlayer.DisplayName)
                        else
                            DisplayText = Name
                        end
                    end)
                    State._plDisp = DisplayText
                    State._plInitial = string.upper(string.sub(DisplayText, 1, 1))
                    State._plHandle = "@" .. Name
                    State._plResolved = true
                end
                local DisplayText = State._plDisp or "player"
                local FooterY = Y + Height - 46
                do
                    local HalfWidth = (SliceWidth - 28) / 2
                    local LineAlpha = Opacity.hairline * 1.8 * DrawVisible * ExpandFade
                    State.fadeLine(X + 14, FooterY - 10, HalfWidth, White, 61, LineAlpha, true)
                    State.fadeLine(X + 14 + HalfWidth, FooterY - 10, HalfWidth, White, 61, LineAlpha)
                end
                local AvatarX, AvatarY = X + 29, FooterY + 16
                if State.avatarImg then
                    pcall(function()
                        State.avatarImg.Position = NewVector2(AvatarX - 14, AvatarY - 14)
                        State.avatarImg.Size = NewVector2(28, 28)
                        State.avatarImg.ZIndex = 629999
                        State.avatarImg.Transparency = DrawVisible
                        pcall(function()
                            State.avatarImg.Rounding = 14
                        end)
                        State.avatarImg.Visible = DrawVisible > 0.01
                    end)
                    DrawCircle(AvatarX, AvatarY, 14, White, 63, false, 1, 28, Opacity.hairline * DrawVisible)
                else
                    DrawCircle(AvatarX, AvatarY, 14, State._accentMid, 61, true, 1, 28, 0.18 * DrawVisible)
                    DrawCircle(AvatarX, AvatarY, 14, White, 62, false, 1, 28, Opacity.hairline * DrawVisible)
                    local Initial = State._plInitial or "P"
                    local InitialWidth = MeasureText(Initial, 13, FontBold)
                    DrawText(
                        Initial,
                        AvatarX - InitialWidth / 2,
                        AvatarY - 7,
                        White,
                        13,
                        FontBold,
                        62,
                        false,
                        false,
                        nil,
                        Opacity.text * DrawVisible
                    )
                end
                DrawText(
                    DisplayText,
                    X + 50,
                    FooterY + 6,
                    White,
                    12,
                    FontBold,
                    62,
                    false,
                    false,
                    MathMax(2, SliceWidth - 100),
                    Opacity.text * DrawVisible * ExpandFade
                )
                DrawText(
                    "Expires in 23h",
                    X + 50,
                    FooterY + 22,
                    White,
                    11,
                    FontSystem,
                    62,
                    false,
                    false,
                    MathMax(2, SliceWidth - 100),
                    Opacity.dim * DrawVisible * ExpandFade
                )
                if State.settingsTab then
                    local GearX, GearY = X + SliceWidth - 26, AvatarY
                    local GearHovered = ExpandFade > 0.5 and IsMouseInside(GearX - 15, GearY - 15, 30, 30)
                    local GearActive = State.activeTab == State.settingsTab
                    local GearAlpha =
                        (GearActive and Opacity.hover or (GearHovered and Opacity.label or Opacity.dim)) * DrawVisible *
                        ExpandFade
                    local GearFade = Approach(State._gearAf or 0, (GearActive or GearHovered) and 1 or 0, 13)
                    State._gearAf = GearFade
                    FillRect(
                        GearX - 15,
                        GearY - 15,
                        30,
                        30,
                        White,
                        61,
                        8,
                        Opacity.tabFill * (GearActive and 1 or 0.6) * GearFade * DrawVisible * ExpandFade
                    )
                    StrokeRect(
                        GearX - 15,
                        GearY - 15,
                        30,
                        30,
                        White,
                        61,
                        8,
                        Opacity.cardStrk * GearFade * DrawVisible * ExpandFade
                    )
                    local GearName = State.settingsIcon or "cog"
                    local GearSize = 20
                    if IconImages[GearName] then
                        if not State._gearImg then
                            pcall(function()
                                State._gearImg = Drawing.new("Image")
                                State._gearImg.Data = IconImages[GearName]
                            end)
                        end
                        if State._gearImg then
                            pcall(function()
                                State._gearImg.Position = NewVector2(GearX - GearSize / 2, GearY - GearSize / 2)
                                State._gearImg.Size = NewVector2(GearSize, GearSize)
                                State._gearImg.ZIndex = 629999
                                State._gearImg.Transparency = GearAlpha
                                State._gearImg.Visible = GearAlpha > 0.01
                            end)
                        end
                    else
                        DrawIcon(GearName, GearX - GearSize / 2, GearY - GearSize / 2, GearSize, White, 62, GearAlpha)
                    end
                    if Clicked and GearHovered and NoPopup then
                        if GearActive then
                            State.activeTab = State._prevTab or State.tabs[1]
                            State.activeIndex = State._prevIndex or 1
                        else
                            State._prevTab = State.activeTab
                            State._prevIndex = State.activeIndex
                            State.activeTab = State.settingsTab
                            State.activeIndex = State.settingsIndex or #State.tabs
                        end
                        State.contentFade = 0
                        Clicked = false
                    end
                end
            end
        else
            local TabBarY = Y + TitleHeight
            local TabBarCenter = TabBarY + TabBarHeight / 2
            local AccentMid2 = AccentMid
            local RightEdge = X + Width - 14
            if State.settingsTab then
                local GearX, GearY = X + Width - 26, TabBarCenter
                local GearHovered = IsMouseInside(GearX - 14, GearY - 14, 28, 28)
                local GearActive = State.activeTab == State.settingsTab
                local GearAlpha =
                    (GearActive and Opacity.hover or (GearHovered and Opacity.label or Opacity.dim)) * DrawVisible
                local GearFade = Approach(State._gearAf or 0, (GearActive or GearHovered) and 1 or 0, 13)
                State._gearAf = GearFade
                FillRect(
                    GearX - 14,
                    GearY - 14,
                    28,
                    28,
                    White,
                    13,
                    8,
                    Opacity.tabFill * (GearActive and 1 or 0.6) * GearFade * DrawVisible
                )
                local GearName = State.settingsIcon or "cog"
                if IconImages[GearName] then
                    if not State._gearImg then
                        pcall(function()
                            State._gearImg = Drawing.new("Image")
                            State._gearImg.Data = IconImages[GearName]
                        end)
                    end
                    if State._gearImg then
                        pcall(function()
                            State._gearImg.Position = NewVector2(GearX - 9, GearY - 9)
                            State._gearImg.Size = NewVector2(18, 18)
                            State._gearImg.ZIndex = 169999
                            State._gearImg.Transparency = GearAlpha
                            State._gearImg.Visible = GearAlpha > 0.01
                        end)
                    end
                else
                    DrawIcon(GearName, GearX - 9, GearY - 9, 18, White, 15, GearAlpha)
                end
                if Clicked and GearHovered and NoPopup then
                    if GearActive then
                        State.activeTab = State._prevTab or State.tabs[1]
                        State.activeIndex = State._prevIndex or 1
                    else
                        State._prevTab = State.activeTab
                        State._prevIndex = State.activeIndex
                        State.activeTab = State.settingsTab
                        State.activeIndex = State.settingsIndex or #State.tabs
                    end
                    State.contentFade = 0
                    Clicked = false
                end
                RightEdge = GearX - 22
            end
            local AvatarX, AvatarY = RightEdge - 13, TabBarCenter
            if State.avatarImg then
                pcall(function()
                    State.avatarImg.Position = NewVector2(AvatarX - 11, AvatarY - 11)
                    State.avatarImg.Size = NewVector2(22, 22)
                    State.avatarImg.ZIndex = 169999
                    State.avatarImg.Transparency = DrawVisible
                    pcall(function()
                        State.avatarImg.Rounding = 11
                    end)
                    State.avatarImg.Visible = DrawVisible > 0.01
                end)
                DrawCircle(AvatarX, AvatarY, 11, White, 17, false, 1, 24, Opacity.hairline * DrawVisible)
            else
                local Initial =
                    State._plInitial or string.upper(string.sub(LocalPlayer and LocalPlayer.Name or "P", 1, 1))
                DrawCircle(AvatarX, AvatarY, 11, State._accentMid, 13, true, 1, 24, 0.18 * DrawVisible)
                DrawCircle(AvatarX, AvatarY, 11, White, 14, false, 1, 24, Opacity.hairline * DrawVisible)
                local InitialWidth = MeasureText(Initial, 12, FontBold)
                DrawText(
                    Initial,
                    AvatarX - InitialWidth / 2,
                    AvatarY - 6,
                    White,
                    12,
                    FontBold,
                    15,
                    false,
                    false,
                    nil,
                    Opacity.text * DrawVisible
                )
            end
            local TextX = X + 14
            for Index, Tab in ipairs(State.tabs) do
                if not Tab.hidden then
                    local IsActive = State.activeTab == Tab
                    local IconSpace = Tab.icon and 22 or 0
                    local TabWidth = IconSpace + MeasureText(Tab.name, 14, FontBold) + 24
                    local TabHeight = 26
                    local TabY = TabBarCenter - TabHeight / 2
                    local Hovered = IsMouseInside(TextX, TabY, TabWidth, TabHeight)
                    local Hovered2 = Hovered and State.hoverEffects ~= false
                    local ActiveFade = Approach(Tab._af or 0, IsActive and 1 or 0, 13)
                    Tab._af = ActiveFade
                    FillRect(TextX, TabY, TabWidth, TabHeight, White, 13, 7, Opacity.tabFill * ActiveFade * DrawVisible)
                    StrokeRect(
                        TextX,
                        TabY,
                        TabWidth,
                        TabHeight,
                        White,
                        14,
                        7,
                        Opacity.cardStrk * ActiveFade * DrawVisible
                    )
                    FillRect(
                        TextX + TabWidth / 2 - 8 * ActiveFade,
                        TabBarY + TabBarHeight - 3,
                        MathMax(1, 16 * ActiveFade),
                        2,
                        AccentMid2,
                        15,
                        1,
                        0.95 * ActiveFade * DrawVisible
                    )
                    FillRect(
                        TextX,
                        TabY,
                        TabWidth,
                        TabHeight,
                        White,
                        13,
                        7,
                        (Hovered2 and not IsActive and 0.07 or 0) * DrawVisible
                    )
                    local TextAlpha =
                        (IsActive and Opacity.hover or (Hovered2 and Opacity.label or Opacity.dim)) * DrawVisible
                    local TextX2 = TextX + 12
                    if Tab.icon then
                        local IconY = TabBarCenter - 8
                        local AccentIconData = IconImages[Tab.icon .. "#a"]
                        if IconImages[Tab.icon] and AccentIconData then
                            if not Tab._img then
                                Tab._ic = {}
                                pcall(function()
                                    Tab._img = Drawing.new("Image")
                                    Tab._img.Data = IconImages[Tab.icon]
                                end)
                            end
                            if not Tab._imgA then
                                Tab._icA = {}
                                pcall(function()
                                    Tab._imgA = Drawing.new("Image")
                                    Tab._imgA.Data = AccentIconData
                                end)
                                Tab._icaKey = State._iconAccentKey
                            end
                            if Tab._imgA and Tab._icaKey ~= State._iconAccentKey then
                                Tab._icaKey = State._iconAccentKey
                                pcall(function()
                                    Tab._imgA.Data = AccentIconData
                                end)
                            end
                            PlaceImg(Tab._img, Tab._ic, TextX + 10, IconY, 16, 16, 169998, TextAlpha, TextAlpha > 0.01)
                            PlaceImg(
                                Tab._imgA,
                                Tab._icA,
                                TextX + 10,
                                IconY,
                                16,
                                16,
                                169999,
                                TextAlpha * ActiveFade,
                                TextAlpha * ActiveFade > 0.01
                            )
                        elseif IconImages[Tab.icon] then
                            if not Tab._img then
                                Tab._ic = {}
                                pcall(function()
                                    Tab._img = Drawing.new("Image")
                                    Tab._img.Data = IconImages[Tab.icon]
                                end)
                            end
                            PlaceImg(Tab._img, Tab._ic, TextX + 10, IconY, 16, 16, 169999, TextAlpha, TextAlpha > 0.01)
                        else
                            DrawIcon(Tab.icon, TextX + 10, IconY, 16, White, 15, TextAlpha)
                        end
                        TextX2 = TextX + 30
                    end
                    DrawText(
                        Tab.name,
                        TextX2,
                        CenterTextY(TabY, TabHeight, 14),
                        IsActive and AccentMid or White,
                        14,
                        FontBold,
                        15,
                        false,
                        false,
                        TabWidth,
                        TextAlpha
                    )
                    if Clicked and Hovered and NoPopup then
                        if State.activeTab ~= Tab then
                            State.activeTab = Tab
                            State.activeIndex = Index
                            State.contentFade = 0
                        end
                        Clicked = false
                    end
                    TextX = TextX + TabWidth + 6
                end
            end
            DrawLine(
                X,
                TabBarY + TabBarHeight,
                X + Width,
                TabBarY + TabBarHeight,
                White,
                12,
                1,
                Opacity.hairline * DrawVisible
            )
        end
        local CenterX, CharWidth2, ContentY, OffsetX, SwitchWidth
        if SideLayout then
            CenterX = X + SliceWidth
            CharWidth2 = Width - SliceWidth
            ContentY =
                Y + HeaderHeight +
                ((State.activeTab and State.activeTab.subs and #State.activeTab.subs > 0) and 42 or 10)
            OffsetX = CenterX + 12
            SwitchWidth = CharWidth2 - 24 - 6
        else
            CenterX = X
            CharWidth2 = Width
            ContentY = Y + TitleHeight + TabBarHeight + 8
            OffsetX = X + 14
            SwitchWidth = Width - 28 - 6
        end
        DrawLine(
            X + Width - 14,
            Y + Height - 5,
            X + Width - 5,
            Y + Height - 14,
            White,
            13,
            1,
            Opacity.dim * DrawVisible
        )
        DrawLine(
            X + Width - 11,
            Y + Height - 5,
            X + Width - 5,
            Y + Height - 11,
            White,
            13,
            1,
            Opacity.dim * DrawVisible
        )
        DrawLine(X + Width - 8, Y + Height - 5, X + Width - 5, Y + Height - 8, White, 13, 1, Opacity.dim * DrawVisible)
        if Clicked and NoPopup and not State.drag and not State.resizeEdge then
            local CornerHovered = IsMouseInside(X + Width - 22, Y + Height - 22, 24, 24)
            local RightHovered = IsMouseInside(X + Width - CharWidth, Y, CharWidth + 2, Height)
            local BottomHovered = IsMouseInside(X, Y + Height - CharWidth, Width, CharWidth + 2)
            local Fade =
                CornerHovered and "br" or RightHovered and BottomHovered and "br" or RightHovered and "r" or
                BottomHovered and "b" or
                nil
            if Fade then
                State.resizeEdge = Fade
                State.resizeStart = {w = Width, h = Height, mx = State.mouseX, my = State.mouseY}
                Clicked = false
            end
        end
        local ContentHeight = Y + Height - ContentY - 10
        State.contentFade = Approach(State.contentFade, 1, 12)
        if State.contentFade > 0.997 then
            State.contentFade = 1
        end
        if State.activeTab then
            Clicked, RightClicked =
                DrawTabContent(
                State.activeSub or State.activeTab,
                Clicked,
                Held,
                RightClicked,
                OffsetX,
                ContentY,
                SwitchWidth,
                ContentHeight
            )
        end
        return Clicked, Held, RightClicked
    end
    local function DrawNotifications()
        local Notifications = State.notifications
        while #Notifications > 10 do
            TableRemove(Notifications, 1)
        end
        local ViewportWidth, ViewportHeight = GetViewportSize()
        local CardWidth = 292
        local BaseY = ViewportHeight - 16
        local Index = 1
        while Index <= #Notifications do
            local Entry = Notifications[Index]
            Entry.elapsed = Entry.elapsed + (State.dt or 1 / 60)
            if Entry.elapsed >= Entry.duration then
                TableRemove(Notifications, Index)
            else
                local DescriptionLines = WrapText(Entry.description or "", CardWidth - 40, 12, FontSystem)
                if #DescriptionLines == 0 then
                    DescriptionLines = {""}
                end
                if #DescriptionLines > 4 then
                    local Trimmed = {}
                    for TargetIndex = 1, 4 do
                        Trimmed[TargetIndex] = DescriptionLines[TargetIndex]
                    end
                    DescriptionLines = Trimmed
                end
                local CardHeight = 24 + #DescriptionLines * 15 + 14
                BaseY = BaseY - CardHeight
                Entry.targetX = ViewportWidth - CardWidth - 16
                Entry.targetY = BaseY
                Entry.currentX = Approach(Entry.currentX or ViewportWidth, Entry.targetX, 12)
                Entry.currentY = Approach(Entry.currentY or Entry.targetY, Entry.targetY, 12)
                local Fade = 1
                if Entry.elapsed < 0.25 then
                    Fade = Entry.elapsed / 0.25
                elseif Entry.duration - Entry.elapsed < 0.35 then
                    Fade = (Entry.duration - Entry.elapsed) / 0.35
                end
                local CurrentX, CurrentY = Entry.currentX, Entry.currentY
                local Type = Entry.ntype or Entry.title == "error" and "error" or nil
                local TypeColor =
                    Type == "success" and NewColor(95, 210, 135) or Type == "warning" and NewColor(255, 190, 70) or
                    Type == "error" and Theme.bad or
                    State._accentMid
                FillRect(CurrentX + 2, CurrentY + 3, CardWidth, CardHeight, NewColor(0, 0, 0), 299, 12, 0.16 * Fade)
                FillRect(CurrentX, CurrentY, CardWidth, CardHeight, Theme.bg, 300, 12, 0.97 * Fade)
                StrokeRect(CurrentX, CurrentY, CardWidth, CardHeight, White, 301, 12, 0.1 * Fade)
                DrawCircle(CurrentX + 17, CurrentY + 16, 3.5, TypeColor, 302, true, 1, 16, Fade)
                DrawText(
                    Entry.title,
                    CurrentX + 29,
                    CurrentY + 9,
                    Type and TypeColor or White,
                    13,
                    FontBold,
                    302,
                    false,
                    false,
                    CardWidth - 42,
                    (Type and 1 or Opacity.text) * Fade
                )
                for TargetIndex = 1, #DescriptionLines do
                    DrawText(
                        DescriptionLines[TargetIndex],
                        CurrentX + 29,
                        CurrentY + 26 + (TargetIndex - 1) * 15,
                        White,
                        12,
                        FontSystem,
                        302,
                        false,
                        false,
                        CardWidth - 40,
                        Opacity.label * Fade
                    )
                end
                local Fraction = Clamp(1 - Entry.elapsed / Entry.duration, 0, 1)
                local TrackX, BarWidth, TrackTop = CurrentX + 29, CardWidth - 45, CurrentY + CardHeight - 9
                FillRect(TrackX, TrackTop, BarWidth, 2, White, 302, 1, 0.12 * Fade)
                local SearchWidth = BarWidth * Fraction
                local BarAlpha = 0.95 * Fade * Clamp(SearchWidth, 0, 1)
                if Type then
                    FillRect(TrackX, TrackTop, MathMax(1, SearchWidth), 2, TypeColor, 303, 1, BarAlpha)
                else
                    DrawGradient(
                        TrackX,
                        TrackTop,
                        MathMax(1, SearchWidth),
                        2,
                        Theme.accentA,
                        Theme.accentB,
                        303,
                        BarAlpha
                    )
                end
                BaseY = BaseY - 8
                Index = Index + 1
            end
        end
    end
    local function DrawTooltip()
        if not State.tooltipsEnabled then
            return
        end
        local TooltipText = State.tooltipText
        if not TooltipText or TooltipText == "" then
            return
        end
        if (Clock() or 0) - (State.tooltipAt or 0) < 0.35 then
            return
        end
        if State._ttText ~= TooltipText then
            State._ttText = TooltipText
            State._ttLines = WrapText(TooltipText, 240, 12, FontUi)
        end
        local TtLines = State._ttLines
        local MaxWidth = 0
        for _, Line in ipairs(TtLines) do
            MaxWidth = MathMax(MaxWidth, MeasureText(Line, 12, FontUi))
        end
        local TooltipWidth = MathFloor(MaxWidth * 1.04) + 14
        local TooltipHeight = 7 + 15 * #TtLines
        local ViewportWidth, ViewportHeight = GetViewportSize()
        local X = Clamp(State.tooltipX + 12, 8, ViewportWidth - TooltipWidth - 8)
        local TooltipY = Clamp(State.tooltipY + 18, 8, ViewportHeight - TooltipHeight - 4)
        FillRect(X, TooltipY, TooltipWidth, TooltipHeight, Theme.bg, 320, 6, 0.96)
        StrokeRect(X, TooltipY, TooltipWidth, TooltipHeight, White, 321, 6, Opacity.cardStrk)
        for Index, Line in ipairs(TtLines) do
            DrawText(
                Line,
                X + 8,
                TooltipY + 4 + (Index - 1) * 15,
                White,
                12,
                FontUi,
                322,
                false,
                false,
                nil,
                Opacity.text
            )
        end
    end
    local DefaultConfigFolder = RegistryName .. "_configs"
    local function SanitizeFolderName(Text)
        Text = tostring(Text or ""):gsub("[^%w%-_ ]", " "):gsub("%s+", " "):gsub("^ +", ""):gsub(" +$", "")
        return Text
    end
    local function GetConfigFolder()
        return State.cfgFolder or DefaultConfigFolder
    end
    local function EnsureConfigFolder()
        pcall(function()
            local Object = GetConfigFolder()
            if not IsFolder(Object) then
                MakeFolder(Object)
            end
        end)
    end
    local function SerializeConfig()
        local Config = {
            flags = {},
            keybinds = {},
            colors = {},
            uiFont = State.uiFontName,
            layout = State.tabLayout,
            search = State.searchStyle
        }
        for _, Tab in ipairs(State.tabs) do
            for _, Entry in ipairs(Tab.sections) do
                for _, Item in ipairs(Entry.items) do
                    if Item.type == "rangeslider" and not Item.noSave then
                        local Key = Tab.name .. "." .. Entry.name .. "." .. Item.label
                        Config.flags[Key] = {Item.valueLo, Item.valueHi}
                        if Item.keybind then
                            Config.keybinds[Key] = {Item.keybind.value, Item.keybind.mode}
                        end
                    elseif Item.value ~= nil and Item.type ~= "button" and not Item.noSave then
                        local Key = Tab.name .. "." .. Entry.name .. "." .. Item.label
                        if Item.type == "colorpicker" then
                            Config.flags[Key] = {Item.value.R, Item.value.G, Item.value.B, Item.alpha or 1}
                        elseif Item.type == "dropdown" then
                            Config.flags[Key] = ToList(Item.value)
                        else
                            Config.flags[Key] = Item.value
                        end
                        if Item.keybind then
                            Config.keybinds[Key] = {Item.keybind.value, Item.keybind.mode}
                        end
                        if Item.colorpicker and Item.colorpicker.value then
                            local Value = Item.colorpicker.value
                            Config.colors[Key] = {Value.R, Value.G, Value.B, Item.colorpicker.alpha or 1}
                        end
                    end
                end
            end
        end
        local BaseA = State.baseAccentA or Theme.accentA
        local BaseB = State.baseAccentB or Theme.accentB
        Config.settings = {
            accentA = {BaseA.R, BaseA.G, BaseA.B},
            accentB = {BaseB.R, BaseB.G, BaseB.B},
            rainbow = State.rainbow == true,
            rainbowSpeed = State.rainbowSpeed,
            menuOpacity = State.menuOpacity,
            noAnim = State.noAnim == true,
            notifyDur = State.notifyDur,
            hoverEffects = State.hoverEffects ~= false,
            checkboxStyle = State.checkboxStyle == true,
            hotkeyEnabled = State.hotkeyEnabled ~= false,
            menuKey = MenuKey,
            w = State.w,
            h = State.h,
            bg = {Theme.bg.R, Theme.bg.G, Theme.bg.B},
            txt = {Theme.text.R, Theme.text.G, Theme.text.B},
            glowMul = State.glowMul,
            cardStrk = Opacity.cardStrk,
            hairline = Opacity.hairline,
            cardFill = Opacity.card,
            lite = State.lite == true,
            roundScale = State.roundScale,
            smartFps = State.smartFps ~= false,
            sidebarPinned = State.sidebarPinned == true,
            dropdownInline = State.dropdownInline == true,
            bgImg = State.bgImgUrl,
            bgImgA = State.bgImgAlpha,
            bgFx = State.bgEffect,
            bgFxColor = State.bgEffectColor and {State.bgEffectColor.R, State.bgEffectColor.G, State.bgEffectColor.B} or
                nil,
            logo = State.logoSrc,
            icon = State.iconSrc
        }
        return Config
    end
    function UiLib:SaveConfig(Name)
        Name = tostring(Name or State.configName or "default")
        local Json = JsonEncode(SerializeConfig())
        if not Json then
            return self
        end
        EnsureConfigFolder()
        if WriteFile then
            pcall(WriteFile, GetConfigFolder() .. "/" .. Name .. ".json", Json)
        end
        return self
    end
    local function ApplyConfig(Config)
        if not Config then
            return
        end
        State._loadingConfig = true
        if Config.uiFont then
            UiLib:SetFont(Config.uiFont)
        end
        if Config.layout then
            State.tabLayout = Config.layout
        end
        if Config.search then
            State.searchStyle = Config.search
        end
        for _, Tab in ipairs(State.tabs) do
            for _, Entry in ipairs(Tab.sections) do
                for _, Item in ipairs(Entry.items) do
                    if Item.type == "rangeslider" and Item.label and not Item.noSave then
                        local Key = Tab.name .. "." .. Entry.name .. "." .. Item.label
                        local Saved = Config.flags and Config.flags[Key]
                        if type(Saved) == "table" then
                            local Low, High = tonumber(Saved[1]), tonumber(Saved[2])
                            if Low and High then
                                Item.valueLo = SnapToStep(Low, Item)
                                Item.valueHi = SnapToStep(High, Item)
                                if Item.valueLo > Item.valueHi then
                                    Item.valueLo, Item.valueHi = Item.valueHi, Item.valueLo
                                end
                                SafeCall(Item.callback, Item.valueLo, Item.valueHi)
                            end
                        end
                        local Keybind = Config.keybinds and Config.keybinds[Key]
                        if Keybind and Item.keybind then
                            Item.keybind.value = Keybind[1]
                            Item.keybind.mode = NormalizeKeyMode(Keybind[2])
                        end
                    elseif Item.value ~= nil and Item.label and Item.type ~= "button" and not Item.noSave then
                        local Key = Tab.name .. "." .. Entry.name .. "." .. Item.label
                        local Saved = Config.flags and Config.flags[Key]
                        if Saved ~= nil then
                            if Item.type == "colorpicker" and type(Saved) == "table" then
                                Item.value =
                                    NewColor((Saved[1] or 1) * 255, (Saved[2] or 1) * 255, (Saved[3] or 1) * 255)
                                Item.alpha = Saved[4] or 1
                                SafeCall(Item.callback, Item.value, Item.alpha)
                            elseif Item.type == "dropdown" then
                                SetDropdownValue(Item, Saved, true)
                            else
                                SetItemValue(Item, Saved, true)
                            end
                        end
                        local Keybind = Config.keybinds and Config.keybinds[Key]
                        if Keybind and Item.keybind then
                            Item.keybind.value = Keybind[1]
                            Item.keybind.mode = NormalizeKeyMode(Keybind[2])
                        end
                        local SavedColor = Config.colors and Config.colors[Key]
                        if SavedColor and Item.colorpicker then
                            Item.colorpicker.value =
                                NewColor(
                                (SavedColor[1] or 1) * 255,
                                (SavedColor[2] or 1) * 255,
                                (SavedColor[3] or 1) * 255
                            )
                            Item.colorpicker.alpha = SavedColor[4] or 1
                            SafeCall(Item.colorpicker.callback, Item.colorpicker.value, Item.colorpicker.alpha)
                        end
                    end
                end
            end
        end
        local Settings = Config.settings
        if Settings then
            if Settings.accentA and Settings.accentB then
                local Alpha =
                    NewColor(
                    (Settings.accentA[1] or 0) * 255,
                    (Settings.accentA[2] or 0) * 255,
                    (Settings.accentA[3] or 0) * 255
                )
                local Blue =
                    NewColor(
                    (Settings.accentB[1] or 0) * 255,
                    (Settings.accentB[2] or 0) * 255,
                    (Settings.accentB[3] or 0) * 255
                )
                State.baseAccentA = Alpha
                State.baseAccentB = Blue
                if not Settings.rainbow then
                    Theme.accentA = Alpha
                    Theme.accentB = Blue
                end
            end
            if Settings.rainbow ~= nil then
                State.rainbow = Settings.rainbow == true
            end
            if Settings.rainbowSpeed then
                State.rainbowSpeed = Settings.rainbowSpeed
            end
            if Settings.menuOpacity then
                State.menuOpacity = Settings.menuOpacity
            end
            if Settings.noAnim ~= nil then
                State.noAnim = Settings.noAnim == true
            end
            if Settings.notifyDur then
                State.notifyDur = Settings.notifyDur
            end
            if Settings.hoverEffects ~= nil then
                State.hoverEffects = Settings.hoverEffects ~= false
            end
            if Settings.checkboxStyle ~= nil then
                State.checkboxStyle = Settings.checkboxStyle == true
            end
            if Settings.hotkeyEnabled ~= nil then
                State.hotkeyEnabled = Settings.hotkeyEnabled ~= false
            end
            if Settings.menuKey then
                UiLib:SetMenuKey(Settings.menuKey)
            end
            if tonumber(Settings.w) and tonumber(Settings.h) then
                UiLib:SetSize(Settings.w, Settings.h)
            end
            if Settings.bg then
                Theme.bg =
                    NewColor((Settings.bg[1] or 0) * 255, (Settings.bg[2] or 0) * 255, (Settings.bg[3] or 0) * 255)
                Theme.sidebar = Theme.bg
            end
            if Settings.txt then
                Theme.text =
                    NewColor((Settings.txt[1] or 1) * 255, (Settings.txt[2] or 1) * 255, (Settings.txt[3] or 1) * 255)
            end
            if Settings.glowMul then
                State.glowMul = Settings.glowMul
            end
            if Settings.cardStrk then
                Opacity.cardStrk = Settings.cardStrk
            end
            if Settings.hairline then
                Opacity.hairline = Settings.hairline
            end
            if Settings.cardFill then
                Opacity.card = Settings.cardFill
            end
            if Settings.lite ~= nil then
                State.lite = Settings.lite == true
            end
            if Settings.roundScale then
                State.roundScale = Clamp(tonumber(Settings.roundScale) or 1, 0, 2.5)
            end
            if Settings.smartFps ~= nil then
                State.smartFps = Settings.smartFps == true
            end
            if Settings.sidebarPinned ~= nil then
                State.sidebarPinned = Settings.sidebarPinned == true
            end
            if Settings.dropdownInline ~= nil then
                State.dropdownInline = Settings.dropdownInline == true
            end
            if Settings.bgImg then
                UiLib:SetBackgroundImage(Settings.bgImg, Settings.bgImgA)
            elseif not State.bgImg then
                UiLib:SetBackgroundImage(nil)
            end
            UiLib:SetBackgroundEffect(Settings.bgFx)
            if Settings.bgFxColor then
                State.bgEffectColor =
                    NewColor(
                    (Settings.bgFxColor[1] or 1) * 255,
                    (Settings.bgFxColor[2] or 1) * 255,
                    (Settings.bgFxColor[3] or 1) * 255
                )
            end
            if Settings.logo then
                UiLib:SetLogo(Settings.logo)
            end
            if Settings.icon then
                UiLib:SetIcon(Settings.icon)
            end
        end
        if State.settingsTab then
            local SettingStates = {
                ["Performance mode"] = State.lite == true,
                ["Smart FPS"] = State.smartFps ~= false,
                ["Animations"] = State.noAnim ~= true,
                ["Hover effects"] = State.hoverEffects ~= false,
                ["Keybind overlay"] = State.hotkeyEnabled ~= false,
                ["Collapse sidebar"] = not State.sidebarPinned,
                ["Inline dropdowns"] = State.dropdownInline == true,
                ["Rainbow"] = State.rainbow == true,
                ["Checkbox style"] = State.checkboxStyle == true
            }
            for _, Entry in ipairs(State.settingsTab.sections or {}) do
                for _, Target in ipairs(Entry.items or {}) do
                    if Target.type == "checkbox" and SettingStates[Target.label] ~= nil then
                        Target.value = SettingStates[Target.label]
                    end
                end
            end
        end
        State._loadingConfig = nil
    end
    function UiLib:LoadConfig(Name)
        Name = tostring(Name or State.configName or "default")
        State._lastLoadOk = false
        local Path = GetConfigFolder() .. "/" .. Name .. ".json"
        if not (IsFile and IsFile(Path) and ReadFile) then
            return self
        end
        local Value
        pcall(function()
            Value = ReadFile(Path)
        end)
        local Value2 = Value and JsonDecode(Value)
        if type(Value2) ~= "table" then
            return self
        end
        pcall(ApplyConfig, Value2)
        State._loadingConfig = nil
        State._lastLoadOk = true
        return self
    end
    local function AutoloadPath()
        return GetConfigFolder() .. "/_autoload.json"
    end
    local function ReadAutoload()
        local Candidate = AutoloadPath()
        if not (IsFile and IsFile(Candidate) and ReadFile) then
            return {}
        end
        local Value
        pcall(function()
            Value = ReadFile(Candidate)
        end)
        local Kind = Value and JsonDecode(Value)
        return type(Kind) == "table" and Kind or {}
    end
    local function GetAutoload(ConfigName)
        local Kind = ReadAutoload()
        return ConfigName and Kind[tostring(ConfigName)]
    end
    local function SetAutoload(ConfigName, Value)
        if not ConfigName then
            return
        end
        local Kind = ReadAutoload()
        Kind[tostring(ConfigName)] = Value
        EnsureConfigFolder()
        local Json = JsonEncode(Kind)
        if Json and WriteFile then
            pcall(WriteFile, AutoloadPath(), Json)
        end
    end
    local function GetAutoSave(ConfigName)
        local Kind = ReadAutoload()
        local Value = ConfigName and Kind["autosave:" .. tostring(ConfigName)]
        if Value == nil then
            return nil
        end
        return Value == true
    end
    local function SetAutoSave(ConfigName, Enabled)
        if not ConfigName then
            return
        end
        local Kind = ReadAutoload()
        Kind["autosave:" .. tostring(ConfigName)] = Enabled == true
        EnsureConfigFolder()
        local Json = JsonEncode(Kind)
        if Json and WriteFile then
            pcall(WriteFile, AutoloadPath(), Json)
        end
    end
    function UiLib:ExportConfig()
        local Json = JsonEncode(SerializeConfig())
        if not Json or not Base64Encode then
            return nil
        end
        local Success, Encoded = pcall(Base64Encode, Json)
        return Success and Encoded and "INScfg_" .. Encoded or nil
    end
    function UiLib:ImportConfig(Encoded)
        Encoded = tostring(Encoded or "")
        local Blue = string.match(Encoded, "^INScfg_(.+)$") or Encoded
        if not Base64Decode or Blue == "" then
            return self
        end
        local Success, Decoded = pcall(Base64Decode, Blue)
        if Success and type(Decoded) == "string" then
            pcall(ApplyConfig, JsonDecode(Decoded))
            State._loadingConfig = nil
        end
        return self
    end
    function UiLib:ListConfigs()
        local Result = {}
        pcall(function()
            for _, Candidate in ipairs(ListFiles(GetConfigFolder())) do
                local Entry = string.match(Candidate, "([^/\\]+)%.json$")
                if Entry and Entry:sub(1, 1) ~= "_" then
                    Result[#Result + 1] = Entry
                end
            end
        end)
        return Result
    end
    function UiLib:DeleteConfig(Name)
        Name = tostring(Name or "")
        if Name ~= "" and DeleteFile then
            pcall(DeleteFile, GetConfigFolder() .. "/" .. Name .. ".json")
        end
        return self
    end
    function UiLib:SetBackgroundEffect(Name)
        local IsKnown = false
        if Name then
            for _, Edge in ipairs(BackgroundEffects) do
                if Edge == Name then
                    IsKnown = true
                    break
                end
            end
        end
        State.bgEffect = IsKnown and Name ~= "Off" and Name or nil
        return self
    end
    function UiLib:BackgroundEffects()
        return BackgroundEffects
    end
    function UiLib:SetBackgroundEffectColor(Value)
        State.bgEffectColor = Value
        return self
    end
    function State.imgBytes(Url, CachePath)
        local function IsImageData(ValueB)
            if type(ValueB) ~= "string" or #ValueB < 24 then
                return false
            end
            local Alpha, Cache = string.byte(ValueB, 1, 2)
            return Alpha == 0x89 and Cache == 0x50 or Alpha == 0xFF and Cache == 0xD8 or Alpha == 0x47 and Cache == 0x49
        end
        local Blue
        pcall(function()
            if IsFile(Url) then
                Blue = ReadFile(Url)
            end
        end)
        if IsImageData(Blue) then
            return Blue
        end
        local Height = 5381
        for Index = 1, #Url do
            Height = (Height * 33 + string.byte(Url, Index)) % 2147483648
        end
        local CacheName = "RyzenUI_img_" .. string.format("%08x", Height) .. ".dat"
        Blue = nil
        pcall(function()
            if IsFile(CacheName) then
                Blue = ReadFile(CacheName)
            end
        end)
        if IsImageData(Blue) then
            return Blue
        end
        if CachePath then
            Blue = nil
            pcall(function()
                if IsFile(CachePath) then
                    Blue = ReadFile(CachePath)
                end
            end)
            if IsImageData(Blue) then
                pcall(function()
                    WriteFile(CacheName, Blue)
                end)
                return Blue
            end
        end
        Blue = nil
        pcall(function()
            Blue = game:HttpGet(Url)
        end)
        if IsImageData(Blue) then
            pcall(function()
                WriteFile(CacheName, Blue)
            end)
            return Blue
        end
        return nil
    end
    function UiLib:SetBackgroundImage(Url, Alpha, WidthFraction, HeightFraction)
        State.bgImgAlpha = Alpha or State.bgImgAlpha or 0.5
        State.bgImgWFrac = tonumber(WidthFraction)
        State.bgImgHFrac = tonumber(HeightFraction)
        if State.bgImg then
            pcall(function()
                State.bgImg.Visible = false
                State.bgImg:Remove()
            end)
            State.bgImg = nil
        end
        if Url ~= nil and Url ~= "" then
            local Value = tostring(Url)
            local B, C = string.byte(Value, 1, 2)
            if #Value > 24 and (B == 0x89 and C == 0x50 or B == 0xFF and C == 0xD8) then
                State.bgImgUrl = nil
                pcall(function()
                    local Image = Drawing.new("Image")
                    Image.Data = Value
                    Image.Visible = false
                    State.bgImg = Image
                end)
                return self
            end
        end
        State.bgImgUrl = Url ~= nil and Url ~= "" and tostring(Url) or nil
        local BgImgUrl = State.bgImgUrl
        if not BgImgUrl then
            return self
        end
        task.spawn(function()
            pcall(function()
                local Blue = State.imgBytes(BgImgUrl, "RyzenUI_bg_" .. tostring(#BgImgUrl) .. ".dat")
                if Blue and #Blue > 12 then
                    local Byte1, Byte2 = string.byte(Blue, 1, 2)
                    if Byte1 == 0x89 and Byte2 == 0x50 or Byte1 == 0xFF and Byte2 == 0xD8 then
                        if State.bgImgUrl == BgImgUrl then
                            local Image = Drawing.new("Image")
                            Image.Data = Blue
                            State.bgImg = Image
                        end
                    end
                end
            end)
        end)
        return self
    end
    function UiLib:SetLogo(Value)
        if State.logoImg then
            pcall(function()
                State.logoImg.Visible = false
                State.logoImg:Remove()
            end)
            State.logoImg = nil
        end
        if Value == nil or Value == "" then
            State.logoSrc = nil
            return self
        end
        local Url = tostring(Value)
        local Byte1, Byte2 = string.byte(Url, 1, 2)
        if #Url > 24 and (Byte1 == 0x89 and Byte2 == 0x50 or Byte1 == 0xFF and Byte2 == 0xD8) then
            State.logoSrc = nil
            pcall(function()
                local Image = Drawing.new("Image")
                Image.Data = Url
                Image.Visible = false
                State.logoImg = Image
            end)
            return self
        end
        State.logoSrc = Url
        task.spawn(function()
            pcall(function()
                local Blue = State.imgBytes(Url, "RyzenUI_logo_" .. tostring(#Url) .. ".dat")
                if Blue and #Blue > 12 then
                    local Byte12, BitB = string.byte(Blue, 1, 2)
                    if Byte12 == 0x89 and BitB == 0x50 or Byte12 == 0xFF and BitB == 0xD8 then
                        if State.logoSrc == Url then
                            local Image = Drawing.new("Image")
                            Image.Data = Blue
                            Image.Visible = false
                            State.logoImg = Image
                        end
                    end
                end
            end)
        end)
        return self
    end
    function UiLib:SetIcon(Value)
        if State.iconImg then
            pcall(function()
                State.iconImg.Visible = false
                State.iconImg:Remove()
            end)
            State.iconImg = nil
        end
        if Value == nil or Value == "" then
            State.iconSrc = nil
            return self
        end
        local Url = tostring(Value)
        local Byte1, Byte2 = string.byte(Url, 1, 2)
        if #Url > 24 and (Byte1 == 0x89 and Byte2 == 0x50 or Byte1 == 0xFF and Byte2 == 0xD8) then
            State.iconSrc = nil
            pcall(function()
                local Image = Drawing.new("Image")
                Image.Data = Url
                Image.Visible = false
                State.iconImg = Image
            end)
            return self
        end
        State.iconSrc = Url
        task.spawn(function()
            pcall(function()
                local Blue = State.imgBytes(Url, "RyzenUI_icon_" .. tostring(#Url) .. ".dat")
                if Blue and #Blue > 12 then
                    local Byte12, BitB = string.byte(Blue, 1, 2)
                    if Byte12 == 0x89 and BitB == 0x50 or Byte12 == 0xFF and BitB == 0xD8 then
                        if State.iconSrc == Url then
                            local Image = Drawing.new("Image")
                            Image.Data = Blue
                            Image.Visible = false
                            State.iconImg = Image
                        end
                    end
                end
            end)
        end)
        return self
    end
    local WaifuImageUrl = "https://raw.githubusercontent.com/nvqren/Matcha-Waifu/refs/heads/main/waifu.png"
    local function ApplyThemeBackground(Name)
        if Name == "Waifu" then
            Theme.bg = NewColor(15, 19, 13)
            Theme.sidebar = Theme.bg
            UiLib:SetBackgroundImage(WaifuImageUrl, 0.12)
        elseif Name == "NeverBlox" then
            Theme.bg = NewColor(15, 16, 21)
            Theme.sidebar = NewColor(12, 13, 17)
            UiLib:SetBackgroundImage(nil)
        elseif Name == "Lemon" then
            Theme.bg = NewColor(18, 17, 13)
            Theme.sidebar = NewColor(18, 17, 13)
            UiLib:SetBackgroundImage(nil)
        else
            Theme.bg = NewColor(15, 15, 15)
            Theme.sidebar = Theme.bg
            UiLib:SetBackgroundImage(nil)
        end
    end
    function UiLib:ApplyThemePreset(Name)
        local Position = ThemePresets[Name]
        if Position then
            Theme.accentA = Position[1]
            Theme.accentB = Position[2]
            ApplyThemeBackground(Name)
        end
        return self
    end
    function UiLib:ThemePresets()
        local Result = {}
        for Key in pairs(ThemePresets) do
            Result[#Result + 1] = Key
        end
        table.sort(Result)
        return Result
    end
    function UiLib:FontChoices()
        local Result = {}
        for _, Entry in ipairs(FontChoices) do
            Result[#Result + 1] = Entry[1]
        end
        return Result
    end
    function UiLib:SetFont(Name)
        if type(Name) ~= "string" then
            for _, Entry in ipairs(FontChoices) do
                if Entry[2] == Name then
                    Name = Entry[1]
                    break
                end
            end
        end
        State.uiFont = ResolveFont(Name)
        State.uiFontName = type(Name) == "string" and Name or "Default"
        return self
    end
    function UiLib:SetLayout(Mode)
        State.tabLayout = (Mode == "Top" or Mode == "top") and "top" or "side"
        return self
    end
    local function Cleanup()
        if State.destroyed then
            return
        end
        State.destroyed = true
        State.open = false
        State.dropdown = nil
        State.colorpicker = nil
        State.focus = nil
        pcall(SetRobloxInput, true)
        State.inputState = true
        RemoveAllDrawings()
        for _, Kind in ipairs(State.tabs) do
            if Kind._img then
                pcall(function()
                    Kind._img:Remove()
                end)
                Kind._img = nil
            end
            for _, Entry in ipairs(Kind.sections) do
                for _, Target in ipairs(Entry.items) do
                    if Target._img then
                        pcall(function()
                            Target._img:Remove()
                        end)
                        Target._img = nil
                    end
                end
            end
        end
        if State._gearImg then
            pcall(function()
                State._gearImg:Remove()
            end)
            State._gearImg = nil
        end
        if State.bgImg then
            pcall(function()
                State.bgImg:Remove()
            end)
            State.bgImg = nil
        end
        if State.avatarImg then
            pcall(function()
                State.avatarImg:Remove()
            end)
            State.avatarImg = nil
        end
        if State.logoImg then
            pcall(function()
                State.logoImg:Remove()
            end)
            State.logoImg = nil
        end
        if State.iconImg then
            pcall(function()
                State.iconImg:Remove()
            end)
            State.iconImg = nil
        end
    end
    function UiLib:Destroy()
        State.alive = false
        State.open = false
        if not State.rendering then
            Cleanup()
        end
    end
    UiLib.Unload = UiLib.Destroy
    local function IsCapturingInput()
        if State.kbCapture or State.spotlightOpen then
            return true
        end
        if State.colorpicker and State.colorpicker.hexInput then
            return true
        end
        for _, Target in ipairs(KeybindItems) do
            if Target.keybind and Target.keybind.listening then
                return true
            end
        end
        return false
    end
    local function UpdateRainbow()
        if not State.rainbow then
            return
        end
        local Kind = (Clock() or 0) * (State.rainbowSpeed or 0.3) * 0.3
        Theme.accentA = ColorFromHsv(Kind % 1, 0.65, 1)
        Theme.accentB = ColorFromHsv((Kind + 0.12) % 1, 0.72, 1)
    end
    local function DrawDialog(Clicked)
        local Dialog = State.dialog
        State._dlgA = Approach(State._dlgA or 0, Dialog and 1 or 0, 18)
        local DlgA = State._dlgA
        if DlgA < 0.01 then
            return Clicked
        end
        local ViewportWidth, ViewportHeight = GetViewportSize()
        FillRect(0, 0, ViewportWidth, ViewportHeight, NewColor(0, 0, 0), 450, 0, 0.5 * DlgA)
        if not Dialog then
            return Clicked
        end
        local DialogWidth = 344
        local Lines = WrapText(Dialog.text or "", DialogWidth - 44, 13, FontSystem)
        if #Lines == 0 then
            Lines = {""}
        end
        local PickerHeight = 92 + #Lines * 18
        local DeltaX = MathFloor(ViewportWidth / 2 - DialogWidth / 2)
        local DeltaY = MathFloor(ViewportHeight / 2 - PickerHeight / 2) - MathFloor((1 - DlgA) * 12)
        local AccentMid = State._accentMid
        FillRect(DeltaX + 3, DeltaY + 6, DialogWidth, PickerHeight, NewColor(0, 0, 0), 451, 12, 0.3 * DlgA)
        FillRect(DeltaX, DeltaY, DialogWidth, PickerHeight, Theme.bg, 452, 12, 0.99 * DlgA)
        StrokeRect(DeltaX - 1, DeltaY - 1, DialogWidth + 2, PickerHeight + 2, AccentMid, 453, 13, 0.10 * DlgA)
        StrokeRect(DeltaX, DeltaY, DialogWidth, PickerHeight, White, 453, 12, 0.22 * DlgA)
        DrawText(
            Dialog.title,
            DeltaX + 22,
            DeltaY + 18,
            AccentMid,
            16,
            FontBold,
            454,
            false,
            false,
            DialogWidth - 44,
            DlgA
        )
        for Index = 1, #Lines do
            DrawText(
                Lines[Index],
                DeltaX + 22,
                DeltaY + 48 + (Index - 1) * 18,
                White,
                13,
                FontSystem,
                454,
                false,
                false,
                DialogWidth - 44,
                Opacity.label * DlgA
            )
        end
        local ButtonHeight, Gap = 30, 10
        local RestY = DeltaY + PickerHeight - ButtonHeight - 16
        local ButtonWidth = (DialogWidth - 44 - Gap) / 2
        local CancelX = DeltaX + 22
        local ConfirmX = CancelX + ButtonWidth + Gap
        local CancelHovered = IsMouseInside(CancelX, RestY, ButtonWidth, ButtonHeight)
        local ConfirmHovered = IsMouseInside(ConfirmX, RestY, ButtonWidth, ButtonHeight)
        StrokeRect(
            CancelX,
            RestY,
            ButtonWidth,
            ButtonHeight,
            White,
            454,
            6,
            (CancelHovered and 0.4 or Opacity.hairline) * DlgA
        )
        DrawCenteredText(
            Dialog.cancel,
            CancelX + ButtonWidth / 2,
            RestY + ButtonHeight / 2,
            White,
            13,
            FontBold,
            455,
            (CancelHovered and Opacity.text or Opacity.dim) * DlgA
        )
        FillRect(ConfirmX, RestY, ButtonWidth, ButtonHeight, AccentMid, 454, 6, (ConfirmHovered and 0.32 or 0.2) * DlgA)
        StrokeRect(
            ConfirmX,
            RestY,
            ButtonWidth,
            ButtonHeight,
            AccentMid,
            455,
            6,
            (ConfirmHovered and 0.95 or 0.6) * DlgA
        )
        DrawCenteredText(
            Dialog.confirm,
            ConfirmX + ButtonWidth / 2,
            RestY + ButtonHeight / 2,
            AccentMid,
            13,
            FontBold,
            455,
            DlgA
        )
        if DlgA > 0.5 then
            if Keys.esc.click then
                State.dialog = nil
                if Dialog.onCancel then
                    pcall(Dialog.onCancel)
                end
                Keys.esc.click = false
                return false
            end
            if Clicked then
                if IsMouseInside(ConfirmX, RestY, ButtonWidth, ButtonHeight) then
                    State.dialog = nil
                    if Dialog.onConfirm then
                        pcall(Dialog.onConfirm)
                    end
                    return false
                end
                if
                    IsMouseInside(CancelX, RestY, ButtonWidth, ButtonHeight) or
                        not IsMouseInside(DeltaX, DeltaY, DialogWidth, PickerHeight)
                 then
                    State.dialog = nil
                    if Dialog.onCancel then
                        pcall(Dialog.onCancel)
                    end
                    return false
                end
            end
        end
        return false
    end
    local function RenderFrame()
        ResetDrawPools()
        State.tooltipText = nil
        State._vpW = nil
        local Now = Clock() or 0
        State.dt = Clamp(Now - State.lastFrame, 0, 0.05)
        State.lastFrame = Now
        UpdateMouse()
        PollInput()
        State.drawVisible = Approach(State.drawVisible, State.open and 1 or 0, 12)
        if State.drawVisible > 0.997 then
            State.drawVisible = 1
        elseif State.drawVisible < 0.003 then
            State.drawVisible = 0
        end
        if (Keys.lctrl.held or Keys.rctrl.held or Keys.ctrl.held) and Keys.space.click then
            State.spotlightOpen = not State.spotlightOpen
            if State.spotlightOpen then
                State.spotlight = {query = "", sel = 1}
                State.focus = nil
            end
            Keys.space.click = false
        end
        local MenuKeyState = Keys[MenuKey]
        if MenuKeyState and MenuKeyState.click and not State.focus and not IsCapturingInput() then
            if State.minimized then
                State.minimized = false
                if State.minPos then
                    State.x = State.minPos.x
                    State.y = State.minPos.y
                    ClampWindowToScreen()
                end
                SetOpen(true)
            else
                SetOpen(not State.open)
            end
        end
        ProcessFocusedInput()
        if not State.spotlightOpen then
            ProcessKeybinds()
        end
        State._captureKeybind()
        UpdateRainbow()
        State._accentMid = LerpColor(Theme.accentA, Theme.accentB, 0.5)
        if State._rebuildIcons then
            local AccentMid = State._accentMid
            local AccentKey =
                MathFloor(MathFloor(AccentMid.R * 255 + 0.5) / 8) * 65536 +
                MathFloor(MathFloor(AccentMid.G * 255 + 0.5) / 8) * 256 +
                MathFloor(MathFloor(AccentMid.B * 255 + 0.5) / 8)
            local TabSignature = #(State.tabs or {})
            for _, Kind in ipairs(State.tabs or {}) do
                if Kind.subs then
                    TabSignature = TabSignature + #Kind.subs * 97
                end
            end
            if State.settingsTab then
                TabSignature = TabSignature + 991
            end
            local SignatureChanged = State._iconSig ~= TabSignature
            if SignatureChanged or State._iconAccentKey ~= AccentKey then
                local Now2 = Clock() or 0
                if SignatureChanged or not State._iconGenT or Now2 - State._iconGenT >= 0.13 then
                    State._iconAccentKey = AccentKey
                    State._iconSig = TabSignature
                    State._iconGenT = Now2
                    State._rebuildIcons()
                end
            end
        end
        if
            State.open and not State.spotlightOpen and not State.focus and not State.dropdown and not State.colorpicker and
                #State.tabs > 0
         then
            if Keys.left.click then
                local ActiveIndex = State.activeIndex
                repeat
                    ActiveIndex = ActiveIndex - 1
                until ActiveIndex < 1 or not State.tabs[ActiveIndex].hidden
                if ActiveIndex >= 1 then
                    State.activeIndex = ActiveIndex
                    State.activeTab = State.tabs[ActiveIndex]
                    State.contentFade = 0
                end
            end
            if Keys.right.click then
                local ActiveIndex = State.activeIndex
                repeat
                    ActiveIndex = ActiveIndex + 1
                until ActiveIndex > #State.tabs or not State.tabs[ActiveIndex].hidden
                if ActiveIndex <= #State.tabs then
                    State.activeIndex = ActiveIndex
                    State.activeTab = State.tabs[ActiveIndex]
                    State.contentFade = 0
                end
            end
        end
        if Keys.m1.released then
            State.drag = nil
            State.resizeEdge = nil
            State.sliderDrag = nil
            State.scrollDrag = nil
            State.cpDrag = nil
            State.hkDrag = nil
            State.contentDrag = nil
            State.textDrag = nil
            State.spTextDrag = nil
            if State.dropdown then
                State.dropdown._sbDrag = nil
            end
            if State.spotlight then
                State.spotlight._sbDrag = nil
            end
        end
        local Click, Held, Click2 = Keys.m1.click, Keys.m1.held, Keys.m2.click
        if State.drawVisible < 0.01 and not State.open then
            HideImages()
            Click = DrawBoxes(Click, Held)
            Click = DrawKeybindOverlay(Click, Held)
            Click = DrawSpotlight(Click)
            DrawNotifications()
            DrawDialog(Click)
            HideUnusedDrawings()
            return
        end
        ClampWindowToScreen()
        local SpotlightOpen = State.spotlightOpen
        local ClickedRaw = Click
        local ClickedForDialog = Click
        if SpotlightOpen then
            Click = false
            Click2 = false
            Held = false
        end
        if State.dialog then
            Click = false
            Click2 = false
            Held = false
        end
        Click = DrawKeybindOverlay(Click, Held)
        Click = DrawBoxes(Click, Held)
        if (State.minA or 0) < 0.06 then
            Click, Held, Click2 = DrawWindow(Click, Held, Click2)
            Click, Click2 = DrawDropdown(Click, Click2)
            Click = DrawColorpicker(Click, Held)
            Click = DrawKeybindMenu(Click)
            DrawTooltip()
            State.lastTooltipText = State.tooltipText
            if Click and State.focus then
                State.focus = nil
            end
        else
            HideImages()
        end
        UpdateInputBlock(false)
        Click = DrawMinimized(Click, Held)
        local MinimizeFade = State.minA or 0
        if MinimizeFade > 0.06 and MinimizeFade < 0.9 then
            Click = false
        end
        Click = DrawSpotlight(SpotlightOpen and ClickedRaw or false)
        DrawNotifications()
        DrawDialog(ClickedForDialog)
        if not State.lite and (State.minA or 0) < 0.06 then
            local WinRect = State._winRect
            if WinRect then
                DrawBackgroundEffect(WinRect.x, WinRect.y, WinRect.w, WinRect.h, WinRect.th, WinRect.v)
            end
        end
        HideUnusedDrawings()
    end
    local function FrameStep()
        if GetGlobal(RegistryName .. "InstanceId") ~= InstanceToken then
            State.alive = false
        end
        if not State.alive then
            Cleanup()
            return
        end
        State.rendering = true
        local Success, ErrorMessage = pcall(RenderFrame)
        State.rendering = false
        if not Success then
            UiLib:Notify("error", tostring(ErrorMessage), 6)
            State.errorCount = State.errorCount + 1
            pcall(SetRobloxInput, true)
            State.inputState = true
            HideAllDrawings()
            if State.errorCount >= 3 then
                State.alive = false
                Cleanup()
            end
        else
            State.errorCount = 0
        end
    end
    local function GetFrameDelay()
        local Total = State.lite and 1 / 60 or 1 / 144
        if State.smartFps == false then
            return Total
        end
        local MouseX, MouseY = State.mouseX or 0, State.mouseY or 0
        local MouseMoved = MouseX ~= (State._lastMX or -1) or MouseY ~= (State._lastMY or -1)
        State._lastMX, State._lastMY = MouseX, MouseY
        if
            MouseMoved or Keys.m1 and Keys.m1.held or Keys.m2 and Keys.m2.held or State.drag or State.resizeEdge or
                State.scrollDrag or
                State.dropdown or
                State.colorpicker or
                State.focus or
                State.kbCapture or
                State.spotlightOpen
         then
            State._lastAct = Clock() or 0
        end
        local DrawVisible, MinimizeFade, ContentFade = State.drawVisible or 0, State.minA or 0, State.contentFade or 1
        local Animating =
            DrawVisible > 0.01 and DrawVisible < 0.99 or MinimizeFade > 0.01 and MinimizeFade < 0.99 or
            ContentFade < 0.99 or
            State.rainbow and State.open
        if Animating then
            return Total
        end
        if State.open and (Clock() or 0) - (State._lastAct or 0) < 0.5 then
            return Total
        end
        return 1 / 30
    end
    task.spawn(function()
        while State.alive do
            if
                State._winReady and not State._didAutoload and
                    GetGlobal(RegistryName .. "InstanceId") == InstanceToken
             then
                local ItemTotal = 0
                for _, Kind in ipairs(State.tabs) do
                    for _, EaseClamped in ipairs(Kind.sections) do
                        ItemTotal = ItemTotal + #EaseClamped.items
                    end
                end
                local BubbleReady = ItemTotal > 0 and ItemTotal == State._setupCount
                State._setupCount = ItemTotal
                State._setupFrames = (State._setupFrames or 0) + 1
                if BubbleReady or State._setupFrames > 40 then
                    State._didAutoload = true
                    local AutoSaveSetting = GetAutoSave(State._baseConfigName)
                    if AutoSaveSetting ~= nil then
                        State.autoSave = AutoSaveSetting
                    end
                    local Autoload = GetAutoload(State._baseConfigName)
                    if Autoload then
                        State.configName = Autoload
                        pcall(function()
                            UiLib:LoadConfig(State.configName)
                        end)
                        if State._lastLoadOk then
                            pcall(function()
                                UiLib:Notify("config", "auto-loaded: " .. tostring(Autoload), 4, "info")
                            end)
                        end
                    end
                    pcall(function()
                        State._lastCfgEnc = JsonEncode(SerializeConfig())
                    end)
                end
            end
            FrameStep()
            if
                State.alive and State._didAutoload and State.autoSave and
                    (Clock() or 0) - (State._autoSaveT or 0) > 1.2
             then
                State._autoSaveT = Clock() or 0
                pcall(function()
                    local Json = JsonEncode(SerializeConfig())
                    if Json and Json ~= State._lastCfgEnc then
                        local Position =
                            GetConfigFolder() .. "/" .. tostring(State.configName or "default") .. ".json"
                        if
                            WriteFile and
                                (State.configName == State._baseConfigName or IsFile and IsFile(Position))
                         then
                            EnsureConfigFolder()
                            WriteFile(Position, Json)
                            State._lastCfgEnc = Json
                        end
                    end
                end)
            end
            if State.alive then
                task.wait(GetFrameDelay())
            end
        end
        Cleanup()
    end)
    local function BuildSettingsTab(Window, Icon)
        local Tab = Window:Tab("Settings", Icon or "cog")
        Tab._tab.hidden = true
        if State.activeTab == Tab._tab then
            State.activeTab = nil
        end
        State.settingsTab = Tab._tab
        State.settingsIcon = Icon or "cog"
        State.settingsIndex = #State.tabs
        local LineThickness = Tab:Section("Theme", "Left")
        State.baseAccentA = State.baseAccentA or Theme.accentA
        State.baseAccentB = State.baseAccentB or Theme.accentB
        if not State.defaultTheme then
            State.defaultTheme = {
                accentA = Theme.accentA,
                accentB = Theme.accentB,
                bg = Theme.bg,
                text = Theme.text,
                sidebar = Theme.sidebar
            }
        end
        local PresetNames = {"Default"}
        for _, Index in ipairs(UiLib:ThemePresets()) do
            PresetNames[#PresetNames + 1] = Index
        end
        local PresetDropdown, ColorPicker1, ColorPicker2
        local function SetBaseAccent(ValueA, ValueB)
            State.baseAccentA = ValueA
            State.baseAccentB = ValueB
            if not State.rainbow then
                Theme.accentA = ValueA
                Theme.accentB = ValueB
            end
        end
        PresetDropdown =
            LineThickness:Dropdown(
            "Preset",
            {"Default"},
            PresetNames,
            false,
            function(Value)
                local Name = Value[1]
                if Name == "Default" then
                    local DefaultTheme = State.defaultTheme
                    SetBaseAccent(DefaultTheme.accentA, DefaultTheme.accentB)
                    Theme.bg = DefaultTheme.bg
                    Theme.text = DefaultTheme.text
                    Theme.sidebar = DefaultTheme.sidebar
                    if ColorPicker1 then
                        ColorPicker1.item.value = DefaultTheme.accentA
                    end
                    if ColorPicker2 then
                        ColorPicker2.item.value = DefaultTheme.accentB
                    end
                elseif Name and Name ~= "Custom" then
                    local Position = ThemePresets[Name]
                    if Position then
                        SetBaseAccent(Position[1], Position[2])
                        ApplyThemeBackground(Name)
                        if ColorPicker1 then
                            ColorPicker1.item.value = Position[1]
                        end
                        if ColorPicker2 then
                            ColorPicker2.item.value = Position[2]
                        end
                    end
                end
            end,
            "Default = the look this script ships with; pick a preset, or a colour below for Custom",
            true
        )
        ColorPicker1 =
            LineThickness:Colorpicker(
            "Color 1",
            Theme.accentA,
            function(Value)
                SetBaseAccent(Value, State.baseAccentB)
                if PresetDropdown and not State._loadingConfig then
                    PresetDropdown:Set({"Custom"})
                end
            end
        )
        ColorPicker2 =
            LineThickness:Colorpicker(
            "Color 2",
            Theme.accentB,
            function(Value)
                SetBaseAccent(State.baseAccentA, Value)
                if PresetDropdown and not State._loadingConfig then
                    PresetDropdown:Set({"Custom"})
                end
            end
        )
        State._c1pick = ColorPicker1
        State._c2pick = ColorPicker2
        LineThickness:Toggle(
            "Rainbow",
            State.rainbow == true,
            function(Enabled)
                if Enabled then
                    State.baseAccentA = State.baseAccentA or Theme.accentA
                    State.baseAccentB = State.baseAccentB or Theme.accentB
                else
                    Theme.accentA = State.baseAccentA or Theme.accentA
                    Theme.accentB = State.baseAccentB or Theme.accentB
                end
                State.rainbow = Enabled
            end
        )
        LineThickness:Slider(
            "Rainbow speed",
            30,
            1,
            5,
            200,
            "%",
            function(Value)
                State.rainbowSpeed = Value / 100
            end
        )
        local AppearanceSection = Tab:Section("Appearance", "Left")
        AppearanceSection:Colorpicker(
            "Background",
            Theme.bg,
            function(Value)
                Theme.bg = Value
                Theme.sidebar = Value
            end,
            1
        )
        AppearanceSection:Colorpicker(
            "Text color",
            Theme.text,
            function(Value)
                Theme.text = Value
            end,
            1
        )
        AppearanceSection:Slider(
            "Card glow",
            100,
            5,
            0,
            200,
            "%",
            function(Value)
                State.glowMul = Value / 100
            end,
            "strength of the accent glow when you hover a section card"
        )
        AppearanceSection:Dropdown(
            "Background FX",
            {State.bgEffect or "Off"},
            BackgroundEffects,
            false,
            function(Value)
                State.bgEffect = Value[1] and Value[1] ~= "Off" and Value[1] or nil
            end,
            "decorative particles behind the menu (off by default)"
        )
        AppearanceSection:Colorpicker(
            "FX colour",
            NewColor(255, 255, 255),
            function(Value)
                State.bgEffectColor = Value
            end,
            1
        ):Tooltip("recolour the background particles; untouched = each effect's own colour")
        AppearanceSection:Slider(
            "Border",
            6,
            1,
            0,
            30,
            "",
            function(Value)
                Opacity.cardStrk = Value / 100
                Opacity.hairline = Value / 100 * 1.6
            end,
            "how visible the card / control outlines are"
        )
        AppearanceSection:Slider(
            "Frost",
            3,
            1,
            0,
            12,
            "",
            function(Value)
                Opacity.card = Value / 100
            end,
            "how milky the card fills are"
        )
        AppearanceSection:Slider(
            "Corner radius",
            MathFloor((State.roundScale or 1) * 100 + 0.5),
            5,
            0,
            250,
            "%",
            function(Value)
                State.roundScale = Clamp((tonumber(Value) or 100) / 100, 0, 2.5)
            end,
            "roundness of every corner; 100% = default, 0% = sharp"
        )
        AppearanceSection:Toggle(
            "Performance mode",
            State.lite == true,
            function(Enabled)
                State.lite = Enabled
            end,
            "lite rendering for weak PCs: 60fps, no shadow / outer glow / animations, sidebar stays open"
        )
        AppearanceSection:Toggle(
            "Smart FPS",
            State.smartFps ~= false,
            function(Enabled)
                State.smartFps = Enabled
            end,
            "drop to ~30fps when idle / minimized / closed and jump to full speed on activity, frees the CPU for the game"
        )
        local Value = Tab:Section("Interface", "Right")
        Value:Keybind(
            "Menu key",
            MenuKey,
            function(Key)
                UiLib:SetMenuKey(Key)
                UiLib:Notify("menu key", "set to " .. string.upper(Key), 2)
            end,
            "the key that opens / closes this menu"
        )
        Value:Toggle(
            "Keybind overlay",
            State.hotkeyEnabled ~= false,
            function(Enabled)
                State.hotkeyEnabled = Enabled
            end
        )
        Value:Toggle(
            "Hover effects",
            State.hoverEffects ~= false,
            function(Enabled)
                State.hoverEffects = Enabled
            end
        )
        Value:Toggle(
            "Checkbox style",
            State.checkboxStyle == true,
            function(Enabled)
                State.checkboxStyle = Enabled
            end,
            "Draw every toggle as a filling checkbox instead of a switch"
        )
        Value:Toggle(
            "Collapse sidebar",
            not State.sidebarPinned,
            function(Enabled)
                State.sidebarPinned = not Enabled
            end,
            "on = the sidebar shrinks to an icon rail and expands on hover; off = it always stays open"
        )
        Value:Toggle(
            "Inline dropdowns",
            State.dropdownInline == true,
            function(Enabled)
                State.dropdownInline = Enabled
            end,
            "put the dropdown box on the same row as its label instead of below it"
        )
        Value:Dropdown(
            "Tab layout",
            {State.tabLayout == "top" and "Top" or "Sidebar"},
            {"Sidebar", "Top"},
            false,
            function(Value2)
                if Value2[1] then
                    UiLib:SetLayout(Value2[1] == "Top" and "top" or "side")
                end
            end,
            "tabs on the left rail or across the top"
        )
        local Value2 = State.searchStyle or "bar"
        Value:Dropdown(
            "Search",
            {Value2:sub(1, 1):upper() .. Value2:sub(2)},
            {"Bar", "Icon", "Off"},
            false,
            function(Value3)
                if Value3[1] then
                    State.searchStyle = string.lower(Value3[1])
                end
            end,
            "titlebar search: a bar, just an icon, or hidden (Ctrl+Space always works)"
        )
        Value:Dropdown(
            "Font",
            {State.uiFontName or "Default"},
            UiLib:FontChoices(),
            false,
            function(Value3)
                if Value3[1] then
                    UiLib:SetFont(Value3[1])
                    UiLib:Notify("ui", "font: " .. Value3[1], 2)
                end
            end,
            "UI font, Matcha built-ins only (custom web fonts can't be loaded into Drawing)",
            true
        )
        Value:Slider(
            "Menu opacity",
            98,
            1,
            40,
            100,
            "%",
            function(Value3)
                State.menuOpacity = Value3 / 100
            end
        )
        Value:Toggle(
            "Animations",
            State.noAnim ~= true,
            function(Enabled)
                State.noAnim = not Enabled
            end
        )
        Value:Slider(
            "Notify time",
            5,
            1,
            1,
            15,
            "s",
            function(Value3)
                State.notifyDur = Value3
            end
        )
        local ConfigSection = Tab:Section("Configs", "Right")
        local Value3 =
            ConfigSection:Textbox(
            "Name",
            State.configName or "default",
            function(Data)
                State.configName = Data ~= "" and Data or "default"
            end
        )
        Value3.item.noSave = true
        local Value4, Value5
        local function Helper()
            local Cache = {"Off"}
            for _, Index in ipairs(UiLib:ListConfigs()) do
                Cache[#Cache + 1] = Index
            end
            return Cache
        end
        local function Helper2()
            if Value4 then
                Value4:UpdateChoices(UiLib:ListConfigs())
            end
            if Value5 then
                Value5:UpdateChoices(Helper())
            end
        end
        ConfigSection:Button(
            "Save",
            function()
                UiLib:SaveConfig(State.configName)
                Helper2()
                UiLib:Notify("config", "saved: " .. tostring(State.configName), 4, "success")
            end
        ):AddButton(
            "Load",
            function()
                local ConfigName = State.configName
                local Success = false
                for _, Entry in ipairs(UiLib:ListConfigs()) do
                    if Entry == ConfigName then
                        Success = true
                        break
                    end
                end
                if Success then
                    UiLib:LoadConfig(ConfigName)
                    UiLib:Notify("config", "loaded: " .. tostring(ConfigName), 3)
                else
                    UiLib:Notify("config", "no config named " .. tostring(ConfigName), 3, "warning")
                end
            end
        ):AddButton(
            "Delete",
            function()
                UiLib:DeleteConfig(State.configName)
                if Value4 then
                    Value4:Set({})
                end
                Helper2()
                UiLib:Notify("config", "deleted", 3, "warning")
            end
        )
        Value4 =
            ConfigSection:Dropdown(
            "Config",
            {},
            UiLib:ListConfigs(),
            false,
            function(Value6)
                if Value6[1] then
                    State.configName = Value6[1]
                    Value3:Set(Value6[1])
                end
            end,
            "pick a saved config, then Load or Delete it",
            true
        )
        Value4.item.noSave = true
        local AutoSaveSetting = GetAutoSave(State._baseConfigName)
        if AutoSaveSetting ~= nil then
            State.autoSave = AutoSaveSetting
        end
        local Value6 =
            ConfigSection:Toggle(
            "Auto-save",
            State.autoSave == true,
            function(Enabled)
                UiLib:SetAutoSave(Enabled)
                SetAutoSave(State._baseConfigName, Enabled)
                UiLib:Notify("config", Enabled and "auto-save on" or "auto-save off", 2)
            end,
            "save changes to the current config automatically as you change things; off = nothing is written until you press Save"
        )
        Value6.item.noSave = true
        Value5 =
            ConfigSection:Dropdown(
            "Auto-load",
            {GetAutoload(State._baseConfigName) or "Off"},
            Helper(),
            false,
            function(Value7)
                local Selected = Value7[1]
                if Selected and Selected ~= "Off" then
                    SetAutoload(State._baseConfigName, Selected)
                    UiLib:Notify("config", "auto-load: " .. Selected, 3)
                else
                    SetAutoload(State._baseConfigName, nil)
                    UiLib:Notify("config", "auto-load off", 2)
                end
            end,
            "load a config every launch (Off = none); separate from Auto-save",
            true
        )
        Value5.item.noSave = true
        local Value7 = Tab:Section("System", "Right")
        Value7:Button(
            "Re-center window",
            function()
                UiLib:Center()
                UiLib:Notify("ui", "re-centered", 2)
            end
        )
        Value7:Button(
            "Minimize",
            function()
                State.minimized = not State.minimized
                if State.minimized then
                    State.minPos = {x = State.x + 6, y = State.y + 4}
                    State.dropdown = nil
                    State.colorpicker = nil
                    State.keyMenu = nil
                    State.focus = nil
                end
            end
        )
        return Tab
    end
    local function StripSymbols(Text)
        Text = tostring(Text or "")
        if Text == "" then
            return Text
        end
        local Success, Result =
            pcall(
            function()
                local Value = {}
                for _, Picker in utf8.codes(Text) do
                    if Picker < 0x2190 and not (Picker >= 0x200B and Picker <= 0x200F) then
                        Value[#Value + 1] = utf8.char(Picker)
                    end
                end
                return table.concat(Value)
            end
        )
        if not Success then
            Result = Text:gsub("[\240-\244][\128-\191]*", "")
        end
        return Result:gsub("%s+$", ""):gsub("^%s+", "")
    end
    function UiLib:CreateWindow(Options)
        Options = type(Options) == "table" and Options or {}
        State.title = StripSymbols(Options.title or "uilib")
        if Options.subtitle == "auto" then
            State.subtitle = ""
            task.spawn(function()
                local ModeName
                pcall(function()
                    local Result = getgamename()
                    if type(Result) == "string" and Result ~= "" then
                        ModeName = Result
                    end
                end)
                if not (type(ModeName) == "string" and ModeName ~= "") then
                    pcall(function()
                        ModeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
                    end)
                end
                if not (type(ModeName) == "string" and ModeName ~= "") then
                    pcall(function()
                        local Response =
                            game:HttpGet(
                            "https://apis.roblox.com/universes/v1/places/" ..
                                tostring(game.PlaceId) .. "/universe"
                        )
                        local UserId = Response and Response:match('"universeId":%s*(%d+)')
                        if UserId then
                            local Green =
                                game:HttpGet("https://games.roblox.com/v1/games?universeIds=" .. UserId)
                            if Green then
                                ModeName = Green:match('"name":"(.-)"')
                            end
                        end
                    end)
                end
                if not (type(ModeName) == "string" and ModeName ~= "") then
                    pcall(function()
                        local Name = game.Name
                        if type(Name) == "string" and Name ~= "" and Name ~= "Game" and Name ~= "Ugc" then
                            ModeName = Name
                        end
                    end)
                end
                if type(ModeName) == "string" and ModeName ~= "" then
                    State.subtitle = StripSymbols(ModeName)
                end
            end)
        else
            State.subtitle = StripSymbols(Options.subtitle or "")
        end
        if Options.configFolder and SanitizeFolderName(Options.configFolder) ~= "" then
            State.cfgFolder = SanitizeFolderName(Options.configFolder)
        else
            local Kind = SanitizeFolderName(State.title)
            if Kind ~= "" and Kind ~= "uilib" then
                State.cfgFolder = RegistryName .. "_" .. Kind
            end
        end
        if Options.size then
            State.w = Options.size.X
            State.h = Options.size.Y
            State.wTarget = State.w
            State.hTarget = State.h
        end
        if Options.configName then
            State.configName = tostring(Options.configName)
        end
        State._baseConfigName = State.configName
        local ViewportWidth, ViewportHeight = GetViewportSize()
        State.x = Options.position and Options.position.X or MathFloor(ViewportWidth / 2 - State.w / 2)
        State.y = Options.position and Options.position.Y or MathFloor(ViewportHeight / 2 - State.h / 2)
        if Options.menuKey then
            UiLib:SetMenuKey(Options.menuKey)
        end
        if Options.gameInput ~= nil then
            UiLib:SetGameInput(Options.gameInput)
        end
        if Options.logo then
            UiLib:SetLogo(Options.logo)
        end
        if Options.logoSize then
            State.logoSize = Clamp(tonumber(Options.logoSize) or 30, 16, 96)
        end
        if Options.icon then
            UiLib:SetIcon(Options.icon)
        end
        if Options.opacity then
            UiLib:SetOpacity(Options.opacity)
        end
        if Options.rounding ~= nil then
            UiLib:SetRounding(Options.rounding)
        end
        if Options.rowLines ~= nil then
            UiLib:SetRowLines(Options.rowLines)
        end
        if Options.checkboxStyle ~= nil then
            UiLib:SetCheckboxStyle(Options.checkboxStyle)
        end
        if Options.smartFps ~= nil then
            State.smartFps = Options.smartFps == true
        end
        if Options.keybindOverlay ~= nil then
            State.hotkeyEnabled = Options.keybindOverlay ~= false
        end
        if Options.theme then
            UiLib:SetTheme(Options.theme)
        end
        if Options.accent ~= nil or Options.accentA ~= nil or Options.accentB ~= nil then
            UiLib:SetAccent(Options.accentA or Options.accent, Options.accentB or Options.accent)
        end
        if Options.font then
            UiLib:SetFont(Options.font)
        end
        if Options.backgroundEffect then
            UiLib:SetBackgroundEffect(Options.backgroundEffect)
        end
        if Options.backgroundEffectColor then
            UiLib:SetBackgroundEffectColor(Options.backgroundEffectColor)
        end
        if Options.autoSave then
            UiLib:SetAutoSave(true)
        end
        local Value = setmetatable({}, {__index = UiLib})
        function Value:Tab(Name, Icon)
            return UiLib:Tab(Name, Icon)
        end
        function Value:AddSettingsTab(Icon)
            if State.settingsApi then
                return State.settingsApi
            end
            State.settingsApi = BuildSettingsTab(Value, Icon)
            return State.settingsApi
        end
        function Value:GetSettingsTab()
            return State.settingsApi
        end
        function Value:SettingsSection(Name, Side, Description)
            return Value:AddSettingsTab():Section(Name, Side or "Right", Description)
        end
        function Value:SetLogo(Value2)
            return UiLib:SetLogo(Value2)
        end
        function Value:SetIcon(Value2)
            return UiLib:SetIcon(Value2)
        end
        function Value:SetOpacity(Value2)
            return UiLib:SetOpacity(Value2)
        end
        function Value:SaveConfig(Value2)
            return UiLib:SaveConfig(Value2)
        end
        function Value:LoadConfig(Value2)
            return UiLib:LoadConfig(Value2)
        end
        function Value:autoloadConfig(Value2)
            UiLib:LoadConfig(Value2 or State.configName)
            return self
        end
        task.spawn(function()
            State._avLog = {}
            local function Log(CharWidth)
                local AvLog = State._avLog
                if AvLog then
                    AvLog[#AvLog + 1] = tostring(CharWidth)
                end
            end
            local function IsImage(ValueB)
                if not ValueB or #ValueB < 12 then
                    return false
                end
                local Alpha, Cache, Object, Edge = string.byte(ValueB, 1, 4)
                return Alpha == 0x89 and Cache == 0x50 and Object == 0x4E and Edge == 0x47 or
                    Alpha == 0xFF and Cache == 0xD8
            end
            local function SetAvatar(ValueB)
                if not IsImage(ValueB) then
                    return false
                end
                local Image
                local Success =
                    pcall(
                    function()
                        Image = Drawing.new("Image")
                        Image.Data = ValueB
                        Image.Visible = false
                    end
                )
                if Success and Image then
                    State.avatarImg = Image
                    return true
                end
                return false
            end
            local UserId, UserName
            for _ = 1, 30 do
                local Player
                pcall(function()
                    Player = game:GetService("Players").LocalPlayer
                end)
                if Player then
                    pcall(function()
                        if Player.Name and Player.Name ~= "" then
                            UserName = tostring(Player.Name)
                        end
                    end)
                    local Response
                    pcall(function()
                        Response = Player.UserId
                    end)
                    if Response and Response ~= 0 then
                        UserId = Response
                        break
                    end
                end
                task.wait(0.12)
            end
            Log("UserId poll -> uid=" .. tostring(UserId) .. " name=" .. tostring(UserName))
            if not UserId and UserName then
                pcall(function()
                    local Chunk = '{"usernames":["' .. UserName .. '"],"excludeBannedUsers":false}'
                    local Response
                    if HttpPost then
                        Response =
                            HttpPost("https://users.roblox.com/v1/usernames/users", Chunk, "application/json")
                    elseif HttpRequest then
                        local Result =
                            HttpRequest(
                            {
                                Url = "https://users.roblox.com/v1/usernames/users",
                                Method = "POST",
                                Body = Chunk,
                                Headers = {["Content-Type"] = "application/json"}
                            }
                        )
                        Response = Result and (Result.Body or Result.body)
                    end
                    local KeyCode = Response and string.match(Response, '"id":%s*(%d+)')
                    if KeyCode then
                        UserId = tonumber(KeyCode)
                    end
                end)
                Log("name->id fallback -> uid=" .. tostring(UserId))
            end
            if not UserId then
                Log("FAILED: could not resolve a UserId")
                return
            end
            local CacheName = "RyzenUI_av_" .. tostring(UserId) .. ".dat"
            if IsFile and ReadFile then
                local Success
                pcall(function()
                    Success = IsFile(CacheName)
                end)
                if Success then
                    local Cache
                    pcall(function()
                        Cache = ReadFile(CacheName)
                    end)
                    if SetAvatar(Cache) then
                        Log("loaded from disk cache")
                        return
                    end
                end
            end
            local Endpoints = {
                "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" ..
                    tostring(UserId) .. "&size=150x150&format=Png&isCircular=false",
                "https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds=" ..
                    tostring(UserId) .. "&size=150x150&format=Png&isCircular=false",
                "https://thumbnails.roblox.com/v1/users/avatar-bust?userIds=" ..
                    tostring(UserId) .. "&size=150x150&format=Png&isCircular=false"
            }
            for Attempt = 1, 5 do
                for EndpointIndex, Endpoint in ipairs(Endpoints) do
                    local Done = false
                    pcall(function()
                        local Body = game:HttpGet(Endpoint)
                        local State2 = Body and string.match(Body, '"state":%s*"(%w+)"')
                        local Url = Body and string.match(Body, '"imageUrl":"([^"]+)"')
                        Log(
                            "ep" ..
                                EndpointIndex ..
                                    " try" ..
                                        Attempt ..
                                            ": state=" .. tostring(State2) .. " url=" .. (Url and "yes" or "no")
                        )
                        if Url and Url ~= "" then
                            Url = Url:gsub("\\/", "/")
                            local Blue = game:HttpGet(Url)
                            Log("  cdn bytes=" .. (Blue and #Blue or 0) .. " img=" .. tostring(IsImage(Blue)))
                            if SetAvatar(Blue) then
                                if WriteFile then
                                    pcall(function()
                                        WriteFile(CacheName, Blue)
                                    end)
                                end
                                Log("  OK avatar set")
                                Done = true
                            end
                        end
                    end)
                    if Done then
                        return
                    end
                end
                task.wait(0.7)
            end
            Log("FAILED: no usable image after retries")
        end)
        UpdateInputBlock(true)
        State.open = Options.startOpen ~= false
        State._autoSaveT = Clock() or 0
        State._winReady = true
        return Value
    end
    SetGlobal(RegistryName, UiLib)
    SetGlobal(RegistryName .. "UI", UiLib)
    return UiLib
end


local Backend = CreateRyzenBackend()
local FromRGB = Color3.fromRGB

local Themes = {
    Preset = {
        Background = FromRGB(16, 18, 18),
        Inline = FromRGB(21, 24, 24),
        Element = FromRGB(30, 34, 34),
        Accent = FromRGB(255, 255, 255),
        Border = FromRGB(30, 34, 34),
        ["Border 2"] = FromRGB(56, 62, 62),
    },
}

local Ryzen = {
    Backend = Backend,
    Flags = {},
    Themes = Themes,
    Theme = Themes.Preset,
    MenuKeybind = "z",
    Tween = { Time = 0.2, Style = "Quint", Direction = "Out" },
    Folders = {
        Directory = "Ryzen",
        Configs = "Ryzen/Configs",
        Assets = "Ryzen/Assets",
    },
}

local KeyAliases = {
    rightshift = "rshift",
    leftshift = "lshift",
    rightcontrol = "rctrl",
    leftcontrol = "lctrl",
    rightalt = "ralt",
    leftalt = "lalt",
}

local function Options(Value)
    return type(Value) == "table" and Value or { Name = Value }
end

local function KeyName(Value)
    if Value == nil then
        return nil
    end

    local Text = tostring(Value)
    Text = (Text:match("[^%.]+$") or Text):lower()

    return KeyAliases[Text] or Text
end

local function FolderName(Value)
    local Name = tostring(Value or "Ryzen"):gsub("[^%w%-%_ ]", "_"):gsub("%s+", "_")
    return Name ~= "" and Name or "Ryzen"
end

local function EnsureFolder(Path)
    if type(isfolder) == "function" and isfolder(Path) then
        return
    end

    if type(makefolder) == "function" then
        pcall(makefolder, Path)
    end
end

local function Register(Control, Data, Initial)
    local Flag = Data.Flag
    if not Flag then
        return Control
    end

    Ryzen.Flags[Flag] = Initial

    if type(Control) == "table" then
        local RawSet = Control.Set
        if type(RawSet) == "function" then
            Control.Set = function(Self, Value, ...)
                Ryzen.Flags[Flag] = Value
                return RawSet(Self, Value, ...)
            end
        end
    end

    return Control
end

local function MakeCallback(Data, Flag)
    return function(Value, ...)
        if Flag then
            Ryzen.Flags[Flag] = Value
        end

        if type(Data.Callback) == "function" then
            return Data.Callback(Value, ...)
        end
    end
end

local function DecorateLabel(Label)
    if type(Label) ~= "table" then
        return Label
    end

    Label.Colorpicker = function(Self, Value)
        local Data = Options(Value)
        local Initial = Data.Default or Data.Color
        local Control = Self:AddColorpicker(Initial, MakeCallback(Data, Data.Flag), Data.Transparency or Data.Alpha)
        return Register(Control, Data, Initial)
    end

    Label.Keybind = function(Self, Value)
        local Data = Options(Value)
        local Initial = KeyName(Data.Default or Data.Key)
        local Control = Self:AddKeybind(Initial, MakeCallback(Data, Data.Flag), Data.Tooltip)
        return Register(Control, Data, Initial)
    end

    return Label
end

local function DecorateSection(Section)
    local Native = {
        Label = Section.Label,
        Button = Section.Button,
        Toggle = Section.Toggle,
        Slider = Section.Slider,
        Dropdown = Section.Dropdown,
        Colorpicker = Section.Colorpicker,
        Textbox = Section.Textbox,
        Keybind = Section.Keybind,
    }

    function Section:Label(Value)
        local Data = Options(Value)
        return DecorateLabel(Native.Label(self, Data.Name or Data.Text or Value, Data.Color, Data.Tooltip))
    end

    function Section:Button(Value)
        local Data = Options(Value)
        return Native.Button(self, Data.Name or Data.Text or "Button", Data.Callback, Data.Tooltip)
    end

    function Section:Toggle(Value)
        local Data = Options(Value)
        local Initial = Data.Default == true
        local Control = Native.Toggle(self, Data.Name or "Toggle", Initial, MakeCallback(Data, Data.Flag), Data.Tooltip)
        return Register(Control, Data, Initial)
    end

    function Section:Slider(Value)
        local Data = Options(Value)
        local Initial = Data.Default or Data.Min or 0
        local Control = Native.Slider(
            self,
            Data.Name or "Slider",
            Initial,
            Data.Decimals or Data.Step or 1,
            Data.Min or 0,
            Data.Max or 100,
            Data.Suffix or "",
            MakeCallback(Data, Data.Flag),
            Data.Tooltip
        )
        return Register(Control, Data, Initial)
    end

    function Section:Dropdown(Value)
        local Data = Options(Value)
        local Initial = Data.Default

        if Data.Multi and type(Initial) ~= "table" then
            Initial = Initial and { Initial } or {}
        end

        local Control = Native.Dropdown(
            self,
            Data.Name or "Dropdown",
            Initial,
            Data.Items or Data.Values or {},
            Data.Multi == true,
            MakeCallback(Data, Data.Flag),
            Data.Tooltip,
            Data.Searchable,
            Data.MaxSelections
        )
        return Register(Control, Data, Initial)
    end

    function Section:Colorpicker(Value)
        local Data = Options(Value)
        local Initial = Data.Default or Data.Color
        local Control = Native.Colorpicker(
            self,
            Data.Name or "Color",
            Initial,
            MakeCallback(Data, Data.Flag),
            Data.Transparency or Data.Alpha
        )
        return Register(Control, Data, Initial)
    end

    function Section:Textbox(Value)
        local Data = Options(Value)
        local Initial = Data.Default or ""
        local Control = Native.Textbox(
            self,
            Data.Name or Data.Placeholder or "Textbox",
            Initial,
            MakeCallback(Data, Data.Flag),
            Data.Tooltip
        )
        return Register(Control, Data, Initial)
    end

    function Section:Keybind(Value)
        local Data = Options(Value)
        local Initial = KeyName(Data.Default or Data.Key)
        local Control = Native.Keybind(self, Data.Name or "Keybind", Initial, MakeCallback(Data, Data.Flag), Data.Tooltip)
        return Register(Control, Data, Initial)
    end

    return Section
end

local function DecoratePage(Page)
    local NativeSection = Page.Section
    local NativeSub = Page.Sub

    function Page:Section(Value)
        local Data = Options(Value)
        local Side = Data.Side == 2 and "Right" or "Left"
        return DecorateSection(NativeSection(self, Data.Name or "Section", Side, Data.Icon))
    end

    function Page:SubPage(Value)
        local Data = Options(Value)
        return DecoratePage(NativeSub(self, Data.Name or "SubPage", Data.Icon))
    end

    return Page
end

function Ryzen:Window(Value)
    local Data = Options(Value)
    local Title = Data.Name or Data.Title or "Ryzen"
    local RootFolder = "RyzenHub"
    local ConfigFolder = RootFolder .. "/" .. FolderName(Title)

    EnsureFolder(RootFolder)
    EnsureFolder(ConfigFolder)

    local Window = Backend:CreateWindow({
        title = Title,
        subtitle = Data.Subtitle or "",
        size = Data.Size,
        position = Data.Position,
        menuKey = KeyName(Data.Keybind or self.MenuKeybind),
        configFolder = ConfigFolder,
        startOpen = Data.Open ~= false,
    })

    local NativeTab = Window.Tab
    local SettingsCreated = false
    local ToggleKey = KeyName(Data.Keybind or self.MenuKeybind) or "rshift"
    local PanicKey = "end"

    local function CreateSettings()
        if SettingsCreated then
            return
        end
        SettingsCreated = true

        local SettingsPage = DecoratePage(NativeTab(Window, "Settings", "settings"))
        local ConfigPage = SettingsPage:SubPage({ Name = "Configs" })
        local KeysPage = SettingsPage:SubPage({ Name = "Keybinds" })
        local ConfigSection = ConfigPage:Section({ Name = "Configs", Side = 1 })

        local ConfigName = "default"
        local SelectedConfig = "default"

        ConfigSection:Textbox({
            Name = "Config name",
            Default = ConfigName,
            Callback = function(Text)
                ConfigName = tostring(Text or "default")
            end,
        })

        local ConfigList = ConfigSection:Dropdown({
            Name = "Saved configs",
            Items = Backend:ListConfigs(),
            Default = SelectedConfig,
            Callback = function(Selection)
                SelectedConfig = type(Selection) == "table" and Selection[1] or Selection or SelectedConfig
            end,
        })

        local function RefreshConfigs()
            if ConfigList and type(ConfigList.UpdateChoices) == "function" then
                ConfigList:UpdateChoices(Backend:ListConfigs())
            end
        end

        ConfigSection:Button({
            Name = "Save",
            Callback = function()
                Backend:SaveConfig(ConfigName)
                RefreshConfigs()
            end,
        })

        ConfigSection:Button({
            Name = "Load",
            Callback = function()
                Backend:LoadConfig(SelectedConfig or ConfigName)
            end,
        })

        ConfigSection:Button({
            Name = "Delete",
            Callback = function()
                Backend:DeleteConfig(SelectedConfig or ConfigName)
                RefreshConfigs()
            end,
        })

        ConfigSection:Button({ Name = "Refresh", Callback = RefreshConfigs })

        local KeySection = KeysPage:Section({ Name = "Interface", Side = 1 })

        KeySection:Keybind({
            Name = "Menu toggle",
            Default = ToggleKey,
            Callback = function(Key)
                ToggleKey = KeyName(Key) or ToggleKey
            end,
        })

        KeySection:Keybind({
            Name = "Panic unload",
            Default = PanicKey,
            Callback = function(Key)
                PanicKey = KeyName(Key) or PanicKey
            end,
        })

        KeySection:Button({
            Name = "Unload now",
            Callback = function()
                Ryzen:Unload()
            end,
        })
    end

    function Window:Page(PageValue)
        local PageData = Options(PageValue)
        return DecoratePage(NativeTab(self, PageData.Name or "Page", PageData.Icon))
    end

    task.defer(CreateSettings)

    task.spawn(function()
        local ToggleHeld, PanicHeld = false, false

        while true do
            local ToggleDown, PanicDown = false, false

            pcall(function()
                ToggleDown = iskeypressed(ToggleKey) == true
            end)
            pcall(function()
                PanicDown = iskeypressed(PanicKey) == true
            end)

            if ToggleDown and not ToggleHeld then
                Backend:SetOpen(not Backend:IsOpen())
            end

            if PanicDown and not PanicHeld then
                Ryzen:Unload()
                return
            end

            ToggleHeld, PanicHeld = ToggleDown, PanicDown
            task.wait(0.03)
        end
    end)

    return Window
end

function Ryzen:Notification(Text, Duration, Icon)
    return Backend.Notify("Ryzen", tostring(Text or ""), Duration or 5, Icon and "info" or nil)
end

function Ryzen:Notify(...)
    return self:Notification(...)
end

function Ryzen:Unload()
    return Backend:Destroy()
end

function Ryzen:SetOpen(Value)
    return Backend:SetOpen(Value)
end

function Ryzen:GetConfig()
    return Backend:ExportConfig()
end

function Ryzen:LoadConfig(Value)
    return Backend:ImportConfig(Value)
end

function Ryzen:SaveConfig(Name)
    return Backend:SaveConfig(Name)
end

function Ryzen:DeleteConfig(Name)
    return Backend:DeleteConfig(Name)
end

function Ryzen:CreateSettingsPage(Window)
    return Window:Page({ Name = "Settings" })
end

local function Export(Name, Value)
    pcall(function()
        getgenv()[Name] = Value
    end)
    pcall(function()
        _G[Name] = Value
    end)
    pcall(function()
        if type(shared) == "table" then
            shared[Name] = Value
        end
    end)
end

Export("Library", Ryzen)
Export("RyzenLib", Ryzen)

pcall(function()
    local Env = getfenv and getfenv() or nil
    if type(Env) == "table" then
        Env.RyzenUI = Ryzen
        Env.RyzenLib = Ryzen
        Env.Library = Ryzen
    end
end)

return Ryzen
