package {
	public class Cruise extends Component {
		public var game:PlatformerGame;
		public var trajectory:Array;
		public var cruise_mode:int;
		public var current_position:int;
		
		public var speed_x:int;
		public var speed_y:int;

		public function Cruise(aGame:PlatformerGame) {
			game = aGame;
			trajectory = new Array();
			cruise_mode = game.OSCILLATION;
			current_position = 0;
			speed_x = 5; speed_y = 5;
		}
		
		public function add_position(x:int, y:int) {
			var new_position:Position = new Position(game, x, y);
			trajectory.push(new_position);
		}
		
	}
}