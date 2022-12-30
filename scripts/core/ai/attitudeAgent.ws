importonly class AttitudeAgent extends GameComponent
{
	public import function IsDangerous( other : AttitudeAgent ) : Bool;
	public import function GetAttitudeGroup() : CName;
	public import function GetAttitudeTowards( other : AttitudeAgent ) : EAIAttitude;
	public import function SetAttitudeGroup( group : CName );
	public import function SetAttitudeTowards( agent : AttitudeAgent, attitude : EAIAttitude );
	public import function SetAttitudeTowardsAgentGroup( targetAgent : AttitudeAgent, ownerAgent : AttitudeAgent, attitude : EAIAttitude );
}

import enum EAIAttitude
{
	AIA_Friendly,
	AIA_Neutral,
	AIA_Hostile,
}

operator+( s : String, att : EAIAttitude ) : String
{
	return s + EnumValueToString( "EAIAttitude", ( ( Int64 )( att ) ) );
}

operator+( att : EAIAttitude, s : String ) : String
{
	return EnumValueToString( "EAIAttitude", ( ( Int64 )( att ) ) ) + s;
}

