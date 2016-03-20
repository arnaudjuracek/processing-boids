![preview](preview.gif?raw=true "preview")

---
BOIDS study, based on BOIDS pseudo-code http://www.vergenet.net/~conrad/boids/pseudocode.html

##Source code
+ `(int) MAX_SPEED` : the speed each BOID is limited to.
+ `(int) AVOIDING_DISTANCE` : the distance from which each BOID tend to avoid its neighbor.
+ `(int) MAX_BOIDS_LENGTH`: kill first BOIDS when this limit is reached.

See `(PVector[]) Boid.update().rules` for all `PVector` based velocity rules.

##Controls

+ Mouse drag to create walls.
+ <kbd>a</kbd> to spawn 10 BOIDS under the cursor.
+ <kbd>space</kbd> to spawn 10 BOIDS with random position.
+ <kbd>r</kbd> to generate a new full flock (specified by `(int) MAX_BOIDS_LENGTH`).
+ <kbd>o</kbd> to draw a random circle wall.
+ <kbd>l</kbd> to draw a random line wall.
+ <kbd>c</kbd> to clear all drawn walls.

---
Arnaud Juracek, GNU GENERAL PUBLIC LICENSE Version 2, June 1991
