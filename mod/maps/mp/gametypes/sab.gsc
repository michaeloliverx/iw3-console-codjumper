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

