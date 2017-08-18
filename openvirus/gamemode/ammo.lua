-- Define gamemode ammo types here

if ( SERVER ) then AddCSLuaFile() end


-- Dual pistol ammo
game.AddAmmoType( {
	force = 1000,
	name = "OV_DualPistol",
	npcdmg = 10,
	plydmg = 10,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Flak ammo
game.AddAmmoType( {
	force = 8000,
	name = "OV_Flak",
	npcdmg = 75,
	plydmg = 75,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Lazer Pistol ammo
game.AddAmmoType( {
	force = 1500,
	name = "OV_LazerPistol",
	npcdmg = 18,
	plydmg = 18,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Lazer Rifle ammo
game.AddAmmoType( {
	force = 2000,
	name = "OV_LazerRifle",
	npcdmg = 12,
	plydmg = 12,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- M3 ammo
game.AddAmmoType( {
	force = 3000,
	name = "OV_M3",
	npcdmg = 7,
	plydmg = 7,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- MP5 ammo
game.AddAmmoType( {
	force = 2000,
	name = "OV_MP5",
	npcdmg = 11,
	plydmg = 11,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- P90 ammo
game.AddAmmoType( {
	force = 2000,
	name = "OV_P90",
	npcdmg = 7,
	plydmg = 7,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Pistol ammo
game.AddAmmoType( {
	force = 1000,
	name = "OV_Pistol",
	npcdmg = 15,
	plydmg = 15,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Silenced Pistol ammo
game.AddAmmoType( {
	force = 1000,
	name = "OV_SilencedPistol",
	npcdmg = 14,
	plydmg = 14,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Sniper ammo
game.AddAmmoType( {
	force = 4000,
	name = "OV_Sniper",
	npcdmg = 40,
	plydmg = 40,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- XM1014 ammo
game.AddAmmoType( {
	force = 3000,
	name = "OV_XM1014",
	npcdmg = 5,
	plydmg = 5,
	tracer = TRACER_LINE_AND_WHIZ
} )
