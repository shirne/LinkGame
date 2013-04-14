/**************\
	元素原型
\**************/

package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Bitmap;
	import com.greensock.TweenNano;
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.display.Shape;

	public class Block extends Sprite {
		
		public var type:int=0;
		
		public var Link:LinkGame=null;
		
		public var point:SPoint;
		
		public var regPoint:Vector.<Number>;
		public static var maxX:Number;
		public static var maxY:Number;
		
		public static var dir:String="";
		public static var file:String="";
		public static var number:int=0;
		public static var activeColor:uint=0xffaa00;
		public static var radius:Number=5;
		
		public static var filter:GlowFilter;
		
		public static var BitMaps:Vector.<BitmapData>;
				
		private var baseNum:int=2;
		private var isDeleted:Boolean=false;
		private var isDrag:Boolean=false;

		public function Block(link, zx, zy, tp) {
			
			Link = link;
			
			point = new SPoint(zx, zy);
			type = tp;
			
			x=(point.x-1)* Link.size[0];
			y=(point.y-1)* Link.size[1];
			setStyle();
			
			regPoint=new Vector.<Number>(2,true);
			
			buttonMode=true;
			this.addEventListener(Event.ADDED_TO_STAGE,initialize);
		}
		
		public function initialize(e:Event=null):void{
			this.removeEventListener(Event.ADDED_TO_STAGE,initialize);

			
			this.addEventListener(MouseEvent.CLICK,clickHandle);
			this.addEventListener(MouseEvent.MOUSE_DOWN,dragHandle);
			this.addEventListener(MouseEvent.MOUSE_OVER,addFilter);
			this.addEventListener(MouseEvent.MOUSE_OUT,removeFilter);
			this.addEventListener(Event.REMOVED_FROM_STAGE,removed);
		}
		
		public function dragHandle(e:MouseEvent):void{
			regPoint[0]=e.stageX;
			regPoint[1]=e.stageY;
			this.alpha = .6;
			Link.box.setChildIndex(this,Link.box.numChildren-1);
			Link.addEventListener(MouseEvent.MOUSE_MOVE, moveHandle);
			Link.addEventListener(MouseEvent.MOUSE_UP, upHandle);
			Link.addEventListener(MouseEvent.MOUSE_OUT, upHandle);
		}
		
		public function moveHandle(e:MouseEvent):void{
			var px:Number = (this.point.x-1) * Link.size[0] +( e.stageX - regPoint[0]) / Link.box.scaleX / Link.scaleX;
			var py:Number = (this.point.y-1) * Link.size[1] +( e.stageY - regPoint[1]) / Link.box.scaleY / Link.scaleY;
			if(px < 0)px = 0;
			if(px > maxX)px = maxX;
			if(py < 0)py = 0;
			if(py > maxY)py = maxY;
			this.x = px;
			this.y = py;
		}
		
		public function back(speed:Number=.4):void{
			var tn:TweenNano;
			tn=TweenNano.to(this,.3,{x:(this.point.x-1) * Link.size[0],y:(this.point.y-1) * Link.size[1],alpha:1,onComplete:function(){
							tn.kill();
						}});
		}
		
		public function upHandle(e:MouseEvent):void{
			Link.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandle);
			Link.removeEventListener(MouseEvent.MOUSE_UP, upHandle);
			Link.removeEventListener(MouseEvent.MOUSE_OUT, upHandle);
			var target=Link.find(this.x, this.y);
			if(target !== this){
				isDrag = true;
				if(Link.prev){
					Link.prev.active();
				}
				Link.prev=this;
				Link.dragLink(target);
			}else{
				back(.05);
			}
		}
		
		public static function initArg(shape:XML):void{
			Block.dir = shape.folder + '/';
			Block.file = shape.file;
			Block.number = int(shape.number);
			if(shape.radius.length())Block.radius = int(shape.radius);
			if(shape.activeColor.length())Block.activeColor = int(shape.activeColor);
			
			Block.filter = new GlowFilter(activeColor);
		}
		
		private function addFilter(e:MouseEvent):void{
			this.filters = [Block.filter];
		}
		
		private function removeFilter(e:MouseEvent):void{
			e.stopPropagation();
			this.filters = null;
		}
		
		public function clickHandle(e:MouseEvent=null):void{
			if(isDrag){
				isDrag=false;
				active();
				return;
			}
			if(Link.prev && Link.prev!==this){
				Link.link(this);
			}else{
				Link.sound.play(SoundManager.Click);
				active();
			}
		}
		
		public function setStyle() {
			var b:Block=this,oy:Number=this.y;
			var tn:TweenNano=TweenNano.to(this,.15,{scaleY:0,y:oy+Link.size[1]*.5,onComplete:function(){
				while(numChildren>0){
					removeChildAt(0);
				}
				var bm:Bitmap=new Bitmap(BitMaps[type-1]);
				bm.smoothing = true;
				bm.width = Link.size[0]-2;
				bm.height = Link.size[1]-2;
				bm.x = 1;
				bm.y = 1;
				
				addChild(bm);
				var bmk:Shape = new Shape();
				bmk.graphics.beginFill(0xffffff);
				bmk.graphics.drawRoundRect(0,0,bm.width,bm.height, radius);
				bmk.graphics.endFill();
				bmk.x = 1;
				bmk.y = 1;
				bm.mask = bmk;
				addChild(bmk);
				
				tn.kill();
				tn=TweenNano.to(b,.15,{scaleY:1,y:oy,onComplete:function(){
					tn.kill();
				}});
			}});
			
		}
		//移动元素
		public function move(p:SPoint) {
			Link.map[point.index]=null;
			
			this.point = p;
			Link.map[point.index]=this;
			
			var tn:TweenNano = TweenNano.to(this,.2,{y:(point.y-1)* Link.size[1],x:(point.x-1) * Link.size[0],onComplete:function(){
							  tn.kill();
							  }});
			
		}
		
		//设置激活或取消激活
		public function active() {
			while(this.numChildren>baseNum){
				this.removeChildAt(baseNum);
			}
			if (Link.prev===this) {
				Link.prev = null;
			} else {
				Link.prev = this;
				var s:Sprite=new Sprite();
				s.graphics.lineStyle(3,Block.activeColor);
				s.graphics.drawRoundRect(1,1,Link.size[0]-3,Link.size[1]-3, radius);
				this.addChild(s);
			}
		}
		
		public function showTip(){
			while(this.numChildren>baseNum){
				this.removeChildAt(baseNum);
			}
			var s:Sprite=new Sprite();
			s.graphics.lineStyle(3,Block.activeColor);
			s.graphics.drawRoundRect(1,1,Link.size[0]-3,Link.size[1]-3, radius);
			s.filters = [filter];
			this.addChild(s);
		}
		
		//移除,渐隐后从舞台移除
		public function hide() {
			if(isDeleted)return;
			this.removeEventListener(MouseEvent.CLICK,clickHandle);
			this.removeEventListener(MouseEvent.MOUSE_DOWN,dragHandle);
			this.removeEventListener(MouseEvent.MOUSE_OVER,addFilter);
			this.removeEventListener(MouseEvent.MOUSE_OUT,removeFilter);
			isDeleted=true;
			var self=this;
			var tn:TweenNano = TweenNano.to(this,.3,{alpha:0,scaleX:.3,scaleY:.3,x:x + Link.size[0]*.35,y:y + Link.size[1]*.35,onComplete:function(){
											tn.kill();
											Link.box.removeChild(self);
											}});
		}
		
		public function removed(e:Event=null):void{
			this.removeEventListener(Event.REMOVED_FROM_STAGE,removed);
		}
	}
}