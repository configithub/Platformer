package{
	
	public class Position extends Component {
		
		public var game:PlatformerGame;
		public var x:int;
		public var y:int;
		
		public function Position(aGame:PlatformerGame, aX:int, aY:int) {
			game = aGame;
			x = aX;
			y = aY;
		}
		
	}
	
}