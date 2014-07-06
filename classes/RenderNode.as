package{
	public class RenderNode{
		
		var position:Position;
		var display:Displayable;
		var animation:Animation;
		var motion:Motion;
		
		
		public function RenderNode(aPosition:Position, aMotion:Motion, aDisplay:Displayable, aAnimation:Animation) {
			position = aPosition;
			display = aDisplay;
			animation = aAnimation;
			motion = aMotion;
		}
	}
}