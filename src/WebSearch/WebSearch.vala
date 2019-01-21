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
    class Choice {
        public string text;
        public int sort_id;
    }

    private const string DEFAULT_ENGINE_ID = "duckduckgo";
    private const string CUSTOM_ENGINE_ID = "custom";
    private GLib.Settings gsettings;

    private static Gee.HashMap<string, Choice> search_engine_choices;

    private Gtk.Entry custom_query;
    private Gtk.Label custom_error;
    private Gtk.ComboBox engine_choice;
    private Gtk.Grid custom_box;
    private Gtk.ListStore store;
    private Gtk.Box enabled_box;
    private Gtk.Label enabled_label;
    private Gtk.Switch enabled_switch;
    private string STRAWBERRY = "#c6262e";  // From elementary human interface guidelines

    construct {
        /*
        * sort_id is used to pre-sort the items. We want alphabetical except for the default (placed at the top),
        * and custom (placed at the bottom). The reasoning being that it "feels right" to have the default option
        * most visible at the top, and custom, being the least likely to be used, at the bottom.
        */
        search_engine_choices = new Gee.HashMap<string, Choice> ();
        search_engine_choices["duckduckgo"] = new Choice () { sort_id = 0, text = _("DuckDuckGo (default)") };
        search_engine_choices["baidu"] = new Choice () { sort_id = 1, text = _("Baidu") };
        search_engine_choices["bing"] = new Choice () { sort_id = 2, text = _("Bing") };
        search_engine_choices["google"] = new Choice () { sort_id = 3, text = _("Google") };
        search_engine_choices["yahoo"] = new Choice () { sort_id = 4, text = _("Yahoo!") };
        search_engine_choices["yandex"] = new Choice () { sort_id = 5, text = _("Yandex") };
        search_engine_choices[CUSTOM_ENGINE_ID] = new Choice () { sort_id = 6, text = _("Custom") };

        this.halign = Gtk.Align.CENTER;
        this.row_spacing = 24;
        this.margin = 24;
        this.margin_top = 48;
        gsettings = new GLib.Settings ("io.elementary.desktop.wingpanel.applications-menu");
        custom_box = new Gtk.Grid () {
            row_spacing = 5,
            column_spacing = 10,
            visible = false,
            no_show_all = true
        };
        custom_query = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = _("https://example.com/?q={query}")
        };
        var error_text =
            @"<span color='$STRAWBERRY'>" +
            _("Search URL must be a valid URL that contains <b>{query}</b> wherever the search terms should appear, e.g. https://example.com/?q={query}") +
            "</span>";
        custom_error = new Gtk.Label (error_text) {
            use_markup = true,
            wrap = true,
            width_chars = 60,
            max_width_chars = 60,
            halign = Gtk.Align.START,
            justify = Gtk.Justification.LEFT,
            margin = 0,
            no_show_all = true,
            visible = false
        };
        custom_error.set_padding (0, 0);
        var custom_query_label = new Gtk.Label (_("Custom Search URL")) {
            halign = Gtk.Align.START,
            hexpand = false
        };
        custom_box.attach (custom_query_label, 0, 0, 1, 1);
        custom_box.attach (custom_query, 1, 0, 1, 1);
        custom_box.attach (custom_error, 1, 1, 1, 1);

        var selector = new Gtk.Grid () {
            halign = Gtk.Align.START,
            column_spacing = 10
        };

        var label = new Gtk.Label (
            _("Select the search engine to use when launching a web search from within the Applications menu."));

        var choice_label = new Gtk.Label (_("Search the web with"));
        selector.attach (choice_label, 0, 0, 1, 1);

        // This structure corresponds to the search_engine_choices map structure.
        store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (int));
        store.set_sort_column_id (2, Gtk.SortType.ASCENDING);
        Gtk.TreeIter iter;
        foreach (var choice in search_engine_choices.entries) {
            store.append (out iter);
            store.set (iter, 0, choice.key, 1, choice.value.text, 2, choice.value.sort_id);
        }

        engine_choice = new Gtk.ComboBox.with_model (store) {
            id_column = 0
        };
        selector.attach (engine_choice, 1, 0, 1, 1);
        var renderer = new Gtk.CellRendererText ();
        engine_choice.pack_start (renderer, true);
        engine_choice.add_attribute (renderer, "text", 1);

        gsettings.bind ("web-search-engine-id", engine_choice, "active_id", GLib.SettingsBindFlags.DEFAULT);
        gsettings.bind ("web-search-custom-url", custom_query, "text", GLib.SettingsBindFlags.DEFAULT);

        // Fall back to the default if a bad ID is found. This shouldn't happen unless the gsettings were tampered with.
        if (engine_choice.active_id == null || engine_choice.active_id.chomp () == "") {
            engine_choice.active_id = DEFAULT_ENGINE_ID;
        }

        if (engine_choice.active_id == CUSTOM_ENGINE_ID) {
            show_widget (custom_box);
        } else {
            hide_widget (custom_box);
        }

        engine_choice.changed.connect (() => {
            Gtk.TreeIter i;
            engine_choice.get_active_iter (out i);
            Value id;
            store.get_value (i, 0, out id);
            if ((string) id == CUSTOM_ENGINE_ID) {
                show_widget (custom_box);
            } else {
                hide_widget (custom_box);
            }
        });

        custom_query.changed.connect (check_custom_error);
        check_custom_error ();

        enabled_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10) {
            halign = Gtk.Align.CENTER
        };

        enabled_label = new Gtk.Label (null) {
            label = _("Enable Web Search")
        };

        enabled_switch = new Gtk.Switch ();

        gsettings.bind ("web-search-enabled", enabled_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        enabled_box.pack_start (enabled_label, false, false, 0);
        enabled_box.pack_start (enabled_switch, false, false, 0);

        this.attach (enabled_box, 0, 0, 1, 1);
        this.attach (label, 0, 1, 1, 1);
        this.attach (selector, 0, 2, 1, 1);
        this.attach (custom_box, 0, 3, 1, 1);

        show_all ();
    }

    private void check_custom_error () {
        if (!custom_query.text.contains ("{query}") && custom_query.text.length > 0) {
            show_widget (custom_error);
        } else {
            hide_widget (custom_error);
        }
    }

    private static void show_widget (Gtk.Widget w) {
        w.no_show_all = false;
        w.visible = true;
        w.show_all ();
    }

    private static void hide_widget (Gtk.Widget w) {
        w.no_show_all = true;
        w.visible = false;
    }

    public Plug () {
    }
}
