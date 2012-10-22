/**
* Round Timer Manager by Root
*
* Description:
*   Manages round timer when game starts, TNT explodes or object is about to be destroyed.
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

// ====[ INCLUDES ]======================================================
#include <sourcemod>
#include <sdktools>
#include <dodhooks>

// ====[ CONSTANTS ]=====================================================
#define PLUGIN_NAME    "Round Timer Manager"
#define PLUGIN_VERSION "1.0"

// ====[ VARIABLES ]=====================================================
new Handle:rtmanager_roundstart  = INVALID_HANDLE,
	Handle:rtmanager_bombexplode = INVALID_HANDLE,
	Handle:rtmanager_objexplode  = INVALID_HANDLE

// ====[ PLUGIN ]========================================================
public Plugin:myinfo =
{
	name			= PLUGIN_NAME,
	author			= "Root",
	description		= "Manages round timer on bomb maps",
	version			= PLUGIN_VERSION,
	url				= "http://dodsplugins.com/"
}


/* OnPluginStart()
 *
 * When the plugin starts up.
 * --------------------------------------------------------------------------- */
public OnPluginStart()
{
	// Create ConVars
	CreateConVar("rtmanager_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED)
	rtmanager_roundstart  = CreateConVar("dod_roundtimer_start", "420", "Set the time remaining for a round (in seconds)",                           FCVAR_PLUGIN, true, 0.0)
	rtmanager_bombexplode = CreateConVar("dod_roundtimer_bomb",  "30",  "Specified how many seconds add when TNT is just exploded",                  FCVAR_PLUGIN, true, 0.0)
	rtmanager_objexplode  = CreateConVar("dod_roundtimer_score", "180", "How many seconds add when object is exploded/captured\nBomb time ignored!", FCVAR_PLUGIN, true, 0.0)

	// Hook events
	HookEvent("dod_round_start",   Event_round_start)
	HookEvent("dod_bomb_exploded", Event_bomb_exploded)

	// We're going to rewrite an event
	HookEvent("dod_timer_time_added", Event_time_added, EventHookMode_Pre)

	// Create and exec plugin configuration file
	AutoExecConfig(true, "roundtimer_manager")
}

/* Event_round_starts()
 *
 * Called when a round starts.
 * --------------------------------------------------------------------------- */
public Event_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	// If custom round timer is specified, accept changes for entity
	if (GetConVarInt(rtmanager_roundstart) > 0)
	{
		// Searches for an entity by classname
		new roundTimer = FindEntityByClassname(-1, "dod_round_timer")

		if (roundTimer != -1)
		{
			// Sets time remaining on the round timer specified
			SetTimeRemaining(roundTimer, GetConVarInt(rtmanager_roundstart))
		}
	}
}

/* Event_bomb_exploded()
 *
 * Called when TNT explodes.
 * --------------------------------------------------------------------------- */
public Event_bomb_exploded(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(rtmanager_bombexplode) > 0)
	{
		new roundTimer = FindEntityByClassname(-1, "dod_round_timer")

		if (roundTimer != -1)
		{
			// Returns time remaining on the round timer specified
			new Float:flTimeRemaining = GetTimeRemaining(roundTimer)
			SetTimeRemaining(roundTimer, (RoundToZero(flTimeRemaining) + GetConVarInt(rtmanager_bombexplode)))
		}
	}
}

/* Event_time_added()
 *
 * Called when time is added (in bombing maps).
 * --------------------------------------------------------------------------- */
public Event_time_added(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(rtmanager_objexplode) > 0)
	{
		new roundTimer = FindEntityByClassname(-1, "dod_round_timer")

		// Check if entity is valid
		if (roundTimer != -1)
		{
			new Float:flTimeRemaining = GetTimeRemaining(roundTimer)

			// Convert float to an integer
			SetTimeRemaining(roundTimer, (RoundToZero(flTimeRemaining) + GetConVarInt(rtmanager_objexplode) - GetConVarInt(rtmanager_bombexplode) - 120))
		}

		// Draw custom 'minutes added' panel
		SetEventInt(event, "seconds_added", GetConVarInt(rtmanager_objexplode))
	}
}