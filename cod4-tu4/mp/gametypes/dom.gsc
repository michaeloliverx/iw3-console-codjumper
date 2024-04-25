#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.__VERSION__ = "v0.2";

	level.hardcoreMode = true;				// Force hardcore mode

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
											// (disables all obituary messages including those from iPrintln)
	setDvar("ui_hud_showobjicons", 0);		// Hide objective icons from HUD and map

	setDvar("scr_game_perks", 0);			// Remove perks
	setDvar("scr_showperksonspawn", 0);		// Remove perks icons shown on spawn
	setDvar("scr_game_hardpoints", 0);		// Remove killstreaks

	setDvar("player_sprintUnlimited", 1);

	// Remove fall damage
	setDvar("bg_fallDamageMaxHeight", 9999);
	setDvar("bg_fallDamageMinHeight", 9998);

	// Prevent bots from moving
	setDvar("sv_botsRandomInput", 0);
	setDvar("sv_botsPressAttackBtn", 0);

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill("connecting", player);

		// Don't setup bot players
		if ( isDefined( player.pers["isBot"] ) )
			continue;

		player setupPlayer();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
		self thread ammoCheck();
		self thread setupLoadout();
		self thread watchMeleeButtonPressed();
		self thread watchSecondaryOffhandButtonPressed();
		self thread watchFragButtonPressed();
		self thread initMenu();
	}
}

setupPlayer()
{
	self.cj = [];
	self.cj["saves"] = [];
	self.cj["settings"] = [];
	self.cj["deserteagle_choice"] = "deserteaglegold_mp";

	self setClientDvar("cg_overheadRankSize", 0);		// Remove overhead rank
	self setClientDvar("cg_overheadIconSize", 0);		// Remove overhead rank icon
	// self setClientDvar("cg_overheadNamesSize", 0);		// Remove overhead name

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
	self setClientDvar("motd", "CodJumper");

	self setClientDvar("aim_automelee_range", 0);		// Remove melee lunge

	// Disable autoaim for enemy players
	self setClientDvar("aim_slowdown_enabled", 0);
	self setClientDvar("aim_lockon_enabled", 0);

	// Don't show enemy player names 
	self setClientDvar("cg_enemyNameFadeIn", 0);
	self setClientDvar("cg_enemyNameFadeOut", 0);

	// Always show enemies on the map but hide compass, can see enemy positions when pressing start
	self setClientDvar("g_compassShowEnemies", 1);
	self setClientDvar("compassSize", 0.1);
}

initMenuOpts()
{
	self addMenu("main", "CodJumper " + level.__VERSION__, undefined);

	// Host submenu
	if(self GetEntityNumber() == 0)
	{
		self addOpt("main", "[HOST] menu", ::subMenu, "host_menu");
		self addMenu("host_menu", "[HOST] menu", "main");
		self addOpt("host_menu", "Fast restart", ::restartMap);
		self addOpt("host_menu", "Toggle jump_slowdownEnable", ::toggleJumpSlowdown);
		self addOpt("host_menu", "Toggle Old School Mode", ::toggleOldschool);

		// Map selector
		self addOpt("main", "[HOST] Select map", ::subMenu, "host_menu_maps");
		self addMenu("host_menu_maps", "[HOST] Select map", "main");
		self addOpt("host_menu_maps", "Ambush", ::changeMap, "mp_convoy");
		self addOpt("host_menu_maps", "Backlot", ::changeMap, "mp_backlot");
		self addOpt("host_menu_maps", "Bloc", ::changeMap, "mp_bloc");
		self addOpt("host_menu_maps", "Bog", ::changeMap, "mp_bog");
		self addOpt("host_menu_maps", "Broadcast", ::changeMap, "mp_broadcast");
		self addOpt("host_menu_maps", "Chinatown", ::changeMap, "mp_carentan");
		self addOpt("host_menu_maps", "Countdown", ::changeMap, "mp_countdown");
		self addOpt("host_menu_maps", "Crash", ::changeMap, "mp_crash");
		self addOpt("host_menu_maps", "Creek", ::changeMap, "mp_creek");
		self addOpt("host_menu_maps", "Crossfire", ::changeMap, "mp_crossfire");
		self addOpt("host_menu_maps", "District", ::changeMap, "mp_citystreets");
		self addOpt("host_menu_maps", "Downpour", ::changeMap, "mp_farm");
		self addOpt("host_menu_maps", "Killhouse", ::changeMap, "mp_killhouse");
		self addOpt("host_menu_maps", "Overgrown", ::changeMap, "mp_overgrown");
		self addOpt("host_menu_maps", "Pipeline", ::changeMap, "mp_pipeline");
		self addOpt("host_menu_maps", "Shipment", ::changeMap, "mp_shipment");
		self addOpt("host_menu_maps", "Showdown", ::changeMap, "mp_showdown");
		self addOpt("host_menu_maps", "Strike", ::changeMap, "mp_strike");
		self addOpt("host_menu_maps", "Vacant", ::changeMap, "mp_vacant");
		self addOpt("host_menu_maps", "Wet Work", ::changeMap, "mp_cargoship");
	}

	self addOpt("main", "Toggle UFO Mode", ::toggleUFO);
	self addOpt("main", "Toggle 3rd Person", ::toggleThirdPerson);
	self addOpt("main", "Toggle cg_drawgun", ::toggleShowGun);
	self addOpt("main", "Toggle player names", ::togglePlayerNames);
	self addOpt("main", "Toggle gun bob", ::toggleGunBob);
	self addOpt("main", "Spawn bot blocker", ::addBlockerBot);
	self addOpt("main", "Spawn clone", ::addClone);
	self addOpt("main", "Switch Desert Eagle", ::switchDesertEagle);
}

initMenu()
{
	self endon("death");
	self endon("disconnect");

	// Wait until the countdown period is over so player controls aren't unfrozen when menu is open
	if ( level.inPrematchPeriod )
	{
		level waittill("prematch_over");
	}

	level.SCROLL_TIME_SECONDS = 0.15;

	self.inMenu = undefined;

	self.currentMenu = "main";
	self.menuCurs = 0;

	self thread watchUseButtonPressed();

	for(;;)
	{
		if(isDefined(self.inMenu))
		{
			// Menu DOWN
			if(self attackButtonPressed())
			{
				self.menuCurs++;
				if(self.menuCurs > self.menuAction[self.currentMenu].opt.size-1)
					self.menuCurs = 0;
				self.scrollBar moveOverTime(level.SCROLL_TIME_SECONDS);
				self.scrollBar.y = ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2)));
				wait level.SCROLL_TIME_SECONDS;
			}

			// Menu UP
			if(self adsButtonPressed())
			{
				self.menuCurs--;
				if(self.menuCurs < 0)
					self.menuCurs = self.menuAction[self.currentMenu].opt.size-1;
				self.scrollBar moveOverTime(level.SCROLL_TIME_SECONDS);
				self.scrollBar.y = ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2)));
				wait level.SCROLL_TIME_SECONDS;
			}

			// MENU SELECT
			if(self useButtonPressed())
			{
				self thread [[self.menuAction[self.currentMenu].func[self.menuCurs]]](self.menuAction[self.currentMenu].inp[self.menuCurs]);
				wait .2;
			}

			// MENU CLOSE
			if(self meleeButtonPressed())
			{
				if(!isDefined(self.menuAction[self.currentMenu].parent))
				{
					self freezecontrols(false);
					self.inMenu = undefined;
					self.menuCurs = 0;

					self.instructionsBackground destroy();
					self.instructionsText destroy();
					self.openBox destroy();
					self.menuText destroy();
					self.scrollBar destroy();
					self.openText destroy();
				}
				// Go back
				else
					self subMenu(self.menuAction[self.currentMenu].parent);
			}
		}
		wait .05;
	}
}

openCJ()
{
	if(!isDefined(self.inMenu))
	{
		self freezecontrols(true);
		self.inMenu = true;

		self initMenuOpts();
		menuOpts = self.menuAction[self.currentMenu].opt.size;

		instructionsString = "Press [{+activate}] to select item\nPress [{+attack}] [{+speed_throw}] to navigate Menu\nPress [{+melee}] to go back";
		self.instructionsText = self createText("default", 1.5, "TOPLEFT", "LEFT", 10, -54 ,100 ,1, (0, 0, 0) ,instructionsString);
		self.instructionsBackground = self createRectangle("TOPLEFT", "LEFT", 5, -55, 200, 3*19, (0, 0, 0), "white", 4, (1/1.6));

		self.openBox = self createRectangle("TOP", "TOPRIGHT", -160, 10, 300, 445, (0, 0, 0), "white", 1, .7);
		self.openText = self createText("default", 1.5, "TOP", "TOPRIGHT", -160, 16, 2, 1, ( 0, 0, 1), self.menuAction[self.currentMenu].title);
		string = "";
		for(m = 0; m < menuOpts; m++)
			string+= self.menuAction[self.currentMenu].opt[m]+"\n";
		self.menuText = self createText("default", 1.5, "LEFT", "TOPRIGHT", -300, 60, 3, 1, undefined, string);
		self.scrollBar = self createRectangle("TOP", "TOPRIGHT", -160, ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2))), 300, 15, (0, 0, 1), "white", 2, .7);
	}
}

watchUseButtonPressed()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(!self.inMenu && self UseButtonPressed())
		{
			catch_next = false;
			count = 0;

			for(i=0; i<=0.5; i+=0.05)
			{
				if(catch_next && self UseButtonPressed() && !(self isMantling()))
				{
					self thread openCJ();
					wait 1;
					break;
				}
				else if(!(self UseButtonPressed()))
					catch_next = true;

				wait 0.05;
			}
		}

		wait 0.05;
	}
}

subMenu(menu)
{
	self.menuCurs = 0;
	self.currentMenu = menu;
	self.scrollBar moveOverTime(.2);
	self.scrollBar.y = ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2)));
	self.menuText destroy();
	self initMenuOpts();
	self.openText setText(self.menuAction[self.currentMenu].title);
	menuOpts = self.menuAction[self.currentMenu].opt.size;

	wait .2;
	string = "";
	for(m = 0; m < menuOpts; m++)
		string+= self.menuAction[self.currentMenu].opt[m]+"\n";
	self.menuText = self createText("default", 1.5, "LEFT", "TOPRIGHT", -300, 60, 3, 1, undefined, string);
	wait .2;
}

test()
{
	self iPrintln("^4MENU BASE TEST");
}

addMenu(menu, title, parent)
{
	if(!isDefined(self.menuAction))
		self.menuAction = [];
	self.menuAction[menu] = spawnStruct();
	self.menuAction[menu].title = title;
	self.menuAction[menu].parent = parent;
	self.menuAction[menu].opt = [];
	self.menuAction[menu].func = [];
	self.menuAction[menu].inp = [];
}

addOpt(menu, opt, func, inp)
{
	m = self.menuAction[menu].opt.size;
	self.menuAction[menu].opt[m] = opt;
	self.menuAction[menu].func[m] = func;
	self.menuAction[menu].inp[m] = inp;
}

createText(font, fontScale, align, relative, x, y, sort, alpha, glow, text)
{
	textElem = self createFontString(font, fontScale, self);
	textElem setPoint(align, relative, x, y);
	textElem.sort = sort;
	textElem.alpha = alpha;
	textElem.glowColor = glow;
	textElem.glowAlpha = 1;
	textElem setText(text);
	self thread destroyOnDeath(textElem);
	return textElem;
}

createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	boxElem = newClientHudElem(self);
	boxElem.elemType = "bar";
	if(!level.splitScreen)
	{
		boxElem.x = -2;
		boxElem.y = -2;
	}
	boxElem.width = width;
	boxElem.height = height;
	boxElem.align = align;
	boxElem.relative = relative;
	boxElem.xOffset = 0;
	boxElem.yOffset = 0;
	boxElem.children = [];
	boxElem.sort = sort;
	boxElem.color = color;
	boxElem.alpha = alpha;
	boxElem setParent(level.uiParent);
	boxElem setShader(shader, width, height);
	boxElem.hidden = false;
	boxElem setPoint(align, relative, x, y);
	self thread destroyOnDeath(boxElem);
	return boxElem;
}

destroyOnDeath(elem)
{
	self waittill_any("death", "disconnect");
	if(isDefined(elem.bar))
		elem destroyElem();
	else
		elem destroy();
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
		wait 2;
	}
}

setupLoadout()
{
	
	self clearPerks();						// Remove all perks
	self setPerk("specialty_fastreload");	// Give Sleight of Hand

	self takeAllWeapons();

	self giveWeapon("c4_mp");
	self SetActionSlot( 2, "weapon", "c4_mp" );

	self giveWeapon("rpg_mp");
	self SetActionSlot( 3, "weapon", "rpg_mp" );

	deserteagle_choice = self.cj["deserteagle_choice"];

	self giveWeapon(deserteagle_choice);
	wait 0.05;
	self switchToWeapon(deserteagle_choice);

	// Oldschool mode gets the default oldschool weapons
	if(getDvarInt("jump_height") == 64)
	{
		self takeWeapon(deserteagle_choice);
		self giveWeapon("skorpion_mp");
		self giveWeapon("beretta_mp");
		wait 0.05;
		self switchToWeapon("beretta_mp");
	}
	else if(self.pers["class"] == "CLASS_HEAVYGUNNER" || self.pers["class"] == "OFFLINE_CLASS3")
	{
		self giveWeapon("m60e4_mp", 6);		// Gold M60
	}
	else if(self.pers["class"] == "CLASS_SNIPER" || self.pers["class"] == "OFFLINE_CLASS5")
	{
		self giveWeapon("dragunov_mp", 6);	// Gold Dragunov
	}
	else
	{
		self giveWeapon("uzi_mp", 6);		// Gold Mini-Uzi
	}
}

watchMeleeButtonPressed()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(!self.inMenu && self meleeButtonPressed())
		{
			catch_next = false;
			count = 0;

			for(i=0; i<0.5; i+=0.05)
			{
				if(catch_next && self meleeButtonPressed() && self isOnGround())
				{
					self thread savePos(1);
					wait .1;
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

watchSecondaryOffhandButtonPressed()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(!self.inMenu && self secondaryOffhandButtonPressed() && !(self isMantling()))
		{
			self loadPos(1);
			wait .1;
		}
		wait 0.05;
	}
}

watchFragButtonPressed()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self FragButtonPressed())
		{
			self thread toggleUFO();
			wait 0.5;
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

	self setPlayerAngles(self.cj["save"]["ang"+i]);
	self setOrigin(self.cj["save"]["org"+i]);

	wait 0.05;
	self freezecontrols(false);
}

initBot()
{
	bot = addtestclient();
	bot.pers["isBot"] = true;
	while (!isDefined(bot.pers["team"])) wait 0.05;
	bot notify("menuresponse", game["menu_team"], self.team);
	wait 0.5;
	bot.weaponPrefix = "ak47_mp";
	bot notify("menuresponse", "changeclass", "specops_mp");
	bot waittill("spawned_player");
	bot.selectedClass = true;
	while (bot.sessionstate != "playing") wait 0.05;
	bot FreezeControls(true);
	return bot;
}

addBlockerBot()
{
	if (!isDefined(self.bot))
	{
		self.bot = initBot();
		if (!isDefined(self.bot))
		{
			self iPrintLn("^1Couldn't spawn a bot");
			return;
		}
	}

	origin = self.origin;
	wait 0.5;
	for (i = 3; i > 0; i--)
	{
		self iPrintLn("Bot spawns in ^2" + i);
		wait 1;
	}
	self.bot setOrigin(origin);
}

toggleOldschool()
{
	setting = "oldschool";
	printName = "Old School Mode";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self.cj["settings"]["jump_slowdownEnable"] = false;
		setDvar( "jump_height", 64 );
		setDvar( "jump_slowdownEnable", 0 );
		iPrintln(printName + " [^2ON^7]");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self.cj["settings"]["jump_slowdownEnable"] = true;
		setDvar( "jump_height", 39 );
		setDvar( "jump_slowdownEnable", 1 );
		iPrintln(printName + " [^1OFF^7]");
	}
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if(isAlive(player))
		{
			player setupLoadout();
		}
	}
}

toggleJumpSlowdown()
{
	setting = "jump_slowdownEnable";
	printName = setting;

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == true)
	{
		self.cj["settings"][setting] = false;
		setDvar("jump_slowdownEnable", 0);
		iPrintln(printName + " [^1OFF^7]");
	}
	else
	{
		self.cj["settings"][setting] = true;
		setDvar("jump_slowdownEnable", 1);
		iPrintln(printName + " [^2ON^7]");
	}
}

toggleShowGun()
{
	setting = "cg_drawgun";
	printName = setting;

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == true)
	{
		self.cj["settings"][setting] = false;
		self setClientDvar("cg_drawgun", 0);
		self iPrintln(printName + " [^1OFF^7]");
	}
	else
	{
		self.cj["settings"][setting] = true;
		self setClientDvar("cg_drawgun", 1);
		self iPrintln(printName + " [^2ON^7]");
	}
}

toggleThirdPerson()
{
	setting = "cg_thirdPerson";
	printName = "3rd Person";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self setClientDvar("cg_thirdPerson", 1);
		self iPrintln(printName + " [^2ON^7]");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self setClientDvar("cg_thirdPerson", 0);
		self iPrintln(printName + " [^1OFF^7]");
	}
}

toggleUFO()
{
	setting = "ufo_mode";
	printName = "UFO Mode";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self allowSpectateTeam("freelook", true);
		self.sessionstate = "spectator";
		self iPrintln(printName + " [^2ON^7]");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self allowSpectateTeam("freelook", false);
		self.sessionstate = "playing";
		self iPrintln(printName + " [^1OFF^7]");
	}
}

togglePlayerNames()
{
	setting = "cg_overheadnamessize";
	printName = "Player names";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == true)
	{
		self.cj["settings"][setting] = false;
		self setClientDvar(setting, 0);
		self iPrintln(printName + " [^1OFF^7]");
	}
	else
	{
		self.cj["settings"][setting] = true;
		self setClientDvar(setting, 0.65);
		self iPrintln(printName + " [^2ON^7]");
	}
}

toggleGunBob()
{
	setting = "bg_bobMax";
	printName = "Gun bob";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == true)
	{
		self.cj["settings"][setting] = false;
		self setClientDvar(setting, 0);
		self iPrintln(printName + " [^1OFF^7]");
	}
	else
	{
		self.cj["settings"][setting] = true;
		self setClientDvar(setting, 8);
		self iPrintln(printName + " [^2ON^7]");
	}
}

addClone()
{
	body = self clonePlayer(100000);
	self.cj["clones"][self.cj["clones"].size] = body;
}

switchDesertEagle()
{
	if(self.cj["deserteagle_choice"] == "deserteaglegold_mp")
		self.cj["deserteagle_choice"] = "deserteagle_mp";
	else
		self.cj["deserteagle_choice"] = "deserteaglegold_mp";

	self setupLoadout();
}

restartMap()
{
	Map_Restart( false );
}

changeMap(mapname)
{
	Map( mapname );
}
