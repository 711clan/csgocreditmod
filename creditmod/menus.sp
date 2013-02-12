public Action:Command_BuyMenu(client) 
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
                    BuyCredits(param1); 
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
		DrawPanelItem(menu, "Back",ITEMDRAW_CONTROL); 
		DrawPanelItem(menu, "Cancel"); 
		SendPanelToClient(menu, client, MenuHandler_Skills, 20); 
		CloseHandle(menu); 
	} 
	return Plugin_Handled; 
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