import neko.Random;
typedef KV = {index: Int, val: Float}
class Data {
	static function main() {
		var rnd = new Random();
        var arr = [84, 87, 67, 84, 70];
		var ic = 0;
		var k = 0;
        var len = arr.length;
        var y,z;
		while (ic < len) {
            var i = ic++;
			z = k + arr[i];
			y = z + (z << 9);
			k = y ^ (y >> 5);
		}
		k = k + (k << 4);
		k = (k >> 10) ^ k;
		k = (k << 14) + k;
		rnd.setSeed(k);
		var rndval = rnd.float() * (rnd.float() + 1);
        var o = [];
        o.push({ val: rndval, index: 0});
		var ii = 1;
		while (ii < 768) {
            o.push({ val:  3.94381953783290329 * o[ii-1].val * (1 - o[ii-1].val), index: ii});
            ii+=1;
        }
        var r = [];
		for (item in o) {
            var tmp = new KVR();
            tmp.index = item.index;
            tmp.val = item.val;
            r.push(tmp);
        }
        r.sort(comp);
        trace(r);
	}
    static function comp(a:KVR, b:KVR) {
        if (a.val < b.val) {
            return -1;
        }
        else if (a.val > b.val) {
            return 1;
        }
        else {
            return 0;
        }
    }
}
class KVR {
   public var index:Int;
   public var val:Float;
    public function new() {
  }
   public function toString() {
      return index + ":" + val + " ";
   }
}
// import neko.Random;

// class Hello {
// 	static function main() {
// 		var rnd = new Random();

// 		// var arr = [70, 84, 87, 67, 84];
// 		var arr = [84, 87, 67, 84, 70];

// 		var i = 0;
// 		var k = 0;
// 		var len = arr.length;
// 		while (i < len) {
// 			var z = k + arr[i];
// 			var y = ((z << 9) + z);
// 			k = (y >> 5) ^ y;

// 			i += 1;
// 		}

// 		k = (k << 4) + k;
// 		k = (k >> 10) ^ k;
// 		k = (k << 14) + k;

// 		rnd.setSeed(k);

// 		var rndval = rnd.float() * (rnd.float() + 1);

// 		var o:Array<KV> = [];
// 		var tmp = new KV();
// 		tmp.val = rndval;
// 		tmp.index = 0;

// 		o.push(tmp);

// 		i = 0;
// 		while (i < 768) {
// 			i += 1;
// 			var a = new KV();
// 			var t = o[i - 1].val * 3.94381953783290329;
// 			a.val = (1 - o[i - 1].val) * t;
// 			a.index = i;
// 			o.push(a);
// 		}

// 		o.sort(comp);

// 		trace(o);
// 	}

// 	static function comp(a:KV, b:KV) {
// 		if (a.val < b.val) {
// 			return -1;
// 		} else if (a.val > b.val) {
// 			return 1;
// 		} else {
// 			return 0;
// 		}
// 	}
// }

// class KV {
// 	public var index:Int;
// 	public var val:Float;

// 	public function new() {}

// 	public function toString() {
// 		return index + ":" + val + " ";
// 	}
// }
