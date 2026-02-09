AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

util.AddNetworkString( "WireframeRepair_UpdateProgress" )

function ENT:Initialize()
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_NONE )
    self:SetSolidFlags( FSOLID_TRIGGER )
    self:SetCollisionGroup( 0 )

    self.RepairProgress = 0
end

function ENT:SetClass( class )
    self.TurretClass = class
end

function ENT:Repair( amount )
    self.RepairProgress = math.min( self.RepairProgress + amount, 100 )

    net.Start( "WireframeRepair_UpdateProgress" )
        net.WriteEntity( self )
        net.WriteFloat( self.RepairProgress )
    net.Broadcast()

    if self.RepairProgress >= 100 then
        self:Remove()
    end
end

function ENT:Use()
    self:Repair( 2 )
end

function ENT:OnRemove()
    if self.RepairProgress < 100 then return end
    if not self.TurretClass then return end

    local owner = self:GetOwner()
    if not IsValid( owner ) then return end

    local ent = ents.Create( self.TurretClass )
    if not IsValid( ent ) then return end

    ent:SetPos( self:GetPos() )
    ent:SetAngles( self:GetAngles() )

    ent:SetOwner( owner )
    ent:SetNWEntity( "HordeOwner", owner )

    ent:SetCollisionGroup( 5 )

    ent:Spawn()

    owner:Horde_AddDropEntity( ent:GetClass(), ent )
end

function HORDE:SpawnUnweldedTurret( owner, weldedClass, model, pos, ang, scale )
    local ent = ents.Create( "horde_unwelded_turret" )

    ent:SetPos( pos )
    ent:SetAngles( ang )

    ent:SetOwner( owner )
    ent:SetNWEntity( "HordeOwner", owner )

    ent:SetModel( model )
    ent:SetClass( weldedClass )

    if scale then
        ent:SetModelScale( scale, 0 )
    end

    ent:Spawn()
end