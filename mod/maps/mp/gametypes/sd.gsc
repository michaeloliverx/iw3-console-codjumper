#include maps\mp\gametypes\_hud_util;

/**
 * Check if a button is pressed.
 */
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
#if defined(SYSTEM_XENON)
	case "holdbreath":
		return self holdbreathbuttonpressed();
#endif
	case "melee":
		return self meleebuttonpressed();
	case "nightvision":
		return isdefined(self.nightVisionButtonPressedTime) && (getTime() - self.nightVisionButtonPressedTime < 200);
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
 * Check if a button is pressed twice within 500ms.
 */
button_pressed_twice(button)
{
	if (self button_pressed(button))
	{
		// Wait for the button to be released after the first press
		while (self button_pressed(button))
		{
			wait 0.05;
		}

		// Now, wait for a second press within 500ms
		for (elapsed_time = 0; elapsed_time < 0.5; elapsed_time += 0.05)
		{
			if (self button_pressed(button))
			{
				// Ensure it was released before this second press
				return true;
			}

			wait 0.05;
		}
	}
	return false;
}

/**
 * Normalize RGB values (0-255) to (0-1).
 */
rgbToNormalized(rgb)
{
	return (rgb[0] / 255, rgb[1] / 255, rgb[2] / 255);
}

get_themes()
{
	themes = [];

	themes["blue"] = rgbToNormalized((0, 0, 255));
	themes["brown"] = rgbToNormalized((139, 69, 19));
	themes["cyan"] = rgbToNormalized((0, 255, 255));
	themes["gold"] = rgbToNormalized((255, 215, 0));
	themes["green"] = rgbToNormalized((0, 208, 98));
	themes["lime"] = rgbToNormalized((0, 255, 0));
	themes["magenta"] = rgbToNormalized((255, 0, 255));
	themes["maroon"] = rgbToNormalized((128, 0, 0));
	themes["olive"] = rgbToNormalized((128, 128, 0));
	themes["orange"] = rgbToNormalized((255, 165, 0));
	themes["pink"] = rgbToNormalized((255, 25, 127));
	themes["purple"] = rgbToNormalized((90, 0, 208));
	themes["red"] = rgbToNormalized((255, 0, 0));
	themes["salmon"] = rgbToNormalized((250, 128, 114));
	themes["silver"] = rgbToNormalized((192, 192, 192));
	themes["skyblue"] = rgbToNormalized((0, 191, 255));
	themes["tan"] = rgbToNormalized((210, 180, 140));
	themes["teal"] = rgbToNormalized((0, 128, 128));
	themes["turquoise"] = rgbToNormalized((64, 224, 208));
	themes["violet"] = rgbToNormalized((238, 130, 238));
	themes["yellow"] = rgbToNormalized((255, 255, 0));

	return themes;
}

get_dvars()
{
	dvars = [];

	// Alphabetically sorted by key
	dvars["bg_bobMax"] = spawnstruct();
	dvars["bg_bobMax"].type = "slider";
	dvars["bg_bobMax"].name = "bg_bobMax";
	dvars["bg_bobMax"].default_value = 8;
	dvars["bg_bobMax"].min = 0;
	dvars["bg_bobMax"].max = 36;
	dvars["bg_bobMax"].step = 1;

	dvars["cg_drawGun"] = spawnstruct();
	dvars["cg_drawGun"].type = "boolean";
	dvars["cg_drawGun"].name = "cg_drawGun";
	dvars["cg_drawGun"].default_value = 1;

	dvars["cg_drawSpectatorMessages"] = spawnstruct();
	dvars["cg_drawSpectatorMessages"].type = "boolean";
	dvars["cg_drawSpectatorMessages"].name = "cg_drawSpectatorMessages";
	dvars["cg_drawSpectatorMessages"].default_value = 1;

	dvars["cg_fov"] = spawnstruct();
	dvars["cg_fov"].type = "slider";
	dvars["cg_fov"].name = "cg_fov";
	dvars["cg_fov"].default_value = 65;
	dvars["cg_fov"].min = 65;
	dvars["cg_fov"].max = 90;
	dvars["cg_fov"].step = 1;

	dvars["cg_fovScale"] = spawnstruct();
	dvars["cg_fovScale"].type = "slider";
	dvars["cg_fovScale"].name = "cg_fovScale";
	dvars["cg_fovScale"].default_value = 1;
	dvars["cg_fovScale"].min = 0.2;
	dvars["cg_fovScale"].max = 2;
	dvars["cg_fovScale"].step = 0.1;

	dvars["cg_thirdPerson"] = spawnstruct();
	dvars["cg_thirdPerson"].type = "boolean";
	dvars["cg_thirdPerson"].name = "cg_thirdPerson";
	dvars["cg_thirdPerson"].default_value = 0;

	dvars["cg_thirdPersonAngle"] = spawnstruct();
	dvars["cg_thirdPersonAngle"].type = "slider";
	dvars["cg_thirdPersonAngle"].name = "cg_thirdPersonAngle";
	dvars["cg_thirdPersonAngle"].default_value = 356;
	dvars["cg_thirdPersonAngle"].min = -180;
	dvars["cg_thirdPersonAngle"].max = 360;
	dvars["cg_thirdPersonAngle"].step = 1;

	dvars["cg_thirdPersonRange"] = spawnstruct();
	dvars["cg_thirdPersonRange"].type = "slider";
	dvars["cg_thirdPersonRange"].name = "cg_thirdPersonRange";
	dvars["cg_thirdPersonRange"].default_value = 120;
	dvars["cg_thirdPersonRange"].min = 0;
	dvars["cg_thirdPersonRange"].max = 1024;
	dvars["cg_thirdPersonRange"].step = 1;

	dvars["jump_slowdownEnable"] = spawnstruct();
	dvars["jump_slowdownEnable"].scope = "global";
	dvars["jump_slowdownEnable"].type = "boolean";
	dvars["jump_slowdownEnable"].name = "jump_slowdownEnable";
	dvars["jump_slowdownEnable"].default_value = 1;

	dvars["r_blur"] = spawnstruct();
	dvars["r_blur"].type = "slider";
	dvars["r_blur"].name = "r_blur";
	dvars["r_blur"].default_value = 0;
	dvars["r_blur"].min = 0;
	dvars["r_blur"].max = 32;
	dvars["r_blur"].step = 0.2;

	dvars["r_dof_enable"] = spawnstruct();
	dvars["r_dof_enable"].type = "boolean";
	dvars["r_dof_enable"].name = "r_dof_enable";
	dvars["r_dof_enable"].default_value = 1;

	dvars["r_fog"] = spawnstruct();
	dvars["r_fog"].type = "boolean";
	dvars["r_fog"].name = "r_fog";
	dvars["r_fog"].default_value = 1;

	dvars["r_fullbright"] = spawnstruct();
	dvars["r_fullbright"].type = "boolean";
	dvars["r_fullbright"].name = "r_fullbright";
	dvars["r_fullbright"].default_value = 0;

	dvars["r_zfar"] = spawnstruct();
	dvars["r_zfar"].type = "slider";
	dvars["r_zfar"].name = "r_zfar";
	dvars["r_zfar"].default_value = 0;
	dvars["r_zfar"].min = 0;
	dvars["r_zfar"].max = 4000;
	dvars["r_zfar"].step = 500;

	return dvars;
}

get_saved_client_dvar(dvar, default_value)
{
	value = self.cj["dvars"][dvar];
	if (!isdefined(value))
		return default_value;
	else
		return value;
}

set_saved_client_dvar(dvar, value)
{
	self.cj["dvars"][dvar] = value;
	self setClientDvar(dvar, value);

	default_value = undefined;
	if (isdefined(level.DVARS[dvar]))
		default_value = level.DVARS[dvar].default_value;

	msg = dvar + ": " + value;
	if (value == default_value)
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
slider_start(dvar)
{
	self endon("disconnect");
	self endon("end_respawn");

	// self menuAction("CLOSE");

	if (!isDvarStructValid(dvar) || dvar.type != "slider")
	{
		self iprintln("^1dvar struct is invalid");
		return;
	}

	if (!isdefined(self.cj["slider_hud"]))
		self.cj["slider_hud"] = [];
	else
		self slider_hud_destroy();

	// call this on a fresh game to get the default value
	// self iprintln("DEFAULT GAME VALUE " + dvar.name + " " + getdvar(dvar.name));

	// -- Background
	backgroundWidth = level.SCREEN_MAX_WIDTH;
	backgroundHeight = 50;
	centerYPosition = (level.SCREEN_MAX_HEIGHT - backgroundHeight) / 2;

	self.cj["slider_hud"]["background"] = newClientHudElem(self);
	self.cj["slider_hud"]["background"].elemType = "icon";
	self.cj["slider_hud"]["background"].color = (0, 0, 0);
	self.cj["slider_hud"]["background"].alpha = 0.5;
	self.cj["slider_hud"]["background"] setShader("white", backgroundWidth, backgroundHeight);
	self.cj["slider_hud"]["background"].x = 0;
	self.cj["slider_hud"]["background"].y = centerYPosition;
	self.cj["slider_hud"]["background"].alignX = "left";
	self.cj["slider_hud"]["background"].alignY = "top";
	self.cj["slider_hud"]["background"].horzAlign = "fullscreen";
	self.cj["slider_hud"]["background"].vertAlign = "fullscreen";

	// -- Rail
	railWidth = int(level.SCREEN_MAX_WIDTH * 0.75);
	railHeight = 4;
	centerXPosition = (level.SCREEN_MAX_WIDTH - railWidth) / 2;
	centerYPosition = (level.SCREEN_MAX_HEIGHT - railHeight) / 2;

	self.cj["slider_hud"]["rail"] = newClientHudElem(self);
	self.cj["slider_hud"]["rail"].elemType = "icon";
	self.cj["slider_hud"]["rail"].alpha = 0.75;
	self.cj["slider_hud"]["rail"] setShader("white", railWidth, railHeight);
	self.cj["slider_hud"]["rail"].x = centerXPosition;
	self.cj["slider_hud"]["rail"].y = centerYPosition;
	self.cj["slider_hud"]["rail"].alignX = "left";
	self.cj["slider_hud"]["rail"].alignY = "top";
	self.cj["slider_hud"]["rail"].horzAlign = "fullscreen";
	self.cj["slider_hud"]["rail"].vertAlign = "fullscreen";

	// -- Cursor
	cursorWidth = 3;
	cursorHeight = int(backgroundHeight / 2);
	// Start position aligned with the beginning of the rail
	cursorStartXPosition = centerXPosition; // This aligns it to the start of the rail
	// Centered vertically with respect to the rail
	cursorYPosition = centerYPosition - (cursorHeight - railHeight) / 2;

	self.cj["slider_hud"]["cursor"] = newClientHudElem(self);
	self.cj["slider_hud"]["cursor"].elemType = "icon";
	self.cj["slider_hud"]["cursor"].color = self.themeColor; // Use the theme color
	self.cj["slider_hud"]["cursor"].alpha = 0;				 // Hide the cursor initially
	self.cj["slider_hud"]["cursor"] setShader("white", cursorWidth, cursorHeight);
	self.cj["slider_hud"]["cursor"].x = cursorStartXPosition;
	self.cj["slider_hud"]["cursor"].y = cursorYPosition;
	self.cj["slider_hud"]["cursor"].alignX = "left";
	self.cj["slider_hud"]["cursor"].alignY = "top";
	self.cj["slider_hud"]["cursor"].horzAlign = "fullscreen";
	self.cj["slider_hud"]["cursor"].vertAlign = "fullscreen";

	dvarValue = self get_saved_client_dvar(dvar.name, dvar.default_value);

	// Initialize cursor position based on the default dvar value
	updateCursorPosition(dvar, dvarValue, self.cj["slider_hud"]["cursor"], centerXPosition, railWidth, cursorWidth);

	self.cj["slider_hud"]["cursor"].alpha = 1; // Show the cursor after it has been positioned

	self.cj["slider_hud"]["value"] = createFontString("default", 3);
	self.cj["slider_hud"]["value"] setPoint("CENTER", "CENTER", 0, -50);
	self.cj["slider_hud"]["value"] SetValue(dvarValue);

	for (;;)
	{
		if (self fragbuttonpressed() || self secondaryoffhandbuttonpressed())
		{
			if (self fragbuttonpressed())
			{
				dvarValue += dvar.step;
				if (dvarValue > dvar.max)
					dvarValue = dvar.min; // Wrap around to min
			}
			else if (self secondaryoffhandbuttonpressed())
			{
				dvarValue -= dvar.step;
				if (dvarValue < dvar.min)
					dvarValue = dvar.max; // Wrap around to max
			}

			updateCursorPosition(dvar, dvarValue, self.cj["slider_hud"]["cursor"], centerXPosition, railWidth, cursorWidth);
			self.cj["slider_hud"]["value"] SetValue(dvarValue);
			self set_saved_client_dvar(dvar.name, dvarValue);

			wait 0.05; // Prevent rapid firing
		}
		else if (self meleebuttonpressed())
		{
			self set_saved_client_dvar(dvar.name, dvarValue);
			self slider_hud_destroy();

			// self menuAction("OPEN");
			return;
		}

		wait 0.05;
	}
}

slider_hud_destroy()
{
	if (!isdefined(self.cj["slider_hud"]))
		return;
	keys = getarraykeys(self.cj["slider_hud"]);
	for (i = 0; i < keys.size; i++)
	{
		if (isdefined(self.cj["slider_hud"][keys[i]]))
			self.cj["slider_hud"][keys[i]] destroy();
	}
}

toggle_boolean_dvar(dvar)
{
	if (!isDvarStructValid(dvar) || dvar.type != "boolean")
	{
		self iprintln("^1dvar struct is invalid");
		return;
	}

	dvarValue = self get_saved_client_dvar(dvar.name, dvar.default_value);

	if (dvarValue == 0)
		self set_saved_client_dvar(dvar.name, 1);
	else
		self set_saved_client_dvar(dvar.name, 0);
}

reset_all_client_dvars()
{
	dvars = getarraykeys(level.DVARS);
	for (i = 0; i < dvars.size; i++)
	{
		dvar = level.DVARS[dvars[i]];
		self set_saved_client_dvar(dvar.name, dvar.default_value);
	}
}
