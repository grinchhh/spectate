#include <sourcemod>
#include <tog>
#define PLUGIN_VERSION  "1.4"

public Plugin:myinfo = {
	name = "TOG Easy Spectate",
	author = "That One Guy",
	description = "Easily spectate players and print info.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/member.php?u=188078"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_spec", Command_Spec, "sm_spec <target> - Spectates a player.");
	RegConsoleCmd("sm_info", Command_Info, "sm_info <target> - Prints player info to chat.");
}

public Action:Command_Info(client, iArgs)
{
	decl String:sTarget[128];
	GetCmdArg(1, sTarget, sizeof(sTarget));

	decl String:sTargetName[MAX_TARGET_LENGTH];
	decl a_iTargets[MAXPLAYERS], iTargetCount, bool:bTN_Is_ML;

	if((iTargetCount = ProcessTargetString(sTarget, client, a_iTargets, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, sTargetName, sizeof(sTargetName), bTN_Is_ML)) <= 0)
	{
		ReplyToCommand(client, "Not found or invalid parameter.");
		return Plugin_Handled;
	}
	
	for(new i = 0; i < iTargetCount; i++)
	{
		new target = a_iTargets[i];
		if(IsValidClient(target))
		{
			PrintInfo(client, target);
		}
	}
	
	return Plugin_Handled;
}

public Action:Command_Spec(client, iArgs)
{
	if(!IsValidClient(client))
	{
		ReplyToCommand(client, "You must be in game to use this command!");
		return Plugin_Handled;
	}
	
	new iTeam = GetClientTeam(client);
	
	if((iTeam == 2) || (iTeam == 3))
	{
		if(!IsLastPlayerAlive(client, iTeam))
		{
			ChangeClientTeam(client, 1);
		}
		else
		{
			ReplyToCommand(client, "You cannot use this command if you're the last player alive!");
			return Plugin_Handled;
		}
	}
	
	decl String:sArgs[128];
	GetCmdArgString(sArgs, sizeof(sArgs));
	if(StrEqual(sArgs, "", false))
	{
		return Plugin_Handled;
	}
	
	new target = FindTarget(client, sArgs, false, false);
	if(!IsValidClient(target))
	{
		ReplyToCommand(client, "Invalid target!");
		return Plugin_Handled;
	}
	
	if(!IsPlayerAlive(target))
	{
		ReplyToCommand(client, "Target must be alive to spectate them!");
		return Plugin_Handled;
	}
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", target)
	PrintInfo(client, target);
	
	return Plugin_Handled;
}

PrintInfo(client, target)
{
	if(IsValidClient(client)) //if rcon
	{
		if(IsValidClient(target))
		{
			decl String:sID[40], String:sIP[40];
			GetClientIP(target, sIP, sizeof(sIP));
			GetClientAuthString(target, sID, sizeof(sID));
			if(HasFlags(client, "z"))
			{
				PrintToConsole(client, "Target: %N (#%i ; %s); IP: %s", target, GetClientUserId(target), sID, sIP);
			}
			else
			{
				PrintToConsole(client, "Target: %N (#%i ; %s)", target, GetClientUserId(target), sID);
			}
		}
		else
		{
			PrintToConsole(client, "Invalid player!");
		}
	}
	else
	{
		if(IsValidClient(target))
		{
			decl String:sID[40], String:sIP[40];
			GetClientIP(target, sIP, sizeof(sIP));
			GetClientAuthString(target, sID, sizeof(sID));
			PrintToServer("Target: %N (#%i ; %s); IP: %s", target, GetClientUserId(target), sID, sIP);
		}
		else
		{
			PrintToServer("Invalid player!");
		}
	}
}

bool:IsLastPlayerAlive(client, iTeam)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			if((GetClientTeam(i) == iTeam) && (i != client))
			{
				if(IsPlayerAlive(i))
				{
					return false;
				}
			}
		}
	}
	return true;
}
