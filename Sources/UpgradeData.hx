package;

import kha.FastFloat;

class UpgradeData {

	public static var startingLives:Int = 3;
	public static var shootingPower:Int = 1;
	public static var webTime:Int = 150;
	public static var lightningDMG:FastFloat = 1;
	public static var gemDropFactor:FastFloat = 1;
	public static var bornDelay:Int = 200;
	public static var childrenStartingLives:Int = 1;
	public static var childrenShootDelay:Int;
	public static var childrenLightningChance:Int = 30;
	public static var gemCollectionDistance:Int = 200;
	
	public static var level:Array<Int> = new Array<Int>();
	public static var cost:Array<Int> = new Array<Int>();
	
	public static var money:Int = 0;
	
	public static function upgrade(itemID:Int):Void {
	
		switch(itemID) {
			case 0: // Lives up
				startingLives++;
			case 1: // Shooting power up
				shootingPower++;
			case 2: // Web time up
				webTime+= 50;
			case 3: // Lightning DMG up
				lightningDMG += 0.1;
			case 4: // More gems
				gemDropFactor += 0.25;
			case 5: // Reduce born delay
				bornDelay -= 10;
			case 6: // Children lives up
				childrenStartingLives++;
			case 7: // Children fire rate up
				childrenShootDelay -= 5;
			case 8: // Children lightning chance up
				childrenLightningChance += 5;
			case 9: // Gem collection distance
				gemCollectionDistance += 50;
		}
	}
	
}