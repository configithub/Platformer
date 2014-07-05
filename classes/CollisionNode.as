package {
	public class CollisionNode {
		
		var position:Position;
		var motion:Motion;
		var aabb:AABBMask;
		var flag:Flag;
		
		public function CollisionNode(aPosition:Position, aAABB:AABBMask, aMotion:Motion, aFlag:Flag) {
			aabb = aAABB;
			position = aPosition;
			motion = aMotion; // can be null
			flag = aFlag;
		}
		
	}
}