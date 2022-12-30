importonly abstract class IStatsListener extends IScriptable
{
}

import class ScriptStatsListener extends IStatsListener
{
	public export virtual function OnStatChanged( ownerID : StatsObjectID, statType : gamedataStatType, diff : Float, total : Float );
	public export virtual function OnGodModeChanged( ownerID : EntityID, newType : gameGodModeType );
	public import function SetStatType( statType : gamedataStatType );
}

importonly final class StatsBundleHandler extends IScriptable
{
	public import function GetStatValue( statType : gamedataStatType ) : Float;
	public import function GetStatBoolValue( statType : gamedataStatType ) : Bool;
	public import function GetStatDetails() : array< gameStatDetailedData >;
	public import function AddModifier( modifierData : gameStatModifierData ) : Bool;
	public import function RemoveModifier( modifierData : gameStatModifierData );
	public import function RemoveAllModifiers( statType : gamedataStatType );
}

importonly abstract class IStatsSystem extends IGameSystem
{
}

importonly final abstract class StatsSystem extends IStatsSystem
{
	public import function GetStatType( damageType : gamedataDamageType ) : gamedataStatType;
	public import function GetDamageType( statType : gamedataStatType ) : gamedataDamageType;
	public import function GetDamageRecordId( damageType : gamedataDamageType ) : TweakDBID;
	public import function GetDamageTypeByRecordID( damageTypeRecordId : TweakDBID ) : gamedataDamageType;
	public import function GetDamageRecordFromId( damageTypeRecordId : TweakDBID ) : weak< DamageType_Record >;
	public import function GetDamageRecordFromType( damageType : gamedataDamageType ) : weak< DamageType_Record >;
	public import const function GetStatValue( objID : StatsObjectID, statType : gamedataStatType ) : Float;
	public import const function GetStatBoolValue( objID : StatsObjectID, statType : gamedataStatType ) : Bool;
	public import const function GetStatValueFromDamageType( objId : StatsObjectID, damageType : gamedataDamageType ) : Float;
	public import function GetStatDetails( objID : StatsObjectID ) : array< gameStatDetailedData >;
	public import function AddModifier( objID : StatsObjectID, modifierData : gameStatModifierData ) : Bool;
	public import function AddModifiers( objID : StatsObjectID, modifierData : array< gameStatModifierData > ) : Bool;
	public import function AddSavedModifier( objID : StatsObjectID, modifierData : gameStatModifierData ) : Bool;
	public import function RemoveModifier( objID : StatsObjectID, modifierData : gameStatModifierData ) : Bool;
	public import function RemoveSavedModifiers( objID : StatsObjectID, statType : gamedataStatType ) : Bool;
	public import function RemoveAllModifiers( objID : StatsObjectID, statType : gamedataStatType, optional removeSavedModifiers : Bool ) : Bool;
	public import function DefineModifierGroupFromRecord( groupID : Uint64, recordID : TweakDBID ) : Bool;
	public import function UndefineModifierGroup( groupID : Uint64 ) : Bool;
	public import function ApplyModifierGroup( objID : StatsObjectID, groupID : Uint64 ) : Bool;
	public import function RemoveModifierGroup( objID : StatsObjectID, groupID : Uint64 ) : Bool;
	public import function GetStatPrereqModifiersValue( ownerID : StatsObjectID, statPrereqID : TweakDBID ) : Float;
	public import function RegisterListener( objID : StatsObjectID, listener : IStatsListener );
	public import function UnregisterListener( objID : StatsObjectID, listener : IStatsListener );
}

class StatsSystemHelper
{

	public static function GetDetailedStatInfo( obj : GameObject, statType : gamedataStatType, out statData : gameStatDetailedData ) : Bool
	{
		var detailsArray : array< gameStatDetailedData >;
		var i : Int32;
		detailsArray = GameInstance.GetStatsSystem( obj.GetGame() ).GetStatDetails( obj.GetEntityID() );
		for( i = 0; i < detailsArray.Size(); i += 1 )
		{
			if( detailsArray[ i ].statType == statType )
			{
				statData = detailsArray[ i ];
				return true;
			}
		}
		return false;
	}

}

