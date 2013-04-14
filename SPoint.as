package  {
	
	public class SPoint {
		
		public var x:Number;
		public var y:Number;
		
		public static var column:Number=0;

		public function SPoint(x:Number = 0, y:Number = 0) {
			this.x = x;
			this.y = y;
		}
		
		public function get index():int{
			return (y -1) * column + x;
		}
		
		public function equal(p:SPoint):Boolean{
			return p.x==x && p.y==y;
		}
		
		public function offset(x:Number, y:Number):void{
			this.x += x;
			this.y += y;
		}
		
		public function distance(p:SPoint):Number{
			return Math.pow(Math.pow(x - p.x, 2)+Math.pow(y - p.y, 2), .5);
		}
		
		//根据某一中心点和x新点确定y点
		public function scaleX(x:Number, center:SPoint=null):void{
			if(!center){
				center = new SPoint(0,0);
			}
			this.y = Math.round((this.y - center.y) * (x - center.x)/(this.x - center.x) + center.y);
			this.x = x;
		}
		//类上
		public function scaleY(y:Number, center:SPoint=null):void{
			if(!center){
				center = new SPoint(0,0);
			}
			this.x = Math.round((this.x - center.x) * (y - center.y)/(this.y - center.y) + center.x);
			this.y = y;
		}
		
		public function clone():SPoint{
			return new SPoint(x, y);
		}
		
		public function toString():String{
			return "[x:"+ x +", y:"+ y +" ]"
		}

	}
	
}
