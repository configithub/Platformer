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
		
		public function loop() {
			for each(var node:RenderNode in nodes) {
				node.display.display_object.x = node.position.x;
				node.display.display_object.y = node.position.y;
			}
		}
		
		public function add(entity:Entity) {
			var new_node:RenderNode = new RenderNode(entity.components["P"], entity.components["D"]) ;
			nodes.push(new_node);
			container.addChild(new_node.display.display_object);
		}
		
	}
}