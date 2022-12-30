importonly abstract class IStatPoolsListener extends IScriptable
{
}

import class ScriptStatPoolsListener extends IStatPoolsListener
{
	public export virtual function OnStatPoolValueChanged( oldValue : Float, newValue : Float, percToPoints : Float );
}

import class CustomValueStatPoolsListener extends ScriptStatPoolsListener
{
	public import function SetValue( valuePerc : Float );
}

importonly struct StatPoolModifier
{
	import var enabled : Bool;
	import var rangeBegin : Float;
	import var rangeEnd : Float;
	import var startDelay : Float;
	import var valuePerSec : Float;
	import var delayOnChange : Bool;
}

importonly abstract class IStatPoolsSystem extends IGameSystem
{
}

importonly final class StatPoolsSystem extends IStatPoolsSystem
{
	public import function RequestAddingStatPool( objID : StatsObjectID, statPoolRecordID : TweakDBID, optional forceCreateStatPools : Bool );
	public import function RequestRemovingStatPool( objID : StatsObjectID, statPoolType : gamedataStatPoolType );
	public import function GetStatPoolMaxPointValue( objID : StatsObjectID, statPoolType : gamedataStatPoolType ) : Float;
	public import function GetStatPoolValue( objID : StatsObjectID, statPoolType : gamedataStatPoolType, optional perc : Bool ) : Float;
	public import function GetStatPoolValueCustomLimit( objID : StatsObjectID, statPoolType : gamedataStatPoolType, optional perc : Bool ) : Float;
	public import function GetBonus( objID : StatsObjectID, statPoolType : gamedataStatPoolType, optional perc : Bool ) : Float;
	public import function IsStatPoolAdded( objID : StatsObjectID, statPoolType : gamedataStatPoolType ) : Bool;
	public import function HasActiveStatPool( objID : StatsObjectID, statPoolType : gamedataStatPoolType ) : Bool;
	public import function HasStatPoolValueReachedMin( objID : StatsObjectID, statPoolType : gamedataStatPoolType ) : Bool;
	public import function HasStatPoolValueReachedMax( objID : StatsObjectID, statPoolType : gamedataStatPoolType ) : Bool;
	public import function HasStatPoolValueReachedCustomLimit( objID : StatsObjectID, statPoolType : gamedataStatPoolType ) : Bool;
	public import function RequestSettingStatPoolMinValue( objID : StatsObjectID, statPoolType : gamedataStatPoolType, instigator : weak< GameObject > );
	public import function RequestSettingStatPoolMaxValue( objID : StatsObjectID, statPoolType : gamedataStatPoolType, instigator : weak< GameObject > );
	public import function RequestSettingStatPoolValue( objID : StatsObjectID, statPoolType : gamedataStatPoolType, newValue : Float, instigator : weak< GameObject >, optional perc : Bool );
	public import function RequestSettingStatPoolValueCustomLimit( objID : StatsObjectID, statPoolType : gamedataStatPoolType, newValue : Float, instigator : weak< GameObject >, optional perc : Bool );
	public import function RequestSettingStatPoolValueIgnoreChangeMode( objID : StatsObjectID, statPoolType : gamedataStatPoolType, newValue : Float, instigator : weak< GameObject >, optional perc : Bool );
	public import function RequestChangingStatPoolValue( objID : StatsObjectID, statPoolType : gamedataStatPoolType, diff : Float, instigator : weak< GameObject >, forceChunkTransfering : Bool, optional perc : Bool );
	public import function RequestSettingStatPoolBonus( objID : StatsObjectID, statPoolType : gamedataStatPoolType, bonus : Float, instigator : weak< GameObject >, persistentBonus : Bool, optional perc : Bool );
	public import function GetModifier( objID : StatsObjectID, statPoolType : gamedataStatPoolType, type : gameStatPoolModificationTypes, out modifier : StatPoolModifier ) : Bool;
	public import function RequestSettingModifier( objID : StatsObjectID, statPoolType : gamedataStatPoolType, type : gameStatPoolModificationTypes, modifier : StatPoolModifier );
	public import function RequestSettingModifierWithRecord( objID : StatsObjectID, statPoolType : gamedataStatPoolType, type : gameStatPoolModificationTypes, modifierRecordID : TweakDBID );
	public import function RequestResetingModifier( objID : StatsObjectID, statPoolType : gamedataStatPoolType, type : gameStatPoolModificationTypes );
	public import const function GetActiveModifierRecordID( objID : StatsObjectID, statPoolType : gamedataStatPoolType, type : gameStatPoolModificationTypes, out isModifierDefault : Bool ) : TweakDBID;
	public import function ToPercentage( objID : StatsObjectID, statPoolType : gamedataStatPoolType, value : Float ) : Float;
	public import function ToPoints( objID : StatsObjectID, statPoolType : gamedataStatPoolType, percValue : Float ) : Float;
	public import function RequestRegisteringListener( objID : StatsObjectID, statPoolType : gamedataStatPoolType, listener : IStatPoolsListener );
	public import function RequestUnregisteringListener( objID : StatsObjectID, statPoolType : gamedataStatPoolType, listener : IStatPoolsListener );
	public import static function GetStatPoolType( damageType : gamedataDamageType ) : gamedataStatPoolType;
}

import enum gameStatPoolModificationTypes
{
	Regeneration,
	Decay,
}

