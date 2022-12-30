importonly abstract class IMovingPlatformMovement extends IScriptable
{
	public import function SetInitData( type : gameMovingPlatformMovementInitializationType, value : Float );
}

importonly abstract class IMovingPlatformMovementPointToPoint extends IMovingPlatformMovement
{
	public import function SetDestinationLocalPosition( endPointLocal : Vector4 );
	public import function SetDestinationNode( endNode : NodeRef );
}

importonly class MovingPlatformMovementLinear extends IMovingPlatformMovementPointToPoint
{
}

importonly class MovingPlatformMovementDynamic extends IMovingPlatformMovementPointToPoint
{
	import var curveName : CName;
}

importonly class MoveTo extends Event
{
	import var movement : IMovingPlatformMovement;
	import var destinationName : CName;
	import var data : Int32;
}

importonly class ArrivedAt extends Event
{
	import var destinationName : CName;
	import var data : Int32;
}

importonly class BeforeArrivedAt extends Event
{
}

importonly class MovingPlatform extends IPlacedComponent
{
	public import function Pause() : Float;
	public import function Unpause( time : Float ) : gamePlatformMovementState;
	public import function IsActive() : Bool;
}

importonly class TeleportTo extends Event
{
	import var destinationNode : NodeRef;
	import var rootEntityPosition : Vector4;
}

import enum gamePlatformMovementState
{
	Stopped,
	Paused,
	MovingUp,
	MovingDown,
}

import enum gameMovingPlatformMovementInitializationType
{
	Time,
	Speed,
}

import enum gameMovingPlatformLoopType
{
	NoLooping,
	Bounce,
	Repeat,
}

