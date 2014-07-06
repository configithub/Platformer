package  {
	
	import flash.display.MovieClip;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	
	import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
	
	public class PlatformerGame extends MovieClip {
		
		// supported animation states 
		const IDLE:int = 0;
		const LEFT:int = 1;
		const RIGHT:int = 2;
		const JUMPING_LEFT:int = 3;
		const JUMPRING_RIGHT:int = 4;
		
		var map_width:int;
		var map_height:int;
		var map:Array;
		
		var tile_width:int;
		var tile_height:int;
		
		var player:Entity;
		
		// systems
		var render_system:RenderSystem;
		var move_system:MoveSystem;
		var collision_system:CollisionSystem;
		var motion_control_system:MotionControlSystem;
		
		var left_pushed:Boolean;
		var right_pushed:Boolean;
		var up_pushed:Boolean;
		var down_pushed:Boolean;
		var space_pushed:Boolean;
		
		var game_timer:Timer;
		
		public function PlatformerGame() {
			// init all systems + map + entity sprites + input collection
			init();
			// start game loop
			start();
		}
		
		public function init() { 
		  init_systems();
		  init_map();
		  draw_map();
		  init_input_collection();
		  init_player();
		}
		
		public function init_input_collection() { 
          stage.addEventListener(KeyboardEvent.KEY_DOWN, report_key_down);
		  stage.addEventListener(KeyboardEvent.KEY_UP, report_key_up);
		}
		
		public function reset_inputs() {
			left_pushed = false;
			right_pushed = false;
			up_pushed = false;
			down_pushed = false;
			space_pushed = false;
		}
		
		public function report_key_down(event:KeyboardEvent) { 
			if (event.keyCode == 37) {
				left_pushed = true;
			}else if(event.keyCode == 39) {
				right_pushed = true;
			}else if(event.keyCode == 40) {
				down_pushed = true;
			}else if(event.keyCode == 38) {
				up_pushed = true;
			}else if(event.keyCode == 32) {
				space_pushed = true;
			}
		}
		
		public function report_key_up(event:KeyboardEvent) { 
			if (event.keyCode == 37) {
				left_pushed = false;
			}else if(event.keyCode == 39) {
				right_pushed = false;
			}else if(event.keyCode == 40) {
				down_pushed = false;
			}else if(event.keyCode == 38) {
				up_pushed = false;
			}else if(event.keyCode == 32) {
				space_pushed = false;
			}
		}
		
		public function init_systems() { 
			render_system = new RenderSystem(this);
			move_system = new MoveSystem(this);
			collision_system = new CollisionSystem(this);
			motion_control_system = new MotionControlSystem(this);
		}
		
		public function init_player() {
			player = new Entity(this);
			player.add_position(new Position(this, 550, 120));
			player.add_displayable(new Displayable(this, new Player()));
			player.add_motion(new Motion(this, 0, 0, 0, 0, true, true, 10));
			player.add_aabb_mask(new AABBMask(this, 50, 80));
			var player_animation:Animation = new Animation(this);
			player_animation.add_animation_state( IDLE, "idle_player_animation" );
			player_animation.add_animation_state( LEFT, "left_player_animation" );
			player_animation.add_animation_state( RIGHT, "right_player_animation" );
			player.add_animation(player_animation);
			player.add_flag(new Flag(this, 2));
			render_system.add(player); // entity will be rendered
			move_system.add(player); // entity can move
			collision_system.add(player); // entity can collide
			motion_control_system.add(player);
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
			motion_control_system.loop();
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
