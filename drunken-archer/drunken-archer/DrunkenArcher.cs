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
using XNAGameConsole;
using System.IO;

namespace DrunkenArcher {
    /// <summary>
    /// This is the main type for your game
    /// </summary>
    public class Game : Microsoft.Xna.Framework.Game {
        public GraphicsDeviceManager graphics;
        public SpriteBatch spriteBatch;

        public SortedList<int, DrawableList> layers = new SortedList<int, DrawableList>();
        //List<GameObject> engine_objects = new List<GameObject>();
        public Dictionary<int, GameObject> engine_objects = new Dictionary<int, GameObject>();
        public Dictionary<String, Texture2D> textures;
        public Dictionary<String, Song> music;
        public Dictionary<String, SoundEffect> sound;

        public Lua vm;
        public Vector2 camera = new Vector2(0.0f);

        //physics stuff
        static Vector2 gravity = new Vector2(0.0f, 20.0f);
        public World world = new World(gravity, true);

        private ContactListener listener;

        GameConsole game_console;

        private class LuaCommand : IConsoleCommand {
            public string Name
            {
                get { return "lua"; }
            }

            public string Description
            {
                get { return "lua <command>: runs the command in the lua VM"; }
            }

            private Game game;
            public LuaCommand(Game gm)
            {
                this.game = gm;
            }

            public string Execute(string[] arguments)
            {
                string commandString = arguments[0];
                for (int i = 1; i < arguments.Length; i++) {
                    commandString += " " + arguments[i];
                }

                try {
                    game.vm.DoString(commandString);
                    return "";
                }
                catch (NLua.Exceptions.LuaException e) {
                    return "ERROR: " + e.Message;
                }
            }
        }

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
            //this.IsFixedTimeStep = false;

            
        }

        /// <summary>
        /// Allows the game to perform any initialization it needs to before starting to run.
        /// This is where it can query for any required services and load any non-graphic
        /// related content.  Calling base.Initialize will enumerate through any components
        /// and initialize them as well.
        /// </summary>
        protected override void Initialize() {
            // TODO: Add your initialization logic here
            graphics.PreferredBackBufferWidth = 1280;
            graphics.PreferredBackBufferHeight = 720;
            graphics.ApplyChanges();
            base.Initialize();
        }

        SoundEffectInstance musicPlayer;

        string currentSong = "";
        public void playMusic(string path) {
            if (path == currentSong) {
                return;
            }
            currentSong = path;
            /*if (!music.ContainsKey(path)) {
                //Attempt to load the song (we haven't done so yet)
                music[path] = Content.Load<Song>(path);
            }
            MediaPlayer.Play(music[path]);
            MediaPlayer.IsRepeating = true;*/
            if (!sound.ContainsKey(path)) {
                //Attempt to load the song (we haven't done so yet)
                sound[path] = Content.Load<SoundEffect>("music/"+path);
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
                sound[path] = Content.Load<SoundEffect>("sound/" + path);
            }
            sound[path].Play(1.0f, 0.0f, 0.0f);
        }

        private string stageToLoad = "";

        public void luaLoadStage(string path) {
            //This exists to prevent lua from deleting itself while it's running
            stageToLoad = path;
        }

        private string levelToLoad = "";
        public void luaLoadLevel(string name) {
            levelToLoad = name;
            levelLoadCooldown = 60;
        }

        public void setCamera(float x, float y) {
            camera.X = x;
            camera.Y = y;
        }

        float screen_scale = 10f;

        public void loadAllObjects() {
            List<string> files = new List<string>(Directory.EnumerateFiles("lua/objects"));
            foreach (var file in files) {
                vm.DoFile(file);
            }
        }

        public Vector2 screenCoordinates(Vector2 physics_coordinates) {
            return screenCoordinates(physics_coordinates, Vector2.One);
        }

        public Vector2 screenCoordinates(Vector2 physics_coordinates, Vector2 camera_weight) {
            return new Vector2((physics_coordinates.X * screen_scale) - camera.X * camera_weight.X, (physics_coordinates.Y * screen_scale) - camera.Y * camera_weight.Y);
        }

        public void loadStage(string path) {
            //cleanup anything from the old level
            engine_objects.Clear();

            //Cleanup all the graphics layers
            layers.Clear();

            //setup the default layer, 0
            layers.Add(0, new DrawableList());

            //reset the game camera to 0,0
            camera = new Vector2(0);

            //reset the lua VM entirely (the vm is re-run fresh for each new level)
            vm.Dispose(); //cleanup? NO IDEA. No documentation. None. Anywhere.
            vm = new Lua();

            //clear out the physics everything
            world = new World(gravity, true);
            world.DebugDraw = new daDebugDraw(this);

            current_frame = 0;

            //run the initial config set
            vm.DoFile("lua/main.lua");

            //bind some functions into place
            vm.RegisterFunction("GameEngine.spawn", this, GetType().GetMethod("SpawnObject"));
            vm.RegisterFunction("GameEngine.tilemap", this, GetType().GetMethod("CreateTileMap"));
            vm.RegisterFunction("GameEngine.playMusic", this, GetType().GetMethod("playMusic"));
            vm.RegisterFunction("GameEngine.playSound", this, GetType().GetMethod("playSound"));
            vm.RegisterFunction("loadstage", this, GetType().GetMethod("luaLoadStage"));
            vm.RegisterFunction("loadlevel", this, GetType().GetMethod("luaLoadLevel"));
            vm.RegisterFunction("GameEngine.setCamera", this, GetType().GetMethod("setCamera"));
            vm.RegisterFunction("GameEngine.toggleDebug", this, GetType().GetMethod("toggleDebug"));
            vm.RegisterFunction("GameEngine.currentFrame", this, GetType().GetMethod("currentFrame"));
            vm.RegisterFunction("GameEngine.consolePrint", this, GetType().GetMethod("consolePrint"));
            vm.RegisterFunction("GameEngine.loadAllObjects", this, GetType().GetMethod("loadAllObjects"));

            //Set some engine-level variables for the lua code to use
            vm.DoString("current_stage = \"" + path + "\"");

            //set up collision for the new level
            listener = new ContactListener(this, vm);
            world.ContactListener = listener;

            //finally, run the level file
            vm.DoFile("lua/stages/" + path + ".lua");
        }

        public void loadLevel(string name) {
            loadStage("levelloader");
            vm.DoString("load(\"" + name + "\")");
        }

        public void consolePrint(string thing) {
            game_console.WriteLine(thing);
        }

        int current_frame = 0;
        public int currentFrame() {
            return current_frame;
        }

        /// <summary>
        /// Creates a new object and returns its unique ID. This is intended to be called by a
        /// lua script; note that calling it from anywhere else will result in lua not knowing
        /// about the object at all.
        /// </summary>
        public int SpawnObject() {
            GameObject new_object = new GameObject(vm, this);
            engine_objects.Add(new_object.ID(), new_object);

            //tell lua about the new object
            return new_object.ID();
        }

        public void DestroyObject(GameObject gameobject) {
            engine_objects.Remove(gameobject.ID());
        }

        public int CreateTileMap() {
            TileMap new_tilemap = new TileMap(vm, this);
            engine_objects.Add(new_tilemap.ID(), new_tilemap);

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
            loadStage("title");

            // Create a new SpriteBatch, which can be used to draw textures.
            spriteBatch = new SpriteBatch(GraphicsDevice);
            debugBatch = new SpriteBatch(GraphicsDevice);

            pixelDouble = Content.Load<Effect>("PixelDouble");

            //debug stuff
            world.DebugDraw = new daDebugDraw(this);

            game_console = new GameConsole(this, spriteBatch);
            game_console.AddCommand(new LuaCommand(this));
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

        protected void SetButtonState(ButtonState state, string key) {
            if (state == ButtonState.Pressed)
                vm.DoString("gamepad_held." + key + " = true");
        }

        int levelLoadCooldown = 0;

        /// <summary>
        /// Allows the game to run logic such as updating the world,
        /// checking for collisions, gathering input, and playing audio.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        /// 
        bool debug = false;
        protected override void Update(GameTime gameTime) {
            current_frame += 1;
            // Allows the game to exit
            //if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed)
            //    this.Exit();

            GamePadState gamepad_state = GamePad.GetState(PlayerIndex.One);
            GamePadButtons gamepad = gamepad_state.Buttons;
            vm.DoString("prev_gamepad_held = gamepad_held\ngamepad_held = {}");
            
            //gamepad buttons
            SetButtonState(gamepad.A, "A");
            SetButtonState(gamepad.B, "B");
            SetButtonState(gamepad.X, "X");
            SetButtonState(gamepad.Y, "Y");

            SetButtonState(gamepad.Start, "Start");
            SetButtonState(gamepad.Back, "Back");

            SetButtonState(gamepad.LeftShoulder, "LB");
            SetButtonState(gamepad.RightShoulder, "RB");

            SetButtonState(gamepad_state.DPad.Up, "Up");
            SetButtonState(gamepad_state.DPad.Down, "Down");
            SetButtonState(gamepad_state.DPad.Left, "Left");
            SetButtonState(gamepad_state.DPad.Right, "Right");

            //triggers
            //TODO: THIS
            
            vm.DoString("gamepad_left.x = " + gamepad_state.ThumbSticks.Left.X);
            vm.DoString("gamepad_left.y = " + gamepad_state.ThumbSticks.Left.Y);
            vm.DoString("gamepad_left.angle = " + Math.Atan2(-gamepad_state.ThumbSticks.Left.Y, gamepad_state.ThumbSticks.Left.X));
            vm.DoString("gamepad_right.x = " + gamepad_state.ThumbSticks.Right.X);
            vm.DoString("gamepad_right.y = " + gamepad_state.ThumbSticks.Right.Y);
            vm.DoString("gamepad_right.angle = " + Math.Atan2(-gamepad_state.ThumbSticks.Right.Y, gamepad_state.ThumbSticks.Right.X));

            if (!game_console.Opened) {
                Keys[] keys_pressed = Keyboard.GetState().GetPressedKeys();
                vm.DoString("prev_keys_held = keys_held\nkeys_held = {}");
                foreach (var key in keys_pressed) {
                    vm.DoString("keys_held[\"" + key + "\"] = true");
                }
            }

            // TODO: Add your update logic here
            foreach (var o in engine_objects) {
                o.Value.engine_update();
            }

            //handle mouse movement / clicks
            lastMouse = currentMouse;
            currentMouse = Mouse.GetState();
            Vector2 transformed_mouse = new Vector2(((float)Math.Floor((currentMouse.X + camera.X * 2) / 2) / 10f), ((float)Math.Floor((currentMouse.Y + camera.Y * 2) / 2) / 10f));
            vm.DoString("mouse.x = " + transformed_mouse.X);
            vm.DoString("mouse.y = " + transformed_mouse.Y);


            if (currentMouse.LeftButton == ButtonState.Pressed && lastMouse.LeftButton == ButtonState.Released) {
                foreach (var o in engine_objects) {
                    Fixture thing = o.Value.body.GetFixtureList();
                    while (thing != null) {
                        if (thing.TestPoint(transformed_mouse)) {
                            o.Value.click_event(transformed_mouse.X, transformed_mouse.Y);
                        }
                        thing = thing.GetNext();
                    }
                }
                vm.DoString("if stage.on_click then stage.on_click(mouse.x, mouse.y) end");
            }

            if (currentMouse.RightButton == ButtonState.Pressed && lastMouse.RightButton == ButtonState.Released) {
                foreach (var o in engine_objects) {
                    Fixture thing = o.Value.body.GetFixtureList();
                    while (thing != null) {
                        if (thing.TestPoint(transformed_mouse)) {
                            Console.WriteLine("Attempting right click...");
                            o.Value.right_click_event(transformed_mouse.X, transformed_mouse.Y);
                        }
                        thing = thing.GetNext();
                    }
                }
                vm.DoString("if stage.right_click then stage.right_click(mouse.x, mouse.y) end");
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
            world.Step(1.0f / 60.0f, 6, 2);
            listener.HandleEvents(); //process collisions engineside as needed
            vm.DoString("destroyObjects()"); //cleanup any objects that need to die
            vm.DoString("GameEngine.processEvent('update')");

            //If we need to change levels, do that now
            if (stageToLoad != "") {
                loadStage(stageToLoad);
                stageToLoad = "";
            }

            if (levelToLoad != "" && levelLoadCooldown == 0) {
                loadLevel(levelToLoad);
                levelToLoad = "";
            }
            else if (levelLoadCooldown > 0) {
                levelLoadCooldown--;
            }

            base.Update(gameTime);
        }

        public void toggleDebug() {
            debug = !debug;
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        /// 
        public SpriteBatch debugBatch;
        protected override void Draw(GameTime gameTime) {
            //setup a render to texture
            RenderTarget2D render_target = new RenderTarget2D(graphics.GraphicsDevice, graphics.PreferredBackBufferWidth / 2, graphics.PreferredBackBufferHeight / 2);
            graphics.GraphicsDevice.SetRenderTarget(render_target);
            graphics.ApplyChanges();

            GraphicsDevice.Clear(Color.CornflowerBlue);

            // TODO: Add your drawing code here
            spriteBatch.Begin(SpriteSortMode.Immediate, null, SamplerState.PointClamp, null, null, null);

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

            newthing.Begin(SpriteSortMode.Immediate, null, SamplerState.PointClamp, null, null, null);
            Color textureColor = Color.White;
            if (levelToLoad != "") {
                textureColor *= ((float)levelLoadCooldown) / 60f;
                textureColor.A = 255;
            }
            newthing.Draw(render_target, new Rectangle(0, 0, graphics.PreferredBackBufferWidth, graphics.PreferredBackBufferHeight), (debug ? Color.FromNonPremultiplied(64, 64, 64, 255) : textureColor));
            newthing.End();

            //debug!
            if (debug) {
                world.DebugDraw.Flags = DebugDrawFlags.Shape;
                debugBatch.Begin();
                world.DrawDebugData();
                debugBatch.End();
            }

            base.Draw(gameTime);
        }
    }
}
