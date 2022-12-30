importonly struct ChoiceTypeWrapper
{
	public import static function IsType( context : ChoiceTypeWrapper, type : gameinteractionsChoiceType ) : Bool;
	public import static function SetType( context : ChoiceTypeWrapper, type : gameinteractionsChoiceType );
	public import static function ClearType( context : ChoiceTypeWrapper, type : gameinteractionsChoiceType );
}

importonly struct InteractionChoiceMetaData
{
	import editable var tweakDBName : String;
	import editable var tweakDBID : TweakDBID;
	import editable var type : ChoiceTypeWrapper;

	public import static function GetTweakData( metaData : InteractionChoiceMetaData ) : weak< InteractionBase_Record >;
}

importonly struct InteractionChoice
{
	import editable var caption : String;
	import editable var captionParts : InteractionChoiceCaption;
	import mutable editable var data : array< Variant >;
	import editable var choiceMetaData : InteractionChoiceMetaData;
}

importonly struct InteractionAttemptedChoice
{
	import var visualizerType : EVisualizerType;
	import var choice : InteractionChoice;
	import var choiceIdx : Int32;
	import var isSuccess : Bool;
}

import enum gameinteractionsChoiceType
{
	QuestImportant,
	AlreadyRead,
	Inactive,
	CheckSuccess,
	CheckFailed,
	InnerDialog,
	PossessedDialog,
	TimedDialog,
	Blueline,
	Pay,
	Selected,
	Illegal,
}

