Scriptname SOTC:SpawnTypeRegionalScript extends ReferenceAlias
{ Holds dynamic Actor lists for a "Spawntype", aka category of spawns. Attach to an alias on the 
owning RegionQuest }
;Written by SMB92
;Special thanks to J. Ostrus [BigandFlabby] for code contributions that made this mod possible.


;NOTE - This script has now been made to hold 3 lists, one for each Rarity,
;instead of having an array of 3 SpawnTypeActorListScripts for a multi-dim array.
;This alleviates a large number of aliases needed for instancing said scripts, at
;the cost of not being able to add new "rarity levels" easily. Tradeoff is much
;better anyway, although a small performance hit is taken when shuffling Actor
;lists here as they now need to be run through a function and presets compared,
;instead of being directly sent to the right list.

;LEGEND - PREFIX CONVENTION
; Variables and Properties are treated the same. Script types do not have prefixes, unless they
;are explicitly received as function arguments and are multi-instance scripts.
; "a" - (Function/Event Blocks only) Variable was received as function argument OR the variable
;was created from a passed-in Struct/Var[] member
; "k" - Is an "Object" as usual, whether created in a Block or defined in the empty state/a state.
; "f,b,i" - The usual Primitives: Float, Bool, Int.

;------------------------------------------------------------------------------------------------
;PROPERTIES & IMPORTS
;------------------------------------------------------------------------------------------------

Group PrimaryProperties

	SOTC:MasterQuestScript Property MasterScript Auto Const
	{ Fill with MasterQuest }
	
	SOTC:ThreadControllerScript Property ThreadController Auto Const
	{ Fill with ThreadController Alias }

	SOTC:SpawnTypeMasterScript Property LibraryScript Auto Const
	{ Fill with corresponding Master for this Spawntype. Provides quick link to Master Properties }

	SOTC:RegionQuestScript Property RegionScript Auto Const
	{ Fill with owning Region Quest }

	Int Property iSpawnType Auto Const
	{ Initialise with intended Spawntype ID. Inserts at this index on RegionalQuestScript }
	;LEGEND - SPAWNTYPES
	;Spawntypes are essentially "categories" of spawns and species. These are used to provide
	;variety of spawns in different locations. Each SpawnType has a Master Script, which holds
	;the Master list of all Actor types in that category, as well as a Regional script, which
	;defines which Actors of that Spawntype are allowed in that Region (and can also have their
	;"Rarity" defined for that area). They are as follows: (subject to additional types)
	;(NOTE: It is possible for some Actors to be of "mixed" type and appear in multiple lists)
	; [0] - MAIN/MIXED RANDOM - consider this like "urban" spawns, the most common type used
	;This is essentially a random list of anything and everything that would be common enough 
	;to spawn in an area.
	; [1] - URBAN - Minimal Wildlife
	; [2] - WILD - Common wild area stuff
	; [3] - RADSPAWN - Radiated areas spawns
	; [4] - HUMAN
	; [5] - MUTANT
	; [6] - WILDLIFE
	; [7] - INSECT
	; [8] - MONSTER
	; [9] - ROBOT
	; [10] - AQUATIC - Given the lack of real Aquatic spawns, this includes other things that
	;might appear in swamp/marsh/waterside etc.
	; [11] - SNIPER - This end up warranting it's own category. This is also a "Class". Any Actor type
	;that has this Class defined will be featured in this Spawntype.
	; [12] - STORY - Story Mode/Actors will not appear in the initial beta and is subject to feedback.
	;The following were dropped from being a Spawntype:
	; AMBUSH - This is still a "Class". Reasoning is that one can define specific parameters and group
	;loadouts in order to create highly customised Ambushes
	; INFESTATION/SWARM - THis has evolved into a Feature, and while bonus params can still be defined
	;on the ActorScript, it is no longer a Spawntype and can now happen at anytime (when setting active)

	Int Property iWorldID Auto Const
	{ Fill with correct World ID }
	; LEGEND - WORLDS
	; [0] - COMMONWEALTH
	; [1] - FAR HARBOR
	; [2] - NUKA WORLD

	Int Property iRegionID Auto Const
	{ Fill with correct RegionID }
	
	Int Property iCurrentPreset Auto
	{ Initialise 0. Set by Menu/Preset. Determines each Actors Rarity in this Spawntype/Region }
	
	Bool Property bSpawnTypeEnabled Auto
	{ Init True. All are enabled by default. }
	
	Bool Property bCustomSettingsActive Auto
	{ Init False. Set by Menu when custom settings have been applied. For this script,
	this is only to tell that Preset has been changed manually }

EndGroup


Group ActorLists
{ Dynamic Actor Lists }

	ActorQuestScript[] Property CommonActorList Auto  ;Class 1
	{ Initialise one member of None. Fills dynamically upon initialisation }

	ActorQuestScript[] Property UncommonActorList Auto  ;Class 2
	{ Initialise one member of None. Fills dynamically upon initialisation }

	ActorQuestScript[] Property RareActorList Auto  ;Class 3
	{ Initialise one member of None. Fills dynamically upon initialisation }

EndGroup


Group LootSystemProperties

	Bool Property bLootSystemEnabled Auto 
	{ Init False. Set in Menu. When on, spawned Actors of this type may possibly 
	receive a loot item from one of the Formlists below }
	
	Formlist Property kRegularLootList Auto Const
	{ Fill with Formlist made for this Actor Type's regular loot }
	
	Formlist Property kBossLootList Auto Const
	{ Fill with Formlist made for this Actor Type's boss loot }
	
	Int Property iRegularLootChance Auto
	{ Init 20. Change in Menu. Chance an Actor will receive a loot item }
	
	Int Property iBossLootChance Auto
	{ Init 10. Change in Menu. Chance an Actor will receive a loot item }

EndGroup

;LEGEND - LOOT SYSTEM
;There are 2 ways to provide random spawns with a random loot item (or more if using a Use All 
;flagged Leveled List) - through the SpawnTypeRegionalScript or the ActorQuestScript. Both systems
;are identical in function and setup, but can operate independantly. The system works by storing
;formlists on each of the scripts, 1 for regular Actors and 1 for Boss Actors. Spawnpoints will
;check both scripts after spawntime (after all actors are placed in game and packages applied,
;preventing unnecessary slowdown in the spawnloops themselves), and if this system is enabled, it
;will send in the GroupList for that Spawnpoint and do a loop to add a single item from the list to
;each Actors inventory, based on a configurable chance value. The single item can be a Leveled List, 
;and if it is marked to Use All, will add every item from that list.

;Loot on the Spawntype script should be applicable to all Actors in that Spawntype, this intended
;to be a generalised loot table. The reason why this system is included on the Region Spawntype 
;script, and not the Master Spawntype, is so we can specify different loot per Region if we wish.
;Loot on the ActorQuestScript is obviously so we can supply highly specific loot for each Actor type. 
;As mentioned above, either can be enabled/disabled, they are independant from each other. Chance of
;loot values can be defined for both Regular and Boss Actors independantly on each script as well. 

;Fun fact: It was originally an idea to provide loot by using a RefCollectionAlias with specified
;Leveled Lists, and then add Actors to this coolection so they'd automatically get the loot without
;any coding necessary. However, this posed some complications for third-party addons as far as using
;scripts to add loot, and thus I developed the formlist approach, so that now addons can both safely
;add and remove loot items from the list via script. It is also useful in the same sense for adding
;temporary loot to the lists, in case we want to do so for some event such as a quest etc. 

Bool bInit ;Security measure to prevent unwanted Init events

;------------------------------------------------------------------------------------------------
;INITIALISATION & SETTINGS EVENTS
;------------------------------------------------------------------------------------------------

;First startup event
Event OnAliasInit()

	if !bInit
		RegionScript.SpawnTypes.Insert(Self, iSpawnType)
		RegisterForCustomEvent(MasterScript, "SingleSpawntypePresetUpdate")
		bInit = true
	endif
	
EndEvent


;Received by all SPawntypes, but only proceeds if ID number matches. 
Event SOTC:MasterQuestScript.SingleSpawntypePresetUpdate(SOTC:MasterQuestScript akSender, Var[] akArgs)

	if (akArgs[0] as Int == iSpawnType) && (!bCustomSettingsActive) || (akArgs[1] as Bool) ;If not Custom OR Override = true
	
			ReshuffleDynActorLists(true, akArgs[2] as Int) ;(akArgs[2]) Preset to Set
			
	endif

EndEvent


;Usually called by Region script during Preset changes
Function ReshuffleDynActorLists(Bool bForceReset, int aiPreset)

	if (bCustomSettingsActive) && (!bForceReset)
		return ;DENIED
	endif
	;else continue.
	
	if aiPreset > 0 ;If 0, just reshuffle as normal. While likely unused, exists if needed.
		iCurrentPreset = aiPreset ;Set the Preset here
	endif
	ClearDynActorLists()
	FillDynActorLists()

EndFunction


;Fill Actor lists on this script, placing into correct lists as per Preset. This script does not
;have to be aware of the iCurrentPreset value on the Master. 
Function FillDynActorLists()

	ActorQuestScript[] ActorList = LibraryScript.ActorLibrary ;Link to master array
	;We won't store this in a permanent variable, we only need to know about it here

	int iSize = ActorList.Length 
	int iCounter = 0
	Int iActorPreset
	
	while iCounter < iSize ;Won't overshoot
	
		iActorPreset = ActorList[iCounter].WorldPresets[iWorldID].GetActorRegionPreset(iRegionID, iCurrentPreset)
		;This is a necessary evil
		
		if iActorPreset == 1 ;Common
			CommonActorList.Add(ActorList[iCounter])
		elseif iActorPreset == 2 ;Uncommon
			UncommonActorList.Add(ActorList[iCounter])
		elseif iActorPreset == 3 ;Rare
			RareActorList.Add(ActorList[iCounter])
		;else
			;Do nothing, Actor is disabled in this Region or unexpected Int returned
			;Maybe add debug here if this seems to be an issue
		endif
		
		iCounter += 1
	
	endwhile

EndFunction

;Clear all Actor lists on this script
Function ClearDynActorLists()

	CommonActorList.Clear()
	UncommonActorList.Clear()
	RareActorList.Clear()
	
EndFunction


;------------------------------------------------------------------------------------------------
;RETURN FUNCTIONS
;------------------------------------------------------------------------------------------------

;Return single instance of ActorClassPresetScript (single Actor)
;NOTE - This returns class presets directly, as this saves storing/determining "rarity" elsewhere
SOTC:ActorClassPresetScript Function GetRandomActor(bool abForcedRarity, int aiForcedRarity)
;WARNING - Using "forced" params can only be used to get "Rarity" based Classes from here!
	
	int iRarity 
	
	if abForcedRarity ;Check if we are forcing a specific rarity list to be used
		iRarity = aiForcedRarity
	else
		iRarity = MasterScript.RollForRarity() ;Roll if not
	endif
	
	int iSize ;Put into top block in case of reuse
	
	if iRarity == 1
		iSize = CommonActorList.Length - 1
		return CommonActorList[(Utility.RandomInt(0,iSize))].ClassPresets[iRarity] ;GTFO
		
	elseif iRarity == 2
		iSize = UncommonActorList.Length - 1
		return CommonActorList[(Utility.RandomInt(0,iSize))].ClassPresets[iRarity] ;GTFO
		
	else ;Not going to bother checking for 3, if somehow its not 1,2 or 3, Rare will be selected
		iSize = RareActorList.Length - 1
		return RareActorList[(Utility.RandomInt(0,iSize))].ClassPresets[iRarity] ;GTFO
		
	endif
	
EndFunction

;NOTE - All functionality for random swarms and ambushes is moved to Spawnpoint script. It remains
;possible the code could be moved back to here if a nicer method is found.

;Return array of ActorClassPresetScript (multiple Actors)
;NOTE - This returns class presets directly, as this saves storing/determining "rarity" elsewhere
SOTC:ActorClassPresetScript[] Function GetRandomActors(bool abForcedRarity, int aiForcedRarity, int aiNumActorsRequired)
;WARNING - Using "forced" params can only be used to get "Rarity" based Classes from here!
	
	ActorClassPresetScript[] ActorListToReturn = new ActorClassPresetScript[0] ;Temp array used to send back
	int iRarity ;which list to use
	int iSize ;size of list to use
	int iCounter = 0 ;Count up to required amount
	
	;if RegionScript.bRandomInfestEnabled ETC ETC
	
	while iCounter < aiNumActorsRequired ;Maximum of 5 in default mod. Modders may use more.
		
		if abForcedRarity ;
			iRarity = aiForcedRarity
		else
			iRarity = MasterScript.RollForRarity() ;Roll each time
		endif
		
		if iRarity == 1
			iSize = CommonActorList.Length - 1
			ActorListToReturn.Add((CommonActorList[(Utility.RandomInt(0,iSize))]).ClassPresets[iRarity]) ;Add to list
			
		elseif iRarity == 2
			iSize = UncommonActorList.Length - 1
			ActorListToReturn.Add((UncommonActorList[(Utility.RandomInt(0,iSize))]).ClassPresets[iRarity]) ;Add to list
			
		else ;Not going to bother checking for 3, if somehow its not 1,2 or 3, Rare will be selected
			iSize = RareActorList.Length - 1
			ActorListToReturn.Add((RareActorList[(Utility.RandomInt(0,iSize))]).ClassPresets[3]) ;Add to list
			
		endif
		
	endwhile
	
	;endif
	
	return ActorListToReturn ;GTFO
	
EndFunction


;------------------------------------------------------------------------------------------------
;LOOT FUNCTIONS
;------------------------------------------------------------------------------------------------

;Run a chance loop on a Spawnpoints Grouplist, potentially adding a loot item to each Actor in the list.
Function DoLootPass(Actor[] akGroupList, Int aiBossCount)
	
	Int iCounter 
	Int iGroupSize = akGroupList.Length
	Int iLootListSize = (kRegularLootList.GetSize()) -1 ;Actual index count
	Form kLootItem
	
	;Regular Actors inlcuing Bosses if present
	
	while iCounter < iGroupSize
		
		if (Utility.RandomInt(1,100)) < iRegularLootChance
			kLootItem = kRegularLootList.GetAt((Utility.RandomInt(0, iLootListSize))) ;Select random item
			akGroupList[iCounter].AddItem(kLootItem, 1, true) ;Add to this Actor
		endif
			
		iCounter += 1
			
	endwhile
		
	if aiBossCount > 0
	
		iLootListSize = (kBossLootList.GetSize()) -1 ;Actual index count
		iCounter = (iGroupSize) - (aiBossCount) ;Start Counter where Bosses start on the list
		
		while iCounter < iGroupSize
		
			if (Utility.RandomInt(1,100)) < iBossLootChance
				kLootItem = kBossLootList.GetAt((Utility.RandomInt(0, iLootListSize))) ;Select random item
				akGroupList[iCounter].AddItem(kLootItem, 1, true) ;Add to this Actor
			endif
			
			iCounter += 1
			
		endwhile
		
	endif

EndFunction


;------------------------------------------------------------------------------------------------
