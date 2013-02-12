public Action:Command_Buy(client, args) 
{ 
    if (!IsValidClient(client)) return Plugin_Continue; 
    Command_BuyMenu(client); 
    return Plugin_Continue; 
}

public Action:Command_Bank(client, args)
{
	Bank(client);
}

public Action:Command_BuyCredits(client, args)
{
	BuyCredits(client);
}

public Action:BuyCredits(client) 
{ 
    new money = GetEntProp(client, Prop_Send, "m_iAccount"); 
    if (money<10000) 
        return Plugin_Handled; 
    SetEntProp(client, Prop_Send, "m_iAccount", money - 10000); 
    SetClientCredits(client, GetClientCredits(client)+5); 
    PrintToChat(client, "Purchased 5 Credits for $10000"); 
    return Plugin_Handled; 
} 

public Action:Command_ShowCredits(client, args) 
{ 
    new credits=(GetClientCredits(client)); 
    PrintToChat(client, "You have %i Credits", credits); 
}

public Action:Command_SetCredits(client,args)
{
	if (GetCmdArgs() != 2)
	{
		PrintToChat(client, "Syntax: sm_setcredits <SteamID> <amount>");
		PrintToConsole(client, "Syntax: sm_setcredits <SteamID> <amount>");
	}
	new String:id[64];
	new String:str[64];
	GetCmdArg(1, id, sizeof(id));
	GetCmdArg(2, str, sizeof(str));
	SetAuthIdCookie(id, CreditCookie, str);
}

public Action:Command_SetCash(client,args)
{
	if (GetCmdArgs() != 2)
	{
		PrintToChat(client, "Syntax: sm_setcash <SteamID> <amount>");
		PrintToConsole(client, "Syntax: sm_setcash <SteamID> <amount>");
	}
	new String:id[64];
	new String:str[64];
	GetCmdArg(1, id, sizeof(id));
	GetCmdArg(2, str, sizeof(str));
	SetAuthIdCookie(id, CashCookie, str);
}