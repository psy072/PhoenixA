-- Script principal Phoenix A hub
local UIModule = require(script.UIModule)
local ToggleModule = require(script.ToggleModule)
local DragModule = require(script.DragModule)

-- Criar UI
local frame, logoToggle = UIModule.init()

-- Ativar toggle
ToggleModule.init(frame, logoToggle)

-- Ativar drag
DragModule.init(frame)
DragModule.init(logoToggle)
