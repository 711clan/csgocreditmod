public BankMenu(Handle:menu, MenuAction:action, param1, param2) 
{ 
	new iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount"); 
	new iMoney = GetEntData(param1,iAccount,4); 
	new bankcash = GetClientCash(param1); 
	if (action == MenuAction_Select) 
	{
		switch (param2) 
		{
			case 1: //deposit
			{
				SetClientCash(param1, (bankcash + iMoney));
				SetEntData(param1, iAccount, 0, 4, true);
				Bank(param1); 
			} 
			case 2: //withdraw $1000
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
			case 3: //cancel
				return; 
		}
	}
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

public Action:AutoCredit(Handle:timer, any:client) 
{ 
    SetClientCredits(client, (GetClientCredits(client)+1)); 
    return Plugin_Continue; 
} 