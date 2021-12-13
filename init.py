#!/usr/bin/env python3
import configparser
import os
import subprocess

config = configparser.ConfigParser()
config.optionxform = str
config_path = '/config/qBittorrent/config/qBittorrent.conf'

if os.path.exists(os.path.dirname(config_path)) != True:
    os.makedirs(os.path.dirname(config_path))
config.read(config_path)

options = {
    'LegalNotice': [{'opt': 'Accepted', 'val': 'true'}],
    'Preferences': [{'opt': 'Bittorrent\AutoUpdateTrackers', 'val': 'true'}, {'opt': 'Downloads\SavePath', 'val': '/data'}, {'opt': 'WebUI\Enabled', 'val': 'true'}, {'opt': 'WebUI\Address', 'val': '*'}, {'opt': 'WebUI\ServerDomains', 'val': '*'}, {'opt': 'WebUI\ClickjackingProtection', 'val': 'false'}, {'opt': 'WebUI\CSRFProtection', 'val': 'false'}, {'opt': 'WebUI\HostHeaderValidation', 'val': 'false'}, {'opt': 'Bittorrent\MaxRatio', 'val': os.getenv('UPLOAD_RATIO')}, {'opt': 'Connection\GlobalUPLimit', 'val': os.getenv('UPLOAD_SPEED')}, {'opt': 'Connection\PortRangeMin', 'val': os.getenv('PORT_BT')}, {'opt': 'WebUI\Port', 'val': os.getenv('PORT_UI')}, {'opt': 'Bittorrent\CustomizeTrackersListUrl', 'val': os.getenv('TRACKERS')}]
}
for s, o in options.items():
    try:
        config.add_section(s)
    except:
        pass
    for i in o:
        config[s][i['opt']] = i['val']

with open(config_path, 'w+') as file:
    config.write(file)

subprocess.run(['/usr/bin/qbittorrent-nox', '--profile=/config'], shell=False)
