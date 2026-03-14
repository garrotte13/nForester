-- CONSTANTS in prototype phase
local GH_radius = 20
local GH_names = {"bob-greenhouse","bob-greenhouse-advanced"}
local GH_recipe_prefixes = {
    ["bob-greenhouse"] = "mn-basic-greenhouse-cycle-",
    ["bob-greenhouse-advanced"] = "mn-advanced-greenhouse-cycle-"
}

local GH_max_grades = {
    ["bob-greenhouse"] = 60,
    ["bob-greenhouse-advanced"] = 130
}

local function myround(x)
    return math.floor(x+0.5)
end

local function get_wood_recipe(minTop, maxTop, seedTop, timeTop, gradeTop, grade)
    local min_from_grade = myround( grade / (gradeTop/minTop) )
    local max_from_grade = math.min(maxTop, min_from_grade + math.ceil( grade / (gradeTop / (maxTop - minTop) ) ) )
    local seed_prob = (grade/gradeTop) * seedTop
    local time_from_grade = timeTop + myround( (1 - grade/gradeTop) * ( timeTop / 3 ) )
    return min_from_grade, max_from_grade, seed_prob, time_from_grade
end

data.raw.recipe["bob-seedling"].hidden = true
data.raw.recipe["bob-advanced-greenhouse-cycle"].hidden = true
data.raw.recipe["bob-basic-greenhouse-cycle"].hidden = true

data:extend({
    {
        type = "recipe-category",
        name = "mn-wood-spam-tier1"
    },
    {
        type = "recipe-category",
        name = "mn-wood-spam-tier2"
    },
    {
        type = "recipe-category",
        name = "mn-sapling-growth"
    }
})
local min_r
local max_r
local seed_prob
local time_req

for i = 0, GH_max_grades["bob-greenhouse"] do
    min_r, max_r, seed_prob, time_req = get_wood_recipe(8, 16, 0.2, 60, GH_max_grades["bob-greenhouse"], i)
    data:extend({
        {
            type = "recipe",
            name = "mn-basic-greenhouse-cycle-" .. i,
            category = "mn-wood-spam-tier1",
            enabled = true,
            hidden = true,
            ingredients = {
                { type = "fluid", name = "water", amount = 75 }
            },
            results = {
                { type = "item", name = "wood", amount_min = min_r, amount_max = max_r },
                { type = "item", name = "bob-seedling", amount = 1, probability = seed_prob}
            },
            allow_decomposition = false,
            energy_required = time_req,
            always_show_products = true,
            show_amount_in_title = false,
            allow_intermediates = false,
            allow_as_intermediate = false,
            emissions_multiplier = seed_prob * 3,
            localised_name = {"item-name.wood"},
            main_product = "wood"
        }
    })
end

for i = 0, GH_max_grades["bob-greenhouse-advanced"] do
    min_r, max_r, seed_prob, time_req = get_wood_recipe(12, 40, 0.3, 45, GH_max_grades["bob-greenhouse-advanced"], i)
    data:extend({
        {
            type = "recipe",
            name = "mn-advanced-greenhouse-cycle-" .. i,
            category = "mn-wood-spam-tier2",
            enabled = true,
            hidden = true,
            ingredients = {
                { type = "fluid", name = "mn-fertilizer", amount = 90 },
            },
            results = {
                { type = "item", name = "wood", amount_min = min_r, amount_max = max_r },
                { type = "item", name = "bob-seedling", amount = 1, probability = seed_prob}
            },
            allow_decomposition = false,
            energy_required = time_req,
            always_show_products = true,
            show_amount_in_title = false,
            emissions_multiplier = seed_prob * 3,
            localised_name = {"item-name.wood"},
            main_product = "wood"
        }
    })

end

local i_gh_adv = table.deepcopy(data.raw.item["bob-greenhouse"])
i_gh_adv.name = "bob-greenhouse-advanced"
i_gh_adv.place_result = "bob-greenhouse-advanced"
i_gh_adv.order = "g[greenhouse]b"

local c_gh_adv = {
    type = "recipe",
    name = "bob-greenhouse-advanced",
    energy_required = 10,
    enabled = false,
    ingredients = {
      { type = "item", name = "bob-greenhouse", amount = 1 },
      { type = "item", name = "advanced-circuit", amount = 3 },
      mods["boblogistics"] and { type = "item", name = "bob-copper-pipe", amount = 5 } or { type = "item", name = "pipe", amount = 5 },
      mods["bobplates"] and { type = "item", name = "bob-steel-gear-wheel", amount = 3 } or { type = "item", name = "steel-plate", amount = 5 },
    },
    results = { { type = "item", name = "bob-greenhouse-advanced", amount = 1 } },
}

table.insert(data.raw.technology["bob-fertiliser"].effects,
{
    type = "unlock-recipe",
    recipe = "bob-greenhouse-advanced"
})
table.insert(data.raw.technology["bob-fertiliser"].effects,
{
    type = "unlock-recipe",
    recipe = "mn-fertilizer"
})


local r = data.raw["assembling-machine"]["bob-greenhouse"]
r.crafting_categories = {"mn-wood-spam-tier1"}
--r.energy_usage = "70kW"
r.crafting_speed = 0.5
r.allow_copy_paste = false
r.return_ingredients_on_change = false
r.fast_replaceable_group = "bob-greenhouse"
r.next_upgrade = "bob-greenhouse-advanced"
local gh_adv = table.deepcopy(r)
gh_adv.name = "bob-greenhouse-advanced"
gh_adv.minable.result = "bob-greenhouse-advanced"
gh_adv.energy_usage = tonumber(string.match(gh_adv.energy_usage, "(%d+)kW")) * 2.0  .. "kW"
gh_adv.crafting_categories = {"mn-wood-spam-tier2"}
gh_adv.next_upgrade = nil

data:extend({i_gh_adv, gh_adv, c_gh_adv})