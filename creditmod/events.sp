public OnClientPutInServer(client)  
{ 
    if (!IsValidClient(client)) 
        return; 
     
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
    CreditTimer[client] = CreateTimer(300.0, AutoCredit, client, TIMER_REPEAT); 
} 

public OnClientDisconnect(client) 
{ 
    Armor[client] = 0; 
    Health[client] = 0; 
    Gravity[client] = 0; 
    SpeedLevel[client] = 0; 
    Realarmor[client] = 0; 
    Hptaker[client] = 0; 
    Power[client] = 0; 
    multijump[client] = 0; 
    jumpnum[client] = 0; 
     
    if (CreditTimer[client] != INVALID_HANDLE) 
    { 
        KillTimer(CreditTimer[client]); 
        CreditTimer[client] = INVALID_HANDLE; 
    } 
} 

public event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	CreateTimer(0.1, timer_PlayerSpawn, client); 
	SpawnProtection[client] = true;
	CreateTimer(3.0, timer_protectionOff, client);
} 

/*public event_roundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
    CreateTimer(0.1, NewRound); 
}

public Action:NewRound(Handle:hTimer) 
{
	for (new i = 1; i <= MaxClients; i++) 
	{ 
		if(IsValidClient(i))
		{ 
			if(Armor[i] > armor_max_level) Armor[i] = armor_max_level; 
			if(Health[i] > hp_max_level) Health[i] = hp_max_level; 
			if(Gravity[i] > gravity_max_level) Gravity[i] = gravity_max_level; 
			if(Hptaker[i] > hptaker_max_level) Hptaker[i] = hptaker_max_level; 
			if(Power[i] > power_max_level) Power[i] = power_max_level; 
			if(multijump[i] > multijump_max_level) multijump[i] = multijump_max_level;         
		} 
		if(IsPlayerAlive(i)) 
		{ 
			if(Armor[i] > 0) 
			{ 
				UserArmor(i); 
			} 
			if(Health[i] > 0) 
			{ 
				UserHealth(i); 
			} 
			if(Gravity[i] > 0) 
			{ 
				UserGravity(i); 
			} 
		} 
	} 
	return Plugin_Continue; 
} */

public Action:timer_PlayerSpawn(Handle:timer, any:client) 
{
	if (IsValidClient(client))
	{
		SetEntData(client, FindDataMapOffs(client, "m_iMaxHealth"), 500, 4, true); 
		UserHealth(client);
		UserArmor(client);
		UserGravity(client);
		UserSpeed(client);
	}
} 

public Action:timer_protectionOff(Handle:timer, any:client) 
{
	if (IsValidClient(client))
	{
		SpawnProtection[client] = false;
	}
}

public event_itemEquip(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
    new client = GetClientOfUserId(GetEventInt(event, "userid")); 
    if ((client>0) && IsClientInGame(client)) 
    { 
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", (speedperbuy*SpeedLevel[client])+1); 
    } 
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3]) 
{
	if (SpawnProtection[client] == true)
		return Plugin_Handled;
		
	if (attacker > 0 && attacker < MAXPLAYERS && IsClientInGame(attacker) && Power[attacker] > 0 && IsPlayerAlive(client)) 
	{ 
		damage *= ((0.03 * Power[attacker])+1); 
		return Plugin_Changed; 
	} 
	return Plugin_Continue; 
}

public Action:event_death(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	if (Hptaker[attacker] > 0) 
    { 
        if (GetEventBool(event, "headshot")==true) 
        { 
            new hp=((10*Hptaker[attacker])+GetClientHealth(attacker)); 
            SetEntData(attacker, FindDataMapOffs(attacker, "m_iHealth"), hp, 4, true); 
        } 
        else 
        { 
            new hp=((5*Hptaker[attacker])+GetClientHealth(attacker)); 
            SetEntData(attacker, FindDataMapOffs(attacker, "m_iHealth"), hp, 4, true); 
		} 
	}
	CreateTimer(2.0, RespawnPlayer, client);
	return Plugin_Continue; 
}

public Action:Event_OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	if(client <= 0 || !IsClientInGame(client)) 
		return Plugin_Continue; 
	CreateTimer(2.0, RespawnPlayer, client);
	return Plugin_Continue; 
} 

public Action:RespawnPlayer(Handle:timer, any:client) 
{
	if (!IsValidClient(client))
		return;
	CS_RespawnPlayer(client);
}