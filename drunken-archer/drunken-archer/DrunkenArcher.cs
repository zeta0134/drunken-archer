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
        public Dictionary<String, Song> music;
        public Dictionary<String, SoundEffect> sound;

        Lua vm;

        public Game()
        {
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";

            vm = new Lua();
            game_objects = new List<GameObject>();
            textures = new Dictionary<String, Texture2D>();
            music = new Dictionary<String, Song>();
            sound = new Dictionary<String, SoundEffect>();
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
            graphics.PreferredBackBufferWidth = 640;
            graphics.PreferredBackBufferHeight = 480;
            graphics.ApplyChanges();
            base.Initialize();
        }

        public void playMusic(string path) {
            if (!music.ContainsKey(path))
            {
                //Attempt to load the song (we haven't done so yet)
                music[path] = Content.Load<Song>(path);
            }
            MediaPlayer.Play(music[path]);
        }

        public void playSound(string path)
        {
            if (!sound.ContainsKey(path))
            {
                //Attempt to load the song (we haven't done so yet)
                sound[path] = Content.Load<SoundEffect>(path);
            }
            sound[path].Play(0.5f,0.0f,0.0f);
        }

        private string levelToLoad = "";

        public void luaLoadLevel(string path)
        {
            //This exists to prevent lua from deleting itself while it's running
            levelToLoad = path;
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
            vm.RegisterFunction("GameEngine.spawn", this, GetType().GetMethod("SpawnObject"));
            vm.RegisterFunction("GameEngine.playMusic", this, GetType().GetMethod("playMusic"));
            vm.RegisterFunction("GameEngine.playSound", this, GetType().GetMethod("playSound"));
            vm.RegisterFunction("GameEngine.loadLevel", this, GetType().GetMethod("luaLoadLevel"));

            //Set some engine-level variables for the lua code to use
            vm.DoString("current_level = \"" + path + "\"");

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

            GamePadButtons gamepad = GamePad.GetState(PlayerIndex.One).Buttons;
            vm.DoString("prev_gamepad_held = gamepad_held");
            vm["gamepad_held"] = gamepad;

            Keys[] keys_pressed = Keyboard.GetState().GetPressedKeys();
            vm.DoString("prev_keys_held = keys_held\nkeys_held = {}");
            foreach (var key in keys_pressed) {
                vm.DoString("keys_held[\"" + key + "\"] = true");
            }

            //quick thing to restart the level on command
            //if (Keyboard.GetState().IsKeyDown(Keys.R)) {
            //    loadLevel("testlevel.lua");
            //}

            // TODO: Add your update logic here
            foreach (var o in game_objects)
            {
                o.engine_update();
            }
            vm.DoString("GameEngine.update()");

            //If we need to change levels, do that now
            if (levelToLoad != "")
            {
                loadLevel(levelToLoad);
                levelToLoad = "";
            }

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
