package {

	public class MotionControlSystem {

		var game:PlatformerGame;
		var nodes:Array; // things that needs to be moved first (i.e. moving platforms)
		var nodes2:Array; // things that will be moved later on

		// the player is a special entity, especially for entities that are under ai control, 
		// so we might need it across the whole motion control system
		// to avoid picking it again and again we store it in this variable
		var player_node:MotionControlNode; 

		public function MotionControlSystem(aGame:PlatformerGame) {
			game = aGame;
			nodes = new Array();
			nodes2 = new Array();
		}
		
		public function find_player_node() { 
			for each(var node:MotionControlNode in nodes2) { // player should always be in nodes2
				if(node.flag.value == game.PLAYER) {
					player_node = node;
				}
			}
		}

		public function loop_node_array(node_array:Array) {
			for each (var node:MotionControlNode in node_array) {
				if (node.flag.value == game.PLAYER) {// not a cruising entity, for now it means that it answer to keyboard inputs
                    keyboard_control(node);
				}else if(node.ai != null) {
					ai_control(node);
				}else if(node.cruise != null){
					cruise_control(node);
				}
			}
		}

		public function loop() {
			// find player 
			find_player_node();
			// loop both node array, order matters
			loop_node_array(nodes);
			loop_node_array(nodes2);
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
			  game.entity_fires(node.position.entity);
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
		
		public function ai_control(node:MotionControlNode) { 
			if(node.ai.modes[game.DO_ON_SIGHT] != null && player_on_sight(node)) {
				do_action(node, node.ai.modes[game.DO_ON_SIGHT]);
			}else if(node.ai.modes[game.DO_WHEN_BELOW] != null && entity_is_below(node)) {
				do_action(node, node.ai.modes[game.DO_WHEN_BELOW]);
			}else if(node.ai.modes[game.DO_WHEN_HIGHER] != null && entity_is_higher(node)) {
				do_action(node, node.ai.modes[game.DO_WHEN_HIGHER]);
			}
		}
		
		public function player_on_sight(node:MotionControlNode) {
			var error_margin:int = 30;
			if(player_node.position.y < node.position.y + error_margin
			   && player_node.position.y > node.position.y - error_margin) {
				return true;   
			}
			return false;
		}
		
		public function entity_is_below(node:MotionControlNode) { 
			var error_margin:int = 80;
			if(player_node.position.y < node.position.y - error_margin) {
				return true;
			}
			return false;
		}
		
		public function entity_is_higher(node:MotionControlNode) { 
			var error_margin:int = 80;
			if(player_node.position.y > node.position.y + error_margin) {
				return true;
			}
			return false;
		}
		
		public function do_action(node:MotionControlNode, action_id:int) {
			if(action_id == game.FIRE) {
				node.motion.is_facing_left = player_node.position.x < node.position.x;
				game.entity_fires(node.position.entity);
			}else if(action_id == game.FOLLOW) { 
				follow(node);
			}else if(action_id == game.FIND_LEDGE) {
				find_ledge_and_climb(node);
			}
		}
		
		public function follow(node:MotionControlNode) { 
		    if(node.motion.hori_map_collision_last_frame == game.RIGHT_COLLISION ||
			   node.motion.hori_map_collision_last_frame == game.LEFT_COLLISION) {
				   jump(node);
			 }
			var error_margin_x:int = 40;
			if(player_node.position.x > node.position.x + error_margin_x) {
				node.motion.accel_x = 5;
			}else if (player_node.position.x < node.position.x - error_margin_x){
				node.motion.accel_x = -5;
			}
		}
		
		public function find_ledge_and_climb(node:MotionControlNode) {
			if(!find_oneway_tile(node)) { 
				if(node.position.x  > 620) {
					node.motion.accel_x = -5;
				}
				if(node.position.x < 60) { 
					node.motion.accel_x = 5;
				}
			
				if(node.motion.is_facing_left) {
					node.motion.accel_x = -5;
				}else{
					node.motion.accel_x = 5;
				}
				if(node.motion.can_jump) { 
					var rand_task:Number = Math.random();
					if(node.motion.hori_map_collision_last_frame == game.RIGHT_COLLISION) {
						if(rand_task > 0.5) { node.motion.accel_x = -5;
						}else{ jump(node); node.motion.accel_x = 5; }
					}else if(node.motion.hori_map_collision_last_frame == game.LEFT_COLLISION) { 
						if(rand_task > 0.5) { node.motion.accel_x = 5;
						}else{ jump(node); node.motion.accel_x = -5; }
					}
				}
			}else {
				node.motion.accel_x = 0;
				node.motion.speed_x = 0;
				jump(node);
			}
		}
		
		public function jump(node:MotionControlNode) { 
			if(node.motion.can_jump) {
				node.motion.can_jump = false; node.motion.accel_y = -10;
			}
		}
		
		public function find_oneway_tile(node:MotionControlNode):Boolean {
			var x:int = node.position.x;
			var y:int = node.position.y;
			var width:int = 40;
			var height:int = 200;
			var tile_top_left_X:int = game.get_tile_x( x - width / 2);
			var tile_top_left_Y:int = game.get_tile_y( y - height / 2);
			
			var tile_bottom_right_X:int = game.get_tile_x(x + width);
			var tile_bottom_right_Y:int = game.get_tile_y(y + height);
			
			for(var i:int = tile_top_left_X; i <= tile_bottom_right_X; i++) {
				for(var j:int = tile_top_left_Y; j <= tile_bottom_right_Y; j++) {
					if(game.map[ i + j * game.map_width ] == game.ONEWAY) { return true; }
				}
			}
			return false;
		}

		public function add(entity:Entity) {
			var new_node:MotionControlNode = new MotionControlNode(entity.components["P"], entity.components["M"],
								entity.components["C"], entity.components["I"], entity.components["F"]);
			if(new_node.motion.motion_priority == 1) {
				nodes.push(new_node);
			}else{
				nodes2.push(new_node);
			}
		}
	}
}