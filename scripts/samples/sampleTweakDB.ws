exec function TweakDBTest()
{
	var lootTableRecord : LootTable_Record;
	var lootItemRecord : LootItem_Record;
	var lootItemList : array< weak< LootItem_Record > >;
	var itemRecord : Item_Record;
	Log( FloatToString( TDB.GetFloat( T"Scripts.Item.A" ) ) );
	Log( FloatToString( TDB.GetFloat( T"Scripts.Item.C", 10.0 ) ) );
	Log( IntToString( TDB.GetInt( T"Scripts.Item.Int" ) ) );
	Log( IntToString( TDB.GetInt( T"Scripts.Item.In2t", 1999 ) ) );
	Log( TDB.GetString( T"Scripts.Item.String" ) );
	Log( TDB.GetString( T"Scripts.Item.Stng", "DefaultValue" ) );
	lootTableRecord = TDB.GetLootTableRecord( T"LootTables.testSingleItem" );
	lootTableRecord.LootItems( lootItemList );
	lootItemRecord = lootItemList[ 0 ];
	itemRecord = lootItemRecord.ItemID();
	Log( itemRecord.FriendlyName() );
}

