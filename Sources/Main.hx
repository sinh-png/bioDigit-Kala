package;

import kala.asset.Assets;
import kala.debug.Debug;
import kala.Kala;
import kala.objects.group.View;
import kala.objects.text.BasicText;
import states.Preloader;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.notify(function(_) {
			Kala.defaultFont = Assets.fonts.font_1;
			//Debug.collisionDebug = true;
			
			Kala.defaultView = new View(0, 0, G.width, G.height, 16);
			Kala.defaultView.setCenterScaleMode(RATIO);
			Kala.world.addView(Kala.defaultView);
			
			G.state = new Preloader();
			Kala.world.add(G.state);
			
			var text = new BasicText(Assets.fonts.font_1);
			Kala.world.add(text);
			
			Kala.world.onPostUpdate.notify(function(_, _) {
				text.text = "" + Kala.fps;
			});
			
			#if js
			Kala.html5.fillPage();
			#end
		});
		
		Kala.start("bioDigit", G.width, G.height, 1, 60);
	}
	
}
