import class PhysicalBodyInterface extends IScriptable
{
	public import function GetBodyIndex() : Int32;
	public import function IsSimulated() : Bool;
	public import function IsKinematic() : Bool;
	public import function IsQueryable() : Bool;
	public import function ToggleKinematic( flag : Bool );
	public import function SetTransform( pos : Transform );
	public import function GetTransform() : Transform;
	public import function AddLinearImpulse( impulse : Vector4, originInCOM : Bool, optional offset : Vector4 );
	public import function SetIsQueryable( enable : Bool );
	public import function SetIsKinematic( enable : Bool );
}

