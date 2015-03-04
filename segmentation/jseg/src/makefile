CC=gcc
CFLAGS = -O3 -Ijpeg
# CFLAGS = -O2 -I/usr1.bizet/users/deng/Software/jpeg-6b
LIBS = -L. -ljpeg -lm

all: segdist
JPG = djpeg.o cjpeg.o
XVF = xvgif.o xvgifwr.o xvmisc.o xv24to8.o
SEGF = segment.o reggrow.o jfunc.o quan.o ioutil.o imgutil.o mathutil.o  memutil.o

segdist: main.o $(SEGF) $(XVF) $(JPG)
	$(CC) $(CFLAGS) -o segdist main.o $(SEGF) $(XVF) $(JPG) $(LIBS)
	cp segdist ..

main.o: main.c ioutil.c imgutil.c memutil.c segment.h
segment.o: segment.c ioutil.c imgutil.c memutil.c segment.h
reggrow.o: reggrow.c ioutil.c imgutil.c memutil.c segment.h
jfunc.o: jfunc.c ioutil.c imgutil.c memutil.c segment.h
quan.o: quan.c imgutil.c mathutil.c memutil.c
ioutil.o: ioutil.c 
imgutil.o: imgutil.c
mathutil.o: mathutil.c
memutil.o: memutil.c


