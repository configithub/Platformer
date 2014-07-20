package{
	public class RenderNode{
		
		var position:Position;
		var display:Displayable;
		var animation:Animation;
		var motion:Motion;
		var flag:Flag;
		
		public function RenderNode(aFlag:Flag, aPosition:Position, aMotion:Motion, aDisplay:Displayable, aAnimation:Animation) {
			position = aPosition;
			display = aDisplay;
			animation = aAnimation;
			motion = aMotion;
			flag = aFlag;
		}
	}
}