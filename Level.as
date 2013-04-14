package  {
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	public class Level extends Object {
		
		public var level:int=0;
		public var length:int=0;
		
		public var stage:String="";
		public var title:String="";
		
		public var x:int=0;	//横向数目
		public var y:int=0;	//纵向数目
		public var shapes:int=0;	//调用的图形数
		
		public var type:int=0;	//移动规则
		
		public var tip:int=0;
		public var sort:int=0;
		public var time:int=0;
		
		public var config:XMLList=null;
		
		private var Link:LinkGame=null;
		
		private var levelBox:Sprite;
		private var levelButtons:Vector.<LButton>;
		private var closeBtn:LButton;
		

		public function Level(link:LinkGame) {
			Link = link;
			initLevels();
		}
		
		public function initLevels():void{
			config = Link.globalConfig.levels.level;
			if(Link.config.levels.length()){
				config = Link.config.levels.level;
			}
			
			length = config.length();
			level=0;
			next(level);
		}
		
		public function next(lvl:int=-2):void
		{
			if(lvl == -2){
				lvl = level + 1;
			}
			if(lvl < 0)lvl = 0;
			if(lvl >= length)return;
			level = lvl;
			x = int(config[level].x);
			y = int(config[level].y);
			shapes = Math.ceil(Block.number * config[level].shapes * .1);
			type = int(config[level].type);
			tip = int(config[level].tip);
			sort = int(config[level].sort);
			time = int(config[level].time);
			stage = String(config[level].stage);
			title = String(config[level].title);
		}
		
		public function showSelect(allows:Array):void{
			var i:int;
			if(!levelBox){
				levelBox = new Sprite();
				levelButtons = new Vector.<LButton>();
				for(i = 0; i< config.length(); i++){
					levelButtons.push(levelButton(config[i], i));
					levelButtons[i].data.id = i;
					levelBox.addChild(levelButtons[i]);
				}
				closeBtn = new LButton('X',cancelLevel);
				closeBtn.setPadding(3,0);
				closeBtn.textFormat = new TextFormat('Arial',10,SkinConfig.btnTextColor);
			}
			closeBtn.setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
			levelBox.graphics.clear();
			for(i=0;i<levelButtons.length;i++){
				levelButtons[i].setColor(SkinConfig.btnColor,SkinConfig.btnTextColor);
				levelButtons[i].addEventListener(MouseEvent.CLICK,enterLevel);
				levelButtons[i].x = (i%2==1)?220:20;
				levelButtons[i].y = Math.floor(i * .5) * 30 + 20;
			}
			levelBox.graphics.beginFill(SkinConfig.layerColor,SkinConfig.layerAlpha);
			levelBox.graphics.drawRoundRect(0,0,levelBox.width+40,levelBox.height+40,5);
			levelBox.graphics.endFill();
			levelBox.addChild(closeBtn);
			closeBtn.x = levelBox.width - 25;
			closeBtn.y = 5;
			if(Link.state==1)Link.pause();
			Link.parent.addChild(levelBox);
			positionLevelBox();
			Link.stage.addEventListener(Event.RESIZE,positionLevelBox);
		}
		
		public function positionLevelBox(e:Event=null):void{
			levelBox.x = (Link.stage.stageWidth - levelBox.width)*.5;
			levelBox.y = (Link.stage.stageHeight - levelBox.height)*.5;
		}
		
		public function levelButton(lvl:XML, i:int):LButton{
			var btn:LButton = new LButton(lvl.stage +': ' + lvl.title);
			return btn;
		}
		
		public function enterLevel(e:MouseEvent):void{
			var btn:LButton = e.target as LButton;
			Link.reset();
			level=btn.data.id;
			hideLevelBox();
			next(level);
			Link.box.visible = true;
			Link.startBtn.text=Lang.pause;
			Link.enter();
		}
		
		public function cancelLevel(e:MouseEvent):void{
			hideLevelBox();
			if(Link.state==2)Link.start();
		}
		
		public function hideLevelBox(){
			levelBox.removeChild(closeBtn);
			for(var i:int=0;i<levelButtons.length;i++){
				if(levelButtons[i].hasEventListener(MouseEvent.CLICK)){
					levelButtons[i].removeEventListener(MouseEvent.CLICK,enterLevel);
				}
			}
			Link.parent.removeChild(levelBox);
		}
		
		public function reset():void
		{
			level = 0;
			next(level);
		}

	}
	
}
