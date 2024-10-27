#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

/**
 * Flattens the origin by converting it to an integer.
 */
flat_origin(origin)
{
	x = origin[0];
	y = origin[1];
	z = origin[2];
	return (int(x), int(y), int(z));
}

initSpeedometerHudElem()
{
	hudElem = newClientHudElem(self);
	hudElem.horzAlign = "right";
	hudElem.vertAlign = "bottom";
	hudElem.alignX = "right";
	hudElem.alignY = "bottom";
	hudElem.x = 60;
	hudElem.y = 35;
	hudElem.foreground = true;
	hudElem.font = "objective";
	hudElem.hideWhenInMenu = true;
	hudElem.color = (1.0, 1.0, 1.0);
	hudElem.glowColor = ((125/255), (33/255), (20/255));
	hudElem.glowAlpha = 0.0;
	hudElem.fontScale = 1.4;
	hudElem.archived = false;
	hudElem.alpha = 0;
	return hudElem;
}

initHeightMeterHudElem()
{
	hudElem = newClientHudElem(self);
	hudElem.horzAlign = "right";
	hudElem.vertAlign = "bottom";
	hudElem.alignX = "right";
	hudElem.alignY = "bottom";
	hudElem.x = 60;
	hudElem.y = 22;
	hudElem.foreground = true;
	hudElem.font = "objective";
	hudElem.hideWhenInMenu = true;
	hudElem.color = (1.0, 1.0, 1.0);
	hudElem.glowColor = ((125/255), (33/255), (20/255));
	hudElem.glowAlpha = 0.0;
	hudElem.fontScale = 1.4;
	hudElem.archived = false;
	hudElem.alpha = 0;
	return hudElem;
}

updateSpeedometerHudElem()
{
	self endon("end_respawn");
	self endon("disconnect");
	level endon("game_ended");

	if(!isdefined(self.speedometerHudElem))
	{
		self.speedometerHudElem = initSpeedometerHudElem();
		self.heightMeterHudElem = initHeightMeterHudElem();
	}

	for (;;)
	{
		origin = self.origin;
		xyzspeed = self getVelocity();
		normalisedSpeed = int(sqrt(xyzspeed[0] * xyzspeed[0] + xyzspeed[1] * xyzspeed[1]));
		self.speedometerHudElem setValue(normalisedSpeed);
		self.heightMeterHudElem setValue(origin[2]);
		wait .05;
	}
}

toggleSpeedometerHudElem()
{
	setting = "speedometer_enabled";
	printName = "Speedometer";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self.speedometerHudElem.alpha = .5;
		self.heightMeterHudElem.alpha = .5;
		self iPrintln(printName + " [^2ON^7]");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self.speedometerHudElem.alpha = 0;
		self.heightMeterHudElem.alpha = 0;
		self iPrintln(printName + " [^1OFF^7]");
	}
}

toggleFOV()
{
	setting = "cg_fov";
	printName = "FOV";

	currentValue = self.cj["settings"][setting];
	if(!isdefined(currentValue))
		currentValue = 65;

	switch( currentValue )
	{
		case 65:
			newValue = 70;
			break;
		case 70:
			newValue = 75;
			break;
		case 75:
			newValue = 80;
			break;
		default:
			newValue = 65;
			break;
	}
	self.cj["settings"][setting] = newValue;
	self setClientDvar(setting, newValue);
	self iPrintln(printName + " " + newValue);
}

toggleJumpCrouch()
{
	setting = "jumpcrouch_enabled";
	printName = "Jump Crouch";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self setClientDvar("BUTTON_A_ACTION", "+gostand;-gostand;wait 4;togglecrouch");
		self iPrintln(printName + " [^2ON^7]");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self setClientDvar("BUTTON_A_ACTION", "+gostand;-gostand");
		self iPrintln(printName + " [^1OFF^7]");
	}
}

toggleRPGSwitch()
{
	setting = "rpg_switch_enabled";
	printName = "RPG Switch";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self thread rpgSwitch();
		self iPrintln(printName + " [^2ON^7]");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self notify("stop_rpg_switch");
		self iPrintln(printName + " [^1OFF^7]");
	}
}

rpgSwitch()
{
	self endon("disconnect");
	self endon("end_respawn");

	self notify("stop_rpg_switch");
	self endon("stop_rpg_switch");

	while(self.cj["settings"]["rpg_switch_enabled"])
	{
		self waittill("weapon_fired");
		weapon = self getCurrentWeapon();
		if (weapon == "rpg_mp")
		{
			self.cj["settings"]["rpg_switched"] = true;

			if(getDvarInt("jump_height") == 64)
				self switchToWeapon("beretta_mp");
			else
				self switchToWeapon(self.cj["settings"]["deserteagle_choice"]);

			wait 0.4;
			self SetWeaponAmmoClip(weapon, 1);
		}
	}
}

toggle_r_zfar()
{
	setting = "r_zfar";
	printName = "r_zfar";

	currentValue = self.cj["settings"][setting];
	if(!isdefined(currentValue))
		currentValue = 0;

	switch( currentValue )
	{
		case 0:
			newValue = 2000;
			break;
		case 2000:
			newValue = 2500;
			break;
		case 2500:
			newValue = 3000;
			break;
		case 3000:
			newValue = 3500;
			break;
		default:
			newValue = 0;
			break;
	}
	self.cj["settings"][setting] = newValue;
	self setClientDvar(setting, newValue);
	self iPrintln(printName + " " + newValue);
}

toggle_r_fog()
{
	setting = "r_fog";
	printName = "Fog";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == true)
	{
		self.cj["settings"][setting] = false;
		self setClientDvar(setting, 0);
		self iPrintln(printName + " [^1OFF^7]");
	}
	else
	{
		self.cj["settings"][setting] = true;
		self setClientDvar(setting, 1);
		self iPrintln(printName + " [^2ON^7]");
	}
}

toggle_r_dof_enable()
{
	setting = "r_dof_enable";
	printName = "Depth of field";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == true)
	{
		self.cj["settings"][setting] = false;
		self setClientDvar(setting, 0);
		self iPrintln(printName + " [^1OFF^7]");
	}
	else
	{
		self.cj["settings"][setting] = true;
		self setClientDvar(setting, 1);
		self iPrintln(printName + " [^2ON^7]");
	}
}

toggle_look_straight_down()
{
	setting = "player_view_pitch_down";
	printName = "Look straight down";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self setClientDvar(setting, 89.9);
		self iPrintln(printName + " [^2ON^7]");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self setClientDvar(setting, 70);
		self iPrintln(printName + " [^1OFF^7]");
	}
}

resetAllGameObjects()
{
	modelnames = getarraykeys(level.FORGE_MODELS);
	for (i = 0; i < modelnames.size; i++)
	{
		modelName = modelnames[i];
		for (j = 0; j < level.FORGE_MODELS[modelName].size; j++)
		{
			modelEnt = level.FORGE_MODELS[modelName][j];
			modelEnt.origin = modelEnt.startOrigin;
			modelEnt.angles = modelEnt.startAngles;
		}
	}
	iprintln("All game objects reset");
}

show_hide_by_script_gameobjectname(script_gameobjectname)
{
	hidden = false;
	ents = getentarray();
	for (i = 0; i < ents.size; i++)
	{
		if (isdefined(ents[i].script_gameobjectname) && ents[i].script_gameobjectname == script_gameobjectname)
		{
			if(isdefined(ents[i].hidden) && ents[i].hidden)
			{
				ents[i] show();
				ents[i] solid();
				ents[i].hidden = false;
			}
			else
			{
				ents[i] hide();
				ents[i] notsolid();
				ents[i].hidden = true;
				hidden = true;
			}
		}
	}

	action = "shown";
	if(hidden)
		action = "hidden";

	type = script_gameobjectname;
	if(type == "bombzone")
		type = "sd";

	iprintln(type + " " + action);
}

spawnGameObject(ent)
{
	playerAngles = self getPlayerAngles();
	ent.origin = flat_origin(self.origin + (anglestoforward(playerAngles) * 150));
	ent.angles = (0, playerAngles[1], 0);
	self iprintln("Object spawned at " + ent.origin + ent.angles);
}

enableLeanBinds()
{
	self setClientDvar("activeaction", "vstr VSTR_LEAN_ENABLED");
	self iPrintln("Lean Binds [^2ON^7] (Requires map restart)");
	self iPrintln("[{+actionslot 3}]/[{+actionslot 4}] for lean and [{+actionslot 2}] for RPG");
}

disableLeanBinds()
{
	self setClientDvar("activeaction", "vstr VSTR_LEAN_DISABLED");
	self iPrintln("Lean Binds [^1OFF^7] (Requires map restart)");
}

kickAllBots()
{
	for ( i = 0; i < level.players.size; i++ )
		if ( isdefined(level.players[i].pers["isBot"]) )
			kick(level.players[i] getEntityNumber());
}

getPlayerFromName(playerName)
{
	for (i = 0; i < level.players.size; i++)
		if (level.players[i].name == playerName)
			return level.players[i];
}

createforgehud()
{
	instructions = [];
	instructions[instructions.size] = "[{+smoke}] [{+frag}] Decrease/Increase";
	instructions[instructions.size] = "While holding [{+activate}]:";
	instructions[instructions.size] = "[{+smoke}] Next mode";
	instructions[instructions.size] = "[{+frag}] Prev mode";

	instructions[instructions.size] = "[{+attack}] Pick up/Drop";
	if(level.xenon)
		instructions[instructions.size] = "[{+breath_sprint}] Clone object";

	instructions[instructions.size] = "";
	instructions[instructions.size] = "[{+speed_throw}] Exit Forge";
	instructions[instructions.size] = "[{+melee}] Switch to UFO mode";

	instructionsString = "";
	for (i = 0; i < instructions.size; i++)
		instructionsString += instructions[i] + "\n";

	self.forge_hud = [];
	self.forge_hud["instructions"] = createFontString("default", 1.4);
	self.forge_hud["instructions"] setPoint("TOPLEFT", "TOPLEFT", -30, -20);
	self.forge_hud["instructions"] setText(instructionsString);

	x = 30;

	// self.forge_hud["slots"] = createFontString("default", 1.4);
	// self.forge_hud["slots"] setPoint("TOPRIGHT", "TOPRIGHT", x, -20);
	// self.forge_hud["slots"].label = &"slots: &&1";
	// self.forge_hud["slots"] SetValue(0);

	self.forge_hud["mode"] = createFontString("default", 1.4);
	self.forge_hud["mode"] setPoint("TOPRIGHT", "TOPRIGHT", x, -20);
	self.forge_hud["mode"] setText("mode: " + self.forge_change_mode);

	self.forge_hud["pitch"] = createFontString("default", 1.4);
	self.forge_hud["pitch"] setPoint("TOPRIGHT", "TOPRIGHT", x, 0);
	self.forge_hud["pitch"].label = &"pitch: &&1";
	self.forge_hud["pitch"] SetValue(0);

	self.forge_hud["yaw"] = createFontString("default", 1.4);
	self.forge_hud["yaw"] setPoint("TOPRIGHT", "TOPRIGHT", x, 20);
	self.forge_hud["yaw"].label = &"yaw: &&1";
	self.forge_hud["yaw"] SetValue(0);

	self.forge_hud["roll"] = createFontString("default", 1.4);
	self.forge_hud["roll"] setPoint("TOPRIGHT", "TOPRIGHT", x, 40);
	self.forge_hud["roll"].label = &"roll: &&1";
	self.forge_hud["roll"] SetValue(0);

	self.forge_hud["x"] = createFontString("default", 1.4);
	self.forge_hud["x"] setPoint("TOPRIGHT", "TOPRIGHT", x, 60);
	self.forge_hud["x"].label = &"x: &&1";
	self.forge_hud["x"] SetValue(0);

	self.forge_hud["y"] = createFontString("default", 1.4);
	self.forge_hud["y"] setPoint("TOPRIGHT", "TOPRIGHT", x, 80);
	self.forge_hud["y"].label = &"y: &&1";
	self.forge_hud["y"] SetValue(0);

	self.forge_hud["z"] = createFontString("default", 1.4);
	self.forge_hud["z"] setPoint("TOPRIGHT", "TOPRIGHT", x, 100);
	self.forge_hud["z"].label = &"z: &&1";
	self.forge_hud["z"] SetValue(0);

	self.forge_hud["reticle"] = createIcon("reticle_flechette", 40, 40);
	self.forge_hud["reticle"] setPoint("center", "center", "center", "center");

	self waittill_any("end_respawn", "disconnect", "forge_end");
	self destroyforgehud();
}

destroyforgehud()
{
	huds = getarraykeys(self.forge_hud);
	for (i = 0; i < huds.size; i++)
		if (isdefined(self.forge_hud[huds[i]]))
			self.forge_hud[huds[i]] destroy();
}

forgestart()
{
	self endon("disconnect");
	self endon("end_respawn");
	self endon("forge_end");

	self ufocontrolsON();

	if (!isdefined(self.spectator_mode))
		self.spectator_mode = "ufo";

	if (!isdefined(self.forge_change_mode))
		self.forge_change_mode = "pitch";

	if (self.spectator_mode == "forge")
		self thread createforgehud();

	if (self.spectator_mode == "ufo")
		self iprintln("UFO mode ON");
	else
		self iprintln("Forge mode ON");

	focusedColor = (0, 0.5, 0.5);
	unfocusedColor = (1, 1, 1);
	pickedUpColor = (1, 0, 0);

	focusedEnt = undefined;
	pickedUpEnt = undefined;

	unit = 1;

	for (;;)
	{
		// prevent monitoring when in menu
		if (isDefined(self.inMenu) && self.inMenu)
		{
			wait 0.1;
			continue;
		}

		// don't unfreeze controls if in menu otherwise the menu controls will break
		if (!isDefined(self.inMenu))
			self freezecontrols(false);

		// HOLD X actions
		while (self usebuttonpressed())
		{
			// freeze controls to allow meleebuttonpressed while in spectator
			self freezecontrols(true);
			if (self meleebuttonpressed())
			{
				if (self.spectator_mode == "ufo")
				{
					self.spectator_mode = "forge";
					self iprintln("Forge mode");
					self thread createforgehud();
					wait 0.5;
					break;
				}
				else
				{
					self thread destroyforgehud();
					self.spectator_mode = "ufo";
					self iprintln("UFO mode");
					wait 0.5;
					break;
				}
				wait 0.05;
			}

			if (self.spectator_mode == "forge")
			{
				// CLONE OBJECT
				if(self holdbreathbuttonpressed())
				{
					if(isdefined(focusedEnt))
					{
						if(isdefined(pickedUpEnt))
						{
							self iprintln("Can't clone while holding an object");
							wait 0.1;
							continue;
						}
						if(isdefined(focusedEnt.model) && isdefined(focusedEnt.script_brushmodel) && (focusedEnt.model == "com_bomb_objective" || focusedEnt.model == "com_laptop_2_open" || focusedEnt.model == "com_plasticcase_beige_big"))
						{
							// spawn a script_model convert it to a script_brushmodel
							script_brushmodel = spawn("script_model", focusedEnt.script_brushmodel.origin);
							script_brushmodel.angles = focusedEnt.script_brushmodel.angles;
							script_brushmodel clonebrushmodeltoscriptmodel(focusedEnt.script_brushmodel);

							script_model = spawn("script_model", focusedEnt.origin);
							script_model setmodel(focusedEnt.model);
							script_model.angles = focusedEnt.angles;

							script_brushmodel linkto(script_model);

							script_model linkto(self);
							focusedEnt = script_model;	// so HUD updates correctly
							pickedUpEnt = script_model;
							self iprintln("Cloned and picked up " + getdisplayname(script_model));
							wait 0.25;
							// break;
						}
						// mp_bog
						else if (focusedEnt.classname == "script_brushmodel" && (focusedEnt.targetname == "arch_before" || "pipe_shootable"))
						{
							script_brushmodel = spawn("script_model", focusedEnt.origin);
							script_brushmodel.angles = focusedEnt.angles;
							script_brushmodel clonebrushmodeltoscriptmodel(focusedEnt);

							script_brushmodel linkto(self);
							pickedUpEnt = script_brushmodel;
							self iprintln("Cloned and picked up " + getdisplayname(script_brushmodel));
							wait 0.25;
						}
						
						else
						{
							self iprintln("Can't clone " + getdisplayname(focusedEnt));
						}
					}
				}

				// exit forge
				if (self adsButtonPressed())
				{
					self thread destroyforgehud();
					self ufocontrolsOFF();
					self freezecontrols(false);
					self iprintln("Forge mode OFF");
					return;
				}

				// pick up or drop ent
				if (!isdefined(pickedUpEnt) && isdefined(focusedEnt) && self attackButtonPressed())
				{
					ent = focusedEnt;
					ent linkto(self);
					pickedUpEnt = focusedEnt;
					self iprintln("Picked up " + getdisplayname(ent));
					wait 0.25;
					break;
				}
				else if (isdefined(pickedUpEnt) && self attackButtonPressed())
				{
					ent = pickedUpEnt;
					ent unlink();
					ent.origin = flat_origin(ent.origin); // snap to whole numbers
					pickedUpEnt = undefined;
					self iprintln("Dropped " + getdisplayname(ent));
					wait 0.25;
					break;
				}

				// change mode
				if (self fragbuttonpressed())
				{
					if (self.forge_change_mode == "z")
						self.forge_change_mode = "pitch";
					else if (self.forge_change_mode == "pitch")
						self.forge_change_mode = "yaw";
					else if (self.forge_change_mode == "yaw")
						self.forge_change_mode = "roll";
					else if (self.forge_change_mode == "roll")
						self.forge_change_mode = "z";

					self.forge_hud["mode"] setText("mode: " + self.forge_change_mode);

					wait 0.1;
				}
				else if (self secondaryoffhandbuttonpressed())
				{
					if (self.forge_change_mode == "pitch")
						self.forge_change_mode = "z";
					else if (self.forge_change_mode == "z")
						self.forge_change_mode = "roll";
					else if (self.forge_change_mode == "roll")
						self.forge_change_mode = "yaw";
					else if (self.forge_change_mode == "yaw")
						self.forge_change_mode = "pitch";

					self.forge_hud["mode"] setText("mode: " + self.forge_change_mode);

					wait 0.1;
				}
			}

			wait 0.05;
		}

		if (self.spectator_mode == "forge")
		{
			if (!isdefined(pickedUpEnt))
			{
				forward = anglestoforward(self getplayerangles());
				eye = self.origin + (0, 0, 10);
				start = eye;
				end = vectorscale(forward, 9999);
				trace = bullettrace(start, start + end, true, self);
				if (isdefined(trace["entity"]))
				{
					ent = trace["entity"];
					self.forge_hud["reticle"].color = focusedColor;
					if (isdefined(ent.forge_parent))
						ent = ent.forge_parent;

					focusedEnt = ent;
				}
				else
				{
					self.forge_hud["reticle"].color = unfocusedColor;
					focusedEnt = undefined;
				}
			}
			else
			{
				self.forge_hud["reticle"].color = pickedUpColor;
			}

			// update hud
			if (isdefined(focusedEnt))
			{
				self.forge_hud["pitch"] SetValue(focusedEnt.angles[0]);
				self.forge_hud["yaw"] SetValue(focusedEnt.angles[1]);
				self.forge_hud["roll"] SetValue(focusedEnt.angles[2]);
				self.forge_hud["x"] SetValue(focusedEnt.origin[0]);
				self.forge_hud["y"] SetValue(focusedEnt.origin[1]);
				self.forge_hud["z"] SetValue(focusedEnt.origin[2]);
				self.forge_hud["mode"].alpha = 1;
				self.forge_hud["pitch"].alpha = 1;
				self.forge_hud["yaw"].alpha = 1;
				self.forge_hud["roll"].alpha = 1;
				self.forge_hud["x"].alpha = 1;
				self.forge_hud["y"].alpha = 1;
				self.forge_hud["z"].alpha = 1;
			}
			else
			{
				self.forge_hud["mode"].alpha = 0;
				self.forge_hud["pitch"].alpha = 0;
				self.forge_hud["yaw"].alpha = 0;
				self.forge_hud["roll"].alpha = 0;
				self.forge_hud["x"].alpha = 0;
				self.forge_hud["y"].alpha = 0;
				self.forge_hud["z"].alpha = 0;
			}

			// rotations and movements can't be done on a linked entity so do it on focus
			if (!isdefined(pickedUpEnt) && isdefined(focusedEnt) && self secondaryoffhandbuttonpressed() || self fragbuttonpressed())
			{
				if (self secondaryoffhandbuttonpressed())
				{
					if (self.forge_change_mode == "pitch")
						focusedEnt rotatepitch(unit, 0.05);
					else if (self.forge_change_mode == "yaw")
						focusedEnt rotateyaw(unit, 0.05);

					else if (self.forge_change_mode == "roll")
						focusedEnt rotateroll(unit, 0.05);
					else if (self.forge_change_mode == "z")
						focusedEnt movez(unit * -1, 0.05);
				}
				else if (self fragbuttonpressed())
				{
					if (self.forge_change_mode == "pitch")
						focusedEnt rotatepitch(unit * -1, 0.05);
					else if (self.forge_change_mode == "yaw")
						focusedEnt rotateyaw(unit * -1, 0.05);
					else if (self.forge_change_mode == "roll")
						focusedEnt rotateroll(unit * -1, 0.05);
					else if (self.forge_change_mode == "z")
						focusedEnt movez(unit, 0.05);
				}
			}
		}

		wait 0.05;
	}
}

// TODO: refactor forge mode into readable functions
// maybe switch statement with actions
// Don't allow more clone while something is picked up
// Add entity counter to hud
// RB opens + closes. Except if hovering on item in forge mode


ufoend()
{
	if (self.spectator_mode == "ufo")
	{
		self ufocontrolsOFF();
		self notify("forge_end");
		self iprintln("UFO mode OFF");
	}
}

ufocontrolsON()
{
	self setClientDvar("player_view_pitch_up", 89.9);	// allow looking straight up
	self setClientDvar("player_view_pitch_down", 89.9); // allow looking straight down

	self allowSpectateTeam("freelook", true);
	self.sessionstate = "spectator";
}

ufocontrolsOFF()
{
	self setClientDvar("player_view_pitch_down", 70);

	self allowSpectateTeam("freelook", false);
	self.sessionstate = "playing";
}

getdisplayname(ent)
{
	if (isplayer(ent))
		return ent.name;
	else if (isdefined(ent.model) && ent.model != "")
		return ent.model;
	else
		return ent.classname;
}

// TODO: maybe store script_brushmodel and link script_model to it
initForgeModels()
{
	// keep in alphabetical order
	level.FORGE_MODELS = [];
	level.FORGE_MODELS["bc_hesco_barrier_med"] = [];
	level.FORGE_MODELS["com_bomb_objective"] = [];
	level.FORGE_MODELS["com_laptop_2_open"] = [];
	level.FORGE_MODELS["com_plasticcase_beige_big"] = [];

	level.FORGE_MODELS["pipe"] = [];
	level.FORGE_MODELS["terrain"] = [];
	level.FORGE_MODELS["arch"] = [];
	level.FORGE_MODELS["fuel_tanker"] = [];
	level.FORGE_MODELS["fence_piece"] = [];

	script_models = getentarray("script_model", "classname");
	script_brushmodels = getentarray("script_brushmodel", "classname");

	for (i = 0; i < script_models.size; i++)
	{
		if (script_models[i].model == "com_bomb_objective")
		{
			for (j = 0; j < script_brushmodels.size; j++)
			{
				if (!isdefined(script_brushmodels[j].script_gameobjectname))
					continue;

				if (script_brushmodels[j].script_gameobjectname != script_models[i].script_gameobjectname)
					continue;

				if (distance(script_models[i].origin, script_brushmodels[j].origin) > 80)
					continue;

				script_models[i].script_brushmodel = script_brushmodels[j];
				script_brushmodels[j] linkto(script_models[i]);
				level.FORGE_MODELS["com_bomb_objective"][level.FORGE_MODELS["com_bomb_objective"].size] = script_models[i];
			}
		}

		if (script_models[i].model == "com_laptop_2_open")
		{
			choices = [];
			for (j = 0; j < script_brushmodels.size; j++)
			{
				if (script_brushmodels[j].script_gameobjectname != "hq")
					continue;

				if (!isdefined(script_brushmodels[j].targetname) || script_brushmodels[j].targetname != script_models[i].target)
					continue;

				choices[choices.size] = script_brushmodels[j];
			}

			AssertEx(choices.size == 2, "Expected 2 brush choices for com_laptop_2_open, got " + choices.size);
			// choose the higher Zorigin
			if (choices[0].origin[2] > choices[1].origin[2])
			{
				script_models[i].script_brushmodel = choices[0];
				choices[0] linkto(script_models[i]);
			}
			else
			{
				script_models[i].script_brushmodel = choices[1];
				choices[1] linkto(script_models[i]);
			}

			level.FORGE_MODELS["com_laptop_2_open"][level.FORGE_MODELS["com_laptop_2_open"].size] = script_models[i];
		}

		if (script_models[i].model == "com_plasticcase_beige_big")
		{
			choices = [];
			for (j = 0; j < script_brushmodels.size; j++)
			{
				if (!isdefined(script_brushmodels[j].script_gameobjectname))
					continue;

				if (script_brushmodels[j].script_gameobjectname != "hq")
					continue;

				if (!isdefined(script_brushmodels[j].targetname) || script_brushmodels[j].targetname != script_models[i].targetname)
					continue;

				choices[choices.size] = script_brushmodels[j];
			}

			AssertEx(choices.size == 2, "Expected 2 brush choices for com_plasticcase_beige_big, got " + choices.size);
			// choose the lower Zorigin
			if (choices[0].origin[2] < choices[1].origin[2])
			{
				script_models[i].script_brushmodel = choices[0];
				choices[0] linkto(script_models[i]);
			}
			else
			{
				script_models[i].script_brushmodel = choices[1];
				choices[1] linkto(script_models[i]);
			}

			level.FORGE_MODELS["com_plasticcase_beige_big"][level.FORGE_MODELS["com_plasticcase_beige_big"].size] = script_models[i];
		}
	}

	if (getdvar("mapname") == "mp_crossfire")
	{
		// there are 3 bc_hesco_barrier_med script_models linked to 1 script_brushmodel
		for (i = 0; i < script_brushmodels.size; i++)
		{
			if (!isdefined(script_brushmodels[i].script_gameobjectname))
				continue;

			if (script_brushmodels[i].script_gameobjectname != "dom")
				continue;

			bc_hesco_barrier_med_script_brushmodel = script_brushmodels[i];
			bc_hesco_barrier_med_script_models = [];

			for (j = 0; j < script_models.size; j++)
			{
				if (script_models[j].model == "bc_hesco_barrier_med")
				{
					if (distance(script_models[j].origin, bc_hesco_barrier_med_script_brushmodel.origin) < 80)
					{
						bc_hesco_barrier_med_script_models[bc_hesco_barrier_med_script_models.size] = script_models[j];
						script_models[j] linkto(bc_hesco_barrier_med_script_brushmodel);
						script_models[j].forge_parent = bc_hesco_barrier_med_script_brushmodel;
					}
				}
			}

			assertex(bc_hesco_barrier_med_script_models.size == 3, "Expected 3 bc_hesco_barrier_med script_models linked to 1 script_brushmodel, got " + bc_hesco_barrier_med_script_models.size);

			level.FORGE_MODELS["bc_hesco_barrier_med"][level.FORGE_MODELS["bc_hesco_barrier_med"].size] = bc_hesco_barrier_med_script_brushmodel;
		}
	}

	if (getdvar("mapname") == "mp_bog")
	{
		level.FORGE_MODELS["arch"][level.FORGE_MODELS["arch"].size] = getentbyorigin((3461, -149, 176));
	}

	if (getdvar("mapname") == "mp_cargoship")
	{
		level.FORGE_MODELS["fuel_tanker"][level.FORGE_MODELS["fuel_tanker"].size] = getentbyorigin((1300, 61, 104));
	}

	if (getdvar("mapname") == "mp_countdown")
	{
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-573, 2956, 32));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-574, 2958, 35));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-581, 2961, -18));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-568, 2953, -18));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-505, 2918, -37));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-506, 2918, 82));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-474, 2900, 36));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-439, 2880, 82));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-505, 2918, -11));
		level.FORGE_MODELS["fence_piece"][level.FORGE_MODELS["fence_piece"].size] = getentbyorigin((-439, 2880, -12));
	}

	if (getdvar("mapname") == "mp_farm")
	{
		level.FORGE_MODELS["pipe"] = getEntArray("gas_station", "targetname");
	}

	if (getdvar("mapname") == "mp_showdown")
	{
		level.FORGE_MODELS["terrain"][level.FORGE_MODELS["terrain"].size] = getentbyorigin((-1040, 74, 82), 1);
		level.FORGE_MODELS["terrain"][level.FORGE_MODELS["terrain"].size] = getentbyorigin((-1040, 74, 82), 2);
		level.FORGE_MODELS["terrain"][level.FORGE_MODELS["terrain"].size] = getentbyorigin((-778, 684, 82), 1);
		level.FORGE_MODELS["terrain"][level.FORGE_MODELS["terrain"].size] = getentbyorigin((-778, 684, 82), 2);
	}

	// capture the starting positions
	for (i = 0; i < level.FORGE_MODELS.size; i++)
	{
		modelName = getarraykeys(level.FORGE_MODELS)[i];
		for (j = 0; j < level.FORGE_MODELS[modelName].size; j++)
		{
			modelEnt = level.FORGE_MODELS[modelName][j];
			modelEnt.startOrigin = modelEnt.origin;
			modelEnt.startAngles = modelEnt.angles;
		}
	}
}

/**
 * Finds the nth entity with the specified origin.
 *
 * @param origin - The target origin to match.
 * @param matchNumber - (Optional) The 1-based position of the match to return. Defaults to 1.
 * @returns The entity at the specified matchNumber, or undefined if not found.
 */
getentbyorigin(origin, matchNumber)
{
	if (!isdefined(matchNumber))
		matchNumber = 1;

	matchCount = 0;

	ents = getentarray();
	for (i = 0; i < ents.size; i++)
	{
		if (ents[i].origin == origin)
		{
			matchCount++;
			if (matchCount == matchNumber)
				return ents[i];
		}
	}
}
