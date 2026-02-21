local constants = {}
-- CONSTANTS

constants.GH_radius = 20
constants.GH_grow_interval = 11000 -- must be a multiple of 40
constants.GH_names = {"bob-greenhouse","bob-greenhouse-advanced"}
constants.GH_recipe_prefixes = {
    ["bob-greenhouse"] = "mn-basic-greenhouse-cycle-",
    ["bob-greenhouse-advanced"] = "mn-advanced-greenhouse-cycle-"
}

constants.GH_max_grades = {
    ["bob-greenhouse"] = 60,
    ["bob-greenhouse-advanced"] = 130
}


return constants