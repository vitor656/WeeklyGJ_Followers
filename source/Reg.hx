
enum States {
    Title;
    Intro;
    GetReady;
    Run;
    GameOver;
}

class Reg {
    public static inline var LAYER_TILES : String = "Tiles";
    public static inline var LAYER_ENTITIES : String = "Entities";
    public static var SPAWN_TIME : Float = 2;

    public static inline var GRAVITY : Float = 200;
    public static inline var VELOCITY : Float = 50;
    public static inline var JUMP_FORCE : Float = 60;

    public static inline var ENEMY_VELOCITY : Float = 20;


    public static var PS : PlayState;
    public static var gameState : States;
    public static var score : Int;
    public static var gameTime : Float;
}