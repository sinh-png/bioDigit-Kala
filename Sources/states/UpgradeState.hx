package states;

import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.Kala;
import kala.objects.group.Group.GenericGroup;
import kala.objects.sprite.BaseButtonSprite;
import kala.objects.sprite.ButtonSprite;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kala.objects.text.Text;
import kala.objects.text.TextAlign;
import kha.FastFloat;
import ui.Button;

class UpgradeState extends GenericGroup {

	public static var instance:UpgradeState;
	
	//
	
	public var background:Sprite;
	
	public var currentItem(default, set):Int;
	public var itemButtons:Array<ItemButton> = new Array<ItemButton>();
	public var upgradeButton:Button;
	public var upgradeGroup:GenericGroup;
	public var startButton:Button;
	public var backButton:Button;
	public var gemIcon:Sprite;
	public var moneyText:BasicText;
	public var descriptionBG:Sprite;
	public var descriptionText:Text;
	public var costText:BasicText;
	public var levelText:BasicText;
	
	public var tween:Tween;
	
	public function new() {
		super();
		
		antialiasing = true;

		background = new Sprite(R.images.background_blur);
		add(background);
		
		upgradeGroup = new GenericGroup(true);
		upgradeGroup.x = G.width;
		add(upgradeGroup);
		
		gemIcon = new Sprite().loadSpriteData(R.sheets.sprite_sheet_2.get("crystal_icon.png"), R.images.sprite_sheet_2);
		gemIcon.x = 50;
		gemIcon.y = -5;
		upgradeGroup.add(gemIcon);
		
		moneyText = new BasicText(30);
		moneyText.x = gemIcon.x + gemIcon.width - 10;
		moneyText.y = gemIcon.y + (gemIcon.height - moneyText.height) / 2;
		upgradeGroup.add(moneyText);
		
		startButton = new Button("startButton", R.upgradeStartButton);
		startButton.x = 550;
		startButton.onOver.notify(onButtonHoverHandle);
		startButton.onOut.notify(onButtonOutHandle);
		startButton.onPush.notify(onButtonReleaseHandle);
		upgradeGroup.add(startButton);
		
		backButton = new Button("backButton", R.upgradeBackButton);
		backButton.x = startButton.x - backButton.width - 10;
		backButton.scale.ox = backButton.width;
		backButton.onOver.notify(onButtonHoverHandle);
		backButton.onOut.notify(onButtonOutHandle);
		backButton.onPush.notify(onButtonReleaseHandle);
		upgradeGroup.add(backButton);
		
		var itemX:Int = 10;
		var itemY:Int = 200;
		var space:Int = cast (G.width - 20 - 141 * 5) / 5;
		for (i in 0...10) {
			itemButtons[i] = new ItemButton(i);
			itemButtons[i].x = itemX;
			itemButtons[i].y = itemY;
			
			upgradeGroup.add(itemButtons[i]);
			
			itemX += 141 + space;
			
			if (i == 4) {
				itemY += 142 + space;
				itemX = 10;
			}
			
			itemButtons[i].data = i;
		}
		
		descriptionBG = new Sprite().loadSpriteData(R.upgradeDescBG);
		descriptionBG.setXY(
			(G.width - descriptionBG.width) / 2,
			startButton.height  + (itemButtons[0].y - startButton.height - descriptionBG.height) / 2 + 5
		);
		upgradeGroup.add(descriptionBG);
		
		upgradeButton = new Button("upgradeButton", R.upgradeButton);
		var padding = (descriptionBG.height - upgradeButton.height) / 2;
		upgradeButton.setXY(descriptionBG.x + padding, descriptionBG.y + padding);
		upgradeButton.onOver.notify(onButtonHoverHandle);
		upgradeButton.onOut.notify(onButtonOutHandle);
		upgradeButton.onPush.notify(onButtonReleaseHandle);
		upgradeGroup.add(upgradeButton);
		
		costText = new BasicText();
		costText.text = "Cost: 1000";
		costText.x = upgradeButton.x + upgradeButton.width + 20;
		costText.y = descriptionBG.y + 5;
		upgradeGroup.add(costText);
		
		levelText = new BasicText();
		levelText.y = costText.y;
		levelText.onTextChange.notify(function(_, _) {
			levelText.x = descriptionBG.x + descriptionBG.width - levelText.width - 20; 
		});
		levelText.text = "Level: 5/10";
		upgradeGroup.add(levelText);
		
		var xx = upgradeButton.x + upgradeButton.width;
		descriptionText = new Text(30, cast descriptionBG.x + descriptionBG.width - xx, TextAlign.CENTER);
		descriptionText.padding.x = 20;
		descriptionText.setXY(xx, costText.y + 40);
		upgradeGroup.add(descriptionText);
		
		tween = new Tween(this);
		
		onFirstFrame.notify(onStartHandle);
	}
	
	function onStartHandle(_):Void {
		Kala.updateRate = 60;
		
		backButton.scale.setXY(1, 1);
		startButton.scale.setXY(1, 1);
		
		for (item in itemButtons) {
			item.scale.setXY(0.8, 0.8);
			item.selected = false;
			item.onOutHandle(null);
		}
		
		currentItem = 0;
		updateItems();
		upgradeButton.opacity = 0.75;
		itemButtons[0].scale.setXY(1, 1);
		itemButtons[0].onReleaseHandle(null, 0);
		
		upgradeGroup.active = false;
		tween.get()
			.tween(upgradeGroup, { x: 0 }, 80, Ease.bounceOut)
			.call(function(_) upgradeGroup.active = true)
		.start();
		
		G.audioButton.hide();
	}
	
	function onButtonHoverHandle(button:BaseButtonSprite):Void {
		if (button.data == "upgradeButton") button.opacity = itemButtons[currentItem].upgradable ? 1 : 0.75;
		else button.scale.setXY(1.2, 1.2);
	}
	
	function onButtonOutHandle(button:BaseButtonSprite):Void {
		if (button.data == "upgradeButton") button.opacity = 0.75;
		else button.scale.setXY(1, 1);
	}
	
	function onButtonReleaseHandle(button:BaseButtonSprite, _):Void {
		switch(button.data) {
			case "upgradeButton": upgradeItem();
			case "startButton": startGame();
			case "backButton": backToMainMenu();
		}
	}
	
	function upgradeItem():Void {
		G.sfxGroup.play(R.sounds.upgrade);
		UpgradeData.upgrade(currentItem);
		currentItem = currentItem; // Update cost & level texts.
		updateItems();
	}
	
	function updateItems():Void {
		for (i in 0...10) {
			var btn = itemButtons[i];
			if (UpgradeData.isUpgradable(i)) {
				btn.upgradable = true;
			} else {
				btn.upgradable = false;
				btn.opacity = btn.selected ? 0.75 : 0.5;
			}
		}
		
		upgradeButton.active = UpgradeData.isUpgradable(currentItem);
		upgradeButton.opacity = upgradeButton.active ? 1 : 0.75;
	}
	
	function startGame():Void {
		Save.save();
		UpgradeData.update();
		G.audioButton.show();
		
		upgradeGroup.active = false;
		tween.get()
			.tween(upgradeGroup, { x: -G.width }, 80, Ease.backIn)
			.call(function(_) G.switchState(PlayState.instance))
		.start();
		
		if (!G.tutorialPassed) PlayState.instance.tutorialState = 0;
		else PlayState.instance.tutorialState = -1;
	}
	
	function backToMainMenu():Void {
		Save.save();
		UpgradeData.update();
		
		upgradeGroup.active = false;
		tween.get()
			.tween(upgradeGroup, { x: G.width }, 80, Ease.backIn)
			.call(function(_) G.switchState(MainMenuState.instance))
		.start();
	}
	
	function set_currentItem(value:Int):Int {
		if (UpgradeData.itemLevel[value] < UpgradeData.itemMaxLevel[value]) {
			costText.text = "Cost: " + UpgradeData.getCost(value);
			levelText.text = "Level: " + UpgradeData.itemLevel[value] + "/" + UpgradeData.itemMaxLevel[value];
		} else {
			costText.text = "";
			levelText.text = "Level: MAX";
		}

		switch(value) {
			case 0: descriptionText.text = "Increases your starting lives.";
			case 1: descriptionText.text = "Increases your fire rate and number of bullets per shot.";
			case 2: descriptionText.text = "Increases the duration of your webs.";
			case 3: descriptionText.text = "Increases the power of lightning.";
			case 4: descriptionText.text = "Increases the quantity of crystals dropped from enemies.";
			case 5: descriptionText.text = "Increases the spawn rate of your children.";
			case 6: descriptionText.text = "Helps your children withstand more attack";
			case 7: descriptionText.text = "Increases the fire rate of your children.";
			case 8: descriptionText.text = "Increases chance of your children casting lightning.";
			case 9: descriptionText.text = "Increases the radius to attract crystals.";
		}
		
		return currentItem = value;
	}
	
}

class ItemButton extends Button {
	
	public var selected:Bool = false;
	public var upgradable(default, set):Bool = false;
	
	public function new(id:Int) {
		super(id, Reflect.getProperty(R, "upgradeItem" + id));
		
		scale.set(0.8, 0.8, width / 2, height / 2);
		opacity = 0.75;
		
		onOver.notify(onHoverHandle);
		onOut.notify(onOutHandle);
		onPush.notify(onReleaseHandle);
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);
		
		if (selected) {
			if (scale.x < 1) scale.x = scale.y += 0.025;
		} else {
			if (scale.x > 0.8) scale.x = scale.y -= 0.025;
		}
	}
	
	public function onReleaseHandle(_, _):Void {
		UpgradeState.instance.currentItem = data;
		UpgradeState.instance.upgradeButton.active = upgradable;
		for (item in UpgradeState.instance.itemButtons) item.selected = false;
		selected = true;
	}
	
	public function onHoverHandle(_):Void {
		opacity = 1;
	}
	
	public function onOutHandle(_):Void {
		opacity = 0.75;
	}
	
	function set_upgradable(value:Bool):Bool {
		if (value) color = 0xffffffff;
		else color = 0xffff2222;
		return upgradable = value;
	}
	
}