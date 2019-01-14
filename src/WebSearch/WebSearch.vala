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
        selector.column_spacing = 16;

        var label = new Gtk.Label (_("When launching a web search from within the Applications menu, use this search engine:"));

        var choice_label = new Gtk.Label (_("Search Engine"));
        selector.attach(choice_label, 0, 0, 1, 1);

        var engine_choice = new Gtk.ComboBoxText ();
        engine_choice.append_text (_("Google"));
        engine_choice.append_text (_("DuckDuckGo"));
        engine_choice.append_text (_("Bing"));
        engine_choice.append_text (_("Yahoo!"));
        selector.attach (engine_choice, 1, 0, 1, 1);

        this.attach(label, 0, 0, 1, 1);
        this.attach(selector, 0, 1, 1, 1);

        show_all ();
    }

    public Plug () {
    }
}
