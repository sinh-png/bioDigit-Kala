package states;

import enemies.*;
import kala.behaviors.display.Clip;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.Kala;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.BasicButtonSprite;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kala.objects.text.Text;
import kala.objects.text.TextAlign;
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
	
	public var backButton:BasicButtonSprite;
	
	public var playerGroup:Group<Sprite>;
	public var player:Player;
	
	public var boss:Boss;
	public var enemyGroup:Group<Enemy>;
	
	public var uiGroup:GenericGroup;
	public var livesIcon:Sprite;
	public var livesText:BasicText;
	public var gemIcon:Sprite;
	public var gemText:BasicText;
	public var chargingProcessText:BasicText;
	
	public var tutorialState:Int = -1; // -1 - tutorial off
	public var tutorialText:Text;
	public var tutorialFinger:Sprite;
	public var tutorialFingerTween:Tween;

	public var closing:Bool;
	
	public var maxOnScreenEnemy:FastFloat;
	public var onScreenEnemyCount:Int;
	
	public var framesLeftUntilBoss:Int;
	public var killsLeftUntilBoss:Int;
	
	public function new() {
		super();
		
		onFirstFrame.notify(onStartHandle);
		
		antialiasing = true;
		
		tween = new Tween(this);
		
		background = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("background/normal.jpg"), R.images.sprite_sheet_1);
		add(background);
		
		boss = new Boss();
		boss.sleep();
		add(boss);
		
		add(Web.group);
		
		enemyGroup = new Group<Enemy>();
		enemyGroup.data = "enemies";
		add(enemyGroup);
		
		add(Gem.group);
		
		add(Minion.group);
		add(Bullet.minionGroup);
		
		playerGroup = new Group<Sprite>();
		add(playerGroup);

		player = Player.instance = new Player();
		playerGroup.add(player);
		playerGroup.add(player.energyBall);
		
		add(Bullet.mainGroup);
		add(Lightning.group);
		
		add(EnemyB.childGroup);
		add(EnemyD.childGroup);
		
		add(boss.leftThrone);
		add(boss.rightThrone);
		add(Boss.lightningGroup);
		
		foreground = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("background/foreground.png"), R.images.sprite_sheet_1);
		foreground.y = G.height - foreground.height;
		add(foreground);
		
		uiGroup = player.playStateUIGroup = new GenericGroup(true);
		add(uiGroup);
		
		livesIcon = new Sprite().loadSpriteData(R.sheets.sprite_sheet_2.get("heart.png"), R.images.sprite_sheet_2);
		livesIcon.y = G.height - livesIcon.height - 4;
		uiGroup.add(livesIcon);
		
		livesText = new BasicText("X 3", 30);
		livesText.x = livesIcon.x + livesIcon.width + 2;
		livesText.y = livesIcon.y + 7;
		uiGroup.add(livesText);
		
		gemIcon = new Sprite().loadSpriteData(R.sheets.sprite_sheet_2.get("crystal_icon.png"), R.images.sprite_sheet_2);
		gemIcon.x = 150;
		gemIcon.y = livesIcon.y - 16;
		uiGroup.add(gemIcon);
		
		gemText = Gem.gemText = new BasicText("X 3", 30);
		gemText.x = gemIcon.x + gemIcon.width + 2;
		gemText.y = livesText.y;
		uiGroup.add(gemText);
		
		chargingProcessText = player.chargingProcessText = new BasicText(30);
		chargingProcessText.y = 460;
		add(chargingProcessText);
		
		tutorialText = new Text(24, G.width);
		tutorialText.align = TextAlign.CENTER;
		tutorialText.padding.set(30, 10);
		tutorialText.bgColor = 0xff000000;
		tutorialText.bgOpacity = 0.5;
		tutorialText.y = 90;
		tutorialText.onPostUpdate.notify(tutorialUpdate);
		add(tutorialText);
		
		tutorialFinger = new Sprite();
		tutorialFinger.loadSpriteData(R.sheets.sprite_sheet_2.get("fingerprint.png", R.images.sprite_sheet_2));
		tutorialFinger.y = 300;
		add(tutorialFinger);
		
		tutorialFingerTween = new Tween(tutorialFinger);
		tutorialFingerTween.get()
			.startLoop()
				#if (cap_30 && !debug)
				.tween(tutorialFinger, { opacity: 0 }, 45, Ease.sineInOut)
				.tween(tutorialFinger, { opacity: 1 }, 45, Ease.sineInOut)
				.wait(60)
				#else
				.tween(tutorialFinger, { opacity: 0 }, 90, Ease.sineInOut)
				.tween(tutorialFinger, { opacity: 1 }, 90, Ease.sineInOut)
				.wait(120)
				#end
			.endLoop()
		.start();
		
		backButton = new BasicButtonSprite();
		backButton.loadSpriteData(R.sheets.sprite_sheet_2.get("back_button.png", R.images.sprite_sheet_2));
		backButton.x = G.width - backButton.width - 5;
		backButton.y = 7;
		backButton.addObjectRectMask();
		backButton.onOver.notify(function(_) backButton.opacity = 1);
		backButton.onOut.notify(function(_) backButton.opacity = 0.6);
		backButton.onPush.notify(function(_, _) goTo(UpgradeState.instance));
		backButton.kill();
		add(backButton);
		
		blurOverlay = new Sprite(R.images.background_blur);
		add(blurOverlay);
		
		//
		
		Gem.playerPos = player.position;
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);
		
		if (tutorialState == -1) {
			if (framesLeftUntilBoss > 0 || killsLeftUntilBoss > 0) {
				if (boss.alive) {
					if (maxOnScreenEnemy - onScreenEnemyCount >= 3) {
						spawnRandomEnemy();
					}
				} else {
					framesLeftUntilBoss--;
					if (maxOnScreenEnemy - onScreenEnemyCount >= 1) {
						spawnRandomEnemy();
					}
				}
			} else {
				if (maxOnScreenEnemy - onScreenEnemyCount >= 2) {
					resetBossRevivingCondition();
					boss.revive();
				}
			}
		}
	}
	
	public function goTo(state:GenericGroup):Void {
		closing = true;
		
		tween.get()
			.tween(blurOverlay, { opacity: 1 }, 36, Ease.sineIn)
			.call(function(_) {
				
				for (enemy in enemyGroup) {
					if (enemy.alive) enemy.put();
				}
				for (enemy in EnemyB.childGroup) {
					if (enemy.alive) enemy.put();
				}
				for (enemy in EnemyD.childGroup) {
					if (enemy.alive) enemy.put();
				}
				boss.sleep();
				Boss.lightningGroup.killAll();
				Gem.group.killAll();
				Minion.group.killAll();
				Bullet.mainGroup.killAll();
				Bullet.minionGroup.killAll();
				Lightning.group.killAll();
				Web.group.killAll();
				
				G.switchState(state);
			})
		.start();
		
		Save.save();
	}
	
	function onStartHandle(_):Void {
		#if (cap_30 && !debug)
		Kala.updateRate = 30;
		#else
		Kala.updateRate = 60;
		#end
		closing = false;
		active = true;
		maxOnScreenEnemy = 2;
		onScreenEnemyCount = 0;
		resetBossRevivingCondition();
		
		if (G.tutorialPassed) {
			backButton.revive();
			backButton.opacity = 0.6;
		} else {
			backButton.kill();
		}
		
		if (tutorialState == -1) {
			tutorialText.kill();
			tutorialFinger.kill();
		} else {
			tutorialText.revive();
			tutorialText.text = G.touchControl ?
					"Touch on the left side of the screen to move left." :
					"Press [LEFT ARROW] to move left.";
			if (G.touchControl) {
				tutorialFinger.revive();
				tutorialFinger.opacity = 1;
				tutorialFinger.flipX = false;
				tutorialFinger.x = 0;
			} else {
				tutorialFinger.kill();
			}
		}
		
		//boss.revive();
		//EnemyA.create(3, -140, 250);
		//EnemyC.create(3, -120, 50);
		//EnemyB.create(300, 100);
		//EnemyD.create(160, -110);

		uiGroup.opacity = 1;
		gemText.text = "X " + UpgradeData.money;
		player.onStart();

		blurOverlay.opacity = 1;
		tween.get()
			.tween(blurOverlay, { opacity: 0 }, 36, Ease.sineOut)
		.start();
	}
	
	function tutorialUpdate(_, _):Void {
		switch(tutorialState) {
			case -1:
			case 0: 
				if (player.x < 125) {
					tutorialState = 1;
					tutorialText.text = "Now try to go back to the center of the screen.";
					tutorialFinger.flipX = true;
					tutorialFinger.x = G.width - tutorialFinger.width;
				}
				
			case 1:
				
				if (player.x > G.width / 2 - 10) {
					tutorialState = 2;
					tutorialText.text = G.touchControl ?
					"Charge your enegry by touching on both sides of the screen at the same time." :
					"Charge your enegry by pressing\n[LEFR ARROW] & [RIGHT ARROW] at the same time.";
					tutorialFinger.kill();
				}
				
			case 2:
				if (player.charging) {
					tutorialState = 3;
					tutorialText.text = G.touchControl ?
					"Charge your enegry by touching on both sides of the screen at the same time." :
					"Charge your enegry by pressing\n[LEFR ARROW] & [RIGHT ARROW] at the same time.";
				}
				
			case 3:
				if (player.charging) {
					tutorialState = 4;
					tutorialText.text = "Depend on how much energy charged, you can shoot web or lightning.";
				}
				
			case 4:
				if (!player.charging) {
					tutorialState = 5;
					player.webShot = 0;
					tutorialText.text = "Webs will slow your enemies. Try shooting some.";
				}
			
			case 5:
				if (enemyGroup.countAlive() < 6) {
					EnemyC.create(Random.int(0, 2), Random.int(45, G.width - 45), -90);
				}
				
				if (player.webShot > 2) {
					tutorialState = 6;
					tutorialText.text = "You will shoot lightning instead of web if enough energy is charged. Lightning can deal large amount of damage to multiple enemies at once. Try using it to destroy all these flying creatures.";
					while (enemyGroup.countAlive() < 12) {
						EnemyC.create(Random.int(1, 2), Random.int(45, G.width - 45), -90);
					}
				}
				
			case 6:
				if (enemyGroup.countAlive() < 7) {
					tutorialState = 7;
					tutorialText.text = "Enemies will drop crystals when destroyed. Collect these to upgrade your ability.";
				}

			case 7:
				if (enemyGroup.countAlive() == 0) {
					tutorialState = 8;
					tutorialText.text = "Good job! You can go back to this tutorial by pressing the HELP button on main menu. Good luck and have fun!";
				}
		}
		
		if (tutorialState > 7) {
			tutorialState++;
			#if (cap_30 && !debug)
			if (tutorialState == 150) {
			#else
			if (tutorialState == 300) {
			#end
				tutorialState = 999;
				G.tutorialPassed = true;
				Save.save();
				goTo(UpgradeState.instance);
			}
		}
	}
	
	inline function spawnRandomEnemy():Void {
		switch(Random.int(0, 3)) {
			case 0: EnemyA.createRandomPos(Random.int(1, 3));
			case 1: EnemyB.createRandomPos();
			case 2: EnemyC.createRandomPos(Random.int(1, 3));
			case 3: EnemyD.createRandomPos();
		}
	}
	
	inline function resetBossRevivingCondition():Void {
		#if (cap_30 && !debug)
		framesLeftUntilBoss = 2000;
		#else
		framesLeftUntilBoss = 4000;
		#end
		killsLeftUntilBoss = 12;
	}
	
}