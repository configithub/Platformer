﻿package{
	
	public class Motion extends Component{
		
		public var game:PlatformerGame;
		
		var accel_x:int;
		var accel_y:int;
		
		var speed_x:int;
		var speed_y:int;
		
		var apply_gravity:Boolean; // used to tell if gravity needs to be applied to the entity
		var apply_horizontal_friction:Boolean;
		var max_speed:int; // used to cap speed
		var can_jump:Boolean;
		var can_fire:Boolean;
		
		var hori_map_collision_last_frame:int;
		
		var motion_priority:int;
		
		var stand_on:CollisionNode;
		
		var is_facing_left:Boolean;
		
		public function Motion(aGame:PlatformerGame, aSpeedX:int, aSpeedY:int, aAccelX:int, aAccelY:int, aGravity:Boolean, aFriction:Boolean, aMaxSpeed:int) {
			accel_x = aAccelX;
			accel_y = aAccelY;
			speed_x = aSpeedX;
			speed_y = aSpeedY;
			game = aGame;
			apply_gravity = aGravity;
			apply_horizontal_friction = aFriction;
			max_speed = aMaxSpeed;
			can_jump = false;
			can_fire = true;
			is_facing_left = true;
			motion_priority = 2;
			hori_map_collision_last_frame = 0;
		}
		
	}
	
}