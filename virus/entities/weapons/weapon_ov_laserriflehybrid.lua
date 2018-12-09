-- Laser Rifle (Hybrid)

SWEP.PrintName = "#weapon_ov_laserriflehybrid"


SWEP.Category				= "GMod Tower Tribute"
SWEP.Author				= "Babel Industries"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= "Equipped with a zoom function, this gun is slightly smarter than the average gun."
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "RCP-120"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 2				-- Slot in the weapon selection menu
SWEP.SlotPos				= 21			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= true		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= true		-- set false if you want no crosshair
SWEP.Weight				= 30			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "ar2"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles

SWEP.DisableChambering = true
SWEP.CanBeSilenced		= false
SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_rcp120.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/w_rcp120.mdl"	-- Weapon world model
SWEP.Base				= "tfa_gun_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false
SWEP.Akimbo = false




SWEP.Primary.Sound			= Sound("Weapon_RCP120.Fire")		-- Script that calls the primary fire sound
SWEP.Primary.RPM			= 1100			-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 120		-- Size of a clip
SWEP.Primary.DefaultClip		= 480		-- Bullets you start with
SWEP.Primary.KickUp				= 0.15		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.15		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.15		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= true	-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "ar2"			-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet. Use AirboatGun for a light metal peircing shotgun pellets

SWEP.Secondary.IronFOV			= 54		-- How much you 'zoom' in. Less is more! 	

SWEP.IronSightsSensitivity = 0.6

SWEP.data 				= {}				--The starting firemode
SWEP.data.ironsights			= 1

SWEP.Primary.NumShots	= 1		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 20	-- Base damage per bullet
SWEP.Primary.Spread		= .025	-- Define from-the-hip accuracy 1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = .005 -- Ironsight accuracy, should be the same for shotguns

SWEP.Primary.SpreadMultiplierMax = 1.5 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = 1/3.5 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = 3 --How much the spread recovers, per second.

-- Enter iron sight info and bone mod info below
SWEP.SightsPos = Vector(-2.88, -3.796, 1.34)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector()
SWEP.RunSightsAng = Vector()
SWEP.InspectPos = Vector(2.759, -1.328, 0.36)
SWEP.InspectAng = Vector(5.785, 26.798, 0)
SWEP.Offset = {
        Pos = {
        Up = 0,
        Right = 1,
        Forward = -10,
        },
        Ang = {
        Up = 0,
        Right = -3,
        Forward = 175,
        },
		Scale = 1.0
}

SWEP.VElements = {
	["Screen"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "Weapon", rel = "", pos = Vector(0.01, -4.171, -0.055), angle = Angle(0, -90, 0), size = Vector(0.028, 0.028, 0.028), color = Color(255, 255, 255, 255), surpresslightning = false, material = "!tfa_rtmaterial", skin = 0, bodygroup = {} },
	["HudA"] = { type = "Quad", bone = "Weapon", rel = "", pos = Vector(-0.072, -3.790, -0.110), angle = Angle(180, 0.1, 0), size = 0.01, draw_func = function( weapon )
	
		if ( weapon:Clip1() < 41 ) then
			draw.SimpleText(""..weapon:Clip1(), "default", 0, 0, Color(255,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		else 
			draw.SimpleText(""..weapon:Clip1(), "default", 0, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
		
	end	},
	["HudB"] = { type = "Quad", bone = "Weapon", rel = "", pos = Vector(-0.31, -3.793, -0.110), angle = Angle(180, 0.1, 0), size = 0.01, draw_func = function( weapon )
		
		if ( weapon:Ammo1() < 121 ) then
			draw.SimpleText(""..weapon:Ammo1(), "default", 0, 0, Color(255,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			
		else 
			draw.SimpleText(""..weapon:Ammo1(), "default", 0, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
		
	end }
}


--- RT Stuff ---

local function  drawFilledCircle( x, y, radius, seg )
	local kirkle = {}

	table.insert(kirkle, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert(kirkle, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert(kirkle, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly(kirkle)
end
	
local weaponcol = Color(0.435*255,0.10*255,0.7*255,255)

local ceedee = {}

SWEP.RTMaterialOverride = -1 --the number of the texture, which you subtract from GetAttachment

SWEP.RTOpaque = true

local g36
if surface then
	g36 = surface.GetTextureID("effects/combine_binocoverlay") --the texture you vant to use
end

SWEP.RTCode = function( self, mat )
	
	render.OverrideAlphaWriteEnable( true, true)
	surface.SetDrawColor(color_white)
	surface.DrawRect(-256,-256, ScrW() ,ScrH())
	render.OverrideAlphaWriteEnable( true, true)
	
	local ang = self.Owner:EyeAngles()
	
	local AngPos = self.Owner:GetViewModel():GetAttachment(0)
	
	if AngPos then
	
		ang = AngPos.Ang
		
		ang:RotateAroundAxis(ang:Right(), 0)

		end
	
	ceedee.x = 0
	ceedee.y = 0
	ceedee.w =  ScrW() 
	ceedee.h =  ScrH() 
	ceedee.fov = 7.0
	ceedee.drawviewmodel = false
	ceedee.drawhud = false
	
	
	if self.CLIronSightsProgress>0.01 then
		render.RenderView(ceedee)
	end
		
	render.OverrideAlphaWriteEnable( false, true)
	
	
	cam.Start2D()
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(color_black,0))
		surface.DrawTexturedRect(0,0,ScrW(),ScrH())
		surface.SetDrawColor(color_white)
		surface.SetTexture(g36)
		surface.DrawTexturedRect(-500,-500,2048,2048)
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(color_black,(1-self.CLIronSightsProgress)*255))
		surface.DrawTexturedRect(0,0,ScrW(),ScrH())
	cam.End2D()
	
end