package{
	
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    
	public class RenderSystem {
		
		var game:PlatformerGame;
		var nodes:Array;
		
		var container:DisplayObjectContainer;
		
		public function RenderSystem(aGame:PlatformerGame) {
			game = aGame;
			container = game;
			nodes = new Array();
		}
		
		public function player_position():Position { 
			return game.player.components["P"];
		}
		
		public function is_standing(node:RenderNode) { // check if entity is standing on something (map or other entity)
			if(node.motion.stand_on == null && node.motion.speed_y == 0
			 || node.motion.stand_on != null) {
				 return true;
			}
			return false;
		}
		
		public function find_animation_state(node:RenderNode) {
			if(node.animation.animation_states[game.LEFT] != null) {
				if( node.motion.speed_x < 0 && is_standing(node) ) {
					node.animation.current_state = game.LEFT;
					node.motion.is_facing_left = true;
				}
			}
			if(node.animation.animation_states[game.RIGHT] != null) {
				if( node.motion.speed_x > 0 && is_standing(node) ) {
					node.animation.current_state = game.RIGHT;
					node.motion.is_facing_left = false;
				}
			}
			if(node.animation.animation_states[game.IDLE] != null) {
				if( node.motion.speed_x == 0 && is_standing(node) ) {
					node.animation.current_state = game.IDLE;
				}
			}
		}
		
		public function loop() {
			for each(var node:RenderNode in nodes) {
				if(node.animation != null) { 
				  find_animation_state(node);
				  // apply animation state
				  if(node.display.display_object.currentLabel != node.animation.get_current_value()) {
					node.display.display_object.stop();
				    node.display.display_object.gotoAndPlay(node.animation.get_current_value());
				  }
				} 
				// render entity
				node.display.display_object.x = node.position.x - player_position().x + 320;
				node.display.display_object.y = node.position.y;
			}
		}
		
		public function add(entity:Entity) {
			var new_node:RenderNode = new RenderNode(entity.components["P"], entity.components["M"], entity.components["D"], entity.components["N"]) ;
			new_node.display.display_object.stop();
			nodes.push(new_node);
			container.addChild(new_node.display.display_object);
		}
		
	}
}