public MenuHandler_Skills(Handle:menu, MenuAction:action, param1, param2) 
{
	if (action == MenuAction_Select) 
	{ 
		new credits=GetClientCredits(param1); 
		switch (param2) 
		{ 
			case 1: //hp
			{
				if(credits < hpcost) 
					PrintToChat(param1, "[711] Insufficient credits"); 
				if(Health[param1] == hp_max_level) 
					PrintToChat(param1, "[711] Max level reached"); 
				if(credits >= hpcost && Health[param1] < hp_max_level) 
				{ 
					Health[param1]++; 
					UserHealth(param1); 
					SetClientCredits(param1, (credits -= hpcost)); 
					PrintToChat(param1, "[711] HP increased"); 
				} 
				Menu_Skills(param1); 
			}
			case 2: //armor
			{ 
				if(credits < armorcost) 
					PrintToChat(param1, "[711] Insufficient credits"); 
				if(Armor[param1] == armor_max_level) 
					PrintToChat(param1, "[711] Max level reached"); 
				if((credits) >= armorcost && Armor[param1] < armor_max_level) 
				{ 
					Armor[param1]++; 
					UserArmor(param1); 
					SetClientCredits(param1, (credits -= armorcost)); 
					PrintToChat(param1, "[711] Armor increased"); 
				} 
				Menu_Skills(param1); 
			} 
			case 3: //speed
			{ 
				if(credits < speedcost) 
					PrintToChat(param1, "[711] Insufficient credits"); 
				if(SpeedLevel[param1] == speed_max_level) 
					PrintToChat(param1, "[711] Max level reached"); 
				if(credits >= speedcost && SpeedLevel[param1] < speed_max_level) 
				{ 
					SpeedLevel[param1]++; 
					UserSpeed(param1); 
					SetClientCredits(param1, (credits -= speedcost)); 
					PrintToChat(param1, "[711] You now run faster"); 
				} 
				Menu_Skills(param1); 
			} 
			case 4: //gravity
			{ 
				if(credits < gravitycost) 
					PrintToChat(param1, "[711] Insufficient credits"); 
				if(Gravity[param1] == gravity_max_level) 
					PrintToChat(param1, "[711] Max level reached"); 
				if(credits >= gravitycost && Gravity[param1] < gravity_max_level) 
				{ 
					Gravity[param1]++; 
					UserGravity(param1); 
					SetClientCredits(param1, (credits -= gravitycost)); 
					PrintToChat(param1, "[711] You now jump higher"); 
				} 
				Menu_Skills(param1); 
			} 
			case 5: //Multijump
			{ 
				if(credits < multijumpcost) 
					PrintToChat(param1, "[711] Insufficient credits"); 
				if(multijump[param1] == multijump_max_level) 
					PrintToChat(param1, "[711] Max level reached"); 
				if(credits >= multijumpcost && multijump[param1] < multijump_max_level) 
				{ 
					multijump[param1]++; 
					SetClientCredits(param1, (credits -= multijumpcost)); 
					PrintToChat(param1, "[711] You now can jump in the air %i times",multijump[param1]/1); 
				} 
				Menu_Skills(param1); 
			}
			case 6: //Power
			{ 
				if(credits < powercost) 
					PrintToChat(param1, "[711] Insufficient credits"); 
				if(Power[param1] == power_max_level) 
					PrintToChat(param1, "[711] Max level reached"); 
				if(credits >= powercost && Power[param1] < power_max_level) 
				{ 
					Power[param1]++; 
					SetClientCredits(param1, (credits -= powercost)); 
					PrintToChat(param1, "[711] You now deal more damage"); 
				} 
				Menu_Skills(param1); 
			}
			case 7: //HP Consumer
			{ 
				if(credits < hptakercost) 
					PrintToChat(param1, "[711] Insufficient credits"); 
				if(Hptaker[param1] == hptaker_max_level) 
					PrintToChat(param1, "[711] Max level reached"); 
				if(credits >= hptakercost && Hptaker[param1] < hptaker_max_level) 
				{ 
					Hptaker[param1]++; 
					SetClientCredits(param1, (credits -= hptakercost)); 
					PrintToChat(param1, "[711] %i HP added per kill", (5*Hptaker[param1])); 
				} 
				Menu_Skills(param1); 
			}
			default: //cancel
			{ 
				return; 
			}     
		} 
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu); 
	} 
} 




public UserArmor(client) 
{ 
    new iap = (Armor[client] * armorperbuy); 
    Client_SetArmor(client, 100 + iap); 
    return; 
} 

public UserHealth(client)  
{ 
    new ihp = ((Health[client] * hpperbuy)+100); 
    SetEntData(client, FindDataMapOffs(client, "m_iHealth"), ihp, 4, true); 
    return; 
} 

public UserSpeed(client) 
{ 
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", (speedperbuy*SpeedLevel[client])+1); 
    return; 
} 

public UserGravity(client) 
{ 
    SetEntityGravity(client, 1 - Gravity[client] * gravityperbuy); 
    return; 
} 





public OnGameFrame()  
{ 
    if (g_bDoubleJump)  
    { 
        for (new i = 1; i <= MaxClients; i++)  
        { 
            if (IsClientInGame(i) && IsPlayerAlive(i))  
            { 
                DoubleJump(i); 
            } 
        } 
    } 
} 

stock DoubleJump(const any:client)  
{ 
    new fCurFlags = GetEntityFlags(client), fCurButtons    = GetClientButtons(client); 
     
    if (g_fLastFlags[client] & FL_ONGROUND)  
    {         
        if (!(fCurFlags & FL_ONGROUND) && !(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP) 
        { 
            OriginalJump(client); 
        } 
    }  
    else if (fCurFlags & FL_ONGROUND)  
    { 
        Landed(client); 
    }  
    else if (!(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP)  
    { 
        ReJump(client); 
    } 
     
    g_fLastFlags[client]    = fCurFlags    ; 
    g_fLastButtons[client]    = fCurButtons; 
} 

stock OriginalJump(const any:client) { 
    jumpnum[client]++; 
} 

stock Landed(const any:client) { 
    jumpnum[client] = 0; 
} 

stock ReJump(const any:client)  
{ 
    if ( 1 <= jumpnum[client] <= multijump[client])  
    { 
        jumpnum[client]++; 
        decl Float:vVel[3]; 
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel); 
         
        vVel[2] = g_flBoost; 
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel); 
    } 
} 