importonly abstract class IBlackboardSystem extends IGameSystem
{
}

importonly class BlackboardSystem extends IBlackboardSystem
{
	public import function Get( definition : BlackboardDefinition ) : IBlackboard;
	public import function GetLocalInstanced( entityID : EntityID, definition : BlackboardDefinition ) : IBlackboard;
	public import final function RegisterLocalBlackboard( blackboard : IBlackboard );
	public import final function UnregisterLocalBlackboard( blackboard : IBlackboard );
	public import final function RegisterLocalBlackboardForDebugRender( blackboard : IBlackboard, debugName : String );
}

class BlackBoardRequestEvent extends Event
{
	protected var m_blackBoard : weak< IBlackboard >;
	protected var m_storageClass : gameScriptedBlackboardStorage;
	protected var m_entryTag : CName;

	public function PassBlackBoardReference( newBlackbord : weak< IBlackboard >, blackBoardName : CName )
	{
		m_blackBoard = newBlackbord;
		m_entryTag = blackBoardName;
	}

	public function GetBlackboardReference() : weak< IBlackboard >
	{
		return m_blackBoard;
	}

	public function SetStorageType( storageType : gameScriptedBlackboardStorage )
	{
		m_storageClass = storageType;
	}

	public function GetStorageType() : gameScriptedBlackboardStorage
	{
		return m_storageClass;
	}

	public function GetEntryTag() : CName
	{
		return m_entryTag;
	}

}

class RegisterPostionEvent extends BlackBoardRequestEvent
{
	var start : Bool;
}

