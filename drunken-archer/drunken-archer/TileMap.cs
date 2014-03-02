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

        Tile[,] map;
        Fixture[,] fixtures;

        public int width = 0;
        public int height = 0;

        public int tile_width = 16;
        public int tile_height = 16;

        //static int next_id = 1;
        //int id;

        public bool debug = false;
        public int highlight_x = -1;
        public int highlight_y = -1;

        public TileMap(Lua vm, Game gm) : base(vm, gm) {
            id = next_id++;
            bind_to_lua(vm);
            game = gm;

            body.SetType(Box2D.XNA.BodyType.Static);
        }

        public override void engine_update()
        {
            base.engine_update();
            if (dirty) {
                updateFixtures();
                dirty = false;
            }
        }

        public override void Draw(Game game) {
            Vector2 map_position = new Vector2(x * 10f - game.camera.X * _camera_weight.X, y * 10f - game.camera.Y * _camera_weight.Y);

            for (int dy = 0; dy < height; dy++) {
                for (int dx = 0; dx < width; dx++) {
                    if (map[dx, dy].index > 0) {
                        int tilemap_x = (map[dx, dy].index - 1) * tile_width;
                        int tilemap_y = 0;
                        while (tilemap_x >= texture.Width && tilemap_y < texture.Height) {
                            tilemap_x -= texture.Width;
                            tilemap_y += tile_height;
                        }
                        Vector2 tile_position = map_position + new Vector2(dx * tile_width, dy * tile_height);
                        if (tile_position.X >= 0 - tile_width && tile_position.Y >= 0 - tile_height &&
                            tile_position.X <= game.graphics.PreferredBackBufferWidth && tile_position.Y <= game.graphics.PreferredBackBufferHeight) {
                                Color tile_color = sprite_color;
                                if (debug) {
                                    if (highlight_x == dx && highlight_y == dy) {
                                        tile_color = Color.LightCoral;
                                    }
                                    else if (map[dx, dy].solid) {
                                        tile_color = Color.LightBlue;
                                    }
                                }
                                game.spriteBatch.Draw(
                                    texture, 
                                    tile_position, 
                                    new Rectangle(tilemap_x, tilemap_y, tile_width, tile_height), 
                                    tile_color);
                        }
                    }
                }
            }
        }

        public void setTiles(string name) {
            string path = "art/tiles/" + name;
            if (!game.textures.ContainsKey(path)) {
                //try to load the asset first
                game.textures[path] = game.Content.Load<Texture2D>(path);
            }
            texture = game.textures[path];
        }

        public int maxIndex()
        {
            //returns the maximum tile, based on the size of the currently loaded tilemap texture
            return (texture.Width / tile_width) * (texture.Height / tile_height);

            //Note: undefined behavior if the tile texture is not an even multiple of the tile width / height
        }

        bool dirty = false;
        private void updateFixtures() {
            Fixture current = body.GetFixtureList();
            //clear out all fixtures
            while (current != null) {
                Fixture destroy = current;
                current = current.GetNext();
                body.DestroyFixture(destroy);
            }

            //add new fixtures based on the existing tilemap
            bool line = false;
            int lineStart = 0;
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    if (map[x, y].solid && !line) {
                        line = true;
                        lineStart = x;
                    }

                    if (((!map[x,y].solid) || x == width - 1) && line) {
                        //finish out the current line
                        //add a new physics object for this tile
                        //(note: this method will probably fail)
                        PolygonShape box = new PolygonShape();
                        float phys_width = ((float)tile_width / 10.0f);
                        float phys_height = (float)tile_height / 10.0f;

                        box.SetAsBox(
                            (phys_width * (x - lineStart + (x == width - 1 ? 1 : 0))) / 2.0f,
                            phys_height / 2.0f,
                            new Vector2(
                                phys_width * (lineStart) + ((phys_width * (x - lineStart + (x == width - 1 ? 1 : 0))) / 2.0f),
                                phys_height * y + phys_height / 2.0f),
                            0.0f);

                        FixtureDef fdef = new FixtureDef();
                        fdef.shape = box;
                        fdef.density = 1.0f;
                        fdef.friction = 1.0f;

                        fixtures[x, y] = body.CreateFixture(fdef);
                        line = false;
                    }
                }
            }
        }

        public void mapSize(int w, int h) {
            //Note: This does clear out the map contents by design; they'll need to be reset manually
            width = w;
            height = h;
            map = new Tile[w, h];
            fixtures = new Fixture[w, h];
            dirty = true;
        }

        public void resizeMap(int w, int h) {
            var oldmap = map;
            int oldwidth = width;
            int oldheight = height;
            mapSize(w, h);
            //now, attempt to copy all the valid tiles from the old map into the new one
            for (int x = 0; x < width && x < oldwidth; x++) {
                for (int y = 0; y < height && y < oldheight; y++) {
                    //map[x, y] = oldmap[x, y];
                    setTile(x, y, oldmap[x, y].index, oldmap[x, y].solid);
                }
            }
            dirty = true;
        }

        public int getTile(int x, int y) {
            return map[x, y].index;
        }

        public bool isSolid(int x, int y) {
            return map[x, y].solid;
        }

        public void setTile(int x, int y, int index, bool solid) {
            bool wassolid = map[x, y].solid;
            
            map[x, y].index = index;
            map[x, y].solid = solid;

            //HACK
            if (wassolid != solid) {
                dirty = true; //make sure fixtures get removed properly
            }
        }
    }
}
