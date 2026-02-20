MUTATION.PrintName = "Nemesis"
MUTATION.Description = "Leaves behind poisonous clouds on death.\nClouds deal Poison damage based on victim's health."

MUTATION.Hooks = {}

MUTATION.Hooks.Horde_OnSetMutation = function(ent, mutation)
    if mutation == "nemesis" then
        if SERVER then
            local e = ents.Create("obj_mutation_nemesis")
            local col_min, col_max = ent:GetCollisionBounds()
            local height = math.abs(col_min.z - col_max.z)
            local p = ent:GetPos()
            p.z = p.z + height / 2
            e:SetPos(p)
            e:SetParent(ent)
            ent.Horde_Nemesis_Orb = e
        end
    end
end

MUTATION.Hooks.Horde_OnEnemyKilled = function(victim, killer, weapon)
    if victim:Horde_HasMutation("nemesis") then
        local victim_pos = victim:GetPos()

        local ent = ents.Create( "horde_nemesis_cloud" )
        ent:SetPos( victim_pos )
        ent:Spawn()
    end
end

MUTATION.Hooks.Horde_OnUnsetMutation = function (ent, mutation)
    if not ent:IsValid() or mutation ~= "nemesis" then return end
    if SERVER then
        ent.Horde_Nemesis_Orb:Remove()
    end
    ent:StopParticles()
end