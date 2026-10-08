--// Player Teleport + Auto Reset GUI
--// LocalScript - StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
--// SETTINGS
local TELEPORT_DISTANCE = 3
local RESET_DELAY = 0.4
local selectedPlayer = nil
local enabled = false
--// GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "PlayerTeleportGUI"
Gui.ResetOnSpawn = false
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 400)
Main.Position = UDim2.new(0.5, -125, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0
Main.Parent = Gui
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main
--// TITLE / DRAG BAR
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Teleport Players"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title
--// SEARCH
local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -10, 0, 35)
Search.Position = UDim2.new(0, 5, 0, 45)
Search.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Search.PlaceholderText = "Search players..."
Search.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
Search.Text = ""
Search.TextColor3 = Color3.new(1, 1, 1)
Search.TextSize = 14
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main
local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = Search
--// ON/OFF BUTTON
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -10, 0, 35)
Toggle.Position = UDim2.new(0, 5, 0, 85)
Toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 15
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = Toggle
--// PLAYER LIST
local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -10, 1, -130)
List.Position = UDim2.new(0, 5, 0, 125)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.Parent = Main
local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.Parent = List
--// TOGGLE
Toggle.MouseButton1Click:Connect(function()
enabled = not enabled
if enabled then
Toggle.Text = "ON"
Toggle.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
else
Toggle.Text = "OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
end
end)
--// TELEPORT + RESET
local function teleportAndReset(player)
if not player or player == LocalPlayer then
return
end
local myCharacter = LocalPlayer.Character
local targetCharacter = player.Character
if not myCharacter or not targetCharacter then
return
end
local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
if not myRoot or not targetRoot then
return
end
-- Teleport in front
myRoot.CFrame =
targetRoot.CFrame * CFrame.new(0, 0, -TELEPORT_DISTANCE)
-- Wait
task.wait(RESET_DELAY)
-- Reset
local humanoid = myCharacter:FindFirstChildOfClass("Humanoid")
if humanoid then
humanoid.Health = 0
end
end
--// AUTOMATIC LOOP
task.spawn(function()
while true do
if enabled and selectedPlayer then
if selectedPlayer.Parent == Players then
teleportAndReset(selectedPlayer)
else
selectedPlayer = nil
end
end
task.wait()
end
end)
--// CREATE PLAYER BUTTONS
local function refreshPlayers()
for _, child in ipairs(List:GetChildren()) do
if child:IsA("TextButton") then
child:Destroy()
end
end
local searchText = Search.Text:lower()
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
local displayName = player.DisplayName:lower()
local username = player.Name:lower()
if searchText == ""
or displayName:find(searchText, 1, true)
or username:find(searchText, 1, true) then
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -5, 0, 38)
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.Text = player.DisplayName .. " @" .. player.Name
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 14
Button.Font = Enum.Font.Gotham
Button.Parent = List
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = Button
Button.MouseButton1Click:Connect(function()
selectedPlayer = player
-- Highlight selected player
for _, otherButton in ipairs(List:GetChildren()) do
if otherButton:IsA("TextButton") then
otherButton.BackgroundColor3 =
Color3.fromRGB(50, 50, 50)
end
end
Button.BackgroundColor3 =
Color3.fromRGB(70, 110, 180)
end)
end
end
end
List.CanvasSize = UDim2.new(
0,
0,
0,
Layout.AbsoluteContentSize.Y + 5
)
end
--// SEARCH
Search:GetPropertyChangedSignal("Text"):Connect(function()
refreshPlayers()
end)
--// PLAYER JOIN / LEAVE
Players.PlayerAdded:Connect(function()
refreshPlayers()
end)
Players.PlayerRemoving:Connect(function(player)
if player == selectedPlayer then
selectedPlayer = nil
end
refreshPlayers()
end)
refreshPlayers()
--// MOVABLE GUI
local dragging = false
local dragStart
local startPosition
Title.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPosition = Main.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
UserInputService.InputChanged:Connect(function(input)
if not dragging then
return
end
if input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch then
local delta = input.Position - dragStart
Main.Position = UDim2.new(
startPosition.X.Scale,
startPosition.X.Offset + delta.X,
startPosition.Y.Scale,
startPosition.Y.Offset + delta.Y
)
end
end)
