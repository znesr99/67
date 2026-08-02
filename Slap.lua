if not getgenv().Config then
	getgenv().Config = {
		Hop = {
			["Time Hop"] = 120, -- เวลาวินาทีที่จะย้ายเซิฟ
			["HopServer"] = false, -- ย้ายเซิฟ (true เปิด / false ปิด)
		},
		Hitbox = {
			["HitBox Size"] = 30, -- ขนาดของ Hitbox
			["Enabled Hitbox"] = false, -- เปิด Hitbox (true เปิด / false ปิด)
		},
		Main = {
			["Auto Teleport Attack"] = false, -- ฟามคน (true เปิด / false ปิด)
		}
	}
end


local PlayersService = game:GetService("Players")
local LocalPlayer = PlayersService.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local NameMap = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

local WindUI = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()


local Window = WindUI:CreateWindow({
	Title = "MarvenRiz X Hub",
	Icon = "rbxassetid://87526284179554",
	Author = "Map : "..NameMap,
	Folder = "MarvenRizX",
	Size = UDim2.fromOffset(360,410),
	Theme = "Dark",
	Resizable = true,
	IconSize = 60,
	HideSearchBar = true,
	ScrollBarEnabled = false,
})


local Tab = Window:Tab({
	Title = "Auto Farm",
	Border = true
})


local Main = Tab:Section({
	Title = "| Main"
})

local Hitbox = Tab:Section({
	Title = "| Hitbox"
})

local Hop = Tab:Section({
	Title = "| Hop Server"
})


Main:Toggle({
	Title = "Auto Attack Players",
	Default = getgenv().Config.Main["Auto Teleport Attack"],
	Callback = function(v)
		getgenv().Config.Main["Auto Teleport Attack"] = v
	end
})


Hitbox:Slider({
	Title = "Hitbox Size",
	Step = 1,
	Value = {
		Min = 1,
		Max = 40,
		Default = getgenv().Config.Hitbox["HitBox Size"]
	},
	Callback = function(v)
		getgenv().Config.Hitbox["HitBox Size"] = v
	end
})


Hitbox:Toggle({
	Title = "Enabled Hitbox",
	Default = getgenv().Config.Hitbox["Enabled Hitbox"],
	Callback = function(v)
		getgenv().Config.Hitbox["Enabled Hitbox"] = v
	end
})



Hop:Slider({
	Title = "Time Hop",
	Step = 10,
	Value = {
		Min = 30,
		Max = 100000,
		Default = getgenv().Config.Hop["Time Hop"]
	},
	Callback = function(v)
		getgenv().Config.Hop["Time Hop"] = v
	end
})

Hop:Toggle({
	Title = "Hop Server",
	Default = getgenv().Config.Hop["HopServer"],
	Callback = function(v)
		getgenv().Config.Hop["HopServer"] = v
	end
})



local Target
local List = {}
local Index = 1
local LastScan = 0


task.spawn(function()
	while task.wait() do
		pcall(function()

			if getgenv().Config.Main["Auto Teleport Attack"] then

				if tick()-LastScan >= 2 then
					LastScan = tick()

					List = {}

					for _,v in ipairs(PlayersService:GetPlayers()) do
						if v ~= LocalPlayer 
						and v.Character
						and v.Character:FindFirstChild("HumanoidRootPart")
						and (
							(v.Backpack and v.Backpack:FindFirstChildWhichIsA("Tool"))
							or v.Character:FindFirstChildWhichIsA("Tool")
						)
						then
							table.insert(List,v)
						end
					end


					if #List > 0 then
						if Index > #List then
							Index = 1
						end

						Target = List[Index]
						Index += 1
					else
						Target = nil
					end
				end


				local Char = LocalPlayer.Character

				if Char and Char:FindFirstChild("HumanoidRootPart") then

					if not Char:FindFirstChildWhichIsA("Tool")
					and not LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") then

						firetouchinterest(
							Char.HumanoidRootPart,
							workspace.Lobby.Teleport1,
							0
						)

						firetouchinterest(
							Char.HumanoidRootPart,
							workspace.Lobby.Teleport1,
							1
						)
					end


					if Target
					and Target.Character
					and Target.Character:FindFirstChild("HumanoidRootPart") then

						Char.HumanoidRootPart.CFrame =
							Target.Character.HumanoidRootPart.CFrame *
							CFrame.new(0,0,4)

						game:GetService("VirtualUser"):CaptureController()
						game:GetService("VirtualUser"):Button1Down(
							Vector2.new(1280,672)
						)

					end
				end
			end
		end)
	end
end)



task.spawn(function()
	while task.wait() do
		pcall(function()

			if getgenv().Config.Hitbox["Enabled Hitbox"] then

				local Char = LocalPlayer.Character

				if Char then
					local Tool = Char:FindFirstChildWhichIsA("Tool")

					if Tool then
						for _,v in ipairs(Tool:GetDescendants()) do

							if v:IsA("MeshPart")
							and v:FindFirstChildOfClass("TouchTransmitter") then

								local Size = getgenv().Config.Hitbox["HitBox Size"]

								v.Size = Vector3.new(Size,Size,Size)
								v.Transparency = 0.5
								v.Color = Color3.fromRGB(255,0,0)

							end
						end
					end
				end
			end
		end)
	end
end)



local function HopServer()

	local Servers = {}
	local Cursor = ""

	pcall(function()

		repeat

			local URL = "https://games.roblox.com/v1/games/"
				.. game.PlaceId ..
				"/servers/Public?sortOrder=Desc&limit=100"

			if Cursor ~= "" then
				URL = URL .. "&cursor=" .. Cursor
			end


			local Data = HttpService:JSONDecode(
				game:HttpGet(URL)
			)


			for _,Server in ipairs(Data.data) do

				if Server.id ~= game.JobId
				and Server.playing >= 5
				and Server.playing <= 10 then

					table.insert(Servers, Server.id)

				end

			end


			Cursor = Data.nextPageCursor

		until #Servers > 0 or not Cursor

	end)


	if #Servers > 0 then

		local JobId = Servers[math.random(1,#Servers)]

		print("Hop To:", JobId)

		TeleportService:TeleportToPlaceInstance(
			game.PlaceId,
			JobId,
			LocalPlayer
		)

	else

		warn("ไม่เจอ Server 8-10 คน")

	end

end

task.spawn(function()

	local Timer = tick()

	while task.wait(1) do

		if getgenv().Config.Hop["HopServer"] then

			if tick() - Timer >= getgenv().Config.Hop["Time Hop"] then

				Timer = tick()
				print("Hop")
				HopServer()
				
			end

		else

			Timer = tick()

		end

	end

end)

