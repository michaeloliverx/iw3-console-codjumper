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
