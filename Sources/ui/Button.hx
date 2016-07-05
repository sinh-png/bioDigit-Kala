package ui;

import kala.behaviors.collision.transformable.shapes.CollisionPolygon;
import kala.objects.sprite.PushSprite;
import kala.objects.sprite.Sprite.SpriteData;
import kha.FastFloat;

class Button extends PushSprite {

	public var mask:CollisionPolygon;
	
	public function new(data:Dynamic, spriteData:SpriteData, centerX:Bool = false, centerY:Bool = false) {
		super();
		this.data = data;
		loadSpriteData(spriteData);
		centerOrigin(centerX, centerY);
		mask = addObjectRectMask();
	}
	
}