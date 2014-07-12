package {
	
	public class MoveSystem {
		
		var game:PlatformerGame;
		var nodes:Array;
		
		public function MoveSystem(aGame:PlatformerGame) {
			game = aGame;
			nodes = new Array();
		}
		
		public function loop() {
			for each (var node:MoveNode in nodes) {
				// update speed
				node.motion.speed_x += node.motion.accel_x;
				node.motion.speed_y += node.motion.accel_y;
				// apply horizontal friction
				if(node.motion.apply_horizontal_friction) {
				  if(node.motion.speed_x > 0) { node.motion.speed_x -= 1 };
				  if(node.motion.speed_x < 0) { node.motion.speed_x += 1 };
				  if(node.motion.accel_x > 0) { node.motion.accel_x -= 1 };
				  if(node.motion.accel_x < 0) { node.motion.accel_x += 1 };
				}
				// apply gravity
				if(node.motion.apply_gravity) { node.motion.accel_y += 1; }
				// cap speed
				if(node.motion.speed_x > node.motion.max_speed) { node.motion.speed_x = node.motion.max_speed; }
				else if(node.motion.speed_x < -1 * node.motion.max_speed) { node.motion.speed_x = -1 * node.motion.max_speed; }
				if(node.motion.speed_y > node.motion.max_speed) { node.motion.speed_y = node.motion.max_speed; }
				else if(node.motion.speed_y < -1 * node.motion.max_speed) { node.motion.speed_y = -1 * node.motion.max_speed; }
				if(node.flag.collision_mode == game.NO_COLLISION ||
				   node.flag.collision_mode == game.PLATFORM_COLLISION) {
				  // update position
				  node.position.x += node.motion.speed_x;
				  node.position.y += node.motion.speed_y;
				}
			}
		}
		
		
			
		
		public function add(entity:Entity) {
			var new_node:MoveNode = new MoveNode(entity.components["P"], entity.components["M"], entity.components["F"]) ;
			nodes.push(new_node);
		}
		
	}
	
}