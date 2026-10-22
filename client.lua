local enabled = Config.Enabled

local carrying = nil   -- { entity = handle, kind = 'vehicle' | 'object' }
local busy = false

local objectHashes = {}
for _, m in ipairs(Config.Objects) do objectHashes[joaat(m)] = true end

---------------------------------------------------------------- helpers
local function loadAnim(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    local t = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < t do Wait(0) end
end

local function requestControl(ent)
    local t = GetGameTimer() + 2000
    while not NetworkHasControlOfEntity(ent) and GetGameTimer() < t do
        NetworkRequestControlOfEntity(ent)
        Wait(0)
    end
    return NetworkHasControlOfEntity(ent)
end

local function camDirection()
    local rot = GetGameplayCamRot(2)
    local pitch, yaw = math.rad(rot.x), math.rad(rot.z)
    return vec3(-math.sin(yaw) * math.cos(pitch), math.cos(yaw) * math.cos(pitch), math.sin(pitch))
end

local function findTarget()
    local ped = PlayerPedId()
    local pc = GetEntityCoords(ped)
    local best, bestDist, bestKind = nil, Config.Reach, nil

    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if Config.LiftableVehicleClasses[GetVehicleClass(veh)]
            and not IsEntityAttached(veh)
            and GetPedInVehicleSeat(veh, -1) == 0
            and GetVehicleNumberOfPassengers(veh) == 0 then
            local d = #(pc - GetEntityCoords(veh))
            if d < bestDist then best, bestDist, bestKind = veh, d, 'vehicle' end
        end
    end

    for _, obj in ipairs(GetGamePool('CObject')) do
        if objectHashes[GetEntityModel(obj)] and not IsEntityAttached(obj) then
            local d = #(pc - GetEntityCoords(obj))
            if d < bestDist then best, bestDist, bestKind = obj, d, 'object' end
        end
    end

    return best, bestKind
end

---------------------------------------------------------------- lift / drop / throw
local function lift(ent, kind)
    busy = true
    local ped = PlayerPedId()

    if not requestControl(ent) then busy = false return end

    TaskTurnPedToFaceEntity(ped, ent, 400)
    Wait(400)
    loadAnim(Config.PickupAnim.dict)
    TaskPlayAnim(ped, Config.PickupAnim.dict, Config.PickupAnim.name, 8.0, -8.0, Config.LiftTime, 0, 0, false, false, false)
    Wait(Config.LiftTime)

    if not DoesEntityExist(ent) then busy = false return end

    SetEntityAsMissionEntity(ent, true, true)
    FreezeEntityPosition(ent, false)
    local a = Config.Attach[kind]
    AttachEntityToEntity(ent, ped, GetPedBoneIndex(ped, a.bone),
        a.pos.x, a.pos.y, a.pos.z, a.rot.x, a.rot.y, a.rot.z,
        false, false, false, false, 2, true)

    loadAnim(Config.CarryAnim.dict)
    TaskPlayAnim(ped, Config.CarryAnim.dict, Config.CarryAnim.name, 8.0, -8.0, -1, 49, 0, false, false, false)

    carrying = { entity = ent, kind = kind }
    busy = false
end

local function release()
    if not carrying then return end
    local ent = carrying.entity
    if DoesEntityExist(ent) then DetachEntity(ent, true, true) end
    ClearPedTasks(PlayerPedId())
    SetPedMoveRateOverride(PlayerPedId(), 1.0)
    carrying = nil
end

local function impactWatch(ent)
    CreateThread(function()
        local hit = {}
        local endAt = GetGameTimer() + 2500
        local self = PlayerPedId()
        while GetGameTimer() < endAt and DoesEntityExist(ent) do
            if #(GetEntityVelocity(ent)) > Config.ImpactMinSpeed then
                local ec = GetEntityCoords(ent)
                for _, p in ipairs(GetGamePool('CPed')) do
                    if p ~= self and not hit[p] and not IsPedDeadOrDying(p, true)
                        and #(ec - GetEntityCoords(p)) < Config.ImpactRadius then
                        hit[p] = true
                        SetPedToRagdoll(p, Config.ImpactRagdollMs, Config.ImpactRagdollMs, 0, false, false, false)
                        ApplyDamageToPed(p, Config.ImpactDamageAmount, false)
                    end
                end
            end
            Wait(50)
        end
    end)
end

local function throw()
    if not carrying or busy then return end
    busy = true
    local ped = PlayerPedId()
    local ent, kind = carrying.entity, carrying.kind

    loadAnim(Config.ThrowAnim.dict)
    TaskPlayAnim(ped, Config.ThrowAnim.dict, Config.ThrowAnim.name, 8.0, -8.0, 700, 48, 0, false, false, false)
    Wait(Config.ThrowWindup)

    if DoesEntityExist(ent) then
        DetachEntity(ent, true, true)
        SetEntityNoCollisionEntity(ent, ped, true)
        ActivatePhysics(ent)
        local dir = camDirection()
        local power = Config.ThrowPower[kind]
        SetEntityVelocity(ent, dir.x * power, dir.y * power, dir.z * power + Config.ThrowUpward)
        if Config.ImpactDamage then impactWatch(ent) end
        SetTimeout(1000, function()
            if DoesEntityExist(ent) then SetEntityNoCollisionEntity(ent, ped, false) end
        end)
    end

    SetPedMoveRateOverride(ped, 1.0)
    carrying = nil
    busy = false
end

---------------------------------------------------------------- input
RegisterCommand('pf_strength_lift', function()
    if not enabled or busy then return end
    local ped = PlayerPedId()
    if carrying then throw() return end
    if IsPedInAnyVehicle(ped, false) and not Config.AllowInVehicle then return end
    if IsPedDeadOrDying(ped, true) or IsPedRagdoll(ped) then return end

    local ent, kind = findTarget()
    if ent then lift(ent, kind) end
end, false)

RegisterCommand('pf_strength_drop', function()
    if carrying and not busy then release() end
end, false)

RegisterCommand('strengthon', function()
    enabled = true
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), Config.MeleeDamageMultiplier)
    TriggerEvent('chat:addMessage', { args = { 'Strength', 'Enabled' } })
end, false)

RegisterCommand('strengthoff', function()
    enabled = false
    release()
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    TriggerEvent('chat:addMessage', { args = { 'Strength', 'Disabled' } })
end, false)

RegisterKeyMapping('pf_strength_lift', 'Strength: lift / throw', 'keyboard', Config.LiftThrowKey)
RegisterKeyMapping('pf_strength_drop', 'Strength: drop', 'keyboard', Config.DropKey)

---------------------------------------------------------------- carry loop
CreateThread(function()
    while true do
        if carrying then
            local ped = PlayerPedId()
            local ent = carrying.entity

            if not DoesEntityExist(ent) or IsPedDeadOrDying(ped, true)
                or IsPedRagdoll(ped) or IsPedInAnyVehicle(ped, false) or not IsEntityAttachedToEntity(ent, ped) then
                release()
            else
                DisableControlAction(0, 22, true)  -- jump
                DisableControlAction(0, 21, true)  -- sprint
                DisableControlAction(0, 24, true)  -- attack
                DisableControlAction(0, 25, true)  -- aim
                DisableControlAction(0, 23, true)  -- enter vehicle
                DisableControlAction(0, 44, true)  -- cover
                SetPedMoveRateOverride(ped, Config.CarrySpeed)
                if not busy and not IsEntityPlayingAnim(ped, Config.CarryAnim.dict, Config.CarryAnim.name, 3) then
                    TaskPlayAnim(ped, Config.CarryAnim.dict, Config.CarryAnim.name, 8.0, -8.0, -1, 49, 0, false, false, false)
                end
            end
            Wait(0)
        else
            Wait(250)
        end
    end
end)

---------------------------------------------------------------- melee boost
CreateThread(function()
    while true do
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), enabled and Config.MeleeDamageMultiplier or 1.0)
        Wait(1000)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    release()
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
end)
