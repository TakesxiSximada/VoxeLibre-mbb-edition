---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by michieal.
--- DateTime: 12/29/22 12:33 PM -- Restructure Date
--- Copyright (C) 2022 - 2023, Michieal. See License.txt

-- CONSTS
local DOUBLE_DROP_CHANCE = 8
-- Used everywhere. Often this is just the name, but it makes sense to me as BAMBOO, because that's how I think of it...
-- "BAMBOO" goes here.
local BAMBOO = "mcl_bamboo:bamboo"
local BAMBOO_ENDCAP_NAME = "mcl_bamboo:bamboo_endcap"
local BAMBOO_PLANK = BAMBOO .. "_plank"

-- LOCALS
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local node_sound = mcl_sounds.node_sound_wood_defaults()
local pr = PseudoRandom((os.time() + 15766) * 12) -- switched from math.random() to PseudoRandom because the random wasn't very random.

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.disallow
end

-- basic bamboo nodes.
local bamboo_def = {
	description = "Bamboo",
	tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {handy = 1, axey = 1, choppy = 1, flammable = 3},
	sounds = node_sound,

	drop = {
		max_items = 1,
		-- From the API:
		-- max_items: Maximum number of item lists to drop.
		-- The entries in 'items' are processed in order. For each:
		-- Item filtering is applied, chance of drop is applied, if both are
		-- successful the entire item list is dropped.
		-- Entry processing continues until the number of dropped item lists
		-- equals 'max_items'.
		-- Therefore, entries should progress from low to high drop chance.
		items = {
			-- Examples:
			{
				-- 1 in DOUBLE_DROP_CHANCE chance of dropping.
				-- Default rarity is '1'.
				rarity = DOUBLE_DROP_CHANCE,
				items = {BAMBOO .. " 2"},
			},
			{
				-- 1 in 1 chance of dropping. (Note: this means that it will drop 100% of the time.)
				-- Default rarity is '1'.
				rarity = 1,
				items = {BAMBOO},
			},
		},
	},

	inventory_image = "mcl_bamboo_bamboo_shoot.png",
	wield_image = "mcl_bamboo_bamboo_shoot.png",
	_mcl_blast_resistance = 1,
	_mcl_hardness = 1.5,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.175, -0.5, -0.195, 0.05, 0.5, 0.030},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.175, -0.5, -0.195, 0.05, 0.5, 0.030},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.175, -0.5, -0.195, 0.05, 0.5, 0.030},
		}
	},
	node_placement_prediction = "",

	on_rotate = on_rotate,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local node = minetest.get_node(pointed_thing.under)
		local pos = pointed_thing.under
		local nodename = node.name

		mcl_bamboo.mcl_log("Node placement data:")
		mcl_bamboo.mcl_log(dump(pointed_thing))
		mcl_bamboo.mcl_log("node name: " .. nodename)

		mcl_bamboo.mcl_log("Checking for protected placement of bamboo.")
		if mcl_bamboo.is_protected(pos, placer) then
			return
		end
		mcl_bamboo.mcl_log("placement of bamboo is not protected.")

		-- Use pointed node's on_rightclick function first, if present
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				mcl_bamboo.mcl_log("attempting placement of bamboo via targeted node's on_rightclick.")
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		if mcl_bamboo.is_bamboo(nodename) == false and nodename ~= BAMBOO_ENDCAP_NAME then
			-- not bamboo...
			if nodename ~= "mcl_flowerpots:flower_pot" then
				if mcl_bamboo.is_dirt(nodename) == false then
					mcl_bamboo.mcl_log("bamboo dirt node not found; node name: " .. nodename)
					return
				end
			end
		end

		mcl_bamboo.mcl_log("placing bamboo directly.")

		local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
		local wdir = minetest.dir_to_wallmounted(dir)
		local fdir = minetest.dir_to_facedir(dir)
		if wdir ~= 1 then
			return
		end

		local place_item = ItemStack(itemstack) -- make a copy so that we don't indirectly mess with the original.

		local bamboo_node = mcl_bamboo.is_bamboo(nodename)
		mcl_bamboo.mcl_log("node name: " .. nodename .. "\nbamboo_node: " .. bamboo_node)
		-- intentional use of nodename.

		if bamboo_node ~= -1 then
			place_item = ItemStack(mcl_bamboo.bamboo_index[bamboo_node])
		else
			local placed_type = pr:next(1, 4) -- randomly choose which one to place.
			mcl_bamboo.mcl_log("Place_Bamboo_Shoot--Type: " .. placed_type)
			place_item = ItemStack(mcl_bamboo.bamboo_index[placed_type])
		end

		-- height check for placing bamboo nodes. because... lmfao bamboo stalk to the sky.
		-- variables used in more than one spot.
		local first_shoot
		local chk_pos
		local soil_pos
		local node_name = ""
		local dist = 0
		local height = -1
		local BAMBOO_MAX_HEIGHT = 16 -- base height check.

		local BAMBOO_SOIL_DIST = BAMBOO_MAX_HEIGHT * -1
		-- -------------------
		for py = -1, BAMBOO_SOIL_DIST, -1 do
			chk_pos = vector.offset(pos, 0, py, 0)
			node_name = minetest.get_node(chk_pos).name
			if mcl_bamboo.is_dirt(node_name) then
				soil_pos = chk_pos
				break
			else
				if mcl_bamboo.is_bamboo(node_name) == false then
					break
				end
			end
		end
		-- requires knowing where the soil node is.
		if soil_pos == nil then
			return itemstack -- returning itemstack means don't place.
		end

		first_shoot = vector.offset(soil_pos, 0, 1, 0)
		local meta = minetest.get_meta(first_shoot)

		if meta then
			height = meta:get_int("height", -1)
		end

		dist = vector.distance(soil_pos, chk_pos)

		-- okay, so don't go beyond max height...
		if dist > 15 and height == -1 then
			-- height not found
			return itemstack
		end

		if dist + 1 > height - 1 then
			-- height found.
			return itemstack
		end

		minetest.item_place(place_item, placer, pointed_thing, fdir)
		itemstack:take_item(1)
		return itemstack, pointed_thing.under
	end,

	on_destruct = function(pos)
		-- Node destructor; called before removing node.
		local new_pos = vector.offset(pos, 0, 1, 0)
		local node_above = minetest.get_node(new_pos)
		local bamboo_node = string.sub(node_above.name, 1, string.len(BAMBOO))
		local istack = ItemStack(BAMBOO)
		local sound_params = {
			pos = new_pos,
			gain = 1.0, -- default
			max_hear_distance = 10, -- default, uses a Euclidean metric
		}

		if node_above and (bamboo_node == BAMBOO or node_above.name == BAMBOO_ENDCAP_NAME) then
			minetest.remove_node(new_pos)
			minetest.sound_play(node_sound.dug, sound_params, true)
			if pr:next(1, DOUBLE_DROP_CHANCE) == 1 then
				minetest.add_item(new_pos, istack)
			end
			minetest.add_item(new_pos, istack)
		end
	end,
}
minetest.register_node(BAMBOO, bamboo_def)

local bamboo_top = table.copy(bamboo_def)
bamboo_top.groups = {not_in_creative_inventory = 1, handy = 1, axey = 1, choppy = 1, flammable = 3}
bamboo_top.tiles = {"mcl_bamboo_endcap.png"}
bamboo_top.drawtype = "plantlike_rooted" --"plantlike"
--bamboo_top.paramtype2 = "meshoptions"
--bamboo_top.param2 = 2
bamboo_top.waving = 2
bamboo_top.special_tiles = {{name = "mcl_bamboo_endcap.png"}}
bamboo_top.nodebox = nil
bamboo_top.selection_box = nil
bamboo_top.collision_box = nil

bamboo_top.on_place = function(itemstack, _, _)
	-- Should never occur... but, if it does, then nix it.
	itemstack:set_name(BAMBOO)
	return itemstack
end

minetest.register_node(BAMBOO_ENDCAP_NAME, bamboo_top)

local bamboo_block_def = {
	description = "Bamboo Block",
	tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_block.png"},
	groups = {handy = 1, building_block = 1, axey = 1, flammable = 2, material_wood = 1, bamboo_block = 1, fire_encouragement = 5, fire_flammability = 5},
	sounds = node_sound,
	paramtype2 = "facedir",
	drops = "mcl_bamboo:bamboo_block",
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_bamboo:bamboo_block_stripped", -- this allows us to use the built in Axe's strip block.
	on_place = function(itemstack, placer, pointed_thing)

		local pos = pointed_thing.under

		if mcl_bamboo.is_protected(pos, placer) then
			return
		end

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		return minetest.item_place(itemstack, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(pointed_thing.above, pointed_thing.under)))
	end,

}

minetest.register_node("mcl_bamboo:bamboo_block", bamboo_block_def)

local bamboo_stripped_block = table.copy(bamboo_block_def)
bamboo_stripped_block.on_rightclick = nil
bamboo_stripped_block.description = S("Stripped Bamboo Block")
bamboo_stripped_block.tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png",
							   "mcl_bamboo_bamboo_block_stripped.png"}
minetest.register_node("mcl_bamboo:bamboo_block_stripped", bamboo_stripped_block)
minetest.register_node("mcl_bamboo:bamboo_plank", {
	description = S("Bamboo Plank"),
	_doc_items_longdesc = S("Bamboo Plank"),
	_doc_items_hidden = false,
	tiles = {"mcl_bamboo_bamboo_plank.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1, fire_encouragement = 5, fire_flammability = 20},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

--	Bamboo Part 2 Base nodes.
-- 	Bamboo Mosaic
local bamboo_mosaic = table.copy(minetest.registered_nodes[BAMBOO_PLANK])
bamboo_mosaic.tiles = {"mcl_bamboo_bamboo_plank_mosaic.png"}
bamboo_mosaic.groups = {handy = 1, axey = 1, flammable = 3, fire_encouragement = 5, fire_flammability = 20}
bamboo_mosaic.description = S("Bamboo Mosaic Plank")
bamboo_mosaic._doc_items_longdesc = S("Bamboo Mosaic Plank")
minetest.register_node("mcl_bamboo:bamboo_mosaic", bamboo_mosaic)

--[[ Bamboo alternative node types. Note that the table.copy's are very important! if you use a common node def and
make changes, even after registering them, the changes overwrite the previous node definitions, and in this case,
you will end up with 4 nodes all being type 3. --]]

local bamboo_one_def = table.copy(bamboo_def)
bamboo_one_def.node_box = {
	type = "fixed",
	fixed = {
		{-0.05, -0.5, 0.285, -0.275, 0.5, 0.06},
	}
}
bamboo_one_def.collision_box = {
	-- see [Node boxes] for possibilities
	type = "fixed",
	fixed = {
		{-0.05, -0.5, 0.285, -0.275, 0.5, 0.06},
	}
}
bamboo_one_def.selection_box = {
	type = "fixed",
	fixed = {
		{-0.05, -0.5, 0.285, -0.275, 0.5, 0.06},
	}
}
mcl_bamboo.mcl_log(dump(mcl_bamboo.bamboo_index))
minetest.register_node(mcl_bamboo.bamboo_index[2], bamboo_one_def)
local bamboo_two_def = table.copy(bamboo_def)

bamboo_two_def.node_box = {
	type = "fixed",
	fixed = {
		{0.25, -0.5, 0.325, 0.025, 0.5, 0.100},
	}
}
bamboo_two_def.collision_box = {
	-- see [Node boxes] for possibilities
	type = "fixed",
	fixed = {
		{0.25, -0.5, 0.325, 0.025, 0.5, 0.100},
	}
}
bamboo_two_def.selection_box = {
	type = "fixed",
	fixed = {
		{0.25, -0.5, 0.325, 0.025, 0.5, 0.100},
	}
}
minetest.register_node(mcl_bamboo.bamboo_index[3], bamboo_two_def)
local bamboo_three_def = table.copy(bamboo_def)

bamboo_three_def.node_box = {
	type = "fixed",
	fixed = {
		{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
	}
}
bamboo_three_def.collision_box = {
	-- see [Node boxes] for possibilities
	type = "fixed",
	fixed = {
		{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
	}
}
bamboo_three_def.selection_box = {
	type = "fixed",
	fixed = {
		{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
	}
}
minetest.register_node(mcl_bamboo.bamboo_index[4], bamboo_three_def)
