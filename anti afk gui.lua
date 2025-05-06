-- Удаление старого GUI, если уже существует
local player = game.Players.LocalPlayer
local oldGui = player:FindFirstChild("PlayerGui"):FindFirstChild("AntiAFKGui")
if oldGui then
    oldGui:Destroy()
end

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "AntiAFKGui"

-- Фрейм
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 140, 0, 70)
frame.Position = UDim2.new(0.05, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

-- Кнопка
local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0, 120, 0, 50)
button.Position = UDim2.new(0, 10, 0, 10)
button.Text = "Anti AFK: OFF"
button.BackgroundColor3 = Color3.new(1, 0, 0)

-- Перетаскивание GUI
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Включение / отключение Anti AFK
local antiAFKEnabled = false
button.MouseButton1Click:Connect(function()
	antiAFKEnabled = not antiAFKEnabled
	button.Text = antiAFKEnabled and "Anti AFK: ON" or "Anti AFK: OFF"
	button.BackgroundColor3 = antiAFKEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

-- Функция прыжка
local function jumpCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end

-- Цикл прыжков
task.spawn(function()
	while true do
		task.wait(5)
		if antiAFKEnabled then
			jumpCharacter()
		end
	end
end)
