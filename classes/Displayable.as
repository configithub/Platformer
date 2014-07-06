package  {
	
    import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	public class Displayable extends Component {
		
		var display_object:MovieClip;
		var game:PlatformerGame;
		
		public function Displayable(aGame:PlatformerGame, aSprite:MovieClip) {
			display_object = aSprite;
			game = aGame;
		}
		
	}
}