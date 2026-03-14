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
        type = "recipe",
		name = "mn-fertilizer",
        --subgroup = "fluid",
        energy_required = 30,
        enabled = false,
        category = "chemistry",
        ingredients = {
          { type = "fluid", name = "water", amount = 90 },
          { type = "fluid", name = "bob-carbon-dioxide", amount = 10 },
          { type = "item", name = "bob-fertiliser", amount = 5 },
        },
        results = { { type = "fluid", name = "mn-fertilizer", amount = 90} },
	},
})