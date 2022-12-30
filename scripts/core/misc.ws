import class IScriptable
{
	public import const function GetClassName() : CName;
	public import const function IsA( className : CName ) : Bool;
	public import const function IsExactlyA( className : CName ) : Bool;
	public import static function DetectScriptableCycles();
}

importonly struct RWLock
{
	public import static function Acquire( self : ref< RWLock > );
	public import static function Release( self : ref< RWLock > );
	public import static function AcquireShared( self : ref< RWLock > );
	public import static function ReleaseShared( self : ref< RWLock > );
}

importonly class CallbackHandle extends IScriptable
{
}

enum ELogType
{
	DEFAULT = 0,
	WARNING = 1,
	ERROR = 2,
}

import enum EComparisonType
{
	Greater,
	GreaterOrEqual,
	Equal,
	NotEqual,
	Less,
	LessOrEqual,
}

export function InitializeScripts()
{
	Log( "InitializeScripts" );
	StatsEffectsEnumToTDBID( -1 );
}

import function IsFinal() : Bool;
import function UseProfiler() : Bool;
import function GetPlatformShortName() : String;
import function Log( const text : ref< String > );
import function LogError( const text : ref< String > );
import function LogWarning( const text : ref< String > );
import function LogChannel( channel : CName, const text : ref< String > );
import function LogChannelError( channel : CName, const text : ref< String > );
import function LogChannelWarning( channel : CName, const text : ref< String > );

function LogDamage( const str : ref< String > )
{
	LogChannel( 'Damage', str );
}

function LogDM( const str : ref< String > )
{
	LogChannel( 'DevelopmentManager', str );
}

function LogItems( const str : ref< String > )
{
	LogChannel( 'Items', str );
}

function LogStats( const str : ref< String > )
{
	LogChannel( 'Stats', str );
}

function LogStatPools( const str : ref< String > )
{
	LogChannel( 'StatPools', str );
}

function LogStrike( const str : ref< String > )
{
	LogChannel( 'Strike', str );
}

function LogAI( const str : ref< String > )
{
	LogChannel( 'AI', str );
}

function LogAIError( const str : ref< String > )
{
	LogChannelError( 'AI', str );
	ReportFailure( str );
}

function LogAICoverError( const str : ref< String > )
{
	LogChannelWarning( 'AICover', str );
}

function LogPuppet( const str : ref< String > )
{
	LogChannel( 'Puppet', str );
}

function LogUI( const str : ref< String > )
{
	LogChannel( 'UI', str );
}

function LogUIWarning( const str : ref< String > )
{
	LogChannelWarning( 'UI', str );
}

function LogUIError( const str : ref< String > )
{
	LogChannelError( 'UI', str );
}

function LogTargetManager( const str : ref< String >, optional type : CName )
{
	FindProperLog( 'TargetManager', type, str );
}

function LogDevices( const str : ref< String >, optional type : ELogType )
{
	if( IsFinal() )
	{
		return;
	}
	FindProperLog( 'Device', type, str );
}

function LogDevices( const object : IScriptable, const str : ref< String >, optional type : ELogType )
{
	var extendedString : String;
	var address : String;
	var id : String;
	const var devicePS : ScriptableDeviceComponentPS;
	const var deviceObj : Device;
	const var puppetPS : ScriptedPuppetPS;
	var isOverride : Int32;
	var tooltip : String;
	var deviceSpecificTags : String;
	return;
	tooltip = "[ ";
	tooltip += ( NameToString( object.GetClassName() ) + " " );
	devicePS = ( ( ScriptableDeviceComponentPS )( object ) );
	deviceObj = ( ( Device )( object ) );
	if( devicePS )
	{
		address = EntityID.ToDebugString( PersistentID.ExtractEntityID( devicePS.GetID() ) );
		id = EntityID.ToDebugStringDecimal( PersistentID.ExtractEntityID( devicePS.GetID() ) );
		deviceSpecificTags = devicePS.GetDebugTags();
		isOverride = GetFact( devicePS.GetGameInstance(), 'dbgDevices' );
		if( isOverride )
		{
			if( !( devicePS.ShouldDebug() ) )
			{
				return;
			}
		}
		if( IsStringValid( devicePS.GetDebugName() ) )
		{
			tooltip += ( "#DN: " + devicePS.GetDebugName() );
		}
		if( devicePS.IsPartOfSystem( ESystems.SecuritySystem ) )
		{
			tooltip += "#SecSys+ ";
		}
		else
		{
			tooltip += "#SecSys- ";
		}
		if( devicePS.IsQuickHacksExposed() )
		{
			tooltip += "#QH Exposed+ ";
		}
		else
		{
			tooltip += "#QH Exposed- ";
		}
		tooltip += ( " $: " + devicePS.GetDeviceStatus() );
	}
	else if( deviceObj )
	{
		devicePS = deviceObj.GetDevicePS();
		if( devicePS )
		{
			address = EntityID.ToDebugString( PersistentID.ExtractEntityID( devicePS.GetID() ) );
			id = EntityID.ToDebugStringDecimal( PersistentID.ExtractEntityID( devicePS.GetID() ) );
		}
		isOverride = GetFact( deviceObj.GetGame(), 'dbgDevices' );
		if( isOverride )
		{
			if( !( deviceObj.ShouldInitiateDebug() ) )
			{
				return;
			}
		}
	}
	else if( ( ( ScriptedPuppetPS )( object ) ) )
	{
		puppetPS = ( ( ScriptedPuppetPS )( object ) );
		address = EntityID.ToDebugString( PersistentID.ExtractEntityID( puppetPS.GetID() ) );
	}
	else
	{
		address = "UKNOWN OBJECT!";
	}
	if( IsStringValid( deviceSpecificTags ) )
	{
		tooltip += ( " | " + deviceSpecificTags );
	}
	extendedString += ( "LOGS: " + str );
	LogDevices( ( ( ( ( ( ( ( tooltip + " ] [ " ) + extendedString ) + " ] [ " ) + "ADDRESS: " ) + address ) + " || ID: " ) + id ) + " ] ", type );
	if( type == ELogType.ERROR && DeviceHelper.IsDebugModeON( devicePS.GetGameInstance() ) )
	{
		LogError( "ERROR DETECTED - TRACING" );
		Trace();
	}
}

function LogDevices( const object : SecuritySystemControllerPS, input : SecuritySystemInput, const str : ref< String >, optional type : ELogType )
{
	var prefix : String;
	var message : String;
	if( IsFinal() )
	{
		return;
	}
	prefix = ( ( ( ( "SecuritySystemInput [ Frame: " + IntToString( ( ( Int32 )( GameInstance.GetFrameNumber( object.GetGameInstance() ) ) ) ) ) + " @" ) + " | ID #" ) + input.GetID() ) + " ]";
	message = ( prefix + " " ) + str;
	LogDevices( object, message, type );
}

function LogDevices( const object : SecuritySystemControllerPS, id : Int32, const str : ref< String >, optional type : ELogType )
{
	var prefix : String;
	var message : String;
	if( IsFinal() )
	{
		return;
	}
	prefix = ( ( ( "Most recent accepted ID [ Frame: " + IntToString( ( ( Int32 )( GameInstance.GetFrameNumber( object.GetGameInstance() ) ) ) ) ) + " @" ) + id ) + " ]";
	message = ( prefix + " " ) + str;
	LogDevices( object, message, type );
}

function LogDevices( const object : SecurityAreaControllerPS, id : Int32, const str : ref< String >, optional type : ELogType )
{
	var prefix : String;
	var message : String;
	if( IsFinal() )
	{
		return;
	}
	prefix = ( ( ( "[ Frame: " + IntToString( ( ( Int32 )( GameInstance.GetFrameNumber( object.GetGameInstance() ) ) ) ) ) + " #" ) + id ) + " ]";
	message = ( prefix + " " ) + str;
	LogDevices( object, message, type );
}

function FindProperLog( channelName : CName, logType : ELogType, const message : ref< String > )
{
	switch( logType )
	{
		case ELogType.WARNING:
			LogChannelWarning( channelName, message );
		break;
		case ELogType.ERROR:
			LogChannelError( channelName, message );
		break;
		default:
			LogChannel( channelName, message );
		break;
	}
}

function FindProperLog( channelName : CName, logType : CName, const message : ref< String > )
{
	if( ( logType == 'Warning' || logType == 'warning' ) || logType == 'w' )
	{
		LogChannelWarning( channelName, message );
	}
	else if( ( logType == 'Error' || logType == 'error' ) || logType == 'e' )
	{
		LogChannelError( channelName, message );
	}
	else
	{
		LogChannel( channelName, message );
	}
}

import function Trace();
import function TraceToString() : String;
import function DebugBreak();
import function DumpClassHierarchy( baseClass : CName ) : Bool;
import function EnumGetMax( type : CName ) : Int64;
import function EnumGetMin( type : CName ) : Int64;
import function EnumValueFromString( const enumStr : ref< String >, const enumValue : ref< String > ) : Int64;
import function EnumValueFromName( enumName : CName, enumValue : CName ) : Int64;
import function EnumValueToString( const enumStr : ref< String >, enumValue : Int64 ) : String;
import function EnumValueToName( enumName : CName, enumValue : Int64 ) : CName;
import function IsNameValid( n : CName ) : Bool;
import function IsStringValid( const n : ref< String > ) : Bool;

function LogAssert( condition : Bool, const text : ref< String > )
{
	if( !( condition ) )
	{
		LogChannel( 'ASSERT', text );
	}
}

exec function CastEnum()
{
	var enumState : EDeviceStatus;
	var value : Int32;
	enumState = EDeviceStatus.DISABLED;
	value = ( ( Int32 )( enumState ) );
	switch( value )
	{
		case -2:
			Log( "Disabled " + IntToString( value ) );
		break;
		case -1:
			Log( "Unpowered " + IntToString( value ) );
		break;
		case 0:
			Log( "Off " + IntToString( value ) );
		break;
		case 1:
			Log( "On " + IntToString( value ) );
		break;
		default:
			Log( "wtf " + IntToString( value ) );
		break;
	}
}

exec function GetFunFact()
{
	var RNG : Int32;
	RNG = RandRange( 0, 23 );
	switch( RNG )
	{
		case 0:
			Log( "Duck vaginas are spiral shaped with dead ends." );
		break;
		case 1:
			Log( "Plural of axolotl is axolotls" );
		break;
		case 2:
			Log( "In the UK, it is illegal to eat mince pies on Christmas Day!" );
		break;
		case 3:
			Log( "Pteronophobia is the fear of being tickled by feathers!" );
		break;
		case 4:
			Log( "When hippos are upset, their sweat turns red." );
		break;
		case 5:
			Log( "The average woman uses her height in lipstick every 5 years." );
		break;
		case 6:
			Log( " Cherophobia is the fear of fun" );
		break;
		case 7:
			Log( "If Pinokio says “My Nose Will Grow Now”, it would cause a paradox. " );
		break;
		case 8:
			Log( "Billy goats urinate on their own heads to smell more attractive to females." );
		break;
		case 9:
			Log( "The person who invented the Frisbee was cremated and made into a frisbee after he died!" );
		break;
		case 10:
			Log( "If you consistently fart for 6 years & 9 months, enough gas is produced to create the energy of an atomic bomb!" );
		break;
		case 11:
			Log( "McDonalds calls frequent buyers of their food “heavy users." );
		break;
		case 12:
			Log( "Guinness Book of Records holds the record for being the book most often stolen from Public Libraries." );
		break;
		case 13:
			Log( "In Romania it is illegal to performe pantimime as it is considered to be higly offensive" );
		case 14:
			Log( "Banging your head against a wall can burn 150 calories per hour" );
		case 15:
			Log( "Crocodile poop used to be used as a contraception" );
		break;
		case 16:
			Log( "In Finland they have an official tournament for peaple riding on a fake horses" );
		break;
		case 17:
			Log( "The Vatican City is the country that drinks the most wine per capita at 74 liters per citizen per year." );
		break;
		case 18:
			Log( "It's possible to lead a cow upstairs...but not downstairs." );
		break;
		case 19:
			Log( "There's a chance you won't get a fun fact from GetFunFact" );
		break;
		case 20:
			Log( "For every non-porn webpage, there are five porn pages." );
		break;
		case 21:
			Log( "At any given time, at least 0,7% of earth population is drunk." );
		break;
		case 22:
			Log( " You can’t say happiness without saying penis." );
		break;
		default:
			Log( "No fact for you. Ha ha!" );
	}
}

function ProcessCompare( comparator : EComparisonType, valA : Float, valB : Float ) : Bool
{
	switch( comparator )
	{
		case EComparisonType.Greater:
			return valA > valB;
		case EComparisonType.GreaterOrEqual:
			return valA >= valB;
		case EComparisonType.Equal:
			return valA == valB;
		case EComparisonType.NotEqual:
			return valA != valB;
		case EComparisonType.Less:
			return valA < valB;
		case EComparisonType.LessOrEqual:
			return valA <= valB;
	}
}

exec function DetectCycles()
{
	IScriptable.DetectScriptableCycles();
}

import function CompareArrayNameContents( arr1, arr2 : array< CName > ) : Bool;
