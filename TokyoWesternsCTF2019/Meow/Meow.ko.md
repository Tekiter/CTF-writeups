# Meow

### category: Reversing


## 문제

문제 파일로는 Meow.n 파일과 `flag_enc.png` 파일이 주어졌다.

![image_encrypted](image/input.png)



## 풀이

Meow.n 파일은 [Neko VM](https://nekovm.org) 에서 실행 가능한 바이트코드 파일이다. 또한 이 바이트코드는 [Haxe](https://haxe.org/)로 작성되어, neko로 컴파일된 파일이다.
`neko Meow.n` 명령으로 이 파일을 실행해 보면 다음과 같은 문자열이 출력된다:
`Usage: meow INPUT OUTPUT`.

이 바이트코드를 해석하기 위해 검색을 해본 결과, Neko VM의 컴파일러인 nekoc 의 -d 옵션으로 바이트코드를 읽을 수 있는 형태로 바꿀 수 있다는 것을 알아냈다.

`nekoc -d Meow.txt` 명령어로 `Meow.dump` 파일을 얻었다.

```
  global 97 : function 1997 nargs 2
  global 98 : function 2047 nargs 1
  global 99 : var 
  global 100 : string "Usage: meow INPUT OUTPUT"
  global 101 : var 
  global 102 : float 3.94381953783290329
  global 103 : function 2111 nargs 2
  global 104 : var 
  global 105 : function 2136 nargs 0
```
`Meow.dump`의 105번째 줄을 보면 실행시의 문자열이 global 100에 등록되어 있다.


```
000C8A   2145    AccGlobal 100
000C8C   2146    Push
000C8D   2147    AccGlobal 37
000C8F   2148    Push
000C90   2149    AccField new
000C92   2150    ObjCall 1
000C94   2151    Push
000C95   2152    AccGlobal 99
000C97   2153    Push
000C98   2154    AccField println
000C9A   2155    ObjCall 1
```
2145번 코드를 보면 AccGlobal 100 명령으로 문자열을 가져오고 이를 println 명령으로 출력하는 루틴으로 추정할 수 있다. 따라서 이 코드가 있는 부분이 main이다.

```
000C7B   2136    AccGlobal 99
000C7D   2137    Push
000C7E   2138    AccField args
000C80   2139    ObjCall 0
000C82   2140    AccField length
000C84   2141    Push
000C85   2142    AccInt 2
000C87   2143    Lt
000C88   2144    JumpIfNot 2162 
```
이 부분이 main의 시작이다.

***

이후 main 부분을 해석하여 다음 의사코드를 얻었다.

```
function func(a, b) {
    if a.val < b.val {
        return -1;
    }
    else if a.val > b.val {
        return 1;
    }
    else {
        return 0;
    }
}


if args().length < 2 {
   println(new string("Usage: meow INPUT OUTPUT"))
   exit(1)
}

img = readPixels(args()[0])

if img.width != 768 or img.height != 768 {
   exit(1)
}

rnd = new Random()


i = 0
k = 0

while (i < arr.length) {
   
   z = k+arr[i]
   y = ((z << 9) + z)

   k = (y >> 5) ^ y

   i += 1
}

k = (k << 4) + k
k = (k << 10) ^ k
k = (k << 14) + k

rnd.setSeed(k)

rndval = (rnd.float() + 1) * rnd.float()


o = new array()
o101 = new(obj101)
o101.val = ranval
o101.index = 0
o.push(o101)



i = 1
while (i < 768) {
   a = new(obj101)
   t = o[i-1] * 3.94381953783290329   
   a.val = (1 - o[i-1].val) * t
   a.index = i
   o.push(a)
   i+=1
}

o.sort(func)

k = 0
while (i < img.height) {
   
   while (j < img.width) {

      pos = o[k].index % img.width
      px1 = img.get_pixel(pos, i)
      px2 = img.get_pixel(j, i)
      img.set_pixel(pos, i, px2)
      img.set_pixel(j, i, px1)
      
      k = (k+1)%768

      j+=1
   }

   i+=1
}


k = 0
while (i < img.height) {
   while (j < img.width) {
      t = o[k].val
      vv = int(t*13337)
      px3 = img.get_pixel(j, img.height)
      b1 = ((vv & 255) << 8) | (vv & 255)
      b2 = (((vv & 255) << 16) | b1) ^ px3
      img.set_pixel(j, i, b2)
      k = (k+1)%100 
      j+=1
   }
   i+=1
}

writePixels(args()[1], img)
```


명령어의 기능은 Neko VM 인터프리터 부분 소스를 참고했다.
* https://github.com/HaxeFoundation/neko/blob/master/vm/interp.c#L613


이 의사코드에 따르면 먼저 랜덤하게 값들을 생성하고 o배열에 넣은 다음, 이 값들을 기반으로 이미지 인코딩을 진행한다. 그런데, 여기서 랜덤 시드는 변하는 값이 아닌 고정값이다. 따라서 o배열은 항상 고정이므로 [Data.hx](Data.hx) 파일을 작성해 neko로 컴파일하고 실행하여 o배열을 얻어냈다.

***

이미지 인코딩 로직은 크게 2단계로 나뉜다.

```
k = 0
while (i < img.height) {
   
   while (j < img.width) {

      pos = o[k].index % img.width
      px1 = img.get_pixel(pos, i)
      px2 = img.get_pixel(j, i)
      img.set_pixel(pos, i, px2)
      img.set_pixel(j, i, px1)
      
      k = (k+1)%768

      j+=1
   }

   i+=1
}
```
첫번째 단계는 이미지의 모든 픽셀을 순회하면서, 특정 위치의 픽셀을 다른 위치의 픽셀과 교환한다. 단순히 순서에 따라 픽셀 교환만 하기 때문에, 교환 순서만 반대로 해주면 첫번째 단계를 디코딩 할 수 있다.


```
k = 0
while (i < img.height) {
   while (j < img.width) {
      t = o[k].val
      vv = int(t*13337)
      px3 = img.get_pixel(j, img.height)
      b1 = ((vv & 255) << 8) | (vv & 255)
      b2 = (((vv & 255) << 16) | b1) ^ px3
      img.set_pixel(j, i, b2)
      k = (k+1)%100 
      j+=1
   }
   i+=1
}
```
두번째 단계는 모든 픽셀을 순회하면서, 각 위치의 픽셀의 RGB값을 o[k] 값과 xor하여 색을 변조시킨다. o[k] 값에 따라 xor키인 vv가 계속 달라지지만, 특정 픽셀에서 사용되는 vv값은 항상 같기 때문에 (o 배열이 항상 같으므로), 인코딩 시의 vv 배열을 기록해 두면 쉽게 디코딩 할 수 있다.


이 모든 정보를 조합하여 디코더를 짜면 다음과 같다.

[go.py](go.py)
```
import sys
from PIL import Image

def pixel2hex(px):
    return int('{:02x}{:02x}{:02x}'.format(px[0], px[1], px[2]), 16)

def hex2pixel(hx):
    return (hx >> 16, (hx & 0xff00) >> 8,hx & 0xff, 255)

class KV():
    def __init__(self, idx, val):
        self.index = idx
        self.val = val

    def __repr__(self):
        return "%d => %f" % (self.index, self.val)
    
ori = [ ... ]
o = [KV(k,v) for k, v in ori.items()]
vt = [ ... ]


frompath = "input.png"
topath = "output.png"
imgsize = 768

img = Image.open(frompath)
pixels = img.load()

def enc():
    k = 0
    for i in range(imgsize):
        for j in range(imgsize):
            pos = o[k].index % imgsize
            px1 = pixels[pos, i]
            px2 = pixels[j, i]
            pixels[pos, i] = px2
            pixels[j, i] = px1
            assert(k == j)
            k = (k+1)%768
    
    k = 0
    for i in range(imgsize):
        for j in range(imgsize):
            
            t = o[k].val
            vv = int(t*13337)


            px3 = pixel2hex(pixels[j, i])
            b1 = ((vv & 255) << 8) | (vv & 255)
            b2 = (((vv & 255) << 16) | b1) ^ px3
            pixels[j,i] = hex2pixel(b2)
            k = (k+1)%100

    img.save(topath)
    print("SAVED " + topath)



def dec():
    for vv, i, j in vt:
        px = pixel2hex(pixels[j,i])
        key = ((vv & 255) << 8) | (vv & 255) | ((vv & 255) << 16)
        pixels[j,i] = hex2pixel(px ^ key)


    for i in reversed(range(imgsize)):
        for j in reversed(range(imgsize)):

            pos = o[j].index % imgsize
            px1 = pixels[j, i]
            px2 = pixels[pos, i]
            pixels[j, i] = px2
            pixels[pos, i] = px1


    
    
    img.save(topath)
    print("SAVED " + topath)
        

dec()
```


## Flag
TWCTF{Ny4nNyanNy4n_M30wMe0wMeow}

![image_decrypted](image/output.png)
