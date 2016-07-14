package states;

import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.objects.group.Group.GenericGroup;
import kala.objects.sprite.PushSprite;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kala.objects.text.Text;
import kala.objects.text.TextAlign;
import kha.FastFloat;
import ui.Button;

class UpgradeState extends GenericGroup {

	public static var instance:UpgradeState;
	
	//
	
	public var currentItem(default, set):Int;
	public var itemButtons:Array<ItemButton> = new Array<ItemButton>();
	public var upgradeButton:Button;
	
	var background:Sprite;
	
	var upgradeGroup:GenericGroup;
	var startButton:Button;
	var backButton:Button;
	var gemIcon:Sprite;
	var moneyText:BasicText;
	var descriptionBG:Sprite;
	var descriptionText:Text;
	var costText:BasicText;
	var levelText:BasicText;
	
	var tween:Tween;
	
	public function new() {
		super();
		
		antialiasing = true;

		background = new Sprite(R.images.background_blur);
		add(background);
		
		upgradeGroup = new GenericGroup(true);
		upgradeGroup.x = G.width;
		add(upgradeGroup);
		
		startButton = new Button("startButton", R.upgradeStartButton);
		startButton.x = 550;
		startButton.onOver.notify(onButtonHoverHandle);
		startButton.onOut.notify(onButtonOutHandle);
		startButton.onRelease.notify(onButtonReleaseHandle);
		upgradeGroup.add(startButton);
		
		backButton = new Button("backButton", R.upgradeBackButton);
		backButton.x = startButton.x - backButton.width - 10;
		backButton.scale.ox = backButton.width;
		backButton.onOver.notify(onButtonHoverHandle);
		backButton.onOut.notify(onButtonOutHandle);
		backButton.onRelease.notify(onButtonReleaseHandle);
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
		upgradeButton.onRelease.notify(onButtonReleaseHandle);
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
		
		descriptionText = new Text("TO GET HEIGHT", TextAlign.CENTER);
		
		updateItems();
		
		tween = new Tween(this);
		
		onFirstFrame.notify(onStartHandle);
	}
	
	function onStartHandle(_):Void {
		upgradeGroup.active = false;
		tween.get()
			.tween(upgradeGroup, { x: 0 }, 80, Ease.bounceOut)
			.call(function(_) upgradeGroup.active = true)
		.start();
	}
	
	function onButtonHoverHandle(button:PushSprite):Void {
		if (button.data == "upgradeButton") button.opacity = 1;
		else button.scale.setXY(1.2, 1.2);
	}
	
	function onButtonOutHandle(button:PushSprite):Void {
		if (button.data == "upgradeButton") button.opacity = 0.75;
		else button.scale.setXY(1, 1);
	}
	
	function onButtonReleaseHandle(button:PushSprite, _):Void {
		switch(button.data) {
			case "upgradeButton": upgradeItem();
			case "startButton": startGame();
			case "backButton": backToMainMenu();
		}
	}
	
	function upgradeItem():Void {
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
		UpgradeData.update();
		
		upgradeGroup.active = false;
		tween.get()
			.tween(upgradeGroup, { x: -G.width }, 80, Ease.backIn)
			.call(function(_) G.switchState(PlayState.instance))
		.start();
	}
	
	function backToMainMenu():Void {
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
		
		return currentItem = value;
	}
	
}

class ItemButton extends Button {
	
	public var selected(default, set):Bool = false;
	public var upgradable:Bool = false;
	
	public function new(id:Int) {
		super(id, Reflect.getProperty(R, "upgradeItem" + id));
		
		scale.set(0.8, 0.8, width / 2, height / 2);
		opacity = 0.75;
		
		onOver.notify(onHoverHandle);
		onOut.notify(onOutHandle);
		onRelease.notify(onReleaseHandle);
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);
		
		if (selected) {
			if (scale.x < 1) scale.x = scale.y += 0.025;
		} else {
			if (scale.x > 0.8) scale.x = scale.y -= 0.025;
		}
	}
	
	function onHoverHandle(_):Void {
		if (!selected) opacity = upgradable ? 1 : 0.75;
	}
	
	function onOutHandle(_):Void {
		if (!selected) opacity = upgradable ? 0.75 : 0.5;
	}
	
	function onReleaseHandle(_, _):Void {
		UpgradeState.instance.currentItem = data;
		UpgradeState.instance.upgradeButton.active = upgradable;
		for (item in UpgradeState.instance.itemButtons) item.selected = false;
		selected = true;
	}
	
	function set_selected(value:Bool):Bool {
		if (value) opacity = upgradable ? 1 : 0.75;
		else opacity = upgradable ? 0.75 : 0.5;
		return selected = value;
	}
	
}