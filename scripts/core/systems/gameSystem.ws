importonly abstract class IGameSystem extends IScriptable
{
}

importonly struct gameSaveLock
{
	import var reason : gameSaveLockReason;
}

importonly abstract class gameIAutoSaveSystem extends IGameSystem
{
}

importonly class gameAutoSaveSystem extends gameIAutoSaveSystem
{
	public import function RequestCheckpoint() : Bool;
	public import function RequestForcedAutoSave() : Bool;
}

import enum gameGameVersion
{
	Current,
}

import enum gameSaveLockReason
{
	Nothing,
	Combat,
	Scene,
	Quest,
	Script,
	Boundary,
	MainMenu,
	LoadingScreen,
	PlayerStateMachine,
	PlayerState,
	Tier,
	NotEnoughSlots,
	NotEnoughSpace,
	PlayerOnMovingPlatform,
}

