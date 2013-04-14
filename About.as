package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	public class About extends Sprite {
		
		public var helpXML:XML;
		
		private var header:Sprite;
		private var content:Sprite;
		private var contentMask:Shape;
		private var copyright:TextField;
		
		private var currentIndex:int=0;
		private var currentContentHeight:int=0;
		
		private var closeBtn:LButton;
		
		private var Link:LinkGame;
		
		private var textPadding:Number=20;
		
		public var inStage:Boolean=false;
		
		public function About(link:LinkGame,h:XML):void {
			
			Link = link;
			helpXML = h;
			
			this.addEventListener(Event.ADDED_TO_STAGE,firstInit);
			this.addEventListener(Event.REMOVED_FROM_STAGE,teminate);
		}
		
		private function firstInit(e:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE,firstInit);
			
			content=new Sprite();
			content.mouseChildren=false;
			
			header=new Sprite();
			for(var i:int=0; i< helpXML.item.length(); i++){
				
				header.addChild(createHead(helpXML.item[i], i));
				content.addChild(createContent(String(helpXML.item[i]),i));
			}
			header.y = textPadding;
			addChild(header);
			
			contentMask = new Shape();
			content.mask = contentMask;
			
			addChild(content);
			addChild(contentMask);
			
			closeBtn = new LButton('X',closeSelf);
			closeBtn.setPadding(3,0);
			closeBtn.textFormat = new TextFormat('Arial',10,0xffffff);
			addChild(closeBtn);
			
			copyright = new TextField();
			copyright.htmlText=Lang.about;
			addChild(copyright);
			
			initialize();
		}
		
		private function createHead(item:XML, i:int):Sprite{
			var head:Sprite=new Sprite();
			
			var headText:TextField = new TextField();
			headText.defaultTextFormat=new TextFormat("微软雅黑", 14, 0x333333,true);
			headText.autoSize=TextFieldAutoSize.LEFT;
			headText.text=item.@title;
			headText.x = 10;
			headText.y = 3;
			
			head.addChild(headText);
			head.buttonMode=true;
			head.mouseChildren=false;
			
			normalHead(head);
			
			head.addEventListener(MouseEvent.CLICK, active);
			
			return head;
		}
		
		private function createContent(cont:String, i:int):TextField{
			var textField:TextField = new TextField();
			textField.defaultTextFormat=new TextFormat("微软雅黑", 14, SkinConfig.layerTextColor);
			textField.autoSize=TextFieldAutoSize.LEFT;
			textField.wordWrap=true;
			textField.htmlText = cont;
			textField.y = 10;
			return textField;
		}
		
		private function active(e:MouseEvent=null):void{
			var s:Sprite;
			if(e){
				s = e.target as Sprite;
				for(var i:int=0; i< header.numChildren; i++){
					if(s === header.getChildAt(i)){
						if(currentIndex == i){
							return;
						}else{
							normalHead(header.getChildAt(currentIndex) as Sprite);
							content.getChildAt(currentIndex).visible=false;
							currentIndex = i;
						}
					}
				}
			}
			
			activeHead(header.getChildAt(currentIndex) as Sprite);
			content.getChildAt(currentIndex).visible=true;
			currentContentHeight = content.getChildAt(currentIndex).height;
			content.y = textPadding + header.height;
		}
		
		private function normalHead(h:Sprite):void{
			var tf:TextField=h.getChildAt(0) as TextField;
			h.graphics.beginFill(SkinConfig.layerColor);
			h.graphics.drawRect(0,0, tf.width + 20, tf.height + 6);
			h.graphics.endFill();
			tf.textColor = SkinConfig.layerTextColor;
		}
		private function activeHead(h:Sprite):void{
			var tf:TextField=h.getChildAt(0) as TextField;
			h.graphics.beginFill(SkinConfig.layerTextColor);
			h.graphics.drawRect(0,0, tf.width + 20, tf.height + 6);
			h.graphics.endFill();
			tf.textColor = SkinConfig.layerColor;
		}
		public function initialize(e:Event=null):void{
			if(e){
				this.removeEventListener(Event.ADDED_TO_STAGE,initialize);
			}
			
			inStage = true;

			content.addEventListener(MouseEvent.MOUSE_WHEEL,scrollContent);

			rerender();
			stage.addEventListener(Event.RESIZE,rerender);
		}
		
		public function scrollContent(e:MouseEvent):void{
			var oy=content.y;
			if(e.delta > 0){
				oy += 30;
			}else{
				oy -= 30;
			}
			if(oy < contentMask.height - currentContentHeight - textPadding){
				oy = contentMask.height - currentContentHeight - textPadding;
			}
			if(oy > textPadding + header.height ){
				oy = textPadding + header.height;
			}
			content.y = oy;
		}
		
		public function rerender(e:Event=null):void{
			var h:Number = stage.stageHeight * .8;
			var w:Number = Link.mainWidth * h * .8/Link.mainHeight;
			
			this.graphics.clear();
			this.graphics.beginFill(SkinConfig.layerColor,SkinConfig.layerAlpha);
			this.graphics.drawRoundRect(0,0,w,h,5);
			this.graphics.endFill();
			
			this.x = (stage.stageWidth - w)*.5;
			this.y = (stage.stageHeight - h)*.5;
			
			closeBtn.setColor(SkinConfig.btnColor, SkinConfig.btnTextColor);
			closeBtn.x = w - 30;
			closeBtn.y = 10;
			
			var left:int=0;
			var tf:TextField, tff:TextFormat;
			for(var i:int; i< header.numChildren; i++){
				header.getChildAt(i).x = left;
				left += header.getChildAt(i).width + 5;
				tf=content.getChildAt(i) as TextField;
				tf.visible=false;
				tf.width = w - textPadding * 2;
				tff = tf.defaultTextFormat;
				tff.color = SkinConfig.layerTextColor;
				tf.defaultTextFormat = tff;
			}
			active();
			
			content.x = textPadding;
			content.y = textPadding + header.height;
			
			
			contentMask.y = textPadding+header.height;
			contentMask.graphics.clear();
			contentMask.graphics.beginFill(0xffffff, .6);
			contentMask.graphics.drawRoundRect(0,0,w,h - 60 - header.height - textPadding,5);
			contentMask.graphics.endFill();
			
			header.x = (w - textPadding * 2 - header.width)*.5;
			
			copyright.y = h - textPadding * 2;
			copyright.x = (w - copyright.width)*.5;
		}
		
		public function closeSelf(e:MouseEvent):void{
			this.parent.removeChild(this);
		}
		
		public function teminate(e:Event):void{
			if(content.hasEventListener(MouseEvent.MOUSE_WHEEL)){
				content.removeEventListener(MouseEvent.MOUSE_WHEEL,scrollContent);
			}
			stage.removeEventListener(Event.RESIZE,rerender);
			inStage = false;
			this.addEventListener(Event.ADDED_TO_STAGE,initialize);
		}

	}
	
}
