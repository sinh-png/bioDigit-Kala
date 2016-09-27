package enemies;

import kala.behaviors.motion.VelocityMotion;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.math.Random;
import kala.objects.group.Group;
import kala.util.pool.Pool;
import kha.FastFloat;
import states.PlayState;

class EnemyB extends Enemy {
	
	#if (cap_30 && !debug)
	static inline var turnSpeed = 6;
	static inline var accel = -0.1;
	static inline var baseSpeed = -4;
	#else
	static inline var turnSpeed = 6;
	static inline var accel = -0.05;
	static inline var baseSpeed = -2;
	#end
	
	public static var childGroup:Group<EnemyB> = new Group<EnemyB>(false, function() {
		var child = new EnemyB();
		child.scale.setXY(0.5, 0.5);
		child.addCircleMask(child.halfWidth, child.halfHeight, 15);
		child.revive();
		child.motion = new VelocityMotion(child);
		child.motion.accel = accel;
		
		child.onPreUpdate.notify(function(_, elapsed) {
			if (child.motion.velocity.speed > baseSpeed) child.motion.velocity.angle += turnSpeed * elapsed;
			
			if (
				child.motion.velocity.speed < baseSpeed &&
				(
					child.x < -child.halfWidth || child.x > G.width + child.halfWidth ||
					child.y < -child.halfHeight || child.y > G.height + child.halfHeight
				)
			) {
				child.alive = false;
			}
			
			return false;
		});
		
		return child;
	});
	
	//

	static var pool:Pool<EnemyB> = new Pool<EnemyB>(function() {
		var enemy = new EnemyB();
		enemy.addCircleMask(enemy.halfWidth, enemy.halfHeight, 30);
		PlayState.instance.enemyGroup.add(enemy);
		return enemy;
	});
	
	public static inline function create(x:FastFloat, y:FastFloat):Void {
		PlayState.instance.onScreenEnemyCount++;
		
		var enemy = pool.get();
		enemy.revive();
		enemy.setXY(x, y);
		enemy.scale.setXY(1, 1);
		enemy.hp = 200;
		enemy.bodyAtkOn = false;
		enemy.isSubEnemy = false;
		enemy.moveRandom(function() {
			G.sfxGroup.play(R.sounds.spawn, 0.4);
			for (i in 0...6) {
				enemy.createChild(60 * i);
			}
		});
	}
	
	public static inline function createRandomPos():Void {
		switch(Random.int(0, 2)) {
			case 0: create( -60, Random.int(0, 300));
			case 1: create(G.width + 60, Random.int(0, 300));
			case 2: create(Random.int(60, G.width - 60), -60);
		}
	}
	
	//
	
	var motion:VelocityMotion;
	
	public function new() {
		super();
		
		sprite.loadSpriteData(R.enemyB);
		setOrigin(halfWidth = sprite.width / 2, halfHeight = sprite.height / 2);

		hpText.setXY(halfWidth, halfHeight);
		hpText.size = 30;
		
		initDeathEffect();
		
		#if (cap_30 && !debug)
		tween.get()
			.startLoop()
				.tweenAngle(this, -15, 15, 60, Ease.sineInOut)
				.tweenAngle(this, 15, -15, 60, Ease.sineInOut)
			.endLoop()
		.start();
		#else
		tween.get()
			.startLoop()
				.tweenAngle(this, -15, 15, 120, Ease.sineInOut)
				.tweenAngle(this, 15, -15, 120, Ease.sineInOut)
			.endLoop()
		.start();
		#end
	}
	
	override public function kill():Void {
		if (scale.x == 1) {
			gemDropQuantity = 5;
		} else {
			motion.velocity.speed = 0;
			gemDropQuantity = 1;
		}
		
		super.kill();
	}
	
	override function put():Void {
		super.put();
		if (scale.x == 1) pool.putUnsafe(this);
	}
	
	inline function createChild(angle:FastFloat):Void {
		var child = childGroup.createAlive();
		child.setXY(x, y);
		child.hp = 20;
		child.motion.velocity.setAngleSpeed(angle, 5);
		child.motion.turnSpeed = 0;
		child.bodyAtkOn = true;
		child.isSubEnemy = true;
	}

}