using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;
using NLua;

namespace DrunkenArcher
{
    /// <summary>
    /// This is the main type for your game
    /// </summary>
    public class Game : Microsoft.Xna.Framework.Game
    {
        GraphicsDeviceManager graphics;
        SpriteBatch spriteBatch;

        List<GameObject> game_objects;
        public Dictionary<String, Texture2D> textures;

        Lua vm;

        public Game()
        {
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";

            vm = new Lua();
            game_objects = new List<GameObject>();
            textures = new Dictionary<String, Texture2D>();
        }

        /// <summary>
        /// Allows the game to perform any initialization it needs to before starting to run.
        /// This is where it can query for any required services and load any non-graphic
        /// related content.  Calling base.Initialize will enumerate through any components
        /// and initialize them as well.
        /// </summary>
        protected override void Initialize()
        {
            // TODO: Add your initialization logic here

            base.Initialize();
        }

        public void loadLevel(string path) 
        {
            //cleanup anything from the old level
            game_objects.Clear();

            //reset the lua VM entirely (the vm is re-run fresh for each new level)
            vm.Dispose(); //cleanup? NO IDEA. No documentation. None. Anywhere.
            vm = new Lua();

            //run the initial config set
            vm.DoFile("lua/main.lua");

            //bind some functions into place
            vm.RegisterFunction("GameEngine.spawn",
                this,
                GetType().GetMethod("SpawnObject"));

            

            //finally, run the level file
            vm.DoFile("lua/" + path);
        }

        /// <summary>
        /// Creates a new object and returns its unique ID. This is intended to be called by a
        /// lua script; note that calling it from anywhere else will result in lua not knowing
        /// about the object at all.
        /// </summary>
        public int SpawnObject()
        {
            GameObject new_object = new GameObject(vm, this);
            game_objects.Add(new_object);
            //tell lua about the new object
            return new_object.ID();
        }

        /// <summary>
        /// LoadContent will be called once per game and is the place to load
        /// all of your content.
        /// </summary>
        protected override void LoadContent()
        {
            // TODO: use this.Content to load your game content here
            textures["art/sprites/triangle"] = Content.Load<Texture2D>("art/sprites/triangle");
            textures["art/sprites/zero"] = Content.Load<Texture2D>("art/sprites/zero");
            
            //load the test level
            loadLevel("testlevel.lua");

            // Create a new SpriteBatch, which can be used to draw textures.
            spriteBatch = new SpriteBatch(GraphicsDevice);

            
        }

        /// <summary>
        /// UnloadContent will be called once per game and is the place to unload
        /// all content.
        /// </summary>
        protected override void UnloadContent()
        {
            // TODO: Unload any non ContentManager content here
        }

        /// <summary>
        /// Allows the game to run logic such as updating the world,
        /// checking for collisions, gathering input, and playing audio.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Update(GameTime gameTime)
        {
            // Allows the game to exit
            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed)
                this.Exit();

            //quick thing to restart the level on command
            if (Keyboard.GetState().IsKeyDown(Keys.R)) {
                loadLevel("testlevel.lua");
            }

            // TODO: Add your update logic here
            foreach (var o in game_objects)
            {
                o.engine_update();
            }
            vm.DoString("GameEngine.update()");

            base.Update(gameTime);
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.CornflowerBlue);

            // TODO: Add your drawing code here
            spriteBatch.Begin();

            //fancy stuff
            foreach (var o in game_objects)
            {
                if (o.texture != null)
                {
                    spriteBatch.Draw(o.texture, new Vector2((float)o.x, (float)o.y), o.color);
                }
            }

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
