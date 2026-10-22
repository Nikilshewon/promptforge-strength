Config = {}

Config.Enabled = true

-- Keybinds (players can rebind in Settings > Key Bindings > FiveM)
Config.LiftThrowKey = 'G'   -- lift nearest object / throw if already carrying
Config.DropKey      = 'H'   -- gently drop what you're carrying

-- Melee damage boost (1.10 = +10%)
Config.MeleeDamageMultiplier = 1.10

-- Lifting
Config.Reach = 2.2                 -- how close you must be (meters)
Config.CarrySpeed = 0.9            -- move rate while carrying (1.0 = normal)
Config.LiftTime = 700              -- ms pickup animation
Config.AllowInVehicle = false

-- Vehicle classes you can lift. 13 = cycles (bikes/BMX), 8 = motorcycles
Config.LiftableVehicleClasses = {
    [13] = true,
    [8]  = false,
}

-- Small objects you can lift (add any prop model name)
Config.Objects = {
    'prop_bin_01a', 'prop_bin_02a', 'prop_bin_03a', 'prop_bin_04a', 'prop_bin_05a',
    'prop_bin_06a', 'prop_bin_07a', 'prop_bin_07b', 'prop_bin_07c', 'prop_bin_07d',
    'prop_bin_08a', 'prop_bin_08open', 'prop_bin_10a', 'prop_bin_10b', 'prop_bin_11a',
    'prop_bin_11b', 'prop_bin_12a', 'prop_bin_13a', 'prop_bin_14a', 'prop_bin_14b',
    'prop_bin_beach_01a', 'prop_bin_beach_01d',
    'prop_cs_bin_01', 'prop_cs_bin_02', 'prop_cs_bin_03',
    'prop_rub_binbag_01', 'prop_rub_binbag_03', 'prop_ld_binbag_01', 'prop_cs_rub_binbag_01',
}

-- Throwing
Config.ThrowWindup = 350           -- ms before release
Config.ThrowPower = { vehicle = 22.0, object = 28.0 }
Config.ThrowUpward = 2.5           -- extra upward velocity

-- Impact damage on peds hit by thrown objects
Config.ImpactDamage = true
Config.ImpactRadius = 1.6
Config.ImpactMinSpeed = 4.0
Config.ImpactDamageAmount = 25
Config.ImpactRagdollMs = 2500

-- Attach offsets (tweak to taste). bone 24818 = SKEL_Spine3
Config.Attach = {
    vehicle = { bone = 24818, pos = vec3(0.0, 0.75, 0.15), rot = vec3(0.0, 0.0, 90.0) },
    object  = { bone = 24818, pos = vec3(0.0, 0.45, -0.1), rot = vec3(0.0, 0.0, 0.0) },
}

Config.CarryAnim = { dict = 'anim@heists@box_carry@', name = 'idle' }
Config.PickupAnim = { dict = 'pickup_object', name = 'pickup_low' }
Config.ThrowAnim = { dict = 'melee@large_wpn@streamed_core', name = 'ground_attack_on_spot' }
