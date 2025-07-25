local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Backpack = Player.Backpack

local GameEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Event")

local library = require(ReplicatedStorage.lib) --loadstring(game:HttpGet("https://raw.githubusercontent.com/lolz59/library/refs/heads/main/ice.lua"))()

local Menu = library.new("Trench war UI 650")

local states = {
	Multiplier = 1,
	SpawnRate = 200,
	WalkSpeed = 16,
	SilentAim = false,
	
	HitboxEnabled = false,
	HitboxSize = 8,
	Nametags = false,
	Highlight = false,
	
	DmgAll = false,
	HealAll = false,
	
	TrollTarget = nil,
	Viewing = nil,
	
	HealTroll = false,
	DmgTroll = false,
	KillTroll = false,
		
	MortarAim = false,
}

function DamagePlayer(Target: Player, Amount: number)
	if Target.Character and Target.Character:FindFirstChildWhichIsA("Humanoid") then
		local tool = Player.Character:FindFirstChildWhichIsA("Tool")
		
		if tool and tool:FindFirstChild("RemoteEvent") and tool.Name ~= "Mortar" then
			tool.RemoteEvent:FireServer(Target.Character.Humanoid, Amount, {1, CFrame.new()})
		end
	end
end

function GetGun(Name: string)
	local Character = Player.Character
	local Pos = Character.PrimaryPart.Position

	while not Player.Backpack:FindFirstChild(Name) do
		GameEvent:FireServer("Spawn", {[2] = Pos})
		if Player.Backpack:WaitForChild(Name, states.SpawnRate / 1000) then break end
	end

	Player.Character:PivotTo(CFrame.new(Pos))
end

--

local Guns = Menu:CreateSection("Guns")

Guns:CreateSlider("Damage mutliplier", 100, states.Multiplier, 1, function(value)
	states.Multiplier = value
end)

for _, name in ipairs({"Sniper", "Thompson", "Machine Gun", "Mortar", "M1Garand"}) do
	Guns:CreateButton("Get " .. name, function() GetGun(name) end)
end

Guns:CreateToggle("Mortar aimbot (WIP)", function(enabled)
	states.MortarAim = enabled
end)

--

local Deploy = Menu:CreateSection("Deploy")

local spawnPoints = {
	["Axis"] = -800,
	["A"] = -500,
	["B"] = -250,
	["C"] = 0,
	["D"] = 250,
	["E"] = 500,
	["Allies"] = 800
}

local function trySpawn(arg1)	
	GameEvent:FireServer("Spawn", {nil, Vector3.new(math.random(-163, 163), 90, spawnPoints[arg1])})
end

for name in pairs(spawnPoints) do
	Deploy:CreateButton(name, function()
		trySpawn(name)
	end)
end

--

local Server = Menu:CreateSection("Server")

Server:CreateSlider("Walkspeed", 100, states.WalkSpeed, 1, function(value)
	states.WalkSpeed = value
end)

Server:CreateButton("Kill all", function()
	for i, player in pairs(Players:GetPlayers()) do
		if player ~= Player and Player.Character then
			DamagePlayer(player, Player.Character.Humanoid.Health + 100)
		end
	end
end)

Server:CreateToggle("Heal all", function(enabled)
	states.HealAll = enabled
end)

Server:CreateToggle("Damage all", function(enabled)
	states.Multiplier = 0
	states.DmgAll = enabled
end)

--

local Target = Menu:CreateSection("Target")

local TargetLabel = Target:CreateTextLabel("Targeting: none")

Target:CreateTextBox("Username", "Target", function(input)
	local inputLower = input:lower()
	local matchedPlayer = nil

	for _, player in ipairs(Players:GetPlayers()) do
		local usernameMatch = player.Name:lower():sub(1, #inputLower) == inputLower
		local displayNameMatch = player.DisplayName:lower():sub(1, #inputLower) == inputLower

		if player ~= Player and (usernameMatch or displayNameMatch) then
			matchedPlayer = player
			break
		end
	end

	if matchedPlayer then
		TargetLabel.Text = "Targeting: " .. matchedPlayer.Name
		states.TrollTarget = matchedPlayer
	else
		TargetLabel.Text = "Targeting: none"
		states.TrollTarget = nil
	end
end)

Target:CreateToggle("Heal target", function(enabled)
	states.HealTroll = enabled
end)

Target:CreateToggle("Kill target", function(enabled)
	states.KillTroll = enabled
end)

Target:CreateToggle("Damage target", function(enabled)
	states.DmgTroll = enabled
end)

Target:CreateButton("View target", function()
	if states.TrollTarget then
		states.Viewing = states.TrollTarget
	end
end)

Target:CreateButton("Stop viewing", function()
	states.Viewing = nil
	
	workspace.CurrentCamera.CameraSubject = Player.Character and Player.Character:FindFirstChild("Humanoid")
		or workspace.CurrentCamera
end)

--

local Hitbox = Menu:CreateSection("Hitbox")

Hitbox:CreateToggle("Hitbox enabled", function(enabled)
	states.HitboxEnabled = enabled
end)

Hitbox:CreateSlider("Hitbox size", 100, states.HitboxSize, 1, function(value)
	states.HitboxSize = 1 + value
end)

Hitbox:CreateToggle("Nametags enabled", function(enabled)
	states.Nametags = enabled
end)

Hitbox:CreateToggle("Highlight enabled", function(enabled)
	states.Highlight = enabled
end)

--

local espCache = {}

local function destroyESP(player)
	local cache = espCache[player]
	if not cache then return end

	if cache.billboard then cache.billboard:Destroy() end
	if cache.highlight then cache.highlight:Destroy() end

	espCache[player] = nil
end

local function updateHitbox(hrp)
	if states.HitboxEnabled then
		hrp.Size = Vector3.one * states.HitboxSize
		hrp.Transparency = 0.5
	else
		hrp.Size = Vector3.one * 2
		hrp.Transparency = 1
	end
	hrp.CanCollide = false
end

local function createNametag(player, hrp, humanoid)
	local cache = espCache[player]
	if not cache.billboard then
		local bb = Instance.new("BillboardGui")
		bb.Name = "EnemyNametag"
		bb.AlwaysOnTop = true
		bb.Size = UDim2.new(0, 200, 0, 20)
		bb.SizeOffset = Vector2.new(0, 1)

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 0, 0)
		label.TextStrokeTransparency = 0
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = bb

		cache.billboard = bb
	end

	cache.billboard.Adornee = hrp
	cache.billboard.Parent = hrp
	cache.billboard.Label.Text = player.DisplayName .. " | " .. math.round(humanoid.Health) .. " HP"
end

local function createHighlight(player, character)
	local cache = espCache[player]
	if not cache.highlight then
		local hl = Instance.new("Highlight")
		hl.Name = "EnemyHighlight"
		hl.FillTransparency = 1
		hl.OutlineColor = Color3.new(1, 0, 0)
		cache.highlight = hl
	end

	cache.highlight.Adornee = character
	cache.highlight.Parent = character
end

-- main

RunService.RenderStepped:Connect(function()
	for _, enemy in ipairs(Players:GetPlayers()) do
		if enemy == Player then continue end

		local character = enemy.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		local hrp = character and character:FindFirstChild("HumanoidRootPart")

		local isEnemy = enemy.Team ~= Player.Team
		local isAlive = humanoid and humanoid.Health > 0

		espCache[enemy] = espCache[enemy] or {}

		if isEnemy and character and humanoid and hrp and isAlive then
			updateHitbox(hrp)

			if states.Nametags then
				createNametag(enemy, hrp, humanoid)
			else
				if espCache[enemy].billboard then
					espCache[enemy].billboard:Destroy()
					espCache[enemy].billboard = nil
				end
			end

			if states.Highlight then
				createHighlight(enemy, character)
			else
				if espCache[enemy].highlight then
					espCache[enemy].highlight:Destroy()
					espCache[enemy].highlight = nil
				end
			end

		else
			destroyESP(enemy)
			if hrp then
				hrp.Size = Vector3.one
				hrp.Transparency = 1
			end
		end
	end
	
	if Player.Character then
		Player.Character.Humanoid.WalkSpeed = states.WalkSpeed
	end
end)

--

task.spawn(function()
	while true do
		local succ, res = pcall(function()
			if states.DmgAll or states.HealAll and not (states.DmgAll and states.HealAll) then
				for i, player in pairs(Players:GetPlayers()) do
					if player ~= Player and player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
						local dmg = if states.DmgAll then math.max(0, player.Character.Humanoid.Health - 5) else -100

						DamagePlayer(player, dmg)
					end
				end
			end

			if states.TrollTarget and states.TrollTarget.Character then
				local char = states.TrollTarget.Character

				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
					if hrp then
						workspace.CurrentCamera.CameraSubject = hrp
					end
				end

				if states.HealTroll then
					local dmg = -100
					DamagePlayer(states.TrollTarget, dmg)
				elseif states.KillTroll then
					local dmg = states.TrollTarget.Character.Humanoid.Health + 100
					DamagePlayer(states.TrollTarget, dmg)
				elseif states.DmgTroll then
					local dmg = math.max(0, states.TrollTarget.Character.Humanoid.Health - 2)
					DamagePlayer(states.TrollTarget, dmg)
				end
			end
		end)
		
		if not succ then warn("354: " ..res) end

		task.wait(0.2)
	end
end)

--

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
	local args = { ... }
	local method = getnamecallmethod()

	if method == "FireServer" and self.Name == "RemoteEvent" then
		if typeof(args[2]) == "number" then
			local multiplier = tonumber(states.Multiplier)
			
			if multiplier then
				args[2] *= multiplier
			end
			
			if states.SilentAim then
				local origin = Player.Character.PrimaryPart.Position + Vector3.new(0, 10, 0)
				local hitpos = Vector3.new()
				
				local distance = (origin - hitpos).Magnitude
				local direction = CFrame.new(origin, hitpos) * CFrame.Angles(0, math.pi/2, 0) * CFrame.new(distance / 2, 0, 0)
				
				args[3] = {distance, direction}
			end
			
			return old(self, unpack(args))
		elseif typeof(args[1]) == "Vector3" and self.Parent and self.Parent.Name == "Mortar" then
			--args[1] *= multiplier
			return old(self, unpack(args))
		end
	end

	return old(self, ...)
end)

setreadonly(mt, true)

--]]
