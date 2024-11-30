local nowprediction = true
local auto_parry_enabled = false
local anti_lag_enabled = false
local personnel_detector_enabled = false
local ball_trial_Enabled = false
local spam_speed = 1
local spam_sensetive = 0
local lastBetweentarget = 0
local lastTarget = os.clock()
local strength = 0
local gravity_enabled = false
local current_curve = nil
local ai_Enabled = false
local auto_win = false
local tp_hit = false
local dymanic_curve_check_enabled = false
local visualize_Enabled = false
local target_Ball_Distance = 0
local parry_adjustment = 1
local spam_adjustment = 1
local curve_chance = 0
local anti_curve_theload = 0.5
local prediction_mode = "Dymanic"
local prediction_therlod = 0.8
local Visualize_Color = Color3.fromRGB(38, 255, 183)
local last_hit_remote = 0
local auto_farm = false
local auto_farm_speed = 0
local auto_farm_axis = "XYZ"
local auto_rank = false
local auto_rank_mode = "Passive"
local Legit_Thersold = 10
local parry_mode = "Rage"
local legit_cancel = false
local auto_spam_enabled = false
function getgelp()
	local nurysium_module = {}
	
	local Players = game:GetService("Players")
	
	local Services = {
		game:GetService('AnimationFromVideoCreatorService'),
		game:GetService('AdService')
	}
	
	function nurysium_module.isAlive(Entity)
		return Entity.Character and workspace.Alive:FindFirstChild(Entity.Name) and workspace.Alive:FindFirstChild(Entity.Name).Humanoid.Health > 0
	end
	
	function nurysium_module.getBall()
		for index, ball in workspace:WaitForChild("Balls"):GetChildren() do
			if ball:IsA("BasePart") and ball:GetAttribute("realBall") then
				return ball
			end
		end
	end
	
	return nurysium_module;
end


local function Round(number)
    if number % 1 >= 0.5 then
        return math.ceil(number)
    else
        return math.floor(number)
    end
end

local Helper = getgelp()
local RobloxReplicatedStorage = game:GetService('RobloxReplicatedStorage')
local RbxAnalyticsService = game:GetService('RbxAnalyticsService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local NetworkClient = game:GetService('NetworkClient')
local TweenService = game:GetService('TweenService')
local VirtualUser = game:GetService('VirtualUser')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local LogService = game:GetService('LogService')
local Lighting = game:GetService('Lighting')
local CoreGui = game:GetService('CoreGui')
local Players = game:GetService('Players')
local Debris = game:GetService('Debris')
local Stats = game:GetService('Stats')
local uis = game:GetService("UserInputService")
local Teams = game:GetService("Teams")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local crypter = loadstring(game:HttpGet("https://raw.githubusercontent.com/Egor-Skriptunoff/pure_lua_SHA/master/sha2.lua"))()

local Notification = loadstring(game:HttpGet("https://pastefy.app/NxEL2lJw/raw",true))()

local Gui = Notification:Init()

setfpscap(240)

local LocalPlayer = Players.LocalPlayer
local client_id = RbxAnalyticsService:GetClientId()

local names_map = {
	['protected'] = crypter.sha3_384(client_id, 'sha3-256'),

	['Pillow'] = crypter.sha3_384(client_id .. 'Pillow', 'sha3-256'),
	['Touhou'] = crypter.sha3_384(client_id .. 'Touhou', 'sha3-256'),
	['Shion'] = crypter.sha3_384(client_id .. 'Shion', 'sha3-256'),
	['Miku'] = crypter.sha3_384(client_id .. 'Miku', 'sha3-256'),
	['Sino'] = crypter.sha3_384(client_id .. 'Sino', 'sha3-256'),
	['Soi'] = crypter.sha3_384(client_id .. 'Soi', 'sha3-256')
}

local interface = loadstring(game:HttpGet('https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua'))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Options = interface.Options
local assets = game:GetObjects('rbxassetid://98657300657778')[1]

assets.Parent = RobloxReplicatedStorage
assets.Name = names_map['protected']

local effects_folder = assets.effects
local objects_folder = assets.objects
local sounds_folder = assets.sounds
local gui_folder = assets.gui

local RunTime = workspace.Runtime
local Alive = workspace.Alive
local Dead = workspace.Dead

local AutoParry = {
	ball = nil,
	target = nil,
	entity_properties = nil
}

local Player = {
	Entity = nil,

	properties = {
		grab_animation = nil
	}
}

Player.Entity = {
	properties = {
		sword = '',
		server_position = Vector3.zero,
		velocity = Vector3.zero,
		position = Vector3.zero,
		is_moving = false,
		speed = 0,
		ping = 0
	}
}

local World = {}

AutoParry.ball = {
	training_ball_entity = nil,
	client_ball_entity = nil,
	ball_entity = nil,

	properties = {
		last_ball_pos = Vector3.zero,
		aero_dynamic_time = tick(),
		hell_hook_completed = true,
		last_position = Vector3.zero,
		rotation = Vector3.zero,
		position = Vector3.zero,
		last_warping = tick(),
		parry_remote = nil,
		is_curved = false,
		last_tick = tick(),
		auto_spam = false,
		cooldown = false,
		respawn_time = 0,
		parry_range = 0,
		spam_range = 0,
		maximum_speed = 0,
		old_speed = 0,
		parries = 0,
		direction = 0,
		distance = 0,
		velocity = 0,
		last_hit = 0,
		lerp_radians = 0,
		radians = 0,
		speed = 0,
		dot = 0
	}
}

AutoParry.target = {
	current = nil,
	from = nil,
	aim = nil,
}

AutoParry.entity_properties = {
	server_position = Vector3.zero,
	velocity = Vector3.zero,
	is_moving = false,
	direction = 0,
	distance = 0,
	old_distance = 0,
	speed = 0,
	dot = 0,
	parent = nil,
	character = nil,
}



local function linear_predict(a: any, b: any, time_volume: number)
	return a + (b - a) * time_volume
end

function World:get_pointer()
	local mouse_location = UserInputService:GetMouseLocation()
	local ray = workspace.CurrentCamera:ScreenPointToRay(mouse_location.X, mouse_location.Y, 0)

	return CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)
end

function AutoParry.get_ball()
	for _, ball in workspace.Balls:GetChildren() do
		if ball:GetAttribute("realBall") then
			return ball
		end
	end
end

function AutoParry.get_client_ball()
	for _, ball in workspace.Balls:GetChildren() do
		if not ball:GetAttribute("realBall") then
			return ball
		end
	end
end

function makingtrail()
	local ball = nil


	local function createOrUpdateTrail()
		local Trail = ball:FindFirstChild("Trail")
		if not Trail then
			Trail = Instance.new("Trail")
			Trail.Name = "Trail"
			Trail.FaceCamera = true
			Trail.Parent = ball
		end

		local At1 = ball:FindFirstChild("at1")
		local At2 = ball:FindFirstChild("at2")

		if At1 and At2 then
			Trail.Attachment0 = At1
			Trail.Attachment1 = At2

			Trail.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0.00, Color3.new(1.00, 0.00, 0.02)),
				ColorSequenceKeypoint.new(0.14, Color3.new(0.98, 1.00, 0.00)),
				ColorSequenceKeypoint.new(0.30, Color3.new(0.07, 1.00, 0.00)),
				ColorSequenceKeypoint.new(0.48, Color3.new(0.00, 0.98, 1.00)),
				ColorSequenceKeypoint.new(0.69, Color3.new(0.03, 0.00, 1.00)),
				ColorSequenceKeypoint.new(0.88, Color3.new(1.00, 0.00, 0.98)),
				ColorSequenceKeypoint.new(1.00, Color3.new(1.00, 0.00, 0.02))
			}

			Trail.WidthScale = NumberSequence.new{
				NumberSequenceKeypoint.new(0.00, 0.5, 0.00),
				NumberSequenceKeypoint.new(1.00, 0.00, 0.00)
			}

			Trail.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0.00, 0.00, 0.00),
				NumberSequenceKeypoint.new(1.00, 1.00, 0.00)
			}

			Trail.Enabled = true
		end
	end

	local function enableTrailAndDisableFF()
		createOrUpdateTrail()

		local Trail = ball:FindFirstChild("Trail")
		if Trail then
			Trail.Enabled = true
		end

		local ff = ball:FindFirstChild("ff")
		if ff then
			ff.Enabled = false
		end
	end


	local function disableTrailAndEnableFF()
		local Trail = ball:FindFirstChild("Trail")
		if Trail then
			Trail:Destroy()
		end

		local ff = ball:FindFirstChild("ff")
		if ff then
			ff.Enabled = true
		end
	end

	ball = Helper.getBall()

	if ball then
		if ball_trial_Enabled then
			enableTrailAndDisableFF()
		else
			disableTrailAndEnableFF()
		end
	end

end

local self = Helper.getBall()
local Visualize = Instance.new("Part")
Visualize.Color = Visualize_Color
Visualize.Material = Enum.Material.ForceField
Visualize.Transparency = 0.5
Visualize.Anchored = true
Visualize.CanCollide = false
Visualize.CastShadow = false
Visualize.Shape = Enum.PartType.Ball
Visualize.Size = Vector3.new(30,30,30)
Visualize.Parent = workspace

local Highlight = Instance.new("Highlight")
Highlight.Parent = Visualize
Highlight.Enabled = true
Highlight.FillTransparency = 0
Highlight.OutlineColor = Color3.new(1, 1, 1)
Highlight.FillColor = Color3.new(0,1,1)

task.defer(function()
	RunService.PreSimulation:Connect(function()
		Visualize.Color = Visualize_Color
		if visualize_Enabled and LocalPlayer then
			Visualize.Transparency = 0
			Visualize.Material = Enum.Material.ForceField
			Visualize.Size = Vector3.new(AutoParry.ball.properties.parry_range,AutoParry.ball.properties.parry_range,AutoParry.ball.properties.parry_range)
			Visualize.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position)
		else
			Visualize.Material = Enum.Material.ForceField
			Visualize.Transparency = 1
		end
	end)
end)

function Player:get_aim_entity()
	local closest_entity = nil
	local minimal_dot_product = -math.huge
	local camera_direction = workspace.CurrentCamera.CFrame.LookVector

	for _, player in Alive:GetChildren() do
		if not player then
			continue
		end

		if player.Name ~= LocalPlayer.Name then
			if not player:FindFirstChild('HumanoidRootPart') then
				continue
			end

			local entity_direction = (player.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Unit
			local dot_product = camera_direction:Dot(entity_direction)

			if dot_product > minimal_dot_product then
				minimal_dot_product = dot_product
				closest_entity = player
			end
		end
	end

	return closest_entity
end

function Player:get_closest_player_to_cursor()
	local closest_player = nil
	local minimal_dot_product = -math.huge

	for _, player in workspace.Alive:GetChildren() do
		if player == LocalPlayer.Character then
			continue
		end

		if player.Parent ~= Alive then
			continue
		end

		local player_direction = (player.PrimaryPart.Position - workspace.CurrentCamera.CFrame.Position).Unit
		local pointer = World.get_pointer()
		local dot_product = pointer.LookVector:Dot(player_direction)

		if dot_product > minimal_dot_product then
			minimal_dot_product = dot_product
			closest_player = player
		end
	end

	return closest_player
end

function AutoParry.get_parry_remote()
        local Services = {cloneref(game:GetService("AnimationFromVideoCreatorService")),cloneref(game:GetService('AdService'))}

        for _, v in pairs(Services) do
            local temp_remote = v:FindFirstChildOfClass('RemoteEvent')
    
            if temp_remote and temp_remote.Name:find('\n') then
            AutoParry.ball.properties.parry_remote = temp_remote
        end
    end
end

AutoParry.get_parry_remote()

function AutoParry.perform_grab_animation()
	local animation = ReplicatedStorage.Shared.SwordAPI.Collection.Default:FindFirstChild('GrabParry')
	local currently_equipped = Player.Entity.properties.sword

	if not currently_equipped or currently_equipped == 'Titan Blade' then
		return
	end

	if not animation then
		return
	end

	local sword_data = ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(currently_equipped)

	if not sword_data or not sword_data['AnimationType'] then
		return
	end

	local character = LocalPlayer.Character

	if not character or not character:FindFirstChild('Humanoid') then
		return
	end

	for _, object in ReplicatedStorage.Shared.SwordAPI.Collection:GetChildren() do
		if object.Name ~= sword_data['AnimationType'] then
			continue
		end

		if not (object:FindFirstChild('GrabParry') or object:FindFirstChild('Grab')) then
			continue
		end

		local sword_animation_type = 'GrabParry'

		if object:FindFirstChild('Grab') then
			sword_animation_type = 'Grab'
		end

		animation = object[sword_animation_type]
	end

	Player.properties.grab_animation = character.Humanoid:LoadAnimation(animation)
	Player.properties.grab_animation:Play()
end

function AutoParry.perform_parry()
	local ball_properties = AutoParry.ball.properties

	if ball_properties.cooldown and not ball_properties.auto_spam then
		return
	end

	ball_properties.parries += 1
	AutoParry.ball.properties.last_hit = tick()

	local camera = workspace.CurrentCamera
	local camera_direction = camera.CFrame.Position

	local direction = camera.CFrame
	local target_position = AutoParry.entity_properties.server_position

	if not ball_properties.auto_spam then
		AutoParry.perform_grab_animation()

		ball_properties.cooldown = true


		if math.random() <= curve_chance / 100 then
			if current_curve == 'Stright' then
				direction = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, target_position)
			end
	
			if current_curve == 'Backwards' then
				direction = CFrame.new(camera_direction, (camera_direction + (-camera.CFrame.LookVector * 10000)) + Vector3.new(0, 1000, 0))
			end
	
			if current_curve == 'Randomizer' then
				direction = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, Vector3.new(math.random(-1000, 1000), math.random(-350, 1000), math.random(-1000, 1000)))
			end
	
			if current_curve == 'Boost' then
				direction = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, target_position + Vector3.new(0, 150, 0))
			end
			if current_curve == 'Camera' then
				direction = CFrame.new(camera_direction, target_position + Vector3.new(0, 60, 0))
			end
		else
			direction = camera.CFrame
		end

		ball_properties.parry_remote:FireServer(
			0,
			direction,
			{ [AutoParry.target.aim.Name] = target_position },
			{ target_position.X, target_position.Y },
			false
		)



		task.delay(1, function()
			if ball_properties.parries > 0 then
				ball_properties.parries -= 1
			end
		end)

		return
	end

	ball_properties.parry_remote:FireServer(
		0.5,
		direction,
		{ [AutoParry.target.aim.Name] = target_position },
		{ target_position.X, target_position.Y },
		false
	)

	task.delay(1, function()
		if ball_properties.parries > 0 then
			ball_properties.parries -= 1
		end
	end)
end

function AutoParry.reset()
	nowprediction = true
	AutoParry.ball.properties.is_curved = false
	AutoParry.ball.properties.auto_spam = false
	AutoParry.ball.properties.cooldown = false
	AutoParry.ball.properties.maximum_speed = 0
	AutoParry.ball.properties.parries = 0
	AutoParry.entity_properties.server_position = Vector3.zero
	AutoParry.target.current = nil
	AutoParry.target.from = nil
end

ReplicatedStorage.Remotes.PlrHellHooked.OnClientEvent:Connect(function(hooker: Model)
	if hooker.Name == LocalPlayer.Name then
		AutoParry.ball.properties.hell_hook_completed = true

		return
	end

	AutoParry.ball.properties.hell_hook_completed = false
end)

ReplicatedStorage.Remotes.PlrHellHookCompleted.OnClientEvent:Connect(function()
	AutoParry.ball.properties.hell_hook_completed = true
end)

function AutoParry.is_curved()
	local target = AutoParry.target.current

	if not target then
		return false
	end

	local ball_properties = AutoParry.ball.properties
	local current_target = target.Name

	-- Check for MaxShield
	if target.PrimaryPart:FindFirstChild('MaxShield') and current_target ~= LocalPlayer.Name and ball_properties.distance < 50 then
		return false
	end

	-- Check for TimeHole1
	if AutoParry.ball.ball_entity:FindFirstChild('TimeHole1') and current_target ~= LocalPlayer.Name and ball_properties.distance < 100 then
		ball_properties.auto_spam = false
		return false
	end

	-- Check for WEMAZOOKIEGO
	if AutoParry.ball.ball_entity:FindFirstChild('WEMAZOOKIEGO') and current_target ~= LocalPlayer.Name and ball_properties.distance < 100 then
		return false
	end

	-- Check for At2 and speed
	if AutoParry.ball.ball_entity:FindFirstChild('At2') and ball_properties.speed <= 0 then
		return true
	end

	-- Handle AeroDynamicSlashVFX
	if AutoParry.ball.ball_entity:FindFirstChild('AeroDynamicSlashVFX') then
		Debris:AddItem(AutoParry.ball.ball_entity.AeroDynamicSlashVFX, 0)
		ball_properties.auto_spam = false
		ball_properties.aero_dynamic_time = tick()
	end

	-- Handle Tornado
	if RunTime:FindFirstChild('Tornado') then
		local tornadoTime = RunTime.Tornado:GetAttribute("TornadoTime") or 1
		if ball_properties.distance > 5 and (tick() - ball_properties.aero_dynamic_time) < (tornadoTime + 0.314159) then
			return true
		end
	end

	-- Check hell_hook_completed
	if not ball_properties.hell_hook_completed and target.Name == LocalPlayer.Name and ball_properties.distance > 5 - math.random() then
		return true
	end

	local ball_direction = ball_properties.velocity.Unit
	local ball_speed = ball_properties.speed

	-- Calculate thresholds
	local speed_threshold = math.min(ball_speed / 100, 40)
	local angle_threshold = 40 * math.max(ball_properties.dot, 0)
	local player_ping = Player.Entity.properties.ping

	local accurate_direction = ball_properties.velocity.Unit
	accurate_direction *= ball_direction

	local direction_difference = (accurate_direction - ball_properties.velocity).Unit
	local accurate_dot = ball_properties.direction:Dot(direction_difference)
	local dot_difference = ball_properties.dot - accurate_dot
	local dot_threshold = anti_curve_theload - player_ping / 1000

	local reach_time = ball_properties.distance / ball_properties.maximum_speed - (player_ping / 1000)
	local enough_speed = ball_properties.maximum_speed > 100

	local ball_distance_threshold = 15 - math.min(ball_properties.distance / 1000, 15) + angle_threshold + speed_threshold

	if enough_speed and reach_time > player_ping / 10 then
		ball_distance_threshold = math.max(ball_distance_threshold - 15, 15)
	end

	if ball_properties.distance < ball_distance_threshold then
		return false
	end

	if dot_difference < dot_threshold then
		return true
	end

	if ball_properties.lerp_radians < 0.018 then
		ball_properties.last_curve_position = ball_properties.position
		ball_properties.last_warping = tick() 
	end

	if (tick() - ball_properties.last_warping) < (reach_time / 1.5) then
		return true
	end

	-- Update curve position
	local ball_position = ball_properties.position
	local previous_position = ball_properties.last_curve_position or ball_position
	local travel_direction = (ball_position - previous_position).Unit

	ball_properties.last_curve_position = ball_position

	return ball_properties.dot < dot_threshold
end


local old_from_target = (typeof(old_from_target) == "Instance" and old_from_target:IsA("Model")) and old_from_target or nil

function AutoParry:is_spam()
if not auto_spam_enabled then return false end
	local target = AutoParry.target.current

	if not target then
		return false
	end

	if AutoParry.target.from ~= LocalPlayer.Character then
		old_from_target = AutoParry.target.from
	end

	local player_ping = Player.Entity.properties.ping
	local distance_threshold = (spam_adjustment + self.moveAmountThing + (self.maximum_speed / 5.5)) - AutoParry.entity_properties.distance

	local ball_properties = AutoParry.ball.properties
	local reach_time = ball_properties.distance / ball_properties.maximum_speed - (player_ping / 1000)

	if self.parries < 3 and AutoParry.target.from == old_from_target then
		return false
	end

	if (tick() - self.last_hit) > 0.8 and self.entity_distance > distance_threshold and self.parries < 3 then
		self.parries = 1

		return false
	end

	if ball_properties.lerp_radians > 0.028 then
		if self.parries < 2 then
			self.parries = 1
		end

		return false
	end

	if (tick() - ball_properties.last_warping) < (reach_time / 1.3) and self.entity_distance > distance_threshold and self.parries < 4 then
		if self.parries < 3 then
			self.parries = 1
		end

		return false
	end

	if math.abs(self.speed - self.old_speed) < 5.2 and self.entity_distance > distance_threshold and self.speed < 60 and self.parries < 3 then
		if self.parries < 3 then
			self.parries = 0
		end

		return false
	end

	if self.speed < 10 then
		self.parries = 1

		return false
	end

	if self.maximum_speed < self.speed and self.entity_distance > distance_threshold then
		self.parries = 1

		return false
	end

	if self.entity_distance > self.range and self.entity_distance > distance_threshold then
		if self.parries < 2 then
			self.parries = 1
		end

		return false
	end

	if self.ball_distance > self.range and self.entity_distance > distance_threshold then
		if self.parries < 2 then
			self.parries = 2
		end

		return false
	end

	if self.last_position_distance > self.spam_accuracy and self.entity_distance > distance_threshold then
		if self.parries < 4 then
			self.parries = 2
		end

		return false
	end

	if self.ball_distance > self.spam_accuracy and self.ball_distance > distance_threshold then
		if self.parries < 3 then
			self.parries = 2
		end

		return false
	end

	if self.entity_distance > self.spam_accuracy and self.entity_distance > (distance_threshold - math.pi) then
		if self.parries < 3 then
			self.parries = 2
		end

		return false
	end

	return true	
end



task.defer(function()
	RunService.PreSimulation:Connect(function()
		makingtrail()
	end)
end)
AutoParry.ball.ball_entity = AutoParry.get_ball()
AutoParry.ball.client_ball_entity = AutoParry.get_client_ball()

RunService.PreSimulation:Connect(function()
	local ball = AutoParry.ball.ball_entity

	if not ball then
		return
	end

	local zoomies = ball:FindFirstChild('zoomies')

	local ball_properties = AutoParry.ball.properties

	ball_properties.position = ball.Position
	ball_properties.velocity = ball.AssemblyLinearVelocity

	if zoomies then
		ball_properties.velocity = ball.zoomies.VectorVelocity
	end

	ball_properties.distance = (Player.Entity.properties.server_position - ball_properties.position).Magnitude
	ball_properties.speed = ball_properties.velocity.Magnitude
	ball_properties.direction = (Player.Entity.properties.server_position - ball_properties.position).Unit
	ball_properties.dot = ball_properties.direction:Dot(ball_properties.velocity.Unit)
	ball_properties.radians = math.rad(math.asin(ball_properties.dot))
	ball_properties.lerp_radians = linear_predict(ball_properties.lerp_radians, ball_properties.radians, 0.8)


	if not (ball_properties.lerp_radians < 0) and not (ball_properties.lerp_radians > 0) then
		ball_properties.lerp_radians = 0.027
	end

	ball_properties.maximum_speed = math.max(ball_properties.speed, ball_properties.maximum_speed)

	AutoParry.target.aim = (not uis.TouchEnabled and Player.get_closest_player_to_cursor() or Player.get_aim_entity())

	if ball:GetAttribute('from') ~= nil then
		AutoParry.target.from = Alive:FindFirstChild(ball:GetAttribute('from'))
	end

	AutoParry.target.current = Alive:FindFirstChild(ball:GetAttribute('target'))

	if AutoParry.target == nil then
		return

	end

	ball_properties.rotation = ball_properties.position

	if AutoParry.target.current and AutoParry.target.current.Name == LocalPlayer.Name then
		return
	end

	if not AutoParry.target.current then
		return
	end

	local target_server_position = AutoParry.target.current.PrimaryPart.Position
	local target_velocity = AutoParry.target.current.PrimaryPart.AssemblyLinearVelocity


    local targetPlayer = Players:GetPlayerFromCharacter(AutoParry.target.current)
    if targetPlayer and (targetPlayer.Team ~= LocalPlayer.Team or targetPlayer.Team.Name == "Playing") then
        AutoParry.entity_properties.server_position = target_server_position
        AutoParry.entity_properties.velocity = target_velocity
        AutoParry.entity_properties.distance = (Player.Entity.properties.server_position - target_server_position).Magnitude
        AutoParry.entity_properties.old_distance = (Player.Entity.properties.server_position - target_server_position).Magnitude
        AutoParry.entity_properties.direction = (Player.Entity.properties.server_position - target_server_position).Unit
        AutoParry.entity_properties.speed = target_velocity.Magnitude
        AutoParry.entity_properties.is_moving = target_velocity.Magnitude > 0.1
        AutoParry.entity_properties.dot = AutoParry.entity_properties.is_moving and math.max(AutoParry.entity_properties.direction:Dot(target_velocity.Unit), 0)
        AutoParry.entity_properties.parent = AutoParry.target.current.Parent 
		AutoParry.entity_properties.character = AutoParry.target.current.Character
    end
end)

function AutoParry.IsCooldown()
	return AutoParry.ball.properties.last_hit - last_hit_remote > 0.5
end

local LocalPlayer = Players.LocalPlayer

local Window = interface:CreateWindow({
	Title = "NW Hub",
	SubTitle = "Made by Hiuyup and 0x75D",
	TabWidth = 180,
	Size = UDim2.fromOffset(500, 350),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Main = Window:AddTab({ Title = "Auto Parry", Icon = "sword" }),
	Visual = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
	Setting = Window:AddTab({ Title = "Settings", Icon = "cog" }),
}

local Options = interface.Options

do
	local auto_parry = Tabs.Main:AddToggle("ap",{
		Title = "Auto Parry", 
		Description = "-Automatically Parries the ball when targeting You.",
		Default = false,
	})
local auto_spam = Tabs.Main:AddToggle("as", {
  Title = "Auto Spam",
  Description = "-Automatically Spams The Parry functiom to calsh with other people",
  Default = false
})  
  
	auto_parry:OnChanged(function(v)
		auto_parry_enabled = v
	end)
auto_spam:OnChanged(function(v)
  auto_spam_enabled = v
end)
  
	local Auto_Farm = Tabs.Main:AddToggle("Auto_Farm",{
		Title = "Auto Farm", 
		Description = "-Rotates your player around the ball.",
		Default = false,
	})

	Auto_Farm:OnChanged(function(v)
		auto_farm = v
	end)

	local Auto_Rank = Tabs.Main:AddToggle("Auto_Rank",{
		Title = "Auto Rank", 
		Description = "-Self Explanatory",
		Default = false,
	})

	Auto_Rank:OnChanged(function(v)
		auto_rank = v
	end)

	local parry_mode = Tabs.Setting:AddDropdown("pm",{
		Title = "Parry Mode",
		Description = "Choose a parry mode",
		Values = {"Legit", "Rage"},
		Multi = false,
		Default = 2,
	})

	local Legit_Th = Tabs.Setting:AddInput("Legit_Th", {
		Title = "Legit Random Adjustment",
		Description = "",
		Default = "10",
		Placeholder = "Enter Number Only",
		Numeric = true,-- Ony allows numbers
		Finished = false -- Only calls callback when you press enter
		Callback = function(Value)
			Legit_Thersold = tonumber(Value)
		end
	})

	parry_mode:OnChanged(function(v)
		parry_mode = tostring(v)
	end)

	local curve_method2 = Tabs.Setting:AddDropdown("cm",{
		Title = "Curve Medthod",
		Description = "Curve Medthod that all",
		Values = {"Stright", "Backwards", "Randomizer", "Boost","Camera",},
		Multi = false,
		Default = 1,
	})

	curve_method2:OnChanged(function(v)
		current_curve = v
	end)

	local Parry_Adjustment = Tabs.Setting:AddSlider("Parry_Adjustment", 
	{
		Title = "Parry Distance Adjustment",
		Description = "Adjust the Parry distance",
		Default = 1,
		Min = 1,
		Max = 2,
		Rounding = 1,
		Callback = function(Value)
			parry_adjustment = Value
		end
	})

	local Spam_Adjustment = Tabs.Setting:AddSlider("Spam_Adjustment", 
	{
		Title = "Spam Distance Adjustment",
		Description = "Adjust the Spam distance",
		Default = 25,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Callback = function(Value)
			spam_adjustment = Value
		end
	})

	local Auto_Farm_Speed = Tabs.Setting:AddSlider("Auto_Farm_Speed", 
	{
		Title = "Auto Farm Speed Adjustment",
		Description = "Change Speed of Auto Farm",
		Default = 60,
		Min = 0,
		Max = 120,
		Rounding = 1,
		Callback = function(Value)
			auto_farm_speed = Value
		end
	})

	local Auto_Farm_Axis = Tabs.Setting:AddDropdown("Auto_Farm_Axis",{
		Title = "Auto Farm Axis",
		Description = "Change Auto Farm Axis",
		Values = {"X", "Y","Z","XY","XZ","YX","YZ","ZX","ZY","XYZ",},
		Multi = false,
		Default = 10,
	})

	Auto_Farm_Axis:OnChanged(function(v)
		auto_farm_axis = tostring(v)
	end)

	local Auto_Rank_Mode = Tabs.Setting:AddDropdown("Auto_Rank_Mode",{
		Title = "Auto Rank Mode",
		Description = "Change AI-Based",
		Values = {"Aggressive", "Passive","Smart",},
		Multi = false,
		Default = 2,
	})

	local Curve_Chance = Tabs.Setting:AddSlider("Curve_Chance", 
	{
		Title = "Curve Chance Adjustment",
		Description = "Adjust the Curve Chance",
		Default = 0,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Callback = function(Value)
			curve_chance = Round(Value)
		end
	})

	local Anti_curve_chance = Tabs.Setting:AddSlider("Anti_curve_chance", 
	{
		Title = "Anti curve chance Adjustment",
		Description = "Adjust the Anti curve Sensetive (high = less detection low = more detection 1 = no detection)",
		Default = 0.5,
		Min = 0,
		Max = 1,
		Rounding = 1,
		Callback = function(Value)
			anti_curve_theload = Value
		end
	})

	local Preditction_Mode = Tabs.Setting:AddDropdown("Preditction_Mode",{
		Title = "Preditction Mode",
		Description = "Dymanic = Ping Based",
		Values = {"Dymanic", "Adjustable",},
		Multi = false,
		Default = 1,
	})

	Preditction_Mode:OnChanged(function(v)
		prediction_mode = tostring(v)
	end)

	local Preditction_Adjustment = Tabs.Setting:AddSlider("Preditction_Adjustment", 
	{
		Title = "Preditction Adjustment",
		Description = "Adjust the Prediction (if prediction mode is adjustable)",
		Default = 0.8,
		Min = 0,
		Max = 0.9,
		Rounding = 1,
		Callback = function(Value)
			prediction_therlod = Value
		end
	})


	local personnel_detector2 = Tabs.Main:AddToggle("pd",{
		Title = "Personnel detector", 
		Description = "Leave when mod contect creator etc joins",
		Default = false,
	})

	personnel_detector2:OnChanged(function(v)
		personnel_detector_enabled = v
	end)

	local anti_lag = Tabs.Visual:AddToggle("al",{
		Title = "Anti lag", 
		Description = "anti lag that all :)",
		Default = false,
	})

	anti_lag:OnChanged(function(v)
		anti_lag_enabled = v

		if anti_lag_enabled then
			local lighting = game:GetService("Lighting")
			lighting.GlobalShadows = false
			lighting.Brightness = 0
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("Part") or v:IsA("MeshPart") then


				elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
					v.Enabled = false
				end
			end
			lighting.FogEnd = 9e9


		else
			local lighting = game:GetService("Lighting")
			lighting.GlobalShadows = true
			lighting.Brightness = 2
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("Part") or v:IsA("MeshPart") then


				elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
					v.Enabled = true
				end
			end
		end
	end)
end

do

	local ball_trail = Tabs.Visual:AddToggle("bt",{
		Title = "Ball Trail", 
		Description = "Trail but for ball (old version may have bug)",
		Default = false,
	})

	local visualize = Tabs.Visual:AddToggle("vl",{
		Title = "Visualize", 
		Description = "Visualize a Parry range",
		Default = false,
	})

	local Visualize_Colorb = Tabs.Visual:AddColorpicker("Visualize_Colorb", {
		Title = "Visualize Color",
		Description = "Change Visualize Color",
		Default = Color3.fromRGB(38, 255, 183)
	})

	visualize:OnChanged(function(v)
		visualize_Enabled = v
	end)

	ball_trail:OnChanged(function(v)
		ball_trial_Enabled = v
	end)

	Visualize_Colorb:OnChanged(function()
		Visualize_Color = Visualize_Colorb.Value
	end)
	

end


do
	local dymanic_curve_check = Tabs.Setting:AddToggle("dcc",{
		Title = "Dymanic Adjust Curve Detection", 
		Description = "Work only for spam",
		Default = false,
	})
	dymanic_curve_check:OnChanged(function(v)
		dymanic_curve_check_enabled = v
	end)

	local adjust_spam_speed = Tabs.Setting:AddDropdown("Asps",{
		Title = "Spam Speed",
		Description = "Adjust the Spam Speed",
		Values = {1, 2, 3, 4,5,6,7,8,9,10,},
		Multi = false,
		Default = 1,
	})

	adjust_spam_speed:OnChanged(function(v)
		spam_speed = v
	end)


end

local dropdown_emotes_table = {}
local emote_instances = {}

for _, emote in ReplicatedStorage.Misc.Emotes:GetChildren() do
	local emote_name = emote:GetAttribute('EmoteName')

	if not emote_name then
		return
	end

	table.insert(dropdown_emotes_table, emote_name)
	emote_instances[emote_name] = emote
end

LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.zero)
end)

local current_animation = nil
local current_animation_name = nil

local looped_emotes = {
	"Emote108",
	"Emote225",
	"Emote300",
	"Emote301"
}


local spamming_done = (typeof(spamming_done) == "boolean" and spamming_done) or true

local staff_roles = {
	'content creator',
	'contributor',
	'trial qa',
	'tester',
	'mod'
}

Players.PlayerAdded:Connect(function(player)
	local is_friend = LocalPlayer:IsFriendsWith(player.UserId)
  
	if not personnel_detector_enabled then
		return
	end
	local player_role = tostring(player:GetRoleInGroup(12836673)):lower()
	local player_is_staff = table.find(staff_roles, player_role)

	if player_is_staff then
		game:Shutdown()

		return
	end
end)


local is_respawned = (typeof(is_respawned) == "boolean" and is_respawned) or false

workspace.Balls.ChildRemoved:Connect(function(child)
	is_respawned = false

	if child == AutoParry.ball.ball_entity then
		AutoParry.ball.ball_entity = nil
		AutoParry.ball.client_ball_entity = nil
		AutoParry.reset()
	end
end)

workspace.Balls.ChildAdded:Connect(function()
	if is_respawned then
		return
	end

	is_respawned = true

	local ball_properties = AutoParry.ball.properties

	ball_properties.respawn_time = tick()

	AutoParry.ball.ball_entity = AutoParry.get_ball()
	AutoParry.ball.client_ball_entity = AutoParry.get_client_ball()

	local target = AutoParry.ball.ball_entity:GetAttribute('target')

	if target == LocalPlayer.Name then

		if ball_properties.distance <= 10 then
			perform_parry()
		end

		return
	end

	AutoParry.ball.ball_entity:GetAttributeChangedSignal('target'):Connect(function()
		if target == LocalPlayer.Name then
			ball_properties.cooldown = false

            if ball_properties.distance <= 10 then
				perform_parry()
			end

			return
		end

		ball_properties.cooldown = false
		ball_properties.old_speed = ball_properties.speed
		ball_properties.last_position = ball_properties.position

		ball_properties.parries += 1

		task.delay(1, function()
			if ball_properties.parries > 0 then
				ball_properties.parries -= 1
			end
		end)	
	end)
end)



RunService.Stepped:Connect(function()
	if not AutoParry.ball.properties.auto_spam then
		return
	end

	for v = 1,spam_speed do
		AutoParry.perform_parry()
	end
end)

local custom_win_audio = Instance.new('Sound', sounds_folder)



ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(slash: any, root: any)
	task.spawn(function()
		if root.Parent and root.Parent ~= LocalPlayer.Character then
			if root.Parent.Parent ~= Alive then
				return
			end

			AutoParry.ball.properties.cooldown = false
		end
	end)

	if AutoParry.ball.properties.auto_spam then
		for v = 1,spam_speed do
			AutoParry.perform_parry()
		end
	end

	legit_cancel = false
end)

local custom_audio = Instance.new('Sound', sounds_folder)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
	last_hit_remote = tick()
	task.delay(0.05,function()
		AutoParry.ball.properties.cooldown = false
	end)

	if LocalPlayer.Character.Parent ~= Alive then
		return
	end

	if not Player.properties.grab_animation then
		return
	end



	Player.properties.grab_animation:Stop()

	local ball = AutoParry.get_client_ball()

	if not ball then
		return
	end


	if AutoParry.ball.properties.auto_spam then
		for v = 1,spam_speed do
			AutoParry.perform_parry()
		end
	end


	ball = nil
end)

local function calurateParry(deltaTimeSim)
	if not deltaTimeSim then
		deltaTimeSim = 0
	end

	if not auto_parry_enabled or legit_cancel then
		AutoParry.reset()

		return
	end

	

	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	if Character.Parent == Dead then
		AutoParry.reset()

		return
	end

	if not AutoParry.ball.ball_entity then
		return
	end

	local ball_properties = AutoParry.ball.properties


	ball_properties.is_curved = AutoParry.is_curved()

	local ping_threshold = math.clamp(Player.Entity.properties.ping / 10, 10, 16)
	local predictiedTime = (ping_threshold / 100)

	if prediction_mode == "Dymanic" then
		predictiedTime = (ping_threshold / 100)
	else
		predictiedTime = prediction_therlod
	end

	local predictedPosition = ball_properties.position + (ball_properties.velocity * predictiedTime + (ball_properties.velocity * deltaTimeSim))
	local distance = (Player.Entity.properties.server_position - predictedPosition).Magnitude

	local parryBuffer = 1 + ball_properties.maximum_speed / 1000 + (ping_threshold / 1000)

	local parry_accuracity = ball_properties.maximum_speed / 11.5 + ping_threshold * parryBuffer * parry_adjustment
	local ball_distance_accuracity = ball_properties.distance * 1 - ping_threshold / 100
	ball_properties.parry_range = ping_threshold + ball_properties.speed / math.pi * parryBuffer * parry_adjustment
	local player_properties = Player.Entity.propertie

	if Player.Entity.properties.ping >= 190 then
		parry_accuracity = parry_accuracity * (1 + Player.Entity.properties.ping / 1000)
		ball_properties.parry_range = ball_properties.parry_range * (1 + Player.Entity.properties.ping / 1000)

	end
	



	if Player.Entity.properties.sword == 'Titan Blade' then
		ball_properties.parry_range += 11
	end	

	if ball_properties.auto_spam then
		return
	end

	if ball_properties.is_curved then
		return
	end

	if distance > ball_properties.parry_range and distance > parry_accuracity then
		return
	end

	if AutoParry.target.current and AutoParry.target.current ~= LocalPlayer.Character then
		return
	end



	AutoParry.perform_parry()
	task.spawn(function()
		repeat
			RunService.Heartbeat:Wait()
		until 
		(tick() - ball_properties.last_hit) > 1 - (ping_threshold / 100)

		ball_properties.cooldown = false
	end)
end


task.spawn(function()
	RunService.Heartbeat:Connect(function(deltaTimeSim)
		calurateParry(deltaTimeSim)
	end)
end)



task.spawn(function()
	RunService.RenderStepped:Connect(function()

		if not auto_parry_enabled then
			AutoParry.reset()
	
			return
		end
	
		local Character = LocalPlayer.Character
	
		if not Character then
			return
		end
	
		if Character.Parent == Dead then
			AutoParry.reset()
	
			return
		end
	
		if not AutoParry.ball.ball_entity then
			return
		end
	
		local ball_properties = AutoParry.ball.properties
	
		local baseMoveAmount = 0.5
		local moveAmount = baseMoveAmount * (1 / (AutoParry.entity_properties.distance + 0.01)) * 1000
	
		local ping_threshold = math.clamp(Player.Entity.properties.ping / 10, 10, 16)
	
		local spam_accuracity = ball_properties.maximum_speed / 7 + (moveAmount - AutoParry.entity_properties.distance)
	
		local player_properties = Player.Entity.properties
	
	
		ball_properties.spam_range = ball_properties.speed / 2.3 + (moveAmount - AutoParry.entity_properties.distance)
	
	
	
		if Player.Entity.properties.sword == 'Titan Blade' then
			ball_properties.spam_range += 2
		end	
	
		local distance_to_last_position = LocalPlayer:DistanceFromCharacter(ball_properties.last_position)
	
		if ball_properties.auto_spam and AutoParry.target.current then
			ball_properties.auto_spam = AutoParry.is_spam({
				speed = ball_properties.speed,
				spam_accuracy = spam_accuracity,
				parries = ball_properties.parries,
				ball_speed = ball_properties.speed,
				range = ball_properties.spam_range / (3.15 - ping_threshold / 10),
				last_hit = ball_properties.last_hit,
				ball_distance = ball_properties.distance,
				maximum_speed = ball_properties.maximum_speed,
				old_speed = AutoParry.ball.properties.old_speed,
				entity_distance = AutoParry.entity_properties.distance,
				last_position_distance = distance_to_last_position,
				moveAmountThing = moveAmount,
			})
		end
	
		if ball_properties.auto_spam then
			return
		end
	
	
	
	
	
		if AutoParry.target.current and AutoParry.target.current.Name == LocalPlayer.Name then
			ball_properties.auto_spam = AutoParry.is_spam({
				speed = ball_properties.speed,
				spam_accuracy = spam_accuracity,
				parries = ball_properties.parries,
				ball_speed = ball_properties.speed,
				range = ball_properties.spam_range,
				last_hit = ball_properties.last_hit,
				ball_distance = ball_properties.distance,
				maximum_speed = ball_properties.maximum_speed,
				old_speed = AutoParry.ball.properties.old_speed,
				entity_distance = AutoParry.entity_properties.distance,
				old_entity_distance = AutoParry.entity_properties.old_distance,
				last_position_distance = distance_to_last_position,
				moveAmountThing = moveAmount,
			})
		end
	
	end)
end)

RunService:BindToRenderStep('server position simulation', 1, function()
	local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()

	if not LocalPlayer.Character then
		return
	end

	if not LocalPlayer.Character.PrimaryPart then
		return
	end

	local PrimaryPart = LocalPlayer.Character.PrimaryPart
	local old_position = PrimaryPart.Position

	task.delay(ping / 1000, function()
		Player.Entity.properties.server_position = old_position
	end)
end)

RunService.PreSimulation:Connect(function()
	NetworkClient:SetOutgoingKBPSLimit(math.huge)

	local character = LocalPlayer.Character

	if not character then
		return
	end

	if not character.PrimaryPart then
		return
	end

	local player_properties = Player.Entity.properties

	player_properties.sword = character:GetAttribute('CurrentlyEquippedSword')
	player_properties.ping = LocalPlayer:GetNetworkPing() * 1000
	player_properties.velocity = character.PrimaryPart.AssemblyLinearVelocity
	player_properties.speed = Player.Entity.properties.velocity.Magnitude
	player_properties.is_moving = Player.Entity.properties.speed > 30
end)
--//Auto Farm
task.defer(function()
	RunService.Stepped:Connect(function()
		if auto_farm and workspace.Alive:FindFirstChild(LocalPlayer.Name) then
			local self = Helper.getBall()
			if not self then return end
			
			local player = LocalPlayer.Character
			local ball_Position = self.Position


			local ping = game:GetService("Stats"):FindFirstChild("PerformanceStats"):FindFirstChild("Ping"):GetValue() or 0
			local adjusted_Distance = math.clamp(15 + (ping / 50), 15, 50) + (AutoParry.ball.properties.last_hit - last_hit_remote)

			-- ใช้ speed ในการควบคุมการเคลื่อนที่
			local angle = tick() * auto_farm_speed
			local offset = Vector3.new(
				auto_farm_axis:find("X") and math.cos(angle) * adjusted_Distance or 0,
				auto_farm_axis:find("Y") and math.sin(angle) * adjusted_Distance or 0,
				auto_farm_axis:find("Z") and math.sin(angle) * adjusted_Distance or 0
			)

			-- คำนวณตำแหน่งเป้าหมายรอบ ๆ ลูกบอล
			local target_Position = ball_Position + offset

			-- อัปเดตตำแหน่งของ HumanoidRootPart ให้หันไปที่ลูกบอล
			player.HumanoidRootPart.CFrame = CFrame.new(target_Position, ball_Position)
		end
	end)
end)

--//Function AI
local function walk_to(position)
	LocalPlayer.Character.Humanoid:MoveTo(position)
end
--//Main AI
local runService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local AutoRankMode = auto_rank_mode --// Can be "aggressive", "passive", or "smart"

--// Define minimum and maximum distances for each mode
local MODE_DISTANCES = {
    Aggressive = { Min = 18, Max = 10 },
    Passive = { Min = 30, Max = 100 },
    Smart = {
        Close = { Min = 18, Max = 10 },
        Far = { Min = 20, Max = 15 }
    }
}

local function avoidWalls(startPos, targetPos)
    local direction = (targetPos - startPos).Unit
    local ray = Ray.new(startPos, direction * 10)
    local hit, hitPosition = workspace:FindPartOnRay(ray, LocalPlayer.Character)

    if hit then
        -- Wall detected, adjust path
        local adjustedDir = (targetPos - hitPosition).Unit + Vector3.new(0, 0, 0.5) -- Simple adjustment
        return startPos + adjustedDir * 10
    end

    return targetPos
end

runService.Stepped:Connect(function()
    if not auto_rank or not workspace.Alive:FindFirstChild(LocalPlayer.Name) then return end

    local self = Helper.getBall()
    if not self or not AutoParry.entity_properties then return end

    local enitiy_char = AutoParry.target.current ~= LocalPlayer and AutoParry.target.current
    if not enitiy_char then return end

    local hrp = enitiy_char:FindFirstChild('HumanoidRootPart')
    if not hrp then
        --// Walk randomly if target has no HumanoidRootPart
        walk_to(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.sin(tick()) * math.random(35, 50), 0, math.cos(tick()) * math.random(35, 50)))
        return
    end

    local tickNow = tick()
    local ball_Position = self.Position
    local ball_Distance = LocalPlayer:DistanceFromCharacter(ball_Position)
    local player_Position = LocalPlayer.Character.PrimaryPart.Position
    local target_Position = hrp.Position
    local target_Distance = LocalPlayer:DistanceFromCharacter(target_Position)
    local target_LookVector = hrp.CFrame.LookVector
    local resolved_Position = Vector3.zero

    --// Match target jump if on ground
    local target_Humanoid = enitiy_char:FindFirstChildOfClass("Humanoid")
    if target_Humanoid and target_Humanoid:GetState() == Enum.HumanoidStateType.Jumping and LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    --// Don't move if facing away from ball and ball is approaching
    if (ball_Position - player_Position):Dot(LocalPlayer.Character.PrimaryPart.CFrame.LookVector) < -0.2 and tickNow % 8 <= 4 then
        return 
    end

    --// Mode handling with distance logic
    if AutoRankMode == "Aggressive" then
        local dist = MODE_DISTANCES.Aggressive
        resolved_Position = target_Position - target_LookVector * math.random(dist.Min, dist.Max) + (player_Position - target_Position).Unit * 8 

    elseif AutoRankMode == "Passive" then
        local dist = MODE_DISTANCES.Passive
        resolved_Position = target_Position - target_LookVector * math.random(dist.Min, dist.Max) 
        if target_Distance > 20 then 
            resolved_Position =  resolved_Position + (player_Position - target_Position).Unit * 25 
        else 
            resolved_Position =  resolved_Position + player_Position 
        end

    elseif AutoRankMode == "Smart" then
        local dist = ball_Distance < 15 and target_Distance < 15 or AutoParry.ball.properties.auto_spam and MODE_DISTANCES.Smart.Close or MODE_DISTANCES.Smart.Far
        resolved_Position = target_Position - target_LookVector * math.random(dist.Min, dist.Max) 
        if ball_Distance < 15 and target_Distance < 15 or AutoParry.ball.properties.auto_spam then
            resolved_Position = resolved_Position + (player_Position - target_Position).Unit * 8 
        else
            if target_Distance > 20 then 
                resolved_Position = resolved_Position + (player_Position - target_Position).Unit * 25
            else 
                resolved_Position = resolved_Position + player_Position
            end
        end
    end

    --// Prevent getting too close to the target
    if (player_Position - target_Position).Magnitude < 8 then
        resolved_Position = target_Position + (player_Position - target_Position).Unit * 35
    end

    --// Stay close to the ball if it's nearby
    if ball_Distance < 8 then
        resolved_Position = player_Position + (player_Position - ball_Position).Unit * 10
    end

    -- Avoid walls before walking
    resolved_Position = avoidWalls(player_Position, resolved_Position)

    -- Apply a slight random movement
    walk_to(resolved_Position + Vector3.new(math.sin(tickNow) * 10, 0, math.cos(tickNow) * 10))
end)
--//Legit Hanlder
task.defer(function()
	runService.Stepped:Connect(function()
		if not auto_parry_enabled or parry_mode == "Rage" then return end

		if AutoParry.entity_properties.distance <= 30 + (AutoParry.ball.properties.speed / 5.5) and AutoParry.ball.distance <= 25 then
			if math.random(1,Legit_Thersold) == 1 then
				perform_parry()
			else
				legit_cancel = true
			end
		end
	end)
end)
local DeviceType = game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC"
if DeviceType == "Mobile" then
    local ClickButton = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local ImageLabel = Instance.new("ImageLabel")
    local TextButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local UICorner_2 = Instance.new("UICorner")

    ClickButton.Name = "ClickButton"
    ClickButton.Parent = game.CoreGui
    ClickButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ClickButton
    MainFrame.AnchorPoint = Vector2.new(1, 0)
    MainFrame.BackgroundTransparency = 0.8
    MainFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38) 
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(1, -60, 0, 10)
    MainFrame.Size = UDim2.new(0, 45, 0, 45)

    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = MainFrame

    UICorner_2.CornerRadius = UDim.new(0, 10)
    UICorner_2.Parent = ImageLabel

    ImageLabel.Parent = MainFrame
    ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel.Size = UDim2.new(0, 45, 0, 45)
    ImageLabel.Image = "rbxassetid://"

    TextButton.Parent = MainFrame
    TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
    TextButton.BackgroundTransparency = 1
    TextButton.BorderSizePixel = 0
    TextButton.Position = UDim2.new(0, 0, 0, 0)
    TextButton.Size = UDim2.new(0, 45, 0, 45)
    TextButton.AutoButtonColor = false
    TextButton.Font = Enum.Font.SourceSans
    TextButton.Text = "NW"
    TextButton.TextColor3 = Color3.new(220, 125, 255)
    TextButton.TextSize = 20

    TextButton.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "LeftControl", false, game)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "LeftControl", false, game)
    end)
end

SaveManager:SetLibrary(interface)
InterfaceManager:SetLibrary(interface)

InterfaceManager:SetFolder("NW Hub")
SaveManager:SetFolder("NW Hub/BladeBall")

InterfaceManager:BuildInterfaceSection(Tabs.Setting)
SaveManager:BuildConfigSection(Tabs.Setting)

interface:Notify({
	Title = "Loaded",
	Content = "NW Hub Successfully loaded! Have Fun!",
	Duration = 5
})