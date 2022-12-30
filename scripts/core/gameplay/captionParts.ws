importonly abstract class InteractionChoiceCaptionPart extends IScriptable
{
	public import function GetType() : gamedataChoiceCaptionPartType;
}

import class InteractionChoiceCaptionScriptPart extends InteractionChoiceCaptionPart
{

	protected const virtual function GetPartType() : gamedataChoiceCaptionPartType
	{
		return gamedataChoiceCaptionPartType.Invalid;
	}

}

importonly class InteractionChoiceCaptionStringPart extends InteractionChoiceCaptionPart
{
	import const var content : String;
}

importonly class InteractionChoiceCaptionIconPart extends InteractionChoiceCaptionPart
{
	import var iconRecord : weak< ChoiceCaptionIconPart_Record >;
}

importonly class InteractionChoiceCaptionBluelinePart extends InteractionChoiceCaptionPart
{
	import const var blueline : BluelineDescription;
}

importonly struct InteractionChoiceCaption
{
	import const var parts : array< InteractionChoiceCaptionPart >;

	public import static function AddPartFromRecordID( self : InteractionChoiceCaption, recordId : TDBID );
	public import static function AddPartFromRecord( self : InteractionChoiceCaption, record : weak< ChoiceCaptionPart_Record > );
	public import static function AddTextPart( self : InteractionChoiceCaption, text : String );
	public import static function AddTagPart( self : InteractionChoiceCaption, tag : String );
	public import static function AddScriptPart( self : InteractionChoiceCaption, part : InteractionChoiceCaptionScriptPart );
	public import static function Clear( self : InteractionChoiceCaption );
}

function GetCaptionTagsFromArray( argList : ref< array< InteractionChoiceCaptionPart > > ) : String
{
	var i : Int32;
	var toRet : String;
	var preLoc : String;
	var postLoc : String;
	var currType : gamedataChoiceCaptionPartType;
	var stringTags : array< String >;
	toRet = "";
	for( i = 0; i < argList.Size(); i = i + 1 )
	{
		currType = ( ( InteractionChoiceCaptionPart )( argList[ i ] ) ).GetType();
		if( currType == gamedataChoiceCaptionPartType.Tag )
		{
			preLoc = ( ( InteractionChoiceCaptionStringPart )( argList[ i ] ) ).content;
			postLoc = GetLocalizedText( preLoc );
			stringTags.PushBack( postLoc );
		}
	}
	for( i = stringTags.Size() - 1; i >= 0; i = i - 1 )
	{
		toRet += stringTags[ i ];
		if( i != 0 )
		{
			toRet += " ";
		}
	}
	return toRet;
}

