-- ============================================================
--   ZYNX ENGINE v2.1 | TK: tizi8776
--   Original + búsqueda + GUI mejorada + efecto de nieve ❄️
-- ============================================================

local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("ZynxBlankEngine") then
    CoreGui.ZynxBlankEngine:Destroy()
end

-- ============================================================
-- PERSISTENCIA (igual que el original)
-- ============================================================
local ARCHIVO_GUARDADO = "MisAccesoriosForzados.json"
local ACCESORIOS_IDS   = {}

local function cargarAccesorios()
    if isfile and readfile and isfile(ARCHIVO_GUARDADO) then
        local ok, datos = pcall(function()
            return HttpService:JSONDecode(readfile(ARCHIVO_GUARDADO))
        end)
        if ok and datos then ACCESORIOS_IDS = datos return end
    end
    ACCESORIOS_IDS = {
        {id = 10159600649, nombre = "Accesorio Ejemplo 1"},
        {id = 139607718,   nombre = "Korblox Right Leg"},
    }
end

local function guardarAccesorios()
    if writefile then
        pcall(function()
            writefile(ARCHIVO_GUARDADO, HttpService:JSONEncode(ACCESORIOS_IDS))
        end)
    end
end

-- ============================================================
-- LÓGICA DE ACCESORIOS (igual que el original)
-- ============================================================
local function forzarAccesorioPorID(id)
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    if character:FindFirstChild("AccesorioForzado_" .. id) then return end

    local ok, objetos = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
    if not ok or not objetos or #objetos == 0 then return end

    local asset     = objetos[1]
    local accesorio = asset:IsA("Accessory") and asset or asset:FindFirstChildOfClass("Accessory")
    if not accesorio then return end

    local handle = accesorio:FindFirstChild("Handle") or accesorio:FindFirstChild("handle")
    if not handle then return end

    local clon       = accesorio:Clone()
    clon.Name        = "AccesorioForzado_" .. id
    local clonHandle = clon:FindFirstChild("Handle") or clon:FindFirstChild("handle")

    local attachmentAccesorio = clonHandle:FindFirstChildOfClass("Attachment")
    local parteCuerpoObjetivo = character:FindFirstChild("Head")

    if attachmentAccesorio then
        local attCuerpo = character:FindFirstChild(attachmentAccesorio.Name, true)
        if attCuerpo and attCuerpo.Parent then
            parteCuerpoObjetivo = attCuerpo.Parent end
    end

    pcall(function() clon:RemoveCharacterAssociations() end)
    for _, v in ipairs(clonHandle:GetChildren()) do
        if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("WeldConstraint") then v:Destroy() end
    end

    clon.Parent = character
    local weld  = Instance.new("Weld")
    weld.Name   = "WeldForzado_" .. id
    weld.Part0  = clonHandle
    weld.Part1  = parteCuerpoObjetivo

    if attachmentAccesorio then
        local attCuerpo = character:FindFirstChild(attachmentAccesorio.Name, true)
        if attCuerpo then
            weld.C0 = attachmentAccesorio.CFrame
            weld.C1 = attCuerpo.CFrame
        else
            weld.C0 = CFrame.new(0, -0.6, 0)
        end
    else
        weld.C0 = CFrame.new(0, -0.6, 0)
    end
    weld.Parent = clonHandle
end

cargarAccesorios()

-- ============================================================
-- SCREENGUI
-- ============================================================
local ScreenGui        = Instance.new("ScreenGui")
ScreenGui.Name         = "ZynxBlankEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent       = CoreGui

-- ============================================================
-- VENTANA PRINCIPAL (un poco más alta para la búsqueda)
-- ============================================================
local MainFrame             = Instance.new("Frame")
MainFrame.Name              = "MainFrame"
MainFrame.Size              = UDim2.new(0, 520, 0, 410)
MainFrame.Position          = UDim2.new(0.5, -260, 0.5, -205)
MainFrame.BackgroundColor3  = Color3.fromRGB(10, 12, 20)
MainFrame.BorderSizePixel   = 0
MainFrame.Active            = true
MainFrame.Visible           = false
MainFrame.ClipsDescendants  = true
MainFrame.Parent            = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Borde exterior sutil
local BorderFrame           = Instance.new("Frame")
BorderFrame.Size            = UDim2.new(1, 2, 1, 2)
BorderFrame.Position        = UDim2.new(0, -1, 0, -1)
BorderFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BorderFrame.BorderSizePixel = 0
BorderFrame.ZIndex          = 0
BorderFrame.Parent          = MainFrame
Instance.new("UICorner", BorderFrame).CornerRadius = UDim.new(0, 13)

-- ============================================================
-- CAPA DE NIEVE (canvas sobre la GUI)
-- ============================================================
local SnowCanvas            = Instance.new("Frame")
SnowCanvas.Name             = "SnowCanvas"
SnowCanvas.Size             = UDim2.new(1, 0, 1, 0)
SnowCanvas.BackgroundTransparency = 1
SnowCanvas.ZIndex           = 10
SnowCanvas.ClipsDescendants = true
SnowCanvas.Parent           = MainFrame

-- Generar copos de nieve
local NIEVE_MAX = 35
local copos     = {}

local function crearCopo()
    local f             = Instance.new("Frame", SnowCanvas)
    f.BackgroundColor3  = Color3.fromRGB(200, 230, 255)
    f.BorderSizePixel   = 0
    local size          = math.random(2, 5)
    f.Size              = UDim2.new(0, size, 0, size)
    f.Position          = UDim2.new(math.random(), 0, -0.05, 0)
    f.BackgroundTransparency = math.random(20, 50) / 100
    Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    return {
        frame   = f,
        speedY  = math.random(40, 100) / 1000,   -- caída
        speedX  = (math.random() - 0.5) * 0.002, -- deriva lateral
        posX    = math.random(),
        posY    = -0.05,
        size    = size,
    }
end

for i = 1, NIEVE_MAX do
    local c = crearCopo()
    c.posY  = math.random()  -- dispersar al inicio
    c.frame.Position = UDim2.new(c.posX, 0, c.posY, 0)
    table.insert(copos, c)
end

-- Animación de nieve con RunService
local snowConnection
snowConnection = RunService.Heartbeat:Connect(function(dt)
    if not MainFrame.Parent then snowConnection:Disconnect() return end
    if not MainFrame.Visible then return end

    for _, copo in ipairs(copos) do
        copo.posY = copo.posY + copo.speedY * dt * 3
        copo.posX = copo.posX + copo.speedX * dt * 3

        -- rebobinar cuando sale por abajo
        if copo.posY > 1.05 then
            copo.posY  = -0.05
            copo.posX  = math.random()
            copo.speedY = math.random(40, 100) / 1000
            copo.speedX = (math.random() - 0.5) * 0.002
        end
        -- rebote lateral
        if copo.posX < 0 then copo.posX = 0 copo.speedX = math.abs(copo.speedX) end
        if copo.posX > 1 then copo.posX = 1 copo.speedX = -math.abs(copo.speedX) end

        copo.frame.Position = UDim2.new(copo.posX, 0, copo.posY, 0)
    end
end)

-- ============================================================
-- DEGRADADO DE FONDO (estrellas/cielo nocturno)
-- ============================================================
local BGGrad            = Instance.new("UIGradient")
BGGrad.Color            = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(10, 10, 24)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 18, 35)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  12, 22)),
})
BGGrad.Rotation         = 135
BGGrad.Parent           = MainFrame

-- ============================================================
-- BARRA SUPERIOR DE COLOR (animada)
-- ============================================================
local GlowBar           = Instance.new("Frame", MainFrame)
GlowBar.Size            = UDim2.new(1, 0, 0, 3)
GlowBar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
GlowBar.BorderSizePixel = 0
GlowBar.ZIndex          = 5

local GlowBarGrad       = Instance.new("UIGradient", GlowBar)
GlowBarGrad.Color       = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 120, 255)),
})

-- Animar el degradado de la barra
local gradOffset = 0
RunService.Heartbeat:Connect(function(dt)
    if not MainFrame.Parent then return end
    gradOffset = (gradOffset + dt * 0.4) % 1
    GlowBarGrad.Offset = Vector2.new(gradOffset - 0.5, 0)
end)

-- ============================================================
-- TOP BAR
-- ============================================================
local TopBar            = Instance.new("Frame", MainFrame)
TopBar.Size             = UDim2.new(1, 0, 0, 42)
TopBar.Position         = UDim2.new(0, 0, 0, 3)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex           = 5

local Title             = Instance.new("TextLabel", TopBar)
Title.Size              = UDim2.new(1, -80, 1, 0)
Title.Position          = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text              = "❄  NX v2.0  //  TK: tizi8776"
Title.TextColor3        = Color3.fromRGB(160, 220, 255)
Title.TextSize          = 13
Title.Font              = Enum.Font.GothamBold
Title.TextXAlignment    = Enum.TextXAlignment.Left
Title.ZIndex            = 6

local CloseBtn          = Instance.new("TextButton", TopBar)
CloseBtn.Size           = UDim2.new(0, 28, 0, 28)
CloseBtn.Position       = UDim2.new(1, -36, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
CloseBtn.Text           = "X"
CloseBtn.TextColor3     = Color3.fromRGB(200, 80, 80)
CloseBtn.TextSize       = 13
CloseBtn.Font           = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex         = 6
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ============================================================
-- BARRA DE BÚSQUEDA ← la nueva
-- ============================================================
local SearchContainer   = Instance.new("Frame", MainFrame)
SearchContainer.Size    = UDim2.new(1, -30, 0, 32)
SearchContainer.Position = UDim2.new(0, 15, 0, 48)
SearchContainer.BackgroundColor3 = Color3.fromRGB(18, 22, 38)
SearchContainer.BorderSizePixel  = 0
SearchContainer.ZIndex  = 5
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 7)

local SearchIcon        = Instance.new("TextLabel", SearchContainer)
SearchIcon.Size         = UDim2.new(0, 28, 1, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text         = "🔍"
SearchIcon.TextSize     = 12
SearchIcon.Font         = Enum.Font.Gotham
SearchIcon.ZIndex       = 6

local SearchBox         = Instance.new("TextBox", SearchContainer)
SearchBox.Size          = UDim2.new(1, -35, 1, 0)
SearchBox.Position      = UDim2.new(0, 28, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text          = ""
SearchBox.PlaceholderText = "Buscar por nombre..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 90, 110)
SearchBox.TextColor3    = Color3.fromRGB(200, 220, 255)
SearchBox.TextSize      = 12
SearchBox.Font          = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.BorderSizePixel = 0
SearchBox.ZIndex        = 6

-- ============================================================
-- ÁREA DE CONTENIDO
-- ============================================================
local ContentFrame      = Instance.new("Frame", MainFrame)
ContentFrame.Name       = "ContentFrame"
ContentFrame.Size       = UDim2.new(1, -30, 1, -165)
ContentFrame.Position   = UDim2.new(0, 15, 0, 88)
ContentFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
ContentFrame.BorderSizePixel  = 0
ContentFrame.ZIndex     = 5
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 8)

-- Borde interior del content
local ContentBorder     = Instance.new("UIStroke", ContentFrame)
ContentBorder.Color     = Color3.fromRGB(30, 50, 80)
ContentBorder.Thickness = 1

local ScrollFrame       = Instance.new("ScrollingFrame", ContentFrame)
ScrollFrame.Size        = UDim2.new(1, -16, 1, -12)
ScrollFrame.Position    = UDim2.new(0, 8, 0, 6)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize  = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 220)
ScrollFrame.ZIndex      = 5

local Layout            = Instance.new("UIListLayout", ScrollFrame)
Layout.Padding          = UDim.new(0, 5)

-- ============================================================
-- BARRA INFERIOR
-- ============================================================
local BottomBar         = Instance.new("Frame", MainFrame)
BottomBar.Size          = UDim2.new(1, 0, 0, 70)
BottomBar.Position      = UDim2.new(0, 0, 1, -70)
BottomBar.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
BottomBar.BorderSizePixel  = 0
BottomBar.ZIndex        = 5

local BottomBorder      = Instance.new("Frame", BottomBar)
BottomBorder.Size       = UDim2.new(1, 0, 0, 1)
BottomBorder.BackgroundColor3 = Color3.fromRGB(25, 45, 70)
BottomBorder.BorderSizePixel  = 0

local InputBox          = Instance.new("TextBox", BottomBar)
InputBox.Size           = UDim2.new(0, 300, 0, 36)
InputBox.Position       = UDim2.new(0, 15, 0, 17)
InputBox.BackgroundColor3 = Color3.fromRGB(16, 20, 34)
InputBox.TextColor3     = Color3.fromRGB(200, 220, 255)
InputBox.Text           = ""
InputBox.PlaceholderText = "  Pegar ID de Accesorio aquí..."
InputBox.PlaceholderColor3 = Color3.fromRGB(70, 85, 110)
InputBox.Font           = Enum.Font.Gotham
InputBox.TextSize       = 12
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.BorderSizePixel = 0
InputBox.ZIndex         = 6
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 7)
Instance.new("UIStroke", InputBox).Color        = Color3.fromRGB(30, 55, 90)

local LinkBtn           = Instance.new("TextButton", BottomBar)
LinkBtn.Size            = UDim2.new(0, 36, 0, 36)
LinkBtn.Position        = UDim2.new(0, 323, 0, 17)
LinkBtn.BackgroundColor3 = Color3.fromRGB(16, 20, 34)
LinkBtn.Text            = "🔗"
LinkBtn.Font            = Enum.Font.GothamBold
LinkBtn.TextColor3      = Color3.fromRGB(0, 180, 255)
LinkBtn.TextSize        = 14
LinkBtn.BorderSizePixel = 0
LinkBtn.ZIndex          = 6
Instance.new("UICorner", LinkBtn).CornerRadius = UDim.new(0, 7)

local AddBtn            = Instance.new("TextButton", BottomBar)
AddBtn.Size             = UDim2.new(0, 140, 0, 36)
AddBtn.Position         = UDim2.new(0, 367, 0, 17)
AddBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
AddBtn.Text             = "+  Añadir Ítem"
AddBtn.Font             = Enum.Font.GothamBold
AddBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
AddBtn.TextSize         = 13
AddBtn.BorderSizePixel  = 0
AddBtn.ZIndex           = 6
Instance.new("UICorner", AddBtn).CornerRadius = UDim.new(0, 7)

local AddGrad           = Instance.new("UIGradient", AddBtn)
AddGrad.Color           = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 130, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 80,  200)),
})
AddGrad.Rotation        = 90

-- ============================================================
-- NOTIFICACIÓN
-- ============================================================
local mostrarNotificacionXeno
mostrarNotificacionXeno = function(mensaje)
    local nf                = Instance.new("Frame", ScreenGui)
    nf.Size                 = UDim2.new(0, 250, 0, 48)
    nf.Position             = UDim2.new(1, 30, 1, -65)
    nf.BackgroundColor3     = Color3.fromRGB(10, 12, 22)
    nf.BorderSizePixel      = 0
    nf.ZIndex               = 20
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", nf).Color        = Color3.fromRGB(0, 120, 200)

    local accent            = Instance.new("Frame", nf)
    accent.Size             = UDim2.new(0, 3, 0.7, 0)
    accent.Position         = UDim2.new(0, 8, 0.15, 0)
    accent.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    accent.BorderSizePixel  = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local lbl               = Instance.new("TextLabel", nf)
    lbl.Size                = UDim2.new(1, -25, 1, 0)
    lbl.Position            = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                = mensaje
    lbl.TextColor3          = Color3.fromRGB(200, 225, 255)
    lbl.TextSize            = 12
    lbl.Font                = Enum.Font.GothamBold
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 21

    TweenService:Create(nf, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -268, 1, -65)}):Play()

    task.delay(2.5, function()
        local t = TweenService:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 30, 1, -65)})
        t:Play()
        t.Completed:Connect(function() nf:Destroy() end)
    end)
end

-- ============================================================
-- LISTA VISUAL (con filtro de búsqueda)
-- ============================================================
local function actualizarListaVisual()
    for _, item in ipairs(ScrollFrame:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end

    local filtro = SearchBox.Text:lower()

    for _, datos in ipairs(ACCESORIOS_IDS) do
        -- Filtro de búsqueda: nombre o ID
        if filtro ~= "" then
            local nombreMatch = datos.nombre:lower():find(filtro, 1, true)
            local idMatch     = tostring(datos.id):find(filtro, 1, true)
            if not nombreMatch and not idMatch then continue end
        end

        local id   = datos.id  -- captura local correcta

        local Fila = Instance.new("Frame", ScrollFrame)
        Fila.Size  = UDim2.new(1, -5, 0, 36)
        Fila.BackgroundColor3 = Color3.fromRGB(14, 18, 30)
        Fila.BorderSizePixel  = 0
        Fila.ZIndex           = 5
        Instance.new("UICorner", Fila).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", Fila).Color        = Color3.fromRGB(25, 40, 65)

        -- Hover effect en la fila
        Fila.MouseEnter:Connect(function()
            TweenService:Create(Fila, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(18, 24, 42)}):Play()
        end)
        Fila.MouseLeave:Connect(function()
            TweenService:Create(Fila, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(14, 18, 30)}):Play()
        end)

        -- Nombre (editable)
        local NomInput              = Instance.new("TextBox", Fila)
        NomInput.Size               = UDim2.new(0, 200, 1, 0)
        NomInput.Position           = UDim2.new(0, 12, 0, 0)
        NomInput.BackgroundTransparency = 1
        NomInput.Text               = datos.nombre
        NomInput.Font               = Enum.Font.GothamMedium
        NomInput.TextColor3         = Color3.fromRGB(210, 230, 255)
        NomInput.TextSize           = 12
        NomInput.TextXAlignment     = Enum.TextXAlignment.Left
        NomInput.ZIndex             = 6
        NomInput.FocusLost:Connect(function()
            datos.nombre = NomInput.Text
            guardarAccesorios()
        end)

        -- ID label
        local IdLabel               = Instance.new("TextLabel", Fila)
        IdLabel.Size                = UDim2.new(0, 130, 1, 0)
        IdLabel.Position            = UDim2.new(0, 220, 0, 0)
        IdLabel.BackgroundTransparency = 1
        IdLabel.Text                = "ID: " .. tostring(id)
        IdLabel.Font                = Enum.Font.Code
        IdLabel.TextColor3          = Color3.fromRGB(70, 90, 130)
        IdLabel.TextSize            = 11
        IdLabel.TextXAlignment      = Enum.TextXAlignment.Left
        IdLabel.ZIndex              = 6

        -- Botón copiar
        local CopyBtn               = Instance.new("TextButton", Fila)
        CopyBtn.Size                = UDim2.new(0, 30, 0, 24)
        CopyBtn.Position            = UDim2.new(1, -74, 0, 6)
        CopyBtn.BackgroundColor3    = Color3.fromRGB(18, 24, 40)
        CopyBtn.Text                = "📋"
        CopyBtn.Font                = Enum.Font.GothamBold
        CopyBtn.TextColor3          = Color3.fromRGB(0, 180, 255)
        CopyBtn.TextSize            = 11
        CopyBtn.BorderSizePixel     = 0
        CopyBtn.ZIndex              = 6
        Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 5)

        CopyBtn.MouseEnter:Connect(function()
            TweenService:Create(CopyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
        end)
        CopyBtn.MouseLeave:Connect(function()
            if CopyBtn.Text == "📋" then
                TweenService:Create(CopyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 24, 40)}):Play()
            end
        end)
        CopyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(tostring(id))
                CopyBtn.Text = "✅"
                CopyBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 55)
                mostrarNotificacionXeno("ID copiado con éxito")
                task.delay(1.3, function()
                    CopyBtn.Text = "📋"
                    TweenService:Create(CopyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 24, 40)}):Play()
                end)
            else
                mostrarNotificacionXeno("Tu ejecutor no soporta copiar")
            end
        end)

        -- Botón borrar
        local DelBtn                = Instance.new("TextButton", Fila)
        DelBtn.Size                 = UDim2.new(0, 30, 0, 24)
        DelBtn.Position             = UDim2.new(1, -40, 0, 6)
        DelBtn.BackgroundColor3     = Color3.fromRGB(35, 16, 18)
        DelBtn.Text                 = "-"
        DelBtn.Font                 = Enum.Font.GothamBold
        DelBtn.TextColor3           = Color3.fromRGB(220, 70, 70)
        DelBtn.TextSize             = 11
        DelBtn.BorderSizePixel      = 0
        DelBtn.ZIndex               = 6
        Instance.new("UICorner", DelBtn).CornerRadius = UDim.new(0, 5)

        DelBtn.MouseEnter:Connect(function()
            TweenService:Create(DelBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(140, 30, 30), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)
        DelBtn.MouseLeave:Connect(function()
            TweenService:Create(DelBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 16, 18), TextColor3 = Color3.fromRGB(220, 70, 70)}):Play()
        end)
        DelBtn.MouseButton1Click:Connect(function()
            local char = localPlayer.Character
            if char then
                local acc = char:FindFirstChild("AccesorioForzado_" .. id)
                if acc then acc:Destroy() end
            end
            -- Eliminar por ID (no por índice)
            for i, d in ipairs(ACCESORIOS_IDS) do
                if d.id == id then table.remove(ACCESORIOS_IDS, i) break end
            end
            guardarAccesorios()
            actualizarListaVisual()
        end)
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 8)
end

-- Búsqueda en tiempo real
SearchBox:GetPropertyChangedSignal("Text"):Connect(actualizarListaVisual)

-- ============================================================
-- BOTÓN AÑADIR
-- ============================================================
AddBtn.MouseButton1Click:Connect(function()
    local text = InputBox.Text:gsub("%s+", "")
    local id   = tonumber(text)
    if id then
        table.insert(ACCESORIOS_IDS, {id = id, nombre = "Nuevo Accesorio"})
        guardarAccesorios()
        actualizarListaVisual()
        forzarAccesorioPorID(id)
        InputBox.Text = ""
    else
        InputBox.Text = "  ¡ID Inválida!"
        task.wait(1.5)
        InputBox.Text = ""
    end
end)

AddBtn.MouseEnter:Connect(function()
    TweenService:Create(AddBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}):Play()
end)
AddBtn.MouseLeave:Connect(function()
    TweenService:Create(AddBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
end)

-- ============================================================
-- BOTÓN LINK
-- ============================================================
LinkBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://www.tiktok.com/@tizi8776")
        LinkBtn.Text = "✅"
        task.wait(1.5)
        LinkBtn.Text = "🔗"
    else
        LinkBtn.Text = "❌"
        task.wait(1.5)
        LinkBtn.Text = "🔗"
    end
end)
LinkBtn.MouseEnter:Connect(function()
    TweenService:Create(LinkBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 28, 48)}):Play()
end)
LinkBtn.MouseLeave:Connect(function()
    TweenService:Create(LinkBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(16, 20, 34)}):Play()
end)

-- ============================================================
-- CERRAR
-- ============================================================
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(180, 40, 40)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(50, 30, 30)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    snowConnection:Disconnect()
    ScreenGui:Destroy()
end)

-- ============================================================
-- ARRASTRAR
-- ============================================================
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================================
-- TOGGLE CTRL
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if UserInputService:IsKeyDown(Enum.KeyCode.C) or UserInputService:IsKeyDown(Enum.KeyCode.V) then return end
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================================
-- SPAWN → RE-APLICAR
-- ============================================================
local function aplicarTodo()
    for _, datos in ipairs(ACCESORIOS_IDS) do
        task.spawn(function() forzarAccesorioPorID(datos.id) end)
    end
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    aplicarTodo()
end)

-- ============================================================
-- INICIO
-- ============================================================
actualizarListaVisual()
aplicarTodo()
task.delay(3, function()
    mostrarNotificacionXeno("Ctrl izquierdo para ocultar/mostrar")
end)

mostrarNotificacionXeno("❄  Zx ejecutado con éxito 🇦🇷")
