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
using Box2D.XNA;

namespace DrunkenArcher {
    /// <summary>
    /// This is the main type for your game
    /// </summary>
    public class Game : Microsoft.Xna.Framework.Game {
        public GraphicsDeviceManager graphics;
        public SpriteBatch spriteBatch;

        public SortedList<int, DrawableList> layers = new SortedList<int, DrawableList>();
        List<GameObject> engine_objects = new List<GameObject>();
        public Dictionary<String, Texture2D> textures;
        public Dictionary<String, Song> music;
        public Dictionary<String, SoundEffect> sound;

        Lua vm;
        public Vector2 camera = new Vector2(0.0f);

        //physics stuff
        static Vector2 gravity = new Vector2(0.0f, 10.0f);
        public World world = new World(gravity, true);

        public Game() {
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";

            vm = new Lua();
            textures = new Dictionary<String, Texture2D>();
            music = new Dictionary<String, Song>();
            sound = new Dictionary<String, SoundEffect>();

            //testing!
            Vector2[] edges = new Vector2[4];
            edges[0] = new Vector2(0f, 0f);
            edges[1] = new Vector2(64f, 0f);
            edges[2] = new Vector2(64f, 48f);
            edges[3] = new Vector2(0f, 48f);
            LoopShape shape = new LoopShape();
            shape._vertices = edges;
            shape._count = 4;

            BodyDef def = new BodyDef();
            def.type = BodyType.Static;
            def.position = new Vector2(0f, 0f);
            Body stage = world.CreateBody(def);

            FixtureDef fdef = new FixtureDef();
            fdef.shape = shape;
            fdef.density = 1.0f;
            fdef.friction = 0.3f;
            Fixture fixture = stage.CreateFixture(fdef);

            //this.IsMouseVisible = true;

        }

        /// <summary>
        /// Allows the game to perform any initialization it needs to before starting to run.
        /// This is where it can query for any required services and load any non-graphic
        /// related content.  Calling base.Initialize will enumerate through any components
        /// and initialize them as well.
        /// </summary>
        protected override void Initialize() {
            // TODO: Add your initialization logic here
            graphics.PreferredBackBufferWidth = 640;
            graphics.PreferredBackBufferHeight = 480;
            graphics.ApplyChanges();
            base.Initialize();
        }

        SoundEffectInstance musicPlayer;

        public void playMusic(string path) {
            /*if (!music.ContainsKey(path)) {
                //Attempt to load the song (we haven't done so yet)
                music[path] = Content.Load<Song>(path);
            }
            MediaPlayer.Play(music[path]);
            MediaPlayer.IsRepeating = true;*/
            if (!sound.ContainsKey(path)) {
                //Attempt to load the song (we haven't done so yet)
                sound[path] = Content.Load<SoundEffect>(path);
            }

            if (musicPlayer != null) {
                musicPlayer.Stop();
            }

            musicPlayer = sound[path].CreateInstance();
            musicPlayer.IsLooped = true;
            musicPlayer.Play();
        }

        public void playSound(string path) {
            if (!sound.ContainsKey(path)) {
                //Attempt to load the song (we haven't done so yet)
                sound[path] = Content.Load<SoundEffect>(path);
            }
            sound[path].Play(0.5f, 0.0f, 0.0f);
        }

        private string levelToLoad = "";

        public void luaLoadLevel(string path) {
            //This exists to prevent lua from deleting itself while it's running
            levelToLoad = path;
        }

        public void setCamera(float x, float y) {
            camera.X = x;
            camera.Y = y;
        }

        public void loadLevel(string path) {
            //cleanup anything from the old level
            engine_objects.Clear();

            //Cleanup all the graphics layers
            layers.Clear();

            //setup the default layer, 0
            layers.Add(0, new DrawableList());

            //reset the lua VM entirely (the vm is re-run fresh for each new level)
            vm.Dispose(); //cleanup? NO IDEA. No documentation. None. Anywhere.
            vm = new Lua();

            //clear out the physics everything
            world = new World(gravity, true);

            //run the initial config set
            vm.DoFile("lua/main.lua");

            //bind some functions into place
            vm.RegisterFunction("GameEngine.spawn", this, GetType().GetMethod("SpawnObject"));
            vm.RegisterFunction("GameEngine.tilemap", this, GetType().GetMethod("CreateTileMap"));
            vm.RegisterFunction("GameEngine.playMusic", this, GetType().GetMethod("playMusic"));
            vm.RegisterFunction("GameEngine.playSound", this, GetType().GetMethod("playSound"));
            vm.RegisterFunction("GameEngine.loadLevel", this, GetType().GetMethod("luaLoadLevel"));
            vm.RegisterFunction("GameEngine.setCamera", this, GetType().GetMethod("setCamera"));

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
        public int SpawnObject() {
            GameObject new_object = new GameObject(vm, this);
            engine_objects.Add(new_object);

            //the default layer is 0
            layers[0].items.Add(new_object);

            //tell lua about the new object
            return new_object.ID();
        }

        public int CreateTileMap() {
            TileMap new_tilemap = new TileMap(vm, this);
            engine_objects.Add(new_tilemap);

            //the default layer is 0
            layers[0].items.Add(new_tilemap);

            //tell lua about the new object
            return new_tilemap.ID();
        }

        Effect pixelDouble;

        /// <summary>
        /// LoadContent will be called once per game and is the place to load
        /// all of your content.
        /// </summary>
        protected override void LoadContent() {
            //load the test level
            loadLevel("physicstest.lua");

            // Create a new SpriteBatch, which can be used to draw textures.
            spriteBatch = new SpriteBatch(GraphicsDevice);

            pixelDouble = Content.Load<Effect>("PixelDouble");
        }

        /// <summary>
        /// UnloadContent will be called once per game and is the place to unload
        /// all content.
        /// </summary>
        protected override void UnloadContent() {
            // TODO: Unload any non ContentManager content here
        }

        MouseState lastMouse;
        MouseState currentMouse;

        /// <summary>
        /// Allows the game to run logic such as updating the world,
        /// checking for collisions, gathering input, and playing audio.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Update(GameTime gameTime) {
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

            // TODO: Add your update logic here
            foreach (var o in engine_objects) {
                o.engine_update();
            }

            //handle mouse movement / clicks
            lastMouse = currentMouse;
            currentMouse = Mouse.GetState();
            vm.DoString("mouse.x = " + ((float)(currentMouse.X + camera.X) / 10f));
            vm.DoString("mouse.y = " + ((float)(currentMouse.Y + camera.Y) / 10f));


            if (currentMouse.LeftButton == ButtonState.Pressed && lastMouse.LeftButton == ButtonState.Released) {
                vm.DoString("GameEngine.processEvent('on_click')");
            }

            if (currentMouse.ScrollWheelValue < lastMouse.ScrollWheelValue) {
                vm.DoString("GameEngine.processEvent('scroll_down')");
            }

            if (currentMouse.ScrollWheelValue > lastMouse.ScrollWheelValue) {
                vm.DoString("GameEngine.processEvent('scroll_up')");
            }

            //scroll click
            if (currentMouse.MiddleButton == ButtonState.Pressed && lastMouse.MiddleButton == ButtonState.Released) {
                vm.DoString("GameEngine.processEvent('scroll_click')");
            }

            //process world stuffs
            world.Step(1.0f / 60.0f, 8, 3);
            vm.DoString("GameEngine.processEvent('update')");

            //If we need to change levels, do that now
            if (levelToLoad != "") {
                loadLevel(levelToLoad);
                levelToLoad = "";
            }

            base.Update(gameTime);
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime) {
            //setup a render to texture
            RenderTarget2D render_target = new RenderTarget2D(graphics.GraphicsDevice, graphics.PreferredBackBufferWidth, graphics.PreferredBackBufferHeight);
            graphics.GraphicsDevice.SetRenderTarget(render_target);
            graphics.ApplyChanges();

            GraphicsDevice.Clear(Color.CornflowerBlue);

            // TODO: Add your drawing code here
            spriteBatch.Begin();

            //Draw each layer of the engine in turn; lower layers draw first so they
            //end up behind everything else
            foreach (var layer in layers)
            {
                layer.Value.Draw(this);
            }

            spriteBatch.End();

            //grab the rendered texture and apply effects and stuff
            graphics.GraphicsDevice.SetRenderTarget(null);
            graphics.ApplyChanges();

            SpriteBatch newthing = new SpriteBatch(graphics.GraphicsDevice);

            newthing.Begin(SpriteSortMode.Immediate, null, SamplerState.PointClamp, null, null, pixelDouble);
            newthing.Draw(render_target, new Rectangle(0, 0, graphics.PreferredBackBufferWidth, graphics.PreferredBackBufferHeight), Color.LightGray);
            newthing.End();

            base.Draw(gameTime);
        }
    }
}
