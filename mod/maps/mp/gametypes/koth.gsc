#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

/**
 * Flattens the Z-coordinate of the origin by converting it to an integer.
 *
 * @param origin - Array with X, Y, Z coordinates.
 * @return Tuple with Z as an integer.
 */
flat_origin_z(origin)
{
    x = origin[0];
    y = origin[1];
    z = origin[2];
    return (x, y, int(z));
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
	for (i = 0; i < level.bombs.size; i++)
	{
		level.bombs[i].origin = level.bombs[i].startOrigin;
		level.bombs[i].angles = level.bombs[i].startAngles;
	}
	for (i = 0; i < level.crates.size; i++)
	{
		level.crates[i].origin = level.crates[i].startOrigin;
		level.crates[i].angles = level.crates[i].startAngles;
	}
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

initGameObjects()
{
	ents = getentarray();

	for (i = 0; i < ents.size; i++)
	{
		// Search and Destroy / Sabotage bombs
		if(ents[i].classname == "script_model" && ents[i].model == "com_bomb_objective")
		{
			linkScriptBrushModel(ents[i]);
			ents[i].startOrigin = ents[i].origin;
			ents[i].startAngles = ents[i].angles;
			level.bombs[level.bombs.size] = ents[i];
		}

		// Headquarters crates
		if(ents[i].classname == "script_model" && ents[i].script_gameobjectname == "hq" && ents[i].model == "com_plasticcase_beige_big")
		{
			linkScriptBrushModel(ents[i]);
			ents[i].startOrigin = ents[i].origin;
			ents[i].startAngles = ents[i].angles;
			level.crates[level.crates.size] = ents[i];
		}
	}

	// self iPrintLn("Found " + level.bombs.size + " bombs on this map!");
	// self iPrintLn("Found " + level.crates.size + " crates on this map!");

	return true;
}

linkScriptBrushModel(ent)
{
	brushModels = getEntArray("script_brushmodel", "classname");
	for (i = 0; i < brushModels.size; i++)
	{
		if(distance(ent.origin, brushModels[i].origin) < 80 && ent.script_gameobjectname == brushModels[i].script_gameobjectname)
		{
			brushModels[i] LinkTo(ent);
			break;
		}
	}
}

spawnGameObject()
{
	playerAngles = self getPlayerAngles();
	ent = self.activeGameObject;
	ent.origin = flat_origin_z(self.origin + (anglestoforward(playerAngles) * 150));
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

InitExtraObjects()
{
	level.Showdownent = [];
	level.Wetwork = [];
	level.DownpourEnts = [];
	level.countdownents = [];
	entities = getEntArray();
	if (getDvar("mapname") == "mp_bog")
	{
	    for (i = 0; i < entities.size; i++)
    	    {
            	if (entities[i].classname == "script_brushmodel" && entities[i].targetname == "arch_before")
        	{
	    
		    	level.Ent1 = entities[i];
            
			break;
       	    
		}
	    }
	}
	if (getDvar("mapname") == "mp_countdown")
	{
	    for (i = 12; i < 18; i++) 
  	    {
        	if (entities[i].classname == "script_brushmodel")
        	{
		    	level.countdownents[i - 12] = entities[i]; 	  	    
		}
		wait .5;
	    }
	}
	if (getDvar("mapname") == "mp_farm")
	{
	   for (i = 384; i < 387; i++) 
    	   {
        	if (entities[i])
        	{
		    	level.DownpourEnts[i - 384] = entities[i]; 	  	    
		}
		wait .5;
	   }
	}
	if (getDvar("mapname") == "mp_cargoship")
	{
	    for (i = 445; i < 446; i++) 
    	    {
	    	level.Wetwork[i - 445] = entities[i]; 	  	    
		break;
    	    }
	}
	if (getDvar("mapname") == "mp_showdown")
	{
	    for (i = 276; i < 284; i++) 
    	    {
	    	level.Showdownent[i - 276] = entities[i]; 	  	    
		
	    }
	}
}

forgestart()
{
	self endon("disconnect");
	self endon("end_respawn");

	self.cj["settings"]["forge"] = true;

	self setClientDvar("player_view_pitch_up", 89.9);	   // allow looking straight up
	self setClientDvar("player_view_pitch_down", 89.9);	   // allow looking straight down
	self setClientDvar("player_spectateSpeedScale", 0.75); // Slower movement in spectator for precision
	self setClientDvar("cg_descriptiveText", 0);		   // Show button icons and text

	// TODO: place compass (if needed)

	self allowSpectateTeam("freelook", true);
	self.sessionstate = "spectator";

	instructions[0] = "[{+smoke}] + [{+frag}] Exit Forge";
	instructions[1] = "HOLD [{+activate}] + [{+smoke}] Pickup/Drop";
	instructions[2] = "HOLD [{+activate}] + [{+frag}] Cycle Modes";
	instructions[3] = "[{+smoke}] Decrease [{+frag}] Increase";

	instructionsString = "";
	for (i = 0; i < instructions.size; i++)
		instructionsString += instructions[i] + "\n";

	self.hud = [];

	self.hud["instructions"] = createFontString("default", 1.4);
	self.hud["instructions"] setPoint("TOPLEFT", "TOPLEFT", 0, 0);
	self.hud["instructions"] setText(instructionsString);

	self.hud["mode"] = createFontString("default", 1.4);
	self.hud["mode"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 60);
	self.hud["mode"] setText("mode: " + "pitch");

	self.hud["pitch"] = createFontString("default", 1.4);
	self.hud["pitch"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 80);
	self.hud["pitch"].label = &"pitch: &&1";
	self.hud["pitch"] SetValue(1);

	self.hud["yaw"] = createFontString("default", 1.4);
	self.hud["yaw"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 100);
	self.hud["yaw"].label = &"yaw: &&1";
	self.hud["yaw"] SetValue(1);

	self.hud["roll"] = createFontString("default", 1.4);
	self.hud["roll"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 120);
	self.hud["roll"].label = &"roll: &&1";
	self.hud["roll"] SetValue(1);

	self.hud["z"] = createFontString("default", 1.4);
	self.hud["z"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 140);
	self.hud["z"].label = &"z: &&1";
	self.hud["z"] SetValue(1);

	self.hud["reticle"] = createIcon("reticle_flechette", 40, 40);
	self.hud["reticle"] setPoint("center", "center", "center", "center");

	self iprintln("Forge started");

	focusedColor = (0, 0.5, 0.5);
	unfocusedColor = (1, 1, 1);
	pickedUpColor = (1, 0, 0);

	focusedEnt = undefined;
	pickedUpEnt = undefined;

	mode = "pitch";
	unit = 1;

	// NOTE: while in spectator mode only the following buttons are available:
	// usebuttonpressed, secondaryoffhandbuttonpressed, fragbuttonpressed, adsbuttonpressed, attackbuttonpressed
	// adsbuttonpressed, attackbuttonpressed are both used by spectator to move up and down

	for (;;)
	{
		// exit forge mode
		if (self secondaryoffhandbuttonpressed() && self fragbuttonpressed())
		{
			self setclientdvar("player_view_pitch_down", 70);

			self allowSpectateTeam("freelook", false);
			self.sessionstate = "playing";

			huds = getarraykeys(self.hud);
			for (i = 0; i < huds.size; i++)
				self.hud[huds[i]] destroy();

			self.cj["settings"]["forge"] = false;

			self iprintln("Forge ended");
			break;
		}

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
				self.hud["reticle"].color = focusedColor;
				focusedEnt = ent;
			}
			else
			{
				self.hud["reticle"].color = unfocusedColor;
				focusedEnt = undefined;
			}
		}
		else
		{
			self.hud["reticle"].color = pickedUpColor;
		}

		while (self usebuttonpressed())
		{
			// pick up or drop ent
			if (!isdefined(pickedUpEnt) && isdefined(focusedEnt) && self secondaryoffhandbuttonpressed())
			{
				ent = focusedEnt;
				ent linkto(self);
				pickedUpEnt = focusedEnt;
				self iprintln("Picked up " + getdisplayname(ent));
				wait 0.1;
				break;
			}
			else if (isdefined(pickedUpEnt) && !isplayer(pickedUpEnt) && self secondaryoffhandbuttonpressed())
			{
				ent = pickedUpEnt;
				ent unlink();
				ent.origin = flat_origin_z(ent.origin); // snap to whole numbers
				pickedUpEnt = undefined;
				self iprintln("Dropped " + getdisplayname(ent));
				wait 0.1;
				break;
			}

			// change mode
			if (self fragbuttonpressed())
			{
				if (mode == "z")
					mode = "pitch";
				else if (mode == "pitch")
					mode = "yaw";
				else if (mode == "yaw")
					mode = "roll";
				else if (mode == "roll")
					mode = "z";

				self.hud["mode"] setText("mode: " + mode);

				wait 0.1;
			}

			wait 0.05;
		}

		// update hud
		if (isdefined(focusedEnt))
		{
			self.hud["pitch"] SetValue(focusedEnt.angles[0]);
			self.hud["yaw"] SetValue(focusedEnt.angles[1]);
			self.hud["roll"] SetValue(focusedEnt.angles[2]);
			self.hud["z"] SetValue(focusedEnt.origin[2]);
			self.hud["pitch"].alpha = 1;
			self.hud["yaw"].alpha = 1;
			self.hud["roll"].alpha = 1;
			self.hud["z"].alpha = 1;
		}
		else
		{
			self.hud["pitch"].alpha = 0;
			self.hud["yaw"].alpha = 0;
			self.hud["roll"].alpha = 0;
			self.hud["z"].alpha = 0;
		}

		// rotations and movements can't be done on a linked entity
		if (!isdefined(pickedUpEnt) && isdefined(focusedEnt) && self secondaryoffhandbuttonpressed() || self fragbuttonpressed())
		{
			if (self secondaryoffhandbuttonpressed())
			{
				if (mode == "pitch")
					focusedEnt rotatepitch(unit, 0.05);
				else if (mode == "yaw")
					focusedEnt rotateyaw(unit, 0.05);

				else if (mode == "roll")
					focusedEnt rotateroll(unit, 0.05);
				else if (mode == "z")
					focusedEnt movez(unit * -1, 0.05);
			}
			else if (self fragbuttonpressed())
			{
				if (mode == "pitch")
					focusedEnt rotatepitch(unit * -1, 0.05);
				else if (mode == "yaw")
					focusedEnt rotateyaw(unit * -1, 0.05);
				else if (mode == "roll")
					focusedEnt rotateroll(unit * -1, 0.05);
				else if (mode == "z")
					focusedEnt movez(unit, 0.05);
			}
		}

		wait 0.05;
	}
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
