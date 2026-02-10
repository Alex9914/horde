SPELL.PrintName           = "Eostre's Grove"
SPELL.Weapon              = { "horde_druid" }
SPELL.Mind                = { 20 }
SPELL.Price               = 1500
SPELL.ChargeTime          = { 0 }
SPELL.ChargeRelease       = true
SPELL.Cooldown            = 1
SPELL.Upgrades            = 4
SPELL.Upgrade_Description = "Increases heal per second by 5 and duration by 5 seconds"
SPELL.Upgrade_Prices      = function( upgradeLevel )
    return 550 + 50 * upgradeLevel
end
SPELL.Slot        = HORDE.Spell_Slot_LMB
SPELL.DamageType  = { HORDE.DMG_POISON }
SPELL.Icon        = "spells/eostre_grove.png"
SPELL.Type        = { HORDE.Spell_Type_AOE }
SPELL.Description = [[Call forth Eostre's blessing to enchant the ground around you healing 5 hp for 10 seconds around you]]
SPELL.Fire        = function( ply, wpn )
    local level = ply:Horde_GetSpellUpgrade( "eostre_grove" )
    local pos = ply:GetPos()

    local durationPerLevel = 5
    local healPerLevel = 5

    local duration = 10 + durationPerLevel * level
    local radius = 350

    local healPerSec = 5 + healPerLevel * level

    local function heal( amount )
        local healinfo = HealInfo:New( { amount = amount, healer = ply } )

        for _, ent in pairs( ents.FindInSphere( pos, radius ) ) do
            if ent:IsPlayer() then
                HORDE:OnPlayerHeal( ent, healinfo )
            elseif ent:GetClass() == "npc_vj_horde_antlion" then
                HORDE:OnAntlionHeal( ent, healinfo )
            elseif ent:IsNPC() then
                local dmg = DamageInfo()
                dmg:SetDamage( amount )
                dmg:SetDamageType( DMG_NERVEGAS )
                dmg:SetAttacker( ply )
                dmg:SetInflictor( wpn )
                dmg:SetDamagePosition( ply:GetPos() )

                ent:TakeDamageInfo( dmg )
            end
        end
    end

    local effect = EffectData()
        effect:SetOrigin( pos )
        effect:SetScale( radius )
        effect:SetMagnitude( duration )
    util.Effect( "horde_eostre_grove", effect, true, true )

    local ident = ply:SteamID64() .. ":" .. CurTime()

    timer.Create( "Horde_Eostre_Grove_Sound_" .. ident, 1, duration, function()
        sound.Play( "horde/spells/mystic_field.ogg", pos, 100, 100 )
    end )

    local interval = 1 / healPerSec
    if interval < 0.25 then
        interval = 0.25
    end

    local remainder = 0

    timer.Create( "Horde_Eostre_Grove_Heal_" .. ident, interval, math.ceil( duration / interval ), function()
        if not IsValid( ply ) then return end

        local exactHeal = healPerSec * interval
        local baseHeal = math.floor( exactHeal )
        remainder = remainder + ( exactHeal - baseHeal )

        if remainder >= 1 then
            baseHeal = baseHeal + 1
            remainder = remainder - 1
        end

        heal( baseHeal )

        if timer.RepsLeft( "Horde_Eostre_Grove_Heal_" .. ident ) == 0 and remainder > 0 then
            heal( math.ceil( remainder ) )
        end
    end )
end