/**
 * Flattens the origin by converting it to an integer.
 */
flat_origin(origin)
{
	x = origin[0];
	y = origin[1];
	z = origin[2];
	return (int(x), int(y), int(z));
}

/**
 * Sets the origin of all spawnpoint entities to the specified origin.
 */
setAllSpawnPointsToOrigin(origin)
{
	ents = getentarray();
	for (i = 0; i < ents.size; i++)
		if (issubstr(ents[i].classname, "_spawn") && isdefined(ents[i].origin))
			ents[i].origin = origin;
}

/**
 * Delete all map entities that are no use for CJ to free up entity slots.
 */
deleteUselessEntities()
{
	// List of classnames to delete, 1 to delete, 0 to keep
	classnames_delete = [];
	classnames_delete["info_player_start"] = 1;
	classnames_delete["misc_mg42"] = 1;
	classnames_delete["misc_turret"] = 1;
	classnames_delete["mp_ctf_spawn_allies"] = 1;
	classnames_delete["mp_ctf_spawn_allies_start"] = 1;
	classnames_delete["mp_ctf_spawn_axis"] = 1;
	classnames_delete["mp_ctf_spawn_axis_start"] = 1;
	classnames_delete["mp_dm_spawn"] = 1;
	classnames_delete["mp_dom_spawn"] = 1;
	classnames_delete["mp_dom_spawn_allies_start"] = 1;
	classnames_delete["mp_dom_spawn_axis_start"] = 1;
	classnames_delete["mp_global_intermission"] = 0;
	classnames_delete["mp_sab_spawn_allies"] = 1;
	classnames_delete["mp_sab_spawn_allies_start"] = 1;
	classnames_delete["mp_sab_spawn_axis"] = 1;
	classnames_delete["mp_sab_spawn_axis_start"] = 1;
	classnames_delete["mp_sd_spawn_attacker"] = 1;
	classnames_delete["mp_sd_spawn_defender"] = 1;
	classnames_delete["mp_tdm_spawn"] = 1;
	classnames_delete["mp_tdm_spawn_allies_start"] = 1;
	classnames_delete["mp_tdm_spawn_axis_start"] = 1;
	classnames_delete["script_brushmodel"] = 0;
	classnames_delete["script_model"] = 0;
	classnames_delete["script_origin"] = 1;
	classnames_delete["script_struct"] = 1;
	classnames_delete["trigger_hurt"] = 1;
	classnames_delete["trigger_multiple"] = 1;
	classnames_delete["trigger_radius"] = 1;
	classnames_delete["trigger_use_touch"] = 1;
	classnames_delete["worldspawn"] = 0;

	// We need to keep at least one of each tdm spawn
	classnames_keep_one = [];
	classnames_keep_one["mp_tdm_spawn"] = false;
	classnames_keep_one["mp_tdm_spawn_allies_start"] = false;
	classnames_keep_one["mp_tdm_spawn_axis_start"] = false;

	// List of targetnames to delete, 1 to delete, 0 to keep
	targetname_delete = [];
	targetname_delete["ctf_flag_allies"] = 1;
	targetname_delete["ctf_flag_axis"] = 1;
	targetname_delete["exploder"] = 1;
	targetname_delete["flag_descriptor"] = 1;
	targetname_delete["heli_crash_start"] = 1;
	targetname_delete["heli_dest"] = 1;
	targetname_delete["heli_loop_start"] = 1;
	targetname_delete["heli_start"] = 1;
	targetname_delete["minimap_corner"] = 0; // mini map preview
	targetname_delete["sab_bomb"] = 1;
	targetname_delete["sd_bomb"] = 1;

	ents = getentarray();

	for (i = 0; i < ents.size; i++)
	{
		dodelete = false;

		if (isdefined(classnames_delete[ents[i].classname]) && classnames_delete[ents[i].classname] == 1)
		{
			if (isdefined(classnames_keep_one[ents[i].classname]) && classnames_keep_one[ents[i].classname] == false)
			{
				classnames_keep_one[ents[i].classname] = true;
			}
			else
				dodelete = true;
		}

		if (isdefined(targetname_delete[ents[i].targetname]) && targetname_delete[ents[i].targetname] == 1)
			dodelete = true;

		// HQ phone model
		if (ents[i].classname == "script_model" && ents[i].model == "com_cellphone_on")
			dodelete = true;

		if (dodelete)
			ents[i] delete ();
	}
}

/**
 * Gather and return all potential forge models.
 */
get_forge_models()
{
	// keep in alphabetical order
	forge_models = [];
	forge_models["bc_hesco_barrier_med"] = [];
	forge_models["com_bomb_objective"] = [];
	forge_models["com_laptop_2_open"] = [];
	forge_models["com_plasticcase_beige_big"] = [];
	forge_models["pipe"] = [];
	forge_models["terrain"] = [];
	forge_models["arch"] = [];
	forge_models["fuel_tanker"] = [];
	forge_models["fence_piece"] = [];

	script_models = getentarray("script_model", "classname");
	script_brushmodels = getentarray("script_brushmodel", "classname");

	for (i = 0; i < script_models.size; i++)
	{
		if (script_models[i].model == "com_bomb_objective")
		{
			for (j = 0; j < script_brushmodels.size; j++)
			{
				if (!isdefined(script_brushmodels[j].script_gameobjectname))
					continue;

				if (script_brushmodels[j].script_gameobjectname != script_models[i].script_gameobjectname)
					continue;

				if (distance(script_models[i].origin, script_brushmodels[j].origin) > 80)
					continue;

				script_models[i].script_brushmodel = script_brushmodels[j];
				script_brushmodels[j] linkto(script_models[i]);
				forge_models["com_bomb_objective"][forge_models["com_bomb_objective"].size] = script_models[i];
			}
		}

		if (script_models[i].model == "com_laptop_2_open")
		{
			choices = [];
			for (j = 0; j < script_brushmodels.size; j++)
			{
				if (script_brushmodels[j].script_gameobjectname != "hq")
					continue;

				if (!isdefined(script_brushmodels[j].targetname) || script_brushmodels[j].targetname != script_models[i].target)
					continue;

				choices[choices.size] = script_brushmodels[j];
			}

			AssertEx(choices.size == 2, "Expected 2 brush choices for com_laptop_2_open, got " + choices.size);
			// choose the higher Zorigin
			if (choices[0].origin[2] > choices[1].origin[2])
			{
				script_models[i].script_brushmodel = choices[0];
				choices[0] linkto(script_models[i]);
			}
			else
			{
				script_models[i].script_brushmodel = choices[1];
				choices[1] linkto(script_models[i]);
			}

			forge_models["com_laptop_2_open"][forge_models["com_laptop_2_open"].size] = script_models[i];
		}

		if (script_models[i].model == "com_plasticcase_beige_big")
		{
			choices = [];
			for (j = 0; j < script_brushmodels.size; j++)
			{
				if (!isdefined(script_brushmodels[j].script_gameobjectname))
					continue;

				if (script_brushmodels[j].script_gameobjectname != "hq")
					continue;

				if (!isdefined(script_brushmodels[j].targetname) || script_brushmodels[j].targetname != script_models[i].targetname)
					continue;

				choices[choices.size] = script_brushmodels[j];
			}

			AssertEx(choices.size == 2, "Expected 2 brush choices for com_plasticcase_beige_big, got " + choices.size);
			// choose the lower Zorigin
			if (choices[0].origin[2] < choices[1].origin[2])
			{
				script_models[i].script_brushmodel = choices[0];
				choices[0] linkto(script_models[i]);
			}
			else
			{
				script_models[i].script_brushmodel = choices[1];
				choices[1] linkto(script_models[i]);
			}

			forge_models["com_plasticcase_beige_big"][forge_models["com_plasticcase_beige_big"].size] = script_models[i];
		}
	}

	if (getdvar("mapname") == "mp_crossfire")
	{
		// there are 3 bc_hesco_barrier_med script_models linked to 1 script_brushmodel
		for (i = 0; i < script_brushmodels.size; i++)
		{
			if (!isdefined(script_brushmodels[i].script_gameobjectname))
				continue;

			if (script_brushmodels[i].script_gameobjectname != "dom")
				continue;

			bc_hesco_barrier_med_script_brushmodel = script_brushmodels[i];
			bc_hesco_barrier_med_script_models = [];

			for (j = 0; j < script_models.size; j++)
			{
				if (script_models[j].model == "bc_hesco_barrier_med")
				{
					if (distance(script_models[j].origin, bc_hesco_barrier_med_script_brushmodel.origin) < 80)
					{
						script_models[j] linkto(bc_hesco_barrier_med_script_brushmodel);
						script_models[j].forge_parent = bc_hesco_barrier_med_script_brushmodel;
						script_models[j].forge_enabled = true;
						bc_hesco_barrier_med_script_models[bc_hesco_barrier_med_script_models.size] = script_models[j];
					}
				}
			}

			assertex(bc_hesco_barrier_med_script_models.size == 3, "Expected 3 bc_hesco_barrier_med script_models linked to 1 script_brushmodel, got " + bc_hesco_barrier_med_script_models.size);
			bc_hesco_barrier_med_script_brushmodel.forge_children = bc_hesco_barrier_med_script_models;

			forge_models["bc_hesco_barrier_med"][forge_models["bc_hesco_barrier_med"].size] = bc_hesco_barrier_med_script_brushmodel;
		}
	}

	if (getdvar("mapname") == "mp_bog")
	{
		forge_models["arch"][forge_models["arch"].size] = getentbyorigin((3461, -149, 176));
	}

	if (getdvar("mapname") == "mp_cargoship")
	{
		forge_models["fuel_tanker"][forge_models["fuel_tanker"].size] = getentbyorigin((1300, 61, 104));
	}

	if (getdvar("mapname") == "mp_countdown")
	{
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-573, 2956, 32));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-574, 2958, 35));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-581, 2961, -18));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-568, 2953, -18));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-505, 2918, -37));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-506, 2918, 82));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-474, 2900, 36));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-439, 2880, 82));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-505, 2918, -11));
		forge_models["fence_piece"][forge_models["fence_piece"].size] = getentbyorigin((-439, 2880, -12));
	}

	if (getdvar("mapname") == "mp_farm")
	{
		forge_models["pipe"] = getEntArray("gas_station", "targetname");
	}

	if (getdvar("mapname") == "mp_showdown")
	{
		forge_models["terrain"][forge_models["terrain"].size] = getentbyorigin((-1040, 74, 82), 1);
		forge_models["terrain"][forge_models["terrain"].size] = getentbyorigin((-1040, 74, 82), 2);
		forge_models["terrain"][forge_models["terrain"].size] = getentbyorigin((-778, 684, 82), 1);
		forge_models["terrain"][forge_models["terrain"].size] = getentbyorigin((-778, 684, 82), 2);
	}

	// capture the starting positions
	for (i = 0; i < forge_models.size; i++)
	{
		modelName = getarraykeys(forge_models)[i];
		for (j = 0; j < forge_models[modelName].size; j++)
		{
			modelEnt = forge_models[modelName][j];
			modelEnt.startOrigin = modelEnt.origin;
			modelEnt.startAngles = modelEnt.angles;
			modelEnt.forge_enabled = true;
		}
	}

	// Remove empty model types
	to_return = [];
	modelnames = getarraykeys(forge_models);
	for (i = 0; i < modelnames.size; i++)
	{
		if (forge_models[modelnames[i]].size == 0)
			continue;
		else
			to_return[modelnames[i]] = forge_models[modelnames[i]];
	}

	return to_return;
}

/**
 * Finds the nth entity with the specified origin.
 *
 * @param origin - The target origin to match.
 * @param matchNumber - (Optional) The 1-based position of the match to return. Defaults to 1.
 * @returns The entity at the specified matchNumber, or undefined if not found.
 */
getEntByOrigin(origin, matchNumber)
{
	if (!isdefined(matchNumber))
		matchNumber = 1;

	matchCount = 0;

	ents = getentarray();
	for (i = 0; i < ents.size; i++)
	{
		if (ents[i].origin == origin)
		{
			matchCount++;
			if (matchCount == matchNumber)
				return ents[i];
		}
	}
}

/**
 * Spawns an entity in front of the player.
 */
set_ent_position_in_front(ent)
{
	playerAngles = self getPlayerAngles();
	ent.origin = flat_origin(self.origin + (anglestoforward(playerAngles) * 150));
	ent.angles = (0, playerAngles[1], 0);
	self iprintln("Object spawned at " + ent.origin + ent.angles);
}

/**
 * Resets all game objects to their starting positions (if set).
 */
entities_reset_to_start_position()
{
	modelnames = getarraykeys(level.FORGE_MODELS);
	for (i = 0; i < modelnames.size; i++)
	{
		modelName = modelnames[i];
		for (j = 0; j < level.FORGE_MODELS[modelName].size; j++)
		{
			modelEnt = level.FORGE_MODELS[modelName][j];
			modelEnt.origin = modelEnt.startOrigin;
			modelEnt.angles = modelEnt.startAngles;
		}
	}
	iprintln("All game objects reset");
}

/**
 * Hides or shows all entities with the specified script_gameobjectname.
 */
entities_show_hide_by_script_gameobjectname(script_gameobjectname)
{
	hidden = false;
	ents = getentarray();
	for (i = 0; i < ents.size; i++)
	{
		if (isdefined(ents[i].script_gameobjectname) && ents[i].script_gameobjectname == script_gameobjectname)
		{
			if (isdefined(ents[i].hidden) && ents[i].hidden)
			{
				ents[i] show();
				ents[i] solid();
				ents[i].hidden = false;
			}
			else
			{
				ents[i] hide();
				ents[i] notsolid();
				ents[i].hidden = true;
				hidden = true;
			}
		}
	}

	action = "shown";
	if (hidden)
		action = "hidden";

	type = script_gameobjectname;
	if (type == "bombzone")
		type = "sd";

	iprintln(type + " " + action);
}