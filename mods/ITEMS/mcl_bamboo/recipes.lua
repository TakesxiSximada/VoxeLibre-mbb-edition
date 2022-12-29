---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by michieal.
--- DateTime: 12/29/22 12:46 PM -- Restructure Date
--- These are all of the fuel recipes and all of the crafting recipes, consolidated into one place.

local bamboo = "mcl_bamboo:bamboo"

	-- Craftings
	-- Basic Bamboo craftings
	minetest.register_craft({
		output = "mcl_core:stick",
		recipe = {
			{bamboo},
			{bamboo},
		}
	})

	minetest.register_craft({
		output = bamboo .. "_block",
		recipe = {
			{bamboo, bamboo, bamboo},
			{bamboo, bamboo, bamboo},
			{bamboo, bamboo, bamboo},
		}
	})

	minetest.register_craft({
		output = bamboo .. "_plank 2",
		recipe = {
			{bamboo .. "_block"},
		}
	})

	minetest.register_craft({
		output = bamboo .. "_plank 2",
		recipe = {
			{bamboo .. "_block_stripped"},
		}
	})

	minetest.register_craft({
		output = bamboo .. "_mosaic",
		recipe = {
			{"mcl_stair:slab_bamboo_plank"},
			{"mcl_stair:slab_bamboo_plank"},
		}
	})

	-- Bamboo specific items

	if minetest.get_modpath("mcl_doors") then
		if mcl_doors then
			minetest.register_craft({
				output = "mcl_bamboo:bamboo_door 3",
				recipe = {
					{bamboo .. "_plank", bamboo .. "_plank"},
					{bamboo .. "_plank", bamboo .. "_plank"},
					{bamboo .. "_plank", bamboo .. "_plank"}
				}
			})
			minetest.register_craft({
				output = "mcl_bamboo:bamboo_trapdoor 2",
				recipe = {
					{bamboo .. "_plank", bamboo .. "_plank", bamboo .. "_plank"},
					{bamboo .. "_plank", bamboo .. "_plank", bamboo .. "_plank"},
				}
			})
		end
	end

	minetest.register_craft({
		output = "mcl_bamboo:scaffolding 6",
		recipe = {{bamboo, "mcl_mobitems:string", bamboo},
				  {bamboo, "", bamboo},
				  {bamboo, "", bamboo}}
	})

	-- Fuels
	-- Basic Bamboo nodes
	minetest.register_craft({
		type = "fuel",
		recipe = bamboo,
		burntime = 2.5, -- supposed to be 1/2 that of a stick, per minecraft wiki as of JE 1.19.3
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo .. "_block",
		burntime = 15,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo .. "_block_stripped",
		burntime = 15,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo .. "_plank",
		burntime = 7.5,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = bamboo .. "_mosaic",
		burntime = 7.5,
	})

	-- Bamboo Items
	if minetest.get_modpath("mcl_doors") then
		if mcl_doors then
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_bamboo:bamboo_door",
				burntime = 10,
			})

			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_bamboo:bamboo_trapdoor",
				burntime = 15,
			})
		end
	end

	if minetest.get_modpath("mcl_stairs") then
		if mcl_stairs ~= nil then
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:slab_bamboo_plank",
				burntime = 7.5,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:slab_bamboo_block",
				burntime = 7.5,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:slab_bamboo_stripped",
				burntime = 7.5,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:stair_bamboo_plank",
				burntime = 15,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:stair_bamboo_block",
				burntime = 15,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:stair_bamboo_stripped",
				burntime = 15,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:slab_bamboo_mosaic",
				burntime = 7.5,
			})
			minetest.register_craft({
				type = "fuel",
				recipe = "mcl_stairs:stair_bamboo_mosaic",
				burntime = 15,
			})
		end
	end

	minetest.register_craft({
		type = "fuel",
		recipe = "mesecons_button:button_bamboo_off",
		burntime = 5,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_bamboo:scaffolding",
		burntime = 20
	})
