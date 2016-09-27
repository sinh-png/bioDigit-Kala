package player;

import kala.behaviors.collision.basic.Collider;
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.display.Flicker;
import kala.input.Touch;
import kala.Kala;
import kala.objects.group.Group.GenericGroup;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kha.FastFloat;
import states.MainMenuState;
import states.PlayState;
import states.UpgradeState;

class Player extends Sprite {

	#if (cap_30 && !debug)
	static inline var runningSpeed = 12;
	static inline var chargingSpeed = 0.02;
	#else
	static inline var runningSpeed = 6;
	static inline var chargingSpeed = 0.01;
	#end
	
	public static var instance:Player;
	
	//
	
	public var lives(default, set):Int;
	
	public var energyBall:EngeryBall;
	
	public var playStateUIGroup:GenericGroup;
	public var chargingProcessText:BasicText;
	
	public var flicker:Flicker;
	
	public var mask:CollisionCircle;
	var collider:Collider;
	
	public var webShot:Int;
	public var charging:Bool;
	public var chargedValue:FastFloat;
	
	var shootAlarm:Int;
	var minionSpawnAlarm:Int;
	var minionSpawned:Int;
	var vspeed:FastFloat;
	
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
		
		collider = new Collider(this);
		mask = collider.addCircle(position.ox, position.oy, 25);
		
		energyBall = new EngeryBall();
		
		flicker = new Flicker(this);
		#if (cap_30 && !debug)
		flicker.delay = 1;
		flicker.visibleDuration = 2;
		#else
		flicker.delay = 2;
		flicker.visibleDuration = 4;
		#end
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);
		
		if (lives > 0) updateAlive(elapsed);
		else {
			animation.play("stand");
			
			y += vspeed;
			#if (cap_30 && !debug)
			vspeed += 1;
			angle += 16;
			#else
			vspeed += 0.25;
			angle += 8;
			#end
			
			energyBall.kill();
			chargingProcessText.kill();
			
			if (y > G.height + height && !PlayState.instance.closing) {
				PlayState.instance.goTo(UpgradeState.instance);
			}
		}
		
		if (!charging) if (playStateUIGroup.opacity < 1) playStateUIGroup.opacity += 0.02;
	}
	
	public function onStart():Void {
		lives = UpgradeData.startingLives;
		position.setXBetween(0, G.width);
		y = 414;
		angle = 0;
		chargedValue = 0;
		shootAlarm = UpgradeData.shootDelay;
		minionSpawnAlarm = 0;
		minionSpawned = 0;
		flicker.flickersLeft = 0;
		energyBall.revive();
		chargingProcessText.revive();
		#if (cap_30 && !debug)
		vspeed = -18;
		#else
		vspeed = -9;
		#end
	}
	
	public function getHit():Void {
		if (PlayState.instance.tutorialState == -1) lives--;
		if (lives > 0) {
			#if (cap_30 && !debug)
			flicker.flicker(30);
			#else
			flicker.flicker(60);
			#end
		}
		#if (cap_30 && !debug)
		Kala.defaultView.shake(18, 15);
		#else
		Kala.defaultView.shake(18, 30);
		#end
	}
	
	inline function updateAlive(elapsed:FastFloat):Void {
		var moving:Int = 0; // -1 - moving left, 1 - moving right, 0 - not moving
		charging = false;
		
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
			if (playStateUIGroup.opacity > 0) playStateUIGroup.opacity -= 0.02;
			
			chargedValue += chargingSpeed;
			if (chargedValue > 1) chargedValue = 1;
			
			if (chargedValue > 0.1) {
				mask.position.y = position.oy + 14;
				animation.play("charge");
				chargingProcessText.visible = true;
				
				if (chargedValue > 0.4) {
					chargingProcessText.text = "LIGHTNING" + " - " + Math.floor((chargedValue - 0.4) / 0.6 * 100) + "%";
				} else {
					chargingProcessText.text = "WEB" + " - " + Math.floor(chargedValue / 0.4 * 100) + "%";
				}
				
				chargingProcessText.x = x - chargingProcessText.width / 2;
				if (chargingProcessText.x < 0) chargingProcessText.x = 0;
				else if (chargingProcessText.x > G.width - chargingProcessText.width) {
					chargingProcessText.x = G.width - chargingProcessText.width;
				}
			} else {
				animation.play("stand");
			}
			
			energyBall.charge(chargedValue, x);
		} else {
			mask.position.y = position.oy;
			
			if (shootAlarm > 0) shootAlarm--;
			else {
				shootAlarm = UpgradeData.shootDelay;
				var middleIndex = Math.floor(UpgradeData.bulletsPerShot / 2);
				if (UpgradeData.bulletsPerShot % 2 == 0) {
					for (i in 0...UpgradeData.bulletsPerShot + 1) {
						if (i == UpgradeData.middleBulletIndex) continue;
						Bullet.shoot1(
							x,
							i - UpgradeData.middleBulletIndex,
							10 + UpgradeData.bulletsPerShot - Math.abs(i - UpgradeData.middleBulletIndex) * 1.6
						);
					}
				} else {
					for (i in 0...UpgradeData.bulletsPerShot) {
						Bullet.shoot1(
							x,
							i - UpgradeData.middleBulletIndex,
							10 + UpgradeData.bulletsPerShot - Math.abs(i - UpgradeData.middleBulletIndex) * 1.6
						);
					}
				}
				
			}
			
			chargingProcessText.visible = false;
			
			if (chargedValue > 0.4) {
				Lightning.shoot(x, (chargedValue - 0.4) / 0.6);
			} else if (chargedValue > 0.1) {
				webShot++;
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
		
		if (minionSpawnAlarm > 0) minionSpawnAlarm--;
		else if (PlayState.instance.tutorialState == -1 || minionSpawned < 6) {
			minionSpawnAlarm = UpgradeData.minionSpawnDelay;
			Minion.create();
		}
	}
	
	function set_lives(value:Int):Int {
		PlayState.instance.livesText.text = "X " + value;
		return lives = value;
	}
	
}