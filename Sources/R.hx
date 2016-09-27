package;

import kala.asset.Assets;
import kala.asset.Assets.SheetList;
import kala.objects.sprite.Sprite.SpriteData;
import kha.Assets.FontList;
import kha.Assets.ImageList;
import kha.Assets.SoundList;

/**
 * Used to store sprite data & assets. 
 */
class R {

	public static var sheets:SheetList;
	public static var images:ImageList;
	public static var sounds:SoundList;
	public static var fonts:FontList;
	
	public static var playerChildRunning:SpriteData;
	public static var playerChildStanding:SpriteData;
	public static var playerWebShooting:SpriteData;
	public static var playerWebSpreading:SpriteData;
	public static var playerLightning:SpriteData;
	public static var playerBullet:SpriteData;
	
	public static var enemyA:SpriteData;
	public static var enemyB:SpriteData;
	public static var enemyC:SpriteData;
	public static var enemyD:SpriteData;
	public static var enemyDChild:SpriteData;
	public static var boss:SpriteData;
	public static var bossLightning:SpriteData;
	public static var bossThroneBig:SpriteData;
	public static var bossThroneSmall:SpriteData;
	
	public static var upgradeBackButton:SpriteData;
	public static var upgradeStartButton:SpriteData;
	public static var upgradeButton:SpriteData;
	public static var upgradeDescBG:SpriteData;
	public static var upgradeItem0:SpriteData;
	public static var upgradeItem1:SpriteData;
	public static var upgradeItem2:SpriteData;
	public static var upgradeItem3:SpriteData;
	public static var upgradeItem4:SpriteData;
	public static var upgradeItem5:SpriteData;
	public static var upgradeItem6:SpriteData;
	public static var upgradeItem7:SpriteData;
	public static var upgradeItem8:SpriteData;
	public static var upgradeItem9:SpriteData;
	
	public static var gem:SpriteData;
	
	static var uncompressedSoundCount:Int = 0;
	static var onAllSoundsUncompressedCB:Void->Void;
	
	public static function init():Void {
		sheets = Assets.sheets;
		images = Assets.images;
		sounds = Assets.sounds;
		fonts = Assets.fonts;
		
		playerChildRunning = sheets.sprite_sheet_2.get("player/mini/run/", images.sprite_sheet_2);
		playerChildStanding = sheets.sprite_sheet_2.get("player/mini/stand/", images.sprite_sheet_2);
		playerWebShooting = sheets.sprite_sheet_2.get("player/web/shooting.png", images.sprite_sheet_2);
		playerWebSpreading = sheets.sprite_sheet_2.get("player/web/spreading.png", images.sprite_sheet_2);
		playerLightning = sheets.sprite_sheet_2.get("player/lightning/", images.sprite_sheet_2);
		playerBullet = sheets.sprite_sheet_2.get("player/bullet.png", images.sprite_sheet_2);
		
		enemyA = sheets.sprite_sheet_2.get("enemies/enemy_0.png", images.sprite_sheet_2);
		enemyB = sheets.sprite_sheet_2.get("enemies/enemy_1.png", images.sprite_sheet_2);
		enemyC = sheets.sprite_sheet_2.get("enemies/enemy_2/", images.sprite_sheet_2);
		enemyD = sheets.sprite_sheet_2.get("enemies/enemy_3/big/", images.sprite_sheet_2);
		enemyDChild = sheets.sprite_sheet_2.get("enemies/enemy_3/mini/", images.sprite_sheet_2);
		
		boss = sheets.sprite_sheet_2.get("enemies/boss/body.png", images.sprite_sheet_2);
		bossLightning = sheets.sprite_sheet_2.get("enemies/boss/lightning/", images.sprite_sheet_2);
		bossThroneBig = sheets.sprite_sheet_2.get("enemies/boss/throne/big.png", images.sprite_sheet_2);
		bossThroneSmall = sheets.sprite_sheet_2.get("enemies/boss/throne/small.png", images.sprite_sheet_2);
		
		gem = sheets.sprite_sheet_2.get("crystal.png", images.sprite_sheet_2);
		
		upgradeBackButton = sheets.sprite_sheet_1.get("upgrade_menu/back_button.png", images.sprite_sheet_1);
		upgradeStartButton = sheets.sprite_sheet_1.get("upgrade_menu/start_button.png", images.sprite_sheet_1);
		upgradeButton = sheets.sprite_sheet_1.get("upgrade_menu/level_up_button.png", images.sprite_sheet_1);
		upgradeDescBG = sheets.sprite_sheet_1.get("upgrade_menu/description_bg.png", images.sprite_sheet_1);
		upgradeItem0 = sheets.sprite_sheet_1.get("upgrade_menu/icons/0.png", images.sprite_sheet_1);
		upgradeItem1 = sheets.sprite_sheet_1.get("upgrade_menu/icons/1.png", images.sprite_sheet_1);
		upgradeItem2 = sheets.sprite_sheet_1.get("upgrade_menu/icons/2.png", images.sprite_sheet_1);
		upgradeItem3 = sheets.sprite_sheet_1.get("upgrade_menu/icons/3.png", images.sprite_sheet_1);
		upgradeItem4 = sheets.sprite_sheet_1.get("upgrade_menu/icons/4.png", images.sprite_sheet_1);
		upgradeItem5 = sheets.sprite_sheet_1.get("upgrade_menu/icons/5.png", images.sprite_sheet_1);
		upgradeItem6 = sheets.sprite_sheet_1.get("upgrade_menu/icons/6.png", images.sprite_sheet_1);
		upgradeItem7 = sheets.sprite_sheet_1.get("upgrade_menu/icons/7.png", images.sprite_sheet_1);
		upgradeItem8 = sheets.sprite_sheet_1.get("upgrade_menu/icons/8.png", images.sprite_sheet_1);
		upgradeItem9 = sheets.sprite_sheet_1.get("upgrade_menu/icons/9.png", images.sprite_sheet_1);
	}
	
	public static function uncompressSounds(onCompleteCB:Void->Void):Void {
		onAllSoundsUncompressedCB = onCompleteCB;
		R.sounds.Dissonant_Waltz.uncompress(onSoundUncompressed);
		R.sounds.bounce.uncompress(onSoundUncompressed);
		R.sounds.flap.uncompress(onSoundUncompressed);
		R.sounds.lightning.uncompress(onSoundUncompressed);
		R.sounds.upgrade.uncompress(onSoundUncompressed);
		R.sounds.spawn.uncompress(onSoundUncompressed);
	}
	
	static function onSoundUncompressed():Void {
		uncompressedSoundCount++;
		if (uncompressedSoundCount == 1) {
			onAllSoundsUncompressedCB();
		}
	}

}