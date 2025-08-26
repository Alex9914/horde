SPELL.PrintName       = "Brighid's Blessing"
SPELL.Weapon          = { "horde_druid" }
SPELL.Mind            = { 20, 30, 40 }
SPELL.Price           = 1500
SPELL.ChargeTime      = { 0.5, 1, 1.5 }
SPELL.ChargeRelease   = nil
SPELL.Cooldown        = 10
SPELL.Slot            = HORDE.Spell_Slot_LMB
SPELL.DamageType      = { HORDE.DMG_POISON }
SPELL.Icon            = "spells/brighid_blessing.png"
SPELL.Type            = { HORDE.Spell_Type_AOE }
SPELL.Description     = [[Heals 5 hp, increases healing by 5 per charge]]
SPELL.Fire            = function( ply, wpn, charge_stage )
    ply:EmitSound( "horde/player/life_diffuser.ogg", 100, 100, 1, CHAN_AUTO ) -- Need to figure out what custom sound it should have

    local tr = HORDE:traceSolidIgnoreAllies( ply )
    if not tr.Hit then return end
    local pos = tr.HitPos

    local effect = EffectData()
        effect:SetOrigin( pos )
        effect:SetRadius( 325 )
    util.Effect( "horde_life_diffuser", effect, true, true ) -- Need to figure out what custom effect it would have

    local healinfo = HealInfo:New( { amount = 5 * charge_stage, healer = ply } )

    for _, ent in pairs( ents.FindInSphere( ply:GetPos(), 300 ) ) do
        if ent:IsPlayer() then
            HORDE:OnPlayerHeal( ent, healinfo )
        elseif ent:GetClass() == "npc_vj_horde_antlion" then
            HORDE:OnAntlionHeal( ent, healinfo )
        elseif ent:IsNPC() then
            local dmg = DamageInfo()
            dmg:SetDamage( 5 * charge_stage )
            dmg:SetDamageType( DMG_NERVEGAS )
            dmg:SetAttacker( ply )
            dmg:SetInflictor( wpn )
            dmg:SetDamagePosition( ply:GetPos() )
            ent:TakeDamageInfo( dmg )
        end
    end
end