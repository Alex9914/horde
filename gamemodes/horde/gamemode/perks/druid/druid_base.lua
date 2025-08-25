PERK.PrintName = "Druid Base"
PERK.Description = [[
The Old Gods have chosen their champion to help rid the world of the undead.
Scourge channel their blessings and the forces of nature to assist your fellow warriors in battle.]]
PERK.Icon = "materials/subclasses/druid.png"
PERK.Params = {}
PERK.Hooks = {}

PERK.Hooks.Horde_OnSetPerk = function( ply, perk )
    if not SERVER then return end
    if perk ~= "druid_base" then return end

    ply:Horde_SetMindRegenTick( 0.25 )
    ply:SetMaxArmor( 0 )

    local spellWep = "horde_druid"

    if ply:HasWeapon( spellWep ) then return end

    ply:Horde_UnsetSpellWeapon()
    ply:StripWeapons()

    timer.Simple( 0, function()
        if not ply:Alive() then return end

        ply:Give( spellWep )

        local primarySpell = ply:Horde_GetPrimarySpell()
        local secondarySpell = ply:Horde_GetSecondarySpell()
        local utilitySpell = ply:Horde_GetUtilitySpell()
        local ultimateSpell = ply:Horde_GetUltimateSpell()

        local prmySpellWep = primarySpell and primarySpell.Weapon
        local secSpellWep = secondarySpell and secondarySpell.Weapon
        local utilSpellWep = utilitySpell and utilitySpell.Weapon
        local ultSpellWep = ultimateSpell and ultimateSpell.Weapon

        if not primarySpell or ( prmySpellWep ~= nil and not table.HasValue( prmySpellWep, spellWep ) ) then
            ply:Horde_SetSpell( "brighid_blessing" )
        end

        if not secondarySpell or ( secSpellWep ~= nil and not table.HasValue( secSpellWep, spellWep ) ) then
            ply:Horde_SetSpell( "raise_spectre" )
        end

        if utilitySpell or ( utilSpellWep ~= nil and not table.HasValue( utilSpellWep, spellWep ) ) then
            ply:Horde_SetSpell( "illuminate" )
        end

        if ultimateSpell and ( ultSpellWep ~= nil and not table.HasValue( ultSpellWep, spellWep ) ) then
            ply:Horde_UnsetSpell( ultimateSpell.ClassName )
        end

        ply:Horde_RecalcAndSetMaxMind()
    end )
end

PERK.Hooks.Horde_OnUnsetPerk = function( ply, perk )
    if not SERVER then return end
    if perk ~= "druid_base" then return end

    if not ply:HasWeapon( "horde_druid" ) then return end

    ply:StripWeapon( "horde_druid" )

    ply:Horde_SetMaxMind( 0 )
    ply:Horde_SetMind( 0 )
    ply:Horde_SetMindRegenTick( 0 )
    ply:SetMaxArmor( 100 )
end