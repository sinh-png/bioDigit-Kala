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
	
	public static var myGroup:Group<Minion> = new Group<Minion>(false, function() return new Minion());
	
	public static inline function create():Void {
		var child = myGroup.createAlive();
	}
	
	//
	
	var moveAlarm:Int;
	var dx:FastFloat;
	var playerPos:Position;
	
	var shootAlarm:Int;
	
	var collider:Collider;
	var mask:CollisionCircle;
	
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
		moveAlarm = 0;
		shootAlarm = 4;
	}
	
	override public function update(elapsed:FastFloat):Void {
		if (shootAlarm > 0) shootAlarm--;
		else {
			Bullet.shoot2(x);
			#if (cap_30 && !debug)
			shootAlarm = 5;
			#else
			shootAlarm = 10;
			#end
		}
		
		if (Math.abs(dx - playerPos.x) > 150) move();
		else {
			if (moveAlarm > 0) moveAlarm--;
			else {
				move();
				#if (cap_30 && !debug)
				moveAlarm = Random.int(100, 200);
				#else
				moveAlarm = Random.int(200, 400);
				#end
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
	
	inline function move():Void {
		dx = Mathf.clamp(playerPos.x + Random.int( -150, 150), 0, G.width);
	}
	
}