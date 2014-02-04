using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;
using Box2D.XNA;

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
            game = gm;
            sprite_color = Color.White;

            //setup physics stuff
            BodyDef def = new BodyDef();
            def.type = BodyType.Dynamic;
            def.position = new Vector2(0.0f);
            body = game.world.CreateBody(def);

            //create a fixture for the bounding box
            PolygonShape box = new PolygonShape();
            box.SetAsBox(1.0f, 1.0f);

            FixtureDef fdef = new FixtureDef();
            fdef.shape = box;
            fdef.density = 1.0f;
            fdef.friction = 0.3f;

            fixture = body.CreateFixture(fdef);

            bind_to_lua(vm);
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
            
            //setup fun physics things
            body.DestroyFixture(fixture);

            PolygonShape box = new PolygonShape();
            float phys_width = (float)texture.Width / 10.0f;
            float phys_height = (float)texture.Width / 10.0f;
            box.SetAsBox(
                phys_width / 2.0f,
                phys_height / 2.0f,
                new Vector2(phys_width / 2.0f, phys_height / 2.0f), 
                0.0f);

            FixtureDef fdef = new FixtureDef();
            fdef.shape = box;
            fdef.density = 1.0f;
            fdef.friction = 0.3f;

            fixture = body.CreateFixture(fdef);
            body.ResetMassData();
        }

        public void bind_to_lua(Lua vm) {
            vm["object_to_bind"] = this;
            vm["body_to_bind"] = this.body;
        }

        public void Draw(Game game) {
            if (this.texture != null) {
                float draw_x = (body.Position.X * 10.0f) - game.camera.X * _camera_weight.X;
                float draw_y = (body.Position.Y * 10.0f) - game.camera.Y * _camera_weight.Y;

                float scale = 1.0f;
                float angle = body.GetAngle();
                float layer = 0f;
                game.spriteBatch.Draw(texture, new Vector2(draw_x, draw_y), null, sprite_color, angle, new Vector2(0.0f), scale, SpriteEffects.None, layer);
                
            }
        }
    }
}
