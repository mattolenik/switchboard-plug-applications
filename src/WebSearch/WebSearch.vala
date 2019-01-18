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
    private Wingpanel.ApplicationsMenu.Settings settings;
    private const string default_engine = "duckduckgo";

    private static Gee.HashMap<string, string> search_engine_choices;

    private Gtk.Entry custom_query;
    private Gtk.Label custom_error;
    private Gtk.ComboBox engine_choice;
    private Gtk.Grid custom_box;
    private Gtk.ListStore store;

    static construct {
        search_engine_choices = new Gee.HashMap<string, string>();
        search_engine_choices["duckduckgo"] = _("DuckDuckGo (default)");
        search_engine_choices["google"]     = _("Google");
        search_engine_choices["bing"]       = _("Bing");
        search_engine_choices["yahoo"]      = _("Yahoo");
        search_engine_choices["yandex"]     = _("Yandex");
        search_engine_choices["baidu"]      = _("Baidu");
        search_engine_choices["custom"]     = _("Custom");
    }

    construct {
        this.halign = Gtk.Align.CENTER;
        this.row_spacing = 24;
        this.margin = 24;
        this.margin_top = 64;
        settings = new Wingpanel.ApplicationsMenu.Settings ();
        custom_box = new Gtk.Grid () {
            row_spacing = 5,
            column_spacing = 10,
            visible = false,
            no_show_all = true
        };
        custom_query = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = _("e.g. https://example.com/?q={query}")
        };
        custom_error = new Gtk.Label (null) {
            label = _("<span foreground='red'>The URL must contain {query} somewhere within it. Place {query} where the search terms should be.</span>"),
            use_markup = true,
            halign = Gtk.Align.START,
            no_show_all = true,
            visible = false
        };
        var custom_query_label = new Gtk.Label (null) {
            label = _("Custom URL"),
            halign = Gtk.Align.START,
            hexpand = false
        };
        custom_box.attach (custom_query_label, 0, 0, 1, 1);
        custom_box.attach (custom_query,       1, 0, 1, 1);
        custom_box.attach (custom_error,       0, 1, 2, 1);

        var selector = new Gtk.Grid () {
            halign = Gtk.Align.START,
            column_spacing = 10
        };

        var label = new Gtk.Label (_("Select the search engine to use when launching a web search from within the Applications menu."));

        var choice_label = new Gtk.Label (_("Search the web with"));
        selector.attach (choice_label, 0, 0, 1, 1);

        // This structure corresponds to the search_engine_choices map structure.
        store = new Gtk.ListStore (2, typeof (string), typeof (string));
        Gtk.TreeIter iter;
        foreach (var choice in search_engine_choices.entries) {
            store.append (out iter);
            store.set (iter, 0, choice.key, 1, choice.value);
        }

        engine_choice = new Gtk.ComboBox.with_model (store);
        selector.attach (engine_choice, 1, 0, 1, 1);
        var renderer = new Gtk.CellRendererText ();
        engine_choice.pack_start (renderer, true);
        engine_choice.add_attribute (renderer, "text", 1);

        string engine_id;
        if (settings.search_engine == null || settings.search_engine.length == 0) {
            engine_id = default_engine;
        } else {
            engine_id = settings.search_engine[0];
        }
        if (engine_id == "custom") {
            custom_query.text = settings.search_engine[1];
            custom_box.no_show_all = false;
            custom_box.visible = true;
            custom_query_changed();
        }
        iter = get_iter_for_id (engine_id) ?? get_iter_for_id (default_engine);
        engine_choice.set_active_iter (iter);
        engine_choice.changed.connect (() => {
            Gtk.TreeIter i;
            engine_choice.get_active_iter (out i);
            Value id;
            store.get_value (i, 0, out id);
            if ((string) id == "custom") {
                custom_query.text = settings.search_engine[1];
                settings.search_engine = new string[] { (string) id, custom_query.text };
                custom_box.visible = true;
                custom_box.no_show_all = false;
                custom_box.show_all ();
            } else {
                settings.search_engine = new string[] { (string) id };
                custom_box.visible = false;
                custom_box.no_show_all = true;
            }
        });

        custom_query.changed.connect (custom_query_changed);

        this.attach (label, 0, 0, 1, 1);
        this.attach (selector, 0, 1, 1, 1);
        this.attach (custom_box, 0, 2, 1, 1);

        show_all ();
    }

    private void custom_query_changed() {
        if (!custom_query.text.contains("{query}") && custom_query.text.length > 0) {
            debug("Custom query string does not contain {query}");
            custom_error.visible = true;
            custom_error.no_show_all = false;
            custom_error.show_all ();
        } else {
            custom_error.visible = false;
            custom_error.no_show_all = true;
        }
        settings.search_engine = new string[] { "custom", custom_query.text };
    }

    private Gtk.TreeIter? get_iter_for_id (string id) {
        Gtk.TreeIter iter;
        for (bool next = store.get_iter_first (out iter); next; next = store.iter_next (ref iter)) {
            Value id_value;
            store.get_value (iter, 0, out id_value);
            if ((string) id_value == id) {
                return iter;
            }
        }
        return null;
    }

    public Plug () {
    }
}
