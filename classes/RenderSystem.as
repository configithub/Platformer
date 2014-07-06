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
			//node.animation.current_state = game.IDLE;
			//trace( "speed_x : " + node.motion.speed_x + ", speed_y : " + node.motion.speed_y);
			//trace(node.motion.speed_x > 0 && node.motion.speed_y ==0 );
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
			if(node.animation.animation_states[game.IDLE] != null) {
				if( node.motion.speed_x == 0 && node.motion.speed_y == 0 ) {
					node.animation.current_state = game.IDLE;
				}
			}
			//node.animation.current_state = game.RIGHT;
			
		}
		
		public function loop() {
			for each(var node:RenderNode in nodes) {
				if(node.animation != null) { 
				  find_animation_state(node);
				  if(node.display.display_object.currentLabel != node.animation.get_current_value()) {
					 //trace("animation switch " + node.display.display_object.currentLabel + " / " + node.animation.get_current_value() );
					//node.display.display_object.stop();
					node.display.display_object.stop();
				    node.display.display_object.gotoAndPlay(node.animation.get_current_value());
				  }
				  trace(node.display.display_object.currentFrame);
				} 
				
				node.display.display_object.x = node.position.x;
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