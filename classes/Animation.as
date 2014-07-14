package {
	
	
	
	public class Animation extends Component {
		
		var game:PlatformerGame;
		var animation_states:Object;
		var current_state:int;
		
		
		public function Animation(aGame:PlatformerGame) {
			game = aGame;
			animation_states = new Object();
			current_state = game.IDLE;
		}
		
		public function add_animation_state(aKey:int, aValue:String) {
			animation_states[aKey] = aValue;
		}
		
		public function get_current_value():String {
			return animation_states[current_state];
		}
		
	}
	
}