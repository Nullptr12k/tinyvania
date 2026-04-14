param(
  [string]$Root = "."
)

$ErrorActionPreference = "Stop"
Set-Location $Root

$luaOrder = @(
  "src/render/palettes.lua",
  "src/shared/util.lua",
  "src/ecs/entities.lua",
  "src/entities/items.lua",
  "src/entities/interactables.lua",
  "src/entities/platforming.lua",
  "src/effects/particle_system.lua",
  "src/entities/enemies.lua",
  "src/player/constants.lua",
  "src/player/player.lua",
  "src/world/camera_map.lua",
  "src/render/map.lua",
  "src/ui/ui.lua",
  "src/core/boot.lua"
)

$luaText = ($luaOrder | ForEach-Object { Get-Content $_ -Raw }) -join "`n"

$out = @()
$out += "pico-8 cartridge // http://www.pico-8.com"
$out += "version 41"
$out += "__lua__"
$out += $luaText.TrimEnd("`r","`n")
$out += (Get-Content "assets/gfx.p8sec" -Raw).TrimEnd("`r","`n")
$out += (Get-Content "assets/gff.p8sec" -Raw).TrimEnd("`r","`n")
$out += (Get-Content "assets/map.p8sec" -Raw).TrimEnd("`r","`n")
$out += ""

New-Item -ItemType Directory -Force -Path "build" | Out-Null
Set-Content -Path "build/tinyvania.p8" -Value ($out -join "`n") -Encoding ascii

# Keep root source cart as include-based edit entrypoint
$srcCart = @(
  "pico-8 cartridge // http://www.pico-8.com",
  "version 41",
  "__lua__",
  "#include src/main.lua"
)
Set-Content -Path "tinyvania.p8" -Value (($srcCart -join "`n") + "`n") -Encoding ascii

