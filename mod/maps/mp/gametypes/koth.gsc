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
	self endon("death");
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

activeGameObjectRotatePitch(angle)
{
	self.activeGameObject rotatepitch(angle, 0.05);
	wait 0.1;
	self iprintln("pitch: " + self.activeGameObject.angles[0]);
}

activeGameObjectRotateYaw(angle)
{
	self.activeGameObject rotateyaw(angle, 0.05);
	wait 0.1;
	self iprintln("yaw: " + self.activeGameObject.angles[1]);
}

activeGameObjectRotateRoll(angle)
{
	self.activeGameObject rotateroll(angle, 0.05);
	wait 0.1;
	self iprintln("roll: " + self.activeGameObject.angles[2]);
}

activeGameObjectMoveOriginZ(z)
{
	self.activeGameObject movez(z, 0.05);
	wait 0.1;
	self iprintln("z: " + self.activeGameObject.origin[2]);
}

forgeMode()
{
	self endon("death");
	self endon("disconnect");
	self endon("stop_forge");

	for (;;) {
		while (self adsbuttonpressed())
		{
			trace = bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglestoforward(self getplayerangles()) * 1000000, true, self);
			ent = trace["entity"];
			while (self adsbuttonpressed())
			{
				origin = self gettagorigin("j_head") + anglestoforward(self getplayerangles()) * 150;
				// Only pickup bots, bombs and crates
				if ( isplayer(ent) && isdefined(ent.pers["isBot"]) )
				{
					ent setorigin(origin);
				}
				if ( isdefined(ent.model) && (ent.model == "com_bomb_objective" || ent.model == "com_plasticcase_beige_big") )
				{
					ent.origin = origin;
				}
				wait 0.05;
			}
		}
		wait 0.05;
	}
}

toggleForgeMode()
{
	setting = "forge_mode";
	printName = "Forge Mode";

	if (!isdefined(self.cj["settings"][setting]) || self.cj["settings"][setting] == false)
	{
		self.cj["settings"][setting] = true;
		self thread forgeMode();
		self iPrintln(printName + " [^2ON^7]");
		self iPrintln("Hold [{+speed_throw}] to lift stuff");
	}
	else
	{
		self.cj["settings"][setting] = false;
		self notify("stop_forge");
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
	self endon("death");

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

#if CJ_ENHANCED
// NOTE: Currently all custom GSC functions require self

removeBarriersOverHeight(height)
{
	self restorebrushcollisions();
	self removebrushcollisionsoverheight(height);
	if(height == 0)
		iprintln("Barriers removed");
	else
		iprintln("Barriers above " + height + " height removed");
}

restoreBarriers()
{
	self restorebrushcollisions();
	iprintln("Barriers restored");
}

startAutoMantle()
{
	self endon("disconnect");
	self endon("death");
	self endon("stop_automantle");

	playerName = "bot0";
	bot = getPlayerFromName(playerName);
	if (!isdefined(bot))
	{
		self iPrintln("Could not find player: " + playerName);
		return;
	}
	else
	{
		self iprintln("Watching player: " + playerName);
	}

	bot savePos();
	for (;;)
	{
		if (distance(bot geteye(), self getOrigin()) < 150)
		{
			self botaction();
			wait 2;
			bot loadPos();
		}
		wait 0.05;
	}
}

stopAutoMantle()
{
	self notify("stop_automantle");
	self iprintln("Stopped automantle");
}

#endif
