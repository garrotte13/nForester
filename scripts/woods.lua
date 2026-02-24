local woods = {}

local MNconst = require("scripts.constants")
local flora = require("scripts.flora")
local act_types = {
    grow = 1,
    mature = 2,
    re_adding = 3,
    check_poison = 4
}

local function find_free_tick(e_tick)
    local action_ticks = storage.mn_acts
    while action_ticks[e_tick] do e_tick = e_tick + 20 end
return e_tick
end

function woods.MN_actions(e)
    local act_now = storage.mn_acts[e.tick]
    --game.print("my tick is: ".. e.tick)
    if not act_now then return end
    if act_now.type == act_types.grow then
        local house = storage.mn_gh[act_now.r]
        if not house then
            storage.mn_acts[e.tick] = nil
            return
        end
        if (house.entity.products_finished >= house.lastP + 2) and house.grade > 0 then
            house.lastP = house.entity.products_finished
            local max_grade = MNconst.GH_max_grades[house.entity.name]
            if (house.trees_total<max_grade*4) and math.random(1, math.ceil(math.abs(house.trees_total-max_grade*0.7)/5+max_grade*0.05)) == 1 then
                --game.print("Greenhouse #".. act_now.r.. " is ready to grow a tree")
                local trees_found = {}
                for _, t in pairs(house.tr_list) do
                    table.insert(trees_found, t)
                end
                if house.entity.get_output_inventory().remove({name="bob-seedling", count=1}) > 0 and math.random(1,7) > 1 then
                    local parent_tree = trees_found[math.random(1,#trees_found)]
                    local newborn_pos = {
                        x = parent_tree.position.x + (math.random(0,60)-30)/10,
                        y = parent_tree.position.y + (math.random(0,60)-30)/10,
                    }
                    --game.print("A tree is to be placed!")
                    newborn_pos = parent_tree.surface.find_non_colliding_position(parent_tree.name, newborn_pos, 2, 0.01)
                    if newborn_pos then
                        local t_tile = parent_tree.surface.get_tile(newborn_pos)
                        local t_name = flora.check_tile_for_tree(t_tile)
                        if t_name then
                            parent_tree.surface.create_entity{name = parent_tree.name, position = newborn_pos, create_build_effect_smoke = true, raise_built = true}
                            game.print("A tree is placed here: [gps=" .. newborn_pos.x.. ",".. newborn_pos.y.. "]")
                        else
                            --game.print("Selected land is not fertile for a new tree")    
                        end
                    else
                        --game.print("No place was found for a new tree")
                    end
                end

            else
                --game.print("Greenhouse #".. act_now.r.. " prepared for a tree growth, but has bad luck")
            end
        else
           -- game.print("Greenhouse #".. act_now.r.. " hasn't been working enough to change forest")
        end
        storage.mn_acts[find_free_tick(e.tick + MNconst.GH_grow_interval)] = {
            type = act_types.grow,
            r = act_now.r
        }
    elseif act_now.type == act_types.mature then
        local sapling = act_now.e
        if not sapling or not sapling.valid then return end
        local pos = sapling.position
        local sapling_surface = sapling.surface
        sapling.destroy()
        if math.random(1,5) > 1 then
            if pos then
                local t_tile = sapling_surface.get_tile(pos)
                local t_name = flora.check_tile_for_tree(t_tile)
                if t_name then 
                    pos = sapling_surface.find_non_colliding_position(t_name, pos, 1.8, 0.01)
                    if pos then
                        sapling_surface.create_entity{name = t_name, position = pos, create_build_effect_smoke = true, raise_built = true}
                    end
                end
            end
        end
    elseif act_now.type == act_types.re_adding then
        local house = storage.mn_gh[act_now.r]
        if house and house.entity and house.entity.valid then
            local chunkk = house.entity.surface.index.. ":".. math.floor(house.pos.x/32).. ":".. math.floor(house.pos.y/32)
            storage.mn_chunks[chunkk] = storage.mn_chunks[chunkk] - 1
            if storage.mn_chunks[chunkk] < 1 then
                storage.mn_chunks[chunkk] = nil
            end
            local pa = house.lastP
            woods.GHadded(house.entity, e.tick, true)
            storage.mn_gh[act_now.r].lastP = pa
        end
    elseif act_now.type == act_types.check_poison then
        local house = storage.mn_gh[act_now.r]
        if house and house.entity and house.entity.valid then
            local the_tr = act_now.tree_str
            if (house.grade > 0 and not the_tr) or not house.tr_list[the_tr] then the_tr = next(house.tr_list, nil) end
            local k = 0
            while k < 21 and the_tr do
                local tree = house.tr_list[the_tr]
                if tree and tree.valid then
                    
                end
                the_tr = next(house.tr_list, the_tr)
                k = k + 1
            end
            storage.mn_acts[find_free_tick(e.tick + MNconst.GH_grow_interval/2)] = {
                type = act_types.check_poison,
                r = act_now.r,
                tree_str = the_tr
            }
        end
    end
    storage.mn_acts[e.tick] = nil
end

function woods.GH_init()
    storage.mn_gh = {}
    storage.mn_acts = {}

end

local function GH_SetRecipe(house, grade)
    local progress_now = house.crafting_progress or 0
    if grade == 0 then
        house.set_recipe(nil)
        house.recipe_locked = true
        return progress_now
    else
        house.set_recipe(MNconst.GH_recipe_prefixes[house.name] .. grade)
        house.crafting_progress = progress_now
        house.recipe_locked = true
    end
end

local function find_houses(entity, dbl)
    local s_radius = dbl and 2*MNconst.GH_radius or MNconst.GH_radius
    local zminX = math.floor( (entity.position.x - s_radius) / 32)
    local zmaxX = math.floor( (entity.position.x + s_radius) / 32)
    local zminY = math.floor( (entity.position.y - s_radius) / 32)
    local zmaxY = math.floor( (entity.position.y + s_radius) / 32)
    local found_chunks
    for zx = zminX, zmaxX do
        for zy = zminY, zmaxY do
            if storage.mn_chunks[entity.surface.index.. ":".. zx.. ":".. zy] then
                found_chunks = true
                break
            end
            if found_chunks then break end
        end
    end
    if not found_chunks then return end

    local found = entity.surface.find_entities_filtered{position = entity.position, radius = s_radius - 1.28, name = MNconst.GH_names, force = "player" }
    local f_houses = {}
    if found and found[1] then
        for i = 1,#found do
            if found[i] ~= entity then
                table.insert(f_houses, found[i])
            end
        end
    end
    if f_houses[1] then return f_houses end
end

function woods.GHadded(entity, t, no_kick)
    local pos = entity.position
    local r = entity.unit_number
    local maxgrade = MNconst.GH_max_grades[entity.name] 
    local houses = storage.mn_gh
    local houses_near
    local trees_found = entity.surface.find_entities_filtered{position = pos, radius = MNconst.GH_radius-0.38, type = "tree"}
    local trees_list = {}
    local trees_number = 0
    if trees_found and trees_found[1] then
        houses_near = find_houses(entity, true)
        for i=1,#trees_found do
            local tree_is_busy
            if not ( string.find(trees_found[i].name, "dead") or string.find(trees_found[i].name, "dry") ) then
                local tree_pos = trees_found[i].position.x .. ":" .. trees_found[i].position.y
                if houses_near then
                    for y=1,#houses_near do
                        if houses[houses_near[y].unit_number].tr_list[tree_pos] then
                            tree_is_busy = true
                            break
                        end
                    end
                    if not tree_is_busy then
                        trees_list[tree_pos] = trees_found[i]
                        trees_number = trees_number + 1
                    end
                else
                    trees_list[tree_pos] = trees_found[i]
                    trees_number = trees_number + 1
                end
            end
            if trees_number == maxgrade then
                break
            end
        end
    end

    houses[r] = {
        --grade = math.min(200, trees_number),
        grade = trees_number,
        trees_total = 0,
        pos = pos,
        entity = entity,
        lastP = entity.products_finished or 0,
        tr_list = trees_list,
        re_set = nil
    }
    if trees_found then houses[r].trees_total = #trees_found end
    GH_SetRecipe(entity, trees_number)
    if not t then t = game.tick end
    t = math.ceil(1 + t/20)*20
    if not no_kick then
        storage.mn_acts[find_free_tick(t + MNconst.GH_grow_interval/2)] = {
            type = act_types.check_poison,
            r = r,
            tree_str = nil
        }
    end
    local chunk_x = math.floor(pos.x/32)
    local chunk_y = math.floor(pos.y/32)
    if storage.mn_chunks[entity.surface.index.. ":".. chunk_x.. ":".. chunk_y] then
        storage.mn_chunks[entity.surface.index.. ":".. chunk_x.. ":".. chunk_y] = storage.mn_chunks[entity.surface.index.. ":".. chunk_x.. ":".. chunk_y] + 1
    else
        storage.mn_chunks[entity.surface.index.. ":".. chunk_x.. ":".. chunk_y] = 1
    end
    t = find_free_tick(t + MNconst.GH_grow_interval)
    storage.mn_acts[t] = {
        type = act_types.grow,
        r = r
    }
    game.print("GH #".. r.. " installed. To be checked next time at tick:".. t .. " Engaged trees: ".. trees_number.. " Total trees: ".. houses[r].trees_total )
end

function woods.GHremoved(entity, t)
    local r = entity.unit_number
    local pos = entity.position
    local houses = storage.mn_gh
    local chunkk = entity.surface.index.. ":".. math.floor(pos.x/32).. ":".. math.floor(pos.y/32)
    storage.mn_chunks[chunkk] = storage.mn_chunks[chunkk] - 1
    if storage.mn_chunks[chunkk] < 1 then
        storage.mn_chunks[chunkk] = nil
    end
    if houses[r].grade > 0 then
        local trees_found = {}
        for _, t in pairs(houses[r].tr_list) do
            if t and t.valid then table.insert(trees_found, t) end
        end
        houses[r].tr_list = nil
        local houses_near = find_houses(entity, true)
        if houses_near then
            local ds = MNconst.GH_radius^2
            for y = 1,#trees_found do
                for i = 1,#houses_near do
                    local h = houses_near[i].unit_number
                    if houses[h].grade < MNconst.GH_max_grades[houses_near[i].name] and ((houses[h].pos.x - trees_found[y].position.x)^2 + (houses[h].pos.y - trees_found[y].position.y)^2) <= ds then
                        houses[h].tr_list[trees_found[y].position.x.. ":".. trees_found[y].position.y] = trees_found[y]
                        houses[h].grade = houses[h].grade + 1
                        break
                    end
                end
            end
            for i = 1,#houses_near do
                GH_SetRecipe(houses_near[i], houses[houses_near[i].unit_number].grade)
            end

        end
    end
    houses[r] = nil
end

function woods.TreeAdded(entity, t)
    if not storage.mn_gh then return end
    local houses_near = find_houses(entity)
    if houses_near then
        local houses = storage.mn_gh
        local h
        local tree_is_free = not ( string.find(entity.name, "dead") or string.find(entity.name, "dry") )
        for i = 1,#houses_near do
            h = houses_near[i].unit_number
            houses[h].trees_total = houses[h].trees_total + 1
            if tree_is_free and houses[h].grade < MNconst.GH_max_grades[houses_near[i].name] then
                houses[h].grade = houses[h].grade + 1
                game.print("A tree added to the work space of GH #"..h)
                tree_is_free = false
                houses[h].tr_list[entity.position.x .. ":" .. entity.position.y] = entity
                GH_SetRecipe(houses_near[i], houses[h].grade)
            end
        end
    end
end

function woods.TreeRemoved(entity, t)
    if not storage.mn_gh then return end
    local houses_near = find_houses(entity)
    if houses_near then
        local houses = storage.mn_gh
        local h
        for i = 1,#houses_near do
            h = houses_near[i].unit_number
            houses[h].trees_total = houses[h].trees_total - 1
            if houses[h].grade > 0 and houses[h].tr_list[entity.position.x .. ":" .. entity.position.y]  then
                houses[h].tr_list[entity.position.x .. ":" .. entity.position.y] = nil
                houses[h].grade = houses[h].grade - 1
                game.print("A tree removed from the work space of GH #"..h)
                GH_SetRecipe(houses_near[i], houses[h].grade)
                if not houses[h].re_set and houses[h].trees_total > houses[h].grade then
                    houses[h].re_set = true
                    storage.mn_acts[find_free_tick(math.ceil(9 + t/20)*20)] = {
                        type = act_types.re_adding,
                        r = h
                    }
                end
            end
        end
    end
end

function woods.SaplingPlaced(entity, t)
    --if math.random(1,5) > 2 then
        storage.mn_acts[find_free_tick(math.ceil((t+MNconst.GH_grow_interval*0.5)/20)*20)] = {
            type = act_types.mature,
            e = entity
        }
    --else
      --  entity.destroy() --bad luck
    --end
end

return woods