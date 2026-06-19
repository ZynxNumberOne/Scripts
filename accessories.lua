-- Acción del Botón de Link (Abre directo en el navegador tipo Delta)
LinkBtn.MouseButton1Click:Connect(function()
    local miEnlace = "https://discord.gg/tu-invitacion" -- CAMBIÁ ESTO por tu link real
    
    -- Detectamos si el executor tiene la función para abrir links externos
    local requestFunc = syn and syn.request or http_request or request
    
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = miEnlace,
                Method = "GET"
            })
        end)
        LinkBtn.Text = "🚀" -- Icono de que ya se mandó al navegador
        task.wait(1.5)
        LinkBtn.Text = "🔗"
    elseif setclipboard then
        -- Plan B: Si el executor es viejo o no lo soporta, lo copia
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
