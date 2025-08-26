local plyMeta = FindMetaTable( "Player" )

function plyMeta:Horde_AddWindsOfTaranis( duration )
    timer.Create( "Horde_RemoveWindsOfTaranis" .. self:SteamID(), duration, 1, function()
        self:Horde_RemoveWindsOfTaranis()
    end )

    if self.Horde_WindsOfTaranis == 1 then return end
    self.Horde_WindsOfTaranis = 1

    net.Start( "Horde_SyncStatus" )
        net.WriteUInt( HORDE.Status_Winds_of_Taranis, 8 )
        net.WriteUInt( 1, 8 )
    net.Send( self )
end

function plyMeta:Horde_RemoveWindsOfTaranis()
    if not self:IsValid() then return end

    if self.Horde_WindsOfTaranis == 0 then return end
    self.Horde_WindsOfTaranis = 0

    timer.Remove( "Horde_RemoveWindsOfTaranis" .. self:SteamID() )

    net.Start( "Horde_SyncStatus" )
        net.WriteUInt( HORDE.Status_Winds_of_Taranis, 8 )
        net.WriteUInt( 0, 8 )
    net.Send( self )
end

function plyMeta:Horde_GetWindsOfTaranis()
    return self.Horde_WindsOfTaranis or 0
end

hook.Add( "Horde_PlayerMoveBonus", "Horde_WindsOfTaranisSpeed", function( ply, bonusWalk, bonusRun, bonusJump )
    if ply:Horde_GetWindsOfTaranis() == 1 then
        local bonus2 = 0.2 * ( 1 + ply:Horde_GetApplyBuffMore() )
        bonusWalk.increase = bonusWalk.increase + bonus2
        bonusRun.increase = bonusRun.increase + bonus2
        bonusJump.increase = bonusJump.increase + bonus2
    end
end )

hook.Add( "Horde_OnPlayerDamageTaken", "Horde_WindsOfTaranisEvasion", function( ply, _, bonus )
    if ply:Horde_GetWindsOfTaranis() == 1 then
        bonus.evasion = bonus.evasion + 0.20
    end
end )

hook.Add( "Horde_ResetStatus", "Horde_WindsOfTaranisReset", function( ply )
    ply.Horde_WindsOfTaranis = 0
end )