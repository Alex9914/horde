PERK.PrintName = "Druid Base"
PERK.Description = [[
This doesn't do anything yet]]
PERK.Icon = "materials/subclasses/druid.png"
PERK.Params = {}
PERK.Hooks = {}

PERK.Hooks.Horde_OnSetPerk = function( ply, perk )
    if not SERVER then return end
    if perk ~= "druid_1_1" then return end
end

PERK.Hooks.Horde_OnUnsetPerk = function( ply, perk )
    if not SERVER then return end
    if perk ~= "druid_1_1" then return end
end