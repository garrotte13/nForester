data:extend({
    {
        type = "fluid",
		name = "mn-fertilizer",
        icon = "__nForester__/graphics/fluid_fertilizer_64.png",
        icon_size = 64,
        subgroup = "fluid",
        default_temperature = 15,
        max_temperature = 100,
        heat_capacity = "2kJ",
        base_color = { r = 0.0, g = 0.8, b = 0.1 },
        flow_color = { r = 0.0, g = 0.7, b = 0.3 },
	},
    {
		type = "item",
		name = "mn-fertiliser-solid",
        order = "g[fertiliser]b",
		subgroup = "bob-resource-chemical",
		icon = "__nForester__/graphics/fertilizer.png",
		icon_size = 64,
		stack_size = 100,
	},
    {
        type = "recipe",
		name = "mn-fertilizer",
        energy_required = 30,
        enabled = false,
        category = "chemistry",
        ingredients = {
          { type = "fluid", name = "water", amount = 90 },
          { type = "fluid", name = "bob-carbon-dioxide", amount = 10 },
          { type = "item", name = "bob-fertiliser", amount = 5 },
          { type = "item", name = "mn-fertiliser-solid", amount = 5 }
        },
        results = { { type = "fluid", name = "mn-fertilizer", amount = 90} },
	},
    {
        type = "recipe",
		name = "mn-fertiliser-solid",
        energy_required = 5,
        enabled = false,
        category = "chemistry",
        ingredients = {
          { type = "fluid", name = "sulfuric-acid", amount = 10 },
          { type = "fluid", name = "ammonia", amount = 20 },
        },
        results = { { type = "item", name = "mn-fertiliser-solid", amount = 2} },
	},
})