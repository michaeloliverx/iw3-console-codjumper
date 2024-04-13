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

	// DEATHMATCH
	setDvar("scr_dm_scorelimit", 0);
	setDvar("scr_dm_timelimit", 0);
	setDvar("scr_dm_roundlimit", 0);

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

		// Disable FX
		self setClientDvar("fx_enable", 0);
		self setClientDvar("fx_marks", 0);
		self setClientDvar("fx_marks_ents", 0);
		self setClientDvar("fx_marks_smodels", 0);

		self setClientDvar("clanname", "");					// Remove clan tag

		if(self isHost()){
			self thread watchOldschoolModeToggle();
		}
		self thread doWelcomeMessage();
		self thread setupClass();
		self thread ammoCheck();
		self thread watchLB();
		self thread watchRS();
		self thread watchX();
	}
}

isHost()
{
	return self GetEntityNumber() == 0;
}

doWelcomeMessage()
{
	if ( level.inPrematchPeriod )
	{
		level waittill("prematch_over");
	}
	thread maps\mp\gametypes\_hud_message::oldNotifyMessage( "CodJumper", "by mo", undefined, undefined);
	self iPrintln("^7Save Position=2x [{+melee}]\nLoad Position=2x [{+usereload}]\nUFO Mode=[{+smoke}]");
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

	if(level.oldschool == true)
	{
		self takeWeapon("deserteaglegold_mp");
		self giveWeapon("skorpion_mp");
		self giveWeapon("beretta_mp");
		wait 0.05;
		self switchToWeapon("beretta_mp");
	}
	else if(self.pers["class"] == "CLASS_HEAVYGUNNER" || self.pers["class"] == "OFFLINE_CLASS3")
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

watchOldschoolModeToggle()
{
	self endon("death");
	self endon("disconnect");
	self endon("game_ended");

	for (;;)
	{
		self waittill( "night_vision_on" );
		self toggleOldschoolMode();
		self waittill( "night_vision_off" );
		self toggleOldschoolMode();
		wait 0.05;
	}
}

toggleOldschoolMode() {
	if(level.oldschool == true)
	{
		self sayAll("Oldschool mode [^1OFF^7]");
		level.oldschool = false;
		setDvar( "jump_height", 39 );
		setDvar( "jump_slowdownEnable", 1 );
		self thread killAllPlayers();
	}
	else
	{
		self sayAll("Oldschool mode [^2ON^7]");
		level.oldschool = true;
		setDvar( "jump_height", 64 );
		setDvar( "jump_slowdownEnable", 0 );
		self thread killAllPlayers();
	}
}

killAllPlayers()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if(isAlive(player))
		{
			player suicide();
		}
	}
}

watchLB()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self SecondaryOffhandButtonPressed())
		{
			self thread toggleUFO();
			wait 1;
		}
		wait 0.05;
	}
}

toggleUFO()
{
	if(!self.ufoMode)
	{
		self allowSpectateTeam("freelook", true);
		self.sessionstate = "spectator";
		self iPrintln("UFO Mode [^2ON^7]");
		self.ufoMode = true;
	}
	else
	{
		self allowSpectateTeam("freelook", false);
		self.sessionstate = "playing";
		self iPrintln("UFO Mode [^1OFF^7]");
		self.ufoMode = false;
	}
}

watchRS()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self meleeButtonPressed())
		{
			catch_next = false;
			count = 0;

			for(i=0; i<0.5; i+=0.05)
			{
				if(catch_next && self meleeButtonPressed() && self isOnGround())
				{
					self thread savePos(1);
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && self isOnGround())
				{
					while(self attackButtonPressed() && count < 1)
					{
						count+=0.1;
						wait 0.1;
					}
					if(count >= 1 && self isOnGround())
						self thread savePos(3);
					else if(count < 1 && self isOnGround())
						self thread savePos(2);

					wait 1;
					break;
				}
				else if(!(self meleeButtonPressed()) && !(self attackButtonPressed()))
					catch_next = true;

				wait 0.05;
			}
		}

		wait 0.05;
	}
}

watchX()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self useButtonPressed())
		{
			catch_next = false;
			count = 0;

			for(i=0; i<=0.5; i+=0.05)
			{
				if(catch_next && self useButtonPressed() && !(self isMantling()))
				{
					self thread loadPos(1);
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && !(self isMantling()))
				{
					while(self attackButtonPressed() && count < 1)
					{
						count+= 0.1;
						wait 0.1;
					}
					if(count < 1 && self isOnGround() && !(self isMantling()))
						self thread loadPos(2);
					else if(count >= 1 && self isOnGround() && !(self isMantling()))
						self thread loadPos(3);

					wait 1;
					break;
				}
				else if(!(self useButtonPressed()))
					catch_next = true;

				wait 0.05;
			}
		}

		wait 0.05;
	}
}

savePos(i)
{
	wait 0.05;
	self.cj["save"]["org"+i] = self.origin;
	self.cj["save"]["ang"+i] = self getPlayerAngles();
}

loadPos(i)
{
	self freezecontrols(true);
	wait 0.05;

	if(!self isOnGround())
		wait 0.05;

	self setPlayerAngles(self.cj["save"]["ang"+i]);
	self setOrigin(self.cj["save"]["org"+i]);

	if(!self isOnGround())
		wait 0.05;

	wait 0.05;
	self freezecontrols(false);
}
