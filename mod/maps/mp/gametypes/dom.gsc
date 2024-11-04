/**
 *
 * NOTE: shader width and height cannot be floats otherwise the shader will not be displayed.
 *
 * Codes for colors:
 * ^0 = Black
 * ^1 = Red
 * ^2 = Green
 * ^3 = Yellow
 * ^4 = Blue
 * ^5 = Cyan
 * ^6 = Pink
 * ^7 = White/Default
 * ^8 = Gray
 * ^9 = Gray/Map Default
 *
 */

#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\koth;
#include maps\mp\gametypes\sab;
#include maps\mp\gametypes\sd;

main()
{
	maps\mp\gametypes\war::main();
}

initCJ()
{
	// Virtual resolution for HUD elements; scaled to real monitor dimensions by the game engine
	level.SCREEN_MAX_WIDTH = 640;
	level.SCREEN_MAX_HEIGHT = 480;

	level.MENU_SCROLL_TIME_SECONDS = 0.250;

	level.DVARS = get_dvars();
	level.THEMES = get_themes();
	level.FORGE_MODELS = get_forge_models();
	level.MAPNAMES = get_maps();
	level.PLAYER_MODELS = get_player_models();

	// loop through and verify all dvars are valid
	// raise an error if any are invalid

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

		player cj_player_init_once();

		// // developer dvars
		// player setclientdvar("developer", 1);
		// player setclientdvar("developer_script", 1);
		// player setclientdvar("con_minicon", 1);
		// player setclientdvar("con_miniconlines", 20);
		// player setclientdvar("con_minicontime", 10);

		player setclientdvar("loc_warnings", 0);				  // Disable unlocalized warnings
		player setclientdvar("compassSize", 0.001);				  // Hide compass
		player setclientdvar("player_view_pitch_up", 89.9);		  // Allow looking straight up
		player setclientdvar("ui_ConnectScreenTextGlowColor", 0); // Remove glow color applied to the mode and map name strings on the connect screen
		player setclientdvar("cg_descriptiveText", 0);			  // Disable spectator button icons
		player setclientdvar("player_spectateSpeedScale", 1.5);	  // Faster movement in spectator
		player setClientDvar("aim_automelee_range", 0);			  // Remove melee lunge
		player setClientDvar("clanname", "");					  // Remove clan tag
		player setClientDvar("motd", "CodJumper");
		player setClientDvars("aim_slowdown_enabled", 0, "aim_lockon_enabled", 0);		  // Disable autoaim for enemy players
		player setClientDvars("cg_enemyNameFadeIn", 0, "cg_enemyNameFadeOut", 0);		  // Hide enemy player names
		player setClientDvars("cg_overheadRankSize", 0, "cg_overheadIconSize", 0);		  // Hide overhead rank and icon
		player setClientDvar("cg_scoreboardPingText", 1);								  // Show ping in scoreboard
		player setClientDvar("cg_chatHeight", 0);										  // prevent people from freezing consoles via say command
		player setClientDvar("nightVisionDisableEffects", 1);							  // Remove nightvision fx
		player setClientDvars("g_TeamName_Allies", "Jumpers", "g_TeamName_Axis", "Bots"); // Set team names
		player setClientDvars("fx_enable", 0);											  // Disable FX

		// Remove objective waypoints on screen
		player setClientDvar("waypointIconWidth", 0.1);
		player setClientDvar("waypointIconHeight", 0.1);
		player setClientDvar("waypointOffscreenPointerWidth", 0.1);
		player setClientDvar("waypointOffscreenPointerHeight", 0.1);

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	for (;;)
	{
		self waittill("spawned_player");
		self thread watchbuttons();
		self setupLoadoutCJ();
		self thread replenishAmmo();
	}
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
	is_host = self GetEntityNumber() == 0;

	// Bind menu
	self addMenu("bind_menu", "main_menu");
	self addMenuOption("bind_menu", "Jumpcrouch", ::emptyFunc);
	self addMenuOption("bind_menu", "Lean", ::emptyFunc);

	// Bot menu
	self addMenu("bot_menu", "main_menu");
	self addMenuOption("bot_menu", "Spawn Bot", ::spawnBotAtOrigin);
	self addMenuOption("bot_menu", "Kick Bot", ::kickBot);

	// CJ menu
	self addMenu("cj_menu", "main_menu");
	// self addMenuOption("cj_menu", "Load Previous Position", ::emptyFunc);
	self addMenuOption("cj_menu", "RPG Switch", ::toggle_rpg_switch);

	// DVAR menu
	self addMenu("dvar_menu", "main_menu");
	self addMenuOption("dvar_menu", "^1Reset All^7", ::resetAllClientDvars);
	dvars = getarraykeys(level.DVARS);
	for (i = dvars.size - 1; i >= 0; i--) // reverse order to display the dvars in the order they are defined
	{
		dvar = level.DVARS[dvars[i]];
		if (dvar.type == "slider")
			self addMenuOption("dvar_menu", dvar.name, ::dvarSlider, dvar);
		else if (dvar.type == "boolean")
			self addMenuOption("dvar_menu", dvar.name, ::booleanDvarToggle, dvar);
	}

	// Filmtweaks menu
	self addMenu("filmtweaks_menu", "main_menu");
	self addMenuOption("filmtweaks_menu", "^1Reset^7", ::setFilmTweaksPreset);
	self addMenuOption("filmtweaks_menu", "Art 1", ::setFilmTweaksPreset, "art_1");
	self addMenuOption("filmtweaks_menu", "Art 2", ::setFilmTweaksPreset, "art_2");
	self addMenuOption("filmtweaks_menu", "Art 3", ::setFilmTweaksPreset, "art_3");
	self addMenuOption("filmtweaks_menu", "Art 4", ::setFilmTweaksPreset, "art_4");
	self addMenuOption("filmtweaks_menu", "Blue Sky", ::setFilmTweaksPreset, "blue_sky");
	self addMenuOption("filmtweaks_menu", "Green Sky", ::setFilmTweaksPreset, "green_sky");
	self addMenuOption("filmtweaks_menu", "Pink Sky", ::setFilmTweaksPreset, "pink_sky");

	// Game Objects menu
	self addMenu("menu_game_objects", "main_menu");
	self addMenuOption("menu_game_objects", "Spawn Object", ::menuAction, "CHANGE_MENU", "menu_game_objects_spawn");
	self addMenu("menu_game_objects_spawn", "menu_game_objects");

	// create a submenu for each model type
	modelnames = getarraykeys(level.FORGE_MODELS);
	for (i = 0; i < modelnames.size; i++)
	{
		modelName = modelnames[i];
		// If there is only one model of this type, don't create a submenu
		if (level.FORGE_MODELS[modelName].size == 1)
		{
			modelEnt = level.FORGE_MODELS[modelName][0];
			self addMenuOption("menu_game_objects_spawn", modelName, ::set_ent_position_in_front, modelEnt);
			continue;
		}
		else
		{
			menuLabel = modelName + " " + " (" + level.FORGE_MODELS[modelName].size + ")";
			menuKey = "menu_game_objects_select_" + modelName;
			self addMenuOption("menu_game_objects_spawn", menuLabel, ::menuAction, "CHANGE_MENU", menuKey);
			self addMenu(menuKey, "menu_game_objects_spawn");
			for (j = 0; j < level.FORGE_MODELS[modelName].size; j++)
			{
				modelEnt = level.FORGE_MODELS[modelName][j];
				menuLabel = modelName + " " + (j + 1);
				self addMenuOption(menuKey, menuLabel, ::set_ent_position_in_front, modelEnt);
			}
		}
	}
	if (is_host)
	{
		self addMenuOption("menu_game_objects", "Show/Hide Domination", ::entities_show_hide_by_script_gameobjectname, "dom");
		self addMenuOption("menu_game_objects", "Show/Hide HQ", ::entities_show_hide_by_script_gameobjectname, "hq");
		self addMenuOption("menu_game_objects", "Show/Hide Sab", ::entities_show_hide_by_script_gameobjectname, "sab");
		self addMenuOption("menu_game_objects", "Show/Hide SD", ::entities_show_hide_by_script_gameobjectname, "bombzone");
		self addMenuOption("menu_game_objects", "Reset All!", ::entities_reset_to_start_position);
	}

	// HUD menu
	// maybe allow changing position of the HUD elements
	self addMenu("hud_menu", "main_menu");
	self addMenuOption("hud_menu", "Distance HUD", ::toggleHUDType, "distance");
	self addMenuOption("hud_menu", "Speed HUD", ::toggleHUDType, "speed");
	self addMenuOption("hud_menu", "Z Origin HUD", ::toggleHUDType, "z_origin");

	// Assault Rifles menu
	self addMenu("assault_rifles_menu", "loadout_menu");
	self addMenuOption("assault_rifles_menu", "AK47", ::replaceWeapon, "ak47_mp");
	self addMenuOption("assault_rifles_menu", "G3", ::replaceWeapon, "g3_mp");
	self addMenuOption("assault_rifles_menu", "G36C", ::replaceWeapon, "g36c_mp");
	self addMenuOption("assault_rifles_menu", "M14", ::replaceWeapon, "m14_mp");
	self addMenuOption("assault_rifles_menu", "M16A4", ::replaceWeapon, "m16_mp");
	self addMenuOption("assault_rifles_menu", "M4A1", ::replaceWeapon, "m4_mp");
	self addMenuOption("assault_rifles_menu", "MP44", ::replaceWeapon, "mp44_mp");

	// LMGs menu
	self addMenu("lmgs_menu", "loadout_menu");
	self addMenuOption("lmgs_menu", "M249 SAW", ::replaceWeapon, "saw_mp");
	self addMenuOption("lmgs_menu", "M60E4", ::replaceWeapon, "m60e4_mp");
	self addMenuOption("lmgs_menu", "RPD", ::replaceWeapon, "rpd_mp");

	// Pistols menu
	self addMenu("pistols_menu", "loadout_menu");
	self addMenuOption("pistols_menu", "Colt 45", ::replaceWeapon, "colt45_mp");
	self addMenuOption("pistols_menu", "Desert Eagle", ::replaceWeapon, "deserteagle_mp");
	self addMenuOption("pistols_menu", "Desert Eagle Gold", ::replaceWeapon, "deserteaglegold_mp");
	self addMenuOption("pistols_menu", "M9 Beretta", ::replaceWeapon, "beretta_mp");
	self addMenuOption("pistols_menu", "USP .45", ::replaceWeapon, "usp_mp");

	// Shotguns menu
	self addMenu("shotguns_menu", "loadout_menu");
	self addMenuOption("shotguns_menu", "M1014", ::replaceWeapon, "m1014_mp");
	self addMenuOption("shotguns_menu", "Winchester 1200", ::replaceWeapon, "winchester1200_mp");

	// SMGs menu
	self addMenu("smgs_menu", "loadout_menu");
	self addMenuOption("smgs_menu", "AK74u", ::replaceWeapon, "ak74u_mp");
	self addMenuOption("smgs_menu", "Mini-Uzi", ::replaceWeapon, "uzi_mp");
	self addMenuOption("smgs_menu", "MP5", ::replaceWeapon, "mp5_mp");
	self addMenuOption("smgs_menu", "P90", ::replaceWeapon, "p90_mp");
	self addMenuOption("smgs_menu", "Skorpion", ::replaceWeapon, "skorpion_mp");

	// Sniper Rifles menu
	self addMenu("sniper_rifles_menu", "loadout_menu");
	self addMenuOption("sniper_rifles_menu", "Barrett .50cal", ::replaceWeapon, "barrett_mp");
	self addMenuOption("sniper_rifles_menu", "Dragunov", ::replaceWeapon, "dragunov_mp");
	self addMenuOption("sniper_rifles_menu", "M21", ::replaceWeapon, "m21_mp");
	self addMenuOption("sniper_rifles_menu", "M40A3", ::replaceWeapon, "m40a3_mp");
	self addMenuOption("sniper_rifles_menu", "R700", ::replaceWeapon, "remington700_mp");

	// Camo menu
	self addMenu("camo_menu", "loadout_menu");
	self addMenuOption("camo_menu", "^1Reset^7", ::giveCamo, 0);
	self addMenuOption("camo_menu", "Desert", ::giveCamo, 1);
	self addMenuOption("camo_menu", "Woodland", ::giveCamo, 2);
	self addMenuOption("camo_menu", "Digital", ::giveCamo, 3);
	self addMenuOption("camo_menu", "Blue Tiger", ::giveCamo, 5);
	self addMenuOption("camo_menu", "Red Tiger", ::giveCamo, 4);
	self addMenuOption("camo_menu", "Gold", ::giveCamo, 6);

	// Loadout menu
	self addMenu("loadout_menu", "main_menu");
	self addMenuOption("loadout_menu", "Assault Rifles", ::menuAction, "CHANGE_MENU", "assault_rifles_menu");
	self addMenuOption("loadout_menu", "LMGs", ::menuAction, "CHANGE_MENU", "lmgs_menu");
	self addMenuOption("loadout_menu", "Pistols", ::menuAction, "CHANGE_MENU", "pistols_menu");
	self addMenuOption("loadout_menu", "Shotguns", ::menuAction, "CHANGE_MENU", "shotguns_menu");
	self addMenuOption("loadout_menu", "SMGs", ::menuAction, "CHANGE_MENU", "smgs_menu");
	self addMenuOption("loadout_menu", "Sniper Rifles", ::menuAction, "CHANGE_MENU", "sniper_rifles_menu");
	self addMenuOption("loadout_menu", "Camo Menu", ::menuAction, "CHANGE_MENU", "camo_menu");
	self addMenuOption("loadout_menu", "Sleight of Hand", ::toggleFastReload);

	// Map menu
	self addMenu("map_menu", "main_menu");
	maps = getarraykeys(level.MAPNAMES);
	for (i = maps.size - 1; i >= 0; i--) // reverse order to display the maps in the order they are defined
		self addMenuOption("map_menu", level.MAPNAMES[maps[i]], ::changeMap, maps[i]);

	// Player model menu
	self addMenu("player_model_menu", "main_menu");
	keys = getarraykeys(level.PLAYER_MODELS);
	for (i = keys.size - 1; i >= 0; i--) // reverse order to display the maps in the order they are defined
	{
		model = keys[i];
		model_friendly_name = level.PLAYER_MODELS[model];
		self addMenuOption("player_model_menu", model_friendly_name, ::change_player_model, model);
	}

	// Theme menu
	self addMenu("theme_menu", "main_menu");
	themes = getarraykeys(level.THEMES);
	for (i = themes.size - 1; i >= 0; i--) // reverse order to display the dvars in the order they are defined
		self addMenuOption("theme_menu", themes[i], ::menuAction, "CHANGE_THEME", themes[i]);

	// Main menu
	self addMenu("main_menu");
	self addMenuOption("main_menu", "Bind Menu", ::menuAction, "CHANGE_MENU", "bind_menu");
	self addMenuOption("main_menu", "Bot Menu", ::menuAction, "CHANGE_MENU", "bot_menu");
	self addMenuOption("main_menu", "CJ Menu", ::menuAction, "CHANGE_MENU", "cj_menu");
	self addMenuOption("main_menu", "DVAR Menu", ::menuAction, "CHANGE_MENU", "dvar_menu");
	// self addMenuOption("main_menu", "Filmtweaks Menu", ::menuAction, "CHANGE_MENU", "filmtweaks_menu");	// hide for now until it's can easily reset all to default
	self addMenuOption("main_menu", "Game Objects Menu", ::menuAction, "CHANGE_MENU", "menu_game_objects");
	self addMenuOption("main_menu", "HUD Menu", ::menuAction, "CHANGE_MENU", "hud_menu");
	self addMenuOption("main_menu", "Loadout Menu", ::menuAction, "CHANGE_MENU", "loadout_menu");
	self addMenuOption("main_menu", "Map Menu", ::menuAction, "CHANGE_MENU", "map_menu");
	self addMenuOption("main_menu", "Player Model Menu", ::menuAction, "CHANGE_MENU", "player_model_menu");
	self addMenuOption("main_menu", "Theme Menu", ::menuAction, "CHANGE_MENU", "theme_menu");
}

emptyFunc()
{
	self iprintln("^1Not implemented yet");
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
	menuWidth = int(level.SCREEN_MAX_WIDTH * 0.25); // force int because shaders dimensions won't work with floats
	menuTextPaddingLeft = 5;
	menuScrollerAlpha = 0.7;

	menuBackground = newClientHudElem(self);
	menuBackground.elemType = "icon";
	menuBackground.color = (0, 0, 0);
	menuBackground.alpha = 0.5;
	menuBackground setShader("white", menuWidth, level.SCREEN_MAX_HEIGHT);
	menuBackground.x = level.SCREEN_MAX_WIDTH - menuWidth;
	menuBackground.y = 0;
	menuBackground.alignX = "left";
	menuBackground.alignY = "top";
	menuBackground.horzAlign = "fullscreen";
	menuBackground.vertAlign = "fullscreen";
	self.menuBackground = menuBackground;

	leftBorderWidth = 2;

	menuBorderLeft = newClientHudElem(self);
	menuBorderLeft.elemType = "icon";
	menuBorderLeft.color = self.themeColor;
	menuBorderLeft.alpha = level.menuScrollerAlpha;
	menuBorderLeft setShader("white", leftBorderWidth, level.SCREEN_MAX_HEIGHT);
	menuBorderLeft.x = (level.SCREEN_MAX_WIDTH - menuWidth);
	menuBorderLeft.y = 0;
	menuBorderLeft.alignX = "left";
	menuBorderLeft.alignY = "top";
	menuBorderLeft.horzAlign = "fullscreen";
	menuBorderLeft.vertAlign = "fullscreen";
	self.menuBorderLeft = menuBorderLeft;

	menuScroller = newClientHudElem(self);
	menuScroller.elemType = "icon";
	menuScroller.color = self.themeColor;
	menuScroller.alpha = level.menuScrollerAlpha;
	menuScroller setShader("white", menuWidth, int(level.fontHeight * 1.5));
	menuScroller.x = level.SCREEN_MAX_WIDTH - menuWidth;
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
	menuTextFontElem settext(getMenuText());
	menuTextFontElem.x = (level.SCREEN_MAX_WIDTH - menuWidth) + menuTextPaddingLeft;
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
	menuHeaderFontElem.x = (level.SCREEN_MAX_WIDTH - menuWidth) + menuTextPaddingLeft;
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
	menuHeaderAuthorFontElem.x = (level.SCREEN_MAX_WIDTH - menuWidth) + menuTextPaddingLeft;
	menuHeaderAuthorFontElem.y = int(level.SCREEN_MAX_HEIGHT * 0.075);
	menuHeaderAuthorFontElem.alignX = "left";
	menuHeaderAuthorFontElem.alignY = "top";
	menuHeaderAuthorFontElem.horzAlign = "fullscreen";
	menuHeaderAuthorFontElem.vertAlign = "fullscreen";
	menuHeaderAuthorFontElem settext("by mo");
	self.menuHeaderAuthorFontElem = menuHeaderAuthorFontElem;

	menuVersionFontElem = newClientHudElem(self);
	menuVersionFontElem.elemType = "font";
	menuVersionFontElem.font = "default";
	menuVersionFontElem.fontscale = 1.4;
	menuVersionFontElem.alpha = 0.5;
	menuVersionFontElem.x = (level.SCREEN_MAX_WIDTH - menuWidth) + menuTextPaddingLeft;
	menuVersionFontElem.y = int(level.SCREEN_MAX_HEIGHT - (level.fontHeight * menuVersionFontElem.fontscale) - menuTextPaddingLeft);
	menuVersionFontElem.alignX = "left";
	menuVersionFontElem.alignY = "top";
	menuVersionFontElem.horzAlign = "fullscreen";
	menuVersionFontElem.vertAlign = "fullscreen";
	menuVersionFontElem settext("v1.0.0");
	self.menuVersionFontElem = menuVersionFontElem;
}

/**
 * Handle menu actions.
 * @param action The action to perform.
 * @param param1 The action parameter. (optional)
 */
menuAction(action, param1)
{
	if (!isdefined(self.themeColor))
		self.themeColor = level.THEMES["skyblue"];

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
		self.menuVersionFontElem destroy();
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
	self endon("end_respawn");

	self thread watchNightVisionButton();

	for (;;)
	{
		// Menu is closed
		if (!self isMenuOpen())
		{
			if (self button_pressed_twice("use"))
			{
				menuAction("OPEN");
				wait 0.2;
			}
			else if (self button_pressed("nightvision"))
			{
				self thread spawnBotAtOrigin();
				wait 0.2;
			}
			else if (self button_pressed_twice("melee"))
			{
				self position_save();
				wait 0.2;
			}
			else if (self button_pressed("smoke"))
			{
				self position_load();
				wait 0.2;
			}
			else if (self button_pressed("frag"))
			{
				self ufo_controls_toggle();
				wait 0.2;
			}
		}
		// Menu is open
		else
		{
			if (self button_pressed("ads"))
			{
				menuAction("UP");
				wait 0.2;
			}
			else if (self button_pressed("attack"))
			{
				menuAction("DOWN");
				wait 0.2;
			}
			else if (self button_pressed("melee"))
			{
				menuAction("BACK");
				wait 0.2;
			}
			else if (self button_pressed("use"))
			{
				menuAction("SELECT");
				wait 0.2;
			}
		}
		wait 0.05;
	}
}

button_pressed(button)
{
	switch (ToLower(button))
	{
	case "ads":
		return self adsbuttonpressed();
	case "attack":
		return self attackbuttonpressed();
	case "frag":
		return self fragbuttonpressed();
	// case "HOLD_BREATH":
	// 	return self holdbreathbuttonpressed();
	// 	break;
	// case "JUMP":
	// 	return self jumpbuttonpressed();
	// 	break;
	case "melee":
		return self meleebuttonpressed();
	case "nightvision":
		return self nightvisionbuttonpressed();
	case "smoke":
		return self secondaryoffhandbuttonpressed();
	case "use":
		return self usebuttonpressed();
	default:
		self iprintln("^1Unknown button " + button);
		return false;
	}
}

/**
 * Check if the a button is pressed twice in 500ms.
 */
button_pressed_twice(button)
{
	if (self button_pressed(button))
	{
		has_released = false;

		for (elapsed_time = 0; elapsed_time < 0.5; elapsed_time += 0.05)
		{
			if (has_released && self button_pressed(button))
				return true;
			else if (!self button_pressed(button))
				has_released = true;

			wait 0.05;
		}
	}
	return false;
}

toggleFastReload()
{
	self.cj["loadout"].fastReload = !self.cj["loadout"].fastReload;
	if (self.cj["loadout"].fastReload)
		self iprintln("Fast reload [^2ON^7]");
	else
		self iprintln("Fast reload [^1OFF^7]");

	self setupLoadoutCJ(false);
}

giveCamo(index)
{
	self.cj["loadout"].primaryCamoIndex = index;
	self.cj["loadout"].incomingWeapon = self.cj["loadout"].primary;
	self setupLoadoutCJ(false);
}

replaceWeapon(weapon)
{
	if (weaponClass(weapon) != "pistol")
	{
		self.cj["loadout"].primary = weapon;
		self.cj["loadout"].primaryCamoIndex = 0;
	}
	else
		self.cj["loadout"].sidearm = weapon;

	self.cj["loadout"].incomingWeapon = weapon;
	self setupLoadoutCJ();
}

cj_player_init_once()
{
	self.cj = [];

	self.cj["rpg_switch"] = false;
	self.cj["rpg_switched"] = false;

	// Default loadout
	self.cj["loadout"] = spawnstruct();
	self.cj["loadout"].primary = "mp5_mp";
	self.cj["loadout"].primaryCamoIndex = 0;
	self.cj["loadout"].sidearm = "deserteaglegold_mp";
	self.cj["loadout"].fastReload = false;
	self.cj["loadout"].incomingWeapon = undefined;

	self.cj["save_history"] = [];
}

/**
 * Sets up the loadout for the player.
 */
setupLoadoutCJ(printInfo)
{

	if (!isdefined(printInfo))
		printInfo = true;

	self clearPerks();
	self takeAllWeapons();

	// wait 0.05;

	self giveWeapon(self.cj["loadout"].primary, self.cj["loadout"].primaryCamoIndex);
	self giveWeapon(self.cj["loadout"].sidearm);

	self giveWeapon("rpg_mp");

	if (self.cj["loadout"].fastReload)
		self setPerk("specialty_fastreload");

	self SetActionSlot(1, "nightvision");
	self SetActionSlot(3, "weapon", "rpg_mp");

	wait 0.05;

	// Switch to the appropriate weapon
	if (isdefined(self.cj["loadout"].incomingWeapon) && weaponClass(self.cj["loadout"].incomingWeapon) != "pistol")
		self switchtoweapon(self.cj["loadout"].primary);
	else
		self switchtoweapon(self.cj["loadout"].sidearm);

	self.cj["loadout"].incomingWeapon = undefined;

	// Adjust move speed based on primary weapon type
	moveSpeedScalePercentage = 100;
	// Taken from maps\mp\gametypes\_class::giveLoadout
	switch (weaponClass(self.cj["loadout"].primary))
	{
	case "rifle":
		self setMoveSpeedScale(0.95);
		moveSpeedScalePercentage = 95;
		break;
	case "pistol":
		self setMoveSpeedScale(1.0);
		break;
	case "mg":
		self setMoveSpeedScale(0.875);
		moveSpeedScalePercentage = 87.5;
		break;
	case "smg":
		self setMoveSpeedScale(1.0);
		break;
	case "spread":
		self setMoveSpeedScale(1.0);
		break;
	default:
		self setMoveSpeedScale(1.0);
		break;
	}

	if (printInfo)
		self iprintln("Move speed scale: " + moveSpeedScalePercentage + " percent");
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

clientdvar_get(dvar)
{
	if (!isdefined(self.clientdvars))
		self.clientdvars = [];

	if (!isdefined(self.clientdvars[dvar.name]))
		return dvar.default_value;

	return self.clientdvars[dvar.name];
}

clientdvar_set(dvar, value)
{
	if (!isdefined(self.clientdvars))
		self.clientdvars = [];

	self.clientdvars[dvar.name] = value;

	self setclientdvar(dvar.name, value);

	msg = dvar.name + " set to " + value;
	if (value == dvar.default_value)
		msg += " [DEFAULT]";

	self iprintln(msg);
}

isDvarStructValid(dvar)
{
	// all must have a name, type
	if (!isdefined(dvar) || !isdefined(dvar.type) || !isdefined(dvar.name))
		return false;

	// type specific checks
	if (dvar.type == "slider")
	{
		if (!isdefined(dvar.default_value) || !isdefined(dvar.min) || !isdefined(dvar.max) || !isdefined(dvar.step))
			return false;
	}
	else if (dvar.type == "boolean")
	{
		if (!isdefined(dvar.default_value))
			return false;
	}
	return true;
}

// Function to calculate and update the cursor position based on dvar value
updateCursorPosition(dvar, dvarValue, sliderCursor, centerXPosition, railWidth, cursorWidth)
{
	// Calculate normalized position (0 to 1) on the rail
	normalizedPosition = (dvarValue - dvar.min) / (dvar.max - dvar.min);
	// Calculate actual x position on the rail
	sliderCursor.x = centerXPosition + int(normalizedPosition * (railWidth - cursorWidth));
}

// TODO: more options
// - reset to default
// - add a label to the slider?
// - ignore main menu button presses when the slider controls are open
dvarSlider(dvar)
{
	self endon("disconnect");
	self endon("end_respawn");

	self menuAction("CLOSE");

	if (!isDvarStructValid(dvar))
	{
		self iprintln("^1dvar is missing required fields");
		return;
	}
	if (dvar.type != "slider")
	{
		self iprintln("^1dvar type is not a slider");
		return;
	}

	// call this on a fresh game to get the default value
	// self iprintln("DEFAULT GAME VALUE " + dvar.name + " " + getdvar(dvar.name));

	// -- Background
	backgroundWidth = level.SCREEN_MAX_WIDTH;
	backgroundHeight = 50;
	centerYPosition = (level.SCREEN_MAX_HEIGHT - backgroundHeight) / 2;

	sliderBackground = newClientHudElem(self);
	sliderBackground.elemType = "icon";
	sliderBackground.color = (0, 0, 0);
	sliderBackground.alpha = 0.5;
	sliderBackground setShader("white", backgroundWidth, backgroundHeight);
	sliderBackground.x = 0;
	sliderBackground.y = centerYPosition;
	sliderBackground.alignX = "left";
	sliderBackground.alignY = "top";
	sliderBackground.horzAlign = "fullscreen";
	sliderBackground.vertAlign = "fullscreen";

	// -- Rail
	railWidth = int(level.SCREEN_MAX_WIDTH * 0.75);
	railHeight = 4;
	centerXPosition = (level.SCREEN_MAX_WIDTH - railWidth) / 2;
	centerYPosition = (level.SCREEN_MAX_HEIGHT - railHeight) / 2;

	sliderRail = newClientHudElem(self);
	sliderRail.elemType = "icon";
	sliderRail.alpha = 0.75;
	sliderRail setShader("white", railWidth, railHeight);
	sliderRail.x = centerXPosition;
	sliderRail.y = centerYPosition;
	sliderRail.alignX = "left";
	sliderRail.alignY = "top";
	sliderRail.horzAlign = "fullscreen";
	sliderRail.vertAlign = "fullscreen";

	// -- Cursor
	cursorWidth = 3;
	cursorHeight = int(backgroundHeight / 2);
	// Start position aligned with the beginning of the rail
	cursorStartXPosition = centerXPosition; // This aligns it to the start of the rail
	// Centered vertically with respect to the rail
	cursorYPosition = centerYPosition - (cursorHeight - railHeight) / 2;

	sliderCursor = newClientHudElem(self);
	sliderCursor.elemType = "icon";
	sliderCursor.color = self.themeColor; // Use the theme color
	sliderCursor.alpha = 0;				  // Hide the cursor initially
	sliderCursor setShader("white", cursorWidth, cursorHeight);
	sliderCursor.x = cursorStartXPosition;
	sliderCursor.y = cursorYPosition;
	sliderCursor.alignX = "left";
	sliderCursor.alignY = "top";
	sliderCursor.horzAlign = "fullscreen";
	sliderCursor.vertAlign = "fullscreen";

	dvarValue = self clientdvar_get(dvar);

	// Initialize cursor position based on the default dvar value
	updateCursorPosition(dvar, dvarValue, sliderCursor, centerXPosition, railWidth, cursorWidth);

	sliderCursor.alpha = 1; // Show the cursor after it has been positioned

	sliderValue = createFontString("default", 3);
	sliderValue setPoint("CENTER", "CENTER", 0, -50);
	sliderValue SetValue(dvarValue);

	for (;;)
	{
		if (self fragbuttonpressed() || self secondaryoffhandbuttonpressed())
		{
			if (self fragbuttonpressed())
			{
				dvarValue += dvar.step;
				if (dvarValue > dvar.max)
				{
					dvarValue = dvar.min; // Wrap around to min
				}
			}
			else if (self secondaryoffhandbuttonpressed())
			{
				dvarValue -= dvar.step;
				if (dvarValue < dvar.min)
				{
					dvarValue = dvar.max; // Wrap around to max
				}
			}

			updateCursorPosition(dvar, dvarValue, sliderCursor, centerXPosition, railWidth, cursorWidth);
			sliderValue SetValue(dvarValue);
			self clientdvar_set(dvar, dvarValue);

			wait 0.05; // Prevent rapid firing
		}
		else if (self meleebuttonpressed())
		{
			self clientdvar_set(dvar, dvarValue);

			sliderBackground destroy();
			sliderRail destroy();
			sliderCursor destroy();
			sliderValue destroy();

			self menuAction("OPEN");
			return;
		}

		wait 0.05;
	}
}

booleanDvarToggle(dvar)
{
	if (!isDvarStructValid(dvar))
	{
		self iprintln("^1dvar is missing required fields");
		return;
	}
	if (dvar.type != "boolean")
	{
		self iprintln("^1dvar type is not a boolean");
		return;
	}

	dvarValue = self clientdvar_get(dvar);

	if (dvarValue == 0)
		self clientdvar_set(dvar, 1);
	else
		self clientdvar_set(dvar, 0);
}

resetAllClientDvars()
{
	dvars = getarraykeys(level.DVARS);
	for (i = 0; i < dvars.size; i++)
	{
		dvar = level.DVARS[dvars[i]];
		self clientdvar_set(dvar, dvar.default_value);
	}
}

changeMap(mapname)
{
	// TODO: kick all testclients
	Map(mapname);
	kickAllBots();
}
