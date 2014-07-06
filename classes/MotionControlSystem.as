package {

	public class MotionControlSystem {

		var game:PlatformerGame;
		var nodes:Array;

		public function MotionControlSystem(aGame:PlatformerGame) {
			game = aGame;
			nodes = new Array();
		}

		public function loop() {
			for each (var node:MotionControlNode in nodes) {
				if (node.cruise == null) {// not a cruising entity, for now it means that it answer to keyboard inputs
                  keyboard_control(node);
				}
			}
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
		}

		public function add(entity:Entity) {
			var new_node:MotionControlNode = new MotionControlNode(entity.components["P"],entity.components["M"],entity.components["C"],entity.components["F"]);
			nodes.push(new_node);
		}


	}

}