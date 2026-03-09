local house_renders = {}
local MN_const = require("scripts.constants")

local function v_in_table(v, t)
  for i = 1, #t do
      if t[i] == v then return true end
  end
end

local function house_cursor(player)
    local pcs = player.cursor_stack
    local pcg = player.cursor_ghost
    if pcs and pcs.valid_for_read and pcs.valid and v_in_table(pcs.name,MN_const.GH_names) then
      return true
    elseif pcg and v_in_table(pcg.name.name,MN_const.GH_names) then
      return true
    end
end

local function match_players(players, player, remove)
    if not players then return false, {} end
    for k, v in pairs(players) do
      if v == player then
        if remove then table.remove(players, k) end
        return true, players
      end
    end
    return false, players
end

function house_renders.add_circle(house, player)
    if not house or not house.valid then return end
    local renders = rendering.get_all_objects("nForester")
    local found = false
    for _, rend_obj in pairs(renders) do
      if rend_obj.valid and rend_obj.type == "circle" then
        if rend_obj.target.entity == house then
          found = true
          break
        end
      end
    end
    if not found then
      local r_obj
      if player and house_cursor(player) then
        r_obj = rendering.draw_circle{
          color={r=0.05, g=0.10, b=0.10, a=0.05},
          radius = MN_const.GH_radius,
          filled=true,
          target=house,
          players={player},
          surface = house.surface,
          draw_on_ground=true,
          visible=true
        }
       -- game.print("Drawn visible circle:".. r_obj.id)
      else
        r_obj = rendering.draw_circle{
          color={r=0.05, g=0.10, b=0.10, a=0.05},
          radius = MN_const.GH_radius,
          filled=true,
          target=house,
          players={},
          surface = house.surface,
          visible=false,
          draw_on_ground=true
        }
      --  game.print("Drawn invisible circle:".. r_obj.id)
      end
  
    end
end

function house_renders.remove_circle(house)
    if not house or not house.valid then return end
    local renders = rendering.get_all_objects("nForester")

    for _, r_obj in pairs(renders) do
      if r_obj.valid and r_obj.type:match("circle") then
        if r_obj.target.entity == house then
          --game.print("Destroyed circle:".. id)
          r_obj.destroy()
          return
        end
      end
    end
  end


local function hide_all_circles(player)
    local renders = rendering.get_all_objects("nForester")
    local match
    local players
    for _, r_obj in pairs(renders) do
      if r_obj.valid and r_obj.type == "circle" then
        if r_obj.visible then
          match, players = match_players(r_obj.players, player, true)
          if match then
            r_obj.players = players
          end
          if #players == 0 then
            r_obj.visible = false
          end
        end
      end
    end
  end

local function show_all_circles(player)
    local renders = rendering.get_all_objects("nForester")
  --  local target
    local match
    local players
    for _, r_obj in pairs(renders) do
      if r_obj.valid and r_obj.type == "circle" then
  --      target = rendering.get_target(id)
  --      if target.entity.force == player.force then
          if r_obj.visible then
            match, players = match_players(r_obj.players, player, false)
            players = r_obj.players
            if match then
            else
              table.insert(players, player)
              r_obj.players = players
            end
          else
            r_obj.players = {player}
            r_obj.visible = true
          end
  --      end
      end
    end
  end

local function hide_circle(house, player)
    if not house or not house.valid then return end
    local renders = rendering.get_all_objects("nForester")
    local match
    local players
    for _, r_obj in pairs(renders) do
      if r_obj.valid and r_obj.type == "circle" then
        if r_obj.target.entity == house then
          if r_obj.visible then
            match, players = match_players(r_obj.players, player, true)
            if match then
              r_obj.players = players
            end
            if #players == 0 then
              r_obj.visible = false
            end
          end
        end
      end
    end
  end

local function show_circle(house, player)
    if not house or not house.valid then return end
    local renders = rendering.get_all_objects("nForester")
    local found = false
    local match
    local players
    for _, r_obj in pairs(renders) do
      if r_obj.valid and r_obj.type == "circle" then
        if r_obj.target.entity == house then
          found = true
          if r_obj.visible then
            match, players = match_players(r_obj.players, player, false)
            players = r_obj.players
            if not match then
              table.insert(players, player)
              r_obj.players = players
            end
          else
            r_obj.players = {player}
            r_obj.visible = true
          end
        end
      end
    end
    if not found then
      house_renders.add_circle(house, player)
    end
end

function house_renders.selection_changed(player)
    local selection = player.selected
    if selection and selection.valid and
     ( v_in_table(selection.name, MN_const.GH_names) or selection.name == "entity-ghost" and v_in_table(selection.ghost_name, MN_const.GH_names) )  then
      show_circle(selection, player)
     elseif not house_cursor(player) then
      hide_all_circles(player)
      --hide_circle(selection, player)
    end
  end
  
  function house_renders.cursor_changed(player)
    if house_cursor(player) then
      game.print("showing all circles")
      show_all_circles(player)
    else
      hide_all_circles(player)
      game.print("hiding all circles")
    end
  end

return house_renders