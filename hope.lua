local Players=  game:GetService("Players")
local remote = game:GetService("ReplicatedStorage"):WaitForChild("WeaponsSystem"):WaitForChild("Network"):WaitForChild("WeaponHit")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lolz59/library/refs/heads/main/ice.lua"))()

local Menu = library.new("GGGUI")

local Enabled = false

local Main = Menu:CreateSection("Main")

Main:CreateToggle("Fire", function(toggled)
	Enabled = toggled
end)

while true do
	if Enabled then
		local succ, res = pcall(function()
			local weaponInstance = Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
			
			if not weaponInstance then return end

			for i, victim in ipairs(Players:GetPlayers()) do
				if victim ~= Players.LocalPlayer and victim.Character then
					local h = victim.Character:FindFirstChildWhichIsA()("Humanoid")
					if h and h.Health > 0 then
						local fakeHitInfo = {
							part = victim.Character.Head,
							h = h,
							p = victim.Character.Head.Position,
							n = Vector3.new(0, 1, 0),
							m = Enum.Material.DiamondPlate,
							d = 0.001,
							t = 0.5,
							maxDist = 9999
						}

						remote:FireServer(weaponInstance, fakeHitInfo)
					end
				end
			end
		end)
		
		if not succ then warn(res) end
	end
	
	task.wait(.1)
end
