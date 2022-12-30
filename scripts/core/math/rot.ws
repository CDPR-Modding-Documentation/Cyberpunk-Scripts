import struct EulerAngles
{
	import var Roll : Float;
	import var Pitch : Float;
	import var Yaw : Float;

	public import static function GetXAxis( rotation : EulerAngles ) : Vector4;
	public import static function GetYAxis( rotation : EulerAngles ) : Vector4;
	public import static function GetZAxis( rotation : EulerAngles ) : Vector4;
	public import static function GetForward( rotation : EulerAngles ) : Vector4;
	public import static function GetRight( rotation : EulerAngles ) : Vector4;
	public import static function GetUp( rotation : EulerAngles ) : Vector4;
	public import static function ToMatrix( rotation : EulerAngles ) : Matrix;
	public import static function ToQuat( rotation : EulerAngles ) : Quaternion;
	public import static function GetAxes( rotation : EulerAngles, out forward, right, up : Vector4 );
	public import static function Dot( a, b : EulerAngles ) : Float;
	public import static function Rand( min, max : Float ) : EulerAngles;
	public import static function AlmostEqual( a : EulerAngles, b : EulerAngles, epsilon : Float ) : Bool;
}

function GetOppositeRotation180( rot : EulerAngles ) : EulerAngles
{
	var ret : EulerAngles;
	ret.Pitch = AngleNormalize180( rot.Pitch + 180.0 );
	ret.Yaw = AngleNormalize180( rot.Yaw + 180.0 );
	ret.Roll = AngleNormalize180( rot.Roll + 180.0 );
	return ret;
}

