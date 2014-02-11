using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;
using NLua;
using Box2D.XNA;

namespace DrunkenArcher {
    class TileMap : GameObject {
        struct Tile {
            public bool solid;
            public int index;
        }

        Texture2D tile_texture;
        Tile[,] map;

        public int width = 0;
        public int height = 0;

        public int tile_width = 16;
        public int tile_height = 16;

        static int next_id = 1;
        int id;

        public TileMap(Lua vm, Game gm) : base(vm, gm) {
            id = next_id++;
            bind_to_lua(vm);
            game = gm;

            body.SetType(Box2D.XNA.BodyType.Static);
        }

        public override void Draw(Game game) {
            Vector2 map_position = new Vector2(x * 10f - game.camera.X * _camera_weight.X, y * 10f - game.camera.Y * _camera_weight.Y);

            for (int dy = 0; dy < height; dy++) {
                for (int dx = 0; dx < width; dx++) {
                    if (map[dx, dy].index > 0) {
                        int tilemap_x = (map[dx, dy].index - 1) * tile_width;
                        int tilemap_y = 0;
                        while (tilemap_x > tile_texture.Width && tilemap_y < tile_texture.Height) {
                            tilemap_x -= tile_texture.Width;
                            tilemap_y += tile_height;
                        }
                        Vector2 tile_position = map_position + new Vector2(dx * tile_width, dy * tile_height);
                        if (tile_position.X >= 0 - tile_width && tile_position.Y >= 0 - tile_height &&
                            tile_position.X <= game.graphics.PreferredBackBufferWidth && tile_position.Y <= game.graphics.PreferredBackBufferHeight) {
                            game.spriteBatch.Draw(tile_texture, tile_position, new Rectangle(tilemap_x, tilemap_y, tile_width, tile_height), (map[dx, dy].solid ? Color.LightBlue : Color.White));
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

        public int getTile(int x, int y) {
            return map[x, y].index;
        }

        public bool isSolid(int x, int y) {
            return map[x, y].solid;
        }

        public void setTile(int x, int y, int index, bool solid) {
            //if this block was solid before, remove the physics object
            //TODO: THIS
            
            map[x, y].index = index;
            map[x, y].solid = solid;

            if (solid) {
                //add a new physics object for this tile
                //(note: this method will probably fail)
                PolygonShape box = new PolygonShape();
                float phys_width = (float)tile_width / 10.0f;
                float phys_height = (float)tile_height / 10.0f;

                box.SetAsBox(
                    phys_width / 2.0f,
                    phys_height / 2.0f,
                    new Vector2(
                        phys_width * x + phys_width / 2.0f,
                        phys_height * y + phys_height / 2.0f),
                    0.0f);

                FixtureDef fdef = new FixtureDef();
                fdef.shape = box;
                fdef.density = 1.0f;
                fdef.friction = 0.3f;

                fixture = body.CreateFixture(fdef);
            }
        }
    }
}
