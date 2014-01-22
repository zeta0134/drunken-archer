using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DrunkenArcher
{
    class GameObject
    {
        static int next_id = 1;
        int id;

        public double x = 0;
        public double y = 0;

        struct acceleration
        {
            double x;
            double y;
        };

        public GameObject(Lua vm)
        {
            id = next_id++;
            bind_to_lua(vm);
        }

        public int ID()
        {
            return id;
        }

        public void bind_to_lua(Lua vm)
        {

            Console.WriteLine("Attempting to bind a lua thingy...");

            string lua_name = "objects[" + id + "]";

            //vm[lua_name] = this;
            vm["object_to_bind"] = this;
        }
    }
}
