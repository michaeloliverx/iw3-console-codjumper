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
	setDvar("player_footstepsThreshhold", 50000);				 // Disable footsteps sounds TODO: disable jump sounds
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

		player setclientdvar("loc_warnings", 0);				  // Disable unlocalized warnings
		player setclientdvar("compassSize", 0.001);				  // Hide compass
		player setclientdvar("player_view_pitch_up", 89.9);		  // Allow looking straight up
		player setclientdvar("ui_ConnectScreenTextGlowColor", 0); // Remove glow color applied to the mode and map name strings on the connect screen
		player setclientdvar("cg_descriptiveText", 0);			  // Disable spectator button icons
		player setclientdvar("player_spectateSpeedScale", 1.5);	  // Faster movement in spectator

		// developer dvars
		player setclientdvar("developer", 1);
		player setclientdvar("developer_script", 1);
		player setclientdvar("con_minicon", 1);
		player setclientdvar("con_miniconlines", 20);
		player setclientdvar("con_minicontime", 10);

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	for (;;)
	{
		self waittill("spawned_player");
		self initLoadout();
		self thread replenishAmmo();
	}
}

/**
 * Set the player's loadout.
 */
initLoadout()
{
	self takeallweapons();
	self giveweapon("deserteagle_mp");
	self giveWeapon("rpg_mp");
	self setactionslot(3, "weapon", "rpg_mp");

	wait 0.05;
	self switchtoweapon("deserteagle_mp");
}

/**
 * Constantly replace the players ammo.
 */
replenishAmmo()
{
	self endon("end_respawn");
	self endon("disconnect");

	for (;;)
	{
		currentWeapon = self getCurrentWeapon(); // undefined if the player is mantling or on a ladder
		if (isdefined(currentWeapon))
			self giveMaxAmmo(currentWeapon);
		wait 1;
	}
}
