#!/usr/bin/env python3
import json, sys

with open('/tmp/matugen_out.json') as f:
    data = json.load(f)

c = data['colors']
p = data['palettes']
m = 'dark'

def g(pal, t): return pal[str(t)]['color']

bg = c['background'][m]['color']
fg = c['on_background'][m]['color']
primary = c['primary'][m]['color']
surface = c['surface'][m]['color']
surface_c = c['surface_container'][m]['color']
error = c['error'][m]['color']
outline_v = c['outline_variant'][m]['color']
on_surface = c['on_surface'][m]['color']
secondary = c['secondary'][m]['color']

n = p['neutral']
e = p['error']
pr = p['primary']
s = p['secondary']
t = p['tertiary']

print(f'''foreground              {fg}
background              {bg}
selection_foreground    {surface}
selection_background    {primary}
cursor                  {primary}
cursor_text_color       {surface}
url_color               {primary}

active_border_color     {primary}
inactive_border_color   {outline_v}
bell_border_color       {error}

active_tab_foreground   {surface}
active_tab_background   {primary}
inactive_tab_foreground {fg}
inactive_tab_background {surface_c}
tab_bar_background      {bg}

mark1_foreground {fg}
mark1_background {surface_c}
mark2_foreground {surface}
mark2_background {primary}
mark3_foreground {on_surface}
mark3_background {secondary}

color0  {g(n, 10)}
color1  {g(e, 50)}
color2  {g(pr, 40)}
color3  {g(t, 60)}
color4  {g(pr, 60)}
color5  {g(s, 50)}
color6  {g(t, 50)}
color7  {g(n, 90)}
color8  {g(n, 50)}
color9  {g(e, 80)}
color10 {g(pr, 60)}
color11 {g(t, 80)}
color12 {g(pr, 80)}
color13 {g(s, 70)}
color14 {g(t, 60)}
color15 {g(n, 99)}''')
