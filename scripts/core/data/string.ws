enum ESpaceFillMode
{
	JustifyLeft = 0,
	JustifyRight = 1,
	JustifyCenter = 2,
}

import function StrLen( const str : ref< String > ) : Int32;
import function StrCmp( const str, with : ref< String >, optional length : Int32, optional noCase : Bool ) : Int32;
import function StrFindFirst( const str, match : ref< String > ) : Int32;
import function StrFindLast( const str, match : ref< String > ) : Int32;
import function StrSplitFirst( const str, divider : ref< String >, out left, right : String ) : Bool;
import function StrSplitLast( const str, divider : ref< String >, out left, right : String ) : Bool;
import function StrSplit( const str, divider : ref< String >, optional includeEmpty : Bool ) : array< String >;
import function StrReplace( const str, match, with : ref< String > ) : String;
import function StrReplaceAll( const str, match, with : ref< String > ) : String;
import function StrMid( const str : ref< String >, first : Int32, optional length : Int32 ) : String;
import function StrLeft( const str : ref< String >, length : Int32 ) : String;
import function StrRight( const str : ref< String >, length : Int32 ) : String;
import function StrBeforeFirst( const str, match : ref< String > ) : String;
import function StrBeforeLast( const str, match : ref< String > ) : String;
import function StrAfterFirst( const str, match : ref< String > ) : String;
import function StrAfterLast( const str, match : ref< String > ) : String;
import function StrBeginsWith( const str, match : ref< String > ) : Bool;
import function StrEndsWith( const str, match : ref< String > ) : Bool;
import function StrUpper( const str : ref< String > ) : String;
import function StrLower( const str : ref< String > ) : String;
import function StrChar( i : Int32 ) : String;
import function NameToString( n : CName ) : String;
import function StringToName( const str : ref< String > ) : CName;
import function FloatToString( value : Float ) : String;
import function FloatToStringPrec( value : Float, precision : Int32 ) : String;
import function IntToString( value : Int32 ) : String;
import function StringToInt( const value : ref< String >, optional defValue : Int32 ) : Int32;
import function StringToUint64( const value : ref< String >, optional defValue : Uint64 ) : Uint64;
import function StringToFloat( const value : ref< String >, optional defValue : Float ) : Float;
import function IsStringNumber( const value : ref< String > ) : Bool;

function NoTrailZeros( f : Float ) : String
{
	var tmp : String;
	tmp = FloatToString( f );
	if( ( StrFindFirst( tmp, "," ) >= 0 ) || ( StrFindFirst( tmp, "." ) >= 0 ) )
	{
		while( StrEndsWith( tmp, "0" ) )
		{
			tmp = StrLeft( tmp, StrLen( tmp ) - 1 );
		}
	}
	if( StrEndsWith( tmp, "," ) || StrEndsWith( tmp, "." ) )
	{
		tmp = StrLeft( tmp, StrLen( tmp ) - 1 );
	}
	return tmp;
}

import function BoolToString( value : Bool ) : String;
import function StringToBool( const s : ref< String > ) : Bool;

function SpaceFill( str : String, length : Int32, optional mode : ESpaceFillMode, optional fillChar : String ) : String
{
	var strLen, i, addLeft, addRight, fillLen : Int32;
	fillLen = StrLen( fillChar );
	if( fillLen == 0 )
	{
		fillChar = " ";
	}
	else if( fillLen > 1 )
	{
		fillChar = StrChar( 0 );
	}
	strLen = StrLen( str );
	if( strLen >= length )
	{
		return str;
	}
	if( mode == ESpaceFillMode.JustifyLeft )
	{
		addLeft = 0;
		addRight = length - strLen;
	}
	else if( mode == ESpaceFillMode.JustifyRight )
	{
		addLeft = length - strLen;
		addRight = 0;
	}
	else if( mode == ESpaceFillMode.JustifyCenter )
	{
		addLeft = ( ( Int32 )( FloorF( ( ( ( Float )( length ) ) - ( ( Float )( strLen ) ) ) / 2.0 ) ) );
		addRight = ( length - strLen ) - addLeft;
	}
	for( i = 0; i < addLeft; i += 1 )
	{
		str = fillChar + str;
	}
	for( i = 0; i < addRight; i += 1 )
	{
		str += fillChar;
	}
	return str;
}

import function StrContains( const str : ref< String >, const subStr : ref< String > ) : Bool;
import operator+( const a : ref< String >, const b : ref< String > ) : String;
import operator+=( a : ref< String >, const b : ref< String > ) : String;
import operator+( const a : ref< String >, b : Int32 ) : String;
import operator+( const a : ref< String >, b : Bool ) : String;
import operator+( a : Bool, const b : ref< String > ) : String;
import operator+( a : Int32, const b : ref< String > ) : String;
import operator+( const a : ref< String >, b : Float ) : String;
import operator+( a : Float, const b : ref< String > ) : String;

operator*( a : String, count : Int32 ) : String
{
	var i : Int32;
	var result : String;
	var bit : String;
	bit = a;
	for( i = 0; i < count; i += 1 )
	{
		result = result + bit;
	}
	return result;
}

import operator+( a : CName, b : CName ) : CName;
