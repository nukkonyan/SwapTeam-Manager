#include	<multicolors>
#include	<tf2_stocks>
#include	<cstrike>

public	Plugin	myinfo	=	{
	name		=	"[ANY] SwapTeam Manager",
	author		=	"Tk /id/Teamkiller324",
	description	=	"Manage and swap players teams",
	version		=	"1.0.0",
	url			=	"https://steamcommunity.com"
}

public Extension __ext_tf2 =	{
	name = "TF2 Tools",		//This allows any game to load without "TF2 Tools Extension is required" error on plugin startup
	file = "game.tf2.ext",	//since the other games doesn't use the tf2 natives and the extension is automatically loaded
	required = 0			//when server is running team fortress 2
};

public Extension __ext_cstrike =	{
	name = "cstrike",
	file = "games/game.cstrike.ext",
	required = 0
};

/*
This plugin is a standalone version of swapteam module part of my All-In-One Plugin "Random Commands Plugin" (Unreleased)
*/

char		game[64];

ConVar		swapNotify,
			swapInstant,
			swapUpdateModel;

char		swapPrefix[1024];

public	void	OnPluginStart()	{
	GetGameFolderName(game,	sizeof(game));
	
	LoadTranslations("common.phrases");
	LoadTranslations("swapteam_manager.phrases");
	FormatEx(swapPrefix, sizeof(swapPrefix), "%t{default}", "swapteam_prefix", LANG_SERVER);
	
	RegAdminCmd("sm_swap",			SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");
	RegAdminCmd("sm_swapteam",		SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");
	RegAdminCmd("sm_switch",		SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");
	RegAdminCmd("sm_switchteam",	SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");

	RegAdminCmd("sm_exchange",		ExchangeTeamPlayer,	ADMFLAG_SLAY,	"Exchange a players team to another players team");
	
	RegConsoleCmd("sm_spec",		SpecTeam,							"Switch to spectator team");
	RegAdminCmd("sm_switchspec",	SpecTeamPlayer,		ADMFLAG_SLAY,	"Switch player to spectator");
	RegAdminCmd("sm_swapspec",		SpecTeamPlayer,		ADMFLAG_SLAY,	"Switch player to spectator");
	
	RegAdminCmd("sm_forceteam",		ForceClientTeam,	ADMFLAG_ROOT,	"Force a team index number on a client");
	
	swapNotify	=	CreateConVar("commands_swapteam_notify",	"1",	"Notify to show everyone or just client for chat team changes");
	swapInstant	=	CreateConVar("commands_swapteam_instant",	"0",	"Determine wheter the team switch should be instant or not");
	if(GetEngineVersion() == Engine_CSS || GetEngineVersion() == Engine_CSGO)	{
		swapUpdateModel	=	CreateConVar("commands_swapteam_updatemodel",	"1",	"Determine if the client model should be updated upon instant team swap");
	}
	
	AutoExecConfig(true,	"swapteam_manager");
}

public Action SwapTeamPlayer(int client, int args)	{
	if(StrEqual(game, "tf2classic"))	{
		if(args < 2)	{
			CPrintToChat(client, "%s %t", swapPrefix, "swapteam_usage_tf2c");
			return Plugin_Handled;
		}
	}
	else	{
		if(args < 1)	{
			CPrintToChat(client, "%s %t", swapPrefix, "swapteam_usage");
			return Plugin_Handled;
		}
	}
		
	char	arg1		[MAX_TARGET_LENGTH],
			arg2		[MAX_TARGET_LENGTH],
			target_name	[MAX_TARGET_LENGTH];
	int		target_list	[MAXPLAYERS],
			target_count;
	bool	tn_is_ml;
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	if((target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	char teamname[128];
	for(int i = 0; i < target_count; i++)
	{
		int	target	=	target_list[i];
		if(GetEngineVersion() == Engine_TF2)	{
			if(StrEqual(game, "tf2classic"))	{
				if(StrContains(arg2, "Yel", false) != -1)	{
					if(GetClientTeam(target) != 5)	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target_list[i], 5);
						else
							TF2_ChangeClientTeam(target_list[i], TFTeam_Yellow);
						teamname = "{orange}Yellow";
					}
				}
				else if(StrContains(arg2, "Gre", false) != -1)	{
					if(GetClientTeam(target) != 4)	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target_list[i], 4);
						else
							TF2_ChangeClientTeam(target_list[i], TFTeam_Green);
						teamname = "{lightgreen}Green";
					}
				}
				else if(StrContains(arg2, "Blu", false) != -1)	{
					if(GetClientTeam(target) != 3)	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 3);
						else
							TF2_ChangeClientTeam(target, TFTeam_Blue);
						teamname = "{blue}Blue";
					}
				}
				else if(StrContains(arg2, "Red", false) != -1)	{
					if(GetClientTeam(target) != 2)
					if(swapInstant.BoolValue)
						SetClientTeamNum(target, 2);
					else
						TF2_ChangeClientTeam(target, TFTeam_Red);
					teamname = "{red}Red";
				}
			}
			else	{
				switch(TF2_GetClientTeam(target))	{						
					case TFTeam_Unassigned, TFTeam_Spectator:	{
						int picker = GetRandomInt(2, 3);
						
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, picker);
						else
							ChangeClientTeam(target, picker);
						
						switch (picker)	{
							case 2: teamname = "{red}Red";
							case 3: teamname = "{blue}Blue";
						}
					}
					case TFTeam_Red:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 3);	//Team to be changed from
						else
							TF2_ChangeClientTeam(target, TFTeam_Blue);
						teamname = "{blue}Blue";	//Team to be changed to
					}
					case TFTeam_Blue:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 2);
						else
							TF2_ChangeClientTeam(target, TFTeam_Red);
						teamname = "{red}Red";
					}
					default: return Plugin_Handled;
				}
			}
		}
		else if(GetEngineVersion() == Engine_CSS || GetEngineVersion() == Engine_CSGO)
		{
			switch(GetClientTeam(target))
			{
				case CS_TEAM_NONE, CS_TEAM_SPECTATOR:	{
					int picker = GetRandomInt(2, 3);
					
					if(swapInstant.BoolValue)	{
						SetClientTeamNum(target, picker);
						if(swapUpdateModel.BoolValue)	{
							CS_UpdateClientModel(target);
						}
					}
					else
						ChangeClientTeam(target, picker);
					
					switch(picker)	{
						case 2: teamname = "{red}Terrorists";
						case 3: teamname = "{blue}Counter-Terrorists";
					}
				}
				case CS_TEAM_T:	{
					if(swapInstant.BoolValue)
						CS_SwitchTeam(target, 3);
					else
						ChangeClientTeam(target, 3);
					teamname = "{blue}Counter-Terrorists";
				}
				case CS_TEAM_CT:	{
					if(swapInstant.BoolValue)
						CS_SwitchTeam(target, 2);
					else
						ChangeClientTeam(target, 2);
						
					if(GetEngineVersion() == Engine_CSS)
						teamname = "{red}Terrorists";
					else
						teamname = "{orange}Terrorists";
				}
				default: return Plugin_Handled;
			}
		}
	}
	if(swapNotify.BoolValue)
		CPrintToChat(client, "%s %t", swapPrefix, "swapteam_target_client", target_name, teamname);

	return Plugin_Handled;	
}

public Action SpecTeamPlayer(int client, int args)	{
	if(args < 1)	{
		CPrintToChat(client, "%s %t", swapPrefix, "swapteam_spec_usage");
		return Plugin_Handled;
	}
		
	char	arg1		[MAX_TARGET_LENGTH],
			target_name	[MAX_TARGET_LENGTH],
			teamname	[128];
	int		target_list	[MAXPLAYERS],
			target_count;
	bool	tn_is_ml;
	
	GetCmdArg(1, arg1, sizeof(arg1));
	if((target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		if(GetClientTeam(target_list[i]) != 1)	{	//Checks if you're already in spectator team
			ChangeClientTeam(target_list[i], 1);
			teamname = "{grey}Spectator";
		}
		else
			return Plugin_Handled;
	}
	if(swapNotify.BoolValue)
		CPrintToChatAll("%s %t", swapPrefix, "swapteam_target", client, target_name, teamname);
	else
		CPrintToChat(client, "%s %t", swapPrefix, "swapteam_target_client", target_name, teamname);
	return Plugin_Handled;	
}

public Action ExchangeTeamPlayer(int client, int args)	{
	if(args < 2)	{
		CPrintToChat(client, "%s %t", swapPrefix, "exchangeteam_usage");
		return Plugin_Handled;
	}
	
	char	arg1			[MAX_TARGET_LENGTH],
			arg2			[MAX_TARGET_LENGTH],
			target_name		[MAX_TARGET_LENGTH],
			target_name2	[MAX_TARGET_LENGTH];
	int		target_list		[MAXPLAYERS],
			target_list2	[MAXPLAYERS],
			target_count;
	bool	tn_is_ml;
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	if((target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
		
	if((target_count = ProcessTargetString(
		arg2,
		client,
		target_list2,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name2,
		sizeof(target_name2),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	char	teamname1	[256],
			teamname2	[256];
		
	for (int i = 0; i < target_count; i++)
	{	
		int	client1	=	target_list[i],
			client2	=	target_list2[i],
			team1	=	GetClientTeam(target_list[i]),
			team2	=	GetClientTeam(target_list2[i]);
		
		if(team1 == team2)	{
			CPrintToChat(client, "%s %t", swapPrefix, "exchangeteam_error", target_name, target_name2);
			return Plugin_Handled;
		}
		
		if(GetEngineVersion() == Engine_CSS & Engine_CSGO)
		{
			if(swapInstant.BoolValue)	{
				SetClientTeamNum(client1,	team2);
				SetClientTeamNum(client2,	team1);
			}
			else	{
				ChangeClientTeam(client1,	team2);
				ChangeClientTeam(client2,	team1);
			}
			switch (team1)
			{
				case 0:	return Plugin_Handled;
				case 1:	return Plugin_Handled;
				case 2:
				{
					if(GetEngineVersion() == Engine_CSGO)
						teamname1	=	"{orange}Terrorists";
					else
						teamname1	=	"{red}Terrorists";
				}
				case 3: teamname1	=	"{blue}Counter-Terrorists";
			}
			switch (team2)
			{
				case 0:	return Plugin_Handled;
				case 1:	return Plugin_Handled;
				case 2:
				{
					if(GetEngineVersion() == Engine_CSGO)
						teamname2	=	"{orange}Terrorists";
					else
						teamname2	=	"{red}Terrorists";
				}
				case 3: teamname2	=	"{blue}Counter-Terrorists";
			}
		}
		else if (GetEngineVersion() == Engine_TF2)
		{
			SetClientTeamNum(client1, team2);
			SetClientTeamNum(client2, team1);
			switch (team1)
			{
				case 0: return Plugin_Handled;
				case 1: return Plugin_Handled;
				case 2: teamname1	=	"{red}Red";
				case 3: teamname1	=	"{blue}Blue";
				case 4: teamname1	=	"{lightgreen}Green";
				case 5: teamname1	=	"{yellow}Yellow";
			}
			switch (team2)
			{
				case 0: return Plugin_Handled;
				case 1: return Plugin_Handled;
				case 2: teamname2	=	"{red}Red";
				case 3: teamname2	=	"{blue}Blue";
				case 4: teamname2	=	"{lightgreen}Green";
				case 5: teamname2	=	"{yellow}Yellow";
			}
		}
	}
	CPrintToChat(client, "%s %t", swapPrefix, "exchangeteam_target", target_name, teamname2, target_name2, teamname1);
	
	return Plugin_Handled;
}

public Action	SpecTeam(int client, int args)	{
	ChangeClientTeam(client, 1);
}

public Action ForceClientTeam(int client, int args)	{
	if(args < 2)	{
		CPrintToChat(client,	"%s %t", swapPrefix, "forceteam_usage");
		return Plugin_Handled;
	}
	
	char	arg1			[MAX_TARGET_LENGTH],
			arg2			[MAX_TARGET_LENGTH],
			target_name		[MAX_TARGET_LENGTH];
	int		target_list		[MAXPLAYERS],
			target_count;
	bool	tn_is_ml;
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	if((target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	int	value	=	StringToInt(arg2);
	
	int limit;
	if(GetEngineVersion() == Engine_CSS)	{
		limit = 3;
	}
	else if(GetEngineVersion() == Engine_CSGO)	{
		limit = 3;
	}
	else if(GetEngineVersion() == Engine_TF2)	{
		if(StrEqual(game,	"tf2classic"))	{
			limit = 5;
		}
		else	{
			limit = 3;	
		}
	}
	
	if(value < 0)	{
		CPrintToChat(client,	"%s %t", swapPrefix, "forceteam_error_lower");
		return Plugin_Handled;
	}
	else if(value > limit)	{
		CPrintToChat(client,	"%s %t", swapPrefix, "forceteam_error_over", limit);
		return Plugin_Handled;
	}
	else	{
		for(int i = 0; i < MaxClients; i++)	{
			SetClientTeamNum(target_list[i], value);
		}
	}
	
	CPrintToChat(client, "%s %t", swapPrefix, "forceteam_target", target_name, value);
	
	return Plugin_Handled;
}

//Needed -> Imported from tk.inc / Teamkiller324's Include
stock	void	SetClientTeamNum(int client,	int value)	{
	SetEntProp(client,	Prop_Send,	"m_iTeamNum",	value);
}