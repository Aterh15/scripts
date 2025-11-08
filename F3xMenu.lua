local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local selectedPart = nil
local currentMode = "Select"
local clipboard = nil
local dragConnection = nil
local rotateSnap = 15
local moveSnap = 1
local scaleSnap = 1

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "F3X_BuilderGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.BorderSizePixel = 0
Title.Text = "F3X Building Tools"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local ButtonsFrame = Instance.new("ScrollingFrame")
ButtonsFrame.Size = UDim2.new(1, -20, 1, -50)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 45)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.BorderSizePixel = 0
ButtonsFrame.ScrollBarThickness = 6
ButtonsFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ButtonsFrame.Parent = MainFrame

local function createButton(name, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 150, 0, 35)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = ButtonsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    return button
end

local yOffset = 0
local function createSection(title)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.new(0, 5, 0, yOffset)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ButtonsFrame
    
    yOffset = yOffset + 30
end

local function selectPart(part)
    if selectedPart and selectedPart:FindFirstChild("SelectionBox") then
        selectedPart.SelectionBox:Destroy()
    end
    
    if part and part:IsA("BasePart") then
        selectedPart = part
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "SelectionBox"
        selectionBox.Adornee = part
        selectionBox.Color3 = Color3.fromRGB(0, 170, 255)
        selectionBox.LineThickness = 0.05
        selectionBox.Parent = part
        
        print("[Builder] Selected object: " .. part.Name)
    end
end

createSection("SELECTION")

createButton("SelectButton", "Select Part", UDim2.new(0, 5, 0, yOffset), function()
    currentMode = "Select"
    print("[Builder] Mode: Select part. Click on an object.")
end)
yOffset = yOffset + 40

createButton("DeselectButton", "Deselect", UDim2.new(0, 165, 0, yOffset - 40), function()
    if selectedPart and selectedPart:FindFirstChild("SelectionBox") then
        selectedPart.SelectionBox:Destroy()
    end
    selectedPart = nil
    print("[Builder] Selection cleared")
end)

createSection("CREATE")

local partTypes = {
    {name = "Block", text = "Block"},
    {name = "Sphere", text = "Sphere"},
    {name = "Cylinder", text = "Cylinder"},
    {name = "Wedge", text = "Wedge"}
}

for i, partType in ipairs(partTypes) do
    local xPos = ((i - 1) % 2) * 160 + 5
    if (i - 1) % 2 == 0 and i > 1 then
        yOffset = yOffset + 40
    end
    
    createButton("Create" .. partType.name, partType.text, UDim2.new(0, xPos, 0, yOffset), function()
        local part = Instance.new("Part")
        part.Size = Vector3.new(4, 4, 4)
        part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, -10)
        part.Anchored = true
        part.BrickColor = BrickColor.Random()
        
        if partType.name == "Sphere" then
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.Sphere
            mesh.Parent = part
        elseif partType.name == "Cylinder" then
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.Cylinder
            mesh.Parent = part
        elseif partType.name == "Wedge" then
            part:Destroy()
            part = Instance.new("WedgePart")
            part.Size = Vector3.new(4, 4, 4)
            part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, -10)
            part.Anchored = true
            part.BrickColor = BrickColor.Random()
        end
        
        part.Parent = workspace
        selectPart(part)
        print("[Builder] Created: " .. partType.name)
    end)
end
yOffset = yOffset + 40

createSection("EDIT")

createButton("MoveButton", "Move", UDim2.new(0, 5, 0, yOffset), function()
    if not selectedPart then
        print("[Builder] Select an object first!")
        return
    end
    currentMode = "Move"
    print("[Builder] Mode: Move. Use: W/A/S/D/Q/E")
end)

createButton("RotateButton", "Rotate", UDim2.new(0, 165, 0, yOffset), function()
    if not selectedPart then
        print("[Builder] Select an object first!")
        return
    end
    currentMode = "Rotate"
    print("[Builder] Mode: Rotate. Use: R/T (X), F/G (Y), Z/X (Z)")
end)
yOffset = yOffset + 40

createButton("ScaleUpButton", "Scale Up", UDim2.new(0, 5, 0, yOffset), function()
    if selectedPart then
        selectedPart.Size = selectedPart.Size + Vector3.new(1, 1, 1)
        print("[Builder] Size increased")
    end
end)

createButton("ScaleDownButton", "Scale Down", UDim2.new(0, 165, 0, yOffset), function()
    if selectedPart and selectedPart.Size.X > 1 then
        selectedPart.Size = selectedPart.Size - Vector3.new(1, 1, 1)
        print("[Builder] Size decreased")
    end
end)
yOffset = yOffset + 40

createSection("CLIPBOARD")

createButton("CopyButton", "Copy", UDim2.new(0, 5, 0, yOffset), function()
    if selectedPart then
        clipboard = selectedPart:Clone()
        print("[Builder] Object copied")
    end
end)

createButton("PasteButton", "Paste", UDim2.new(0, 165, 0, yOffset), function()
    if clipboard then
        local newPart = clipboard:Clone()
        newPart.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, -10)
        newPart.Parent = workspace
        selectPart(newPart)
        print("[Builder] Object pasted")
    end
end)
yOffset = yOffset + 40

createButton("DeleteButton", "Delete", UDim2.new(0, 5, 0, yOffset), function()
    if selectedPart then
        selectedPart:Destroy()
        selectedPart = nil
        print("[Builder] Object deleted")
    end
end)

createButton("DuplicateButton", "Duplicate", UDim2.new(0, 165, 0, yOffset), function()
    if selectedPart then
        local clone = selectedPart:Clone()
        clone.Position = selectedPart.Position + Vector3.new(5, 0, 0)
        clone.Parent = workspace
        selectPart(clone)
        print("[Builder] Object duplicated")
    end
end)
yOffset = yOffset + 40

createSection("PROPERTIES")

createButton("ColorButton", "Color", UDim2.new(0, 5, 0, yOffset), function()
    if selectedPart then
        selectedPart.BrickColor = BrickColor.Random()
        print("[Builder] Color changed")
    end
end)

createButton("MaterialButton", "Material", UDim2.new(0, 165, 0, yOffset), function()
    if selectedPart then
        local materials = {
            Enum.Material.Plastic,
            Enum.Material.Wood,
            Enum.Material.Slate,
            Enum.Material.Concrete,
            Enum.Material.Metal,
            Enum.Material.Glass,
            Enum.Material.Neon,
            Enum.Material.Marble
        }
        selectedPart.Material = materials[math.random(1, #materials)]
        print("[Builder] Material changed")
    end
end)
yOffset = yOffset + 40

createButton("AnchorButton", "Anchor ON/OFF", UDim2.new(0, 5, 0, yOffset), function()
    if selectedPart then
        selectedPart.Anchored = not selectedPart.Anchored
        print("[Builder] Anchor: " .. tostring(selectedPart.Anchored))
    end
end)

createButton("TransparencyButton", "Transparency", UDim2.new(0, 165, 0, yOffset), function()
    if selectedPart then
        selectedPart.Transparency = selectedPart.Transparency == 0 and 0.5 or 0
        print("[Builder] Transparency: " .. selectedPart.Transparency)
    end
end)
yOffset = yOffset + 40

createButton("CollisionButton", "Collision ON/OFF", UDim2.new(0, 5, 0, yOffset), function()
    if selectedPart then
        selectedPart.CanCollide = not selectedPart.CanCollide
        print("[Builder] Collision: " .. tostring(selectedPart.CanCollide))
    end
end)

Mouse.Button1Down:Connect(function()
    if currentMode == "Select" then
        local target = Mouse.Target
        if target and target:IsA("BasePart") then
            selectPart(target)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.End then
        ScreenGui.Enabled = not ScreenGui.Enabled
        print("[Builder] GUI toggled: " .. tostring(ScreenGui.Enabled))
        return
    end
    
    if gameProcessed or not selectedPart then return end
    
    local moveSpeed = moveSnap
    local rotateSpeed = rotateSnap
    
    if currentMode == "Move" then
        if input.KeyCode == Enum.KeyCode.W then
            selectedPart.Position = selectedPart.Position + Vector3.new(0, 0, -moveSpeed)
        elseif input.KeyCode == Enum.KeyCode.S then
            selectedPart.Position = selectedPart.Position + Vector3.new(0, 0, moveSpeed)
        elseif input.KeyCode == Enum.KeyCode.A then
            selectedPart.Position = selectedPart.Position + Vector3.new(-moveSpeed, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            selectedPart.Position = selectedPart.Position + Vector3.new(moveSpeed, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Q then
            selectedPart.Position = selectedPart.Position + Vector3.new(0, moveSpeed, 0)
        elseif input.KeyCode == Enum.KeyCode.E then
            selectedPart.Position = selectedPart.Position + Vector3.new(0, -moveSpeed, 0)
        end
    elseif currentMode == "Rotate" then
        if input.KeyCode == Enum.KeyCode.R then
            selectedPart.Orientation = selectedPart.Orientation + Vector3.new(rotateSpeed, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.T then
            selectedPart.Orientation = selectedPart.Orientation + Vector3.new(-rotateSpeed, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.F then
            selectedPart.Orientation = selectedPart.Orientation + Vector3.new(0, rotateSpeed, 0)
        elseif input.KeyCode == Enum.KeyCode.G then
            selectedPart.Orientation = selectedPart.Orientation + Vector3.new(0, -rotateSpeed, 0)
        elseif input.KeyCode == Enum.KeyCode.Z then
            selectedPart.Orientation = selectedPart.Orientation + Vector3.new(0, 0, rotateSpeed)
        elseif input.KeyCode == Enum.KeyCode.X then
            selectedPart.Orientation = selectedPart.Orientation + Vector3.new(0, 0, -rotateSpeed)
        end
    end
end)

local dragging = false
local dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    print("[Builder] GUI closed")
end)

wait(0.5)
print("[Builder] F3X Building Tools GUI loaded!")
print("[Builder] Press END key to toggle GUI")
ScreenGui.Enabled = true