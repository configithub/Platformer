package 
{
	public class MotionControlNode
	{

		var position:Position;
		var motion:Motion;
		var cruise:Cruise;
		var flag:Flag;

		public function MotionControlNode(aPosition:Position, aMotion:Motion, aCruise:Cruise,  aFlag:Flag)
		{
			cruise = aCruise; // can be null
			position = aPosition;
			motion = aMotion;
			flag = aFlag;
		}

	}

}