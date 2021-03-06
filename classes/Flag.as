﻿package {
	
	public class Flag extends Component {
		
		public var game:PlatformerGame;
		public var value:int; // used to identify the entity type
		public var collision_mode:int;
		public var remove_next_loop:Boolean;
		public var allegiance:int;
		public var remaining_frames:int;
		
		public function Flag(aGame:PlatformerGame, aValue:int, aCollisionMode:int ) {
			game = aGame;
			value = aValue;
			collision_mode = aCollisionMode;
			remove_next_loop = false;
			allegiance = game.ENEMY;
			remaining_frames = 5;
		}
	}
	
}