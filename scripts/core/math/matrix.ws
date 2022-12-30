import struct Matrix
{
	import var X : Vector4;
	import var Y : Vector4;
	import var Z : Vector4;
	import var W : Vector4;

	public import static function Identity() : Matrix;
	public import static function BuiltTranslation( move : Vector4 ) : Matrix;
	public import static function BuiltRotation( rot : EulerAngles ) : Matrix;
	public import static function BuiltScale( scale : Vector4 ) : Matrix;
	public import static function BuiltPreScale( scale : Vector4 ) : Matrix;
	public import static function BuiltTRS( optional translation : Vector4, optional rotation : EulerAngles, optional scale : Vector4 ) : Matrix;
	public import static function BuiltRTS( optional rotation : EulerAngles, optional translation : Vector4, optional scale : Vector4 ) : Matrix;
	public import static function BuildFromDirectionVector( dirVec : Vector4, optional upVec : Vector4 ) : Matrix;
	public import static function GetTranslation( m : Matrix ) : Vector4;
	public import static function GetRotation( m : Matrix ) : EulerAngles;
	public import static function GetScale( m : Matrix ) : Vector4;
	public import static function GetAxisX( m : Matrix ) : Vector4;
	public import static function GetAxisY( m : Matrix ) : Vector4;
	public import static function GetAxisZ( m : Matrix ) : Vector4;
	public import static function GetDirectionVector( m : Matrix ) : Vector4;
	public import static function GetInverted( m : Matrix ) : Matrix;
	public import static function GetInvertedFull( m : Matrix ) : Matrix;
	public import static function ToQuat( m : Matrix ) : Quaternion;
	public import static function IsOk( m : Matrix ) : Bool;
}

import operator*( a : Matrix, b : Matrix ) : Matrix;
import operator*=( out a : Matrix, b : Matrix ) : Matrix;
