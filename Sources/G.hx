package;

import kala.Kala;
import kala.objects.group.Group.GenericGroup;
import kala.objects.group.View;

class G {

	public static inline var width = 700;
	public static inline var height = 495;
	public static inline var halfWidth = width / 2;
	
	public static var state:GenericGroup;
	
	public static inline function switchState(state:GenericGroup):Void {
		Kala.world.swap(G.state, state);
		G.state = state;
	}
	
}