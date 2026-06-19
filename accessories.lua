local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("ZynxBlankEngine") then
    CoreGui.ZynxBlankEngine:Destroy()
end

local ARCHIVO_GUARDADO = "MisAccesoriosForzados.json"
local ACCESORIOS_IDS = {}

local function cargarAccesorios()
    if isfile and readfile and isfile(ARCHIVO_GUARDADO) then
        local exito, datos = pcall(function()
            return HttpService:JSONDecode(readfile(ARCHIVO_GUARDADO))
        end)
        if exito and datos then
            ACCESORIOS_IDS = datos
            return
        end
    end
    ACCESORIOS_IDS = {
        {id = 10159600649, nombre = "Accesorio Ejemplo 1"},
        {id = 139607718, nombre = "Korblox Right Leg"}
    }
end

local function guardarAccesorios()
    if writefile then
        pcall(function()
            writefile(ARCHIVO_GUARDADO, HttpService:JSONEncode(ACCESORIOS_IDS))
        end)
    end
end

local function forzarAccesorioPorID(id)
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    if character:FindFirstChild("AccesorioForzado_" .. id) then return end

    local exito, objetos = pcall(function()
        return game:GetObjects("rbxassetid://" .. id)
    end)
    
    if exito and objetos and #objetos > 0 then
        local asset = objetos[1]
        local accesorio = asset:IsA("Accessory") and asset or asset:FindFirstChildOfClass("Accessory")
        
        if accesorio then
            local handle = accesorio:FindFirstChild("Handle") or accesorio:FindFirstChild("handle")
            if handle then
                local clon = accesorio:Clone()
                clon.Name = "AccesorioForzado_" .. id
                local clonHandle = clon:FindFirstChild("Handle") or clon:FindFirstChild("handle")
                
                local attachmentAccesorio = clonHandle:FindFirstChildOfClass("Attachment")
                local parteCuerpoObjetivo = character:FindFirstChild("Head")
                
                if attachmentAccesorio then
                    local attachmentCuerpo = character:FindFirstChild(attachmentAccesorio.Name, true)
                    if attachmentCuerpo and attachmentCuerpo.Parent then
                        parteCuerpoObjetivo = attachmentCuerpo.Parent
                    end
                end
                
                pcall(function() clon:RemoveCharacterAssociations() end)
                for _, v in ipairs(clonHandle:GetChildren()) do
                    if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("WeldConstraint") then
                        v:Destroy()
                    end
                end
                
                clon.Parent = character
                
                local weld = Instance.new("Weld")
                weld.Name = "WeldForzado_" .. id
                weld.Part0 = clonHandle
                weld.Part1 = parteCuerpoObjetivo
                
                if attachmentAccesorio and character:FindFirstChild(attachmentAccesorio.Name, true) then
                    local attCuerpo = character:FindFirstChild(attachmentAccesorio.Name, true)
                    weld.C0 = attachmentAccesorio.CFrame
                    weld.C1 = attCuerpo.CFrame
                else
                    weld.C0 = CFrame.new(0, -0.6, 0)
                end
                
                weld.Parent = clonHandle
            end
        end
    end
end

cargarAccesorios()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZynxBlankEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local GlowBar = Instance.new("Frame")
GlowBar.Name = "GlowBar"
GlowBar.Size = UDim2.new(1, 0, 0, 3)
GlowBar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
GlowBar.BorderSizePixel = 0
GlowBar.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ZYNX // V2.0"
Title.TextColor3 = Color3.fromRGB(0, 180, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X" 
CloseBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
CloseBtn.TextSize = 13 
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -30, 1, -100)
ContentFrame.Position = UDim2.new(0, 15, 0, 45)
ContentFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -16, 1, -16)
ScrollFrame.Position = UDim2.new(0, 8, 0, 8)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
ScrollFrame.Parent = ContentFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.Parent = ScrollFrame

-- Movimos y achicamos la InputBox para que entre el nuevo botón de link
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0, 295, 0, 36)
InputBox.Position = UDim2.new(0, 15, 1, -46)
InputBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.Text = ""
InputBox.PlaceholderText = "  Pegar ID de Accesorio aquí..."
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 12
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = InputBox

-- Botón de Enlace / Discord (Nuevo)
local LinkBtn = Instance.new("TextButton")
LinkBtn.Name = "LinkBtn"
LinkBtn.Size = UDim2.new(0, 40, 0, 36)
LinkBtn.Position = UDim2.new(0, 320, 1, -46)
LinkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
LinkBtn.Text = "🔗" -- Usamos emoji clásico que Roblox lee perfecto
LinkBtn.Font = Enum.Font.GothamBold
LinkBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
LinkBtn.TextSize = 14
LinkBtn.Parent = MainFrame

local LinkCorner = Instance.new("UICorner")
LinkCorner.CornerRadius = UDim.new(0, 6)
LinkCorner.Parent = LinkBtn

local AddBtn = Instance.new("TextButton")
AddBtn.Size = UDim2.new(0, 135, 0, 36)
AddBtn.Position = UDim2.new(0, 370, 0, 314)
AddBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
AddBtn.Text = "Añadir Ítem"
AddBtn.Font = Enum.Font.GothamBold
AddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddBtn.TextSize = 13
AddBtn.Parent = MainFrame

local AddCorner = Instance.new("UICorner")
AddCorner.CornerRadius = UDim.new(0, 6)
AddCorner.Parent = AddBtn

local function actualizarListaVisual()
    for _, item in ipairs(ScrollFrame:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    
    for idx, datos in ipairs(ACCESORIOS_IDS) do
        local Fila = Instance.new("Frame")
        Fila.Size = UDim2.new(1, -5, 0, 34)
        Fila.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        Fila.BorderSizePixel = 0
        Fila.Parent = ScrollFrame
        
        local FilaCorner = Instance.new("UICorner")
        FilaCorner.CornerRadius = UDim.new(0, 5)
        FilaCorner.Parent = Fila
        
        local NomInput = Instance.new("TextBox")
        NomInput.Size = UDim2.new(0, 220, 1, 0)
        NomInput.Position = UDim2.new(0, 12, 0, 0)
        NomInput.BackgroundTransparency = 1
        NomInput.Text = datos.nombre
        NomInput.Font = Enum.Font.GothamMedium
        NomInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        NomInput.TextSize = 12
        NomInput.TextXAlignment = Enum.TextXAlignment.Left
        NomInput.Parent = Fila
        
        NomInput.FocusLost:Connect(function(enterPressed)
            datos.nombre = NomInput.Text
            guardarAccesorios()
        end)
        
        local IdLabel = Instance.new("TextLabel")
        IdLabel.Size = UDim2.new(0, 150, 1, 0)
        IdLabel.Position = UDim2.new(0, 250, 0, 0)
        IdLabel.BackgroundTransparency = 1
        IdLabel.Text = "ID: " .. tostring(datos.id)
        IdLabel.Font = Enum.Font.Code
        IdLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
        IdLabel.TextSize = 11
        IdLabel.TextXAlignment = Enum.TextXAlignment.Left
        IdLabel.Parent = Fila
        
        local BorrarBtn = Instance.new("TextButton")
        BorrarBtn.Name = "BorrarBtn"
        BorrarBtn.Size = UDim2.new(0, 32, 0, 24)
        BorrarBtn.Position = UDim2.new(1, -40, 0, 5)
        BorrarBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
        BorrarBtn.Text = "x" 
        BorrarBtn.Font = Enum.Font.GothamBold
        BorrarBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        BorrarBtn.TextSize = 11 
        BorrarBtn.Parent = Fila
        
        local BorrarCorner = Instance.new("UICorner")
        BorrarCorner.CornerRadius = UDim.new(0, 4)
        BorrarCorner.Parent = BorrarBtn
        
        BorrarBtn.MouseEnter:Connect(function()
            TweenService:Create(BorrarBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(180, 40, 40), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)
        BorrarBtn.MouseLeave:Connect(function()
            TweenService:Create(BorrarBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 30, 35), TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
        end)
        
        BorrarBtn.MouseButton1Click:Connect(function()
            local char = localPlayer.Character
            if char then
                local acc = char:FindFirstChild("AccesorioForzado_" .. datos.id)
                if acc then acc:Destroy() end
            end
            
            table.remove(ACCESORIOS_IDS, idx)
            guardarAccesorios()
            actualizarListaVisual()
        end)
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

AddBtn.MouseButton1Click:Connect(function()
    local text = InputBox.Text:gsub("%s+", "")
    local id = tonumber(text)
    
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
    TweenService:Create(AddBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 160, 255)}):Play()
end)
AddBtn.MouseLeave:Connect(function()
    TweenService:Create(AddBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 130, 230)}):Play()
end)

-- Acción del Botón de Link (Copia al portapapeles)
LinkBtn.MouseButton1Click:Connect(function()
    local miEnlace = "https://www.tiktok.com/@tizi8776" -- CAMBIÁ ESTO por tu link real
    
    if setclipboard then
        setclipboard(miEnlace)
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
    TweenService:Create(LinkBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
end)
LinkBtn.MouseLeave:Connect(function()
    TweenService:Create(LinkBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
end)

local function aplicarTodo()
    for _, datos in ipairs(ACCESORIOS_IDS) do
        task.spawn(function()
            forzarAccesorioPorID(datos.id)
        end)
    end
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    aplicarTodo()
end)

actualizarListaVisual()
aplicarTodo()

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X, 
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
        update(input)
    end
end)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 96, 92)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(120, 120, 130)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if UserInputService:IsKeyDown(Enum.KeyCode.C) or UserInputService:IsKeyDown(Enum.KeyCode.V) then 
            return 
        end
        MainFrame.Visible = not MainFrame.Visible
    end
end)
