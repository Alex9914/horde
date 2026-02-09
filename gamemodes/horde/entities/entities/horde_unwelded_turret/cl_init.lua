include( "shared.lua" )

local wireframeMaterial = Material( "models/wireframe" )
local repairProgressForEntity = {}

net.Receive( "WireframeRepair_UpdateProgress", function()
    local entity = net.ReadEntity()
    local progress = net.ReadFloat()

    if IsValid( entity ) then
        repairProgressForEntity[entity] = progress
    end
end )

function ENT:Draw()
    local rawProgress = repairProgressForEntity[self]

    if rawProgress then
        rawProgress = rawProgress / 100
    else
        rawProgress = 0
    end

    local visualMax = 0.82
    local targetProgress = rawProgress * visualMax

    local mn, mx = self:GetRenderBounds()
    local up = ( mn - mx ):GetNormalized()
    local bottom = self:GetPos() + mn
    local top = self:GetPos() + mx

    self.SmoothProgress = self.SmoothProgress or 0
    self.SmoothProgress = Lerp( FrameTime() * 5, self.SmoothProgress, targetProgress )

    local lerped = LerpVector( self.SmoothProgress, bottom, top )

    local normal = up
    local distance = normal:Dot( lerped )

    if self.SmoothProgress > 0 then
        local enabled = render.EnableClipping( true )
        render.PushCustomClipPlane( normal, distance )
        self:DrawModel()

        render.PopCustomClipPlane()
        render.EnableClipping( enabled )
    end

    if self.SmoothProgress < 1 then
        render.MaterialOverride( wireframeMaterial )
        local enabled = render.EnableClipping( true )
        render.PushCustomClipPlane( -normal, -distance )
        self:DrawModel()

        render.PopCustomClipPlane()
        render.EnableClipping( enabled )
        render.MaterialOverride( nil )
    end

    if rawProgress == 1 then
        repairProgressForEntity[entity] = nil
    end
end