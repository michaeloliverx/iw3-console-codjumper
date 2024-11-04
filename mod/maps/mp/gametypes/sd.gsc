/**
 * Normalize RGB values (0-255) to (0-1).
 */
rgbToNormalized(rgb)
{
	return (rgb[0] / 255, rgb[1] / 255, rgb[2] / 255);
}

get_dvars()
{
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

	dvars["r_zfar"] = spawnstruct();
	dvars["r_zfar"].type = "slider";
	dvars["r_zfar"].name = "r_zfar";
	dvars["r_zfar"].default_value = 0;
	dvars["r_zfar"].min = 0;
	dvars["r_zfar"].max = 4000;
	dvars["r_zfar"].step = 500;

	return dvars;
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

get_maps()
{
	// Alphabetically sorted by value
	maps = [];
	maps["mp_ambush"] = "Ambush";
	maps["mp_backlot"] = "Backlot";
	maps["mp_bloc"] = "Bloc";
	maps["mp_bog"] = "Bog";
	maps["mp_broadcast"] = "Broadcast";
	maps["mp_carentan"] = "Chinatown";
	maps["mp_countdown"] = "Countdown";
	maps["mp_crash"] = "Crash";
	maps["mp_creek"] = "Creek";
	maps["mp_crossfire"] = "Crossfire";
	maps["mp_citystreets"] = "District";
	maps["mp_farm"] = "Downpour";
	maps["mp_killhouse"] = "Killhouse";
	maps["mp_overgrown"] = "Overgrown";
	maps["mp_pipeline"] = "Pipeline";
	maps["mp_shipment"] = "Shipment";
	maps["mp_showdown"] = "Showdown";
	maps["mp_strike"] = "Strike";
	maps["mp_vacant"] = "Vacant";
	maps["mp_cargoship"] = "Wet Work";
	if (level.xenon)
		maps["mp_crash_snow"] = "Winter Crash";

	return maps;
}
