importonly abstract class IVisionModeSystem extends IGameSystem
{
}

importonly final class VisionModeSystem extends IVisionModeSystem
{
	public import function EnterMode( activator : GameObject, mode : gameVisionModeType );
	public import function SetEntityVisionMode( id : EntityID, val : Bool );
	public import function SetChildEntityVisionMode( parentId : EntityID, childNodeRef : NodeRef, enable : Bool );
	public import function ForceVisionAppearance( entity : GameObject, appearance : VisionAppearance, optional transitionTime : Float );
	public import function CancelForceVisionAppearance( entity : GameObject, optional transitionTime : Float );
	public import function GetScanningController() : ScanningController;
	public import function RegisterActivatorCallback( activator : GameObject, listener : GameObject ) : Bool;
	public import function UnregisterActivatorCallback( activator : GameObject, listener : GameObject );
	public import function RegisterDelayedReveal( revealEntityId : EntityID, revealId : gameVisionModeSystemRevealIdentifier, delayTime : Float );
	public import function UnregisterDelayedReveal( revealEntityId : EntityID, revealId : gameVisionModeSystemRevealIdentifier );
	public import const function IsDelayedRevealInProgress( revealEntityId : EntityID, revealId : gameVisionModeSystemRevealIdentifier ) : Bool;
	public import const function GetDelayedRevealEntries( revealEntityId : EntityID, out revealIds : array< gameVisionModeSystemRevealIdentifier > );
}

