#include maps\mp\gametypes\_hud_util;

nightVisionButtonPressed()
{
	return isdefined(self.nightVisionButtonPressedTime) && (getTime() - self.nightVisionButtonPressedTime < 200);
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

setFilmTweaksPreset(preset)
{
	switch (preset)
	{
	case "art_1":
		self setclientdvars(
			"r_filmUseTweaks", 1,
			"r_filmTweakEnable", 1,
			"r_glowUseTweaks", 1);
		break;
	case "art_2":
		self setclientdvars(
			"r_filmUseTweaks", 1,
			"r_filmTweakEnable", 1,
			"r_filmtweakbrightness", 0.07,
			"r_filmtweakdesaturation", 0.2,
			"r_filmTweakLightTint", "1.2 1.2 1",
			"r_filmTweakDarkTint", "1.1 1.1 1.8",
			"r_filmTweakContrast", 1.6,
			"r_lightTweakSunColor", "0.9 0.6 0.35 1",
			"r_lightTweakSunDirection", "-40 140 0",
			"r_lightTweakSunLight", 1.1,
			"r_specularColorScale", 4,
			"r_glow", 0,
			"r_desaturation", 0);
		break;
	case "art_3":
		self setclientdvars(
			"r_filmUseTweaks", 1,
			"r_filmTweakEnable", 1,
			"r_filmTweakContrast", 1.4,
			"r_filmTweakDarkTint", "0.9 1 1.3",
			"r_filmTweakLightTint", "1.25 1.4 1.7",
			"r_filmTweakBrightness", 0,
			"r_distortion", 1,
			"r_desaturation", 0,
			"r_blur", 0.05,
			"r_filmtweakdesaturation", 0,
			"r_specularColorScale", 3,
			"r_lightTweakSunColor", "1 0.6 0.25 0",
			"r_lightTweakSunDirection", "-30 -260 0",
			"r_lightTweakSunLight", 1.6);
		break;
	case "art_4":
		self setclientdvars(
			"r_filmUseTweaks", 1,
			"r_filmTweakEnable", 1,
			"r_filmTweakBrightness", 0,
			"r_filmTweakContrast", 1.2,
			"r_filmTweakDesaturation", 0.2,
			"r_filmTweakInvert", 0,
			"r_filmTweakLightTint", "1.6 1.6 1.6",
			"r_filmTweakDarkTint", "0.8 0.8 0.9",
			"r_lightTweakSunColor", "1 0.9 0.6 1",
			"r_lightTweakSunDirection", "-90 100 0",
			"r_lightTweakSunLight", 1.3);
		break;
	case "blue_sky":
		self setclientdvars(
			"r_filmUseTweaks", 1,
			"r_filmTweakEnable", 1,
			"r_filmTweakContrast", 2,
			"r_filmTweakDarkTint", "1.7 1.7 2",
			"r_filmtweakdesaturation", 0,
			"r_filmTweakLightTint", "0. 0.25 .5",
			"r_filmTweakBrightness", 0.5,
			"r_gamma", 0.8);
		break;
	case "pink_sky":
		self setclientdvars(
			"r_filmUseTweaks", 1,
			"r_filmTweakEnable", 1,
			"r_filmTweakContrast", 2,
			"r_filmTweakDarkTint", "1.7 1.7 2",
			"r_filmtweakdesaturation", 0,
			"r_filmTweakLightTint", "0.3 0.2 0.3",
			"r_filmTweakBrightness", 0.5,
			"r_gamma", 0.8);
		break;
	case "green_sky":
		self setclientdvars(
			"r_filmUseTweaks", 1,
			"r_filmTweakEnable", 1,
			"r_filmTweakContrast", 2,
			"r_filmTweakDarkTint", "1.7 1.7 2",
			"r_filmtweakdesaturation", 0,
			"r_filmTweakLightTint", "0 0.25 0.25",
			"r_filmTweakBrightness", 0.5,
			"r_gamma", 0.8);
		break;
	default:
		// TODO: find out default values for all (each might be map specific)
		self setclientdvars(
			"r_filmUseTweaks", 0,
			"r_filmTweakEnable", 0,
			"r_filmTweakBrightness", 0.5,
			"r_filmTweakDesaturation", 0.2,
			"r_filmTweakLightTint", "1.1 1.05 0.85",
			"r_filmTweakDarkTint", "0.7 0.85 1",
			"r_specularColorScale", 1,
			"r_lightTweakSunColor", "1 0.921569 0.878431 1", // differs on each map
			"r_gamma", 1,
			"r_blur", 0,
			"r_desaturation", 1,
			"r_lightTweakSunLight", 1.3 // differs on each map

		);
		break;
	}
	self iprintln("Film tweaks set to ^2" + preset);
}

toggleHUDType(type)
{
	if (!isdefined(self.meterHUD))
		self.meterHUD = [];

	// not defined means OFF
	if (!isdefined(self.meterHUD[type]))
	{
		if (type == "distance")
			self thread startDistanceHUD();
		else if (type == "speed")
			self thread startSpeedHUD();
		else if (type == "z_origin")
			self thread startZOriginHUD();
	}
	else
	{
		self notify("end_hud_" + type);
		self.meterHUD[type] destroy();
	}
}

startDistanceHUD()
{
	self endon("disconnect");
	self endon("end_hud_distance");

	fontScale = 1.4;
	x = 62;
	y = 10;

	self.meterHUD["distance"] = createFontString("small", fontScale);
	self.meterHUD["distance"] setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", x, y);
	self.meterHUD["distance"].alpha = 0.5;
	self.meterHUD["distance"].label = &"distance:&&1";

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
		self.meterHUD["distance"] setValue(distance);

		wait 0.05;
	}
}

startSpeedHUD()
{
	self endon("disconnect");
	self endon("end_hud_speed");

	fontScale = 1.4;
	x = 62;
	y = 22;
	alpha = 0.5;

	self.meterHUD["speed"] = createFontString("small", fontScale);
	self.meterHUD["speed"] setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", x, y);
	self.meterHUD["speed"].alpha = alpha;
	self.meterHUD["speed"].label = &"speed:&&1";

	for (;;)
	{
		velocity3D = self getVelocity();
		horizontalSpeed2D = int(sqrt(velocity3D[0] * velocity3D[0] + velocity3D[1] * velocity3D[1]));
		self.meterHUD["speed"] setValue(horizontalSpeed2D);

		wait 0.05;
	}
}

startZOriginHUD()
{
	self endon("disconnect");
	self endon("end_hud_z_origin");

	fontScale = 1.4;
	x = 62;
	y = 36;

	self.meterHUD["z_origin"] = createFontString("small", fontScale);
	self.meterHUD["z_origin"] setPoint("BOTTOMRIGHT", "BOTTOMRIGHT", x, y);
	self.meterHUD["z_origin"].alpha = 0.5;
	self.meterHUD["z_origin"].label = &"z:&&1";

	for (;;)
	{
		self.meterHUD["z_origin"] setValue(self.origin[2]);

		wait 0.05;
	}
}

initTestClient()
{
	testclient = addtestclient();

	if (!isdefined(testclient))
		return;

	testclient.pers["isBot"] = true;

	while (!isDefined(testclient.pers["team"]))
		wait 0.05;

	testclient [[level.axis]] ();

	wait 0.5;

	testclient.class = level.defaultClass;
	testclient.pers["class"] = level.defaultClass;
	testclient [[level.spawnClient]] ();

	wait .1;

	return testclient;
}

spawnBotAtOrigin()
{
	origin = self.origin;
	playerAngles = self getPlayerAngles();

	if (!isdefined(self.testclient))
	{
		self.testclient = initTestClient();
		if (!isdefined(self.testclient))
		{
			self iPrintLn("^1Failed to spawn bot");
			return;
		}
	}

// plugin handles bot controls
#if defined(SYSTEM_XENON)
	self.testclient freezeControls(false);
#else
	self.testclient freezeControls(true);
#endif

	for (i = 3; i > 0; i--)
	{
		self iPrintLn("Bot spawns in ^2" + i);
		wait 1;
	}

	self.testclient setOrigin(origin);
	// Face the bot the same direction the player was facing
	self.testclient setPlayerAngles((0, playerAngles[1], 0));
	// self.testclient savePos(); // Save the bot's position for auto mantle
}

kickBot()
{
	if (isdefined(self.testclient))
	{
		kick(self.testclient getEntityNumber());
		self.testclient = undefined;
	}
}

kickAllBots()
{
	for (i = 0; i < level.players.size; i++)
		if (isdefined(level.players[i].pers["isBot"]))
			kick(level.players[i] getEntityNumber());
}

position_save()
{
	if (!self isOnGround() || self isMantling())
		return;

	entry = spawnStruct();
	entry.origin = self.origin;
	entry.angles = self getPlayerAngles();

	self.cj["save_history"][self.cj["save_history"].size] = entry;

	maxEntries = 100;
	if (self.cj["save_history"].size >= maxEntries)
	{
		new_history = [];
		startIndex = self.cj["save_history"].size - maxEntries;
		for (i = 0; i < maxEntries; i++)
			new_history[i] = self.cj["save_history"][startIndex + i];

		self.cj["save_history"] = new_history;
	}
}

position_load(index)
{
	// default to the last saved position
	if (!isDefined(index))
		index = self.cj["save_history"].size - 1;

	if (self.cj["save_history"].size < 1)
	{
		self iPrintln("No saved positions");
		return;
	}

	entry = self.cj["save_history"][index];

	self freezecontrols(true);
	wait 0.05;

	if (!self isOnGround())
		wait 0.05;

	self setPlayerAngles(entry.angles);
	self setOrigin(entry.origin);

	// pull out rpg on load if RPG switch is enabled
	if (self.cj["rpg_switch"] && self.cj["rpg_switched"])
	{
		self SetWeaponAmmoClip("rpg_mp", 1);
		self switchToWeapon("rpg_mp");
		self.cj["rpg_switched"] = false;
	}

	self freezecontrols(false);
}

toggle_rpg_switch()
{
	if (self.cj["rpg_switch"])
	{
		self.cj["rpg_switch"] = false;
		self iprintln("RPG Switch OFF");
	}
	else
	{
		self.cj["rpg_switch"] = true;
		self iprintln("RPG Switch ON");
		self thread rpg_switch();
	}
}

rpg_switch()
{
	self endon("disconnect");
	// self endon("rpg_switch_stop");

	while (self.cj["rpg_switch"])
	{
		self waittill("weapon_fired");
		if (self GetCurrentWeapon() == "rpg_mp")
		{
			self.cj["rpg_switched"] = true;

			self switchToWeapon(self.cj["loadout"].sidearm);

			wait 0.05;
			// wait until the RPG is fully switched so the rocket doesn't appear in the barrel on screen
			while (self GetCurrentWeapon() == "rpg_mp")
				wait 0.05;

			self SetWeaponAmmoClip("rpg_mp", 1);
		}
	}
}

spectator_controls_on()
{
	self setClientDvar("player_view_pitch_up", 89.9);	// allow looking straight up
	self setClientDvar("player_view_pitch_down", 89.9); // allow looking straight down

	self allowSpectateTeam("freelook", true);
	self.sessionstate = "spectator";
}

spectator_controls_off()
{
	self setClientDvar("player_view_pitch_down", 70);

	self allowSpectateTeam("freelook", false);
	self.sessionstate = "playing";
}

spectator_switch_mode_active()
{
	if (self.cj["spectator_mode"] == "forge")
	{
		self.cj["spectator_mode"] = "ufo";
		wait 0.05;
		self thread ufo_start();
		self iprintln("mode: UFO");
	}
	else
	{
		self.cj["spectator_mode"] = "forge";
		wait 0.05;
		self thread forge_start();
		self iprintln("mode: Forge");
	}
}

spectator_mode_toggle()
{
	if (self.sessionstate == "playing")
	{
		self spectator_controls_on();

		if (self.cj["spectator_mode"] == "forge")
			self thread forge_start();
		else if (self.cj["spectator_mode"] == "ufo")
			self thread ufo_start();
	}
	// let each mode handle exiting
	else if (self.sessionstate == "spectator")
		self.cj["spectator_prevent_exit_requested"] = true;
}

ufo_start()
{
	self endon("disconnect");
	self endon("end_respawn");

	while (self.sessionstate == "spectator" && self.cj["spectator_mode"] == "ufo")
	{
		// Extra controls
		while (self button_pressed("use"))
		{
			self.cj["spectator_prevent_exit_requested"] = false;
			// freeze controls to allow meleebuttonpressed while in spectator
			self freezecontrols(true);
			// Switch mode
			if (self button_pressed("melee"))
			{
				self spectator_switch_mode_active();
				wait 0.1;
			}

			else if (self button_pressed("smoke"))
				self setplayerangles(self getPlayerAngles() - (0, 0, 1));
			else if (self button_pressed("frag"))
				self setplayerangles(self getPlayerAngles() + (0, 0, 1));

			wait 0.05;
		}
		if (!self.cj["menu_open"])
			self freezecontrols(false);

		if (button_pressed("smoke"))
		{
			self cycle_spectator_speed();
			wait 0.1;
		}
		if (self.cj["spectator_prevent_exit_requested"])
		{
			self.cj["spectator_prevent_exit_requested"] = false;
			self spectator_controls_off();
			return;
		}

		wait 0.05;
	}
}

cycle_spectator_speed()
{
	self.cj["spectator_speed_index"] += 1;
	if (self.cj["spectator_speed_index"] >= level.SPECTATOR_SPEEDS.size)
		self.cj["spectator_speed_index"] = 0;

	speed = level.SPECTATOR_SPEEDS[self.cj["spectator_speed_index"]];
	self setClientDvar("player_spectateSpeedScale", speed);
	msg = "player_spectateSpeedScale " + speed;
	if (speed == 1)
		msg += " (default)";

	self iprintln(msg);
}

// getForgeInstructionsText(state)
// {
// 	instructions = [];

// 	if (!isdefined(state))
// 	{
// 		instructions[instructions.size] = "[{+activate}] Hold for more options";
// 		instructions[instructions.size] = "[{+smoke}] Change speed";
// 		instructions[instructions.size] = "[{+frag}] Exit";
// 	}
// 	else if (state == "FOCUSED")
// 	{
// 		instructions[instructions.size] = "[{+activate}] Hold for more options";
// 		instructions[instructions.size] = "[{+smoke}] Decrease";
// 		instructions[instructions.size] = "[{+frag}] Increase";
// 	}
// 	else if (state == "HOLD_X")
// 	{
// 		instructions[instructions.size] = "[{+smoke}] Next mode";
// 		instructions[instructions.size] = "[{+frag}] Prev mode";

// 		instructions[instructions.size] = "[{+speed_throw}] Exit Forge";
// 		instructions[instructions.size] = "[{+attack}] Pick up/Drop";
// 		if (level.xenon)
// 			instructions[instructions.size] = "[{+breath_sprint}] Clone object";

// 		instructions[instructions.size] = "[{+melee}] Switch to UFO mode";
// 	}

// 	instructionsString = "";
// 	for (i = 0; i < instructions.size; i++)
// 		instructionsString += instructions[i] + "\n";

// 	return instructionsString;
// }

forge_start()
{
	self.forge_hud = [];
	self.forge_hud["instructions"] = createFontString("default", 1.4);
	self.forge_hud["instructions"] setPoint("TOPLEFT", "TOPLEFT", -30, -20);
	self.forge_hud["instructions"] setText("");

	x = 30;

	self.forge_hud["entities"] = createFontString("default", 1.4);
	self.forge_hud["entities"] setPoint("TOPRIGHT", "TOPRIGHT", x, -20);
	self.forge_hud["entities"].label = &"entities (1000 max): &&1";
	self.forge_hud["entities"] SetValue(getentarray().size);

	self.forge_hud["mode"] = createFontString("default", 1.4);
	self.forge_hud["mode"] setPoint("TOPRIGHT", "TOPRIGHT", x, 0);
	self.forge_hud["mode"] setText("mode: " + level.FORGE_CHANGE_MODES[self.cj["forge_change_mode_index"]]);
	self.forge_hud["mode"].alpha = 1;

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

	unfocusedColor = (0.5, 0.5, 0.5); // gray for unfocused
	focusedColor = (0, 1, 0);		  // green for focused
	pickedUpColor = (1, 0, 0);		  // red for picked up

	while (self.sessionstate == "spectator" && self.cj["spectator_mode"] == "forge")
	{
		self.forge_hud["entities"] SetValue(getentarray().size);
		self.forge_hud["mode"] setText("mode: " + level.FORGE_CHANGE_MODES[self.cj["forge_change_mode_index"]]);

		if (isdefined(self.cj["forge_focused_ent"]))
		{
			self.forge_hud["pitch"] SetValue(self.cj["forge_focused_ent"].angles[0]);
			self.forge_hud["yaw"] SetValue(self.cj["forge_focused_ent"].angles[1]);
			self.forge_hud["roll"] SetValue(self.cj["forge_focused_ent"].angles[2]);
			self.forge_hud["x"] SetValue(self.cj["forge_focused_ent"].origin[0]);
			self.forge_hud["y"] SetValue(self.cj["forge_focused_ent"].origin[1]);
			self.forge_hud["z"] SetValue(self.cj["forge_focused_ent"].origin[2]);

			self.forge_hud["pitch"].alpha = 1;
			self.forge_hud["yaw"].alpha = 1;
			self.forge_hud["roll"].alpha = 1;
			self.forge_hud["x"].alpha = 1;
			self.forge_hud["y"].alpha = 1;
			self.forge_hud["z"].alpha = 1;
		}
		else
		{
			self.forge_hud["pitch"].alpha = 0;
			self.forge_hud["yaw"].alpha = 0;
			self.forge_hud["roll"].alpha = 0;
			self.forge_hud["x"].alpha = 0;
			self.forge_hud["y"].alpha = 0;
			self.forge_hud["z"].alpha = 0;
		}

		if (!isdefined(self.cj["forge_pickedup_ent"]))
		{
			forward = anglestoforward(self getplayerangles());
			eye = self.origin + (0, 0, 10);
			start = eye;
			end = common_scripts\utility::vectorscale(forward, 9999);
			trace = bullettrace(start, start + end, true, self);
			if (isdefined(trace["entity"]))
			{
				ent = trace["entity"];
				self.forge_hud["reticle"].color = focusedColor;
				if (isdefined(ent.forge_parent))
					ent = ent.forge_parent;

				self.cj["forge_focused_ent"] = ent;
			}
			else
			{
				self.forge_hud["reticle"].color = unfocusedColor;
				self.cj["forge_focused_ent"] = undefined;
			}
		}
		else
		{
			self.forge_hud["reticle"].color = pickedUpColor;
		}

		while (self button_pressed("use"))
		{
			// freeze controls to allow using melee, attack and ads buttons while in spectator
			self freezecontrols(true);

			// pick up or drop ent
			if (!isdefined(self.cj["forge_pickedup_ent"]) && isdefined(self.cj["forge_focused_ent"]) && self button_pressed("attack"))
			{
				ent = self.cj["forge_focused_ent"];
				ent linkto(self);
				self.cj["forge_pickedup_ent"] = self.cj["forge_focused_ent"];
				self iprintln("Picked up " + getdisplayname(ent));
				wait 0.25;
				break;
			}
			else if (isdefined(self.cj["forge_pickedup_ent"]) && self button_pressed("attack"))
			{
				ent = self.cj["forge_pickedup_ent"];
				ent unlink();
				ent.origin = maps\mp\gametypes\sab::flat_origin(ent.origin); // snap to whole numbers
				self.cj["forge_pickedup_ent"] = undefined;
				self iprintln("Dropped " + getdisplayname(ent));
				wait 0.25;
				break;
			}

			wait 0.05;
		}
		if (!self.cj["menu_open"])
			self freezecontrols(false);

		if (!isdefined(self.cj["forge_focused_ent"]) && !isdefined(self.cj["forge_pickedup_ent"]) && (self button_pressed("smoke") || self button_pressed("frag")))
		{
			self.cj["spectator_prevent_exit_requested"] = false; // override exit request from frag button press
			if (self button_pressed("smoke"))
				self forge_change_mode("prev");
			else if (self button_pressed("frag"))
				self forge_change_mode("next");
			wait 0.1;
		}

		if (self.cj["spectator_prevent_exit_requested"])
		{

			if (isdefined(self.cj["forge_focused_ent"]))
			{
				// do nothing
			}
			else if (isdefined(self.cj["forge_pickedup_ent"]))
				self iprintln("Can't exit while holding an object");
			else
			{
				self.cj["spectator_prevent_exit_requested"] = false;
				self spectator_controls_off();
				return;
			}
		}

		wait 0.05;
	}

	self forge_hud_destroy();
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

forge_hud_destroy()
{
	huds = getarraykeys(self.forge_hud);
	for (i = 0; i < huds.size; i++)
		if (isdefined(self.forge_hud[huds[i]]))
			self.forge_hud[huds[i]] destroy();
}

forge_change_mode(action)
{
	action = tolower(action);
	index = self.cj["forge_change_mode_index"];
	if (action == "prev")
		index -= 1;
	else if (action == "next")
		index += 1;

	if (index >= level.FORGE_CHANGE_MODES.size)
		index = 0;
	else if (index < 0)
		index = level.FORGE_CHANGE_MODES.size - 1;

	self.cj["forge_change_mode_index"] = index;
}
