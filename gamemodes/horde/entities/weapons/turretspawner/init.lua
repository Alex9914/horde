AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function SWEP:OnDrop()
    self:Remove()
end

function SWEP:Equip( ply )
    if IsValid( ply ) and ply:IsPlayer() then
        ply:SelectWeapon( self:GetClass() )
    end
end