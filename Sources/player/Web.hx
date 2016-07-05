package player;

import enemies.Enemy;
import enemies.EnemyB;
import enemies.EnemyD;
import kala.behaviors.collision.basic.Collider;
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.math.Collision;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kha.FastFloat;
import states.PlayState;

class Web extends Sprite {

	public static var myGroup:Group<Web> = new Group<Web>(false, function() return new Web());
	
	public static inline function shoot(x:FastFloat):Void {
		var web = myGroup.createAlive();
		web.spreading = false;
		web.animation.play("shooting");
		web.scale.set(0, 0, web.width / 2, web.height);
		web.position.ox = web.width / 2;
		web.x = x + 10;
		web.opacity = 1;
		web.mask.active = false;
		
		#if (cap_30 && !debug)
		web.tween.get()
			.tween(web.scale, { x: 1.2, y: 1 }, 8, Ease.quartInOut)
			.call(function(_) {
				web.spreading = true;
				web.animation.play("spreading");
				web.position.ox = web.width / 2;
				web.scale.set(0, 0, web.width / 2 - 15, web.height / 2);
				web.mask.active = true;
			})
			.tween(web.scale, { x: Random.roll(), y: 1 }, 15, Ease.elasticOut)
			.wait(UpgradeData.webTime)
			.tween(web, { opacity: 0 }, 60, Ease.sineInOut)
			.call(function(_) web.kill())
		.start();
		#else
		web.tween.get()
			.tween(web.scale, { x: 1.2, y: 1 }, 16, Ease.quartInOut)
			.call(function(_) {
				web.spreading = true;
				web.animation.play("spreading");
				web.position.ox = web.width / 2;
				web.scale.set(0, 0, web.width / 2 - 15, web.height / 2);
				web.mask.active = true;
			})
			.tween(web.scale, { x: Random.roll(), y: 1 }, 30, Ease.elasticOut)
			.wait(UpgradeData.webTime * 2)
			.tween(web, { opacity: 0 }, 120, Ease.sineInOut)
			.call(function(_) web.kill())
		.start();
		#end
	}

	//
	
	var collider:Collider;
	var mask:CollisionCircle;
	var tween:Tween;
	var spreading:Bool;
	
	public function new() {
		super();
		
		loadSpriteData(R.playerWebShooting, "shooting");
		loadSpriteData(R.playerWebSpreading, "spreading");
		
		tween = new Tween(this);

		collider = new Collider(this);
		mask = collider.addCircle(width / 2 - 10, height / 2 - 30, 140);
	}
	
	override public function update(elapsed:FastFloat):Void {
		if (spreading && opacity > 0.15) {
			for (enemy in PlayState.instance.enemyGroup) checkEnemy(enemy);
			for (enemy in EnemyB.childGroup) checkEnemy(enemy);
			for (enemy in EnemyD.childGroup) checkEnemy(enemy);
		}
	}
	
	inline function checkEnemy(enemy:Enemy):Void {
		if (!enemy.sprite.alive || !enemy.collider.available) return;
		if (mask.testCircle(enemy.mask)) {
			enemy.timeScale = 1.3 - opacity;
		}
	}
	
}