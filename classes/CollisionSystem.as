package {

	
	public class CollisionSystem {
		
		var game:PlatformerGame;
		var nodes:Array;
		
		var collision_queue:Array;
		
		public function CollisionSystem(aGame:PlatformerGame) {
			game = aGame;
			nodes = new Array();
		}
		
		public function is_colliding( nodeA:CollisionNode, nodeB:CollisionNode):Boolean {
			if( nodeA.position.x + nodeA.aabb.width / 2 < nodeB.position.x - nodeB.aabb.width / 2
			   || nodeB.position.x + nodeB.aabb.width / 2 < nodeA.position.x - nodeA.aabb.width / 2
			   || nodeA.position.y + nodeA.aabb.height / 2 < nodeB.position.y - nodeB.aabb.height / 2
			   || nodeB.position.y + nodeB.aabb.height / 2 < nodeA.position.y - nodeA.aabb.height / 2) {
				return false;
			}else{
				return true;
			}
		}
		
		public function loop() {
			collision_queue = new Array(); // empty the queue
			// check if something collides and fill the collision queue
			for(var i:int = 0; i < nodes.length-1; i++) {
				for(var j:int = i+1; j < nodes.length; j++) {
					if(nodes[i].flag.value == nodes[j].flag.value) { continue; } // dirty fix to prevent intertile collisions
					if(is_colliding(nodes[i], nodes[j])) {
					  if(nodes[i].flag.value < nodes[j].flag.value) {
					    collision_queue.push(new Collision(nodes[i], nodes[j]));   
					  }else{
						collision_queue.push(new Collision(nodes[j], nodes[i])); 
					  }
					}
				}
			}
			
			// resolve collisions
			for each(var collision:Collision in collision_queue) {
				if(collision.a.flag.value == 1 && collision.b.flag.value == 2) { // a is a tile, b is a player
					// player lands on tile
					var tile_up:int = collision.a.position.y - collision.a.aabb.height / 2;
					var tile_down:int = collision.a.position.y + collision.a.aabb.height / 2;
					var tile_left:int = collision.a.position.x - collision.a.aabb.width / 2;
					var tile_right:int = collision.a.position.x + collision.a.aabb.width / 2;
					
					var player_up:int = collision.b.position.y - collision.b.aabb.height / 2;
					var player_down:int = collision.b.position.y + collision.b.aabb.height / 2;
					var player_left:int = collision.b.position.x - collision.b.aabb.width / 2;
					var player_right:int = collision.b.position.x + collision.b.aabb.width / 2;
					
					if(player_down > tile_up && collision.b.motion.speed_y >0) { 
						collision.b.position.y = collision.a.position.y - collision.a.aabb.height / 2 - collision.b.aabb.height / 2;
						collision.b.motion.accel_y = 0; collision.b.motion.speed_y = 0; collision.b.motion.can_jump = true;
					}else if(player_up < tile_down && collision.b.motion.speed_y <0) {
						collision.b.position.y = collision.a.position.y + collision.b.aabb.height /2 + collision.a.aabb.height/2;
						collision.b.motion.accel_y = 0; collision.b.motion.speed_y = 0;
					}
					
				}
			}
		}
		
		public function add(entity:Entity) {
			var new_node:CollisionNode = new CollisionNode(entity.components["P"], entity.components["A"], entity.components["M"], entity.components["F"]) ;
			nodes.push(new_node);
		}
		
	}
	
}