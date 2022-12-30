importonly abstract class IVisualComponent extends IPlacedComponent
{
	public import function TemporaryHide( on : Bool );
}

importonly final class enteventsSetVisibility extends Event
{
	import var visible : Bool;
	import var source : entVisibilityParamSource;
}

import enum entVisibilityParamSource : Uint8
{
	PhantomEntitySystem,
}

