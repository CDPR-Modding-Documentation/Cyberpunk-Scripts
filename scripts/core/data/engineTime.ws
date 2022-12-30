importonly struct EngineTime
{
	public import static function IsValid( self : EngineTime ) : Bool;
	public import static function FromFloat( value : Float ) : EngineTime;
	public import static function ToFloat( self : EngineTime ) : Float;
	public import static function ToString( self : EngineTime ) : String;
}

import operator+( a : EngineTime, b : EngineTime ) : EngineTime;
import operator+( a : EngineTime, b : Float ) : EngineTime;
import operator+=( out a : EngineTime, b : EngineTime ) : EngineTime;
import operator+=( out a : EngineTime, b : Float ) : EngineTime;
import operator-( a : EngineTime, b : EngineTime ) : EngineTime;
import operator-( a : EngineTime, b : Float ) : EngineTime;
import operator-=( out a : EngineTime, b : EngineTime ) : EngineTime;
import operator-=( out a : EngineTime, b : Float ) : EngineTime;
import operator*( a : EngineTime, b : Float ) : EngineTime;
import operator*=( out a : EngineTime, b : Float ) : EngineTime;
import operator/( a : EngineTime, b : Float ) : EngineTime;
import operator/=( out a : EngineTime, b : Float ) : EngineTime;
import operator==( a : EngineTime, b : EngineTime ) : Bool;
import operator!=( a : EngineTime, b : EngineTime ) : Bool;
import operator>( a : EngineTime, b : EngineTime ) : Bool;
import operator>=( a : EngineTime, b : EngineTime ) : Bool;
import operator<( a : EngineTime, b : EngineTime ) : Bool;
import operator<=( a : EngineTime, b : EngineTime ) : Bool;
import operator>( a : EngineTime, b : Float ) : Bool;
import operator>=( a : EngineTime, b : Float ) : Bool;
import operator<( a : EngineTime, b : Float ) : Bool;
import operator<=( a : EngineTime, b : Float ) : Bool;
