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

namespace DrunkenArcher {

    class GameObject : PhysicsObject, Drawable {

        static int next_id = 1;
        int id;

        public Color sprite_color;
        public Texture2D texture;

        public GameObject(Lua vm, Game gm) {
            id = next_id++;
            bind_to_lua(vm);
            game = gm;
            sprite_color = Color.White;
        }

        public int ID() {
            return id;
        }

        private int layer = 0;

        public void z_index(int z) {
            //remove this item from its current layer (assuming that exists)
            if (game.layers.ContainsKey(layer)) {
                if (game.layers[layer].items.Contains(this)) {
                    game.layers[layer].items.Remove(this);
                }

                //if we just emptied this layer out, remove the list entirely
                if (layer != 0 && game.layers[layer].items.Count == 0) {
                    game.layers.Remove(layer);
                }
            }

            //Switch this item's layer, then add it to the appropriate collection
            layer = z;
            if (!game.layers.ContainsKey(layer)) {
                game.layers.Add(layer, new DrawableList());
            }
            game.layers[layer].items.Add(this);
        }

        public void color(int r, int g, int b, int a) {
            sprite_color = new Color(r, g, b, a);
        }

        public void sprite(string path) {
            if (!game.textures.ContainsKey(path)) {
                //try to load the asset first
                game.textures[path] = game.Content.Load<Texture2D>(path);
            }
            texture = game.textures[path];
        }

        public void bind_to_lua(Lua vm) {
            vm["object_to_bind"] = this;
        }

        public void Draw(Game game) {
            if (this.texture != null) {
                float draw_x = x - game.camera.X * _camera_weight.X;
                float draw_y = y - game.camera.Y * _camera_weight.Y;
                game.spriteBatch.Draw(texture, new Vector2(draw_x, draw_y), sprite_color);
            }
        }
    }
}
