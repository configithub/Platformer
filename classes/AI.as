package {
	
	public class AI extends Component {
		
		var game:PlatformerGame;
		var modes:Object;
		
		public function AI(aGame:PlatformerGame) {
			game = aGame;
			modes = new Object();
		}
		
		public function add_mode(condition:int, action:int /*, priority:int*/ ) {
			modes[condition] = action;
		}
	}
}