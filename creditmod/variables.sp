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