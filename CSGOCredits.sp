#pragma semicolon 1 
#include <sourcemod> 
#include <sdktools> 
#include <sdkhooks> 
#include <nextmap> 
#include <clientprefs> 
#include <sdkhooks> 
#include <smlib>
#include <cstrike>

#define PLUGIN_VERSION "1.1" 

/////////////////////////////////Credits////////////////////////////////// 
//Amount of credits new players get 
#define numnewcredits 5 
//Time Per Credit (in seconds) Edit line xxx from 300.0 to the desired value. 
#define credittime 300.0 


////////////////////////////Costs///////////////////////////////////////// 

#define teleroofcost 2 
#define teleskywalkcost 2 
#define teletowercost 2 
#define teleledgecost 2 

#define telehoestagecost 7 
#define televentscost 7 
#define telestairscost 7 
#define telemiddlecost 3 

#define maxitems 20 
#define maxcredits 500 

#define armorcost 1 
#define hpcost 4 
#define gravitycost 2 
#define multijumpcost 1 

#define realarmorcost 4 
#define hptakercost 4 
#define powercost 4 
#define speedcost 4 

#define changemapcost 2 
#define tclothescost 5 
#define autocost 10 
#define flashbombcost 8 
#define awpcost 14 
#define immunitycost 5 

//////////////////////////////Max Level////////////////////////////////////// 


#define hp_max_level 4
#define armor_max_level 2 //Dont raise it above 2 since CSGO's max armor is 120. Or reduce armorperbuy but meh 
#define gravity_max_level 3
#define multijump_max_level 4 
#define power_max_level 3
#define hptaker_max_level 4
#define speed_max_level 3 


////////////////////////Adds Per Buy//////////////////////////////////////////// 
//How much the skills adds 
#define armorperbuy 10 
#define hpperbuy 15 
#define gravityperbuy 0.05 //% as a decimal 
new Float:speedperbuy=0.06; //% as a decimal 


////////////////////////Other//////////////////////////////////////////// 


//Skills 
new Armor[MAXPLAYERS+1]; 
new Health[MAXPLAYERS+1]; 
new Gravity[MAXPLAYERS+1]; 
new SpeedLevel[MAXPLAYERS+1]; 
new Realarmor[MAXPLAYERS+1]; 
new Hptaker[MAXPLAYERS+1]; 
new Power[MAXPLAYERS+1]; 
new multijump[MAXPLAYERS+1]; 
new jumpnum[MAXPLAYERS+1]; 

new Float:g_flBoost    = 250.0; 
new bool:g_bDoubleJump = true; 
new g_fLastButtons[MAXPLAYERS+1]; 
new g_fLastFlags[MAXPLAYERS+1]; 
 

new bool:SpawnProtection[MAXPLAYERS+1];


//Credit Arrays 
new Handle:CreditCookie; 
new Handle:CashCookie; 
new Handle:CreditTimer[MAXPLAYERS+1]; 


//Items 


public Plugin:myinfo =  
{ 
    name = "711 Source Credit Mod", 
    author = "Taz", 
    description = "Credit Mod for CS:GO", 
    version = PLUGIN_VERSION, 
    url = "http://www.711clan.org", 
}; 

public OnPluginStart()  
{ 
    LogMessage("Rootbeer Mod Loaded Successfully"); 
    CreditCookie = RegClientCookie("rootbeer_credits", "Amount of Credits the client has", CookieAccess_Protected); 
    CashCookie = RegClientCookie("rootbeer_cash", "Amount of Cash the client has", CookieAccess_Protected); 
    RegConsoleCmd("sm_buy", Command_BuyCmd);
    RegConsoleCmd("sm_bank", Command_BankCmd);
    RegConsoleCmd("sm_buycredits", Command_BuyCreditsCmd); 
    RegConsoleCmd("sm_credits", Command_ShowCreditsCmd); 
    RegConsoleCmd("sm_givecreditsall", Command_GiveCreditsAllCmd); //FOR TESTING. This gives everyone on the server 100 credits, and is not an admin command.
    //RegAdminCmd("sm_givecredits", Command_GiveCreditsCmd, ADMFLAG_CHANGEMAP, "Syntax: sm_givecredits <SteamID> <amount>");
    HookEvent("player_death", event_death); 
    HookEvent("player_spawn", event_PlayerSpawn); 
    HookEvent("item_equip", event_itemEquip); 
    HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre); 
    HookEvent("round_start", event_roundStart); 
} 

public OnClientPutInServer(client)  
{ 
    if (!IsValidClient(client)) 
        return; 
     
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
    CreditTimer[client] = CreateTimer(300.0, AutoCredit, client, TIMER_REPEAT); 
} 


public event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
    new client = GetClientOfUserId(GetEventInt(event, "userid")); 
    CreateTimer(0.1, timer_PlayerSpawn, client); 
    SpawnProtection[client] = true;
    CreateTimer(3.0, timer_protectionOff, client);
} 

public event_roundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
    CreateTimer(0.1, NewRound); 
} 

public Action:timer_PlayerSpawn(Handle:timer, any:client) 
{
    if (IsValidClient(client))
    {
        SetEntData(client, FindDataMapOffs(client, "m_iMaxHealth"), 500, 4, true); 
        new ihp = ((Health[client]*hpperbuy)+100); 
        SetEntData(client, FindDataMapOffs(client, "m_iHealth"), ihp, 4, true); 
        
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", (speedperbuy*SpeedLevel[client])+1); 
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

public Action:Event_OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
    new client = GetClientOfUserId(GetEventInt(event, "userid")); 
    if(client <= 0 || !IsClientInGame(client)) 
        return Plugin_Continue; 
    CreateTimer(2.0, RespawnPlayer, client);
    return Plugin_Continue; 
} 

GetClientCredits(client) 
{ 
    if (!IsValidClient(client)) return 0; 
    if (!AreClientCookiesCached(client)) return 0; 
    decl String:strPoints[32]; 
    GetClientCookie(client, CreditCookie, strPoints, sizeof(strPoints)); 
    return StringToInt(strPoints); 
} 

SetClientCredits(client, points) 
{ 
    if (!IsValidClient(client)) return; 
    if (IsFakeClient(client)) return; 
    if (!AreClientCookiesCached(client)) return; 
    decl String:strPoints[32]; 
    IntToString(points, strPoints, sizeof(strPoints)); 
    SetClientCookie(client, CreditCookie, strPoints); 
} 

public Action:AutoCredit(Handle:timer, any:client) 
{ 
    SetClientCredits(client, (GetClientCredits(client)+1)); 
    return Plugin_Continue; 
} 

GetClientCash(client) 
{ 
    if (!IsValidClient(client)) return 0; 
    if (!AreClientCookiesCached(client)) return 0; 
    decl String:strPoints[32]; 
    GetClientCookie(client, CashCookie, strPoints, sizeof(strPoints)); 
    return StringToInt(strPoints); 
} 

SetClientCash(client, cash) 
{ 
    if (!IsValidClient(client)) return; 
    if (IsFakeClient(client)) return; 
    if (!AreClientCookiesCached(client)) return; 
    decl String:strPoints[32]; 
    IntToString(cash, strPoints, sizeof(strPoints)); 
    SetClientCookie(client, CashCookie, strPoints); 
}

public Action:Command_BankCmd(client, args)
{
    Bank(client);
}

public Action:Command_BuyCreditsCmd(client, args) 
{ 
    Command_BuyCredits(client); 
} 

public Action:Command_ShowCreditsCmd(client, args) 
{ 
    new credits=(GetClientCredits(client)); 
    PrintToChat(client, "You have %i Credits", credits); 
} 

public Action:Command_GiveCreditsAllCmd(client,args) 
{ 
    for (new i = 1; i <= MaxClients; i++) 
    { 
        if (IsClientConnected(i)) 
        { 
            if (!IsFakeClient(i)) 
            { 
                SetClientCredits(i, GetClientCredits(i)+100); 
                PrintToChat(i, "100 credits given"); 
            } 
        } 
    } 
}

/*public Action:Command_GiveCreditsCmd(client,args)
{
    if (GetCmdArgs() != 2)
    {
        PrintToChat(client, "Syntax: sm_givecredits <SteamID> <amount>");
        PrintToConsole(client, "Syntax: sm_givecredits <SteamID> <amount>");
    }
    new String:id[64];
    new String:str[64];
    GetCmdArg(1, id, sizeof(id));
    GetCmdArg(2, amt, sizeof(str));
    new amount = StringToInt(str);
    //new credits = GetAuthIdCookie(id, CreditCookie) would go here
    SetAuthIdCookie(id, CreditCookie, credits+amount);
}*/

public Action:NewRound(Handle:hTimer) 
{
    for (new i = 1; i <= MaxClients; i++) 
    { 
        if(IsClientConnected(i)) 
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
} 

public Action:Command_BuyCmd(client, args) 
{ 
    if (!IsValidClient(client)) return Plugin_Continue; 
    Command_Buy(client); 
    return Plugin_Continue; 
} 

public Action:Command_BuyCredits(client) 
{ 
    new money = GetEntProp(client, Prop_Send, "m_iAccount"); 
    if (money<10000) 
        return Plugin_Handled; 
    SetEntProp(client, Prop_Send, "m_iAccount", money - 10000); 
    SetClientCredits(client, GetClientCredits(client)+5); 
    PrintToChat(client, "Purchased 5 Credits for $10000"); 
    return Plugin_Handled; 
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

public Action:RespawnPlayer(Handle:timer, any:client) 
{
    if (!IsValidClient(client))
        return;
    CS_RespawnPlayer(client);
}

//////////////////////////Menus////////////////////////////////////////////////////////////// 

public Action:Command_Buy(client) 
{ 
    new Handle:menu = CreateMenu(MenuHandler_Main); 
    SetMenuTitle(menu, "Credit Mod Menu"); 
    AddMenuItem(menu, "Skills", "Skills"); 
    AddMenuItem(menu, "Bank", "Bank"); 
    AddMenuItem(menu, "Buy 5 Credits", "Buy 5 Credits");     

    SetMenuExitButton(menu, true); 
    DisplayMenu(menu, client, 20); 
    return Plugin_Handled; 
} 

public MenuHandler_Main(Handle:menu, MenuAction:action, param1, param2) 
{ 
    if (action == MenuAction_Select) 
    { 
        switch(param2) 
        { 
            case 0: 
            { 
                    Menu_Skills(param1); 
            } 
            case 1: 
            { 
                    Bank(param1); 
            } 
            case 2: 
            { 
                    Command_BuyCredits(param1); 
            } 
        } 
    } 
    else if (action == MenuAction_Cancel) 
    { 
        PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2); 
    } 
    else if (action == MenuAction_End) 
    { 
        CloseHandle(menu); 
    } 
}

public Action:Menu_Skills(client)
{
    new credits=GetClientCredits(client); 
    { 
        new Handle:menu = CreatePanel(); 
        new String:s[512]; 
        Format(s, 512, "Skills - You have %i Credits",credits); 
        SetPanelTitle(menu, s); 
        Format(s, 512, "Health (Cost: %d Credit) %i/%d", hpcost,Health[client]/1,hp_max_level); 
        DrawPanelItem(menu, s);
        Format(s, 512, "Armor (Cost: %d Credit) %i/%d", armorcost, Armor[client]/1, armor_max_level); 
        DrawPanelItem(menu, s); 
        Format(s, 512, "Speed (Cost: %d Credit) %i/%d", speedcost, SpeedLevel[client]/1,speed_max_level); 
        DrawPanelItem(menu, s); 
        Format(s, 512, "Gravity (Cost: %d Credit) %i/%d", gravitycost, Gravity[client]/1, gravity_max_level); 
        DrawPanelItem(menu, s); 
        Format(s, 512, "Mutlijump (Cost: %d Credit) %i/%d", multijumpcost, multijump[client]/1, multijump_max_level);         
        DrawPanelItem(menu, s); 
        Format(s, 512, "Power (Cost: %d Credit) %i/%d", powercost,Power[client]/1, power_max_level); 
        DrawPanelItem(menu, s); 
        Format(s, 512, "HP Consumer (Cost: %d Credit) %i/%d", hptakercost,Hptaker[client]/1, hptaker_max_level); 
        DrawPanelItem(menu, s); 
        DrawPanelItem(menu, "Cancel"); 
        DrawPanelItem(menu, "Back",ITEMDRAW_CONTROL); 
        SendPanelToClient(menu, client, MenuHandler_Skills, 20); 
        CloseHandle(menu); 
    } 
    return Plugin_Handled; 
}

public MenuHandler_Skills(Handle:menu, MenuAction:action, param1, param2) 
{
    if (action == MenuAction_Select) 
    { 
        new credits=GetClientCredits(param1); 
        switch (param2) 
        { 
            case 1: 
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
            case 2: 
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
            case 3: 
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
            case 4: 
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
            case 5: 
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
            case 6: 
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
            case 7: 
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
            default: 
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

public Action:Bank(client) 
{ 
    new iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount"); 
     
    if (iAccount == -1) 
    { 
        PrintToServer("[SM] Unable to start round money, cannot find necessary send prop offsets."); 
        return Plugin_Handled; 
    } 
     
    new Handle:menu = CreatePanel(); 
    SetPanelTitle(menu, "Bank"); 
    DrawPanelItem(menu, "Deposit your cash"); 
    DrawPanelItem(menu, "Withdraw $1000"); 
    DrawPanelItem(menu, "Cancel"); 
    DrawPanelItem(menu, "Back",ITEMDRAW_CONTROL); 
    SendPanelToClient(menu, client,BankMenu, 20); 
    CloseHandle(menu); 
    return Plugin_Handled; 
} 

public BankMenu(Handle:menu, MenuAction:action, param1, param2) 
{ 
    new iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount"); 
    new iMoney = GetEntData(param1,iAccount,4); 
    new bankcash = GetClientCash(param1); 
    if (action == MenuAction_Select) 
    {
        switch (param2) 
        {
            case 1: 
            {
                SetClientCash(param1, (bankcash + iMoney));
                SetEntData(param1, iAccount, 0, 4, true);
                Bank(param1); 
            } 
            case 2: 
            { 
                if (iMoney<9000) 
                {
                    if (bankcash >=1000) 
                    { 
                        SetEntData(param1, iAccount, (iMoney + 1000), 4, true); 
                        SetClientCash(param1, (bankcash - 1000)); 
                        Bank(param1); 
                    } 
                    else
                    {
                        PrintToChat(param1, "Insufficient Funds!"); 
                        Bank(param1);
                    }
                }
                else
                {
                    PrintToChat(param1, "You can't hold any more money"); 
                    Bank(param1);
                }
            }
            case 3: 
                return; 
        }
    }
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
stock IsValidClient(client, bool:replaycheck = true) 
{ 
    if (client <= 0 || client > MaxClients) return false; 
    if (!IsClientInGame(client)) return false; 
    if (replaycheck) 
    { 
        if (IsClientSourceTV(client) || IsClientReplay(client)) return false; 
    } 
    return true; 
} 

stock SetClientFrags( index, frags ) 
{ 
    SetEntProp( index, Prop_Data, "m_iFrags", frags ); 
    return 1; 
} 

stock SetClientDeaths( index, deaths ) 
{ 
    SetEntProp( index, Prop_Data, "m_iDeaths", deaths ); 
    return 1; 
}  