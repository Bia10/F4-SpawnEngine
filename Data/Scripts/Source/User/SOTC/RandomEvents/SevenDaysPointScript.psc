Scriptname SOTC:RandomEvents:SevenDaysPointScript extends ObjectReference
{ Seven Days to Die Event Script }
;Written by SMB92.
;Special thanks to J. Ostrus [BigandFlabby] for making this mod possible.

;LEGEND - PREFIX CONVENTION
; Variables and Properties are treated the same. Script types do not have prefixes, unless they
;are explicitly received as function arguments and are multi-instance scripts.
; "a" - (Function/Event Blocks only) Variable was received as function argument OR the variable
;was created from a passed-in Struct/Var[] member
; "k" - Is an "Object" as usual, whether created in a Block or defined in the empty state/a state.
; "f,b,i" - The usual Primitives: Float, Bool, Int.

;DEV NOTE: This event is included in the core of the F4-SpawnEngine

;LEGEND - EVENTS FRAMEWORK
;In order for Random Events to be added on by third parties at ease, this system uses Quests to
;instantiate their controller script for the "Event" and the MasterScript simply calls a setstage
;on the Quest in order to activate it (standard stage ID is 10). This eliminates the need to be
;reliant on using a template script or single object of any sort. Controller scripts may include
;a "helper" object which can be used to place in the world to do spawning work for the Event.

;There are currently 4 types of Events supported. They are as follows:
; 1. Bypass Events - These Events can be triggered at any time, based on a chance roll. They will
;"bypass" any Event locks in place. This is good for Events like Ghoul Apocalypse mode where we
;want that always random chance of the Event occurring.
; 2. Timed/Recurring Events - As you would assume, these Events recur according to a timer, which
;is set on the code for that Event.
; 3. Static Events - This type of Event has a chance to occur at any time, based on some conditions
;that can be setup for said Event specifically. This type of Event is subject to Event locks however.
; 4. Unique Events - This type of Event only fires once, and must be coded accordingly.

;So to explain how it works behind the scenes. Events Quests must be started from a Menu (so their 
;Quest must NOT be start game enabled). Upon doing so the Event will be coded to either add itself
;to the MasterScript's arrays of Event Quests based on it's type, or in the case of Timed Events,
;begin their timers and add themselves to the pending Events array when the timer runs out. When
;a SpawnPoint fires (currently RE system ONLY supports the Main SpawnPoint type, SpGroupPoint), the
;MasterScript will check for Events in the same order as listed above. Whenever an Event fires the
;MasterScript will store the SpawnPoint and it will become the Point of the Event. The SP script
;is not used itself, it is purely a location reference. With the exception of bypass events, after
;an Event has fired a "cooldown" timer will be started and a "lock" engaged so that no more Events
;can fire until the cooldown is over. Unique Events will be removed permanently and an accompanying
;GlobalVar will be set to prevent them from starting again (at least without forcing it).
;When Events are toggled off from the Menu, their Quest will be shutdown and their entry(s) removed
;from the Master arrays. Any Events that make use of Helper Points to do spawn work must be coded
;to clean themselves up after a set amount of time.


;------------------------------------------------------------------------------------------------
;PROPERTIES & IMPORTS
;------------------------------------------------------------------------------------------------

import SOTC:Struct_ClassDetails

SOTC:RandomEvents:SevenDaysQuestScript Property Controller Auto Const
{ Fill with the Controller Quest for this Event }

SOTC:ThreadControllerScript Property ThreadController Auto Const
{ Fill with ThreadController script }

ActorBase[] kGroupList ; The group of Spawned Actors



;------------------------------------------------------------------------------------------------
;SPAWN FUNCTION & EVENTS
;------------------------------------------------------------------------------------------------

;Function called by Controller to start the Event Spawn.
Function BeginSpawn(SOTC:ActorClassPresetScript aActorParamsScript)

	;Set the Params struct. Always use the "None" difficulty level (4)
	ClassDetailsStruct ActorParams = aActorParamsScript.ClassDetails[4] 
	

	;NEED TO COMPLETE

EndFunction

;------------------------------------------------------------------------------------------------
