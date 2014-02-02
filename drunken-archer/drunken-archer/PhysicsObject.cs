using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;

namespace DrunkenArcher {
    class PhysicsObject {
        protected static Game game;
        
        public float x = 0;
        public float y = 0;

        public float vx = 0;
        public float vy = 0;

        public float ax = 0;
        public float ay = 0;

        public float tx = 0;
        public float ty = 0;

        public float gravity = 0.0f;
        protected Vector2 _camera_weight = new Vector2(1.0f);

        protected Rectangle bounding_box = new Rectangle(0, 0, 0, 0);

        public void camera_weight(float x, float y) {
            _camera_weight.X = x;
            _camera_weight.Y = y;
        }

        private string group = "";

        public void collision_group(string group) {
            //remove ourselves from an old group, if needed
            if (collision_groups.ContainsKey(group)) {
                collision_groups[group].Remove(this);
            }

            this.group = group;
            if (!collision_groups.ContainsKey(group)) {
                collision_groups[group] = new List<PhysicsObject>();
            }
            collision_groups[group].Add(this);
        }

        private struct CollisionRequest {
            public string target_group;
            public bool response;
        };

        List<CollisionRequest> requests = new List<CollisionRequest>();
        static Dictionary<string, List<PhysicsObject>> collision_groups = new Dictionary<string, List<PhysicsObject>>();

        public bool intersects(Rectangle box) {
            return this.bounding_box.Intersects(box);
        }


        //At the moment, this collision response is based on the following article:
        //http://go.colorize.net/xna/2d_collision_response_xna/
        //with heavy modification to make it work within this framework

        private void process_collision() {
            List<PhysicsObject> collisions = new List<PhysicsObject>();
            foreach (var request in requests) {
                //Proceed only if some objects for the target group actually exist
                if (collision_groups.ContainsKey(request.target_group)) {
                    collisions.Clear();
                    foreach (var target in collision_groups[request.target_group]) {
                        if (target.intersects(this.bounding_box)) {
                            collisions.Add(target);
                        }
                    }

                    if (request.response) {
                        //Respond to the collision; move ourself so we're not overlapping the target objects
                        //TODO: This
                    }

                    //notify colliding objects of their collisions
                }


                
            }
        }

        public void engine_update() {
            //process physics calculations
            //velocity
            x += vx;
            y += vy;

            //acceleration
            vx += ax;
            vy += ay;

            //gravity
            vy += gravity;

            //terminal velocity (aka insanity limiters)
            if (tx > 0) {
                if (vx > tx) {
                    vx = tx;
                }
                if (vx < -tx) {
                    vx = -tx;
                }
            }
            if (ty > 0) {
                if (vy > ty) {
                    vy = ty;
                }
                if (vy < -ty) {
                    vy = -ty;
                }
            }

            //handle collision
            process_collision();
        }
    }
}
