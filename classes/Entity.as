package  {
	
	import flash.display.MovieClip;
	import fl.motion.Motion;
	
	public class Entity extends MovieClip {
		
		var components:Object;
		/*
		*   D : Displayable
		*   P : Position
		*   M : Motion
		*   A : AABBMask
		*   F : Flag
		*/
		var game:PlatformerGame;
		
		public function Entity(aGame:PlatformerGame) {
			game = aGame;
			components = new Object();
		}
		
		public function add_displayable(component:Displayable) {
			component.set_parent(this);
			components["D"] = component;
		}
		
		public function add_position(component:Position) {
		   component.set_parent(this);
		   components["P"] = component;
		}
		
		public function add_motion(component:Motion) { 
		  component.set_parent(this);
		  components["M"] = component;
		}
		
		public function add_aabb_mask(component:AABBMask) {
			component.set_parent(this);
			components["A"] = component;
		}
		
		public function add_flag(component:Flag) {
			component.set_parent(this);
			components["F"] = component;
		}
		
		
	}
}