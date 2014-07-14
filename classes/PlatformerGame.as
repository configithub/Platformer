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
		
		// supported collision modes (in flag component)
		const NO_COLLISION:int = 0;
		const SPECULATIVE_CONTACT:int = 1;
		const PLATFORM_COLLISION:int = 2;
		
		// entity types (in flag component)
		// 0 : void tile;
		const TILE:int = 1;
		const PLAYER:int = 2;
		const ONEWAY:int = 3;
		const BULLET:int = 4;
		const MOVING_PLATFORM:int = 99;
		const ENEMY:int = 6;
		
		// cuise modes (used in motion control system)
		const OSCILLATION:int = 0;
		const ROTATION:int = 1;
		const ONE_WAY_TRIP = 2;
		
		// ai modes (used in motion control system)
		// conditions
		const DO_ON_SIGHT = 0;
		const DO_WHEN_BELOW = 1;
		const DO_WHEN_HIGHER = 2;
		// actions
		const FIRE = 0;
		const FOLLOW = 1;
		const FIND_LEDGE = 2;
		// passive behavior
		const STAY_ON_LEDGE = 0;
		
		/*
		*  if enemy is at the same level as player : either fire at him or follow him horizontally
		*  if enemy is higher than player : follow him horizontally
		*  if enemy is below player : try to find a ledge and when a ledge (one way or moving platform) is juste above enemy, jump
		*  if enemy is at the same level as the player vertically, then stay on ledge (passive behavior), else fall is authorized
		*/
		
		// enemy quntity control
		const MAX_ENEMY:int = 1;
		var nb_enemy:int;
		
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
		var space_released:Boolean;
		
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
		  create_moving_platform(350, 50, 500, 300);
		  nb_enemy = 0;
		}
		
		public function init_input_collection() { 
          stage.addEventListener(KeyboardEvent.KEY_DOWN, report_key_down);
		  stage.addEventListener(KeyboardEvent.KEY_UP, report_key_up);
		}
		
		public function reset_inputs() {
			space_released = false;
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
				space_released = true;
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
			player.add_position(new Position(this, 100, 120));
			player.add_displayable(new Displayable(this, new Player()));
			player.add_motion(new Motion(this, 0, 0, 0, 0, true, true, 10));
			player.add_aabb_mask(new AABBMask(this, 50, 160));
			var player_animation:Animation = new Animation(this);
			player_animation.add_animation_state( IDLE, "idle_player_animation" );
			player_animation.add_animation_state( LEFT, "left_player_animation" );
			player_animation.add_animation_state( RIGHT, "right_player_animation" );
			player.add_animation(player_animation);
			player.add_flag(new Flag(this, PLAYER, SPECULATIVE_CONTACT));
			render_system.add(player); // entity will be rendered
			move_system.add(player); // entity can move
			collision_system.add(player); // entity can collide
			motion_control_system.add(player); // entity can be controlled (via keyboard input in this case)
		}
		
		public function randomly_spawn_enemies(e:TimerEvent) {
			var x:int = (Math.random() * 480) ;
			if( nb_enemy < MAX_ENEMY) {
			  create_enemy(x);
			  nb_enemy += 1;
			}
		}
		
		public function create_enemy(x:int) {
			var enemy:Entity = new Entity(this);
			enemy.add_position(new Position(this, x, -200));
			enemy.add_displayable(new Displayable(this, new Enemy()));
			enemy.add_motion(new Motion(this, 0, 0, 0, 0, true, true, 10));
			enemy.add_aabb_mask(new AABBMask(this, 50, 160));
			var enemy_animation:Animation = new Animation(this);
			enemy_animation.add_animation_state( IDLE, "idle_enemy_animation" );
			enemy_animation.add_animation_state( LEFT, "left_enemy_animation" );
			enemy_animation.add_animation_state( RIGHT, "right_enemy_animation" );
			enemy.add_animation(enemy_animation);
			enemy.add_flag(new Flag(this, ENEMY, SPECULATIVE_CONTACT));
			var ai:AI = new AI(this);
			ai.add_mode(DO_ON_SIGHT, FIRE);
			ai.add_mode(DO_WHEN_HIGHER, FOLLOW);
			ai.add_mode(DO_WHEN_BELOW, FOLLOW);
			enemy.add_ai(ai);
			render_system.add(enemy); // entity will be rendered
			move_system.add(enemy); // entity can move
			collision_system.add(enemy); // entity can collide
			motion_control_system.add(enemy); // entity can be controlled (via keyboard input in this case)
		}

		public function create_moving_platform(x1:int, y1:int, x2:int, y2:int) {
			var platform:Entity = new Entity(this);
			platform.add_position(new Position(this, x1, y1));
			platform.add_displayable(new Displayable(this, new MovingPlatform()));
			var motion:Motion = new Motion(this, 0, 0, 0, 0, false, false, 10);
			motion.motion_priority = 1; // step platforms first
			platform.add_motion(motion);
			platform.add_aabb_mask(new AABBMask(this, 200, 10));
			platform.add_flag(new Flag(this, MOVING_PLATFORM, PLATFORM_COLLISION));
			var cruise:Cruise = new Cruise(this);
			cruise.cruise_mode = OSCILLATION;
			cruise.add_position(x1,y1);
			cruise.add_position(x2,y2);
			platform.add_cruise(cruise);
			render_system.add(platform);
			move_system.add(platform);
			collision_system.add(platform);
			motion_control_system.add(platform);
		}

		public function get_tile_x(x:int):int {
			return x / tile_width;
		}
		
		public function get_tile_y(y:int):int {
			return y / tile_height;
		}
		
		public function create_tile( x:int, y:int ):Entity {
			var tile:Entity = new Entity(this);
			tile.add_position(new Position(this, x, y));
			tile.add_displayable(new Displayable(this, new Tile()));
			tile.add_flag(new Flag(this, TILE, NO_COLLISION));
			render_system.add(tile);
			return tile;
		}
		
		public function create_oneway_tile( x:int, y:int):Entity {
			var tile:Entity = new Entity(this);
			tile.add_position(new Position(this, x,y));
			tile.add_displayable(new Displayable(this, new OneWay()));
			tile.add_flag(new Flag(this, ONEWAY, NO_COLLISION));
			render_system.add(tile);
			return tile;
		}
		
		public function entity_fires(entity:Entity) {
			var bullet:Entity = new Entity(this);
			var bullet_exit_offset_x:int;
			var bullet_exit_offset_y:int;
			var bullet_speed:int;
			if(entity.components["M"].is_facing_left == true) {
				bullet_exit_offset_x = -25;
				bullet_speed = -30;
			}else{
				bullet_exit_offset_x = 25;
				bullet_speed = 30;
			}
			bullet_exit_offset_y = -10;
			bullet.add_position( new Position(this, entity.components["P"].x + bullet_exit_offset_x, entity.components["P"].y + bullet_exit_offset_y));
			bullet.add_displayable(new Displayable(this, new Bullet()));
			bullet.add_motion(new Motion(this, bullet_speed, 0, 0, 0, false, false, Math.abs(bullet_speed)));
			bullet.add_flag(new Flag(this, BULLET, NO_COLLISION));
			render_system.add(bullet);
			move_system.add(bullet); 
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
						   0, 0, 0, 3, 3, 3, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
			
		}
		
		public function start() {
			game_timer = new Timer(25);
			game_timer.addEventListener( TimerEvent.TIMER, loop );
			game_timer.start();
			
			var spawn_timer:Timer = new Timer(10000);
			spawn_timer.addEventListener( TimerEvent.TIMER, randomly_spawn_enemies);
			spawn_timer.start();
		}
		
		public function loop( e:TimerEvent ) {
			motion_control_system.loop();
			move_system.loop();
			collision_system.loop();
			render_system.loop();
			reset_inputs();
		}
		
		public function draw_map() {
			var x:int = 0;
			var y:int = 0;
			for each (var i in map) {
				if( i == TILE ) {
					create_tile( x * tile_width + tile_width / 2,  y * tile_height + tile_height / 2 );
				}else if( i == ONEWAY ) {
					create_oneway_tile( x * tile_width + tile_width / 2,  y * tile_height + tile_height / 2 );
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
