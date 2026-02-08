AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

util.AddNetworkString( "WireframeRepair_UpdateProgress" )

function ENT:Initialize()
    self:SetModel( "models/combine_turrets/floor_turret.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.RepairProgress = 0
end


function ENT:Repair( amount )
    self.RepairProgress = math.min( self.RepairProgress + amount, 1.05 )

    net.Start( "WireframeRepair_UpdateProgress" )
        net.WriteEntity( self )
        net.WriteFloat( self.RepairProgress )
    net.Broadcast()

    if self.RepairProgress > 1 then
        self:Remove()
    end
end

function ENT:Use()
    self:Repair( 0.01 )
end

function ENT:OnRemove()
    if self.RepairProgress < 1 then return end

    local ent = ents.Create( "npc_vj_horde_smg_turret" )
    ent:SetPos( self:GetPos() )
    ent:SetAngles( self:GetAngles() )
    ent:SetOwner( self:GetOwner() )
    ent:Spawn()

    ent:SetCollisionGroup( 5 )
end