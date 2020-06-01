#pragma semicolon 1

#include <sourcemod>
#include <clients>
#include <sdktools>
#include <csgo_colors>

Handle talk;
int flags_talk, g_iCount;
bool clutch;

public Plugin myinfo = {
    name = "Clutch Time",
    author = "L1MON",
    version = "1.1"
};

public void OnPluginStart() 
{
    HookEvent("round_start", OnStart);
    HookEvent("player_death", OnDeath);
    HookEvent("round_end", OnEnd);
    HookEvent("server_cvar", OnCvarChange, EventHookMode_Pre);
    talk = FindConVar("sv_deadtalk");
    flags_talk = GetConVarFlags (talk);
    flags_talk = FCVAR_NOTIFY;
    SetConVarFlags(talk, flags_talk);

    ConVar hCvar;
    HookConVarChange((hCvar = CreateConVar("sm_min_clutch", "4", _, _, true, 0.0, _, _)), Count_Players);
    g_iCount = hCvar.IntValue;

    LoadTranslations("cluth_time.phrases");
}

stock int UTIL_GetAliveClientsInTeam(int iTeamId)
{
    int iPlayers;
    for (int iClient = MaxClients; iClient != 0; --iClient)
        if (IsClientInGame(iClient) && GetClientTeam(iClient) == iTeamId && IsPlayerAlive(iClient))
            iPlayers++;

    return iPlayers;
}

Action OnStart(Event hEvent, const char[] sName, bool bDontBroadcast)
{   
    if (GetClientCount(true) >= 3)
    {
        clutch ^= true;
    }
}

Action OnDeath(Event hEvent, const char[] sName, bool bDontBroadcast)
{   
    if (GameRules_GetProp("m_bWarmupPeriod", 1) != 1)
    {
        if (GetClientCount(true) >= g_iCount)
        {
            if ((UTIL_GetAliveClientsInTeam(2) == 1 || UTIL_GetAliveClientsInTeam(3) == 1) && clutch == false)
            {
                SetConVarInt(talk, 0, false, false);
                CGOPrintToChatAll("%t", "clutch_on");
                clutch = true;
            }
        }
    }
}

Action OnEnd(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    if (GetClientCount(true) >= g_iCount)
    {
        if(clutch == true)
        {
            SetConVarInt(talk, 1, false, false);
            CGOPrintToChatAll("%t", "clutch_off");
        }
    }
}

Action OnCvarChange(Event hEvent, const char[] sName, bool bDontBroadcast)
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