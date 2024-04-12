init()
{
	// TEAM DEATHMATCH
	setDvar("scr_war_scorelimit", 0);
	setDvar("scr_war_timelimit", 0);

	// SABOTAGE
	setDvar("scr_sab_scorelimit", 0);
	setDvar("scr_sab_timelimit", 0);
	setDvar("scr_sab_playerrespawndelay", 0);

	// SEARCH AND DESTROY
	setDvar("scr_sd_scorelimit", 0);
	setDvar("scr_sd_timelimit", 0);
	setDvar("scr_sd_numlives", 0);

	// UI
	// setDvar("ui_hud_hardcore", 1);
	// setDvar("ui_hud_obituaries", 0);		// Hide when player switches teams / dies
	setDvar("ui_hud_showobjicons", 0);		// Hide objective icons from HUD and map

	setDvar("scr_game_perks", 0);			// Remove perks
	setDvar("scr_showperksonspawn", 0);		// Remove perks icons shown on spawn
	setDvar("scr_game_hardpoints", 0);		// Remove killstreaks

	setDvar("player_sprintUnlimited", 1);

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill("connecting", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		self setClientDvar("aim_automelee_range", 0);		// Remove melee lunge
		self setClientDvar("cg_overheadRankSize", 0);		// Remove overhead rank
		self setClientDvar("cg_overheadIconSize", 0);		// Remove overhead rank icon
		self setClientDvar("nightVisionDisableEffects", 1);	// Remove nightvision fx

		// Remove objective waypoints on screen
		self setClientDvar("waypointIconWidth", 0.1);
		self setClientDvar("waypointIconHeight", 0.1);
		self setClientDvar("waypointOffscreenPointerWidth", 0.1);
		self setClientDvar("waypointOffscreenPointerHeight", 0.1);

		self thread setupClass();
		self thread ammoCheck();
	}
}

setupClass()
{
	self endon("death");
	self endon("disconnect");
	self endon("game_ended");

	self clearPerks();						// Remove all perks
	self setPerk("specialty_fastreload");	// Give Sleight of Hand

	self takeAllWeapons();

	self giveWeapon("rpg_mp");
	self SetActionSlot( 3, "weapon", "rpg_mp" );

	// TODO oldschool mode
	// skorpion_mp + beretta_mp

	self giveWeapon("deserteaglegold_mp");
	wait 0.05;
	self switchToWeapon("deserteaglegold_mp");

	if(self.pers["class"] == "CLASS_HEAVYGUNNER" || self.pers["class"] == "OFFLINE_CLASS3")
	{
		self giveWeapon("m60e4_mp", 6);
	}
	else if(self.pers["class"] == "CLASS_SNIPER" || self.pers["class"] == "OFFLINE_CLASS5")
	{
		self giveWeapon("dragunov_mp", 6);
	}
	else
	{
		self giveWeapon("uzi_mp", 6);
	}
}

ammoCheck()
{
	self endon("death");
	self endon("disconnect");
	self endon("game_ended");

	for (;;)
	{
		currentWeapon = self getCurrentWeapon();
		if (!self isMantling() && !self isOnLadder() && self getAmmoCount(currentWeapon) <= weaponClipSize(currentWeapon))
		{
			self giveMaxAmmo(currentWeapon);
		}
		wait 1;
	}
}
