package {

	public class MotionControlSystem {

		var game:PlatformerGame;
		var nodes:Array;
		var nodes2:Array;

		public function MotionControlSystem(aGame:PlatformerGame) {
			game = aGame;
			nodes = new Array();
			nodes2 = new Array();
		}

		public function loop() {
			for each (var node:MotionControlNode in nodes) {
				if (node.cruise == null) {// not a cruising entity, for now it means that it answer to keyboard inputs
                    keyboard_control(node);
				}else{
					cruise_control(node);
				}
			}
			for each (var node:MotionControlNode in nodes2) {
				if (node.cruise == null) {// not a cruising entity, for now it means that it answer to keyboard inputs
                    keyboard_control(node);
				}else{
					cruise_control(node);
				}
			}
		}

		public function keyboard_control(node:MotionControlNode) {
			if (game.right_pushed) {
				node.motion.accel_x = 5;
			}
			else if (game.left_pushed) {
				node.motion.accel_x = -5;
			}
			if (game.up_pushed && node.motion.can_jump) {
				node.motion.can_jump = false;
				node.motion.accel_y = -10;
			}
			if (game.space_released && node.motion.can_fire) { 
			  game.player_fires();
			}
		}
		
		public function cruise_control(node:MotionControlNode) {
			if (node.cruise.cruise_mode == game.OSCILLATION) {
				var next_position:Position = node.cruise.trajectory[ (node.cruise.current_position + 1) % node.cruise.trajectory.length];
				var margin_x:int = 5; var margin_y:int = 5;
				var has_arrived:Boolean = ( Math.abs( node.position.x - next_position.x ) < margin_x
				   && Math.abs( node.position.y - next_position.y ) < margin_y );
				if(has_arrived) {
					node.cruise.current_position = (node.cruise.current_position + 1) % node.cruise.trajectory.length;
					next_position = node.cruise.trajectory[ (node.cruise.current_position + 1) % node.cruise.trajectory.length];
				}
				var module:int = Math.sqrt( Math.pow(next_position.x - node.position.x,2) + Math.pow(next_position.y - node.position.y,2));	
				node.motion.speed_x = node.cruise.speed_x * (next_position.x - node.position.x) / module;
				node.motion.speed_y = node.cruise.speed_y * (next_position.y - node.position.y) / module;
			}
		}

		public function add(entity:Entity) {
			var new_node:MotionControlNode = new MotionControlNode(entity.components["P"],entity.components["M"],entity.components["C"],entity.components["F"]);
			if(new_node.motion.motion_priority == 1) {
				nodes.push(new_node);
			}else{
				nodes2.push(new_node);
			}
		}


	}

}