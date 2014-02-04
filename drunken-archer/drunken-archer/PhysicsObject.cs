using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Box2D.XNA;

namespace DrunkenArcher {
    class PhysicsObject {
        protected static Game game;

        public float x {
            get { return body.Position.X; } 
            set { body.Position = new Vector2(value, body.Position.Y); } }
        public float y {
            get { return body.Position.Y; }
            set { body.Position = new Vector2(body.Position.X, value); } }

        public float vx {
            get { return body.GetLinearVelocity().X; }
            set { body.SetLinearVelocity(new Vector2(value, body.GetLinearVelocity().Y)); }
        }
        public float vy {
            get { return body.GetLinearVelocity().Y; }
            set { body.SetLinearVelocity(new Vector2(body.GetLinearVelocity().X, value)); }
        }



        /*public float vx = 0;
        public float vy = 0;

        public float ax = 0;
        public float ay = 0;

        public float tx = 0;
        public float ty = 0;*/

        protected Vector2 _camera_weight = new Vector2(1.0f);

        protected Rectangle bounding_box = new Rectangle(0, 0, 0, 0);

        public void camera_weight(float x, float y) {
            _camera_weight.X = x;
            _camera_weight.Y = y;
        }

        public Body body;
        protected Fixture fixture;

        public void engine_update() {
            //shadow variables. The great equalizers.
            
        }


        /*
        public void engine_update() {
            //process physics calculations
            //velocity
            x += vx;
            y += vy;

            //acceleration
            vx += ax;
            vy += ay;

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
        }
         * */
    }
}
