/*
* Copyright (c) 2011-2018 elementary LLC. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Matthew Olenik <olenikm@gmail.com>
*/

public class WebSearch.Plug : Gtk.Grid {
    construct {
        this.halign = Gtk.Align.CENTER;
        this.row_spacing = 24;
        this.margin = 24;
        this.margin_top = 64;

        var selector = new Gtk.Grid ();
        selector.halign = Gtk.Align.START;
        selector.column_spacing = 10;

        var label = new Gtk.Label (_("Select the search engine to use when launching a web search from within the Applications menu."));

        var choice_label = new Gtk.Label (_("Search the web with"));
        selector.attach(choice_label, 0, 0, 1, 1);

        Gtk.ListStore store = new Gtk.ListStore (2, typeof (string), typeof (string));
        Gtk.TreeIter iter;
        store.append (out iter);
        store.set (iter, 0, "duckduckgo", 1, _("DuckDuckGo (default)"));
        store.append (out iter);
        store.set (iter, 0, "google",     1, _("Google"));
        store.append (out iter);
        store.set (iter, 0, "bing",       1, _("Bing"));
        store.append (out iter);
        store.set (iter, 0, "yahoo",      1, _("Yahoo!"));

        var engine_choice = new Gtk.ComboBox.with_model(store);
        selector.attach (engine_choice,   1, 0, 1, 1);
        var renderer = new Gtk.CellRendererText ();
        engine_choice.pack_start (renderer, true);
        engine_choice.add_attribute (renderer, "text", 1);
        engine_choice.active = 0;

        this.attach(label, 0, 0, 1, 1);
        this.attach(selector, 0, 1, 1, 1);

        show_all ();
    }

    public Plug () {
    }
}
