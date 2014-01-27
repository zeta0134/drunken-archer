using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;

/* NOTE:
 * I'm breaking a rule of OOP badly here and using public members all over the place. This is
 * mostly because LUA has no understanding of C#'s member access specifiers, and the binding
 * framework we're using complains if we try to use anything else. Think of this as a glorified
 * referenced struct, and not a proper class.
 * */

namespace DrunkenArcher
{

    class GameObject
    {
        static Game game;

        static int next_id = 1;
        int id;

        public double x = 0;
        public double y = 0;

        public double vx = 0;
        public double vy = 0;

        public double ax = 0;
        public double ay = 0;

        public double tx = 0;
        public double ty = 0;

        public Color color;
        public Texture2D texture;

        public static double gravity = 0.0;

        public GameObject(Lua vm, Game gm)
        {
            id = next_id++;
            bind_to_lua(vm);
            game = gm;
            color = Color.White;
        }

        public int ID()
        {
            return id;
        }

        public void sprite_color(int r, int g, int b, int a)
        {
            color = new Color(r, g, b, a);
        }

        public void sprite(string path)
        {
            texture = game.textures[path];
        }

        public void bind_to_lua(Lua vm)
        {

            //Console.WriteLine("Attempting to bind a lua thingy...");

            string lua_name = "objects[" + id + "]";

            //vm[lua_name] = this;
            vm["object_to_bind"] = this;
        }

        public void engine_update()
        {
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
