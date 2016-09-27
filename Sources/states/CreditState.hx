package states;

import kala.behaviors.input.BasicButtonInteraction;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.Kala;
import kala.math.Random;
import kala.math.Rect;
import kala.math.Vec2;
import kala.objects.group.Group.GenericGroup;
import kala.objects.Object;
import kala.objects.sprite.BasicButtonSprite;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kala.util.types.Pair;
import kha.FastFloat;

class CreditState extends GenericGroup {
	
	public static var instance:CreditState;
	
	public var background:Sprite;
	public var backButton:BasicButtonSprite;
	public var animatedTexts:Array<AnimatedText>;
	public var licenseText1:BasicText;
	public var licenseText2:BasicText;

	var tween:Tween;
	
	public function new() {
		super();
		
		Kala.world.antialiasing = true;
		
		background = new Sprite(R.images.background_blur);
		add(background);
		
		onFirstFrame.notify(onStartHandle);
		
		backButton = new BasicButtonSprite();
		backButton.loadSpriteData(R.sheets.sprite_sheet_2.get("back_button.png", R.images.sprite_sheet_2));
		backButton.x = G.width;
		backButton.y = 7;
		backButton.opacity = 0.6;
		backButton.active = false;
		backButton.addObjectRectMask();
		backButton.onOver.notify(function(_) backButton.opacity = 1);
		backButton.onOut.notify(function(_) backButton.opacity = 0.6);
		backButton.onPush.notify(function(_, _) close());
		add(backButton);
		
		animatedTexts = new Array<AnimatedText>();
		
		var letterWidth = R.fonts.SpaceMono_Bold.width(40, "a");
		var letterWidthPlusSpacing = letterWidth + AnimatedText.letterSpacing;
		var lineSpacing = 30;
		var text:String;
		var x:FastFloat;
		var y:FastFloat;
		
		animatedTexts.push(new AnimatedText(40, 80, "MUSIC:"));
		
		text = "Dissonant Waltz";
		x = animatedTexts[0].xx + 40;
		y = animatedTexts[0].yy + lineSpacing;
		animatedTexts.push(new AnimatedText(
			x, y, text,
			new Pair<Int, Int>(0xfff5deb3, 0xffff0000), new Pair<Int, Int>(0, text.length),
			new Rect(
				x - 10, y - 14,
				letterWidthPlusSpacing * text.length - AnimatedText.letterSpacing, 30
			),
			"http://opengameart.org/content/dissonant-waltz"
		));
		
		text = "by Yubatake";
		x = animatedTexts[1].xx + 40;
		y = animatedTexts[1].yy + lineSpacing;
		animatedTexts.push(new AnimatedText(
			x, y, text,
			new Pair<Int, Int>(0xff7fffd4, 0xffff7f50), new Pair<Int, Int>(3, text.length),
			new Rect(
				x - 10 + (letterWidth + 3) * 3, y - 14,
				letterWidthPlusSpacing * (text.length - 3) - AnimatedText.letterSpacing, 30
			),
			"http://opengameart.org/users/yubatake"
		));
		
		animatedTexts.push(new AnimatedText(340, animatedTexts[2].yy + 50, "SOUND EFFECTS BY:", -1));
		
		text = "Blender Foundation";
		x = animatedTexts[3].xx - 10;
		y = animatedTexts[3].yy + lineSpacing;
		animatedTexts.push(new AnimatedText(
			x, y, text, -1,
			new Pair<Int, Int>(0xffe0b0ff, 0xff31ff63), new Pair<Int, Int>(0, text.length),
			new Rect(
				x - 10, y - 14,
				letterWidthPlusSpacing * text.length - AnimatedText.letterSpacing, 30
			),
			"https://apricot.blender.org/"
		));
		
		animatedTexts.push(new AnimatedText(animatedTexts[0].xx, animatedTexts[4].yy + 50, "ARTIST:"));
		
		text = "Dinh Quoc Nam";
		x = animatedTexts[5].xx + 40;
		y = animatedTexts[5].yy + lineSpacing;
		animatedTexts.push(new AnimatedText(
			x, y, text,
			new Pair<Int, Int>(0xffff5555, 0xffede159), new Pair<Int, Int>(0, text.length),
			new Rect(
				x - 10, y - 14,
				letterWidthPlusSpacing * text.length - AnimatedText.letterSpacing, 30
			),
			"https://twitter.com/DINHQUOCNAM"
		));
		
		animatedTexts.push(new AnimatedText(animatedTexts[3].xx, animatedTexts[6].yy + 50, "PROGRAMMER:", -1));
		
		text = "Nguyen Phuc Sinh";
		x = animatedTexts[7].xx + 40;
		y = animatedTexts[7].yy + lineSpacing;
		animatedTexts.push(new AnimatedText(
			x, y, text, -1,
			new Pair<Int, Int>(0xff2ad4ff, 0xffff55ff), new Pair<Int, Int>(0, text.length),
			new Rect(
				x - 10, y - 14,
				letterWidthPlusSpacing * text.length - AnimatedText.letterSpacing, 30
			),
			"https://twitter.com/melon404"
		));
		
		for (text in animatedTexts) add(text);
		
		licenseText1 = new BasicText("The creditted music and sound effects are available under", 20);
		licenseText1.y = G.height - licenseText1.height * 2 - 16;
		add(licenseText1);
		
		licenseText2 = new BasicText("Creative Commons Attribution 3.0 Unported license", 20);
		licenseText2.color = 0xffdaa520;
		licenseText2.y = licenseText1.y + licenseText1.height + 4;
		add(licenseText2);
		
		var buttonBehavior = new BasicButtonInteraction(licenseText2);
		buttonBehavior.addObjectRectMask();
		buttonBehavior.onOver.notify(function(_) licenseText2.color = 0xff007fff);
		buttonBehavior.onOut.notify(function(_) licenseText2.color = 0xffdaa520);
		buttonBehavior.onRelease.notify(function(_, _) Kala.openURL("http://creativecommons.org/licenses/by/3.0/"));
		
		tween = new Tween(this);
	}
	
	function onStartHandle(_):Void {
		licenseText1.x = licenseText2.x = G.width;
		
		tween.get()
			.startBatch()
				.tween(backButton, { x: G.width - backButton.width - 5 }, 40, Ease.sineOut)
				.tween(licenseText1, { x: (G.width - licenseText1.width) / 2 }, 80, Ease.backOut)
				.tween(licenseText2, { x: (G.width - licenseText2.width) / 2 }, 60, Ease.backOut)
			.endBatch()
			.call(function(_) backButton.active = true)
		.start();
		
		for (text in animatedTexts) {
			text.show();
		}
	}
	
	function close():Void {
		for (text in animatedTexts) {
			text.hide();
		}
	
		backButton.active = false;
		backButton.opacity = 0.6;
		tween.get()
			.startBatch()
				.tween(backButton, { x: G.width }, 40, Ease.sineOut)
				.tween(licenseText1, { x: -licenseText1.width }, 80, Ease.backIn)
				.tween(licenseText2, { x: -licenseText1.width }, 60, Ease.backIn)
			.endBatch()
			.call(function(_) G.switchState(MainMenuState.instance))
		.start();
	}
	
}

class AnimatedText extends GenericGroup {
	
	public static inline var letterSpacing = 2;
	
	public var xx:FastFloat;
	public var yy:FastFloat;
	
	var text:String;
	var colors:Pair<Int, Int>;
	var coloredRange:Pair<Int, Int>;
	var tween:Tween;
	var button:BasicButtonSprite;
	var url:String;
	
	public function new(x:FastFloat, y:FastFloat, text:String, ?rotSide:Int = 1, ?colors:Pair<Int, Int>, ?coloredRange:Pair<Int, Int>, ?rect:Rect, ?url:String) {
		super();
		
		xx = x;
		yy = y;
		this.text = text;
		
		tween = new Tween(this);
		
		var t:BasicText;
		var pt:BasicText;
		for (i in 0...text.length) {
			t = new BasicText(text.charAt(i), R.fonts.SpaceMono_Bold, 40);
			
			t.data = { y: y };
			if (i == 0) {
				t.data.x = x;
			} else {
				pt = cast members[i - 1];
				t.data.x = pt.data.x + pt.width + letterSpacing;
				//if (pt.text == 'I' || pt.text == 'i') t.data.x += 14;
			}
			
			t.rotation.setPivot(t.width / 2, t.height / 2);
			tween.get()
				.startLoop()
					.tween(t, { angle: 20 * rotSide }, 80, Ease.sineInOut)
					.tween(t, { angle: -20 * rotSide }, 80, Ease.sineInOut)
				.endLoop()
			.start();
			
			add(t);
		}
		
		if (colors != null) {
			this.url = url;
			this.colors = colors;
			this.coloredRange = coloredRange;
			
			button = new BasicButtonSprite(R.images.invisible_pixel); // callDraw() needs to be called for collider to work.
			button.addRectMask(rect.x, rect.y, rect.width, rect.height);
			button.onOut.notify(onOutHandle);
			button.onOver.notify(onOverHandle);
			button.onRelease.notify(onReleaseHandle);
			add(button);
		}
	}
	
	public function show():Void {
		var t:Object;
		var timeline:TweenTimeline;
		for (i in 0...text.length) {
			t = members[i];
			
			switch(Random.int(0, 3)) {
				case 0: t.setPos( -t.height, Random.int(0, cast G.height - t.height));
				case 1: t.setPos(G.width + t.height, Random.int(0, cast G.height - t.height));
				case 2: t.setPos(Random.int(0, cast G.width - t.width), -t.height);
				case 3: t.setPos(Random.int(0, cast G.width - t.width), G.height + t.height);
			}
			
			timeline = tween.get().tween(t, { x: t.data.x, y: t.data.y }, 80, Ease.sineOut);
			if (i == 0 && colors != null) timeline.call(function(_) button.active = true);
			timeline.start();
		}
		
		if (colors != null) {
			button.active = false;
			
			var startIndex = coloredRange.a;
			for (i in startIndex...coloredRange.b) {
				members[i].color = colors.a;
			}
		}
	}
	
	public function hide():Void {
		if (button != null) button.active = false;
		
		var t:Object;
		var p:Vec2;
		for (i in 0...text.length) {
			t = members[i];
			
			p = new Vec2();
			switch(Random.int(0, 3)) {
				case 0: p.set( -t.height, Random.int(0, cast G.height - t.height));
				case 1: p.set(G.width + t.height, Random.int(0, cast G.height - t.height));
				case 2: p.set(Random.int(0, cast G.width - t.width), -t.height);
				case 3: p.set(Random.int(0, cast G.width - t.width), G.height + t.height);
			}
			
			tween.get()
				.tween(t, { x: p.x, y: p.y }, 80, Ease.sineOut)
			.start();
		}
	}
	
	function onOutHandle(_):Void {
		var startIndex = coloredRange.a;
		for (i in startIndex...coloredRange.b) {
			members[i].color = colors.a;
		}
	}
	
	function onOverHandle(_):Void {
		var startIndex = coloredRange.a;
		for (i in startIndex...coloredRange.b) {
			members[i].color = colors.b;
		}
	}
	
	function onReleaseHandle(_, _):Void {
		Kala.openURL(url);
	}
	
}