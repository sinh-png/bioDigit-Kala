package states;

import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.objects.group.Group.GenericGroup;
import kala.objects.sprite.PushSprite;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kha.FastFloat;
import ui.Button;

class UpgradeState extends GenericGroup {

	public static var instance:UpgradeState;
	
	//
	
	public var currentItem:Int;
	public var itemButtons:Array<ItemButton> = new Array<ItemButton>();
	
	var background:Sprite;
	
	var upgradeGroup:GenericGroup;
	var startButton:Button;
	var backButton:Button;
	var upgradeButton:Button;
	var descriptionBG:Sprite;
	var gemIcon:Sprite;
	var moneyText:BasicText;
	
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
		if (button.data == "upgradeButton") button.opacity = 0.6;
		else button.scale.setXY(1, 1);
	}
	
	function onButtonReleaseHandle(button:PushSprite, _):Void {
		switch(button.data) {
			case "upgradeButton": upgradeItem(0);
			case "startButton": startGame();
			case "backButton": backToMainMenu();
		}
	}
	
	function upgradeItem(id:Int):Void {
		
	}
	
	function startGame():Void {
		upgradeGroup.active = false;
		tween.get()
			.tween(upgradeGroup, { x: G.width }, 80, Ease.backIn)
			.call(function(_) G.switchState(PlayState.instance))
		.start();
	}
	
	function backToMainMenu():Void {
		upgradeGroup.active = false;
		tween.get()
			.tween(upgradeGroup, { x: -G.width }, 80, Ease.backIn)
			.call(function(_) G.switchState(MainMenuState.instance))
		.start();
	}
	
}

class ItemButton extends Button {
	
	public var selected:Bool = false;
	
	public function new(id:Int) {
		super(id, Reflect.getProperty(R, "upgradeItem" + id));
		
		scale.set(0.8, 0.8, width / 2, height / 2);
		opacity = 0.5;
		
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
		opacity = 0.7;
	}
	
	function onOutHandle(_):Void {
		opacity = 0.5;
	}
	
	function onReleaseHandle(_, _):Void {
		UpgradeState.instance.currentItem = data;
		for (item in UpgradeState.instance.itemButtons) item.selected = false;
		selected = true;
	}
	
}