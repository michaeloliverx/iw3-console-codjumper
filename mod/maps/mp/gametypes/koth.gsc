#include maps\mp\gametypes\_hud_util;

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
			"r_filmTweakEnable", 0);
		break;
	}
	self iprintln("Film tweaks set to ^2" + preset);
}

toggleDistanceMeasurementHUD()
{
	// self notify("end_distance_measurement");

	if (!isdefined(self.meterHUD))
		self.meterHUD = [];

	if (!isdefined(self.meterHUD["distance"]))
	{
		self thread startDistanceMeasurement();
	}
	else
	{
		self notify("end_distance_measurement");
		self.meterHUD["distance"] destroy();
	}
}

startDistanceMeasurement()
{
	self endon("disconnect");
	self endon("end_respawn");
	// self endon("end_distance_measurement");

	fontScale = 1.4;
	x = 62;
	y = 36;

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
