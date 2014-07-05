package  {
	
    import flash.display.DisplayObject;
	
	public class Displayable extends Component {
		
		var display_object:DisplayObject;
		var game:PlatformerGame;
		
		public function Displayable(aGame:PlatformerGame, aSprite:DisplayObject) {
			display_object = aSprite;
			game = aGame;
		}
		
	}
}