import struct Transform
{
	import var position : Vector4;
	import var orientation : Quaternion;

	public static function Create( position : Vector4, optional orientation : Quaternion ) : Transform
	{
		var t : Transform;
		t.position = position;
		t.orientation = orientation;
		return t;
	}

	public import static function TransformPoint( xform : Transform, v : Vector4 ) : Vector4;
	public import static function TransformVector( xform : Transform, v : Vector4 ) : Vector4;
	public import static function ToEulerAngles( xform : Transform ) : EulerAngles;
	public import static function ToMatrix( xform : Transform ) : Matrix;
	public import static function GetForward( xform : Transform ) : Vector4;
	public import static function GetRight( xform : Transform ) : Vector4;
	public import static function GetUp( xform : Transform ) : Vector4;
	public import static function GetPitch( xform : Transform ) : Float;
	public import static function GetYaw( xform : Transform ) : Float;
	public import static function GetRoll( xform : Transform ) : Float;
	public import static function SetIdentity( xform : Transform );
	public import static function SetInverse( xform : Transform );
	public import static function GetInverse( xform : Transform ) : Transform;
	public import static function GetPosition( xform : Transform ) : Vector4;
	public import static function GetOrientation( xform : Transform ) : Quaternion;
	public import static function SetPosition( xform : Transform, v : Vector4 );
	public import static function SetOrientation( xform : Transform, quat : Quaternion );
	public import static function SetOrientationEuler( xform : Transform, euler : EulerAngles );
	public import static function SetOrientationFromDir( xform : Transform, direction : Vector4 );
}

import operator*( xform : Transform, v : Vector4 ) : Vector4;
import operator*( xform1 : Transform, xform2 : Transform ) : Transform;
