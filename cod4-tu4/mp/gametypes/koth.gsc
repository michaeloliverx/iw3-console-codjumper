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

activeGameObjectRotatePitch()
{
	self.activeGameObject rotatepitch(5, 0.1);
}

activeGameObjectRotateRoll()
{
	self.activeGameObject rotateroll(90, 0.1);
}

activeGameObjectRotateYaw()
{
	self.activeGameObject rotateyaw(90, 0.1);
}

forgeMode() {
	self endon("death");
	self endon("disconnect");
	self endon("stop_forge");

	for (;;) {
		while (self adsbuttonpressed())
		{
			trace = bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglestoforward(self getplayerangles()) * 1000000, true, self);
			while (self adsbuttonpressed())
			{
				// for players/bots
				trace["entity"] setorigin(self gettagorigin("j_head") + anglestoforward(self getplayerangles()) * 150);
				// for game objects
				trace["entity"].origin = self gettagorigin("j_head") + anglestoforward(self getplayerangles()) * 150;
				wait 0.05;
			}
		}
		wait 0.05;
	}
}

toggleForgeMode() {
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
