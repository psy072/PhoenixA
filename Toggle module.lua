local module = {}

function module.init(frame, logoToggle)
    local uiVisible = true
    logoToggle.MouseButton1Click:Connect(function()
        uiVisible = not uiVisible
        frame.Visible = uiVisible
    end)
end

return module
