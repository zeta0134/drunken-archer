using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;
using NLua;

namespace DrunkenArcher {
    class TileMap : PhysicsObject, Drawable {
        struct Tile {
            public bool solid;
            public int index;
        }

        Texture2D tile_texture;
        Tile[,] map;

        int width = 0;
        int height = 0;

        public int tile_width = 16;
        public int tile_height = 16;

        static int next_id = 1;
        int id;

        public TileMap(Lua vm, Game gm) {
            id = next_id++;
            bind_to_lua(vm);
            game = gm;
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

        public void bind_to_lua(Lua vm) {
            vm["object_to_bind"] = this;
        }

        public void Draw(Game game) {
            Vector2 map_position = new Vector2(x - game.camera.X * _camera_weight.X, y - game.camera.Y * _camera_weight.Y);

            for (int dy = 0; dy < height; dy++) {
                for (int dx = 0; dx < width; dx++) {
                    if (map[dx, dy].index > 0) {
                        Vector2 tile_position = map_position + new Vector2(dx * tile_width, dy * tile_height);
                        if (tile_position.X >= 0 - tile_width && tile_position.Y >= 0 - tile_height &&
                            tile_position.X <= game.graphics.PreferredBackBufferWidth && tile_position.Y <= game.graphics.PreferredBackBufferHeight) {
                            game.spriteBatch.Draw(tile_texture, tile_position, new Rectangle((map[dx, dy].index - 1) * tile_width, 0, tile_width, tile_height), Color.White);
                        }
                    }
                }
            }
        }

        public void setTiles(string path) {
            if (!game.textures.ContainsKey(path)) {
                //try to load the asset first
                game.textures[path] = game.Content.Load<Texture2D>(path);
            }
            tile_texture = game.textures[path];
        }

        public void mapSize(int w, int h) {
            //Note: This does clear out the map contents by design; they'll need to be reset manually
            width = w;
            height = h;
            map = new Tile[w, h];
        }

        public void setTile(int x, int y, int index) {
            map[x, y].index = index;
        }
    }
}
