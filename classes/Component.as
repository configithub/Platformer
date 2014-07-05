package  {
	
	public class Component  {
		
		var entity:Entity;
		
		public function Component() {
			
		}
		
		public function set_parent(aEntity:Entity) { 
		  entity = aEntity;
		}
		
	}
}