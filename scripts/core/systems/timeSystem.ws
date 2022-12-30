importonly class TimeDilatable extends GameObject
{
	public import final function HasIndividualTimeDilation( optional reason : CName ) : Bool;
	public import final function SetIndividualTimeDilation( reason : CName, dilation : Float, optional duration : Float, optional easeInCurve : CName, optional easeOutCurve : CName, optional ignoreGlobalDilation : Bool );
	public import final function UnsetIndividualTimeDilation( optional easeOutCurve : CName );
	public import final function GetTimeDilationValue() : Float;
	public import final function IsIgnoringGlobalTimeDilation() : Bool;
	public import final function IsIgnoringTimeDilation() : Bool;
}

importonly abstract class tickITimeDilationListener extends IScriptable
{
}

importonly class TimeDilationListener extends tickITimeDilationListener
{
}

importonly abstract class gameITimeSystem extends IReplicatedGameSystem
{
}

import final class TimeSystem extends gameITimeSystem
{
	public import final function SetGameTimeBySeconds( seconds : Int32 );
	public import final function SetGameTimeByHMS( hours : Int32, minutes : Int32, seconds : Int32, optional reason : CName );
	public import final function GetGameTime() : GameTime;
	public import final function GetGameTimeStamp() : Float;
	public import final function GetSimTime() : EngineTime;
	public import final function RealTimeSecondsToGameTime( seconds : Float ) : GameTime;
	public import final function SetTimeDilation( reason : CName, dilation : Float, optional duration : Float, optional easeInCurve : CName, optional easeOutCurve : CName, optional listener : TimeDilationListener );
	public import final function UnsetTimeDilation( reason : CName, optional easeOutCurve : CName );
	public import final function SetIgnoreTimeDilationOnLocalPlayerZero( ignore : Bool );
	public import final function SetTimeDilationOnLocalPlayerZero( reason : CName, dilation : Float, optional duration : Float, optional easeInCurve : CName, optional easeOutCurve : CName, optional ignore : Bool );
	public import final function UnsetTimeDilationOnLocalPlayerZero( optional easeOutCurve : CName );
	public import final function IsTimeDilationActive( optional reason : CName ) : Bool;
	public import final function GetActiveTimeDilation( optional reason : CName, optional ignoreCurves : Bool ) : Float;
	public import final function RegisterListener( entity : weak< Entity >, eventToDelay : Event, expectedTime : GameTime, repeat : Int32, optional sendOldNoifications : Bool ) : Uint32;
	public import final function RegisterDelayedListener( entity : weak< Entity >, eventToDelay : Event, delay : GameTime, repeat : Int32, optional sendOldNoifications : Bool ) : Uint32;
	public import final function RegisterIntervalListener( entity : weak< Entity >, eventToDelay : Event, expectedHour : GameTime, timeout : GameTime, optional repeat : Int32 ) : Uint32;
	public import final function UnregisterListener( listenerID : Uint32 );
	public import final function RegisterScriptableSystemIntervalListener( systemName : CName, requestToDelay : ScriptableSystemRequest, expectedHour : GameTime, timeout : GameTime, optional repeat : Int32 ) : Uint32;
	public import testonly function SetPausedState( paused : Bool, source : CName );
	public import function IsPausedState() : Bool;
}

exec function Slowmo( gameInstance : GameInstance )
{
	GameInstance.GetTimeSystem( gameInstance ).SetTimeDilation( 'consoleCommand', 0.1 );
}

exec function Noslowmo( gameInstance : GameInstance )
{
	GameInstance.GetTimeSystem( gameInstance ).UnsetTimeDilation( 'consoleCommand' );
}

exec function SetTimeDilation( gameInstance : GameInstance, amount : String )
{
	var famount : Float;
	famount = StringToFloat( amount );
	if( famount > 0.0 )
	{
		GameInstance.GetTimeSystem( gameInstance ).SetTimeDilation( 'consoleCommand', famount );
	}
	else
	{
		GameInstance.GetTimeSystem( gameInstance ).UnsetTimeDilation( 'consoleCommand' );
	}
}

