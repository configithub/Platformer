package {
	
	public class Flag extends Component {
		
		public var game:PlatformerGame;
		public var value:int
		
		public function Flag(aGame:PlatformerGame, aValue:int) {
			game = aGame;
			value = aValue;
		}
	}
	
}