class Flock{
	ArrayList<Boid> BOIDS;
	boolean SCATTERED;
	PVector LEADER;

	Flock(int boids_length){
		this.BOIDS = new ArrayList<Boid>();
		this.LEADER = new PVector(0,0,0);
		for(int i=0; i<boids_length; i++) this.BOIDS.add(new Boid(this, new PVector(random(-width, width*2), random(-height, height*2))));
	}


	void update(){
		float
			rotation_speed = 0.03,
			wandering_speed = map(sq(sin(sin(TWO_PI+frameCount*.01))), 0, 1, 0, 0.002),
			radius_speed = map(sq(sin(cos(PI+frameCount*.01))), 0, 1, 0, 0.001);
		this.LEADER.x = (width*.5 + sin(wandering_speed*frameCount)*width*.1) + cos(rotation_speed*frameCount)*(width*.3 + cos(radius_speed*frameCount)*width*.1);
		this.LEADER.y = (height*.5 + cos(wandering_speed*frameCount)*height*.1) + sin(rotation_speed*frameCount)*(height*.3 + sin(radius_speed*frameCount)*height*.1);

		for(Boid b : this.BOIDS) b.update();
	}

	void clean(){
		if(this.BOIDS.size() > MAX_BOIDS_LENGTH)
			this.BOIDS.remove(0);
	}


	void draw(){
		for(Boid b : this.BOIDS){
			strokeWeight(10);
			stroke(255, 50);
			point(b.POSITION.x, b.POSITION.y);
			strokeWeight(1);
			stroke(255, 100);
			line(b.POSITION.x, b.POSITION.y, b.TRACE.x, b.TRACE.y);
		}
	}

	void draw_leader(){
		point(this.LEADER.x, this.LEADER.y, this.LEADER.z);
	}



	//------------------------------------------------------------
	// RULES

	PVector fly_towards_centre_of_masse(Boid t){
		PVector v = new PVector(0,0,0);
		for(Boid b : this.BOIDS)
			if(b!=t) v.add(b.POSITION);
		v.div(this.BOIDS.size()-1);
		return PVector.sub(v, t.POSITION).div(50);
	}

	PVector fly_towards_direction(Boid t, PVector dir){
		return dir;
	}

	PVector wander(Boid t){
		// WORK IN PROGRESS
		return PVector.sub(t.POSITION, PVector.div(t.POSITION, noise(t.POSITION.x, t.POSITION.y, t.POSITION.z))).div(100);
	}

	PVector avoid_neighbors(Boid t, float distance){
		PVector v = new PVector(0,0,0);
		for(Boid b : this.BOIDS)
			if(b!=t)
				if(PVector.dist(b.POSITION, t.POSITION) < distance)
					v = v.sub(PVector.sub(b.POSITION, t.POSITION));
		return v.div(5);
	}

	PVector avoid_object(Boid t, PVector object, float distance){
		PVector v = new PVector(0,0,0);
		if(PVector.dist(object, t.POSITION) < distance)
			v = v.sub(PVector.sub(object, t.POSITION));
		return v;
	}

	PVector avoid_objects(Boid t, PVector[] objects, float distance){
		PVector v = new PVector(0,0,0);
		for(PVector p : objects){
			if(PVector.dist(p, t.POSITION) < distance)
				v = v.sub(PVector.sub(p, t.POSITION));
		}
		return v;
	}

	PVector avoid_objects(Boid t, ArrayList<PVector> objects, float distance){
		PVector v = new PVector(0,0,0);
		for(PVector p : objects){
			if(PVector.dist(p, t.POSITION) < distance)
				v = v.sub(PVector.sub(p, t.POSITION));
		}
		return v;
	}

	PVector match_neighbors_velocity(Boid t){
		PVector v = new PVector(0,0,0);
		for(Boid b : this.BOIDS)
			if(b!=t) v.add(b.VELOCITY);
		v.div(this.BOIDS.size()-1);
		return PVector.sub(v, t.VELOCITY).div(2);
	}

	PVector tend_to_place(Boid t, PVector place_pos){
		return PVector.sub(place_pos, t.POSITION).div(100);
	}


	PVector tend_to_place_with_inertia(Boid t, PVector place_pos){
		return PVector.sub(place_pos.lerp(t.POSITION, -1), t.POSITION).div(100);
	}

	PVector bound_position(Boid t, Rectangle zone){
		PVector v = new PVector(0,0,0);
		if(t.POSITION.x < zone.x) v.x = 10;
		else if(t.POSITION.x > zone.x + zone.width) v.x = -10;

		if(t.POSITION.y < zone.y) v.y = 10;
		else if(t.POSITION.y > zone.y + zone.height) v.y = -10;
		return v;
	}

}