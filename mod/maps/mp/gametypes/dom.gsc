#include maps\mp\gametypes\_hud_util;

main()
{
	maps\mp\gametypes\war::main();
}

initCJ()
{
	// Virtual resolution for HUD elements; scaled to real monitor dimensions by the game engine
	level.SCREEN_MAX_WIDTH = 640;
	level.SCREEN_MAX_HEIGHT = 480;

	level.MENU_WIDTH = int(level.SCREEN_MAX_WIDTH * 0.2); // force int because shaders dimensions won't work with floats
	level.MENU_SCROLL_TIME_SECONDS = 0.250;
	level.MENU_TEXT_PADDING_LEFT = 5;
	level.MENU_SCROLLER_ALPHA = 0.7;

	level.THEMES = [];
	level.THEMES["teal"] = rgbToNormalized((0, 128, 128));
	level.THEMES["pink"] = rgbToNormalized((255, 25, 127));
	level.THEMES["orangered"] = rgbToNormalized((255, 69, 0));
	level.THEMES["gold"] = rgbToNormalized((255, 215, 0));
	level.THEMES["blue"] = rgbToNormalized((0, 0, 255));
	level.THEMES["deepskyblue"] = rgbToNormalized((0, 191, 255));
	level.THEMES["purple"] = rgbToNormalized((90, 0, 208));
	level.THEMES["green"] = rgbToNormalized((0, 208, 98));
	level.THEMES["maroon"] = rgbToNormalized((128, 0, 0));
	level.THEMES["salmon"] = rgbToNormalized((250, 128, 114));
	level.THEMES["silver"] = rgbToNormalized((192, 192, 192));

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
		self thread watchbuttons();
		self initLoadout();
		self thread replenishAmmo();
	}
}

/**
 * Normalize RGB values (0-255) to (0-1).
 */
rgbToNormalized(rgb)
{
	return (rgb[0] / 255, rgb[1] / 255, rgb[2] / 255);
}

/**
 * Add a menu to the menuOptions array.
 * @param menuKey The key to identify the menu.
 * @param parentMenuKey The key of the parent menu.
 */
addMenu(menuKey, parentMenuKey)
{
	if (!isdefined(self.menuOptions))
		self.menuOptions = [];
	self.menuOptions[menuKey] = spawnstruct();
	self.menuOptions[menuKey].parent = parentMenuKey;
	self.menuOptions[menuKey].options = [];
}

/**
 * Add a menu option to the menuOptions array.
 * @param menuKey The menu key to add the option to.
 * @param label The text to display for the option.
 * @param func The function to call when the option is selected.
 * @param param1 The first parameter to pass to the function. (optional)
 * @param param2 The second parameter to pass to the function. (optional)
 * @param param3 The third parameter to pass to the function. (optional)
 */
addMenuOption(menuKey, label, func, param1, param2, param3)
{
	option = spawnstruct();
	option.label = label;
	option.func = func;
	option.inputs = [];

	if (isdefined(param1))
		option.inputs[0] = param1;
	if (isdefined(param2))
		option.inputs[1] = param2;
	if (isdefined(param3))
		option.inputs[2] = param3;

	self.menuOptions[menuKey].options[self.menuOptions[menuKey].options.size] = option;
}

/**
 * Generate the menu options.
 */
generateMenu()
{
	// Theme menu
	self addMenu("theme_menu", "main_menu");
	themes = getarraykeys(level.THEMES);
	for (i = 0; i < themes.size; i++)
		self addMenuOption("theme_menu", themes[i], ::menuAction, "CHANGE_THEME", themes[i]);

	// Main menu
	self addMenu("main_menu");
	self addMenuOption("main_menu", "Theme Menu", ::menuAction, "CHANGE_MENU", "theme_menu");
	self addMenuOption("main_menu", "Unknown Menu", ::menuAction, "CHANGE_MENU", "does_not_exist");
}

menuKeyExists(menuKey)
{
	return isdefined(self.menuOptions[menuKey]);
}

/**
 * Get the menu text for the current menu.
 */
getMenuText()
{
	if (!menuKeyExists(self.menuKey))
	{
		self iprintln("^1menu key " + self.menuKey + " does not exist");
		return "";
	}

	string = "";
	for (i = 0; i < self.menuOptions[self.menuKey].options.size; i++)
		string += self.menuOptions[self.menuKey].options[i].label + "\n";

	// hud elements can have a maximum of 255 characters otherwise they disappear
	if (string.size > 255)
		self iprintln("^1menu text exceeds 255 characters. current size: " + string.size);

	return string;
}

/**
 * Initialize the menu HUD elements.
 */
initMenuHudElem()
{
	menuBackground = newClientHudElem(self);
	menuBackground.elemType = "icon";
	menuBackground.children = [];
	menuBackground.sort = 1;
	menuBackground.color = (0, 0, 0);
	menuBackground.alpha = 0.5;
	menuBackground setParent(level.uiParent);
	menuBackground setShader("white", level.MENU_WIDTH, level.SCREEN_MAX_HEIGHT);
	menuBackground.x = level.SCREEN_MAX_WIDTH - level.MENU_WIDTH;
	menuBackground.y = 0;
	menuBackground.alignX = "left";
	menuBackground.alignY = "top";
	menuBackground.horzAlign = "fullscreen";
	menuBackground.vertAlign = "fullscreen";
	self.menuBackground = menuBackground;

	menuBorderLeft = newClientHudElem(self);
	menuBorderLeft.elemType = "icon";
	menuBorderLeft.children = [];
	menuBorderLeft.sort = 2;
	menuBorderLeft.color = self.themeColor;
	menuBorderLeft.alpha = level.MENU_SCROLLER_ALPHA;
	menuBorderLeft setParent(level.uiParent);
	menuBorderLeft setShader("white", 2, level.SCREEN_MAX_HEIGHT);
	menuBorderLeft.x = (level.SCREEN_MAX_WIDTH - level.MENU_WIDTH);
	menuBorderLeft.y = 0;
	menuBorderLeft.alignX = "left";
	menuBorderLeft.alignY = "top";
	menuBorderLeft.horzAlign = "fullscreen";
	menuBorderLeft.vertAlign = "fullscreen";
	self.menuBorderLeft = menuBorderLeft;

	menuScroller = newClientHudElem(self);
	menuScroller.elemType = "icon";
	menuScroller.children = [];
	menuScroller.sort = 2;
	menuScroller.color = self.themeColor;
	menuScroller.alpha = level.MENU_SCROLLER_ALPHA;
	menuScroller setParent(level.uiParent);
	menuScroller setShader("white", level.MENU_WIDTH, int(level.fontHeight * 1.5));
	menuScroller.x = level.SCREEN_MAX_WIDTH - level.MENU_WIDTH;
	menuScroller.y = int(level.SCREEN_MAX_HEIGHT * 0.15);
	menuScroller.alignX = "left";
	menuScroller.alignY = "top";
	menuScroller.horzAlign = "fullscreen";
	menuScroller.vertAlign = "fullscreen";
	self.menuScroller = menuScroller;

	menuTextFontElem = newClientHudElem(self);
	menuTextFontElem.elemType = "font";
	menuTextFontElem.font = "default";
	menuTextFontElem.fontscale = 1.5;
	menuTextFontElem.children = [];
	menuTextFontElem.sort = 3;
	menuTextFontElem setParent(level.uiParent);
	menuTextFontElem settext(getMenuText());
	menuTextFontElem.x = (level.SCREEN_MAX_WIDTH - level.MENU_WIDTH) + level.MENU_TEXT_PADDING_LEFT;
	menuTextFontElem.y = int(level.SCREEN_MAX_HEIGHT * 0.15);
	menuTextFontElem.alignX = "left";
	menuTextFontElem.alignY = "top";
	menuTextFontElem.horzAlign = "fullscreen";
	menuTextFontElem.vertAlign = "fullscreen";
	self.menuTextFontElem = menuTextFontElem;

	menuHeaderFontElem = newClientHudElem(self);
	menuHeaderFontElem.elemType = "font";
	menuHeaderFontElem.font = "objective";
	menuHeaderFontElem.fontscale = 2;
	menuHeaderFontElem.glowColor = self.themeColor;
	menuHeaderFontElem.glowAlpha = 1;
	menuHeaderFontElem.children = [];
	menuHeaderFontElem.sort = 3;
	menuHeaderFontElem setParent(level.uiParent);
	menuHeaderFontElem.x = (level.SCREEN_MAX_WIDTH - level.MENU_WIDTH) + level.MENU_TEXT_PADDING_LEFT;
	menuHeaderFontElem.y = int(level.SCREEN_MAX_HEIGHT * 0.025);
	menuHeaderFontElem.alignX = "left";
	menuHeaderFontElem.alignY = "top";
	menuHeaderFontElem.horzAlign = "fullscreen";
	menuHeaderFontElem.vertAlign = "fullscreen";
	menuHeaderFontElem settext("CodJumper");
	self.menuHeaderFontElem = menuHeaderFontElem;

	menuHeaderAuthorFontElem = newClientHudElem(self);
	menuHeaderAuthorFontElem.elemType = "font";
	menuHeaderAuthorFontElem.font = "default";
	menuHeaderAuthorFontElem.fontscale = 1.5;
	menuHeaderAuthorFontElem.glowColor = self.themeColor;
	menuHeaderAuthorFontElem.glowAlpha = 0.1;
	menuHeaderAuthorFontElem.children = [];
	menuHeaderAuthorFontElem.sort = 3;
	menuHeaderAuthorFontElem setParent(level.uiParent);
	menuHeaderAuthorFontElem.x = (level.SCREEN_MAX_WIDTH - level.MENU_WIDTH) + level.MENU_TEXT_PADDING_LEFT;
	menuHeaderAuthorFontElem.y = int(level.SCREEN_MAX_HEIGHT * 0.075);
	menuHeaderAuthorFontElem.alignX = "left";
	menuHeaderAuthorFontElem.alignY = "top";
	menuHeaderAuthorFontElem.horzAlign = "fullscreen";
	menuHeaderAuthorFontElem.vertAlign = "fullscreen";
	menuHeaderAuthorFontElem settext("v1.0.0    --> by mo");
	self.menuHeaderAuthorFontElem = menuHeaderAuthorFontElem;
}

/**
 * Handle menu actions.
 * @param action The action to perform.
 * @param param1 The action parameter. (optional)
 */
menuAction(action, param1)
{
	if (!isdefined(self.themeColor))
		self.themeColor = level.THEMES["teal"];

	if (!isdefined(self.menuKey))
		self.menuKey = "main_menu";

	if (!isdefined(self.menuCursor))
		self.menuCursor = [];

	if (!isdefined(self.menuCursor[self.menuKey]))
		self.menuCursor[self.menuKey] = 0;

	switch (action)
	{
	case "UP":
	case "DOWN":
		if (action == "UP")
			self.menuCursor[self.menuKey]--;
		else if (action == "DOWN")
			self.menuCursor[self.menuKey]++;

		if (self.menuCursor[self.menuKey] < 0)
			self.menuCursor[self.menuKey] = self.menuOptions[self.menuKey].options.size - 1;
		else if (self.menuCursor[self.menuKey] > self.menuOptions[self.menuKey].options.size - 1)
			self.menuCursor[self.menuKey] = 0;

		self.menuScroller moveOverTime(level.MENU_SCROLL_TIME_SECONDS);
		self.menuScroller.y = (level.SCREEN_MAX_HEIGHT * 0.15 + ((level.fontHeight * 1.5) * self.menuCursor[self.menuKey]));
		break;
	case "SELECT":
		cursor = self.menuCursor[self.menuKey];
		options = self.menuOptions[self.menuKey].options[cursor];
		if (options.inputs.size == 0)
			self [[options.func]] ();
		else if (options.inputs.size == 1)
			self [[options.func]] (options.inputs[0]);
		else if (options.inputs.size == 2)
			self [[options.func]] (options.inputs[0], options.inputs[1]);
		else if (options.inputs.size == 3)
			self [[options.func]] (options.inputs[0], options.inputs[1], options.inputs[2]);
		wait 0.1;
		break;
	case "CLOSE":
		// TODO: check can .children be used to destroy all at once
		self.menuBackground destroy();
		self.menuBorderLeft destroy();
		self.menuScroller destroy();
		self.menuTextFontElem destroy();
		self.menuHeaderFontElem destroy();
		self.menuHeaderAuthorFontElem destroy();
		self.menuOpen = false;
		self freezecontrols(false);
		break;
	case "BACK":
		// close menu if we don't have a parent
		if (!isdefined(self.menuOptions[self.menuKey].parent))
			self menuAction("CLOSE");
		else
			self menuAction("CHANGE_MENU", self.menuOptions[self.menuKey].parent);
		break;
	case "OPEN":
		self.menuOpen = true;
		self freezecontrols(true);
		self generateMenu();
		self initMenuHudElem();
		self.menuScroller.y = (level.SCREEN_MAX_HEIGHT * 0.15 + ((level.fontHeight * 1.5) * self.menuCursor[self.menuKey]));
		break;
	case "CHANGE_THEME":
		self.themeColor = level.THEMES[param1];
		self menuAction("REFRESH");
		break;
	case "CHANGE_MENU":
		self.menuKey = param1;
		self menuAction("REFRESH_TEXT");
		break;
	case "REFRESH_TEXT":
		// sanity check to prevent crashing
		if (!menuKeyExists(self.menuKey))
		{
			self iprintln("^1menu key " + self.menuKey + " does not exist");
			self.menuKey = "main_menu";
		}
		self.menuTextFontElem settext(getMenuText());
		self.menuScroller moveOverTime(level.MENU_SCROLL_TIME_SECONDS);
		self.menuScroller.y = (level.SCREEN_MAX_HEIGHT * 0.15 + ((level.fontHeight * 1.5) * self.menuCursor[self.menuKey]));
		break;
	case "REFRESH":
		self menuAction("CLOSE");
		self menuAction("OPEN");
		break;
	default:
		self iprintln("^1unknown menu action " + action);
		break;
	}
}

isMenuOpen()
{
	if (!isdefined(self.menuOpen))
		self.menuOpen = false;

	return self.menuOpen;
}

/**
 * Main loop to watch for button presses.
 */
watchbuttons()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		if (!self isMenuOpen())
		{
			if (self adsbuttonpressed() && self meleebuttonpressed())
			{
				menuAction("OPEN");
				wait 0.2;
			}
		}
		else
		{
			if (self adsbuttonpressed())
			{
				menuAction("UP");
				wait 0.2;
			}
			else if (self attackbuttonpressed())
			{
				menuAction("DOWN");
				wait 0.2;
			}
			else if (self meleebuttonpressed())
			{
				menuAction("BACK");
				wait 0.2;
			}
			else if (self usebuttonpressed())
			{
				menuAction("SELECT");
				wait 0.2;
			}
		}
		wait 0.05;
	}
}

/**
 * Set the player's loadout.
 */
initLoadout()
{
	self takeallweapons();
	self giveweapon("mp5_mp");
	self giveweapon("deserteagle_mp");
	self giveWeapon("rpg_mp");
	self setactionslot(3, "weapon", "rpg_mp");

	wait 0.05;
	self switchtoweapon("deserteagle_mp");

	// specialty_quieter
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
