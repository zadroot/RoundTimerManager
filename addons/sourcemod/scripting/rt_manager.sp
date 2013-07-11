/**
* Round Timer Manager by Root
*
* Description:
*   Manages round timer when game starts, TNT explodes or an object is about to be destroyed.
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

// ====[ INCLUDES ]=======================================================
#include <sdktools>
#include <dodhooks>

// ====[ CONSTANTS ]======================================================
#define PLUGIN_NAME    "Round Timer Manager"
#define PLUGIN_VERSION "1.0"

// ====[ VARIABLES ]======================================================
new	Handle:rtmanager_roundstart  = INVALID_HANDLE,
	Handle:rtmanager_bombexplode = INVALID_HANDLE,
	Handle:rtmanager_objexplode  = INVALID_HANDLE

// ====[ PLUGIN ]=========================================================
public Plugin:myinfo =
{
	name        = PLUGIN_NAME,
	author      = "Root",
	description = "Manages round timer on maps with round timer",
	version     = PLUGIN_VERSION,
	url         = "http://dodsplugins.com/"
}


/* OnPluginStart()
 *
 * When the plugin starts up.
 * ----------------------------------------------------------------------- */
public OnPluginStart()
{
	CreateConVar("rtmanager_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD)

	// Create console variables for configurations
	rtmanager_roundstart  = CreateConVar("dod_roundtimer_start", "420", "Set the time remaining for a round (in seconds)",                           FCVAR_PLUGIN, true, 0.0)
	rtmanager_bombexplode = CreateConVar("dod_roundtimer_bomb",  "30",  "Specified how many seconds add when TNT is just exploded",                  FCVAR_PLUGIN, true, 0.0)
	rtmanager_objexplode  = CreateConVar("dod_roundtimer_score", "180", "How many seconds add when object is exploded/captured\nBomb time ignored!", FCVAR_PLUGIN, true, 0.0)

	// Hook events which deal with round timer
	HookEvent("dod_round_start",      OnRoundStart,   EventHookMode_PostNoCopy)
	HookEvent("dod_bomb_exploded",    OnBombExploded, EventHookMode_PostNoCopy)
	HookEvent("dod_timer_time_added", OnTimeAdded,    EventHookMode_Pre)

	AutoExecConfig(true, "roundtimer_manager")
}

/* OnRoundStarts()
 *
 * Called when a round starts.
 * ----------------------------------------------------------------------- */
public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	// If custom round time is specified, accept changes for an entity
	if (GetConVarInt(rtmanager_roundstart))
	{
		// Firstly lets search for round timer entity
		new roundTimer = FindEntityByClassname(-1, "dod_round_timer")

		if (roundTimer != -1)
		{
			// Sets time remaining on the round timer specified
			SetTimeRemaining(roundTimer, GetConVarInt(rtmanager_roundstart))
		}
	}
}

/* OnBombExploded()
 *
 * Called when TNT explodes.
 * ----------------------------------------------------------------------- */
public OnBombExploded(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Once again check if value is specified
	if (GetConVarInt(rtmanager_bombexplode))
	{
		new roundTimer = FindEntityByClassname(-1, "dod_round_timer")

		if (roundTimer != -1)
		{
			// Returns time remaining on the round timer specified
			SetTimeRemaining(roundTimer, (RoundToZero(GetTimeRemaining(roundTimer)) + GetConVarInt(rtmanager_bombexplode)))
		}
	}
}

/* OnTimeAdded()
 *
 * Called when time is added (in bombing maps).
 * ----------------------------------------------------------------------- */
public OnTimeAdded(Handle:event, const String:name[], bool:dontBroadcast)
{
	new roundTimer = FindEntityByClassname(-1, "dod_round_timer")
	if (roundTimer != -1)
	{
		// Convert float to an integer, and other than than we should deduct timer when bomb is exploded + default time added
		SetTimeRemaining(roundTimer, (RoundToZero(GetTimeRemaining(roundTimer)) + GetConVarInt(rtmanager_objexplode) - GetConVarInt(rtmanager_bombexplode) - 120))

		// Draw own 'minutes added' element
		SetEventInt(event, "seconds_added", GetConVarInt(rtmanager_objexplode))
	}
}