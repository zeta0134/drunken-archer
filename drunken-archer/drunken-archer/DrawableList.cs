using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DrunkenArcher {
    public class DrawableList : Drawable {
        public List<Drawable> items;

        public DrawableList() {
            items = new List<Drawable>();
        }

        public void Draw(Game game) {
            foreach (var i in items) {
                i.Draw(game);
            }
        }


    }
}
