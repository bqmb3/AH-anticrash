local enabled: boolean = true
local whitelistedMeshes = string.split(game:HttpGet("https://raw.githubusercontent.com/bqmb3/AH-anticrash/main/whitelistedMeshes.txt", true), '\n')
local plr = game:GetService('Players').LocalPlayer
local RunService = game:GetService('RunService')

local newInstanceEvent
local detectedCrashParts = {}
local disabledDuplicates = {}
local duplicatedPos = {}
local disabledMeshes = {}
local disabledSeats = {}
local disabledEffects = {}
local disabledHumanoids = {}
local antiCrashConnections = {}

function sanitizeObject(v)
	if _G.DisableLongName and v:IsA('Humanoid') then
		table.insert(antiCrashConnections, v:GetPropertyChangedSignal("DisplayName"):Connect(function()
			if string.len(v.Parent.Name) > 512 or string.len(v.DisplayName) > 512 then
				disabledHumanoids[v] = v.DisplayDistanceType
				v.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
		end))
		if string.len(v.Parent.Name) > 512 or string.len(v.DisplayName) > 512 then
			disabledHumanoids[v] = v.DisplayDistanceType
			v.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end
    if v:IsA('BasePart') then
		local roundedPos = Vector3.new(math.round(v.Position.X), math.round(v.Position.Y), math.round(v.Position.Z))
        if duplicatedPos[roundedPos] then
            duplicatedPos[roundedPos] += 1
            if duplicatedPos[roundedPos] >= 16 and v.Locked ~= true then
				if _G.GlobalAntiCrash then
					table.insert(detectedCrashParts, v)
				end
                disabledDuplicates[v] = v.Parent
                coroutine.wrap(function()
                    task.wait()
                    v.Parent = game.Lighting
                end)()
            end
        else
            duplicatedPos[roundedPos] = 1
        end
    end
	if _G.DisableMeshes and (v:IsA('SpecialMesh') or v:IsA('MeshPart')) then
		if table.find(whitelistedMeshes, tonumber(tostring(v.MeshId:gsub('%D+', '')))) == nil == false and not (v:FindFirstAncestorOfClass('Model') and v:FindFirstAncestorOfClass('Model'):FindFirstChildOfClass('Humanoid')) then
			disabledMeshes[v] = v.MeshId
			v.MeshId = ''
			table.insert(antiCrashConnections, v:GetPropertyChangedSignal("MeshId"):Connect(function()
				if table.find(whitelistedMeshes, tonumber(tostring(v.MeshId:gsub('%D+', '')))) == nil then
					disabledMeshes[v] = v.MeshId
					v.MeshId = ''
				end
			end))
		end
	elseif _G.DisableSeats and (v:IsA('Seat') or v:IsA('VehicleSeat')) and not v.Disabled then
		v.Disabled = true
		local sitClick = Instance.new('ClickDetector', v)
		sitClick.MouseClick:Connect(function()
			v:Sit(plr.Character:FindFirstChildOfClass('Humanoid'))
		end)
		disabledSeats[v] = sitClick
	elseif _G.DisableEffects and (v:IsA('Fire') or v:IsA('Smoke') or (v:IsA('ParticleEmitter') and v.Texture == 'rbxassetid://2977044760')) then
		disabledEffects[v] = v.Enabled
		v.Enabled = false
	end
end

function setEnabled(v: boolean)
	if enabled == v then return end
    enabled = v
	if enabled then
		for _, v in pairs(workspace:GetDescendants()) do
			sanitizeObject(v)
		end
		newInstanceEvent = workspace.DescendantAdded:Connect(sanitizeObject)
        if _G.DisableForceViewCam then
            RunService:BindToRenderStep("antiCrash", 1, function()
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                workspace.CurrentCamera.CameraSubject = plr.Character:FindFirstChildOfClass('Humanoid')
            end)
        end
	else
		newInstanceEvent:Disconnect()
        if _G.DisableForceViewCam then
            RunService:UnbindFromRenderStep("antiCrash") 
        end
		for _, eventfunc in pairs(antiCrashConnections) do
			eventfunc:Disconnect()
		end
		for meshObj, meshId in pairs(disabledMeshes) do
			if meshObj.Parent then
				meshObj.MeshId = meshId
			end
		end
		for seatObj, sitClick in pairs(disabledSeats) do
			if seatObj.Parent then
				seatObj.Disabled = false
				sitClick:Destroy()
			end
		end
		for effect, effectVisiblity in pairs(disabledEffects) do
			if effect.Parent then
				effect.Enabled = effectVisiblity
			end
		end
        for dupe, dupeParent in pairs(disabledDuplicates) do
			if dupe and dupe.Parent then
                dupe.Parent = dupeParent
            end
		end
		for humObj, humType in pairs(disabledHumanoids) do
			if humObj and humObj.Parent then
				humObj.DisplayDistanceType = humType
            end
		end
		for _, v in pairs(game.Lighting:GetChildren()) do
			if not v:IsA('SunRaysEffect') then
				v.Parent = workspace
			end
		end
        disabledDuplicates = {}
        duplicatedPos = {}
		disabledMeshes = {}
		disabledSeats = {}
		disabledEffects = {}
		disabledHumanoids = {}
		antiCrashConnections = {}
	end
    return enabled
end

if _G.SafeServerHop then
---@diagnostic disable-next-line: undefined-global
    queue_on_teleport(([[
        _G.DisableMeshes = %*
        _G.GlobalAntiCrash = %*
        _G.DisableLongName = %*
        _G.DisableEffects = %*
        _G.DisableSeats = %*
        _G.DisableForceViewCam = %*
        _G.SafeServerHop = true
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/AH-anticrash/main/main.lua",true))()
    ]]):format(_G.DisableMeshes, _G.GlobalAntiCrash, _G.DisableLongName, _G.DisableEffects, _G.DisableSeats, _G.DisableForceViewCam))
end

return {
    isEnabled = function() return enabled end,
    setEnabled = function(v: boolean) return setEnabled(v) end,
    enable = function() return setEnabled(true) end,
    disable = function() return setEnabled(false) end,
    toggle = function() return setEnabled(not enabled) end
}