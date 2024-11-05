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

toggle_hud_display(type)
{
	if (!isdefined(self.cj["meter_hud"]))
		self.cj["meter_hud"] = [];

	// not defined means OFF
	if (!isdefined(self.cj["meter_hud"][type]))
	{
		if (type == "distance")
			self thread start_hud_distance();
		else if (type == "speed")
			self thread start_hud_speed();
		else if (type == "z_origin")
			self thread start_hud_distance_z_origin();
	}
	else
	{
		self notify("end_hud_" + type);
		self.cj["meter_hud"][type] destroy();
	}
}

start_hud_distance()
{
	self endon("disconnect");
	self endon("end_hud_distance");

	fontScale = 1.4;
	x = 62;
	y = 10;

	self.cj["meter_hud"]["distance"] = createFontString("small", fontScale);
	self.cj["meter_hud"]["distance"] setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", x, y);
	self.cj["meter_hud"]["distance"].alpha = 0.5;
	self.cj["meter_hud"]["distance"].label = &"distance:&&1";

	for (;;)
	{
		// trace using the player's eye position
		// but measure distance from the player's origin
		angles = self getPlayerAngles();
		origin = self.origin;

		stance = self getStance();
		if (stance == "prone")
			eye = self.origin + (0, 0, 11);
		else if (stance == "crouch")
			eye = self.origin + (0, 0, 40);
		else
			eye = self.origin + (0, 0, 60);

		start = eye;
		end = start + maps\mp\_utility::vector_scale(anglestoforward(angles), 999999);

		endpos = PhysicsTrace(start, end);

		distance = distance(origin, endpos);
		self.cj["meter_hud"]["distance"] setValue(distance);

		wait 0.05;
	}
}

start_hud_speed()
{
	self endon("disconnect");
	self endon("end_hud_speed");

	fontScale = 1.4;
	x = 62;
	y = 22;
	alpha = 0.5;

	self.cj["meter_hud"]["speed"] = createFontString("small", fontScale);
	self.cj["meter_hud"]["speed"] setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", x, y);
	self.cj["meter_hud"]["speed"].alpha = alpha;
	self.cj["meter_hud"]["speed"].label = &"speed:&&1";

	for (;;)
	{
		velocity3D = self getVelocity();
		horizontalSpeed2D = int(sqrt(velocity3D[0] * velocity3D[0] + velocity3D[1] * velocity3D[1]));
		self.cj["meter_hud"]["speed"] setValue(horizontalSpeed2D);

		wait 0.05;
	}
}

start_hud_distance_z_origin()
{
	self endon("disconnect");
	self endon("end_hud_z_origin");

	fontScale = 1.4;
	x = 62;
	y = 36;

	self.cj["meter_hud"]["z_origin"] = createFontString("small", fontScale);
	self.cj["meter_hud"]["z_origin"] setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", x, y);
	self.cj["meter_hud"]["z_origin"].alpha = 0.5;
	self.cj["meter_hud"]["z_origin"].label = &"z:&&1";

	for (;;)
	{
		self.cj["meter_hud"]["z_origin"] setValue(self.origin[2]);

		wait 0.05;
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

LeanBindToggle()
{
    if (!isDefined(self.LeanBind) || self.LeanBind == false) 
    {
        self.LeanBind = true;
    }
    else 
    {
        self.LeanBind = false;
    }
    if (self.LeanBind == true)
    {
        enableLeanBinds();
    }
    else if (self.LeanBind == false)
    {
        disableLeanBinds();
    }
}
RevertVision()
{
	VisionSetNaked( getDvar( "mapname" ), 3.0 );
	self.CVIndex = 0;
}
CycleVision()
{
	level.visionModes[0] = "blank";
	level.visionModes[1] = "cheat_chaplinnight";
	level.visionModes[2] = "aftermath";
	level.visionModes[3] = "default_night";	
	level.visionModes[4] = "mp_convoy";
   	level.visionModes[5] = "mp_bloc";
	level.visionModes[6] = "mp_backlot";
    	level.visionModes[7] = "mp_bog";
    	level.visionModes[8] = "mp_crash";
	level.visionModes[9] = "mp_citystreets";
    	level.visionModes[10] = "mp_crossfire";
	level.visionModes[11] = "mp_farm";
    	level.visionModes[12] = "mp_vacant";
    	level.visionModes[13] = "mp_overgrown";
    	level.visionModes[14] = "mp_pipeline";
	level.visionModes[15] = "mp_shipment";
    	level.visionModes[16] = "mp_showdown";
    	level.visionModes[17] = "mp_strike";
    	level.visionModes[18] = "mp_countdown";
   	level.visionModes[19] = "mp_cargoship";
    if (!isDefined(self.CVIndex))
    {
        self.CVIndex = 0;
    }
    if (self.CVIndex >= level.visionModes.size)
    {
        self.CVIndex = 0; 
    }
    VisionSetNaked(level.visionModes[self.CVIndex], 1.5);
    self iPrintlnBold("Vision Mode: ^3" + level.visionModes[self.CVIndex]);
    self.CVIndex++;
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

getForgeInstructionsText(state)
{
	instructions = [];

	if (!isdefined(state))
	{
		instructions[instructions.size] = "[{+activate}] Hold for more options";
		instructions[instructions.size] = "[{+smoke}] Change speed";
		instructions[instructions.size] = "[{+frag}] Exit";
	}
	else if (state == "FOCUSED")
	{
		instructions[instructions.size] = "[{+activate}] Hold for more options";
		instructions[instructions.size] = "[{+smoke}] Decrease";
		instructions[instructions.size] = "[{+frag}] Increase";
	}
	else if (state == "HOLD_X")
	{
		instructions[instructions.size] = "[{+smoke}] Next mode";
		instructions[instructions.size] = "[{+frag}] Prev mode";

		instructions[instructions.size] = "[{+speed_throw}] Exit Forge";
		instructions[instructions.size] = "[{+attack}] Pick up/Drop";
		if (level.xenon)
			instructions[instructions.size] = "[{+breath_sprint}] Clone object";

		instructions[instructions.size] = "[{+melee}] Switch to UFO mode";
	}

	instructionsString = "";
	for (i = 0; i < instructions.size; i++)
		instructionsString += instructions[i] + "\n";

	return instructionsString;
}

createforgehud()
{
	self.forge_hud = [];
	self.forge_hud["instructions"] = createFontString("default", 1.4);
	self.forge_hud["instructions"] setPoint("TOPLEFT", "TOPLEFT", -30, -20);
	self.forge_hud["instructions"] setText(getForgeInstructionsText());

	x = 30;

	self.forge_hud["entities"] = createFontString("default", 1.4);
	self.forge_hud["entities"] setPoint("TOPRIGHT", "TOPRIGHT", x, -20);
	self.forge_hud["entities"].label = &"entities (1000 max): &&1";
	self.forge_hud["entities"] SetValue(getentarray().size);

	self.forge_hud["mode"] = createFontString("default", 1.4);
	self.forge_hud["mode"] setPoint("TOPRIGHT", "TOPRIGHT", x, 0);
	self.forge_hud["mode"] setText("mode: " + self.forge_change_mode);
	self.forge_hud["mode"].alpha = 0;

	self.forge_hud["pitch"] = createFontString("default", 1.4);
	self.forge_hud["pitch"] setPoint("TOPRIGHT", "TOPRIGHT", x, 20);
	self.forge_hud["pitch"].label = &"pitch: &&1";
	self.forge_hud["pitch"] SetValue(0);
	self.forge_hud["pitch"].alpha = 0;

	self.forge_hud["yaw"] = createFontString("default", 1.4);
	self.forge_hud["yaw"] setPoint("TOPRIGHT", "TOPRIGHT", x, 40);
	self.forge_hud["yaw"].label = &"yaw: &&1";
	self.forge_hud["yaw"] SetValue(0);
	self.forge_hud["yaw"].alpha = 0;

	self.forge_hud["roll"] = createFontString("default", 1.4);
	self.forge_hud["roll"] setPoint("TOPRIGHT", "TOPRIGHT", x, 60);
	self.forge_hud["roll"].label = &"roll: &&1";
	self.forge_hud["roll"] SetValue(0);
	self.forge_hud["roll"].alpha = 0;

	self.forge_hud["x"] = createFontString("default", 1.4);
	self.forge_hud["x"] setPoint("TOPRIGHT", "TOPRIGHT", x, 80);
	self.forge_hud["x"].label = &"x: &&1";
	self.forge_hud["x"] SetValue(0);
	self.forge_hud["x"].alpha = 0;

	self.forge_hud["y"] = createFontString("default", 1.4);
	self.forge_hud["y"] setPoint("TOPRIGHT", "TOPRIGHT", x, 100);
	self.forge_hud["y"].label = &"y: &&1";
	self.forge_hud["y"] SetValue(0);
	self.forge_hud["y"].alpha = 0;

	self.forge_hud["z"] = createFontString("default", 1.4);
	self.forge_hud["z"] setPoint("TOPRIGHT", "TOPRIGHT", x, 120);
	self.forge_hud["z"].label = &"z: &&1";
	self.forge_hud["z"] SetValue(0);
	self.forge_hud["z"].alpha = 0;

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

	spectator_speed_settings = [];
	spectator_speed_settings["slowest"] = 0.1;
	spectator_speed_settings["slower"] = 0.25;
	spectator_speed_settings["slow"] = 0.5;
	spectator_speed_settings["normal"] = 1;
	spectator_speed_settings["fast"] = 1.5;
	spectator_speed_settings["faster"] = 3;

	if(!isdefined(self.spectator_speed_index))
		self.spectator_speed_index = 3;

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

	unfocusedColor = (0.5, 0.5, 0.5); // gray for unfocused
	focusedColor = (0, 1, 0);		  // green for focused
	pickedUpColor = (1, 0, 0);		  // red for picked up

	self.focusedEnt = undefined;
	self.pickedUpEnt = undefined;

	unit = 1;

	for (;;)
	{
		// prevent monitoring when in menu
		if (self.cj["menu_open"])
		{
			wait 0.1;
			continue;
		}

		if (!isdefined(self.focusedEnt) && !isdefined(self.pickedUpEnt) && self secondaryoffhandbuttonpressed())
		{
			self cycle_spectator_speed();
			wait 0.1;
		}

		// don't unfreeze controls if in menu otherwise the menu controls will break
		if (!self.cj["menu_open"])
			self freezecontrols(false);

		// HOLD X actions
		while (self usebuttonpressed())
		{
			self.forge_hud["instructions"] setText(getForgeInstructionsText("HOLD_X"));
			// freeze controls to allow meleebuttonpressed while in spectator
			self freezecontrols(true);
			if (self meleebuttonpressed())
			{
				if (self.spectator_mode == "ufo")
				{
					self thread createforgehud();
					self.spectator_mode = "forge";
					self setClientDvar("player_spectateSpeedScale", 0.5); // Slower speed for fine movements
					self iprintln("Forge mode");
					wait 0.25;
					break;
				}
				else
				{
					if (isdefined(self.pickedUpEnt))
					{
						self iprintln("Can't switch to UFO while holding an object");
						wait 0.1;
					}
					else
					{
						self thread destroyforgehud();
						self.spectator_mode = "ufo";
						self setClientDvar("player_spectateSpeedScale", 1.5);
						self iprintln("UFO mode");
						wait 0.25;
						break;
					}
				}
				wait 0.05;
			}

			if (self.spectator_mode == "forge")
			{

#if defined(SYSTEM_XENON)
				// CLONE OBJECT
				if (self holdbreathbuttonpressed())
				{
					if (isdefined(self.pickedUpEnt))
					{
						self iprintln("Can't clone while holding an object");
						wait 0.1;
					}
					else if (isdefined(self.focusedEnt))
					{
						cloned_object = self cloneObject(self.focusedEnt);
						if (isdefined(cloned_object))
						{
							cloned_object linkto(self);
							self.pickedUpEnt = cloned_object;
							self.focusedEnt = cloned_object; // so HUD updates correctly
							self iprintln("Cloned and picked up " + getdisplayname(cloned_object));
							wait 0.25;
						}
						else
						{
							self iprintln("Can't clone " + getdisplayname(self.focusedEnt));
							wait 0.1;
						}
					}
				}
#endif
				// pick up or drop ent
				if (!isdefined(self.pickedUpEnt) && isdefined(self.focusedEnt) && self attackButtonPressed())
				{
					ent = self.focusedEnt;
					ent linkto(self);
					self.pickedUpEnt = self.focusedEnt;
					self iprintln("Picked up " + getdisplayname(ent));
					wait 0.25;
					break;
				}
				else if (isdefined(self.pickedUpEnt) && self attackButtonPressed())
				{
					ent = self.pickedUpEnt;
					ent unlink();
					ent.origin = flat_origin(ent.origin); // snap to whole numbers
					self.pickedUpEnt = undefined;
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
			if (!isdefined(self.pickedUpEnt))
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

					self.focusedEnt = ent;
				}
				else
				{
					self.forge_hud["reticle"].color = unfocusedColor;
					self.focusedEnt = undefined;
				}
			}
			else
			{
				self.forge_hud["reticle"].color = pickedUpColor;
			}

			// update hud

			if (isdefined(self.focusedEnt))
				self.forge_hud["instructions"] setText(getForgeInstructionsText("FOCUSED"));
			else
				self.forge_hud["instructions"] setText(getForgeInstructionsText());

			self.forge_hud["entities"] SetValue(getentarray().size);

			if (isdefined(self.focusedEnt))
			{
				self.forge_hud["pitch"] SetValue(self.focusedEnt.angles[0]);
				self.forge_hud["yaw"] SetValue(self.focusedEnt.angles[1]);
				self.forge_hud["roll"] SetValue(self.focusedEnt.angles[2]);
				self.forge_hud["x"] SetValue(self.focusedEnt.origin[0]);
				self.forge_hud["y"] SetValue(self.focusedEnt.origin[1]);
				self.forge_hud["z"] SetValue(self.focusedEnt.origin[2]);
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
			if (!isdefined(self.pickedUpEnt) && isdefined(self.focusedEnt) && (self secondaryoffhandbuttonpressed() || self fragbuttonpressed()))
			{
				if (self secondaryoffhandbuttonpressed())
				{
					if (self.forge_change_mode == "pitch")
						self.focusedEnt rotatepitch(unit, 0.05);
					else if (self.forge_change_mode == "yaw")
						self.focusedEnt rotateyaw(unit, 0.05);
					else if (self.forge_change_mode == "roll")
						self.focusedEnt rotateroll(unit, 0.05);
					else if (self.forge_change_mode == "z")
						self.focusedEnt movez(unit * -1, 0.05);
				}
				else if (self fragbuttonpressed())
				{
					if (self.forge_change_mode == "pitch")
						self.focusedEnt rotatepitch(unit * -1, 0.05);
					else if (self.forge_change_mode == "yaw")
						self.focusedEnt rotateyaw(unit * -1, 0.05);
					else if (self.forge_change_mode == "roll")
						self.focusedEnt rotateroll(unit * -1, 0.05);
					else if (self.forge_change_mode == "z")
						self.focusedEnt movez(unit, 0.05);
				}
			}
		}

		wait 0.05;
	}
}

// TODO: refactor forge mode into readable functions
// maybe switch statement with actions
// Add a way to delete entities
// Add a x,y movement mode
// add better datastructure for forge models, cloned objects don't inherit classname and targetnames etc

#if defined(SYSTEM_XENON)

cloneObject(ent)
{
	if (!isdefined(ent))
	{
		self iprintln("No object to clone");
		return;
	}
	if (ent.classname != "script_brushmodel" && ent.classname != "script_model")
	{
		self iprintln("Entity classname must be one of {script_brushmodel, script_model}");
		return;
	}
	if (!isdefined(ent.forge_enabled) || !ent.forge_enabled)
	{
		self iprintln("Entity must be forge enabled");
		return;
	}
	if (getentarray().size >= 1000)
	{
		self iprintln("Max entities reached");
		return;
	}
	// TODO: maybe add a well known key to entity to indicate the forge type and its required properties to clone
	// case 1: 1 script_model, 1 script_brushmodel
	if (ent.classname == "script_model" && isdefined(ent.script_brushmodel))
	{
		script_model = spawn("script_model", ent.origin);
		script_model setmodel(ent.model);
		script_model.angles = ent.angles;

		script_brushmodel = spawn("script_model", ent.script_brushmodel.origin);
		script_brushmodel.angles = ent.script_brushmodel.angles;
		script_brushmodel clonebrushmodeltoscriptmodel(ent.script_brushmodel);
		script_brushmodel.classname = "script_brushmodel";
		script_brushmodel linkto(script_model);

		script_model.script_brushmodel = script_brushmodel;
		script_model.forge_enabled = true;

		return script_model;
	}
	// case 2: 1 script_brushmodel or script_model
	else if (!isdefined(ent.forge_children))
	{
		script_brushmodel = spawn("script_model", ent.origin);
		script_brushmodel.angles = ent.angles;
		script_brushmodel clonebrushmodeltoscriptmodel(ent);
		script_brushmodel.forge_enabled = true;

		return script_brushmodel;
	}
	// case 3: 1 script_brushmodel or script_model, multiple script_models
	else if (isdefined(ent.forge_children))
	{
		if (ent.forge_children.size == 0)
		{
			self iprintln("No forge_children to clone");
			return;
		}

		script_brushmodel = spawn("script_model", ent.origin);
		script_brushmodel.angles = ent.angles;
		script_brushmodel clonebrushmodeltoscriptmodel(ent);

		script_models = [];

		for (i = 0; i < ent.forge_children.size; i++)
		{
			script_model = spawn("script_model", ent.forge_children[i].origin);
			script_model setmodel(ent.forge_children[i].model);
			script_model.angles = ent.forge_children[i].angles;
			script_model linkto(script_brushmodel);
			script_model.forge_enabled = true;
			script_model.forge_parent = script_brushmodel;
			script_models[script_models.size] = script_model;
		}

		script_brushmodel.forge_enabled = true;
		script_brushmodel.forge_children = script_models;

		return script_brushmodel;
	}
}

#endif

ufoend()
{
	if (self.spectator_mode == "ufo")
	{
		self ufocontrolsOFF();
		self notify("forge_end");
		self iprintln("UFO mode OFF");
	}
	else if (self.spectator_mode == "forge")
	{
		if (isdefined(self.focusedEnt))
			return;
		if (isdefined(self.pickedUpEnt))
			self iprintln("Can't exit while holding an object");
		else
		{
			self notify("forge_end");
			self thread destroyforgehud();
			self ufocontrolsOFF();
			self freezecontrols(false);
			self iprintln("Forge mode OFF");
		}
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

	self freezeControls(false);
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

setSaveIndex()
{
	i = self.cj["savenum"];
	self.cj["savenum"] = (i + 1) % 10;

	self iPrintln("Position " + (self.cj["savenum"] + 1) + " set");
}

cycle_spectator_speed()
{
	speeds[0] = 0.05;
	speeds[1] = 0.1;
	speeds[2] = 0.2;
	speeds[3] = 0.4;
	speeds[4] = 0.8;
	speeds[5] = 1;
	speeds[6] = 1.5;
	speeds[7] = 3;

	self.cj["spectator_speed_index"] += 1;
	if (self.cj["spectator_speed_index"] >= speeds.size)
		self.cj["spectator_speed_index"] = 0;

	speed = speeds[self.cj["spectator_speed_index"]];
	self setClientDvar("player_spectateSpeedScale", speed);
	msg = "player_spectateSpeedScale " + speed;
	if (speed == 1)
		msg += " (default)";

	self iprintln(msg);
}
