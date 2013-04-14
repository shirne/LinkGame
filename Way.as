/**************\
路径原型
\**************/
package {
	import flash.display.Sprite;
	import com.greensock.TweenNano;
	import flash.display.Shape;

	public class Way {
		//连线粗细
		public static var lineWidth:int=2;
		
		//是否找到可以相连的两点
		public var finded:Boolean = false;
		//找到的提示点
		public var findedTip:Boolean = false;

		private var Link:LinkGame = null;
		
		//找到两点连接的路径
		private var path:Vector.<SPoint>;
		//找到能相连的两点
		public var point:Vector.<SPoint>=new Vector.<SPoint>(2,true);

		private var maxSide:int = 0;
		
		//是否进行过提示
		public var tip:Boolean = false;
		
		
		public function Way(link:LinkGame) {
			Link = link;
		}
		
		//检查该点是否系统找到的点一样
		public function isFinded(p1:SPoint,p2:SPoint):Boolean{
			if( ! findedTip){
				return false;
			}else{
				return ((point[0].equal(p1) && point[1].equal(p2))||
						(point[1].equal(p1) && point[0].equal(p2)));
			}
		}
		
		//检查两个点是否能连通
		public function init(p1:SPoint,p2:SPoint) {
			var i:int,j:int,k:int,line:int = 0;
			path = new Vector.<SPoint>();
			finded = false;
			point[0]=p1;
			point[1]=p2;

			var stepX:int = p1.x > p2.x ? -1 : 1,
			stepY:int = p1.y > p2.y ? -1 : 1;

			//内部横向,沿y排
			if (p1.y == p2.y) {
				for (k = p1.x; k * stepX < p2.x * stepX; k += stepX) {
					path.push(new SPoint(k, p1.y));
				}
				if (this.check()) {
					return this;
				}
			} else if (p1.x != p2.x) {
				for (i = p1.y; i*stepY <= p2.y*stepY; i += stepY) {
					for (j = p1.y; j * stepY < i * stepY; j += stepY) {
						path.push(new SPoint(p1.x,j));
					}
					for (k = p1.x; k * stepX < p2.x * stepX; k += stepX) {
						path.push(new SPoint(k, j));
					}
					for (; j*stepY < p2.y*stepY; j += stepY) {
						path.push(new SPoint(p2.x,j));
					}

					if (check()) {
						return this;
					}
				}
			}

			//内部纵向,沿x排
			if (p1.x == p2.x) {
				for (k = p1.y; k * stepY < p2.y * stepY; k += stepY) {
					path.push(new SPoint(p1.x, k));
				}
				if (check()) {
					return this;
				}
			} else if (p1.y != p2.y) {
				for (i=p1.x; i * stepX <= p2.x * stepX; i += stepX) {
					for (j = p1.x; j * stepX < i * stepX; j += stepX) {
						path.push(new SPoint(j, p1.y));
					}
					for (k = p1.y; k * stepY < p2.y * stepY; k += stepY) {
						path.push(new SPoint(j, k));
					}
					for (; j * stepX < p2.x * stepX; j += stepX) {
						path.push(new SPoint(j, p2.y));
					}

					if (this.check()) {
						return this;
					}
				}
			}

			//外部
			if (p1.x > p2.x) {
				maxSide = Math.max(p2.x,Link.level.x - p1.x + 1);
			} else {
				maxSide = Math.max(p1.x,Link.level.x - p2.x + 1);
			}
			if (p1.y > p2.y) {
				maxSide = Math.max(p2.y,Link.level.y - p1.y + 1,maxSide);
			} else {
				maxSide = Math.max(p1.y,Link.level.y - p2.y + 1,maxSide);

			}
			for ( i=1; i <= maxSide; i++) {
				//上
				line = Math.min(p1.y,p2.y) - i;
				if (line >= 0) {
					for (j = p1.y; j > line; j--) {
						path.push(new SPoint(p1.x, j));
					}
					for (k = p1.x; k * stepX < p2.x * stepX; k += stepX) {
						path.push(new SPoint(k, j));
					}
					for (; j < p2.y; j++) {
						path.push(new SPoint(p2.x, j));
					}

					if (this.check()) {
						return this;
					}
				}
				//下
				line = Math.max(p1.y,p2.y) + i;
				if (line <= Link.level.y+1) {
					for (j = p1.y; j < line; j++) {
						path.push(new SPoint(p1.x, j));
					}
					for (k = p1.x; k * stepX < p2.x * stepX; k += stepX) {
						path.push(new SPoint(k, j));
					}
					for (; j > p2.y; j--) {
						path.push(new SPoint(p2.x, j));
					}

					if (this.check()) {
						return this;
					}
				}
				//左
				line = Math.min(p1.x,p2.x) - i;
				if (line >= 0) {
					for (j = p1.x; j > line; j--) {
						path.push(new SPoint(j, p1.y));
					}
					for (k = p1.y; k * stepY < p2.y * stepY; k += stepY) {
						path.push(new SPoint(j, k));
					}
					for (; j < p2.x; j++) {
						path.push(new SPoint(j, p2.y));
					}

					if (this.check()) {
						return this;
					}
				}
				//右
				line = Math.max(p1.x,p2.x) + i;
				if (line <= Link.level.x+1) {
					for (j = p1.x; j < line; j++) {
						path.push(new SPoint(j, p1.y));
					}
					for (k = p1.y; k * stepY < p2.y * stepY; k += stepY) {
						path.push(new SPoint(j, k));
					}
					for (; j > p2.x; j--) {
						path.push(new SPoint(j, p2.y));
					}

					if (this.check()) {
						return this;
					}
				}
			}
			
			return this;
		}
		
		//检查路径是否能连通
		public function check() {
			for (var i:int = 1; i < path.length; i++) {
				if (path[i].x < 1 || path[i].y < 1 || 
				path[i].x > Link.level.x || path[i].y > Link.level.y) {
					continue;
				} else if (Link.map[path[i].index] ) {
					path.splice(0,path.length);
					return false;
				}
			}
			path.push(point[1]);
			finded = true;
			return true;
		}
		
		//显示路径
		public function show( ) {
			
			var line:Shape = new Shape();
			
			line.filters=[Block.filter];

			line.graphics.lineStyle(lineWidth,Block.activeColor);
			line.graphics.moveTo((this.path[0].x-.5)* Link.size[0],(this.path[0].y-.5)* Link.size[1]);
			for (var i:int=1; i< path.length; i++) {
				line.graphics.lineTo((this.path[i].x-.5)*Link.size[0],(this.path[i].y-.5)*Link.size[1]);
			}
			Link.box.addChild(line);
			
			var tn:TweenNano = TweenNano.to( line, .4,{alpha:0,onComplete:function(){
				Link.box.removeChild(line);
				tn.kill();
			}}	);
		}

		//检查是否有可连接路径
		public function find() {
			//先检查之前搜索到的路径是否可用
			if(Link.finded){
				this.init(Link.finded[0].point,Link.finded[1].point);
				findedTip = finded
				if(findedTip){
					return;
				}else{
					Link.finded = null;
				}
			}
			
			var i:int,j:int;
			for ( i=1; i<Link.map.length; i++) {
				if (Link.map[i]) {
					for ( j=i+1; j<Link.map.length; j++) {
						if (Link.map[j] && Link.map[i].type == Link.map[j].type) {
							this.init(Link.map[i].point,Link.map[j].point);
							findedTip = finded
							if (findedTip) {
								Link.finded = [Link.map[i],Link.map[j]];
								return;
							}
						}
					}
				}
			}
			Link.finded = null;
			if (Link.counter > 0) {
				Link.timing.stop();
				if (Link.user.sorttime <= 0) {
					Link.sound.play(SoundManager.Lose);
					Link.alert(Lang.noActionOver(Link.user.score,Link.timing.time),Link.reset);
				} else {
					Link.alert(Lang.noActionReset,Link.resort);
				}
			}
		}

	}

}