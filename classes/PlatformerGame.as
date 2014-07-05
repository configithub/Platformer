package  {
	
	import flash.display.MovieClip;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	
	public class PlatformerGame extends MovieClip {
		
		var map_width:int;
		var map_height:int;
		var map:Array;
		
		var tile_width:int;
		var tile_height:int;
		
		var player:Entity;
		
		var render_system:RenderSystem;
		var move_system:MoveSystem;
		var collision_system:CollisionSystem;
		
		var game_timer:Timer;
		
		public function PlatformerGame() {
			// constructor code
			init();
			start();
		}
		
		public function init() { 
		  init_systems();
		  init_map();
		  draw_map();
		  init_player();
		}
		
		public function init_systems() { 
			render_system = new RenderSystem(this);
			move_system = new MoveSystem(this);
			collision_system = new CollisionSystem(this);
		}
		
		public function init_player() {
			player = new Entity(this);
			player.add_position(new Position(this, 550, 120));
			player.add_displayable(new Displayable(this, new Player()));
			render_system.add(player); // entity will be rendered
			player.add_motion(new Motion(this, 0, 5, 0, 0));
			move_system.add(player); // entity can move
			player.add_aabb_mask(new AABBMask(this, 50, 80));
			player.add_flag(new Flag(this, 2));
			collision_system.add(player);
		}
		
		public function create_tile( x:int, y:int ):Entity {
			var tile:Entity = new Entity(this);
			tile.add_position(new Position(this, x, y));
			tile.add_displayable(new Displayable(this, new Tile()));
			tile.add_aabb_mask(new AABBMask(this, tile_width, tile_height));
			tile.add_flag(new Flag(this, 1));
			render_system.add(tile);
			collision_system.add(tile);
			return tile;
		}
		
		public function init_map() {
	      tile_width = 32;
		  tile_height = 32;
		  map_width = 20;
		  map_height = 15;
		  map  = new Array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			    		   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
			
		}
		
		public function start() {
			game_timer = new Timer(25);
			game_timer.addEventListener( TimerEvent.TIMER, loop );
			game_timer.start();
		}
		
		public function loop( e:TimerEvent ) {
			move_system.loop();
			collision_system.loop();
			render_system.loop();
		}
		
		public function draw_map() {
			var x:int = 0;
			var y:int = 0;
			for each (var i in map) {
				if( i == 1 ) {
					create_tile( x * tile_width + tile_width / 2,  y * tile_height + tile_height / 2 );
				}
				x += 1;
				if( x >= map_width) { 
				  y += 1;
				}
				x = x % map_width;
				y = y % map_height;
			}
		}
	}
	
}
