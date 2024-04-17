#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level thread onPlayerConnect();

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
	for(;;)
	{
		self waittill("spawned_player");
		self thread initMenu();
	}
}

initMenuOpts()
{
	m = "main";
	self addMenu(m, "CodJumper - by mo", undefined);

	// Host submenu
	if(self GetEntityNumber() == 0)
	{
		self addOpt(m, "Host menu", ::subMenu, "");
	}

	self addOpt(m, "Toggle cg_thirdPerson", ::toggleBooleanClientDvar, "cg_thirdPerson");
	self addOpt(m, "Toggle cg_drawgun", ::toggleBooleanClientDvar, "cg_drawgun");
	self addOpt(m, "Add bot blocker", ::addBlockerBot);
	self addOpt(m, "Sub Menu", ::subMenu, "");

	m = "";
	self addMenu(m, "Sub Menu", "main");
	self addOpt(m, "TEST", ::test);
	self addOpt(m, "TEST", ::test);

	// Host submenu options
	if(self GetEntityNumber() == 0)
	{
		m = "";
		self addMenu(m, "Host menu", "main");
		self addOpt(m, "Toggle jump_slowdownEnable", ::toggleBooleanClientDvar, "jump_slowdownEnable");
		self addOpt(m, "Toggle oldschool", ::toggleOldschool);
	}
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

	for(;;)
	{
		if(self secondaryOffHandButtonPressed())
		{
			// MENU INIT / OPEN
			if(!isDefined(self.inMenu))
			{
				self freezecontrols(true);
				self.inMenu = true;

				self initMenuOpts();
				menuOpts = self.menuAction[self.currentMenu].opt.size;

				self.openBox = self createRectangle("TOP", "TOPRIGHT", -160, 10, 300, 445, (0, 0, 0), "white", 1, .7);
				self.openText = self createText("default", 1.5, "TOP", "TOPRIGHT", -160, 16, 2, 1, ( 0, 0, 1), self.menuAction[self.currentMenu].title);
				string = "";
				for(m = 0; m < menuOpts; m++)
					string+= self.menuAction[self.currentMenu].opt[m]+"\n";
				self.menuText = self createText("default", 1.5, "LEFT", "TOPRIGHT", -300, 60, 3, 1, undefined, string);
				self.scrollBar = self createRectangle("TOP", "TOPRIGHT", -160, ((self.menuCurs*17.98)+((self.menuText.y+1)-(17.98/2))), 300, 15, (0, 0, 1), "white", 2, .7);
			}
		}
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

					self.openBox destroy();
					self.menuText destroy();
					self.scrollBar destroy();
					self.openText destroy("");
				}
				else
					self subMenu(self.menuAction[self.currentMenu].parent);
			}
		}
		wait .05;
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


// TODO: Fix for clients
toggleBooleanClientDvar(dvar)
{
	value = getDvarInt(dvar);
	self setClientDvar(dvar, !value);
	self iPrintLn(dvar + " " + value);
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

toggleOldschool(){
	if(level.oldschool == true)
	{
		iPrintln("Oldschool mode [^1OFF^7]");
		level.oldschool = false;
		setDvar( "jump_height", 39 );
		setDvar( "jump_slowdownEnable", 1 );
	}
	else
	{
		iPrintln("Oldschool mode [^2ON^7]");
		level.oldschool = true;
		setDvar( "jump_height", 64 );
		setDvar( "jump_slowdownEnable", 0 );
	}
}
