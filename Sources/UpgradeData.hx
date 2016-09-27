package;

import kha.FastFloat;
import states.UpgradeState;

class UpgradeData {
	
	public static var money(default, set):Int;

	public static var startingLives:Int;
	public static var shootDelay:Int;
	public static var bulletsPerShot:Int;
	public static var middleBulletIndex:Int;
	public static var webDuration:Int;
	public static var lightningDMG:FastFloat;
	public static var gemDropFactor:FastFloat;
	public static var minionSpawnDelay:Int;
	public static var minionStartingLives:Int;
	public static var minionShootDelay:Int;
	public static var minionLightningChance:Int;
	public static var gemCollectionDistance:Int;
	
	public static var itemLevel:Array<Int>;
	public static var itemMaxLevel(default, never):Array<Int> = [99, 5, 10, 10, 10, 10, 4, 10, 10, 3];
	
	public static function getCost(id:Int):Int {
		return Math.round((itemLevel[id] + 1) * (itemLevel[id] + 1) * 10);
	}
	
	public static function isUpgradable(id:Int) {
		return money >= getCost(id) && itemLevel[id] < itemMaxLevel[id];
	}
	
	public static function upgrade(id:Int):Void {
		var cost = getCost(id);
		if (money >= cost) {
			money -= cost;
			itemLevel[id]++;
		}
	}
	
	public static function update(?customItemLevels:Array<Int>):Void {
		var itemLevel:Array<Int>;
		if (customItemLevels == null) itemLevel = UpgradeData.itemLevel;
		else itemLevel = customItemLevels;
			
		startingLives = 1 + itemLevel[0];
		
		shootDelay = 15 - itemLevel[1] * 2;
		bulletsPerShot = itemLevel[1];
		middleBulletIndex = Math.floor(bulletsPerShot / 2);
		
		webDuration = 50 + itemLevel[2] * 30;
		lightningDMG = 1 + itemLevel[3] / 10;
		
		gemDropFactor = 1 + itemLevel[4] / 5;
		
		minionSpawnDelay = 400 - itemLevel[5] * 20;
		minionStartingLives = 1 + itemLevel[6];
		minionShootDelay = 20 - itemLevel[7];
		minionLightningChance = itemLevel[8] * 2;
		
		gemCollectionDistance = 100 + itemLevel[9] * 120;
		
		#if (!cap_30 || debug)
		shootDelay *= 2;
		webDuration *= 2;
		minionSpawnDelay *= 2;
		minionShootDelay *= 2;
		lightningDMG /= 2;
		#end
	}

	static function set_money(value:Int):Int {
		UpgradeState.instance.moneyText.text = "x " + value;
		return money = value;
	}
	
}