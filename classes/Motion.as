package{
	
	public class Motion extends Component{
		
		public var game:PlatformerGame;
		
		var accel_x:int;
		var accel_y:int;
		
		var speed_x:int;
		var speed_y:int;
		
		public function Motion(aGame:PlatformerGame, aSpeedX:int, aSpeedY:int, aAccelX:int, aAccelY:int) {
			accel_x = aAccelX;
			accel_y = aAccelY;
			speed_x = aSpeedX;
			speed_y = aSpeedY;
			game = aGame;
		}
		
	}
	
}