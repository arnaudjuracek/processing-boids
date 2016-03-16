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
			this.FILTER.setFrequency(360.0);
 			this.FILTER.setMinCutoff(0.05);
  			this.FILTER.setBeta(2.0);
  			this.FILTER.setDerivateCutoff(0.9);

		this.POSITION = position;
		this.TRACE = new PVector(0,0);
		this.VELOCITY = new PVector(0,0);
		this.MAX_VELOCITY = new PVector(1,1);
		this.SPEED = random(.5,1.5);
		this.DISTANCE = random(.75, 1.25)*AVOIDING_DISTANCE;
		this.RND = random(.75,1);
	}


	void update(){
		// DEFINE RULES
		PVector[] rules = {
			this.FLOCK.fly_towards_centre_of_masse(this).mult(keyPressed && key == 's' ? -10 : 1),
			this.FLOCK.avoid_neighbors(this, this.DISTANCE),
			this.FLOCK.avoid_object(this, new PVector(mouseX, mouseY), this.RND*50),
			this.FLOCK.avoid_objects(this, WALLS, 20),
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