importonly struct InteractionLayerData
{
	import var tag : CName;
}

importonly abstract class InteractionBaseEvent extends Event
{
	import var hotspot : weak< GameObject >;
	import var activator : weak< GameObject >;
	import var layerData : InteractionLayerData;
}

importonly class InteractionActivationEvent extends InteractionBaseEvent
{
	import var eventType : gameinteractionsEInteractionEventType;

	public import const function IsInputLayerEvent() : Bool;
}

importonly class InteractionChoiceEvent extends InteractionBaseEvent
{
	import var choice : InteractionChoice;
	import var actionType : gameinputActionType;
}

import enum gameinteractionsEInteractionEventType
{
	EIET_activate,
	EIET_deactivate,
}

