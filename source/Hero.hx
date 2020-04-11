import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import Reg.States;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;

class Hero extends FlxSprite {
    public function new() {
        super();

        loadGraphic(AssetPaths.Hero__png, true, 8, 8);
        animation.add("idle", [0, 1, 2, 3], 10, true, true);
        animation.add("run", [4, 5, 6, 7], 12, true, false);
        animation.add("jump", [8,9], 12, true, false);

        acceleration.y = Reg.GRAVITY;
        animation.play("idle");

        setSize(3, 8);
        updateHitbox();


    }

    override function update(elapsed:Float) {

        if(alive) {
            if(Reg.gameState == States.Intro) {
                animation.play("idle");
            } else if (Reg.gameState == States.GetReady) {
                
                animation.play("run");
    
                if(x < ((Reg.PS.map.width / 4) * 3)){
                    velocity.x = Reg.VELOCITY;
                } else {
                    velocity.x = 0;
                    Reg.gameState = States.Run;
                }
                    
            } else if(Reg.gameState == States.Run) {
                
                if(isTouching(FlxObject.FLOOR) && FlxG.keys.justPressed.SPACE) {
                    velocity.y = -Reg.JUMP_FORCE;
                    FlxG.sound.play(AssetPaths.Jump1__ogg);
                }
    
                if(!isTouching(FlxObject.FLOOR)){
                    animation.play("jump");
                } else {
                    animation.play("run");
                }
    
                handleRunningInput();
        
            }
        }
		
        super.update(elapsed);
    }
    
    private function handleRunningInput() {
        if(FlxG.mouse.justPressed) {
            FlxG.sound.play(AssetPaths.Shoot1__ogg);

            var throwEffect : Throw = new Throw(x - 1, y);
            if(FlxG.mouse.getPosition().x < x){
                throwEffect.flipX = true;
                throwEffect.x -= 2;
            }
                
            Reg.PS.add(throwEffect);

            var bullet : Bullet = Reg.PS.bullets.recycle(Bullet, null);

            bullet.setPosition(x, y);

            bullet.velocity.set(
                FlxMath.fastCos(FlxAngle.angleBetweenMouse(this)) * 100,
                FlxMath.fastSin(FlxAngle.angleBetweenMouse(this)) * 100
            );

            FlxG.camera.shake(0.005, 0.1);
        }
    }
}