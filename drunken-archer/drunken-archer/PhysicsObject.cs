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

        public void camera_weight(float x, float y) {
            _camera_weight.X = x;
            _camera_weight.Y = y;
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
        }
    }
}
