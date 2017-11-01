-- Define gamemode ammo types here

if ( SERVER ) then AddCSLuaFile() end


-- Dual pistol ammo
game.AddAmmoType( {
	force = 15,
	name = "OV_DualPistol",
	npcdmg = 15,
	plydmg = 15,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Flak ammo
game.AddAmmoType( {
	force = 50,
	name = "OV_Flak",
	npcdmg = 50,
	plydmg = 50,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Lazer Pistol ammo
game.AddAmmoType( {
	force = 20,
	name = "OV_LazerPistol",
	npcdmg = 20,
	plydmg = 20,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- M3 ammo
game.AddAmmoType( {
	force = 10,
	name = "OV_M3",
	npcdmg = 10,
	plydmg = 10,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- MP5 ammo
game.AddAmmoType( {
	force = 16,
	name = "OV_MP5",
	npcdmg = 16,
	plydmg = 16,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- P90 ammo
game.AddAmmoType( {
	force = 11,
	name = "OV_P90",
	npcdmg = 11,
	plydmg = 11,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Pistol ammo
game.AddAmmoType( {
	force = 16,
	name = "OV_Pistol",
	npcdmg = 16,
	plydmg = 16,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Silenced Pistol ammo
game.AddAmmoType( {
	force = 18,
	name = "OV_SilencedPistol",
	npcdmg = 18,
	plydmg = 18,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- Sniper ammo
game.AddAmmoType( {
	force = 75,
	name = "OV_Sniper",
	npcdmg = 75,
	plydmg = 75,
	tracer = TRACER_LINE_AND_WHIZ
} )


-- XM1014 ammo
game.AddAmmoType( {
	force = 8,
	name = "OV_XM1014",
	npcdmg = 8,
	plydmg = 8,
	tracer = TRACER_LINE_AND_WHIZ
} )
