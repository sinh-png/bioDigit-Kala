package enemies;

import kala.math.Mathf;
import kala.math.Position;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kha.FastFloat;
import kha.Image;
import states.PlayState;

class Gem extends Sprite {

	#if (cap_30 && !debug)
	static inline var collectedSpeed = 18;
	static inline var gravity = 0.2;
	#else
	static inline var collectedSpeed = 9;
	static inline var gravity = 0.1;
	#end
	
	//
	
	public static var playerPos:Position;
	public static var gemText:BasicText;
	
	public static var group:Group<Gem> = new Group<Gem>(false, function() return new Gem());
	
	public static inline function create(x:FastFloat, y:FastFloat):Void {
		var gem = group.createAlive();
		gem.setXY(x, y);
		gem.scale.x = Random.roll();
		gem.scale.y = Random.roll();
		gem.angleOffset = Random.fast( -90, 90);
		
		#if (cap_30 && !debug)
		gem.hspeed = Random.fast( -4, 4);
		gem.vspeed = Random.fast( -2, -6);
		gem.time = 30;
		#else
		gem.hspeed = Random.fast( -2, 2);
		gem.vspeed = Random.fast( -1, -3);
		gem.time = 60;
		#end
	}
	
	//
	
	var hspeed:FastFloat;
	var vspeed:FastFloat;
	var angleOffset:FastFloat;
	var time:FastFloat;
	
	public function new() {
		super();
		loadSpriteData(R.gem, R.images.sprite_sheet_2);
		setOrigin(width / 2, height / 2);
	}
	
	override public function update(elapsed:FastFloat):Void {
		if (time == 0) {
			var distance = position.getDistance(playerPos);
			if (distance < 40) {
				kill();
				if (!G.tutorialPassed || PlayState.instance.tutorialState == -1) {
					UpgradeData.money++;
					gemText.text = "X " + UpgradeData.money;
				}
			} else if (distance < UpgradeData.gemCollectionDistance) {
				var a = position.getAngle(playerPos, false);
				angle = Mathf.deg(a);
				hspeed = collectedSpeed * Math.cos(a);
				vspeed = collectedSpeed * Math.sin(a);
			}
		} else {
			time--;
		}
		
		if (vspeed == 0 && hspeed == 0) return;
		
		if ((x < 0 && hspeed < 0) || (x > G.width && hspeed > 0)) hspeed = -hspeed * 0.8;
		
		if (y > 440 && vspeed > 0) {
			if (vspeed < 1) {
				vspeed = hspeed = 0;
			} else {
				vspeed = -vspeed * 0.6;
				hspeed *= 0.5;
			}
		}
		
		position.move(hspeed, vspeed);
		
		vspeed += gravity;
		
		angle = (hspeed + vspeed) * 20 + angleOffset;
	}
	
}