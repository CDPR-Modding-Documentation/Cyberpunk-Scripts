importonly abstract class IPlacedComponent extends IComponent
{
	public import function GetLocalToWorld() : Matrix;
	public import function GetInitialPosition() : Vector4;
	public import function GetInitialOrientation() : Quaternion;
	public import function GetInitialTransform() : Matrix;
	public import function GetLocalPosition() : Vector4;
	public import function GetLocalOrientation() : Quaternion;
	public import function GetLocalTransform() : Matrix;
	public import function SetLocalPosition( pos : Vector4 );
	public import function SetLocalOrientation( rot : Quaternion );
	public import function SetLocalTransform( pos : Vector4, rot : Quaternion );
}

