import flixel.util.FlxTimer;
import flixel.FlxSprite;

class Throw extends FlxSprite {

    public function new(x : Float, y : Float) {
        super(x, y);

        loadGraphic(AssetPaths.throw__png, true, 8, 8);
        animation.add("throw", [0, 1, 2, 3, 4], 20, false);
        animation.play("throw");

        new FlxTimer().start(0.3, function (_) {
            kill();
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}