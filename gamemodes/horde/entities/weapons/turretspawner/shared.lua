SWEP.PrintName = "Packed Turret"
SWEP.Author = "Alex9914"
SWEP.Instructions = "Testing tool for now"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary = SWEP.Primary

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.GhostModel = "models/props_combine/combine_mine01.mdl"

SWEP.LastTurret = nil

function SWEP:Holster()
    return false
end

local function getTrace( owner )
    local tr = util.TraceLine( {
        start = owner:EyePos(),
        endpos = owner:EyePos() + owner:GetAimVector() * 100,
        filter = { "prop_static", "prop_dynamic" },
        whitelist = true,
        mask = MASK_SOLID,
    } )

    return tr.Hit, tr.HitPos
end

local function checkValid( pos )
    local mins = Vector( -20, -20, 0 )
    local maxs = Vector( 20, 20, 72 )

    local tr = util.TraceHull( {
        start = pos,
        endpos = pos,
        mins = mins,
        maxs = maxs,
        filter = function( ent )
            if not IsValid( ent ) then return true end
            if ent:IsPlayer() then return false end
            if ent:IsNPC() then
                if IsValid( ent:GetNWEntity( "HordeOwner" ) ) then return false end
                local entOwner = ent:GetOwner()
                if IsValid( entOwner ) and entOwner:IsPlayer() then return false end
            end

            return true
        end,
        mask = MASK_PLAYERSOLID,
    } )

    if not tr.Hit then
        debugoverlay.Box( pos, mins, maxs, 0, Color( 0, 255, 0, 100 ) )
    else
        debugoverlay.Box( pos, mins, maxs, 0, Color( 255, 0, 0, 100 ) )
    end

    return not tr.Hit
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local owner = self:GetOwner()

    local hit, pos = getTrace( owner )
    if not hit or not checkValid( pos ) then
        owner:EmitSound( "items/suitchargeno1.wav" )

        return
    end

    if IsValid( self.LastTurret ) then self.LastTurret:Remove() end

    local ent = ents.Create( "horde_unwelded_turret" )
    self.LastTurret = ent
    local ang = Angle( 0, owner:EyeAngles().y, 0 )

    ent:SetPos( pos )
    ent:SetAngles( ang )
    ent:SetOwner( owner )
    ent:Spawn()

    ent:SetCollisionGroup( 0 )
    ent:SetSolid( SOLID_NONE )
    ent:SetSolidFlags( FSOLID_TRIGGER )
end

if not CLIENT then return end

local red = Color( 255, 0, 0 )
local green = Color( 0, 255, 0 )

local hoveringGhostDown = Vector( 0, 0, 25 )

function SWEP:UpdateGhostModel()
    local owner = self:GetOwner()
    if not IsValid( owner ) then return end

    if not self.Ghost then
        self:CreateGhostModel()
    end

    local hit, pos = getTrace( owner )

    if hit then
        if checkValid( pos ) then
            self.Ghost:SetColor( green )
        else
            self.Ghost:SetColor( red )
        end
    else
        pos = owner:EyePos() + owner:GetAimVector() * 75 - hoveringGhostDown
        self.Ghost:SetColor( red )
    end

    self.Ghost:SetPos( pos )
    self.Ghost:SetAngles( Angle( 0, owner:EyeAngles().y, 0 ) )
end