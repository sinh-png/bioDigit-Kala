package player;

import kala.behaviors.collision.basic.Collider;
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.math.Mathf;
import kala.math.Position;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kha.FastFloat;
import kha.Image;
import states.PlayState;

class Minion extends Sprite {
	
	#if (cap_30 && !debug)
	static inline var lightningDelay = 120;
	#else
	static inline var lightningDelay = 240;
	#end
	
	public static var group:Group<Minion> = new Group<Minion>(false, function() return new Minion());
	
	public static inline function create():Void {
		var child = group.createAlive();
	}
	
	//
	
	public var lives:Int;
	
	public var mask:CollisionCircle;
	var collider:Collider;
	
	var moveAlarm:Int;
	var dx:FastFloat;
	var playerPos:Position;
	
	var shootAlarm:Int;
	var lightningAlarm:Int;
	
	var vspeed:FastFloat;
	
	var hitDelayAlarm:Int;
	
	public function new() {
		super();
		
		#if (cap_30 && !debug)
		loadSpriteData(R.playerChildStanding, "stand", 2);
		loadSpriteData(R.playerChildRunning, "run", 3);
		#else
		loadSpriteData(R.playerChildStanding, "stand", 4);
		loadSpriteData(R.playerChildRunning, "run", 6);
		#end
		
		centerOrigin();
		
		playerPos = PlayState.instance.player.position;
		
		collider = new Collider(this);
		mask = collider.addCircle(position.ox, position.oy, 15);
		
		revive();
	}
	
	override public function revive():Void {
		super.revive();
		setXY(playerPos.x, playerPos.y);
		lives = UpgradeData.minionStartingLives;
		moveAlarm = 0;
		shootAlarm = UpgradeData.shootDelay;
		lightningAlarm = lightningDelay;
		angle = 0;
		hitDelayAlarm = 0;
		#if (cap_30 && !debug)
		vspeed = -10;
		#else
		vspeed = -5;
		#end
	}
	
	override public function update(elapsed:FastFloat):Void {
		if (lives == 0) {
			y += vspeed;
			#if (cap_30 && !debug)
			vspeed += 1;
			angle += 16;
			#else
			vspeed += 0.25;
			angle += 8;
			#end
			if (y > G.height + height) kill();
			return;
		}
		
		if (hitDelayAlarm > 0) hitDelayAlarm--;
		
		if (shootAlarm > 0) shootAlarm--;
		else {
			shootAlarm = UpgradeData.minionShootDelay;
			Bullet.shoot2(x);
		}
		
		if (lightningAlarm > 0) lightningAlarm--;
		else {
			lightningAlarm = lightningDelay;
			if (Random.bool(UpgradeData.minionLightningChance)) {
				Lightning.shoot(x, 0);
			}
			
		}
		
		if (Math.abs(dx - playerPos.x) > 150) move();
		else {
			if (moveAlarm > 0) moveAlarm--;
			else {
				#if (cap_30 && !debug)
				moveAlarm = Random.int(100, 200);
				#else
				moveAlarm = Random.int(200, 400);
				#end
				move();
			}
		}
		
		if (x == dx) {
			animation.play("stand");
		} else {
			animation.play("run");
			
			var distance = x - dx;
			var speed = 2 + Math.abs(distance) / 40;
			#if (!cap_30 || debug)
			speed /= 2;
			#end
			
			if (distance > speed) {
				x -= speed;
				scale.x = -1;
			} else if (distance < -speed) {
				x += speed;
				scale.x = 1;
			} else x = dx;
		}
		
		#if (cap_30 && !debug)
		if (y < 430) y += 5;
		#else
		if (y < 430) y += 2.5;
		#end
	}
	
	public function getHit():Void {
		if (hitDelayAlarm > 0) return;
		#if (cap_30 && !debug)
		hitDelayAlarm = 30;
		#else
		hitDelayAlarm = 60;
		#end
		lives--;
	}
	
	inline function move():Void {
		dx = Mathf.clamp(playerPos.x + Random.int( -150, 150), 0, G.width);
	}
	
}