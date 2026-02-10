SPELL.PrintName         = "The Morrigan's Favour"
SPELL.Weapon            = { "horde_druid" }
SPELL.Mind              = { 20 }
SPELL.Price             = 1500
SPELL.ChargeTime        = { 0 }
SPELL.ChargeRelease     = true
SPELL.Cooldown          = 1
SPELL.Slot              = HORDE.Spell_Slot_Utility
SPELL.Icon              = "spells/the_morrigan_favour.png"
SPELL.Type              = { HORDE.Spell_Type_Utility }
SPELL.Description       = [[Call upon the Morrigan to grant you and your allies 20% fortify and berserk for 10 seconds.]]
SPELL.Fire              = function( ply )
    local pos = ply:GetPos()
    local duration = 10
    local radius = 200

    ply:EmitSound( "horde/player/life_diffuser.ogg", 100, 100, 1, CHAN_AUTO ) -- Need to figure out what custom sound it should have

    local effect = EffectData()
        effect:SetOrigin( pos )
        effect:SetRadius( radius + 25 )
    util.Effect( "horde_life_diffuser", effect, true, true ) -- Need to figure out what custom effect it would have

    for _, ent in pairs( ents.FindInSphere( pos, radius ) ) do
        if ent:IsPlayer() then
            ent:Horde_AddBerserk( duration )
            ent:Horde_AddFortify( duration )
        end
    end
end