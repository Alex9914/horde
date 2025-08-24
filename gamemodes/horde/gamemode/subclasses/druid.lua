SUBCLASS.PrintName = "Druid" -- Required
SUBCLASS.UnlockCost = 100
SUBCLASS.ParentClass = HORDE.Class_Warden -- Required for any new classes
SUBCLASS.Icon = "subclasses/druid.png" -- Required
SUBCLASS.Description = [[
The Old Gods have chosen their champion to help rid the world of the undead.
Scourge channel their blessings and the forces of nature to assist your fellow warriors in battle.]] -- Required
SUBCLASS.BasePerk = "druid_base"
SUBCLASS.Perks = {
    [1] = { title = "Bowel", choices = { "carcass_grappendix", "carcass_bio_thruster" } },
    [2] = { title = "Secretion", choices = { "carcass_tactical_spleen", "carcass_anabolic_gland" } },
    [3] = { title = "Limbs", choices = { "carcass_reinforced_arms", "carcass_pneumatic_legs" } },
    [4] = { title = "Core", choices = { "carcass_twin_heart", "carcass_aas_perfume" } },
} -- Required