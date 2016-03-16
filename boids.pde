// SEE http://www.vergenet.net/~conrad/boids/pseudocode.html
import java.awt.Rectangle;
import signal.library.*;

int
	MAX_SPEED = 4,
	AVOIDING_DISTANCE = 20,
	MAX_BOIDS_LENGTH = 10;

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
	stroke(63, 89, 224, 10); strokeWeight(10);
	for(PVector p : LINE) point(p.x, p.y);
}


void mouseDragged(){ LINE.add(new PVector(cur.x, cur.y)); }
void keyPressed(){
	if(key == 'a'){
		flock.BOIDS.add(new Boid(flock, new PVector(random(-width,width), random(-height, height))));
		flock.clean();
	}
	if(key == ' ') for(int i=0; i<10; i++) flock.BOIDS.add(new Boid(flock, new PVector(random(-width,width), random(-height, height))));
	if(key == 'r') flock = new Flock(MAX_BOIDS_LENGTH);
	if(key == 'c') LINE.clear();
}