package player;

import enemies.EnemyB;
import enemies.EnemyD;
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kha.FastFloat;
import states.PlayState;

class Lightning extends Sprite {

	public static var myGroup:Group<Lightning> = new Group<Lightning>(false, function() return new Lightning());
	
	public static inline function shoot(x:FastFloat):Void {
		var lightning = myGroup.createAlive();
		
		lightning.x = x;
		lightning.scale.x = 0;
		
		#if (cap_30 && !debug)
		lightning.tween.get()
			.tween(lightning.scale, { x: 1 * Random.roll() }, 15, Ease.elasticOut)
			.wait(10)
			.tween(lightning.scale, { x: 0 }, 30, Ease.elasticInOut)
			.call(function(_) lightning.kill())
		.start();
		#else
		lightning.tween.get()
			.tween(lightning.scale, { x: 1 * Random.roll() }, 30, Ease.elasticOut)
			.wait(20)
			.tween(lightning.scale, { x: 0 }, 30, Ease.elasticInOut)
			.call(function(_) lightning.kill())
		.start();
		#end
	}
	
	//
	
	var tween:Tween;
	var halfWidth:FastFloat;
	
	public function new() {
		super();
		
		#if (cap_30 && !debug)
		loadSpriteData(R.playerLightning, 2).animation.play();
		#else
		loadSpriteData(R.playerLightning, 4).animation.play();
		#end
		
		halfWidth = position.ox = scale.ox = width / 2;
		position.oy = 10;
		
		tween = new Tween(this);
	}
	
	override public function update(elapsed:FastFloat):Void {
		var absScaleX = Math.abs(scale.x);
		var scaledHalfHitWidth = halfWidth * absScaleX * 0.6;
		var leftX = x - scaledHalfHitWidth;
		var rightX = x + scaledHalfHitWidth;
		
		var eneMask:CollisionCircle;

		for (enemy in PlayState.instance.enemyGroup) {
			if (!enemy.alive || !enemy.collider.available) continue;
			
			eneMask = enemy.mask;
			
			if (
				eneMask.absX + eneMask.radius > leftX &&
				eneMask.absX - eneMask.radius < rightX
			) {
				enemy.hp -= 1 * absScaleX;
			}
		}
		
		for (enemy in EnemyB.childGroup) {
			if (!enemy.alive || !enemy.collider.available) continue;
			
			eneMask = enemy.mask;
			
			if (
				eneMask.absX + eneMask.radius > leftX &&
				eneMask.absX - eneMask.radius < rightX
			) {
				enemy.hp -= 1 * absScaleX;
			}
		}
		
		for (enemy in EnemyD.childGroup) {
			if (!enemy.sprite.alive || !enemy.collider.available) continue;
			
			eneMask = enemy.mask;
			
			if (
				eneMask.absX + eneMask.radius > leftX &&
				eneMask.absX - eneMask.radius < rightX
			) {
				enemy.hp -= 1 * absScaleX;
			}
		}
		
		if (PlayState.instance.boss.alive) PlayState.instance.boss.hp -= 1 * absScaleX;
	}
	
}