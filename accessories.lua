local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

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
        {id = 10159600649, nombre = "Pon un nombre"},
        {id = 73968717744720, nombre = "Pon un nombre"}
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
ScreenGui.Name = "AccManagerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "ACCESORIOS"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0, 340, 0, 210)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.Parent = ScrollFrame

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0, 240, 0, 30)
InputBox.Position = UDim2.new(0, 10, 0, 265)
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.Text = ""
InputBox.PlaceholderText = "Pegar ID de Accesorio aquí..."
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 12
InputBox.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = InputBox

local AddBtn = Instance.new("TextButton")
AddBtn.Size = UDim2.new(0, 90, 0, 30)
AddBtn.Position = UDim2.new(0, 260, 0, 265)
AddBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
AddBtn.Text = "Añadir"
AddBtn.Font = Enum.Font.GothamBold
AddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddBtn.TextSize = 13
AddBtn.Parent = MainFrame

local AddCorner = Instance.new("UICorner")
AddCorner.CornerRadius = UDim.new(0, 5)
AddCorner.Parent = AddBtn

local function actualizarListaVisual()
    for _, item in ipairs(ScrollFrame:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    
    for idx, datos in ipairs(ACCESORIOS_IDS) do
        local Fila = Instance.new("Frame")
        Fila.Size = UDim2.new(1, -5, 0, 30)
        Fila.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        Fila.BorderSizePixel = 0
        Fila.Parent = ScrollFrame
        
        local FilaCorner = Instance.new("UICorner")
        FilaCorner.CornerRadius = UDim.new(0, 4)
        FilaCorner.Parent = Fila
        
        local NomInput = Instance.new("TextBox")
        NomInput.Size = UDim2.new(0, 130, 1, 0)
        NomInput.Position = UDim2.new(0, 8, 0, 0)
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
        IdLabel.Size = UDim2.new(0, 130, 1, 0)
        IdLabel.Position = UDim2.new(0, 145, 0, 0)
        IdLabel.BackgroundTransparency = 1
        IdLabel.Text = tostring(datos.id)
        IdLabel.Font = Enum.Font.Code
        IdLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        IdLabel.TextSize = 11
        IdLabel.TextXAlignment = Enum.TextXAlignment.Left
        IdLabel.Parent = Fila
        
        local BorrarBtn = Instance.new("TextButton")
        BorrarBtn.Size = UDim2.new(0, 26, 0, 22)
        BorrarBtn.Position = UDim2.new(1, -32, 0, 4)
        BorrarBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BorrarBtn.Text = "-"
        BorrarBtn.Font = Enum.Font.GothamBold
        BorrarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BorrarBtn.TextSize = 14
        BorrarBtn.Parent = Fila
        
        local BorrarCorner = Instance.new("UICorner")
        BorrarCorner.CornerRadius = UDim.new(0, 4)
        BorrarCorner.Parent = BorrarBtn
        
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
        table.insert(ACCESORIOS_IDS, {id = id, nombre = "Pon un nombre"})
        guardarAccesorios()
        actualizarListaVisual()
        forzarAccesorioPorID(id)
        InputBox.Text = ""
    else
        InputBox.Text = "¡ID Inválida!"
        task.wait(1.5)
        InputBox.Text = ""
    end
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
