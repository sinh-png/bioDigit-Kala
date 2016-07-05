package states;

import enemies.*;
import kala.behaviors.graphics.Clip;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.Kala;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kha.FastFloat;
import player.Bullet;
import player.Lightning;
import player.Minion;
import player.Player;
import player.Web;

class PlayState extends GenericGroup {

	public static var instance:PlayState;
	
	//
	
	public var tween:Tween;
	
	public var background:Sprite;
	public var foreground:Sprite;
	public var blurOverlay:Sprite;
	
	public var playerGroup:Group<Sprite>;
	public var player:Player;
	
	public var boss:Boss;
	public var enemyGroup:Group<Enemy>;
	
	public var chargingProcessText:BasicText;

	public function new() {
		super();
		
		onFirstFrame.notify(onStart);
		
		antialiasing = true;
		
		tween = new Tween(this);
		
		background = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("background/normal.jpg"), R.images.sprite_sheet_1);
		add(background);
		
		boss = new Boss();
		boss.alive = false;
		add(boss);
		
		add(Web.myGroup);
		
		enemyGroup = new Group<Enemy>();
		enemyGroup.data = "enemies";
		add(enemyGroup);
		
		add(EnemyB.childGroup);
		add(EnemyD.childGroup);
		
		add(Gem.myGroup);
		
		add(Minion.myGroup);
		add(Bullet.minionGroup);
		
		playerGroup = new Group<Sprite>();
		add(playerGroup);

		player = Player.instance = new Player();
		playerGroup.add(player);
		playerGroup.add(player.energyBall);
		
		add(boss.leftThrone);
		add(boss.rightThrone);
		add(Boss.lightningGroup);
		
		add(Bullet.mainGroup);
		add(Lightning.myGroup);
		
		foreground = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("background/foreground.png"), R.images.sprite_sheet_1);
		foreground.y = G.height - foreground.height;
		add(foreground);
		
		chargingProcessText = player.chargingProcessText = new BasicText(R.fonts.font_1, 30);
		chargingProcessText.y = 460;
		//add(chargingProcessText);
		
		blurOverlay = new Sprite(R.images.background_blur);
		add(blurOverlay);

		//
		
		Gem.playerPos = player.position;
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);
	}
	
	function onStart(_):Void {
		#if (cap_30 && !debug)
		Kala.updateRate = 30;
		#else
		Kala.updateRate = 60;
		#end
		
		boss.revive();
		/*EnemyA.create(3, 0, 250);
		EnemyC.create(3, 200, 50);
		EnemyC.create(2, 500, 150);
		EnemyB.create(600, 180);
		EnemyD.create(400, 160);*/
		
		player.restart();
		
		blurOverlay.opacity = 1;
		tween.get()
			.tween(blurOverlay, { opacity: 0 }, 36, Ease.sineOut)
		.start();
	}
	
}