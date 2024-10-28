main()
{
	maps\mp\gametypes\war::main();
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
