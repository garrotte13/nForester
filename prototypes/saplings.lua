data.raw.technology["bob-fertiliser"].prerequisites[1] = "mn-saplings"
table.insert(data.raw.technology["bob-fertiliser"].effects,
{
    type = "unlock-recipe",
    recipe = "mn-sapling-advanced"
})

require("circuit-connector-sprites")
require("circuit-connector-generated-definitions")

local width = 9-0.00001
local height = 9-0.00001
local gap = 0
local scale = 0.9
--local hit_effects = require("__base__.prototypes.entity.hit-effects")

--require("sound-util")
data:extend({

    {
        type = "recipe",
        name = "mn-sapling",
        energy_required = 140,
        enabled = false,
        category = "mn-sapling-growth",
        ingredients = {
          { type = "item", name = "bob-seedling", amount = 30 },
          { type = "fluid", name = "water", amount = 175 },
          { type = "fluid", name = "bob-carbon-dioxide", amount = 150 },
        },
        results = { { type = "item", name = "mn-sapling", amount_min = 15, amount_max = 30} },
    },
    {
        type = "recipe",
        name = "mn-sapling-advanced",
        energy_required = 90,
        enabled = false,
        category = "mn-sapling-growth",
        ingredients = {
          { type = "item", name = "bob-seedling", amount = 30 },
          { type = "fluid", name = "water", amount = 175 },
          { type = "fluid", name = "bob-carbon-dioxide", amount = 200 },
          { type = "item", name = "bob-fertiliser", amount = 15 },
        },
        results = { { type = "item", name = "mn-sapling", amount_min = 25, amount_max = 30} },
    },
    -- taken from the mod https://mods.factorio.com/mod/TreeSeeds
    {
		type = "item",
		name = "mn-sapling",
		subgroup = "terrain",
		icon = "__nForester__/graphics/saplings/icon_sapling.png",
		icon_size = 32,
		stack_size = 50,
		place_result = "sapling-dry"
	},
    {
      type = 'simple-entity-with-owner',
      name = 'sapling-dry',
      icon = '__nForester__/graphics/saplings/icon_sapling.png',
      icon_size = 32,
  
      flags = { 'placeable-neutral', 'breaths-air', 'not-repairable', 'player-creation', 'placeable-off-grid' },
      collision_mask = {layers = {
        item = true, meltable = true, object = true, player = true, floor=true, resource=true, 
        water_tile = true, is_object = true, is_lower_object = true
      }},
      max_health = 25,
      corpse = 'small-remnants',
      collision_box = { { -1.55, -1.55 }, { 1.55, 1.55 } },
      selection_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
      selectable_in_game = true,
      drawing_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      vehicle_impact_sound = { filename = '__base__/sound/car-wood-impact.ogg', volume = 0.5 },
      picture = {
        filename = '__nForester__/graphics/saplings/plant-stick.png',
        priority = 'extra-high',
        width = 123,
        height = 123,
        shift = { 0.6, -1.4 }
      },
      allow_copy_paste = false
    },


    {
        type = "item",
        name = "mn-greenhouse",
        icon = "__nForester__/graphics/gh/greenhouse-icon.png",
        icon_size = 64,
        subgroup = "bob-greenhouse",
        order = "h[mn-greenhouse]",
        place_result = "mn-greenhouse",
        stack_size = 10
    },
    {
        type = "recipe",
        name = "mn-greenhouse",
        enabled = false,
        energy_required = 40,
        ingredients = {
            mods["bobplates"] and {type = "item", name = "bob-glass", amount = 30} or {type = "item", name = "copper-plate", amount = 20},
            {type = "item", name = "electronic-circuit", amount = 15},
            {type = "item", name = "stone-brick", amount = 30},
            {type = "item", name = "pipe", amount = 20},
            mods["bobplates"] and { type = "item", name = "bob-steel-gear-wheel", amount = 12 } or { type = "item", name = "steel-plate", amount = 25 },
        },
        results = {{type = "item", name = "mn-greenhouse", amount = 1}}
    },
    {
    type = "assembling-machine",
    name = "mn-greenhouse",
    icon = "__nForester__/graphics/gh/greenhouse-icon.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation",
        "not-rotatable"
    },
    minable = {mining_time = 1.0, result = "mn-greenhouse"},
    max_health = 600,
    corpse = "kr-big-random-pipes-remnant",
    allowed_effects = {"pollution"},
    module_slots = 2,
    --heating_energy = "2.5MW",
    dying_explosion = "boiler-explosion",
    impact_category = "metal-large",
    match_animation_speed_to_activity = false,
    --mode = "output-to-separate-pipe",
    energy_source = {
        type = "electric",
        usage_priority = "primary-input",
        drain = "25kW",
        emissions_per_minute = {pollution = -2},
    },
    collision_box = {{-width/2+gap, -height/2+gap}, {width/2-gap, height/2-gap}},
    selection_box = {{-width/2, -height/2}, {width/2, height/2}},
    --target_temperature = 65,
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = {
                north = util.empty_sprite(),
                east = util.empty_sprite(),
                south = {
                  filename = "__nForester__/graphics/gh/pipe-patch.png",
                  priority = "high",
                  width = 55,
                  height = 50,
                  scale = 0.5,
                  shift = { 0.01, -0.58 },
                },
                west = util.empty_sprite(),
              },
            pipe_covers = pipecoverspictures(),
            volume = 2000,
            height = 1,
            pipe_connections = {
              { flow_direction = "input", direction = defines.direction.north, position = { 0, -4.0 } },
              { flow_direction = "input", direction = defines.direction.west, position = { -4.0, -1.0 } },
             -- { flow_direction = "input", direction = defines.direction.east, position = { 4.0, -2.0 } },
              --{ flow_direction = "input", direction = defines.direction.south, position = { 0, 4 } },
            },
          },
          {
            production_type = "input",
            pipe_picture = {
                north = util.empty_sprite(),
                east = util.empty_sprite(),
                south = {
                  filename = "__nForester__/graphics/gh/pipe-patch.png",
                  priority = "high",
                  width = 55,
                  height = 50,
                  scale = 0.5,
                  shift = { 0.01, -0.58 },
                },
                west = util.empty_sprite(),
              },
            pipe_covers = pipecoverspictures(),
            volume = 2000,
            height = 2,
            pipe_connections = {
             --{ flow_direction = "input", direction = defines.direction.north, position = { 0, -4.0 } },
             -- { flow_direction = "input", direction = defines.direction.west, position = { -4.0, -1.0 } },
              { flow_direction = "input", direction = defines.direction.east, position = { 4.0, -2.0 } },
              { flow_direction = "input", direction = defines.direction.south, position = { 0, 4 } },
            },
          },
    },
    working_sound = {
        sound = {
          filename = "__nForester__/sounds/greenhouse-watering_16s.ogg",
          volume = 0.95,
          aggregation = {
            max_count = 1,
            remove = false,
            count_already_playing = true,
          },
        },
        idle_sound = { filename = "__base__/sound/idle1.ogg" },
      },
    crafting_categories = {"mn-sapling-growth"},
    crafting_speed = 1,
    energy_usage = "1.8MW",
    graphics_set = {
        working_visualisations = {
            {
                render_layer = "wires",
                animation = {
                    stripes = {
                        {
                            filename = "__nForester__/graphics/gh/greenhouse-hr-emission-1.png",
                            width_in_frames = 8,
                            height_in_frames = 8
                        },
                        {
                            filename = "__nForester__/graphics/gh/greenhouse-hr-emission-2.png",
                            width_in_frames = 8,
                            height_in_frames = 8
                        }
                    },
                    draw_as_glow = true,
                    priority = "extra-high",
                    frame_count = 128,
                    lines_per_file = 8,
                    width = 340,
                    height = 355,
                    animation_speed = 0.5,
                    shift = util.by_pixel(0, -10),
                    scale = scale,
                    blend_mode = "additive",
                    apply_runtime_tint = true,
                    tint = {r = 0.5, g = 0.7, b = 0.5}
                },
            },
            {
                render_layer = "wires",
                light = {
                    type = "basic",
                    intensity = 0.7,
                    size = 25,
                },
                animation = {
                    stripes = {
                        {
                            filename = "__nForester__/graphics/gh/greenhouse-hr-color3-1.png",
                            width_in_frames = 8,
                            height_in_frames = 8
                        },
                        {
                            filename = "__nForester__/graphics/gh/greenhouse-hr-color3-2.png",
                            width_in_frames = 8,
                            height_in_frames = 8
                        }
                    },
                    draw_as_glow = true,
                    priority = "extra-high",
                    frame_count = 128,
                    lines_per_file = 8,
                    width = 340,
                    height = 355,
                    animation_speed = 0.5,
                    shift = util.by_pixel(0, -10),
                    scale = scale,
                    blend_mode = "additive",
                    tint = {r = 0.5, g = 0.7, b = 0.5}
                },
            },
        },
        animation = {
            north = {
                layers = {
                    {
                        filename = "__nForester__/graphics/gh/greenhouse-hr-shadow.png",
                        priority = "high",
                        width = 700,
                        height = 500,
                        frame_count = 1,
                        line_length = 1,
                        repeat_count = 128,
                        animation_speed = 0.5,
                        shift = util.by_pixel(0, -10),
                        draw_as_shadow = true,
                        scale = scale
                    },
                    {
                        stripes = {
                            {
                                filename = "__nForester__/graphics/gh/greenhouse-hr-animation-1.png",
                                width_in_frames = 8,
                                height_in_frames = 8
                            },
                            {
                                filename = "__nForester__/graphics/gh/greenhouse-hr-animation-2.png",
                                width_in_frames = 8,
                                height_in_frames = 8
                            }
                        },
                        priority = "extra-high",
                        frame_count = 128,
                        lines_per_file = 8,
                        width = 340,
                        height = 355,
                        animation_speed = 0.5,
                        shift = util.by_pixel(0, -10),
                        scale = scale,
                        tint = {r = 1, g = 1, b = 1}
                    },
                }
            }
        },
    },
    circuit_wire_max_distance = 12,
    circuit_connector = circuit_connector_definitions.create_vector(
        universal_connector_template,
        {
            { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
            { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
            { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true },
            { variation = 18, main_offset = util.by_pixel(60, 86), shadow_offset = util.by_pixel(170, 135), show_shadow = true }
        }
    ),
    },
    {
        type = "corpse",
        name = "kr-big-random-pipes-remnant",
        icon = "__nForester__/graphics/remnants-icon.png",
        icon_size = 64,
        flags = { "placeable-neutral", "building-direction-8-way", "not-on-map" },
        hidden = true,
        selection_box = { { -4, -4 }, { 4, 4 } },
        tile_width = 3,
        tile_height = 3,
        selectable_in_game = false,
        subgroup = "remnants",
        order = "z[remnants]-a[generic]-b[big]",
        time_before_removed = 60 * 60 * 20,
        final_render_layer = "remnants",
        remove_on_tile_placement = false,
        animation = make_rotated_animation_variations_from_sheet(1, {
          filename = "__nForester__/graphics/big-random-pipes-remnants.png",
            line_length = 1,
            width = 500,
            height = 500,
            frame_count = 1,
            direction_count = 1,
            scale = 0.5,
        }),
    },

    {
        type = "technology",
        name = "mn-saplings",
        icon = "__nForester__/graphics/gh/greenhouse-icon-big.png",
        icon_size = 640,
        prerequisites = {
          "bob-greenhouse", "sulfur-processing"
        },
        effects = {
          {
            type = "unlock-recipe",
            recipe = "mn-greenhouse",
          },
          {
            type = "unlock-recipe",
            recipe = "mn-sapling",
          },
        },
        unit = {
          count = 150,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
          },
          time = 30,
        },
        order = "f-a-c",
      }

  })



