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

    owner:Horde_RemoveDropEntity( self.TurretClass, self:GetCreationID() )
    owner:Horde_AddDropEntity( self.TurretClass, ent )
    owner:Horde_AddWeight( -4 )
end

local entMeta = FindMetaTable("Entity")

function entMeta:SpawnUnweldedTurret( scale )
    local owner = self:GetOwner()
    if not IsValid( owner ) then return end

    local weldedClass = self:GetClass()

    local model = self.Model
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local color = self:GetColor()
    local skinNum = self:GetSkin()
    local mat = self:GetMaterial()

    local ent = ents.Create( "horde_unwelded_turret" )

    ent:SetPos( pos )
    ent:SetAngles( ang )

    ent:SetOwner( owner )
    ent:SetNWEntity( "HordeOwner", owner )

    ent:SetModel( model )
    ent:SetClass( weldedClass )

    ent:SetColor( color )
    ent:SetSkin( skinNum )
    if mat ~= "" then ent:SetMaterial( mat ) end
    if scale then ent:SetModelScale( scale, 0 ) end

    ent:Spawn()

    owner:Horde_AddDropEntity( weldedClass, ent )
    owner:Horde_AddWeight( -4 )
end