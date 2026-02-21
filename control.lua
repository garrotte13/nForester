local woods = require("__nForester__/scripts/woods")
local circle_rendering = require("scripts.gh_rendering")
local MN_const = require("scripts.constants")

--[[

]]

local function v_in_table(v, t)
    for i = 1, #t do
        if t[i] == v then return true end
    end
end

local function smth_built(e)
    local entity = e.entity or e.destination
    if entity and entity.valid then
        if v_in_table(entity.name, MN_const.GH_names) then
            circle_rendering.add_circle(entity, game.players[e.player_index])
            woods.GHadded(entity, e.tick)
        elseif entity.type == "tree" then
            woods.TreeAdded(entity, e.tick)
        elseif entity.name == "entity-ghost" and v_in_table(entity.ghost_name , MN_const.GH_names) then
            circle_rendering.add_circle(entity, game.players[e.player_index])
            entity.set_recipe(MN_const.GH_recipe_prefixes[entity.ghost_name] .. MN_const.GH_max_grades[entity.ghost_name])
            entity.recipe_locked = true
        elseif entity.name == "sapling-dry" then
            woods.SaplingPlaced(entity, e.tick)
        end
    end
end

local function smth_built2(e)
    local entity = e.destination
    game.print("Cloned properties to entity ".. entity.name)
    
end

local function smth_destroyed(e)
    if e.entity then
        if v_in_table(e.entity.name, MN_const.GH_names) then
            circle_rendering.remove_circle(e.entity)
            woods.GHremoved(e.entity, e.tick)
        elseif e.entity.type == "tree" then
            woods.TreeRemoved(e.entity, e.tick)
        elseif e.entity.name == "entity-ghost" and v_in_table(e.entity.ghost_name, MN_const.GH_names) then
            circle_rendering.remove_circle(e.entity)
        end
    end
end



script.on_init(function()
    woods.GH_init()
    storage.mn_chunks = {}
end)

script.on_nth_tick(20, function(e)
    woods.MN_actions(e)
end) 

script.on_configuration_changed(function()
    if not storage.mn_gh or not storage.mn_acts then -- for older games with MN mod
        woods.GH_init()
    end
    if not storage.mn_chunks then
        storage.mn_chunks = {}
        for _, surface in pairs(game.surfaces) do
            local houses = surface.find_entities_filtered({ name = MN_const.GH_names, force = "player" })
            for _, house in pairs(houses) do
                if house.valid and (not storage.mn_gh[house.unit_number]) then
                    woods.GHadded(house)
                end
            end
        end
    end
end)

script.on_event({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
	--defines.events.on_entity_cloned,
}, smth_built)

script.on_event({
	defines.events.on_player_mined_entity,
	defines.events.on_robot_mined_entity,
    defines.events.on_entity_died,
	defines.events.script_raised_destroy,
}, smth_destroyed)

script.on_event({
	defines.events.on_entity_cloned,
}, smth_built2)

--[[
script.on_event(defines.events.on_entity_cloned, function (e)
    if e.destination and e.destination.valid then
        if e.destination.name == "entity-ghost" and v_in_table(e.destination.ghost_name , MN_const.GH_names) then
            --circle_rendering.add_circle(e.destination, game.players[e.player_index])
            e.destination.set_recipe(MN_const.GH_recipe_prefixes[e.destination.ghost_name] .. MN_const.GH_max_grades[e.destination.ghost_name])
            e.destination.recipe_locked = true
        elseif v_in_table(e.destination.name, MN_const.GH_names) then
            e.destination.set_recipe(MN_const.GH_recipe_prefixes[e.destination.name] .. MN_const.GH_max_grades[e.destination.name])
            e.destination.recipe_locked = true

        end
        
    end
end)
]]

-- Pure rendering events
script.on_event(defines.events.on_selected_entity_changed, function(e)
    circle_rendering.selection_changed(game.players[e.player_index])
end)

 script.on_event(defines.events.on_player_cursor_stack_changed, function(e)
    circle_rendering.cursor_changed(game.players[e.player_index])
end)
