import struct Quaternion
{
	import var i : Float;
	import var j : Float;
	import var k : Float;
	import var r : Float;

	public import static function SetIdentity( quat : Quaternion );
	public import static function SetInverse( quat : Quaternion );
	public import static function GetXAxis( quat : Quaternion ) : Vector4;
	public import static function GetYAxis( quat : Quaternion ) : Vector4;
	public import static function GetZAxis( quat : Quaternion ) : Vector4;
	public import static function GetForward( quat : Quaternion ) : Vector4;
	public import static function GetRight( quat : Quaternion ) : Vector4;
	public import static function GetUp( quat : Quaternion ) : Vector4;
	public import static function ToMatrix( quat : Quaternion ) : Matrix;
	public import static function ToEulerAngles( quat : Quaternion ) : EulerAngles;
	public import static function GetAxes( quat : Quaternion, out forward, right, up : Vector4 );
	public import static function Dot( a, b : Quaternion ) : Float;
	public import static function Rand( min, max : Float ) : Quaternion;
	public import static function Transform( quat : Quaternion, v : Vector4 ) : Vector4;
	public import static function TransformInverse( quat : Quaternion, v : Vector4 ) : Vector4;
	public import static function Normalize( quat : Quaternion );
	public import static function Normalized( quat : Quaternion ) : Quaternion;
	public import static function Magnitude( quat : Quaternion ) : Float;
	public import static function MagnitudeSq( quat : Quaternion ) : Float;
	public import static function MulInverse( q1, q2 : Quaternion ) : Quaternion;
	public import static function Conjugate( q : Quaternion ) : Quaternion;
	public import static function SetShortestRotation( q : Quaternion, v1, v2 : Vector4 );
	public import static function SetAxisAngle( out q : Quaternion, axis : Vector4, angle : Float );
	public import static function SetXRot( q : Quaternion, angle : Float );
	public import static function SetYRot( q : Quaternion, angle : Float );
	public import static function SetZRot( q : Quaternion, angle : Float );
	public import static function Lerp( q1, q2 : Quaternion, t : Float ) : Quaternion;
	public import static function Slerp( q1, q2 : Quaternion, t : Float ) : Quaternion;
	public import static function GetAngle( q : Quaternion ) : Float;
	public import static function GetAxis( q : Quaternion ) : Vector4;
	public import static function BuildFromDirectionVector( direction : Vector4, optional up : Vector4 ) : Quaternion;
}

import operator-( a : Quaternion ) : Quaternion;
import operator+( a : Quaternion, b : Quaternion ) : Quaternion;
import operator-( a : Quaternion, b : Quaternion ) : Quaternion;
import operator*( a : Quaternion, b : Quaternion ) : Quaternion;
import operator*( a : Quaternion, b : Float ) : Quaternion;
import operator*( a : Quaternion, b : Vector4 ) : Vector4;
import operator/( a : Quaternion, b : Float ) : Quaternion;
import operator+=( out a : Quaternion, b : Quaternion ) : Quaternion;
import operator-=( out a : Quaternion, b : Quaternion ) : Quaternion;
import operator*=( out a : Quaternion, b : Quaternion ) : Quaternion;
import operator*=( out a : Quaternion, b : Float ) : Quaternion;
import operator/=( out a : Quaternion, b : Float ) : Quaternion;
