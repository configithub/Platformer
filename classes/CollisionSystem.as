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
		
		public function standing_on(node:CollisionNode) {
			if(node.motion.stand_on != null) {
				node.position.x += node.motion.stand_on.motion.speed_x;
				node.position.y += node.motion.stand_on.motion.speed_y;
				node.motion.can_jump = true;
			}else{
				node.motion.can_jump = false;
			}
		}
		
		public function speculative_contact(node:CollisionNode) {
			standing_on(node); // adjust player entity position if it stands on something else
			var step_x:int = 0;
			if(node.motion.speed_x > 0)
			  step_x = 1;
			else if (node.motion.speed_x < 0) 
			  step_x = -1;
			var step_y:int = 0;
			if(node.motion.speed_y > 0)
			  step_y = 1;
			else if (node.motion.speed_y < 0) 
			  step_y = -1;
			
			var speculative_x:int = node.position.x;
			var speculative_y:int = node.position.y;
			
			var dist_x:int = node.motion.speed_x;
			var dist_y:int = node.motion.speed_y;
			
			while(true) {
				speculative_x += step_x;
				if(!valid_map_position(speculative_x, speculative_y, node)) {
					node.motion.speed_x = 0;
					speculative_x -= step_x;
					step_x = 0;
				}else{
					dist_x -= step_x;
				}
				speculative_y += step_y;
				if(!valid_map_position(speculative_x, speculative_y, node)) {
					if(node.motion.speed_y > 0) { node.motion.can_jump = true; }
					node.motion.speed_y = 0;
					speculative_y -= step_y;
					step_y = 0;
				}else{
					dist_y -= step_y;
				}
				if(dist_x == 0) { step_x = 0; }
				if(dist_y == 0) { step_y = 0; }
				if(step_x ==0 && step_y == 0) { break; }
			}
			node.position.x = speculative_x;
			node.position.y = speculative_y;
		}
		
		public function valid_map_position(x:int, y:int, node:CollisionNode):Boolean {
			var tile_top_left_X:int = game.get_tile_x( x - node.aabb.width / 2);
			var tile_top_left_Y:int = game.get_tile_y( y - node.aabb.height / 2);
			
			var tile_bottom_right_X:int = game.get_tile_x(x+node.aabb.width /2);
			var tile_bottom_right_Y:int = game.get_tile_y(y+node.aabb.height /2);
			
			for(var i:int = tile_top_left_X; i <= tile_bottom_right_X; i++) {
				for(var j:int = tile_top_left_Y; j <= tile_bottom_right_Y; j++) {
					if(game.map[ i + j * game.map_width ] == game.TILE ||
					   (game.map[ i + j * game.map_width ] == game.ONEWAY 
						&& node.position.y+node.aabb.height /2 < j * game.tile_height)) { return false; }
				}
			}
			return true;
		}
		
		public function loop() {
			// resolve collision with the map and move entities
			for each(var node:CollisionNode in nodes) {
				if(node.flag.collision_mode == game.SPECULATIVE_CONTACT) {
				  speculative_contact(node);
				  node.motion.stand_on = null; // reinitialize standings
				}
			}
			
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
				if(collision.a.flag.value == game.PLAYER && collision.b.flag.value == game.MOVING_PLATFORM) {
					// moving platform(b) - player(a) collision
					if(collision.a.position.y+collision.a.aabb.height /2 - collision.a.motion.speed_y 
					   < collision.b.position.y - collision.b.aabb.height / 2 - collision.b.motion.speed_y) { // during last frame, player was above platform
						collision.a.position.y = collision.b.position.y - collision.b.aabb.height / 2 - collision.a.aabb.height /2
								- collision.a.motion.speed_y; // adjust player position to avoid interpenetration
						collision.a.motion.stand_on = collision.b; // player now stands on platform
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