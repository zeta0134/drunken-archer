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

    class GameObject : Drawable
    {
        static Game game;

        static int next_id = 1;
        int id;

        public float x = 0;
        public float y = 0;

        public float vx = 0;
        public float vy = 0;

        public float ax = 0;
        public float ay = 0;

        public float tx = 0;
        public float ty = 0;

        private Vector2 _camera_weight = new Vector2(1.0f);
        public Color sprite_color;
        public Texture2D texture;

        public float gravity = 0.0f;

        public GameObject(Lua vm, Game gm)
        {
            id = next_id++;
            bind_to_lua(vm);
            game = gm;
            sprite_color = Color.White;
        }

        public int ID()
        {
            return id;
        }

        public void color(int r, int g, int b, int a)
        {
            sprite_color = new Color(r, g, b, a);
        }

        private int layer = 0;

        public void camera_weight(float x, float y)
        {
            _camera_weight.X = x;
            _camera_weight.Y = y;
        }

        public void z_index(int z)
        {
            //remove this item from its current layer (assuming that exists)
            if (game.layers.ContainsKey(layer))
            {
                if (game.layers[layer].items.Contains(this))
                {
                    game.layers[layer].items.Remove(this);
                }

                //if we just emptied this layer out, remove the list entirely
                if (layer != 0 && game.layers[layer].items.Count == 0) {
                    game.layers.Remove(layer);
                }
            }

            //Switch this item's layer, then add it to the appropriate collection
            layer = z;
            if (!game.layers.ContainsKey(layer))
            {
                game.layers.Add(layer, new DrawableList());
            }
            game.layers[layer].items.Add(this);
        }

        public void sprite(string path)
        {
            if (!game.textures.ContainsKey(path))
            {
                //try to load the asset first
                game.textures[path] = game.Content.Load<Texture2D>(path);
            }
            texture = game.textures[path];
        }

        public void bind_to_lua(Lua vm)
        {

            //Console.WriteLine("Attempting to bind a lua thingy...");

            string lua_name = "objects[" + id + "]";

            //vm[lua_name] = this;
            vm["object_to_bind"] = this;
        }

        public void Draw(Game game)
        {
            if (this.texture != null)
            {
                float draw_x = x + game.camera.X * _camera_weight.X;
                float draw_y = y + game.camera.Y * _camera_weight.Y;
                game.spriteBatch.Draw(texture, new Vector2(draw_x, draw_y), sprite_color);
            }
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
