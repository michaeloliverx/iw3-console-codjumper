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
