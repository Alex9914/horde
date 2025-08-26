SPELL.PrintName           = "Brighid's Blessing"
SPELL.Weapon              = { "horde_druid" }
SPELL.Mind                = { 20, 30, 40 }
SPELL.Price               = 1500
SPELL.ChargeTime          = { 0.5, 1, 1.5 }
SPELL.ChargeRelease       = nil
SPELL.Cooldown            = 1
SPELL.Upgrades            = 4
SPELL.Upgrade_Description = "Increases healing by 3 per level"
SPELL.Upgrade_Prices      = function( upgradeLevel )
    return 550 + 50 * upgradeLevel
end
SPELL.Slot        = HORDE.Spell_Slot_LMB
SPELL.DamageType  = { HORDE.DMG_POISON }
SPELL.Icon        = "spells/brighid_blessing.png"
SPELL.Type        = { HORDE.Spell_Type_AOE }
SPELL.Description = [[Heals the target for 5 HP per charge, increasing by 5 HP with each additional charge. Healing scales with upgrades]]
SPELL.Fire        = function( ply, wpn, chargeLevel )
    local tr = HORDE:traceSolidIgnoreAllies( ply )
    if not tr.Hit then return end
    local pos = tr.HitPos

    local level = ply:Horde_GetSpellUpgrade( "brighid_blessing" )

    local baseHeal = 5
    local healPerLevel = 3 * level
    local healAmount = ( baseHeal + healPerLevel ) * chargeLevel

    local healRadius = 300

    local healingAsDamage = 0.25 -- Healing percentage dealt as damage to enemies within the heal

    ply:EmitSound( "horde/player/life_diffuser.ogg", 100, 100, 1, CHAN_AUTO ) -- Need to figure out what custom sound it should have

    local effect = EffectData()
        effect:SetOrigin( pos )
        effect:SetRadius( healRadius + 25 )
    util.Effect( "horde_life_diffuser", effect, true, true ) -- Need to figure out what custom effect it would have

    local healinfo = HealInfo:New( { amount = healAmount, healer = ply } )

    for _, ent in pairs( ents.FindInSphere( ply:GetPos(), 300 ) ) do
        if ent:IsPlayer() then
            HORDE:OnPlayerHeal( ent, healinfo )
        elseif ent:GetClass() == "npc_vj_horde_antlion" then
            HORDE:OnAntlionHeal( ent, healinfo )
        elseif ent:IsNPC() then
            local dmg = DamageInfo()
            dmg:SetDamage( healAmount * healingAsDamage )
            dmg:SetDamageType( DMG_NERVEGAS )
            dmg:SetAttacker( ply )
            dmg:SetInflictor( wpn )
            dmg:SetDamagePosition( ply:GetPos() )

            ent:TakeDamageInfo( dmg )
        end
    end
end