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
    local progress = repairProgressForEntity[self] or 0

    local mn, mx = self:GetRenderBounds()
    local up = ( mn - mx ):GetNormalized()
    local bottom = self:GetPos() + mn
    local top = self:GetPos() + mx

    local lerped = LerpVector( progress, bottom, top )

    local normal = up
    local distance = normal:Dot( lerped )

    if progress > 0 then
        local enabled = render.EnableClipping( true )
        render.PushCustomClipPlane( normal, distance )
        self:DrawModel()
        render.PopCustomClipPlane()
        render.EnableClipping( enabled )
    end

    if progress < 1 then
        render.MaterialOverride( wireframeMaterial )
        local enabled = render.EnableClipping( true )
        render.PushCustomClipPlane( -normal, -distance )
        self:DrawModel()
        render.PopCustomClipPlane()
        render.EnableClipping( enabled )
        render.MaterialOverride( nil )
    end
end
