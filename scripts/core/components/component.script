importonly abstract class IComponent extends IScriptable
{
	public import const final function GetAppearanceName() : CName;
	public import const final function GetEntity() : weak< Entity >;
	protected import const final function FindComponentByName( componentName : CName ) : weak< IComponent >;
	public import const function GetName() : CName;
	public import const function IsEnabled() : Bool;
	public import function Toggle( on : Bool );
	public import function QueueEntityEvent( ev : Event );
	protected import function RegisterRenderDebug( filterName : String, functionName : CName );
}

