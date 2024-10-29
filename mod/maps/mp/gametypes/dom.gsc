main()
{
	maps\mp\gametypes\war::main();
}

initCJ()
{
	level.hardcoreMode = true;												  // Disable HUD elements
	level.MAP_CENTER_GROUND_ORIGIN = getent("sab_bomb", "targetname").origin; // sab_bomb is always placed in the center of the map

	setdvar("scr_" + level.gametype + "_timelimit", 0);			 // Disable the time limit
	setdvar("scr_" + level.gametype + "_scorelimit", 0);		 // Disable the score limit
	setdvar("scr_" + level.gametype + "_playerrespawndelay", 0); // Disable the respawn delay
	setdvar("scr_" + level.gametype + "_numlives", 0);			 // Disable the number of lives
	setdvar("scr_" + level.gametype + "_roundlimit", 0);		 // Disable the round limit
	setDvar("scr_game_hardpoints", 0);							 // Disable killstreaks
	setDvar("scr_game_perks", 0);								 // Disable perks
	setDvar("scr_showperksonspawn", 0);							 // Don't show perks on spawn, also has the side effect of not creating the 6 (3 text + 3 icon) HUD elements
	setDvar("scr_game_hardpoints", 0);							 // Disable killstreaks
	setDvar("player_sprintUnlimited", 1);						 // Unlimited sprint
	setDvar("jump_slowdownEnable", 0);							 // Disable jump slowdown

	// Remove fall damage
	setDvar("bg_fallDamageMaxHeight", 9999);
	setDvar("bg_fallDamageMinHeight", 9998);

	setDvar("sv_botsPressAttackBtn", 0); // Prevent testclients from pressing attack button

	// prevent dynents from moving from bullets / explosions
	setdvar("dynEnt_active", 0);
	setdvar("dynEnt_bulletForce", 0);
	setdvar("dynEnt_explodeForce", 0);
	setdvar("dynEnt_explodeMaxEnts", 0);
	setdvar("dynEnt_explodeMinForce", 9999999999);
	setdvar("dynEnt_explodeSpinScale", 0);
	setdvar("dynEnt_explodeUpbias", 0);
	setdvar("dynEntPieces_angularVelocity", 0);
	setdvar("dynEntPieces_impactForce", 0);
	setdvar("dynEntPieces_velocity", 0);

	AmbientStop(); // Stop all ambient sounds

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);

		player setClientDvar("loc_warnings", 0);	// Disable unlocalized warnings
		player setClientDvar("compassSize", 0.001); // Hide compass

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	for (;;)
	{
		self waittill("spawned_player");
	}
}
