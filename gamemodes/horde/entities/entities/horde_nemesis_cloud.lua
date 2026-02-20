AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Nemesis Cloud"

if not SERVER then return end

ENT.AreaRadius = 150

ENT.MinDamage = 5
ENT.HealthScaling = 0.05

ENT.StartDelay = 0.5
ENT.Delay = 0.2
ENT.DamageTicks = 10

ENT.Sound = "ambient/levels/canals/toxic_slime_sizzle2.wav"
ENT.Effect = "corruption"

-- Localize Globals for perf
local IsValid = IsValid
local CurTime = CurTime
local util_Effect = util.Effect
local math_max = math.max

local COLLISION_GROUP_IN_VEHICLE = COLLISION_GROUP_IN_VEHICLE
local MOVETYPE_VPHYSICS = MOVETYPE_VPHYSICS
local DMG_ACID = DMG_ACID

local HORDE_IsPlayerOrMinion = HORDE.IsPlayerOrMinion

local table_insert = table.insert
local table_remove = table.remove
local table_RemoveByValue = table.RemoveByValue

local entMeta = FindMetaTable( "Entity" )
local ent_GetPos = entMeta.GetPos
local ent_TakeDamageInfo = entMeta.TakeDamageInfo
local ent_Remove = entMeta.Remove
local ent_EmitSound = entMeta.EmitSound
local ent_NextThink = entMeta.NextThink
local ent_GetMaxHealth = entMeta.GetMaxHealth

local DamageInfo = DamageInfo
local dmginfoMeta = FindMetaTable( "CTakeDamageInfo" )
local dmginfo_SetDamage = dmginfoMeta.SetDamage
local dmginfo_SetAttacker = dmginfoMeta.SetAttacker
local dmginfo_SetInflictor = dmginfoMeta.SetInflictor
local dmginfo_SetDamageType = dmginfoMeta.SetDamageType
local dmginfo_SetDamagePosition = dmginfoMeta.SetDamagePosition

local EffectData = EffectData
local effectDataMeta = FindMetaTable( "CEffectData" )
local effectData_SetOrigin = effectDataMeta.SetOrigin

local vectorMeta = FindMetaTable( "Vector" )
local vector_DistToSqr = vectorMeta.DistToSqr


function ENT:Initialize()
    local vecRadius = Vector( self.AreaRadius, self.AreaRadius, self.AreaRadius )
    self:SetCollisionBounds( -vecRadius, vecRadius )
    self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
    self:SetMoveType( MOVETYPE_VPHYSICS )

    self:SetTrigger( true )
    self:UseTriggerBounds( true )
    self:SetNoDraw( true )

    self.entities = {}
    self.areaRadiusSqr = self.AreaRadius ^ 2
    self.removeAt = CurTime() + self.StartDelay + ( self.Delay * self.DamageTicks )

    ent_NextThink( self, CurTime() + self.StartDelay )
end


function ENT:StartTouch( ent )
    if HORDE_IsPlayerOrMinion( nil, ent ) then
        table_insert( self.entities, ent )
    end
end


function ENT:EndTouch( ent )
    table_RemoveByValue( self.entities, ent )
end


function ENT:Think()
    local pos = ent_GetPos( self )
    local curTime = CurTime()
    local entities = self.entities

    if #entities > 0 then
        local dmginfo = DamageInfo()
        dmginfo_SetAttacker( dmginfo, self )
        dmginfo_SetInflictor( dmginfo, self )
        dmginfo_SetDamageType( dmginfo, DMG_ACID )
        dmginfo_SetDamagePosition( dmginfo, pos )

        for i = #entities, 1, -1 do
            local ent = entities[i]

            if not IsValid( ent ) then
                table_remove( entities, i )
            elseif vector_DistToSqr( pos, ent_GetPos( ent ) ) <= self.areaRadiusSqr then
                dmginfo_SetDamage( dmginfo, math_max( self.MinDamage, self.HealthScaling * ent_GetMaxHealth( ent ) ) )
                ent_TakeDamageInfo( ent, dmginfo )
            end
        end
    end

    local effect = EffectData()
    effectData_SetOrigin( effect, pos )
    util_Effect( self.Effect, effect, true, true )

    ent_EmitSound( self, self.Sound )

    if curTime >= self.removeAt then
        ent_Remove( self )

        return true
    end

    ent_NextThink( self, curTime + self.Delay )

    return true
end