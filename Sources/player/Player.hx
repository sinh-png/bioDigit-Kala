package player;

import kala.input.Touch;
import kala.Kala;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kha.FastFloat;
import states.PlayState;

class Player extends Sprite {

	#if (cap_30 && !debug)
	static inline var runningSpeed = 12;
	static inline var chargingSpeed = 0.04;
	static inline var shootAlarmFrames = 10;
	#else
	static inline var runningSpeed = 6;
	static inline var chargingSpeed = 0.02;
	static inline var shootAlarmFrames = 20;
	#end
	
	public static var instance:Player;
	
	//
	
	public var energyBall:EngeryBall;
	public var chargingProcessText:BasicText;
	
	var chargedValue:FastFloat;
	var shootAlarm:Int = shootAlarmFrames;
	
	public function new() {
		super();
		
		#if (cap_30 && !debug)
		loadSpriteData(R.sheets.sprite_sheet_2.get("player/frames/charge/"), R.images.sprite_sheet_2, "charge", 2);
		loadSpriteData(R.sheets.sprite_sheet_2.get("player/frames/run/"), R.images.sprite_sheet_2, "run", 3);
		loadSpriteData(R.sheets.sprite_sheet_2.get("player/frames/stand/"), R.images.sprite_sheet_2, "stand", 3);
		#else
		loadSpriteData(R.sheets.sprite_sheet_2.get("player/frames/charge/"), R.images.sprite_sheet_2, "charge", 4);
		loadSpriteData(R.sheets.sprite_sheet_2.get("player/frames/run/"), R.images.sprite_sheet_2, "run", 6);
		loadSpriteData(R.sheets.sprite_sheet_2.get("player/frames/stand/"), R.images.sprite_sheet_2, "stand", 6);
		#end
		
		centerOrigin();
		position.setXBetween(0, G.width);
		y = 414;
		
		energyBall = new EngeryBall();
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);

		if (kala.input.Keyboard.SPACE.justPressed) Minion.create();
	
		var charging:Bool = false;
		var moving:Int = 0; // -1 - moving left, 1 - moving right, 0 - not moving
		
		#if js
		if (Kala.html5.mobile) {
			var touchSide = Touch.touches.getSide(G.width / 2);
			if (touchSide == 3) {
				charging = true;
			} else if (touchSide == 2) {
				moving = 1;
			} else if (touchSide == 1) {
				moving = -1;
			}
		} else {
			if (kala.input.Keyboard.LEFT.pressed) {
				if (kala.input.Keyboard.RIGHT.pressed) {
					charging = true;
				} else {
					moving = -1;
				}
			} else {
				if (kala.input.Keyboard.RIGHT.pressed) moving = 1;
			}
		}
		#elseif flash
		if (kala.input.Keyboard.LEFT.pressed) {
			if (kala.input.Keyboard.RIGHT.pressed) {
				charging = true;
			} else {
				moving = -1;
			}
		} else {
			if (kala.input.Keyboard.RIGHT.pressed) moving = 1;
		}
		#end
		
		if (charging) {
			chargedValue += chargingSpeed;
			if (chargedValue > 1) chargedValue = 1;
			
			if (chargedValue > 0.1) {
				animation.play("charge");
				
				chargingProcessText.visible = true;
				
				if (chargedValue > 0.5) {
					chargingProcessText.text = "LIGHTNING";
				} else {
					chargingProcessText.text = "WEB";
				}
				
				chargingProcessText.x = x - chargingProcessText.width / 2;
			} else {
				animation.play("stand");
			}
			
			energyBall.charge(chargedValue, x);
		} else {
			if (shootAlarm > 0) shootAlarm--;
			else {
				shootAlarm = shootAlarmFrames;
				//for(i in 0...7) Bullet.shoot1(x, (i - 3), 20 - Math.abs(i - 3) * 1.6);
			}
			
			chargingProcessText.visible = false;
			
			if (chargedValue > 0.4) {
				Lightning.shoot(x);
			} else if (chargedValue > 0.1) {
				Web.shoot(x);
			}
			
			energyBall.visible = false;
			chargedValue = 0;
			
			if (moving != 0) {
				animation.play("run");
				scale.x = -moving;
				x += runningSpeed * moving;
				if (x < 0) x = 0;
				else if (x > G.width) x = G.width;
			} else {
				animation.play("stand");
			}
		}
	}
	
	public function restart():Void {
		chargedValue = 0;
	}
	
}