#pragma semicolon 1

#pragma newdecls required

#include <sdktools_gamerules>

Handle talk;
int g_iCount;
bool clutch, clutch_msg;

public Plugin myinfo = {
    name = "Clutch Time",
    author = "L1MON",
    version = "1.4.1"
};

public void OnPluginStart() 
{
    HookEvent("round_start", OnStart, EventHookMode_PostNoCopy);
    HookEvent("player_death", OnDeath, EventHookMode_PostNoCopy);
    HookEvent("round_end", OnEnd, EventHookMode_PostNoCopy);
    HookEvent("server_cvar", OnCvarChange, EventHookMode_Pre);
    talk = FindConVar("sv_deadtalk");

    ConVar hCvar;
    HookConVarChange((hCvar = CreateConVar("sm_min_clutch", "4", _, _, true)), Count_Players);
    g_iCount = hCvar.IntValue;

    LoadTranslations("cluth_time.phrases");
}

stock int GetAliveInTeam(int iTeamId)
{
    int iPlayers;
    for (int iClient = MaxClients + 1; --iClient;)
        if (IsClientInGame(iClient) && GetClientTeam(iClient) == iTeamId && IsPlayerAlive(iClient))
            iPlayers++;

    return iPlayers;
}

public Action OnStart(Event hEvent, const char[] sName, bool bDontBroadcast)
{   
    clutch = false;
    clutch_msg = false;
}

public Action OnDeath(Event hEvent, const char[] sName, bool bDontBroadcast)
{   
    if(GetClientCount(true) >= g_iCount && !GameRules_GetProp("m_bWarmupPeriod", 1) && clutch == false && (GetAliveInTeam(2) == 1 || GetAliveInTeam(3) == 1))
    {
        SetConVarInt(talk, 0, false, false);
        PrintToChatAll("%t", "clutch_on");
        clutch = true;
        clutch_msg = true;
    }
}

public Action OnEnd(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    clutch = true;

    if(clutch_msg == true)
    {
        SetConVarInt(talk, 1, false, false);
        PrintToChatAll("%t", "clutch_off");
    }
}

public Action OnCvarChange(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    char sCvar[32];

    hEvent.GetString("cvarname", sCvar, sizeof(sCvar));

    if(!strcmp("sv_deadtalk", sCvar))
    {
        hEvent.BroadcastDisabled = true;
    }
}

public void Count_Players(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
    g_iCount = hCvar.IntValue;
}