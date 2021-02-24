#include	<multicolors>
#include	<tk>

#pragma		semicolon	1
#pragma		newdecls	required

public	Plugin	myinfo	=	{
	name		=	"[ANY] SwapTeam Manager",
	author		=	"Tk /id/Teamkiller324",
	description	=	"Manage and swap players teams",
	version		=	"1.2.0",
	url			=	"https://steamcommunity.com"
}

/*
This plugin is a standalone version of swapteam module part of my All-In-One Plugin "Random Commands Plugin" (Unreleased)
*/

char		game[64],
			swapPrefix[1024];

ConVar		swapNotifySwapTeam,
			swapNotifySpecTeam,
			swapNotifyExchangeTeam,
			swapNotifyForceTeam,
			swapNotifyScramble,
			swapInstant,
			swapInstantScramble,
			swapUpdateModel;

public	void	OnPluginStart()	{	
	//Get the game folder
	GetGameFolderName(game,	sizeof(game));
	
	//Getting the translations & plugin prefix-tag
	LoadTranslations("common.phrases");
	LoadTranslations("swapteam_manager.phrases");
	FormatEx(swapPrefix, sizeof(swapPrefix), "%t{default}", "swapteam_prefix", LANG_SERVER);
	
	//Registering commands
	RegAdminCmd("sm_swap",			SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");
	RegAdminCmd("sm_swapteam",		SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");
	RegAdminCmd("sm_switch",		SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");
	RegAdminCmd("sm_switchteam",	SwapTeamPlayer,		ADMFLAG_SLAY,	"Swap a player to a team");
	
	RegAdminCmd("sm_exchange",		ExchangeTeamPlayer,	ADMFLAG_SLAY,	"Exchange a players team to another players team");
	
	RegConsoleCmd("sm_spec",		SpecTeam,							"Switch to spectator team");
	RegAdminCmd("sm_switchspec",	SpecTeamPlayer,		ADMFLAG_SLAY,	"Switch player to spectator");
	RegAdminCmd("sm_swapspec",		SpecTeamPlayer,		ADMFLAG_SLAY,	"Switch player to spectator");
	
	RegAdminCmd("sm_forceteam",		ForceClientTeam,	ADMFLAG_ROOT,	"Force a team index number on a client");
	
	RegAdminCmd("sm_scramble",		ScramblePlayer,		ADMFLAG_SLAY,	"Scramble a player to a random team");
	RegAdminCmd("sm_scrambleteams",	ScrambleTeams,		ADMFLAG_SLAY,	"Scramble players to a random team");
	
	//Notification ConVars
	swapNotifySwapTeam		=	CreateConVar("sm_swapteam_notify_swapteam",		"1",	"Notify to everyone or just the client for chat team changes",		_,	true,	0.0,	true,	1.0);
	swapNotifySpecTeam		=	CreateConVar("sm_swapteam_notify_specteam",		"1",	"Notify to everyone or just the client for spec team changes",		_,	true,	0.0,	true,	1.0);
	swapNotifyExchangeTeam	=	CreateConVar("sm_swapteam_notify_exchangeteam",	"1",	"Notify to everyone or just the client for exhcnage team changes",	_,	true,	0.0,	true,	1.0);
	swapNotifyForceTeam		=	CreateConVar("sm_swapteam_notify_forceteam",	"1",	"Notify to everyone or just the client for force team changes",		_,	true,	0.0,	true,	1.0);
	swapNotifyScramble		=	CreateConVar("sm_swapteam_notify_scramble",		"1",	"Notify to everyone or just the client for scramble",				_,	true,	0.0,	true,	1.0);
	
	//Determine if the team swap shall be instant
	swapInstant			=	CreateConVar("sm_swapteam_instant",				"0",	"Determine wheter the team switch should be instant or not",			_,	true,	0.0,	true,	1.0);
	swapInstantScramble	=	CreateConVar("sm_swapteam_instant_scramble",	"0",	"Determine wheter the scramble team switch should be instant or not",	_,	true,	0.0,	true,	1.0);
	
	switch(GetEngineVersion())	{
		//Checks if the game is CSGO or CSS for the update playermodel function
		case	Engine_CSS,Engine_CSGO:	{
			swapUpdateModel			=	CreateConVar("sm_swapteam_updatemodel",	"1",	"Determine if the client model should be updated upon instant team swap");
		}
	}
	
	AutoExecConfig(true,	"swapteam_manager");	
}

Action SwapTeamPlayer(int client, int args)	{
	if(StrEqual(game, "tf2classic"))	{
		if(args != 2)	{
			CPrintToChat(client, "%s %t", swapPrefix, "swapteam_usage_tf2c");
			return Plugin_Handled;
		}
	}
	else	{
		if(args != 1)	{
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
		return	Plugin_Handled;
	}
	
	char teamname[128];
	for(int i = 0; i < target_count; i++)	{
		int	target	=	target_list[i];
		switch(GetEngineVersion())	{
			case	Engine_TF2:	{
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
						case	TFTeam_Spectator:	{
							int picker = GetRandomInt(2, 3);
							
							if(swapInstant.BoolValue)
								SetClientTeamNum(target, picker);
							else
								ChangeClientTeam(target, picker);
							
							switch (picker)	{
								case	2:	teamname	=	"{red}Red";
								case	3:	teamname	=	"{blue}Blue";
							}
						}
						case	TFTeam_Red:	{
							if(swapInstant.BoolValue)
								SetClientTeamNum(target, 3);	//Team to be changed from
							else
								TF2_ChangeClientTeam(target, TFTeam_Blue);
							teamname = "{blue}Blue";	//Team to be changed to
						}
						case	TFTeam_Blue:	{
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
			case	Engine_CSS,Engine_CSGO:	{
				switch(CS_GetClientTeam(target))	{
					case	CSTeam_Spectator:	{
						int picker = GetRandomInt(2, 3);
						
						if(swapInstant.BoolValue)	{
							SetClientTeamNum(target, picker);
							if(swapUpdateModel.BoolValue)
								CS_UpdateClientModel(target);
						}
						else
							ChangeClientTeam(target, picker);
						
						switch(picker)	{
							case	2:	teamname = "{red}Terrorists";
							case	3:	teamname = "{blue}Counter-Terrorists";
						}
					}
					case	CSTeam_Terrorist:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 3);
						else
							CS_ChangeClientTeam(target, CSTeam_CTerrorist);
							
						if(GetEngineVersion() == Engine_CSS)
							teamname = "{blue}Counter-Terrorists";
						else
							teamname = "{bluegrey}Counter-Terrorists";
					}
					case	CSTeam_CTerrorist:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 2);
						else
							CS_ChangeClientTeam(target, CSTeam_Terrorist);
							
						if(GetEngineVersion() == Engine_CSS)
							teamname = "{red}Terrorists";
						else
							teamname = "{orange}Terrorists";
					}
					default:	return Plugin_Handled;
				}
			}
			case	Engine_Left4Dead,Engine_Left4Dead2:	{
				switch(L4D_GetClientTeam(target))	{
					case	L4DTeam_Unassigned,L4DTeam_Spectator:	{
						int picker = GetRandomInt(2, 3);
						
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, picker);
						else
							ChangeClientTeam(target, picker);
							
						switch(picker)	{
							case	2:	teamname	=	"{orange}Survivors";
							case	3:	teamname	=	"{lightred}Zombies";
						}
					}
					case	L4DTeam_Survivor:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 3);
						else
							L4D_ChangeClientTeam(target, L4DTeam_Zombie);
						teamname	=	"{lightred}Zombies";
					}
					case	L4DTeam_Zombie:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 2);
						else
							L4D_ChangeClientTeam(target, L4DTeam_Survivor);
						teamname	=	"{orange}Survivors";
					}
					default:	return	Plugin_Handled;
				}
			}
			case	Engine_DODS:	{
				switch(DOD_GetClientTeam(target))	{
					case	DODTeam_Unassigned,DODTeam_Spectator:	{
						int picker = GetRandomInt(2, 3);
						
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, picker);
						else
							ChangeClientTeam(target, picker);
						
						switch(picker)	{
							case	2:	teamname	=	"{red}Wehrmacht";
							case	3:	teamname	=	"{blue}U.S Army.";
						}
					}
					case	DODTeam_Red:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 3);
						else
							DOD_ChangeClientTeam(target, DODTeam_Blue);
					}
					case	DODTeam_Blue:	{
						if(swapInstant.BoolValue)
							SetClientTeamNum(target, 2);
						else
							DOD_ChangeClientTeam(target, DODTeam_Red);
					}
					default:	return	Plugin_Handled;
				}
			}
		}
	}
	if(swapNotifySwapTeam.BoolValue)
		CPrintToChat(client, "%s %t",	swapPrefix,	"swapteam_target",	client,	target_name,	teamname);
	else
		CPrintToChatAll("%s %t",	swapPrefix,	"swapteam_target_client",	target_name,	teamname);

	return Plugin_Handled;	
}

Action SpecTeamPlayer(int client, int args)	{
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
	
	for (int i = 0; i < target_count; i++)	{
		if(GetClientTeam(target_list[i]) != 1)	{	//Checks if you're already in spectator team
			ChangeClientTeam(target_list[i], 1);
			teamname = "{grey}Spectator";
		}
		else
			return Plugin_Handled;
	}
	if(swapNotifySpecTeam.BoolValue)
		CPrintToChatAll("%s %t", swapPrefix, "swapteam_target", client, target_name, teamname);
	else
		CPrintToChat(client, "%s %t", swapPrefix, "swapteam_target_client", target_name, teamname);
	return Plugin_Handled;	
}

Action ExchangeTeamPlayer(int client, int args)	{
	if(args < 2)	{
		CPrintToChat(client, "%s %t", swapPrefix, "exchangeteam_usage");
		return	Plugin_Handled;
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
		
	for(int i = 0; i < target_count; i++)	{	
		int	client1	=	target_list[i],
			client2	=	target_list2[i],
			team1	=	GetClientTeam(target_list[i]),
			team2	=	GetClientTeam(target_list2[i]);
		
		if(team1 == team2)	{
			CPrintToChat(client, "%s %t", swapPrefix, "exchangeteam_error", target_name, target_name2);
			return	Plugin_Handled;
		}
		
		switch(GetEngineVersion())	{
			case	Engine_TF2:	{
				SetClientTeamNum(client1, team2);
				SetClientTeamNum(client2, team1);
				switch(team1)	{
					case	2:	teamname1	=	"{red}Red";
					case	3:	teamname1	=	"{blue}Blue";
					case	4:	teamname1	=	"{lightgreen}Green";
					case	5:	teamname1	=	"{yellow}Yellow";
					default:	return	Plugin_Handled;
				}
				switch(team2)	{
					case	2:	teamname2	=	"{red}Red";
					case	3:	teamname2	=	"{blue}Blue";
					case	4:	teamname2	=	"{lightgreen}Green";
					case	5:	teamname2	=	"{yellow}Yellow";
					default:	return	Plugin_Handled;
				}
			}
			case	Engine_CSS,Engine_CSGO:	{
				if(swapInstant.BoolValue)	{
					SetClientTeamNum(client1,	team2);
					SetClientTeamNum(client2,	team1);
					if(swapUpdateModel.BoolValue)	{
						CS_UpdateClientModel(client1);
						CS_UpdateClientModel(client2);
					}
				}
				else	{
					ChangeClientTeam(client1,	team2);
					ChangeClientTeam(client2,	team1);
					if(swapUpdateModel.BoolValue)	{
						CS_UpdateClientModel(client1);
						CS_UpdateClientModel(client2);
					}
				}
				switch(team1)	{
					case	2:	{
						if(GetEngineVersion() == Engine_CSGO)
							teamname1	=	"{orange}Terrorists";
						else
							teamname1	=	"{red}Terrorists";
					}
					case	3: teamname1	=	"{blue}Counter-Terrorists";
					default:	return	Plugin_Handled;
				}
				switch(team2)	{
					case	2:	{
						if(GetEngineVersion() == Engine_CSGO)
							teamname2	=	"{orange}Terrorists";
						else
							teamname2	=	"{red}Terrorists";
					}
					case	3: teamname2	=	"{blue}Counter-Terrorists";
					default:	return	Plugin_Handled;
				}
			}
		}
	}
	
	if(swapNotifyExchangeTeam.BoolValue)
		CPrintToChat(client,	"%s %t",	swapPrefix,	"exchangeteam_target",	client,	target_name, teamname2,	target_name2,	teamname1);
	else
		CPrintToChatAll("%s %t",	swapPrefix,	"exchangeteam_target_client", target_name, teamname2, target_name2, teamname1);
	
	return	Plugin_Handled;
}

Action	SpecTeam(int client, int args)	{
	ChangeClientTeam(client, 1);
}

Action ForceClientTeam(int client, int args)	{
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
	switch(GetEngineVersion())	{
		case	Engine_CSS,Engine_CSGO:	limit = 3;
		case	Engine_TF2:	{
			if(StrEqual(game,	"tf2classic"))
				limit = 5;
			else
				limit = 3;	
		}
		case	Engine_Left4Dead,Engine_Left4Dead2:	limit = 3;
	}
	
	if(value < 0)	{
		CPrintToChat(client,	"%s %t", swapPrefix, "forceteam_error_lower");
		return	Plugin_Handled;
	}
	else if(value > limit)	{
		CPrintToChat(client,	"%s %t", swapPrefix, "forceteam_error_over", limit);
		return	Plugin_Handled;
	}
	else	{
		for(int i = 0; i < MaxClients; i++)	{
			SetClientTeamNum(target_list[i], value);
		}
	}
	
	if(swapNotifyForceTeam.BoolValue)
		CPrintToChatAll("%s %t",			swapPrefix, "forceteam_target",	client,	value,	target_name);
	else
		CPrintToChat(client,	"%s %t",	swapPrefix,	"forceteam_target_client",	value,	target_name);
	
	return	Plugin_Handled;
}

Action ScramblePlayer(int client, int args)	{
	if(args != 1)	{
		CPrintToChat(client,	"%s %t", swapPrefix, "scrambleplayer_usage");
		return	Plugin_Handled;
	}
	
	char	arg1			[MAX_TARGET_LENGTH],
			target_name		[MAX_TARGET_LENGTH];
	int		target_list		[MAXPLAYERS],
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
		return	Plugin_Handled;
	}

	for(int i = 0; i < target_count; i++)	{
		int	target	=	target_list[i];
		
		int	teams;
		switch(GetEngineVersion())	{
			case	Engine_TF2:	{
				char	tf_game[32];
				GetGameFolderName(tf_game,	sizeof(tf_game));
				if(StrEqual(tf_game,	"tf2classic"))
					teams	=	5;
				else
					teams	=	3;
			}
			default:	teams	=	3;
		}
		int	picker	=	GetRandomInt(2,	teams);
		if(swapInstantScramble.BoolValue)
			SetClientTeamNum(target,	picker);
		else
			ChangeClientTeam(target,	picker);
	}
	
	if(swapNotifyScramble.BoolValue)
		CPrintToChatAll("%s %t",			swapPrefix, "scrambleplayer_target",	client,	target_name);
	else
		CPrintToChat(client,	"%s %t",	swapPrefix,	"scrambleplayer_target_client",	target_name);
	
	return Plugin_Handled;
}

Action ScrambleTeams(int client, int args)	{
	if(args != 0)	{
		CPrintToChat(client,	"%s %t", swapPrefix, "scrambleplayer_usage");
		return	Plugin_Handled;
	}	

	for(int i = 0; i < MaxClients; i++)	{
		int	target	=	i;
		
		int	teams;
		switch(GetEngineVersion())	{
			case	Engine_TF2:	{
				char	tf_game[32];
				GetGameFolderName(tf_game,	sizeof(tf_game));
				if(StrEqual(tf_game,	"tf2classic"))
					teams	=	5;
				else
					teams	=	3;
			}
			default:	teams	=	3;
		}
		int	picker	=	GetRandomInt(2,	teams);
		if(swapInstantScramble.BoolValue)
			SetClientTeamNum(target,	picker);
		else
			ChangeClientTeam(target,	picker);
	}
	
	if(swapNotifyScramble.BoolValue)
		CPrintToChatAll("%s %t",			swapPrefix, "scrambleteams_target");
	else
		CPrintToChat(client,	"%s %t",	swapPrefix,	"scrambleteams_target_client");
	
	return Plugin_Handled;
}