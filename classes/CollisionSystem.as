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
			if(node.motion.stand_on != null) { // entity is standing on another entity
				node.position.x += node.motion.stand_on.motion.speed_x;
				node.position.y += node.motion.stand_on.motion.speed_y;
				node.motion.can_jump = true; 
			}else{
				node.motion.can_jump = false; // later on we will check against the map if the entity can jump, for now we assume it can't
			}
		}
		
		public function speculative_contact(node:CollisionNode) {
			standing_on(node); // adjust player entity position if it stands on something else
			
			// check for horizontal collision, for now none of it 
			node.motion.hori_map_collision_last_frame = game.NO_COLLISION_LF; // no horizontal collision with the map for now
			
			// check all position between current position and destination position step by step
			// if one of the position is not valid, stop there and realize the motion to this position
			// else go to the destination position
			// could be optimized with normal vectors
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
					if(step_x > 0) { node.motion.hori_map_collision_last_frame = game.RIGHT_COLLISION; }
					else { node.motion.hori_map_collision_last_frame = game.LEFT_COLLISION; }
					step_x = 0;
				}else{
					dist_x -= step_x;
				}
				speculative_y += step_y;
				if(!valid_map_position(speculative_x, speculative_y, node)) {
					if(node.motion.speed_y > 0) { node.motion.can_jump = true; } // falling collision, entity can now jump
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
		
		// check if entity collides with the map
		public function valid_map_position(x:int, y:int, node:CollisionNode):Boolean {
			var tile_top_left_X:int = (x - node.aabb.width / 2) / game.tile_width;
			var tile_top_left_Y:int = (y - node.aabb.height / 2) / game.tile_height;
			
			var tile_bottom_right_X:int = (x + node.aabb.width / 2) / game.tile_width;
			var tile_bottom_right_Y:int = (y + node.aabb.height / 2) / game.tile_height;
			
			for(var i:int = tile_top_left_X; i <= tile_bottom_right_X; i++) {
				for(var j:int = tile_top_left_Y; j <= tile_bottom_right_Y; j++) {
					if(game.get_tile(i*game.tile_width, j*game.tile_height) == game.TILE ||
					   (game.get_tile(i*game.tile_width, j*game.tile_height) == game.ONEWAY 
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
				  node.motion.stand_on = null; // reinitialize standings for now
				}
			}
			
			collision_queue = new Array(); // empty the queue
			// check if something collides and fill the collision queue
			for(var i:int = 0; i < nodes.length-1; i++) {
				for(var j:int = i+1; j < nodes.length; j++) {
					if(nodes[i].flag.value == nodes[j].flag.value) { continue; } 
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
				if((collision.a.flag.value == game.PLAYER 
					|| collision.a.flag.value == game.ENEMY) 
					&& collision.b.flag.value == game.MOVING_PLATFORM) {
					// moving platform(b) - player(a) collision
					if(collision.a.position.y+collision.a.aabb.height /2 - collision.a.motion.speed_y 
					   < collision.b.position.y - collision.b.aabb.height / 2 - collision.b.motion.speed_y) { // during last frame, player was above platform
						collision.a.position.y = collision.b.position.y - collision.b.aabb.height / 2 - collision.a.aabb.height /2
								- collision.a.motion.speed_y; // adjust player position to avoid interpenetration
						collision.a.motion.stand_on = collision.b; // player now stands on platform
					}
				}else if(collision.a.flag.value == game.BULLET && collision.b.flag.value == game.ENEMY) {
					if(collision.a.flag.allegiance != collision.b.flag.allegiance) { 
						// kill enemy(b) and remove bullet(a)
						if(!collision.a.flag.remove_next_loop) {
							collision.a.flag.remove_next_loop = true;
						}
						if(!collision.b.flag.remove_next_loop) {
							collision.b.flag.remove_next_loop = true;
						}
					}
				}
			}
			
			// cleanup dead nodes
			remove_dead_nodes(nodes);
		}
		
		public function add(entity:Entity) {
			var new_node:CollisionNode = new CollisionNode(entity.components["P"], entity.components["A"], entity.components["M"], entity.components["F"]) ;
			nodes.push(new_node);
		}
		
		
		public function remove_dead_nodes(nodes:Array) { 
			for(var i:int = 0; i < nodes.length; i++) {
			  if(nodes[i].flag.remove_next_loop) {
				nodes[i] = nodes[nodes.length-1];
				nodes.pop();
			  }
			}
		}
		
	}
	
}