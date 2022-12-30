importonly abstract class ITransactionSystem extends IGameSystem
{
}

importonly final abstract class TransactionSystem extends ITransactionSystem
{
	public import function PrefetchItemAppearance( obj : GameObject, itemID : ItemID, newAppearanceName : CName );
	public import function ChangeItemAppearanceByName( obj : GameObject, itemID : ItemID, newAppearanceName : CName );
	public import function ChangeItemAppearanceByItemID( obj : GameObject, itemID : ItemID, newItemID : ItemID );
	public import function GetItemAppearance( obj : GameObject, itemID : ItemID ) : CName;
	public import function ResetItemAppearance( obj : GameObject, itemID : ItemID );
	public import function ClearAttachmentAppearance( obj : GameObject, slotID : TweakDBID );
	public import function RemoveMoney( obj : GameObject, amount : Int32, currency : CName ) : Bool;
	public import function GiveMoney( source : GameObject, target : GameObject, amount : Int32, currency : CName ) : Bool;
	public import function RemoveItem( obj : GameObject, itemID : ItemID, amount : Int32 ) : Bool;
	public import function RemoveItemByTDBID( obj : GameObject, tdbID : TweakDBID, amount : Int32 ) : Bool;
	public import function GiveItem( obj : GameObject, itemID : ItemID, amount : Int32, optional dynamicTags : array< CName > ) : Bool;
	public import function GiveItemByTDBID( obj : GameObject, tdbID : TweakDBID, amount : Int32 ) : Bool;
	public import function GiveItems( obj : GameObject, itemList : array< ItemModParams > ) : Bool;
	public import function GiveItemByItemData( obj : GameObject, itemData : gameItemData ) : Bool;
	public import function GivePreviewItemByItemData( obj : GameObject, itemData : gameItemData ) : Bool;
	public import function GivePreviewItemByItemID( obj : GameObject, itemID : ItemID ) : Bool;
	public import function CreatePreviewItemID( itemID : ItemID ) : ItemID;
	public import function GiveItemByItemQuery( obj : GameObject, itemQueryTDBID : TweakDBID, optional amount : Uint32, optional seed : Uint64, optional telemetryLogSource : String ) : Bool;
	public import function GiveItemByItemArrayQuery( obj : GameObject, itemQueryTDBID : TweakDBID, optional seed : Uint64 ) : Bool;
	public import function TransferItem( source : GameObject, target : GameObject, itemID : ItemID, amount : Int32, optional dynamicTags : array< CName > ) : Bool;
	public import function TransferAllItems( source : GameObject, target : GameObject ) : Bool;
	public import function TakeItem( newOwner : GameObject, itemToLoot : weak< ItemObject > ) : Bool;
	public import function SellItem( seller : GameObject, buyer : GameObject, itemID : ItemID, amount : Int32, currency : CName, optional price : Int32 ) : Bool;
	public import function SellItemStrict( seller : GameObject, buyer : GameObject, itemID : ItemID, amount : Int32, currency : CName, optional price : Int32 ) : Bool;
	public import function HasItem( obj : GameObject, itemID : ItemID ) : Bool;
	public import function GetNumItems( obj : GameObject, optional tagFilters : array< CName > ) : Int32;
	public import function GetTotalItemQuantity( obj : GameObject ) : Int32;
	public import function HasTag( obj : GameObject, tag : CName, itemID : ItemID ) : Bool;
	public import function GetItemData( obj : GameObject, itemID : ItemID ) : weak< gameItemData >;
	public import function GetItemDataByTDBID( obj : GameObject, itemTDBID : TweakDBID ) : weak< gameItemData >;
	public import function GetItemDataByOwnerEntityId( id : EntityID, itemID : ItemID ) : weak< gameItemData >;
	public import function GetItemQuantity( obj : GameObject, itemID : ItemID ) : Int32;
	public import function GetItemQuantityByTag( obj : GameObject, tag : CName ) : Int32;
	public import function GetItemList( obj : GameObject, out itemList : array< weak< gameItemData > > ) : Bool;
	public import function GetItemListByTag( obj : GameObject, tag : CName, out itemList : array< weak< gameItemData > > ) : Bool;
	public import function GetItemListByTags( obj : GameObject, tagList : array< CName >, out itemList : array< weak< gameItemData > > ) : Bool;
	public import function GetItemListExcludingTags( obj : GameObject, tagList : array< CName >, out itemList : array< weak< gameItemData > > ) : Bool;
	public import function GetItemListFilteredByTags( obj : GameObject, tags : array< CName >, excludedTags : array< CName >, out itemList : array< weak< gameItemData > > ) : Bool;
	public import function RemoveAllItems( obj : GameObject ) : Bool;
	public import function InitializeSlots( obj : GameObject, out slotIDList : array< TweakDBID > ) : Bool;
	public import function RefreshAttachment( obj : GameObject, out slotID : TweakDBID, optional keepWorldTransform : Bool );
	public import function AddItemToSlot( obj : GameObject, slotID : TweakDBID, itemID : ItemID, optional highPriority : Bool, optional itemObject : weak< ItemObject >, optional plane : ERenderingPlane, optional keepWorldTransform : Bool, optional ignoreRestrictions : Bool, optional garmentAppearanceName : CName, optional appearanceItem : ItemID ) : Bool;
	public import function DropItemFromSlot( obj : GameObject, slotID : TweakDBID, optional shouldDestroyEntity : Bool, optional keepWorldTransform : Bool, optional skipSendAnimEquipEvents : Bool ) : Bool;
	public import function RemoveItemFromSlot( obj : GameObject, slotID : TweakDBID, optional shouldDestroyEntity : Bool, optional keepWorldTransform : Bool, optional skipSendAnimEquipEvents : Bool ) : Bool;
	public import function RemoveItemFromAnySlot( obj : GameObject, itemID : ItemID, optional shouldDestroyEntity : Bool, optional keepWorldTransform : Bool ) : Bool;
	public import function ChangeItemToSlot( obj : GameObject, newSlotID : TweakDBID, itemID : ItemID ) : Bool;
	public import function ClearAllSlots( obj : GameObject ) : Bool;
	public import function IsSlotEmpty( obj : GameObject, slotID : TweakDBID ) : Bool;
	public import function IsSlotEmptySpawningItem( obj : GameObject, slotID : TweakDBID ) : Bool;
	public import function HasItemDataInSlot( obj : GameObject, slotID : TweakDBID, itemID : ItemID ) : Bool;
	public import function HasItemInSlot( obj : GameObject, slotID : TweakDBID, itemID : ItemID ) : Bool;
	public import function HasItemInAnySlot( obj : GameObject, itemID : ItemID ) : Bool;
	public import function CanPlaceItemInSlot( obj : GameObject, slotID : TweakDBID, itemID : ItemID ) : Bool;
	public import function GetItemInSlot( obj : GameObject, slotID : TweakDBID ) : ItemObject;
	public import function GetItemInSlotByItemID( obj : GameObject, itemID : ItemID ) : ItemObject;
	public import function MatchVisualTag( entity : Entity, tag : CName, optional matchUsingDefaultAppearance : Bool ) : Bool;
	public import function MatchVisualTagByItemID( itemID : ItemID, owner : GameObject, tag : CName ) : Bool;
	public import function GetVisualTags( entity : Entity, optional matchUsingDefaultAppearance : Bool ) : array< CName >;
	public import function GetVisualTagsByItemID( itemID : ItemID, owner : GameObject ) : array< CName >;
	public import function CycleActiveItemInSlot( obj : GameObject, slotID : TweakDBID ) : ItemID;
	public import function SetActiveItemInSlot( obj : GameObject, slotID : TweakDBID, itemID : ItemID ) : Bool;
	public import function EquipActiveItemInSlot( obj : GameObject, slotID : TweakDBID, highPriority : Bool ) : Bool;
	public import function GetActiveItemInSlot( obj : GameObject, slotID : TweakDBID ) : ItemID;
	public import function CanItemBeActiveInSlot( obj : GameObject, slotID : TweakDBID, itemID : ItemID ) : Bool;
	public import function GetNextActiveItemInSlot( obj : GameObject, slotID : TweakDBID ) : ItemID;
	public import function RemovePart( obj : GameObject, itemID : ItemID, slotID : TweakDBID, optional shouldUpdateEntity : Bool ) : ItemID;
	public import function AddPart( obj : GameObject, itemID : ItemID, partItemID : ItemID, optional slotID : TweakDBID ) : Bool;
	public import function ForcePartInSlot( obj : GameObject, itemID : ItemID, partItemID : ItemID, slotID : TweakDBID ) : Bool;
	public import function GetEmptySlotsOnItem( obj : GameObject, itemID : ItemID, out emptySlots : array< TweakDBID > );
	public import function GetAvailableSlotsOnItem( obj : GameObject, itemID : ItemID, out availableSlots : array< TweakDBID > );
	public import function GetUsedSlotsOnItem( obj : GameObject, itemID : ItemID, out used : array< TweakDBID > );
	public import function GetItemsInstallableInSlot( obj : GameObject, itemID : ItemID, slotID : TweakDBID, out installableItems : array< ItemID > );
	public import function ReinitializeStatsOnEntityItems( obj : GameObject );
	public import function CalculateTemporaryStatsBundle( obj : GameObject, rootPartID : ItemID, replacementPartID : ItemID, slotIdForReplacement : TweakDBID ) : StatsBundleHandler;
	public import function ReleaseItem( owner : GameObject, item : weak< ItemObject > ) : Bool;
	public import function ThrowItem( owner : GameObject, item : weak< GameObject >, setUpAndLaunchEvent : gameprojectileSetUpAndLaunchEvent ) : Bool;
	public import function RegisterInventoryListener( owner : GameObject, callback : InventoryScriptCallback ) : InventoryScriptListener;
	public import function RegisterAttachmentSlotListener( owner : GameObject, callback : AttachmentSlotsScriptCallback ) : AttachmentSlotsScriptListener;
	public import function UnregisterInventoryListener( owner : GameObject, listener : InventoryScriptListener );
	public import function UnregisterAttachmentSlotListener( owner : GameObject, listener : AttachmentSlotsScriptListener );
	public import function OnItemAddedToEquipmentSlot( owner : GameObject, itemID : ItemID, optional garmentAppearanceName : CName, optional appearanceItem : ItemID ) : Bool;
	public import function OnItemRemovedFromEquipmentSlot( owner : GameObject, itemID : ItemID ) : Bool;
	public import function UseAlternativeCyberware() : Bool;
}

struct NPCItemToEquip
{
	var itemID : ItemID;
	var slotID : TweakDBID;
	var bodySlotID : TweakDBID;
}

abstract class AIActionTransactionSystem extends IScriptable
{

	public static function ChooseSingleItemsSetFromPool( powerLevel : Int32, seed : Uint32, itemPool : weak< NPCEquipmentItemPool_Record > ) : array< weak< NPCEquipmentItem_Record > >
	{
		var randomVal : Float;
		var possibleItems : array< weak< NPCEquipmentItemsPoolEntry_Record > >;
		var i, poolSize : Int32;
		var weightSum, accumulator : Float;
		var tempPoolEntry : weak< NPCEquipmentItemsPoolEntry_Record >;
		var results : array< weak< NPCEquipmentItem_Record > >;
		accumulator = 0.0;
		poolSize = itemPool.GetPoolCount();
		for( i = 0; i < poolSize; i += 1 )
		{
			tempPoolEntry = itemPool.GetPoolItem( i );
			if( powerLevel >= tempPoolEntry.MinLevel() )
			{
				possibleItems.PushBack( tempPoolEntry );
				weightSum += tempPoolEntry.Weight();
			}
		}
		randomVal = RandNoiseF( ( ( Int32 )( seed ) ), 0.0, weightSum );
		for( i = 0; i < possibleItems.Size(); i += 1 )
		{
			accumulator += possibleItems[ i ].Weight();
			if( randomVal < accumulator )
			{
				possibleItems[ i ].Items( results );
				return results;
			}
		}
		return results;
	}

	public static function CalculateEquipmentItems( const puppet : weak< ScriptedPuppet >, const equipmentGroupName : CName, out items : array< weak< NPCEquipmentItem_Record > >, optional powerLevel : Int32 )
	{
		var characterRecord : weak< Character_Record >;
		var equipmentGroupRecord : weak< NPCEquipmentGroup_Record >;
		characterRecord = TweakDBInterface.GetCharacterRecord( puppet.GetRecordID() );
		if( !( characterRecord ) || !( IsNameValid( equipmentGroupName ) ) )
		{
			return;
		}
		if( equipmentGroupName == 'PrimaryEquipment' )
		{
			equipmentGroupRecord = characterRecord.PrimaryEquipment();
		}
		else if( equipmentGroupName == 'SecondaryEquipment' )
		{
			equipmentGroupRecord = characterRecord.SecondaryEquipment();
		}
		if( !( equipmentGroupRecord ) )
		{
			return;
		}
		CalculateEquipmentItems( puppet, equipmentGroupRecord, items, powerLevel );
	}

	public static function CalculateEquipmentItems( const puppet : weak< ScriptedPuppet >, equipmentGroupRecord : weak< NPCEquipmentGroup_Record >, out items : array< weak< NPCEquipmentItem_Record > >, powerLevel : Int32 )
	{
		var id : EntityID;
		var seed : Uint32;
		var i, x, itemsCount : Int32;
		var entry : weak< NPCEquipmentGroupEntry_Record >;
		var statSys : StatsSystem;
		var groupID : Uint32;
		var bitsMask : Uint64;
		var itemsSet : array< weak< NPCEquipmentItem_Record > >;
		id = puppet.GetEntityID();
		bitsMask = ( ( Uint64 )( PowF( 2.0, 32.0 ) ) ) - ( ( Uint64 )( 1 ) );
		if( !( equipmentGroupRecord ) )
		{
			return;
		}
		seed = EntityID.GetHash( id );
		groupID = ( ( Uint32 )( TDBID.ToNumber( equipmentGroupRecord.GetID() ) & bitsMask ) );
		seed = seed ^ groupID;
		if( powerLevel < 0 )
		{
			statSys = GameInstance.GetStatsSystem( puppet.GetGame() );
			powerLevel = ( ( Int32 )( statSys.GetStatValue( puppet.GetEntityID(), gamedataStatType.PowerLevel ) ) );
		}
		itemsCount = equipmentGroupRecord.GetEquipmentItemsCount();
		for( i = 0; i < itemsCount; i += 1 )
		{
			entry = equipmentGroupRecord.GetEquipmentItemsItem( i );
			if( ( ( NPCEquipmentItem_Record )( entry ) ) )
			{
				items.PushBack( ( ( NPCEquipmentItem_Record )( entry ) ) );
			}
			else
			{
				seed += ( ( Uint32 )( 1 ) );
				itemsSet = ChooseSingleItemsSetFromPool( powerLevel, seed, ( ( NPCEquipmentItemPool_Record )( entry ) ) );
				for( x = 0; x < itemsSet.Size(); x += 1 )
				{
					items.PushBack( itemsSet[ x ] );
				}
			}
		}
	}

	public static function ShouldPerformEquipmentCheck( obj : weak< ScriptedPuppet >, const equipmentGroup : CName ) : Bool
	{
		var characterRecord : weak< Character_Record >;
		characterRecord = TweakDBInterface.GetCharacterRecord( obj.GetRecordID() );
		if( !( characterRecord ) )
		{
			return false;
		}
		if( !( obj ) || !( IsNameValid( equipmentGroup ) ) )
		{
			return false;
		}
		if( equipmentGroup == 'PrimaryEquipment' )
		{
			if( characterRecord.PrimaryEquipment() )
			{
				return true;
			}
		}
		else if( equipmentGroup == 'SecondaryEquipment' )
		{
			if( characterRecord.SecondaryEquipment() )
			{
				return true;
			}
		}
		return false;
	}

	public static function CheckEquipmentGroupForEquipment( const context : ScriptExecutionContext, condition : weak< AIItemCond_Record > ) : Bool
	{
		var i : Int32;
		var a : Int32;
		var item : Item_Record;
		var itemsCount : Int32;
		var tagCount : Int32;
		var checkTag : Bool;
		var items : array< weak< NPCEquipmentItem_Record > >;
		CalculateEquipmentItems( ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) ), condition.EquipmentGroup(), items );
		itemsCount = items.Size();
		if( ( itemsCount > 0 ) && !( condition.CheckAllItemsInEquipmentGroup() ) )
		{
			itemsCount = 1;
		}
		for( i = 0; i < itemsCount; i += 1 )
		{
			item = items[ i ].Item();
			if( !( item ) )
			{
				continue;
			}
			if( condition.ItemType() && condition.ItemType().Name() != '' )
			{
				if( item.ItemType().Type() != condition.ItemType().Type() )
				{
					continue;
				}
			}
			if( condition.ItemCategory().Name() != '' )
			{
				if( item.ItemCategory() != condition.ItemCategory() )
				{
					continue;
				}
			}
			if( condition.ItemTag() != '' )
			{
				tagCount = item.GetTagsCount();
				for( a = 0; a < tagCount; a += 1 )
				{
					if( item.GetTagsItem( a ) == condition.ItemTag() )
					{
						checkTag = true;
						break;
					}
				}
				if( !( checkTag ) )
				{
					continue;
				}
			}
			return true;
		}
		return false;
	}

	public static function CheckSlotsForEquipment( const context : ScriptExecutionContext, const equipmentGroup : CName ) : Bool
	{
		var itemsToEquip : array< NPCItemToEquip >;
		var i : Int32;
		var itemsInSlots : Int32;
		switch( equipmentGroup )
		{
			case 'PrimaryEquipment':
				if( !( GetEquipment( context, true, itemsToEquip ) ) )
				{
					return false;
				}
			break;
			case 'SecondaryEquipment':
				if( !( GetEquipment( context, false, itemsToEquip ) ) )
				{
					return false;
				}
			break;
			default:
				break;
		}
		for( i = 0; i < itemsToEquip.Size(); i += 1 )
		{
			if( GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).HasItemInSlot( ScriptExecutionContext.GetOwner( context ), itemsToEquip[ i ].slotID, itemsToEquip[ i ].itemID ) )
			{
				itemsInSlots += 1;
			}
		}
		if( itemsInSlots > 0 )
		{
			return true;
		}
		return false;
	}

	public static function GetEquipment( const context : ScriptExecutionContext, checkPrimaryEquipment : Bool, out itemsList : array< NPCItemToEquip > ) : Bool
	{
		var puppet : weak< ScriptedPuppet >;
		var characterRecord : weak< Character_Record >;
		var item : NPCItemToEquip;
		var itemRecord : NPCEquipmentItem_Record;
		var itemCount : Int32;
		var itemID : ItemID;
		var i : Int32;
		var equipmentGroup : weak< NPCEquipmentGroup_Record >;
		var items : array< weak< NPCEquipmentItem_Record > >;
		var slotId : TweakDBID;
		puppet = ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) );
		if( !( puppet ) )
		{
			return false;
		}
		characterRecord = TweakDBInterface.GetCharacterRecord( puppet.GetRecordID() );
		if( !( characterRecord ) )
		{
			return false;
		}
		if( checkPrimaryEquipment )
		{
			equipmentGroup = characterRecord.PrimaryEquipment();
		}
		else
		{
			equipmentGroup = characterRecord.SecondaryEquipment();
		}
		CalculateEquipmentItems( puppet, equipmentGroup, items, -1 );
		itemCount = items.Size();
		for( i = 0; i < itemCount; i += 1 )
		{
			itemRecord = items[ i ];
			if( itemRecord.OnBodySlot() )
			{
				slotId = itemRecord.OnBodySlot().GetID();
			}
			AIActionTransactionSystem.GetItemID( puppet, itemRecord.Item(), slotId, itemID );
			if( GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).HasItem( ScriptExecutionContext.GetOwner( context ), itemID ) )
			{
				item.itemID = itemID;
				item.slotID = itemRecord.EquipSlot().GetID();
				item.bodySlotID = slotId;
				itemsList.PushBack( item );
			}
		}
		return itemsList.Size() > 0;
	}

	public static function GetEquipmentWithCondition( const context : ScriptExecutionContext, checkPrimaryEquipment : Bool, checkForUnequip : Bool, out itemsList : array< NPCItemToEquip > ) : Bool
	{
		var puppet : weak< ScriptedPuppet >;
		var game : GameInstance;
		var transactionSystem : TransactionSystem;
		var characterRecord : weak< Character_Record >;
		var item : NPCItemToEquip;
		var items : array< weak< NPCEquipmentItem_Record > >;
		var primaryItems : array< weak< NPCEquipmentItem_Record > >;
		var itemID : ItemID;
		var primaryItemID : ItemID;
		var conditions : array< weak< AIActionCondition_Record > >;
		var primaryConditions : array< weak< AIActionCondition_Record > >;
		var i, k, z : Int32;
		var equipmentGroup : weak< NPCEquipmentGroup_Record >;
		var itemsToEquip : array< NPCItemToEquip >;
		var bodySlotId : TweakDBID;
		var currentItem : NPCEquipmentItem_Record;
		var defaultID : TweakDBID;
		var hasFistsWoundedEquipped : Bool;
		var secondaryEquipmentDuplicatesPrimary : Bool;
		puppet = ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) );
		if( !( puppet ) )
		{
			return false;
		}
		game = puppet.GetGame();
		characterRecord = TweakDBInterface.GetCharacterRecord( puppet.GetRecordID() );
		if( !( characterRecord ) )
		{
			return false;
		}
		transactionSystem = GameInstance.GetTransactionSystem( game );
		if( checkPrimaryEquipment )
		{
			equipmentGroup = characterRecord.PrimaryEquipment();
		}
		else
		{
			equipmentGroup = characterRecord.SecondaryEquipment();
		}
		CalculateEquipmentItems( puppet, equipmentGroup, items, -1 );
		if( checkForUnequip )
		{
			if( ItemID.GetTDBID( transactionSystem.GetItemInSlot( puppet, T"AttachmentSlots.WeaponRight" ).GetItemID() ) == T"Items.Npc_fists_wounded" )
			{
				hasFistsWoundedEquipped = true;
			}
			if( !( checkPrimaryEquipment ) )
			{
				CalculateEquipmentItems( puppet, characterRecord.PrimaryEquipment(), primaryItems, -1 );
				for( i = 0; i < items.Size(); i += 1 )
				{
					if( primaryItems.Contains( items[ i ] ) )
					{
						secondaryEquipmentDuplicatesPrimary = true;
					}
				}
			}
		}
		for( i = 0; i < items.Size(); i += 1 )
		{
			currentItem = items[ i ];
			if( !( currentItem.Item() ) )
			{
				continue;
			}
			if( !( currentItem.EquipSlot() ) )
			{
				continue;
			}
			if( currentItem.OnBodySlot() )
			{
				bodySlotId = currentItem.OnBodySlot().GetID();
			}
			if( AIActionTransactionSystem.GetItemID( puppet, currentItem.Item(), bodySlotId, itemID ) )
			{
				conditions.Clear();
				if( ( !( checkForUnequip ) && !( transactionSystem.HasItemInSlot( puppet, currentItem.EquipSlot().GetID(), itemID ) ) ) && transactionSystem.HasItem( puppet, itemID ) )
				{
					currentItem.EquipCondition( conditions );
				}
				else if( checkForUnequip && ( transactionSystem.HasItemInSlot( puppet, currentItem.EquipSlot().GetID(), itemID ) || hasFistsWoundedEquipped ) )
				{
					currentItem.UnequipCondition( conditions );
				}
				else
				{
					continue;
				}
				if( ( ( checkForUnequip && ( conditions.Size() == 0 ) ) && checkPrimaryEquipment ) && !( hasFistsWoundedEquipped ) )
				{
					continue;
				}
				if( ( conditions.Size() > 0 ) && !( AICondition.CheckActionConditions( context, conditions ) ) )
				{
					continue;
				}
				if( ( !( checkForUnequip ) && ( conditions.Size() == 0 ) ) && ( itemsList.Size() > 0 ) )
				{
					for( k = 0; k < itemsList.Size(); k += 1 )
					{
						if( itemsList[ k ].slotID == currentItem.EquipSlot().GetID() )
						{
							continue;
						}
					}
				}
				if( !( checkPrimaryEquipment ) && checkForUnequip )
				{
					GetEquipmentWithCondition( context, true, false, itemsToEquip );
					if( itemsToEquip.Size() == 0 )
					{
						GetEquipmentWithCondition( context, false, false, itemsToEquip );
					}
					if( itemsToEquip.Size() == 0 )
					{
						continue;
					}
					else
					{
						if( transactionSystem.HasItemInSlot( puppet, itemsToEquip[ 0 ].slotID, itemsToEquip[ 0 ].itemID ) )
						{
							continue;
						}
						if( secondaryEquipmentDuplicatesPrimary )
						{
							for( z = 0; z < primaryItems.Size(); z += 1 )
							{
								AIActionTransactionSystem.GetItemID( puppet, primaryItems[ z ].Item(), ( ( primaryItems[ z ].OnBodySlot() ) ? ( primaryItems[ z ].OnBodySlot().GetID() ) : ( defaultID ) ), primaryItemID );
								if( itemID == primaryItemID )
								{
									primaryItems[ z ].EquipCondition( primaryConditions );
									if( AICondition.CheckActionConditions( context, primaryConditions ) )
									{
										continue;
									}
								}
							}
						}
					}
				}
				item.itemID = itemID;
				item.slotID = currentItem.EquipSlot().GetID();
				item.bodySlotID = bodySlotId;
				itemsList.PushBack( item );
			}
		}
		return itemsList.Size() > 0;
	}

	public static function GetDefaultEquipment( const context : ScriptExecutionContext, characterRecord : weak< Character_Record >, checkForUnequip : Bool, out itemsList : array< NPCItemToEquip > ) : Bool
	{
		var items : array< weak< NPCEquipmentItem_Record > >;
		var item : NPCItemToEquip;
		var itemID : ItemID;
		var i : Int32;
		var primaryItemsToEquip : array< NPCItemToEquip >;
		var defaultItem : NPCEquipmentItem_Record;
		var sendData : Bool;
		var onBodySlotID : TweakDBID;
		CalculateEquipmentItems( ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) ), characterRecord.SecondaryEquipment(), items, -1 );
		sendData = false;
		GetEquipmentWithCondition( context, true, false, primaryItemsToEquip );
		if( checkForUnequip )
		{
			if( ( primaryItemsToEquip.Size() > 0 ) && !( GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).HasItemInSlot( ScriptExecutionContext.GetOwner( context ), primaryItemsToEquip[ 0 ].slotID, primaryItemsToEquip[ 0 ].itemID ) ) )
			{
				if( !( GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).HasItemInSlot( ScriptExecutionContext.GetOwner( context ), primaryItemsToEquip[ 0 ].slotID, primaryItemsToEquip[ 0 ].itemID ) ) )
				{
					sendData = true;
				}
			}
		}
		if( sendData )
		{
			i = items.Size() - 1;
			if( items[ i ].OnBodySlot() )
			{
				onBodySlotID = items[ i ].OnBodySlot().GetID();
			}
			AIActionTransactionSystem.GetItemID( ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) ), items[ i ].Item(), onBodySlotID, itemID );
			if( ( items.Size() > 0 ) && GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).HasItem( ScriptExecutionContext.GetOwner( context ), itemID ) )
			{
				item.itemID = itemID;
				item.slotID = items[ i ].EquipSlot().GetID();
			}
			else
			{
				defaultItem = characterRecord.DefaultEquipment();
				AIActionTransactionSystem.GetItemID( ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) ), defaultItem.Item(), defaultItem.OnBodySlot().GetID(), itemID );
				if( !( GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).HasItem( ScriptExecutionContext.GetOwner( context ), itemID ) ) )
				{
					GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).GiveItem( ScriptExecutionContext.GetOwner( context ), itemID, 1 );
				}
				item.itemID = itemID;
				item.slotID = defaultItem.EquipSlot().GetID();
			}
			if( !( checkForUnequip ) || GameInstance.GetTransactionSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).HasItemInSlot( ScriptExecutionContext.GetOwner( context ), item.slotID, item.itemID ) )
			{
				itemsList.PushBack( item );
				return true;
			}
		}
		return false;
	}

	public static function GetOnBodyEquipment( obj : weak< ScriptedPuppet >, out itemsToEquip : array< NPCItemToEquip > ) : Bool
	{
		var characterRecord : weak< Character_Record >;
		var equipmentGroup : weak< NPCEquipmentGroup_Record >;
		var itemToEquip : NPCItemToEquip;
		var items : array< weak< NPCEquipmentItem_Record > >;
		var itemID : ItemID;
		var i : Int32;
		if( !( obj ) )
		{
			return false;
		}
		characterRecord = TweakDBInterface.GetCharacterRecord( obj.GetRecordID() );
		if( !( characterRecord ) )
		{
			return false;
		}
		equipmentGroup = characterRecord.PrimaryEquipment();
		if( !( equipmentGroup ) )
		{
			return false;
		}
		CalculateEquipmentItems( obj, equipmentGroup, items, -1 );
		for( i = 0; i < items.Size(); i += 1 )
		{
			if( items[ i ].Item() && AIActionTransactionSystem.GetItemIDFromRecord( items[ i ].Item(), itemID ) )
			{
				itemToEquip.itemID = itemID;
				if( items[ i ].OnBodySlot() )
				{
					itemToEquip.bodySlotID = items[ i ].OnBodySlot().GetID();
				}
				itemsToEquip.PushBack( itemToEquip );
			}
		}
		equipmentGroup = characterRecord.SecondaryEquipment();
		items.Clear();
		CalculateEquipmentItems( obj, equipmentGroup, items, -1 );
		for( i = 0; i < items.Size(); i += 1 )
		{
			if( items[ i ].Item() && AIActionTransactionSystem.GetItemIDFromRecord( items[ i ].Item(), itemID ) )
			{
				itemToEquip.itemID = itemID;
				if( items[ i ].OnBodySlot() )
				{
					itemToEquip.bodySlotID = items[ i ].OnBodySlot().GetID();
				}
				itemsToEquip.PushBack( itemToEquip );
			}
		}
		return itemsToEquip.Size() > 0;
	}

	public static function GetOnBodyEquipmentRecords( obj : weak< ScriptedPuppet >, out outEquipmentRecords : array< weak< NPCEquipmentItem_Record > > ) : Bool
	{
		var characterRecord : weak< Character_Record >;
		var equipmentGroup : weak< NPCEquipmentGroup_Record >;
		var items : array< weak< NPCEquipmentItem_Record > >;
		var i : Int32;
		if( !( obj ) )
		{
			return false;
		}
		characterRecord = TweakDBInterface.GetCharacterRecord( obj.GetRecordID() );
		if( !( characterRecord ) )
		{
			return false;
		}
		equipmentGroup = characterRecord.PrimaryEquipment();
		if( !( equipmentGroup ) )
		{
			return false;
		}
		CalculateEquipmentItems( obj, equipmentGroup, items, -1 );
		for( i = 0; i < items.Size(); i += 1 )
		{
			if( items[ i ].Item() && items[ i ].OnBodySlot() )
			{
				outEquipmentRecords.PushBack( items[ i ] );
			}
		}
		equipmentGroup = characterRecord.SecondaryEquipment();
		items.Clear();
		CalculateEquipmentItems( obj, equipmentGroup, items, -1 );
		for( i = 0; i < items.Size(); i += 1 )
		{
			if( items[ i ].Item() && items[ i ].OnBodySlot() )
			{
				outEquipmentRecords.PushBack( items[ i ] );
			}
		}
		return outEquipmentRecords.Size() > 0;
	}

	public static function GetItemsBodySlot( owner : weak< ScriptedPuppet >, const itemID : ItemID, out onBodySlotID : TweakDBID ) : Bool
	{
		var equipmentRecords : array< weak< NPCEquipmentItem_Record > >;
		var i : Int32;
		if( !( GetOnBodyEquipmentRecords( owner, equipmentRecords ) ) )
		{
			return false;
		}
		for( i = 0; i < equipmentRecords.Size(); i += 1 )
		{
			if( equipmentRecords[ i ].Item().GetID() == ItemID.GetTDBID( itemID ) )
			{
				onBodySlotID = equipmentRecords[ i ].OnBodySlot().GetID();
				return TDBID.IsValid( onBodySlotID );
			}
		}
		return false;
	}

	public static function GetItemID( obj : weak< ScriptedPuppet >, itemRecord : weak< Item_Record >, const onBodySlotID : TweakDBID, out itemID : ItemID ) : Bool
	{
		var itemObj : ItemObject;
		if( !( itemRecord ) )
		{
			return false;
		}
		if( obj && TDBID.IsValid( onBodySlotID ) )
		{
			itemObj = GameInstance.GetTransactionSystem( obj.GetGame() ).GetItemInSlot( obj, onBodySlotID );
			if( itemObj )
			{
				itemID = itemObj.GetItemID();
				if( ItemID.GetTDBID( itemID ) == itemRecord.GetID() )
				{
					return true;
				}
			}
		}
		itemID = ItemID.CreateQuery( itemRecord.GetID() );
		return ItemID.IsValid( itemID );
	}

	public static function GetItemIDFromRecord( itemRecord : weak< Item_Record >, out itemID : ItemID ) : Bool
	{
		if( !( itemRecord ) )
		{
			return false;
		}
		itemID = ItemID.CreateQuery( itemRecord.GetID() );
		return ItemID.IsValid( itemID );
	}

	public static function GetFirstItemID( owner : weak< GameObject >, const itemTag : CName, out itemID : ItemID ) : Bool
	{
		var itemList : array< weak< gameItemData > >;
		if( itemTag != '' )
		{
			GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemListByTag( owner, itemTag, itemList );
		}
		else
		{
			GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemList( owner, itemList );
		}
		if( itemList.Size() > 0 )
		{
			itemID = itemList[ 0 ].GetID();
			return true;
		}
		return false;
	}

	public static function GetFirstItemID( owner : weak< GameObject >, itemType : weak< ItemType_Record >, itemTag : CName, out itemID : ItemID ) : Bool
	{
		var itemList : array< weak< gameItemData > >;
		var i : Int32;
		if( itemTag != '' )
		{
			GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemListByTag( owner, itemTag, itemList );
		}
		else
		{
			GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemList( owner, itemList );
		}
		for( i = 0; i < itemList.Size(); i += 1 )
		{
			if( TweakDBInterface.GetItemRecord( ItemID.GetTDBID( itemList[ i ].GetID() ) ).ItemType() == itemType )
			{
				itemID = itemList[ i ].GetID();
				return true;
			}
		}
		return false;
	}

	public static function GetFirstItemID( owner : weak< GameObject >, itemCategory : weak< ItemCategory_Record >, itemTag : CName, out itemID : ItemID ) : Bool
	{
		var itemList : array< weak< gameItemData > >;
		var i : Int32;
		if( itemTag != '' )
		{
			GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemListByTag( owner, itemTag, itemList );
		}
		else
		{
			GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemList( owner, itemList );
		}
		for( i = 0; i < itemList.Size(); i += 1 )
		{
			if( TweakDBInterface.GetItemRecord( ItemID.GetTDBID( itemList[ i ].GetID() ) ).ItemCategory() == itemCategory )
			{
				itemID = itemList[ i ].GetID();
				return true;
			}
		}
		return false;
	}

	public static function IsSlotEmptySpawningItem( owner : weak< GameObject >, slotID : TweakDBID ) : Bool
	{
		if( !( owner ) )
		{
			return false;
		}
		if( !( TDBID.IsValid( slotID ) ) )
		{
			return false;
		}
		return GameInstance.GetTransactionSystem( owner.GetGame() ).IsSlotEmptySpawningItem( owner, slotID );
	}

	public static function DoesItemMeetRequirements( const weaponItemID : ItemID, condition : AIItemCond_Record, evolution : weak< WeaponEvolution_Record > ) : Bool
	{
		var weaponRecord : weak< WeaponItem_Record >;
		var triggerModeCount : Int32;
		triggerModeCount = condition.GetTriggerModesCount();
		if( !( evolution ) && ( triggerModeCount == 0 ) )
		{
			return true;
		}
		weaponRecord = ( ( WeaponItem_Record )( TweakDBInterface.GetItemRecord( ItemID.GetTDBID( weaponItemID ) ) ) );
		if( weaponRecord )
		{
			if( evolution && ( weaponRecord.Evolution() != evolution ) )
			{
				return false;
			}
			if( triggerModeCount > 0 )
			{
				if( !( weaponRecord.PrimaryTriggerMode() ) || !( condition.TriggerModesContains( weaponRecord.PrimaryTriggerMode() ) ) )
				{
					return false;
				}
			}
			return true;
		}
		return false;
	}

}

