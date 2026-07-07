package mikolka.vslice.ui;

import mikolka.vslice.ui.mainmenu.DesktopMenuState;
import mikolka.compatibility.ui.MainMenuHooks;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.ui.title.TitleState;
import mikolka.compatibility.ModsHelper;
import options.OptionsState;

var Bullshitery:Array<String> = [];

class MainMenuState extends MusicBeatState
{
	#if !LEGACY_PSYCH
	public static var psychEngineVersion:String = '1.0.4'; // This is also used for Discord RPC
	#else
	public static var psychEngineVersion:String = '0.6.3'; // This is also used for Discord RPC
	#end

	#if (MODS_ALLOWED && !LEGACY_PSYCH)
	var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/splash.txt');
	#else

	public static var BullShits:String = NativeFileSystem.getContent(Paths.txt('splash'));
	public static var Bullshitery:String = "" + BullShits;
	var firstArray:Array<String> = Bullshitery.split('\n');

	#end
	public static var pSliceVersion:String = '3.4.2'; 
	public static var xytheEngineVersion:String = "0.0.4";
	public static var funkinVersion:String = '0.6.0'; // Version of funkin' we are emulationg
	

	var bg:FlxSprite;
	var magenta:FlxSprite;

	var stickerSubState:Bool;
	public function new(?stickers:Bool = false)
	{
		super();
		stickerSubState = stickers;
		
	}
	
	override function create()
	{
		if(stickerSubState) ModsHelper.clearStoredWithoutStickers();
		else CacheSystem.clearStoredMemory();
		CacheSystem.clearUnusedMemory();
		#if (debug && !LEGACY_PSYCH)
		FlxG.console.registerFunction("dumpCache",CacheSystem.cacheStatus); 
		FlxG.console.registerFunction("dumpSystem",backend.Native.buildSystemInfo);
		#end
		
		ModsHelper.resetActiveMods();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = VsliceOptions.ANTIALIASING;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = VsliceOptions.ANTIALIASING;
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		var Splash:FlxText = new FlxText(0, 250, FlxG.width / 6 , FlxG.random.getObject(firstArray), 24);
		var psychVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, "Psych Engine " + psychEngineVersion, 12);
		var fnfVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);
		var xytheVer:FlxText = new FlxText(0, FlxG.height - 38, FlxG.width, 'Xythe Engine: v${xytheEngineVersion}', 12);

		Splash.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		xytheVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		Splash.antialiasing = false;
		Splash.scrollFactor.set();
		psychVer.scrollFactor.set();
		fnfVer.scrollFactor.set();
		xytheVer.scrollFactor.set();

		add(Splash);

		Sys.println(FlxG.random.getObject(firstArray));

		add(psychVer);
		add(fnfVer);
		add(xytheVer);
		//var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' ", 12);
	
		//changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			MainMenuHooks.unlockFriday();

		#if MODS_ALLOWED
		MainMenuHooks.reloadAchievements();
		#end
		#end

		super.create();
		#if TOUCH_CONTROLS_ALLOWED
		if (controls.mobileC)
			new mobile.states.MobileMenuState(this);
		else
		#end
		new DesktopMenuState(this);
		
	}

	function goToOptions()
	{
		MusicBeatState.switchState(new OptionsState());
		#if !LEGACY_PSYCH OptionsState.onPlayState = false; #end
		if (PlayState.SONG != null)
		{
			PlayState.SONG.arrowSkin = null;
			PlayState.SONG.splashSkin = null;
			#if !LEGACY_PSYCH PlayState.stageUI = 'normal'; #end
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;
		super.update(elapsed);
	}
}
