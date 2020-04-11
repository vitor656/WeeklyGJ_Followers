import flixel.util.FlxColor;
import flixel.FlxSprite;

class Bullet extends FlxSprite {
    public function new(x:Float, y:Float) {
        super(x, y);

        makeGraphic(2, 2, FlxColor.WHITE);
        centerOrigin();
    }

    override function update(elapsed:Float) {

        if(!isOnScreen()) {
            kill();
        }

        super.update(elapsed);
    }
}