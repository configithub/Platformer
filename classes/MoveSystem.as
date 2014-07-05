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
				node.motion.speed_x += node.motion.accel_x;
				node.motion.speed_y += node.motion.accel_y;
				node.position.x += node.motion.speed_x;
				node.position.y += node.motion.speed_y;
			}
		}
		
		public function add(entity:Entity) {
			var new_node:MoveNode = new MoveNode(entity.components["P"], entity.components["M"]) ;
			nodes.push(new_node);
		}
		
	}
	
}