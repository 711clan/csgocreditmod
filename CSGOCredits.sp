#pragma semicolon 1 
#include <sourcemod> 
#include <sdktools> 
#include <sdkhooks> 
#include <nextmap> 
#include <clientprefs> 
#include <sdkhooks> 
#include <smlib>
#include <cstrike>

/////////////////////////////////Credits////////////////////////////////// 
#define credittime 300.0 //Time Per Credit (in seconds) Edit line xxx from 300.0 to the desired value. 



////////////////////////////Costs///////////////////////////////////////// 
#define armorcost 1 
#define hpcost 4 
#define gravitycost 2 
#define multijumpcost 1 
#define hptakercost 4 
#define powercost 4 
#define speedcost 4 



//////////////////////////////Max Level////////////////////////////////////// 
#define hp_max_level 4
#define armor_max_level 2 //Dont raise it above 2 since CSGO's max armor is 120. Or reduce armorperbuy but meh 
#define gravity_max_level 3
#define multijump_max_level 4 
#define power_max_level 3
#define hptaker_max_level 4
#define speed_max_level 3 


////////////////////////Adds Per Buy//////////////////////////////////////////// 
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

//Multijump Stuff
new jumpnum[MAXPLAYERS+1]; 
new Float:g_flBoost    = 250.0; 
new bool:g_bDoubleJump = true; 
new g_fLastButtons[MAXPLAYERS+1]; 
new g_fLastFlags[MAXPLAYERS+1]; 
 
 //Spawn Protection toggle per player
new bool:SpawnProtection[MAXPLAYERS+1];

//Cash and credit handles
new Handle:CreditCookie; 
new Handle:CashCookie; 
new Handle:CreditTimer[MAXPLAYERS+1]; 


#include "creditmod/menus.sp"
#include "creditmod/skills.sp"
//#include "creditmod/items.sp"
#include "creditmod/bank.sp"
#include "creditmod/events.sp"
#include "creditmod/commands.sp"

#define PLUGIN_VERSION "1.2" 


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
    RegConsoleCmd("sm_buy", Command_Buy);
    RegConsoleCmd("sm_bank", Command_Bank);
    RegConsoleCmd("sm_buycredits", Command_BuyCredits); 
    RegConsoleCmd("sm_credits", Command_ShowCredits); 
    RegAdminCmd("sm_setcredits", Command_SetCredits, ADMFLAG_CHANGEMAP, "Syntax: sm_givecredits <SteamID> <amount>");
    RegAdminCmd("sm_setcash", Command_SetCash, ADMFLAG_CHANGEMAP, "Syntax: sm_givecredits <SteamID> <amount>");
    HookEvent("player_death", event_death); 
    HookEvent("player_spawn", event_PlayerSpawn); 
    HookEvent("item_equip", event_itemEquip); 
    HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre); 
    //HookEvent("round_start", event_roundStart); 
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