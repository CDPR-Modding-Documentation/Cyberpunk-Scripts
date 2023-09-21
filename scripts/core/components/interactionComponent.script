importonly class InteractionSetChoicesEvent extends Event
{
	import var choices : array< InteractionChoice >;
	import var layer : CName;
}

importonly class InteractionResetChoicesEvent extends Event
{
	import var layer : CName;
}

importonly class InteractionSetEnableEvent extends Event
{
	import var enable : Bool;
	import var linkedLayers : CName;
	import var layer : CName;
}

importonly class InteractionMultipleSetEnableEvent extends Event
{
	public import function PushBack( enable : Bool, layer : CName, optional linkedLayers : CName );
}

importonly final class InteractionComponent extends IPlacedComponent
{
	public import function SetSingleChoice( choice : InteractionChoice, optional layer : CName );
	public import function SetChoices( choices : array< InteractionChoice >, optional layer : CName );
	public import function ResetChoices( optional layer : CName, optional deactivate : Bool );
	public import const function GetActiveInputLayers( out activeInputLayers : array< gameinteractionsActiveLayerData > ) : Bool;
	public import const function GetActivatorsForLayer( layerName : CName, out activeInputLayers : array< gameinteractionsActiveLayerData > ) : Bool;
}

