package {

	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.system.ApplicationDomain;
	import com.greensock.TweenNano;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	import flash.filters.GlowFilter;
	import com.shirne.component.FixedMenu;
	import flash.system.System;


	public class LinkGame extends Sprite {

		//头部
		public var header:Sprite = null;

		public var startBtn:LButton = null;
		public var tipBtn:LButton = null;
		public var sortBtn:LButton = null;
		public var resetBtn:LButton = null;
		public var userScore:TextField = null;
		
		//选关按钮
		public var levelBtn:LButton=null;
		//帮助按钮
		public var helpBtn:LButton=null;
		//皮肤切换按钮
		public var skinBtn:LButton=null;
		//演示按钮
		public var demoBtn:LButton=null;

		//计时
		public var timing:Timing = null;

		//主体
		public var box:Sprite = null;
		//显示宽高
		public var mainWidth:int = 550;
		public var mainHeight:int = 420;
		//主场景宽高
		public var sceneWidth:int = 550;
		public var sceneHeight:int = 320;
		
		public var headerHeight:int = 80;
		public var infoLine:int = 35;

		//元素表
		public var map:Vector.<Block>;
		//尺寸
		public var size:Array = null;
		
		//音乐
		public var sound:SoundManager;
		public var bgSound:SoundManager;

		//路径
		public var way:Way = null;

		//关卡
		public var level:Level = null;
		private var levelTitle:TextField=null;

		public var user:User = null;

		//状态,0-停止,1-开始,2-暂停　
		public var state:int = 0;

		public var counter:int = 0;
		
		//上一个选中的元素
		public var prev:Block=null;
		//上一个找到可连接的元素
		public var finded:Array=null;

		//配置
		public var globalConfig:XML=null;
		public var config:XML = null;
		public var configFile:String="config.xml";
		public var statusName:String;
		private var request:URLRequest;
		
		private var Status:TextField=null;
		
		private var skin:SkinConfig;
		
		private var bg:Sprite;
		private var bgData:BitmapData;
		
		private var about:About;
		
		private var inited:Boolean=false;
		
		public function LinkGame() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			new FixedMenu(this,'临风小筑','http://www.shirne.com');
			
			Status=new TextField();
			Status.defaultTextFormat = new TextFormat("微软雅黑", 14, 0x009cff, true);
			Status.autoSize = TextFieldAutoSize.LEFT;
			Status.mouseEnabled=false;
			parent.addChild(Status);
			Status.x=(stage.stageWidth-Status.width)*.5;
			Status.y=(stage.stageHeight-Status.height)*.5;
			
			if(stage.loaderInfo.parameters.configfile){
				configFile = String(stage.loaderInfo.parameters.configfile);
			}
			
			//加载全局配置
			request = new URLRequest(configFile);
			setStatus(Lang.config);
			var ldr:URLLoader=new URLLoader();
			ldr.addEventListener(Event.COMPLETE,globalConfigLoaded);
			ldr.addEventListener(IOErrorEvent.IO_ERROR,loadError);
			ldr.load(request);
		}
		
		public function setStatus(nm:String):void{
			statusName = nm;
			Status.text = Lang.loading(statusName);
			Status.x=(stage.stageWidth-Status.width)*.5;
		}
		
		public function loadError(e:IOErrorEvent):void{
			Status.textColor = 0xff0000;
			Status.text=Lang.loadError(statusName,request.url);
		}
		
		public function globalConfigLoaded(e:Event):void{
			globalConfig = new XML(e.target.data);
			
			//初始化一些配置
			if(globalConfig.width.length()){
				mainWidth = int(globalConfig.width);
			}
			if(globalConfig.height.length()){
				mainHeight = int(globalConfig.height);
			}
			if(globalConfig.scene.length()){
				sceneWidth = int(globalConfig.scene.width);
				sceneHeight = int(globalConfig.scene.height);
			}
			
			//加载配置
			request.url = globalConfig.config[0];
			if(stage.loaderInfo.parameters.xmlfile){
				request.url = String(stage.loaderInfo.parameters.xmlfile);
			}
			setStatus(Lang.skinConfig);
			if(stage.loaderInfo.parameters.skinfile){
				request.url = String(stage.loaderInfo.parameters.skinfile);
			}
			var ldr:URLLoader=new URLLoader();
			ldr.addEventListener(Event.COMPLETE,configLoaded);
			ldr.addEventListener(IOErrorEvent.IO_ERROR,loadError);
			ldr.load(request);
		}

		public function configLoaded(e:Event):void
		{
			config = new XML(e.target.data);
			Block.initArg(config.shape[0]);
			
			size = [int(config.shape.width),int(config.shape.height)];
			
			skin=new SkinConfig(this,globalConfig.config);
			skin.initSkin();
			
			//加载皮肤
			request.url = config.skin.folder +'/' + config.skin.file;
			setStatus(Lang.skin);
			var ldr:Loader = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,skinLoaded);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadError);
			ldr.load(request);
		}
		
		public function skinLoaded(e:Event):void{
			var skinDomain:ApplicationDomain=(e.currentTarget as LoaderInfo).applicationDomain;
			bg = new Sprite();
			if(bgData)bgData.dispose();
			bgData = new (skinDomain.getDefinition('BackGround') as Class)();
			
			sound = new SoundManager(skinDomain);
			
			drawBg();
			
			bg.alpha = 0;
			parent.addChild(bg);
			parent.swapChildren(this,bg);
			new FixedMenu(bg,'临风小筑','http://www.shirne.com');
			var tn:TweenNano = TweenNano.to(bg,.5,{alpha:1,onComplete:function(){tn.kill();}});
			stage.addEventListener(Event.RESIZE,drawBg);
			
			e.target.loader.unload();
			
			//加载资源
			request.url = Block.dir + Block.file;
			setStatus(Lang.resource);
			var ldr:Loader=new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,resourceLoadOK);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadError);
			ldr.load(request);
		}
		
		public function resourceLoadOK(e:Event=null):void
		{
			var dClass:Class,appDomain:ApplicationDomain,lInfo:LoaderInfo;
			lInfo=e.currentTarget as LoaderInfo;
			appDomain = lInfo.applicationDomain;
			var i:int;
			if(Block.BitMaps){
				for(i=0;i<Block.BitMaps.length;i++){
					Block.BitMaps[i].dispose();
				}
				Block.BitMaps.length=0;
			}else{
				Block.BitMaps=new Vector.<BitmapData>();
			}
			
			for(i=1;i<=Block.number;i++){
				dClass = appDomain.getDefinition('Item'+ (i<10?'0'+i:i)) as Class;
				Block.BitMaps.push(new dClass());
			}
			e.target.loader.unload();
			parent.removeChild(Status);
			if(inited){
				System.gc();
				rerender();
			}else{
				inited=true;
				init();
			}
		}
		
		public function init() {
			header = new Sprite();
			addChild(header);

			//创建按钮
			var xPos:Number = 10;
			startBtn = CreateBtn(Lang.start, start, xPos);
			header.addChild(startBtn);
			
			xPos += startBtn.width +15;
			tipBtn = CreateBtn(Lang.tip(0), show, xPos);
			header.addChild(tipBtn);
			
			xPos += tipBtn.width +15;
			sortBtn = CreateBtn(Lang.upset(0), resort, xPos);
			header.addChild(sortBtn);
			
			xPos += sortBtn.width +15;
			resetBtn = CreateBtn(Lang.reset, reset, xPos);
			header.addChild(resetBtn);
			
			userScore = new TextField();
			userScore.defaultTextFormat=new TextFormat("LcdD",14,0xffffff);
			userScore.autoSize = TextFieldAutoSize.LEFT;
			userScore.text = '0';
			userScore.x = 360;
			userScore.y = infoLine + 2;
			addChild(userScore);
			
			var userScoreLabel:TextField=new TextField();
			userScoreLabel.defaultTextFormat=new TextFormat("微软雅黑",14,0xffffff);
			userScoreLabel.autoSize = TextFieldAutoSize.LEFT;
			userScoreLabel.text = Lang.score;
			userScoreLabel.x = 325;
			userScoreLabel.y = infoLine - 2;
			addChild(userScoreLabel);
			
			
			levelTitle = new TextField();
			levelTitle.defaultTextFormat = new TextFormat("微软雅黑", 14, 0x009cff, true);
			levelTitle.autoSize = TextFieldAutoSize.LEFT;
			levelTitle.filters = [new GlowFilter(0xffffff,.8, 6, 6, 4, 10)];
			levelTitle.text = Lang.clickStart;
			levelTitle.x = 10;
			levelTitle.y = 5;
			addChild(levelTitle);

			timing = new Timing(this);
			header.addChild(timing);

			box = new Sprite();
			box.visible = false;
			addChild(box);

			way = new Way(this);
			level = new Level(this);
			Helper.level = level;
			
			var topBtnFormat:TextFormat=new TextFormat("微软雅黑",10,0xffffff);
			
			levelBtn = new LButton(Lang.selectLevel,selectLevel);
			levelBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			levelBtn.x = 400;
			levelBtn.y = 5;
			levelBtn.setPadding(5,0);
			levelBtn.textFormat=topBtnFormat;
			addChild(levelBtn);
			
			helpBtn = new LButton(Lang.help,showHelp);
			helpBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			helpBtn.x = levelBtn.x + levelBtn.width + 10;
			helpBtn.y = 5;
			helpBtn.setPadding(5,0);
			helpBtn.textFormat=topBtnFormat;
			addChild(helpBtn);
			
			skinBtn = new LButton(Lang.skin,changeSkin);
			skinBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			skinBtn.x = helpBtn.x + helpBtn.width + 10;
			skinBtn.y = 5;
			skinBtn.setPadding(5,0);
			skinBtn.textFormat=topBtnFormat;
			addChild(skinBtn);
			
			demoBtn = new LButton(Lang.demo,autoTest);
			demoBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			demoBtn.x = skinBtn.x + skinBtn.width + 10;
			demoBtn.y = 5;
			demoBtn.setPadding(5,0);
			demoBtn.textFormat=topBtnFormat;
			//addChild(demoBtn);
			
			//用户
			user = new User(this);
			
			position();
			stage.addEventListener(Event.RESIZE,position);
		}
		
		public function loadSkin(file:String):void{
			parent.addChild(Status);
			
			setStatus(Lang.skinConfig);
			
			request.url = file;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener(Event.COMPLETE, configLoaded);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			ldr.load(request);
		}
		
		public function rerender():void{
			drawBg();
			
			startBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			tipBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			sortBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			resetBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			levelBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			helpBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			skinBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			demoBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			
			reset();
		}
		
		private function autoTest(e:MouseEvent):void{
			if(finded){
				prev=finded[1];
				finded[0].clickHandle();
			}else{
				
			}
		}
		
		private function changeSkin(e:MouseEvent):void{
			skin.showSelect();
		}
		
		private function showHelp(e:MouseEvent):void{
			if(state == 1)pause();
			if(!about){
				about=new About(this,globalConfig.help[0]);
			}
			if(about.inStage == false){
				parent.addChild(about);
			}
		}
		
		private function selectLevel(e:MouseEvent):void{
			if(state == 1)pause();
			level.showSelect([]);
		}

		private function CreateBtn(txt:String, clickHandle:Function, px:int = 0):LButton {
			var btn:LButton = new LButton(txt, clickHandle);
			btn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			btn.x = px;
			btn.y = infoLine;

			return btn;
		}
		
		//背景皮肤
		public function drawBg(e:Event=null):void{
			var mtx:Matrix = new Matrix();
			
			var scale:Number = Math.max(stage.stageWidth/bgData.width,stage.stageHeight/bgData.height);
			mtx.scale(scale, scale);
			mtx.tx = (stage.stageWidth - bgData.width * scale)*.5;
			mtx.ty = (stage.stageHeight - bgData.height * scale)*.5;
			bg.graphics.clear();
			bg.graphics.beginBitmapFill(bgData,mtx, false, true);
			bg.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			bg.graphics.endFill();
			
		}
		
		//重新定位
		public function position(e:Event=null):void {
			
			var scale:Number=Math.min(stage.stageWidth/mainWidth,stage.stageHeight/mainHeight);
			
			this.scaleX = scale;
			this.scaleY = scale;
			
			this.x = (stage.stageWidth - mainWidth * scale)*.5;
			this.y = (stage.stageHeight - mainHeight * scale)*.5;
			
			this.graphics.clear();
			this.graphics.beginFill(0xffffff,.5);
			this.graphics.drawRoundRect(0, headerHeight , sceneWidth, sceneHeight, 5);
			this.graphics.endFill();
		}
		
		//开始事件
		public function start(e:Event=null):void {
			if(state != 1){
				if(state == 0){
					this.enter();
				}else{
					timing.start();
				}
				state = 1;
				box.visible = true;
				startBtn.text = Lang.pause;
			}else{
				pause();
			}
		}
		
		//暂停
		public function pause(e:Event=null):void{
			state = 2;
			box.visible = false;
			startBtn.text = Lang.goon;
			timing.stop();
		}

		//重置
		public function reset(e:Event=null):void {
			
			level.reset();
			finded=null;
			if(map)map.length=0;
			while(box.numChildren>0){
				box.removeChildAt(0);
			}
			
			state = 0;
			box.visible = false;
			timing.reset();
			user.reset();
			
			startBtn.text = Lang.start;
			levelTitle.text=Lang.clickStart;
		}
		
		//重新排序
		public function resort(e:Event=null) {
			if (user.sorttime <= 0) {
				sound.play(SoundManager.NotMatch);
				return;
			}
			
			user.sorttime--;//
			user.show(true);
			var i:int;
			var shapes:Vector.<int>=new Vector.<int>();
			for ( i=0; i < map.length; i++) {
				if (map[i]) {
					shapes.push(map[i].type);
				}
			}
			for ( i=0; i < map.length; i++) {
				if (map[i]) {
					map[i].type = RndArray(shapes);
					map[i].setStyle();
				}
			}
			if(this.state != 1)this.start();
			if(timing.stoptime)timing.start();
			finded = null;
			way.find();
		}
		
		//进入下一关
		public function nextlevel() {
			if (level.level >= level.length-1) {
				alert(Lang.success(user.score,timing.aTime ),this.reset);
			} else {
				sound.play(SoundManager.Clear);
				level.next();
				alert(Lang.nextLevel(level.title));
			}
		}
		
		//显示提示
		public function show(e:Event=null) {
			if (user.tiptime <= 0) {
				sound.play(SoundManager.NotMatch);
				return;
			}
			sound.play(SoundManager.Tip);
			if (!way.finded) {
				if(state == 0){
					this.reset();
					alert(Lang.notStart);
					return;
				}else{
					//逻辑有一点错误，有时候会跑到这里
					finded = null;
					way.find();
				}
			} 
			if(prev){
				prev.active();
			}
			finded[0].showTip();
			finded[1].showTip();
			way.tip = true;
			user.tiptime--;
			user.show(true);
		}
		
		//根据内部座标查找元素
		public function find(fx:Number, fy:Number):Block{
			var p:SPoint=new SPoint(Math.ceil((fx+size[0] * .5)/size[0]),Math.ceil((fy+size[1] * .5)/size[1]));
			return map[p.index];
		}
		
		//拖动方式连接元素
		public function dragLink(n:Block) {
			if(!n){
				prev.back();
				return;
			}
			if (prev.type == n.type && !prev.point.equal(n.point)) {
				//是否与系统找到的点一致?
				if(way.isFinded(n.point,prev.point)){
					//是否是系统提示的点?
					if(way.tip){
						way.tip = false;
					}else{
						if(counter > map.length * .5)user.score +=  10;
					}
				}else{
					way.init(n.point,prev.point);
				}
				
				if (way.finded) {
					sound.play(SoundManager.Match);
					
					//移除
					remove(n);
					
					//查找下一对
					way.find();
					return;
				}
			}
			sound.play(SoundManager.NotMatch);
			prev.back();
		}
		
		//连接元素
		public function link(n:Block) {
			if (prev.type == n.type) {
				//是否与系统找到的点一致?
				if(way.isFinded(n.point,prev.point)){
					//是否是系统提示的点?
					if(way.tip){
						way.tip = false;
					}else{
						if(counter > map.length * .5)user.score +=  10;
					}
				}else{
					way.init(n.point,prev.point);
				}
				
				if (way.finded) {
					sound.play(SoundManager.Match);
					way.show();
					//移除
					remove(n);
					
					//查找下一对
					way.find();
					return;
				}else{
					sound.play(SoundManager.NotMatch);
				}
			}else{
				sound.play(SoundManager.Click);
			}
			prev.active();
			n.active();
		}
		
		//移除，同时会移除上一个选定的
		//实际并不移除舞台，只移除集合中的位置
		public function remove(obj:Block):void{
			if(finded){
				if(obj.point.equal(finded[0].point) || obj.point.equal(finded[1].point)||
				   prev.point.equal(finded[0].point) || prev.point.equal(finded[1].point)){
					finded = null;
				}
			}
			
			map[obj.point.index]=null;
			map[prev.point.index]=null;
			counter-=2;
			timing.add(2);
			
			obj.hide();
			prev.hide();
			
			//移动;
			move(level.type);
			
			prev=null;
			
			user.score+=2;//每消一个增加一分,增加一秒时间
			user.show();
			if (counter<=0) {
				timing.stop(true);
				nextlevel();
			}
		}
		
		public function RndArray(arr:Vector.<int>):int
		{
			var index=Math.ceil(Math.random()*(arr.length-1));
			return arr.splice(index,1)[0];
		}
		
		//初始化关卡
		public function enter(e:Event=null) {
			var temp:Block=null;
			levelTitle.text = level.stage + ": " + level.title;
			SPoint.column = level.x;
			state = 1;
			var i:int,j:int;
			var shapes:Vector.<int> = new Vector.<int>(level.x*level.y);
			map=new Vector.<Block>(level.x * level.y);
			for ( i=1; i<level.x*level.y; i+=2) {
				shapes[i] = shapes[i + 1] = Math.ceil(Math.random() * level.shapes);
			}

			for ( j=1; j<=level.y; j++) {
				for ( i=1; i<=level.x; i++) {
					temp = new Block(this,i,j,RndArray(shapes));
					map[temp.point.index] = temp;
					box.addChild(temp);
				}
			}
			
			var curWidth:Number = (level.x+1) * size[0];
			var curHeight:Number = (level.y+1) * size[1];
			var scale:Number = Math.min(sceneHeight/curHeight, sceneWidth/curWidth);
			box.scaleX = scale;
			box.scaleY = scale;
			box.x = (sceneWidth - curWidth * scale + size[0] * scale) * .5;
			box.y = headerHeight + (sceneHeight - curHeight * scale + size[1] * scale) * .5;
			
			Block.maxX = (level.x-1) * size[0];
			Block.maxY = (level.y-1) * size[1];
			
			finded = null;
			user.tiptime +=  level.tip;
			user.sorttime +=  level.sort;
			counter = level.x * level.y;
			timing.astrict = level.time;
			user.show(true);
			timing.start();
			way.find();
		}
		
		//t-移动类型,k-分区移动(0-1)
		public function move( t:int, k:int=1) {
			if (t===0) {
				return;
			}
			var index:int,i:int, r:int, c:int,cp:SPoint, np:SPoint, tp:SPoint;
			var centerX:Number,centerY:Number;
			var elements:Vector.<Block>=map.filter(Helper.filter);
			switch (t) {
				case 1 ://上,从上往下排查需要移动的元素
					Helper.d = 1;
					elements.sort(Helper.sortY);
					for(r = 0;r<elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							for(i = cp.y-1;i>0;i--){
								np = new SPoint(cp.x, i);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
						}
						tp = null;
					}
					break;
				case 2 ://下
					Helper.d = -1;
					elements.sort(Helper.sortY);
					for(r = 0;r<elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							for(i = cp.y+1;i <= level.y;i++){
								np = new SPoint(cp.x, i);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
						}
						tp = null;
					}
					break;
				case 3 ://左
					Helper.d = 1;
					elements.sort(Helper.sortX);
					for(r = 0;r<elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							for(i = cp.x - 1;i > 0;i--){
								np = new SPoint(i, cp.y);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
						}
						tp = null;
					}
					break;
				case 4 ://右
					Helper.d = -1;
					elements.sort(Helper.sortX);
					for(r = 0;r<elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							for(i = cp.x + 1;i <= level.x;i++){
								np = new SPoint(i, cp.y);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
						}
						tp = null;
					}
					break;
				case 5 ://中心
					centerX = (level.x + 1) * .5;
					centerY = (level.y + 1) * .5;
					Helper.d = 1;
					Helper.centerPoint = new SPoint(centerX, centerY);
					elements.sort(Helper.distanceCenter);
					
					for(r = 0;r<elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							np = Helper.getNearPoint(cp, map);
							while(np){
								tp = np.clone();
								np = Helper.getNearPoint(np, map);
							}
							if(tp){
								map[cp.index].move(tp);
							}
						}
						tp = null;
					}
					
					return;
				case 6 ://四散,同上
					centerX = (level.x + 1) * .5;
					centerY = (level.y + 1) * .5;
					Helper.d = -1;
					Helper.centerPoint = new SPoint(centerX, centerY);
					elements.sort(Helper.distanceCenter);
					
					for(r = 0;r<elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							np = Helper.getNearPoint(cp, map);
							while(np){
								tp = np.clone();
								np = Helper.getNearPoint(np, map);
							}
							if(tp){
								map[cp.index].move(tp);
							}
						}
						tp = null;
					}
					return;
				case 7 ://上下分离
					Helper.d = 1;
					elements.sort(Helper.sortY);
					centerY = level.y * .5;
					//上移
					for(r = 0; r < elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							if(cp.y > centerY){
								break;
							}
								
							for(i = cp.y-1;i>0;i--){
								np = new SPoint(cp.x, i);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
							tp = null;
						}
					}
					
					//下移
					for(c = elements.length-1; c >= r; c--){
						cp = elements[c].point;
						if(map[cp.index]){
							for(i = cp.y+1;i <= level.y;i++){
								np = new SPoint(cp.x, i);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
							tp = null;
						}
					}
					return;
				case 8 ://左右分离
					Helper.d = 1;
					elements.sort(Helper.sortX);
					centerX = level.x * .5;
					//左移
					for(r = 0; r < elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							if(cp.x > centerX){
								break;
							}
								
							for(i = cp.x-1;i>0;i--){
								np = new SPoint(i, cp.y);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
							tp = null;
						}
					}
					
					//右移
					for(c = elements.length-1; c >= r; c--){
						cp = elements[c].point;
						if(map[cp.index]){
							for(i = cp.x+1;i <= level.x;i++){
								np = new SPoint(i, cp.y);
								if(map[np.index]){
									break;
								}
								tp = np;
							}
							if(tp){
								map[cp.index].move(tp);
							}
							tp = null;
						}
					}
					return;
				case 9 ://上左下右
					Helper.d = 1;
					elements.sort(Helper.sortX);
					centerY = level.y * .5;
					//左移
					for(r = 0; r < elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							if(cp.y <= centerY){
								for(i = cp.x-1;i>0;i--){
									np = new SPoint(i, cp.y);
									if(map[np.index]){
										break;
									}
									tp = np;
								}
								if(tp){
									map[cp.index].move(tp);
								}
								tp = null;
							}
						}
					}
					
					//右移
					for(c = elements.length-1; c >= 0; c--){
						cp = elements[c].point;
						if(map[cp.index]){
							if(cp.y > centerY){
								for(i = cp.x+1;i <= level.x;i++){
									np = new SPoint(i, cp.y);
									if(map[np.index]){
										break;
									}
									tp = np;
								}
								if(tp){
									map[cp.index].move(tp);
								}
								tp = null;
							}
						}
					}
					return;
				case 10 ://左上右下
					Helper.d = 1;
					elements.sort(Helper.sortY);
					centerX = level.x * .5;
					//上移
					for(r = 0; r < elements.length; r++){
						cp = elements[r].point;
						if(map[cp.index]){
							if(cp.x <= centerX){
								for(i = cp.y-1;i>0;i--){
									np = new SPoint(cp.x, i);
									if(map[np.index]){
										break;
									}
									tp = np;
								}
								if(tp){
									map[cp.index].move(tp);
								}
								tp = null;
							}
						}
					}
					
					//下移
					for(c = elements.length-1; c >= 0; c--){
						cp = elements[c].point;
						if(map[cp.index]){
							if(cp.x > centerX){
								for(i = cp.y+1;i <= level.y;i++){
									np = new SPoint(cp.x, i);
									if(map[np.index]){
										break;
									}
									tp = np;
								}
								if(tp){
									map[cp.index].move(tp);
								}
								tp = null;
							}
						}
					}
					return;
				case 11 ://随机
					this.move( Math.ceil(Math.random()*10));
				default :
					return;
			}


		}
		public function alert(txt:String, cal:Function=null):void {
			if(cal === null){
				cal = this.enter;
			}
			//if(this.state == 1){
			//	pause();
			//}
			var msgBox:Sprite=new Sprite();
			var txtf:TextField=new TextField();
			txtf.defaultTextFormat = new TextFormat("微软雅黑",14,SkinConfig.btnTextColor);
			txtf.autoSize = TextFieldAutoSize.LEFT;
			txtf.text = txt;
			txtf.x = 15;
			txtf.y = 15;
			msgBox.addChild(txtf);
			msgBox.graphics.beginFill(0xffffff,SkinConfig.layerAlpha);
			msgBox.graphics.drawRoundRect(0,0,txtf.width + 30,txtf.height+30,5,5);
			msgBox.graphics.endFill();
			msgBox.graphics.beginFill(SkinConfig.btnColor,1);
			msgBox.graphics.drawRoundRect(5,5,txtf.width + 20,txtf.height+20,5,5);
			msgBox.graphics.endFill();
			msgBox.buttonMode = true;
			msgBox.addEventListener(MouseEvent.CLICK, hidestep);
			msgBox.addEventListener(Event.REMOVED_FROM_STAGE,cal);
			msgBox.mouseChildren = false;
			msgBox.x = (mainWidth-msgBox.width)*.5;
			msgBox.y = (mainHeight-msgBox.height)*.5;
			addChild(msgBox);
		}
		
		public function hidestep(e:MouseEvent):void{
			var msgBox:Sprite=e.target as Sprite;
			msgBox.removeEventListener(MouseEvent.CLICK, hidestep);
			
			removeChild(msgBox);
			
		}
	}

}