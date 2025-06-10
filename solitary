local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Backpack = Player.Backpack

local GameEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Event")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lolz59/library/refs/heads/main/ice.lua"))()

local Menu = library.new("Trench war UI")

local states = {
	SpawnRate = 200,
	HitboxEnabled = false,
	HitboxSize = 2,
	Nametags = false,
	Highlight = false,
	Multiplier = 0,
	DmgAll = false,
	HealAll = false,
	TrollTarget = nil,
	HealTroll = false,
	DmgTroll = false,
	KillTroll = false,
	MortarAim = false,
	Rave = false,
}

function DamagePlayer(Target: Player, Amount: number)
	if Target.Character and Target.Character:FindFirstChildWhichIsA("Humanoid") then
		local tool = Player.Character:FindFirstChildWhichIsA("Tool")
		
		if tool and tool:FindFirstChild("RemoteEvent") then
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

Guns:CreateSlider("Damage mutliplier", 100, function(value)
	states.Multiplier = value
end)

Guns:CreateSlider("Spawn rate (ms)", 2000, function(value)
	states.SpawnRate = value
end)

Guns:CreateButton("Get sniper", function()
	GetGun("Sniper")
end)

Guns:CreateButton("Get thompson", function()
	GetGun("Thompson")
end)

Guns:CreateButton("Get MG", function()
	GetGun("Machine Gun")
end)

Guns:CreateButton("Get mortar", function()
	GetGun("Mortar")
end)

Guns:CreateButton("Get rifle", function()
	GetGun("M1Garand")
end)

Guns:CreateToggle("Mortar aimbot", function(enabled)
	states.MortarAim = enabled
end)

Guns:CreateToggle("Rave", function(enabled)
	states.Rave = enabled
end)

--

local Server = Menu:CreateSection("Server")

Server:CreateSlider("Walkspeed", 100, function(value)
	Player.Character.Humanoid.WalkSpeed = value
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
	states.DmgAll = enabled
end)

--

local Target = Menu:CreateSection("Target")

local TargetLabel = Target:CreateTextLabel("Targeting: none")

Target:CreateTextBox("Username", "Target", function(input)
	local inputLower = input:lower()
	local matchedPlayer = nil

	-- Search for the first player whose name starts with the input
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Player and player.Name:lower():sub(1, #inputLower) == inputLower then
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
		for i = 1, 100  do
			GameEvent:FireServer("BanHacker", {states.TrollTarget})
		end
	end
end)

Target:CreateButton("View target", function()
	if states.TrollTarget then
		local char = states.TrollTarget.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
			if hrp then
				workspace.CurrentCamera.CameraSubject = hrp
			end
		end
	end
end)

Target:CreateButton("Stop viewing", function()
	workspace.CurrentCamera.CameraSubject = Player.Character and Player.Character:FindFirstChild("Humanoid")
		or workspace.CurrentCamera
end)

--

local Hitbox = Menu:CreateSection("Hitbox")

Hitbox:CreateToggle("Hitbox enabled", function(enabled)
	states.HitboxEnabled = enabled
end)

Hitbox:CreateSlider("Hitbox size", 100, function(value)
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

RunService.RenderStepped:Connect(function()
	if states.Rave and Player.Character then
		local g = Players:GetPlayers()
		local p: Player = Players[math.random(1, #Players)]
		
		local tool = Player.Character:FindFirstChildWhichIsA("Tool")

		if tool and tool:FindFirstChild("RemoteEvent") and p.Character then
			local targetpos = p.Character.PrimaryPart.Position
			local start = Vector3.new(0, 100, 0)
			local length = (start - targetpos).Magnitude
			tool.RemoteEvent:FireServer(p.Character.Humanoid, -1, {length, CFrame.new(start, targetpos) * CFrame.new(0, 0, -length / 2)})
		end
	end
	
	for _, enemy in ipairs(Players:GetPlayers()) do
		if enemy ~= Player and enemy.Team ~= Player.Team then
			local character = enemy.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			local hrp = character and character:FindFirstChild("HumanoidRootPart")

			if character and humanoid and humanoid.Health > 0 and hrp then
				-- Hitbox
				if states.HitboxEnabled then
					hrp.Size = Vector3.one * states.HitboxSize
					hrp.Transparency = 0.5
					hrp.CanCollide = false
				else
					hrp.Size = Vector3.one * 2
					hrp.Transparency = 1
					hrp.CanCollide = false
				end

				-- ESP cache setup
				espCache[enemy] = espCache[enemy] or {}

				-- Nametag
				if states.Nametags then
					if not espCache[enemy].billboard then
						local bb = Instance.new("BillboardGui")
						bb.AlwaysOnTop = true
						bb.Size = UDim2.new(0, 100, 0, 20)
						bb.StudsOffset = Vector3.new(0, 5, 0)

						local label = Instance.new("TextLabel", bb)
						label.Size = UDim2.new(1, 0, 1, 0)
						label.BackgroundTransparency = 1
						label.Text = enemy.DisplayName
						label.TextColor3 = Color3.new(1, 0, 0)
						label.TextStrokeTransparency = 0
						label.TextScaled = true
						label.Font = Enum.Font.SourceSansBold
						
						espCache[enemy].billboard = bb
					end
					
					espCache[enemy].billboard.Adornee = hrp
					espCache[enemy].billboard.Parent = character
					
				elseif espCache[enemy].billboard then
					espCache[enemy].billboard:Destroy()
					espCache[enemy].billboard = nil
				end

				-- Highlight
				if states.Highlight then
					if not espCache[enemy].highlight then
						local hl = Instance.new("Highlight")
						hl.Name = "EnemyHighlight"
						hl.FillTransparency = 1
						hl.OutlineColor = Color3.new(1, 0, 0)
						espCache[enemy].highlight = hl
					end
					
					espCache[enemy].highlight.Adornee = character
					espCache[enemy].highlight.Parent = character
					
				elseif espCache[enemy].highlight then
					espCache[enemy].highlight:Destroy()
					espCache[enemy].highlight = nil
				end

			else
				-- Cleanup if dead or missing parts
				if espCache[enemy] then
					if espCache[enemy].billboard then espCache[enemy].billboard:Destroy() end
					if espCache[enemy].highlight then espCache[enemy].highlight:Destroy() end
					espCache[enemy] = nil
				end
				
				if hrp then
					hrp.Size = Vector3.one
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		if states.DmgAll or states.HealAll and not (states.DmgAll and states.HealAll) then
			for i, player in pairs(Players:GetPlayers()) do
				if player ~= Player and player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
					local dmg = if states.DmgAll then math.max(0, player.Character.Humanoid.Health - 2) else -100

					DamagePlayer(player, dmg)
				end
			end
		end
		
		if states.TrollTarget and states.TrollTarget.Character then
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
		
		if states.MortarAim then
			if Player.Character:FindFirstChild("Mortar") then
				Player.Character.Mortar.RemoteEvent:FireServer(Player:GetMouse().Hit.Position)
			end
		end

		task.wait(0.2)
	end
end)

--

local MT = getrawmetatable(game)
local Old = MT.__namecall
setreadonly(MT, false)

MT.__namecall = newcclosure(function(Remote, ...) 
	local Args = {...}
	local Method = getnamecallmethod()

	if Remote.Name == "RemoteEvent" and Method == "FireServer" then
		if Args[2] ~= nil and typeof(Args[2]) == "number" then
			local Multiplier = tonumber(states.Multiplier)

			if Multiplier ~= nil then
				Args[2] *= Multiplier

				Remote[Method](Remote, unpack(Args))
			end
		end
	end

	return Old(Remote, ...)
end)
setreadonly(MT, true)
--]]
