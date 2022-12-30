importonly final class gameVisionModuleEvent extends Event
{
	import var changedModule : CName;
	import var activated : Bool;
	import var activator : weak< GameObject >;
}

importonly final class gameVisionModeEvent extends Event
{
	import var activated : Bool;
	import var type : gameVisionModeType;
}

importonly final class gameVisionModeVisualEvent extends Event
{
	import var group : TweakDBID;
	import var changedModule : CName;
	import var activated : Bool;
	import var meshComponentName : CName;
	import var type : gameVisionModeType;
}

importonly class gameVisionModeHideEvent extends Event
{
	import var hide : Bool;
	import var type : gameVisionModeType;
}

importonly final class gameVisionModeUpdateVisuals extends Event
{
	import var pulse : Bool;
}

importonly final class gameVisionModeMappinEvent extends Event
{
	import var show : Bool;
}

importonly final class gameVisionRevealExpiredEvent extends Event
{
	import var revealId : gameVisionModeSystemRevealIdentifier;
}

