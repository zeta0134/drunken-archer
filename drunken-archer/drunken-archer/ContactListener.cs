using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Box2D.XNA;
using NLua;

namespace DrunkenArcher {
    class ContactListener : IContactListener {
        Game game;
        Lua vm;
        
        public ContactListener(Game game, Lua vm) {
            this.game = game;
            this.vm = vm;
        }

        public void BeginContact(Contact contact) {
            GameObject a = (GameObject)contact.GetFixtureA().GetBody().GetUserData();
            GameObject b = (GameObject)contact.GetFixtureB().GetBody().GetUserData();
            if (a.collision_targets.Contains(b.collision_group) || b.collision_targets.Contains(a.collision_group)) {
                contactsToProcess.Add(contact);
            }            
        }
        public void EndContact(Contact contact) {

        }
        public void PreSolve(Contact contact, ref Manifold oldManifold) {
            
        }
        public void PostSolve(Contact contact, ref ContactImpulse impulse) {
            
        }

        private List<Contact> contactsToProcess = new List<Contact>();

        public void HandleEvents() {
            foreach (var contact in contactsToProcess) {
                GameObject a = (GameObject) contact.GetFixtureA().GetBody().GetUserData();
                GameObject b = (GameObject) contact.GetFixtureB().GetBody().GetUserData();

                if (a.collision_targets.Contains(b.collision_group)) {
                    vm.DoString("processCollision(" + a.ID() + ", " + b.ID() + ")");
                }
                
                if (b.collision_targets.Contains(a.collision_group)) {
                    vm.DoString("processCollision(" + b.ID() + ", " + a.ID() + ")");
                }
            }

            //discard the events (for the next frame or whatever)
            contactsToProcess.Clear();
        }
    }
}
