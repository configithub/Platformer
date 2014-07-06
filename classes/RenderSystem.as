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
		
		public function find_animation_state(node:RenderNode) {
			if(node.animation.animation_states[game.IDLE] != null) {
				if( node.motion.speed_x == 0 && node.motion.speed_y == 0 ) {
						node.animation.current_state = game.IDLE;
				}
			}
			if(node.animation.animation_states[game.LEFT] != null) {
				if( node.motion.speed_x < 0 && node.motion.speed_y ==0 ) {
					node.animation.current_state = game.LEFT;
				}
			}
			if(node.animation.animation_states[game.RIGHT] != null) {
				if( node.motion.speed_x > 0 && node.motion.speed_y ==0 ) {
					node.animation.current_state = game.RIGHT;
				}
			}
		}
		
		public function loop() {
			for each(var node:RenderNode in nodes) {
				if(node.animation != null) { find_animation_state(node); } // animated object
				node.display.display_object.x = node.position.x;
				node.display.display_object.y = node.position.y;
			}
		}
		
		public function add(entity:Entity) {
			var new_node:RenderNode = new RenderNode(entity.components["P"], entity.components["M"], entity.components["D"], entity.components["N"]) ;
			nodes.push(new_node);
			container.addChild(new_node.display.display_object);
		}
		
	}
}