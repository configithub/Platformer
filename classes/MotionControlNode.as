package 
{
	public class MotionControlNode
	{

		var position:Position;
		var motion:Motion;
		var cruise:Cruise;
		var ai:AI;
		var flag:Flag;

		public function MotionControlNode(aPosition:Position, aMotion:Motion, aCruise:Cruise, aAI:AI,  aFlag:Flag)
		{
			cruise = aCruise; // can be null
			position = aPosition;
			motion = aMotion;
			ai = aAI;
			flag = aFlag;
		}

	}

}