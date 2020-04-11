import Reg.States;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Insect extends FlxSprite {
    public function new () {
        super();

        loadGraphic(AssetPaths.Insect__png, true, 8, 8);
        animation.add("fly", [0, 1, 2, 3], 15);
        animation.play("fly");

        setSize(2, 2);
        updateHitbox();
    }

    override function update(elapsed:Float) {

        if(Reg.PS.hero.alive && Reg.gameState == States.Run)
            FlxVelocity.moveTowardsObject(this, Reg.PS.hero, Reg.ENEMY_VELOCITY);

        super.update(elapsed);
    }
}