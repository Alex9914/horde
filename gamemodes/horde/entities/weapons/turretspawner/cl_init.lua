include( "shared.lua" )

function SWEP:CreateGhostModel()
    if IsValid( self.Ghost ) then return end

    self.Ghost = ClientsideModel( "models/Combine_turrets/Floor_turret.mdl" )
    self.Ghost:SetMaterial( "models/wireframe" )
    self.Ghost:SetColor( red )
end

function SWEP:RemoveGhostModel()
    if IsValid( self.Ghost ) then
        self.Ghost:Remove()
        self.Ghost = nil
    end
end

function SWEP:OnRemove()
    self:RemoveGhostModel()
    LocalPlayer():ConCommand( "lastinv" )
end

function SWEP:Think()
    self:UpdateGhostModel()

    self:NextThink( CurTime() )
end