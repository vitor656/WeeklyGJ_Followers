package;

import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxBitmapText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import Reg.States;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.FlxState;

class PlayState extends FlxState
{	
	public var map : FlxTilemap;
	public var hero : Hero;
	public var bullets : FlxTypedGroup<Bullet>;
	public var enemies : FlxTypedGroup<Insect>;
	private var	_introEnemies : FlxTypedGroup<Insect>;
	private var _runnningEffects : FlxTypedGroup<FlxSprite>;
	private var _score : FlxBitmapText;
	private var _gameOverText : FlxBitmapText;
	private var _restartText : FlxBitmapText;
	private var _startText : FlxBitmapText;
	private var _flxFlicketStart : FlxFlicker;
	private var _title : FlxBitmapText;
	private var _spawnTimeCounter : Float;
	private var _timerEffects : FlxTimer;
	private var _difficultChanged : Bool;
	private var _introDone : Bool;

	override public function create():Void
	{
		super.create();

		FlxG.sound.cacheAll();
		FlxG.mouse.cursorContainer.visible = false;

		Reg.PS = this;
		Reg.gameState = States.Title;
		Reg.score = 0;
		Reg.gameTime = 0;
		Reg.SPAWN_TIME = 2;
		_difficultChanged = false;
		_spawnTimeCounter = Reg.SPAWN_TIME;
		_introDone = false;

		var ogmoLoader : FlxOgmo3Loader = new FlxOgmo3Loader(AssetPaths.WeeklyGameJam_Map__ogmo, AssetPaths.Level__json);
		map = ogmoLoader.loadTilemap(AssetPaths.Tiles__png, Reg.LAYER_TILES);

		hero = new Hero();
		ogmoLoader.loadEntities(function (entity : EntityData) {
			switch (entity.name) {
				case "Hero":
					hero.setPosition(entity.x, entity.y);

			}
		}, Reg.LAYER_ENTITIES);

		FlxG.camera.setScrollBoundsRect(0, 0, map.width, map.height, true);
		
		_runnningEffects = new FlxTypedGroup<FlxSprite>(10);
		bullets = new FlxTypedGroup<Bullet>(10);
		enemies = new FlxTypedGroup<Insect>(100);
		_introEnemies = new FlxTypedGroup<Insect>(20);
		
		_score = new FlxBitmapText();
		_score.setPosition(-6, 0);
		_score.scale.set(0.5, 0.5);
		_score.scrollFactor.set(0, 0);
		_score.visible = false;

		_gameOverText = new FlxBitmapText();
		_gameOverText.text = "Game Over";
		_gameOverText.screenCenter();
		_gameOverText.scrollFactor.set(0, 0);
		_gameOverText.visible = false;
		
		_restartText = new FlxBitmapText();
		_restartText.text = "Press R to restart";
		_restartText.scale.set(0.3, 0.3);
		_restartText.screenCenter();
		_restartText.y = _restartText.y + 5;
		_restartText.scrollFactor.set(0, 0);
		_restartText.visible = false;
		
		_title = new FlxBitmapText();
		_title.text = "Tree Mutant Insects Runner";
		_title.scale.set(0.4, 0.4);
		_title.screenCenter();
		_title.y -= 20;
		_title.scrollFactor.set(0, 0);
		_title.visible = true;

		_startText = new FlxBitmapText();
		_startText.text = "Press SPACE to start";
		_startText.scale.set(0.3, 0.3);
		_startText.screenCenter();
		_startText.y = _restartText.y + 8;
		_startText.scrollFactor.set(0, 0);
		_startText.visible = true;

		_flxFlicketStart = FlxSpriteUtil.flicker(_startText, 0, 0.5);

		add(_introEnemies);
		add(map);
		add(_runnningEffects);
		add(bullets);
		add(enemies);
		add(hero);
		add(_score);
		add(_gameOverText);
		add(_restartText);
		add(_title);
		add(_startText);
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(map, hero);

		if(Reg.gameState == States.Title) {

			if(FlxG.keys.justPressed.SPACE) {
				_flxFlicketStart.stop();
				_startText.visible = false;
				_title.visible = false;

				Reg.gameState = States.Intro;

				FlxG.sound.play(AssetPaths.Explosion2__ogg);
			}

		} else if(Reg.gameState == States.Intro) {

			if(!_introDone) {

				FlxG.camera.shake(0.01, 1);

				for (i in 0...20) {
					var initialBatinsect : Insect = new Insect();
					initialBatinsect.setPosition(16, 32);
					initialBatinsect.velocity.set(
						FlxMath.fastCos(FlxAngle.asRadians(FlxG.random.int(-90, 30))) * FlxG.random.int(80, 100),
						FlxMath.fastSin(FlxAngle.asRadians(FlxG.random.int(-90, 30))) * FlxG.random.int(80, 100)
					);
					_introEnemies.add(initialBatinsect);
				}
				
				new FlxTimer().start(2, function(_){
					_introEnemies.kill();
					Reg.gameState = States.GetReady;
					FlxG.camera.follow(hero, FlxCameraFollowStyle.PLATFORMER, 0.2);
					createRunningEffects();				
				});
				
				_introDone = true;
			}

		} else if (Reg.gameState == States.GetReady) {

		} else if(Reg.gameState == States.Run) {

			Reg.gameTime += elapsed;

			makeItHarder();
			updateEffects();
			spawnEnemies(elapsed);
			collisions();
			
			if (!_score.visible)
				_score.visible = true;

			_score.text = "Score: " + Reg.score;

		} else if(Reg.gameState == States.GameOver){
			_gameOverText.visible = true;
			_restartText.visible = true;

			if (FlxG.keys.justPressed.R){
				FlxG.resetGame();
			}
		}

		super.update(elapsed);
	}

	private function createRunningEffects() {
		_timerEffects = new FlxTimer().start(0.2, function(timer){
		
			var effect : FlxSprite = _runnningEffects.recycle(FlxSprite, null);
			effect.x = map.width;
			effect.y = FlxG.random.float(0, map.height - 16);
			effect.makeGraphic(FlxG.random.int(2, 5), 1, FlxColor.WHITE);
			effect.velocity.x = -120;
		
		}, 0);
	}

	private function updateEffects() {
		_runnningEffects.forEach(function(effect) {
			if(effect.x < 0) {
				effect.kill();		
			}
		});
	}

	private function spawnEnemies(elapsed:Float) {
		_spawnTimeCounter -= elapsed;
		if(_spawnTimeCounter < 0) {

			var insect : Insect = enemies.recycle(Insect, null);
			var wherefrom : Int = FlxG.random.int(0, 2);
			switch (wherefrom) {
				case 0:
					insect.setPosition(0, FlxG.random.int(0, 64));
				case 1:
					insect.setPosition(FlxG.random.int(64, 128), 0);
				case 2:
					insect.setPosition(128, FlxG.random.int(0, 64));
			}
			
			_spawnTimeCounter = Reg.SPAWN_TIME;
		}
	}

	private function collisions() {
		FlxG.overlap(enemies, bullets, function (collidedEnemy, collidedBullet) {
			FlxG.camera.shake(0.01, 0.1);
			FlxG.sound.play(AssetPaths.Explosion1__ogg);

			var explosion : FlxEmitter = new FlxEmitter();
			explosion.x = cast(collidedEnemy, Insect).x;
			explosion.y = cast(collidedEnemy, Insect).y;
			explosion.makeParticles(1, 1, FlxColor.WHITE, 10);
			explosion.acceleration.set(0, 50, 0, 100);
			add(explosion);

			cast(collidedEnemy, Insect).kill();
			cast(collidedBullet, Bullet).kill();

			explosion.start();

			Reg.score++;
		});

		FlxG.overlap(enemies, hero, function(collidedEnemy, collidedHero) {
			FlxG.camera.shake(0.01, 0.3);
			FlxG.sound.play(AssetPaths.Explosion1__ogg);

			var explosion : FlxEmitter = new FlxEmitter();
			explosion.x = cast(collidedEnemy, Insect).x;
			explosion.y = cast(collidedEnemy, Insect).y;
			explosion.makeParticles(1, 1, FlxColor.WHITE, 50);
			explosion.acceleration.set(0, 50, 0, 100);
			add(explosion);

			cast(collidedEnemy, Insect).kill();
			cast(collidedHero, Hero).kill();

			explosion.start();

			_timerEffects.cancel();
			Reg.gameState = States.GameOver;
		});
	}

	private function makeItHarder() {
		if(Std.int(Reg.gameTime) % 5 == 0 && !_difficultChanged) {
			Reg.SPAWN_TIME -= 0.2;
			_difficultChanged = true;
			new FlxTimer().start(1, function(_) {
				_difficultChanged = false;
			});
		}
	}

}
