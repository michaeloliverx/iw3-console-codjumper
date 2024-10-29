main()
{
	maps\mp\gametypes\war::main();
}

initCJ()
{
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	for (;;)
	{
		self waittill("spawned_player");
	}
}
