HORDE.MapAchievements = HORDE.MapAchievements or {}
HORDE.GlobalAchievements = HORDE.GlobalAchievements or {}

local ACH_PATH = "zmod_horde/achievements.json"
local DEFAULT_MAP = "z_default" -- To store created achievements to copy from
local CURRENT_MAP = game.GetMap() or "unknown"

local globalAchOrder = 1
function HORDE:CreateGlobalAchievement( id, cat, title, desc )
    if not id or not cat or not desc then return end

    HORDE.GlobalAchievements[id] = {
        order = globalAchOrder,
        cat = cat,
        title = title,
        desc = desc,
        unlocked = false
    }

    globalAchOrder = globalAchOrder + 1
end

local mapAchOrder = 1
function HORDE:CreateMapAchievement( id, cat, title, desc )
    if not id or not cat or not desc then return end

    HORDE.MapAchievements[DEFAULT_MAP] = HORDE.MapAchievements[DEFAULT_MAP] or {}
    HORDE.MapAchievements[DEFAULT_MAP][id] = {
        order = mapAchOrder,
        cat = cat,
        title = title,
        desc = desc,
        unlocked = false
    }

    mapAchOrder = mapAchOrder + 1
end

local function createAchievements()
    HORDE:CreateMapAchievement( "win_casual", "difficulty", "Casual Player", "Win on Casual or higher difficulty." )
    HORDE:CreateMapAchievement( "win_easy", "difficulty", "Getting the Hang of It", "Win on Easy or higher difficulty." )
    HORDE:CreateMapAchievement( "win_medium", "difficulty", "Seasoned Fighter", "Win on Medium or higher difficulty." )
    HORDE:CreateMapAchievement( "win_hard", "difficulty", "Hard-Fought Victory", "Win on Hard or higher difficulty." )
    HORDE:CreateMapAchievement( "win_veteran", "difficulty", "Against the Odds", "Win on Veteran Difficulty." )
    HORDE:CreateMapAchievement( "win_elite_rush", "difficulty", "Elite Hunter", "Win on Elite-Rush Difficulty." )

    HORDE:CreateGlobalAchievement( "second_win", "milestone", "Newbie's First Win", "Complete your first game." )
    HORDE:CreateGlobalAchievement( "third_win", "milestone", "Newbie's First Win", "Complete your first game." )
    HORDE:CreateGlobalAchievement( "first_win", "milestone", "Newbie's First Win", "Complete your first game." )
end

local function fillEmptyMap( map )
    local from = HORDE.MapAchievements[DEFAULT_MAP]

    HORDE.MapAchievements[map] = {}
    local to = HORDE.MapAchievements[map]

    table.CopyFromTo( from, to )

    return HORDE.MapAchievements[map]
end

function HORDE:LoadAchievements()
    if not file.Exists( ACH_PATH, "DATA" ) then return end

    local data = file.Read( ACH_PATH, "DATA" )
    if not data then return end

    local saved = util.JSONToTable( data ) or {}
    local savedGlobal = saved.GlobalAchievements
    local savedMap = saved.MapAchievements

    if savedGlobal then
        for id, ach in pairs( HORDE.GlobalAchievements ) do
            if savedGlobal[id] and savedGlobal[id].unlocked ~= nil then
                ach.unlocked = savedGlobal[id].unlocked
            end
        end
    end

    if savedMap then
        for map, achi in pairs( savedMap ) do
            for id, ach in pairs( fillEmptyMap( map ) ) do
                if achi[id] and achi[id].unlocked ~= nil then
                    ach.unlocked = achi[id].unlocked
                end
            end
        end
    end
end

function HORDE:SaveAchievements()
    if not file.IsDir( "zmod_horde", "DATA" ) then
        file.CreateDir( "zmod_horde", "DATA" )
    end

    local saveData = {
        MapAchievements = {},
        GlobalAchievements = {}
    }

    for map, achi in pairs( HORDE.MapAchievements ) do
        if map ~= DEFAULT_MAP then
            saveData.MapAchievements[map] = {}
            for id, ach in pairs( achi ) do
                saveData.MapAchievements[map][id] = {}
                saveData.MapAchievements[map][id].unlocked = ach.unlocked
            end
        end
    end

    for id, ach in pairs( HORDE.GlobalAchievements ) do
        saveData.GlobalAchievements[id] = {}
        saveData.GlobalAchievements[id].unlocked = ach.unlocked
    end

    file.Write( ACH_PATH, util.TableToJSON( saveData ) )
end

function HORDE:GiveMapAchievement( id )
    HORDE.MapAchievements[CURRENT_MAP] = HORDE.MapAchievements[CURRENT_MAP] or {}

    local ach = HORDE.MapAchievements[CURRENT_MAP][id]
    if not ach or ach.unlocked then return end

    ach.unlocked = true
    HORDE:SaveAchievements()
end

function HORDE:GiveGlobalAchievement( id )
    local ach = HORDE.GlobalAchievements[id]
    if not ach or ach.unlocked then return end

    ach.unlocked = true
    HORDE:SaveAchievements()
end

function HORDE:GetSortedMapAchievements( map )
    local sorted = {}

    for _, ach in pairs( HORDE.MapAchievements[map] ) do
        table.insert( sorted, ach )
    end

    table.sort( sorted, function( a, b )
        return a.order < b.order
    end )

    return sorted
end

function HORDE:GetSortedGlobalAchievements()
    local sorted = {}

    for _, ach in pairs( HORDE.GlobalAchievements ) do
        table.insert( sorted, ach )
    end

    table.sort( sorted, function( a, b )
        return a.order < b.order
    end )

    return sorted
end

hook.Add( "Initialize", "Horde_LoadAchievements", function()
    createAchievements()
    HORDE:LoadAchievements()
end )

net.Receive( "Horde_SaveAchievements", function ()
    HORDE:SaveAchievements()
end )

concommand.Add("horde_testing_manual_achievement_load", function()
    createAchievements()
    HORDE:LoadAchievements()
end)