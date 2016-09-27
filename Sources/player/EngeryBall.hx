package player;

import kala.behaviors.tween.Ease;
import kala.math.Random;
import kala.objects.sprite.Sprite;
import kha.FastFloat;

class EngeryBall extends Sprite {

	public function new() {
		super();
		loadSpriteData(R.sheets.sprite_sheet_2.get("player/ball/"), R.images.sprite_sheet_2, 5).animation.play();
		setOrigin(width / 2, height / 2);
		visible = false;
	}
	
	public function charge(factor:FastFloat, x:FastFloat):Void {
		visible = true;
		this.x = x;
		
		factor = Ease.sineInOut(factor) * Random.float(0.85, 1);
		y = 390 - 40 * factor;
		scale.setXY(factor, factor);
	}
	
}