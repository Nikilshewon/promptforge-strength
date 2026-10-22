# PromptForge Strength

Peak human strength for FiveM. Lift and throw bikes, BMX and small trash bins, plus a 10% melee damage boost.

**Standalone, works on every framework** (ESX, QBCore, Qbox, vRP, custom). No dependencies.

## Features

- Lift the nearest bicycle, BMX or small bin and carry it
- Throw it in the direction your camera is facing
- Thrown objects ragdoll and damage peds they hit
- +10% melee damage (configurable)
- Per-player enable/disable commands
- Fully configurable: keys, reach, throw power, props, vehicle classes, attach offsets

## Installation

1. Download or clone this repo
2. Place the `promptforge-strength` folder in your `resources` directory
3. Add to your `server.cfg`:

```cfg
ensure promptforge-strength
```

## Controls

| Key | Action |
| --- | --- |
| `G` | Lift the nearest object, or throw it if you're carrying one |
| `H` | Drop the carried object gently |

Players can rebind both in **Settings > Key Bindings > FiveM**.

## Commands

| Command | Description |
| --- | --- |
| `/strengthon` | Enable strength and the melee boost |
| `/strengthoff` | Disable strength, drop anything carried, reset melee damage |

The starting state is set by `Config.Enabled`.

## Configuration

Everything lives in `config.lua`.

| Option | Default | Description |
| --- | --- | --- |
| `Config.Enabled` | `true` | Default state on join |
| `Config.LiftThrowKey` | `'G'` | Lift / throw key |
| `Config.DropKey` | `'H'` | Drop key |
| `Config.MeleeDamageMultiplier` | `1.10` | Melee damage (1.10 = +10%) |
| `Config.Reach` | `2.2` | Pickup distance in meters |
| `Config.CarrySpeed` | `0.9` | Move rate while carrying |
| `Config.LiftableVehicleClasses` | cycles only | Set `[8] = true` to allow motorcycles |
| `Config.Objects` | bins and bags | Add any prop model name |
| `Config.ThrowPower` | `22 / 28` | Throw force for vehicles / objects |
| `Config.ImpactDamage` | `true` | Ragdoll and damage peds hit by thrown items |
| `Config.Attach` | see file | Carry position offsets per type |

## Notes

- Bikes are networked and sync to all players.
- Bins that are part of the map are client-side props, so other players may not see them move.
- If a carried bike clips through the body, adjust `Config.Attach.vehicle.pos` and `rot`.

## Credits

Made by **PromptForge**.

## License

Commercial license: one license per server. No resale, sharing, leaking or redistribution. See [LICENSE](LICENSE) for full terms.
