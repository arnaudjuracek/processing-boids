import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.Rectangle; 
import java.util.Iterator; 
import signal.library.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class boids extends PApplet {

// SEE http://www.vergenet.net/~conrad/boids/pseudocode.html




int
	MAX_SPEED = 4,
	AVOIDING_DISTANCE = 20,
	MAX_BOIDS_LENGTH = 100;

PApplet THIS;
Flock flock;
ArrayList<PVector> LINE;
PVector cur, tcur, pcur;

public void setup(){
	THIS = this;

	
	background(20);

	flock = new Flock(MAX_BOIDS_LENGTH);
	LINE = new ArrayList<PVector>();
	cur = new PVector(mouseX, mouseY);

	// RANDOMIZE LEADER START POSITION
	frameCount = millis();
}


public void draw(){
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
	cur.add(new PVector(dcur.x*.2f, dcur.y*.2f));

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


public void mouseDragged(){ LINE.add(new PVector(cur.x, cur.y)); }
public void keyPressed(){
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
class Boid{
	Flock FLOCK;
	SignalFilter FILTER;
	PVector
		TRACE,
		POSITION,
		VELOCITY,
		MAX_VELOCITY;
	float SPEED, DISTANCE, RND;

	Boid(Flock parent_flock, PVector position){
		this.FLOCK = parent_flock;
		this.FILTER = new SignalFilter(THIS, 3);
			this.FILTER.setFrequency(360.0f);
 			this.FILTER.setMinCutoff(0.05f);
  			this.FILTER.setBeta(2.0f);
  			this.FILTER.setDerivateCutoff(0.9f);

		this.POSITION = position;
		this.TRACE = new PVector(0,0);
		this.VELOCITY = new PVector(0,0);
		this.MAX_VELOCITY = new PVector(1,1);
		this.SPEED = random(.5f,1.5f);
		this.DISTANCE = random(.75f, 1.25f)*AVOIDING_DISTANCE;
		this.RND = random(.75f,1);
	}


	public void update(){
		// DEFINE RULES
		PVector[] rules = {
			this.FLOCK.fly_towards_centre_of_masse(this).mult(keyPressed && key == 's' ? -10 : 1),
			this.FLOCK.avoid_neighbors(this, this.DISTANCE),
			this.FLOCK.avoid_object(this, new PVector(mouseX, mouseY), this.RND*50),
			this.FLOCK.avoid_objects(this, LINE, 20),
			this.FLOCK.match_neighbors_velocity(this).div(this.RND),
			// this.FLOCK.fly_towards_direction(this, new PVector(0, 1)),
			// this.FLOCK.wander(this),
			// this.FLOCK.tend_to_place(this, new PVector(mouseX, mouseY)),
			this.FLOCK.tend_to_place(this, this.FLOCK.LEADER),
			this.FLOCK.avoid_object(this, this.FLOCK.LEADER, 100*this.RND),
			this.FLOCK.bound_position(this, new Rectangle(20, 20, width-20, height-20))
		};

		// APPLY RULES
		for(PVector r : rules)
			this.VELOCITY.add(r);

		// LIMIT VELOCITY TO MAX_SPEED
		if(this.VELOCITY.mag() > MAX_SPEED)
			this.VELOCITY.div(this.VELOCITY.mag()).mult(MAX_SPEED);

		// APPLY BOID SPEED TO ITS VELOCITY
		this.VELOCITY.mult(this.SPEED);

		// FILTER
		if(abs(this.VELOCITY.x) > this.MAX_VELOCITY.x) this.MAX_VELOCITY.x = abs(this.VELOCITY.x);
		if(abs(this.VELOCITY.y) > this.MAX_VELOCITY.y) this.MAX_VELOCITY.y = abs(this.VELOCITY.y);
		this.VELOCITY = this.FILTER.filterCoord2D(this.VELOCITY, this.MAX_VELOCITY.x, this.MAX_VELOCITY.y);

		// APPLY VELOCTIY TO POSITION
		this.POSITION.add(this.VELOCITY);

		// CALC TRACE POSITION
		this.TRACE = PVector.sub(this.POSITION, this.VELOCITY).lerp(this.POSITION, -5);
		if(PVector.dist(this.POSITION, this.TRACE) > 50)
			this.TRACE = this.POSITION;
	}



}
class Flock{
	ArrayList<Boid> BOIDS;
	boolean SCATTERED;
	PVector LEADER;

	Flock(int boids_length){
		this.BOIDS = new ArrayList<Boid>();
		this.LEADER = new PVector(0,0,0);
		for(int i=0; i<boids_length; i++) this.BOIDS.add(new Boid(this, new PVector(random(-width, width*2), random(-height, height*2))));
	}


	public void update(){
		float
			rotation_speed = 0.03f,
			wandering_speed = map(sq(sin(sin(TWO_PI+frameCount*.01f))), 0, 1, 0, 0.002f),
			radius_speed = map(sq(sin(cos(PI+frameCount*.01f))), 0, 1, 0, 0.001f);
		this.LEADER.x = (width*.5f + sin(wandering_speed*frameCount)*width*.1f) + cos(rotation_speed*frameCount)*(width*.3f + cos(radius_speed*frameCount)*width*.1f);
		this.LEADER.y = (height*.5f + cos(wandering_speed*frameCount)*height*.1f) + sin(rotation_speed*frameCount)*(height*.3f + sin(radius_speed*frameCount)*height*.1f);

		for(Boid b : this.BOIDS) b.update();
	}

	public void clean(){
		if(this.BOIDS.size() > MAX_BOIDS_LENGTH)
			this.BOIDS.remove(0);
	}


	public void draw(){
		for(Boid b : this.BOIDS){
			strokeWeight(10);
			stroke(255, 50);
			point(b.POSITION.x, b.POSITION.y);
			strokeWeight(1);
			stroke(255, 100);
			line(b.POSITION.x, b.POSITION.y, b.TRACE.x, b.TRACE.y);
		}
	}

	public void draw_leader(){
		point(this.LEADER.x, this.LEADER.y, this.LEADER.z);
	}



	//------------------------------------------------------------
	// RULES

	public PVector fly_towards_centre_of_masse(Boid t){
		PVector v = new PVector(0,0,0);
		for(Boid b : this.BOIDS)
			if(b!=t) v.add(b.POSITION);
		v.div(this.BOIDS.size()-1);
		return PVector.sub(v, t.POSITION).div(50);
	}

	public PVector fly_towards_direction(Boid t, PVector dir){
		return dir;
	}

	public PVector wander(Boid t){
		// WORK IN PROGRESS
		return PVector.sub(t.POSITION, PVector.div(t.POSITION, noise(t.POSITION.x, t.POSITION.y, t.POSITION.z))).div(100);
	}

	public PVector avoid_neighbors(Boid t, float distance){
		PVector v = new PVector(0,0,0);
		for(Boid b : this.BOIDS)
			if(b!=t)
				if(PVector.dist(b.POSITION, t.POSITION) < distance)
					v = v.sub(PVector.sub(b.POSITION, t.POSITION));
		return v.div(5);
	}

	public PVector avoid_object(Boid t, PVector object, float distance){
		PVector v = new PVector(0,0,0);
		if(PVector.dist(object, t.POSITION) < distance)
			v = v.sub(PVector.sub(object, t.POSITION));
		return v;
	}

	public PVector avoid_objects(Boid t, PVector[] objects, float distance){
		PVector v = new PVector(0,0,0);
		for(PVector p : objects){
			if(PVector.dist(p, t.POSITION) < distance)
				v = v.sub(PVector.sub(p, t.POSITION));
		}
		return v;
	}

	public PVector avoid_objects(Boid t, ArrayList<PVector> objects, float distance){
		PVector v = new PVector(0,0,0);
		for(PVector p : objects){
			if(PVector.dist(p, t.POSITION) < distance)
				v = v.sub(PVector.sub(p, t.POSITION));
		}
		return v;
	}

	public PVector match_neighbors_velocity(Boid t){
		PVector v = new PVector(0,0,0);
		for(Boid b : this.BOIDS)
			if(b!=t) v.add(b.VELOCITY);
		v.div(this.BOIDS.size()-1);
		return PVector.sub(v, t.VELOCITY).div(2);
	}

	public PVector tend_to_place(Boid t, PVector place_pos){
		return PVector.sub(place_pos, t.POSITION).div(100);
	}


	public PVector tend_to_place_with_inertia(Boid t, PVector place_pos){
		return PVector.sub(place_pos.lerp(t.POSITION, -1), t.POSITION).div(100);
	}

	public PVector bound_position(Boid t, Rectangle zone){
		PVector v = new PVector(0,0,0);
		if(t.POSITION.x < zone.x) v.x = 10;
		else if(t.POSITION.x > zone.x + zone.width) v.x = -10;

		if(t.POSITION.y < zone.y) v.y = 10;
		else if(t.POSITION.y > zone.y + zone.height) v.y = -10;
		return v;
	}

}
  public void settings() { 	size(1200, 800, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "boids" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
