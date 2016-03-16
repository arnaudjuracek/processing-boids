// SEE http://www.vergenet.net/~conrad/boids/pseudocode.html
import java.awt.Rectangle;
import java.util.Iterator;
import signal.library.*;

int
	MAX_SPEED = 4,
	AVOIDING_DISTANCE = 20,
	MAX_BOIDS_LENGTH = 100;

PApplet THIS;
Flock flock;
ArrayList<PVector> LINE;
PVector cur, tcur, pcur;

void setup(){
	THIS = this;

	size(1200, 800, P2D);
	background(20);

	flock = new Flock(MAX_BOIDS_LENGTH);
	LINE = new ArrayList<PVector>();
	cur = new PVector(mouseX, mouseY);

	// RANDOMIZE LEADER START POSITION
	frameCount = millis();
}


void draw(){
	// background(0);
	fill(20, 45); noStroke(); rect(0,0,width,height);
	flock.update();

	// FLOCK
	flock.draw();

	// LEADER
	stroke(198, 16, 96); strokeWeight(15);
	flock.draw_leader();

	// CURSOR
	tcur = new PVector(mouseX, mouseY);
	PVector dcur = PVector.sub(tcur,cur);
	cur.add(new PVector(dcur.x*.2, dcur.y*.2));

	// WALLS
	stroke(63, 89, 224, 10); strokeWeight(20);
	for(PVector p : LINE) point(p.x, p.y);

	// LEADER DESTRUCTS WALL
	Iterator<PVector> iter = LINE.iterator();
	while(iter.hasNext()){
		PVector p = iter.next();
		if(flock.LEADER.dist(p) < 30) iter.remove();
	}
}


void mouseDragged(){ LINE.add(new PVector(cur.x, cur.y)); }
void keyPressed(){
	if(key == 'a'){
		flock.BOIDS.add(new Boid(flock, new PVector(mouseX, mouseY)));
		flock.clean();
	}
	if(key == ' ') for(int i=0; i<10; i++) flock.BOIDS.add(new Boid(flock, new PVector(random(-width,width), random(-height, height))));
	if(key == 'r') flock = new Flock(MAX_BOIDS_LENGTH);
	if(key == 'o'){
		float
			r = random(height)/2,
			x = constrain(random(width), r, width - r),
			y = constrain(random(height), r, height - r),
			c = 2*PI*r;
		for(int a=0; a<c; a+=5) LINE.add(new PVector(x + sin(a)*r, y + cos(a)*r));
	}
	if(key == 'l'){
		float
			x = random(width),
			y = random(height),
			tx = random(width),
			ty = random(height),
			d = dist(x,y,tx,ty);
		for(int i=0; i<d; i+=5) LINE.add(new PVector(lerp(x,tx,map(i,0,d,0,1)),lerp(y,ty,map(i,0,d,0,1))));
	}
	if(key == 'c') LINE.clear();
}