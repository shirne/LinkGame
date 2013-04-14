package  {
	import flash.geom.ColorTransform;
	
	public class Helper {
		
		public static var centerPoint:SPoint=new SPoint(0,0);
		
		public static var level:Level;
		
		public static var d:int = 1;

		public function Helper() {
			
		}
		
		//过滤掉空的元素位置
		public static function filter(item:Block, index:int, vector:Vector.<Block>):Boolean{
			return item?true:false;
		}
		
		//y正向排序, d=-1负向排序
		public static function sortY(a:Block, b:Block):int{
			if(a.point.y > b.point.y){
				return 1 * d;
			}else if(a.point.y < b.point.y){
				return -1 * d;
			}else{
				return 0;
			}
		}
		
		//x正向排序, d=-1 负向排序
		public static function sortX(a:Block, b:Block):int{
			if(a.point.x > b.point.x){
				return 1 * d;
			}else if(a.point.x < b.point.x){
				return -1 * d;
			}else{
				return 0;
			}
		}
		
		//根据到中间的距离排序
		public static function distanceCenter(a:Block, b:Block):int{
			var rst=Math.abs(a.point.distance(centerPoint)) - Math.abs(b.point.distance(centerPoint));
			if(rst > 0){
				return 1 * d;
			}else if(rst < 0){
				return -1 * d;
			}else{
				return 0;
			}
		}
		
		//根据到中间的距离排序
		public static function distance(a:SPoint, b:SPoint):int{
			var rst=Math.abs(a.distance(centerPoint)) - Math.abs(b.distance(centerPoint));
			if(rst > 0){
				return 1 * d;
			}else if(rst < 0){
				return -1 * d;
			}else{
				return 0;
			}
		}
		
		public static function getNearPoint(p:SPoint, map:Vector.<Block>):SPoint{
			var px:SPoint=null,py:SPoint=null, x:Number, y:Number;
			if((p.x - centerPoint.x) * d > 0){
				x = p.x-1;
			}else{
				x = p.x+1;
			}
			if(x >0 && x <= level.x ){
				px = new SPoint(x, p.y);
				if(map[px.index] || p.x + x == centerPoint.x * 2){
					px = null;
				}
			}
			if((p.y - centerPoint.y) * d > 0){
				y = p.y-1;
			}else{
				y = p.y+1;
			}
			if(y >0 && y <= level.y ){
				py = new SPoint(p.x, y);
				if(map[py.index] || p.y + y == centerPoint.y * 2){
					py = null;
				}
			}
			if(px && py){
				return distance(px, py) * d > 0 ? px : py;
			}else{
				return px || py;
			}
			
		}
		
		public static function colorTrans(color:uint, plus:Number):uint{
			var ct:ColorTransform=new ColorTransform();
			ct.color = color;
			var nRed:Number, nBlue:Number, nGreen:Number;
			nRed = ct.redOffset * plus;
			nBlue = ct.blueOffset * plus;
			nGreen = ct.greenOffset * plus;
			if(nRed > 255)nRed = 255;
			if(nBlue > 255)nBlue = 255;
			if(nGreen > 255)nGreen = 255;
			ct.redOffset = nRed;
			ct.blueOffset = nBlue;
			ct.greenOffset = nGreen;
			return ct.color;
		}

	}
	
}
