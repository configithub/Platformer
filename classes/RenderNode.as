package{
	public class RenderNode{
		
		var position:Position;
		var display:Displayable;
		
		
		public function RenderNode(aPosition:Position, aDisplay:Displayable) {
			position = aPosition;
			display = aDisplay;
		}
	}
}